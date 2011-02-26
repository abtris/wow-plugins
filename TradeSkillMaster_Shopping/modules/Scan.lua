local TSM = select(2, ...)
local Scan = TSM:NewModule("Scan", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

-- create a second AceEvent object so that we can register events twice independently of each other
-- Scan events will be for general scanning
-- Scan.eventObject events will be for getting to the correct page to buy the next item
Scan.eventObject = {}
LibStub("AceEvent-3.0"):Embed(Scan.eventObject)

local status = {page=0, retries=0, timeDelay=0, AH=false, filterlist = {}}
local BASE_DELAY = 0.10 -- time to delay for before trying to scan a page again when it isn't fully loaded

local function debug(...)
	TSM:Debug(...)
end

function Scan:IsScanning()
	return status.isScanning
end

local QueryAuctionItems = QueryAuctionItems

-- Scan delay for hard reset
local frame = CreateFrame("Frame")
frame.timeElapsed = 0
frame:Hide()
frame:SetScript("OnUpdate", function(self, elapsed)
	self.timeElapsed = self.timeElapsed + elapsed
	if self.timeElapsed >= 0.05 then
		self.timeElapsed = self.timeElapsed - 0.05
		Scan:SendQuery()
	end
end)

-- Scan delay for soft reset
local frame2 = CreateFrame("Frame")
frame2:Hide()
frame2:SetScript("OnUpdate", function(self, elapsed)
	self.timeLeft = self.timeLeft - elapsed
	if self.timeLeft < 0 then
		self.timeLeft = 0
		self:Hide()

		Scan:ScanAuctions()
	end
end)

function Scan:OnEnable()
	Scan:RegisterEvent("AUCTION_HOUSE_CLOSED")
	Scan:RegisterEvent("AUCTION_HOUSE_SHOW", function() status.AH = true end)
end

-- gets called when the AH is closed
function Scan:AUCTION_HOUSE_CLOSED()
	Scan:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	status.AH = false
	if status.isScanning then -- stop scanning if we were scanning (pass true to specify it was interupted)
		Scan:StopScanning(true)
	end
end

-- prepares everything to start running a scan
function Scan:StartScan(scanQueue, scanType)
	if not status.AH then
		TSM:Print(L["Auction house must be open in order to scan."])
		return
	elseif #(scanQueue) == 0 then
		TSM:Print(L["Nothing to scan."])
		return
	elseif not CanSendAuctionQuery() then
		local delay = CreateFrame("Frame")
		delay:SetScript("OnUpdate", function(self)
				if CanSendAuctionQuery() then
					self:Hide()
					Scan:StartScan(self.scanQueue, self.scanType)
				end
			end)
		delay:Show()
		delay.scanQueue = scanQueue
		delay.scanType = scanType
		return
	end
	
	local ok, func = pcall(function() return AucAdvanced.Scan.Private.Hook.QueryAuctionItems end)
	if ok and TSM.db.global.blockAuc then
		QueryAuctionItems = func
	end
	
	-- sets up the non-function-local variables
	-- filter = current category being scanned for {class, subClass, invSlot}
	-- filterList = queue of categories to scan for
	status.data = {}
	status.page = 0
	status.retries = 0
	status.hardRetry = nil
	status.filterList = scanQueue
	status.filter = scanQueue[1]
	status.isScanning = scanType
	status.numItems = #(scanQueue)
	TSMAPI:LockSidebar()
	if TSM.automaticMode then
		TSM.Automatic.autoFrame.skipButton:Disable()
	elseif scanType == "Dealfinder" then
		TSM.Dealfinder.frame:DisableAll()
	end
	TSMAPI:ShowSidebarStatusBar()
	TSMAPI:SetSidebarStatusBarText(L["Shopping - Scanning"])
	TSMAPI:UpdateSidebarStatusBar(0)
	TSMAPI:UpdateSidebarStatusBar(0, true)
	TSM[scanType].frame.buyFrame:DisableButtons()
	
	--starts scanning
	Scan:SendQuery()
end

-- sends a query to the AH frame once it is ready to be queried (uses frame as a delay)
function Scan:SendQuery(forceQueue)
	if not status.isScanning then return end
	status.queued = not CanSendAuctionQuery()
	if (not status.queued and not forceQueue) then
		-- stop delay timer
		frame:Hide()
		
		-- Query the auction house (then waits for AUCTION_ITEM_LIST_UPDATE to fire)
		local filter = (type(status.filter) == "table" and status.filter.name) or (type(status.filter) == "string" and status.filter)
		debug("query", filter)
		Scan:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
		QueryAuctionItems(filter, nil, nil, 0, 0, 0, status.page, 0, 0)
	else
		-- run delay timer then try again to scan
		frame:Show()
	end
end

-- gets called whenever the AH window is updated (something is shown in the results section)
function Scan:AUCTION_ITEM_LIST_UPDATE()
	Scan:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	if status.isScanning then
		status.timeDelay = 0

		frame2:Hide()
		
		-- now that our query was successful we can get our data
		debug("scan2", status.filter.name)
		Scan:ScanAuctions()
	end
end

-- scans the currently shown page of auctions and collects all the data
function Scan:ScanAuctions()
	if not status.isScanning then return end
	-- collects data on the query:
		-- # of auctions on current page
		-- # of pages total
	local shown, total = GetNumAuctionItems("list")
	local totalPages = math.ceil(total / 50)
	local quantity, buyout = {}, {}
	
	-- Check for bad data
	if status.retries < 3 then
		local badData
		
		for i=1, shown do
			-- checks whether or not the name of the auctions are valid
			-- if not, the data is bad
			_, _, quantity[i], _, _, _, _, _, buyout[i] = GetAuctionItemInfo("list", i)
			if not (quantity[i] and buyout[i]) then
				badData = true
			end
		end
		
		if badData then
			if status.hardRetry then
				-- Hard retry
				-- re-sends the entire query
				status.retries = status.retries + 1
				Scan:SendQuery()
			else
				-- Soft retry
				-- runs a delay and then tries to scan the query again
				status.timeDelay = status.timeDelay + BASE_DELAY
				frame2.timeLeft = BASE_DELAY
				frame2:Show()
	
				-- If after 4 seconds of retrying we still don't have data, will go and requery to try and solve the issue
				-- if we still don't have data, we try to scan it anyway and move on.
				if status.timeDelay >= 4 then
					status.hardRetry = true
					status.retries = 0
				end
			end
			
			return
		end
	end
	
	status.hardRetry = nil
	status.retries = 0
	TSMAPI:UpdateSidebarStatusBar(floor(status.page/totalPages*100 + 0.5), true)
	TSMAPI:UpdateSidebarStatusBar(floor((1-(#(status.filterList)-status.page/totalPages)/status.numItems)*100 + 0.5))
	
	-- now that we know our query is good, time to verify and then store our data
	for i=1, shown do
		local itemID = TSMAPI:GetItemID(GetAuctionItemLink("list", i))
		if type(status.filter) == "table" and itemID == status.filter.itemID then
			Scan:AddAuctionRecord(itemID, quantity[i], buyout[i], status.page)
		elseif type(status.filter) == "string" and strlower(GetItemInfo(itemID) or ""):match(strlower(status.filter)) then
			Scan:AddAuctionRecord(itemID, quantity[i], buyout[i], status.page)
		else
			debug("bad filter", status.filter.name, status.filter.itemID, itemID)
		end
	end

	-- This query has more pages to scan
	-- increment the page # and send the new query
	if totalPages > (status.page + 1) then
		status.page = status.page + 1
		Scan:SendQuery()
		return
	end
	
	-- Removes the current filter from the filterList as we are done scanning for that item
	for i=1, #(status.filterList) do
		if status.filterList[i] == status.filter then
			tremove(status.filterList, i)
			break
		end
	end
	
	-- Query the next filter if we have one
	if status.filterList[1] then
		status.filter = status.filterList[1]
		TSMAPI:UpdateSidebarStatusBar(floor((1-#(status.filterList)/status.numItems)*100 + 0.5))
		status.page = 0
		Scan:SendQuery()
		return
	end
	
	-- we are done scanning!
	Scan:StopScanning()
end

-- Add a new record to the status.data table
function Scan:AddAuctionRecord(itemID, quantity, buyout, page)
	-- Don't add this data if it has no buyout
	if (not buyout) or (buyout <= 0) then return end

	status.data[itemID] = status.data[itemID] or {quantity = 0, records = {}}
	status.data[itemID].quantity = status.data[itemID].quantity + quantity
	
	-- Calculate the bid / buyout per 1 item
	buyout = buyout / quantity
	
	-- Create a new entry in the table
	tinsert(status.data[itemID].records, {buyout=buyout, quantity=quantity, page=page})
end

-- stops the scan because it was either interupted or it was completed successfully
function Scan:StopScanning(interupted)
	if not status.isScanning then return end
	if not TSM.automaticMode then
		TSMAPI:UnlockSidebar()
	end
	TSMAPI:HideSidebarStatusBar()
	if interupted == true then
		-- fires if the scan was interupted (auction house was closed while scanning)
		TSM:Print(L["Scan interupted due to auction house being closed."])
	elseif interupted == "Automatic" then
		TSM:Print(L["Scan interupted due to automatic mode being canceled."])
	else
		-- fires if the scan completed sucessfully
		TSM[status.isScanning]:Process(status.data)
	end
	
	if not TSM[status.isScanning].waitingOnEvent then
		TSM[status.isScanning].frame.buyFrame:EnableButtons()
	end
	status.isScanning = nil
	status.queued = nil
	
	frame:Hide()
	frame2:Hide()
end

function Scan:ScanPageForAuction(auction)
	local validQuery = false
	for i=GetNumAuctionItems("list"), 1, -1 do
		local itemID = TSMAPI:GetItemID(GetAuctionItemLink("list", i))
		local _, _, quantity, _, _, _, _, _, buyout = GetAuctionItemInfo("list", i)
		if not itemID or not quantity then debug("INVALID AUCTION ITEM", i, itemID, quantity) end
		if itemID == auction.itemID and quantity == auction.quantity and abs(buyout - auction.buyout) < 0.1 then
			return i
		elseif itemID == auction.itemID then
			validQuery = true
		end
	end
	return validQuery and 0
end

function Scan:FindAuction(callback, itemID, quantity, buyout, page)
	local index = Scan:ScanPageForAuction({itemID=itemID, quantity=quantity, buyout=buyout})
	if index and index ~= 0 then
		-- we found the item on the current page
		callback(nil, index)
		return
	end
	
	-- delays until all the data is available to be scanned
	Scan.eventObject.frame = Scan.eventObject.frame or CreateFrame("Frame")
	Scan.eventObject.frame:Hide()
	Scan.eventObject.frame:SetScript("OnUpdate", function(self, elapsed)
			if not self.timeLeft then self.timeLeft = BASE_DELAY end
			self.timeLeft = self.timeLeft - elapsed
			if self.timeLeft <= 0 then
				self.timeLeft = nil
				-- if the page hasn't loaded wait BASE_DELAY seconds
				if Scan:VerifyPageData() then
					-- the queried page has loaded
					self:Hide()
					Scan.pagesTried[Scan.tryPage or -1] = true
					local index = Scan:ScanPageForAuction({itemID=itemID, quantity=quantity, buyout=buyout})
					debug(itemID, quantity, buyout, index)
					if index and index ~= 0 then
						-- we found the item!
						Scan:findAuctionCallback(index)
					else
						-- no luck - query the next page
						Scan:LookForItem(itemID, quantity, buyout)
					end
				end
			end
		end)
	
	Scan.findAuctionCallback = function(self, index)
			Scan.eventObject:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			callback(self, index)
		end
	Scan.pagesTried = wipe(Scan.pagesTried or {})
	Scan.eventObject:RegisterEvent("AUCTION_HOUSE_CLOSED", function() Scan.eventObject:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE") end)
			
	if index == 0 then
		-- item is not on the current page
		Scan:LookForItem(itemID, quantity, buyout, page)
	else
		-- the current AH query is not correct
		Scan:LookForItem(itemID, quantity, buyout)
	end
end

local queryDelay = CreateFrame("Frame")
queryDelay:Hide()
queryDelay:RegisterEvent("AUCTION_HOUSE_CLOSED")
queryDelay:SetScript("OnEvent", function(self) self:Hide() end)
queryDelay:SetScript("OnUpdate", function(self)
		if CanSendAuctionQuery() then
			debug("Can't Send Query")
			self:Hide()
			Scan:LookForItem(unpack(self.info))
		end
	end)

function Scan:LookForItem(itemID, quantity, buyout, page)
	if not CanSendAuctionQuery() then
		queryDelay.info = {itemID, quantity, buyout, page}
		queryDelay:Show()
		return
	end

	local name = TSM:GetItemName(itemID)
	if not name then debug("NO NAME", itemID) end
	
	if page == AuctionFrameBrowse.page then
		-- we expected the item to be on this page but didn't find it
		-- try the previous page (unless we are on page 0 in which case go to page 1)
		Scan.tryPage = page - 1
		if page < 0 then page = 0 end
		debug("TRY-A", Scan.tryPage)
		QueryAuctionItems(name, nil, nil, 0, 0, 0, Scan.tryPage, 0, 0)
		Scan.eventObject:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", function()
				Scan.eventObject:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
				Scan.eventObject.frame:Show()
			end)
	else
		-- query the pages in order starting from page 0
		local tryPage
		local totalPages = ceil(select(2, GetNumAuctionItems("list"))/50)
		for i=0, totalPages-1 do
			-- find a page we haven't tried yet
			if not Scan.pagesTried[i] then
				tryPage = i
				break
			end
		end
		
		if not Scan.pagesTried[0] then
			tryPage = 0
		end
		
		if tryPage then
			Scan.tryPage = tryPage
			debug("TRY-B", tryPage)
			QueryAuctionItems(name, nil, nil, 0, 0, 0, tryPage, 0, 0)
			Scan.eventObject:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", function()
					Scan.eventObject:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
					Scan.eventObject.frame:Show()
				end)
		else
			-- we tried all the pages and didn't find the item
			Scan:findAuctionCallback()
		end
	end
end

function Scan:VerifyPageData()
	for i=1, GetNumAuctionItems("list") do
		-- checks whether or not the name of the auctions are valid
		-- if not, the data is bad
		local _, _, quantity, _, _, _, _, _, buyout = GetAuctionItemInfo("list", i)
		if not (quantity and buyout) then
			return false
		end
	end
	if GetNumAuctionItems("list") == 0 then debug("zero auctions to scan!") end
	return true
end