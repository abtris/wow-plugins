local TSMAuc = select(2, ...)
local Scan = TSMAuc:NewModule("Scan", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local auctionData = {}
local status = {}
local BASE_DELAY = 0.1


function Scan:OnInitialize()
	Scan:RegisterEvent("AUCTION_HOUSE_CLOSED", "AuctionHouseClosed")
	status.filterList = {}
end

function Scan:AuctionHouseClosed(postCancel)
	Scan:SendMessage("TSMAuc_AH_CLOSED")
	if status.isScanning then
		if not postCancel then
			TSMAuc:Print(L["Scan interrupted due to Auction House being closed."])
		end
		Scan:StopScanning(true)
	end
end

function Scan:StartItemScan(filterList)
	if #(filterList) == 0 then
		return
	end
	
	status.active = true
	status.isScanning = "item"
	status.page = 0
	status.retries = 0
	status.hardRetry = nil
	status.filterList = filterList
	status.filter = filterList[1]
	status.startFilter = #(filterList)
	status.classIndex = nil
	status.subClassIndex = nil
	
	wipe(auctionData)

	Scan:SendMessage("TSMAuc_START_SCAN", "item", #(status.filterList))
	Scan:SendQuery()
end

function Scan:StopScanning(interrupted)
	if not status.isScanning then return end
	
	status.active = nil
	status.isScanning = nil
	status.queued = nil
	
	Scan:SendMessage("TSMAuc_STOP_SCAN", interrupted)
	Scan:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	TSMAPI:CancelFrame("queryDelay")
	TSMAPI:CancelFrame("scanDelay")
end

function Scan:SendQuery(forceQueue)
	status.queued = not CanSendAuctionQuery()
	if not status.queued and not forceQueue then
		TSMAPI:CancelFrame("queryDelay")
		Scan:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
		QueryAuctionItems(status.filter.name, nil, nil, 0, 0, 0, status.page, 0, 0)
	else
		TSMAPI:CreateTimeDelay("queryDelay", 0.05, function() Scan:SendQuery() end)
	end
end

-- Add a new record
function Scan:AddAuctionRecord(name, link, owner, quantity, bid, buyout)
	-- Don't add this data if it has no buyout or is too big a stack
	if buyout <= 0 then return end
	local ignoreStacksOver = TSMAuc.Config:GetConfigValue(link, "ignoreStacksOver")
	local ignoreStacksUnder = TSMAuc.Config:GetConfigValue(link, "ignoreStacksUnder")
	if quantity > ignoreStacksOver or quantity < ignoreStacksUnder then return end
	
	auctionData[link] = auctionData[link] or {quantity = 0, onlyPlayer = true, records = {}}
	auctionData[link].quantity = auctionData[link].quantity + quantity
	
	-- Not only the player has posted this anymore :(
	if not TSMAuc.db.factionrealm.player[owner] then
		auctionData[link].onlyPlayer = nil
	end
	
	-- Find one thats unused if we can
	buyout = buyout / quantity
	bid = bid / quantity
	
	-- No sense in using a record for each entry if they are all the exact same data
	for _, record in pairs(auctionData[link].records) do
		if record.owner == owner and record.buyout == buyout and record.bid == bid then
			record.buyout = buyout
			record.bid = bid
			record.owner = owner
			record.quantity = record.quantity + quantity
			record.isPlayer = TSMAuc.db.factionrealm.player[owner]
			return
		end
	end
	
	-- Nothing available, create a new one
	table.insert(auctionData[link].records, {owner = owner, buyout = buyout, bid = bid, isPlayer = TSMAuc.db.factionrealm.player[owner], quantity = quantity})
end

function Scan:AUCTION_ITEM_LIST_UPDATE()
	status.timeDelay = 0

	Scan:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	TSMAPI:CancelFrame("scanDelay")
	Scan:ScanAuctions()
end

-- Time to scan auctions!
function Scan:ScanAuctions()
	local shown, total = GetNumAuctionItems("list")
	local totalPages = math.ceil(total / NUM_AUCTION_ITEMS_PER_PAGE)
		
	-- Check for bad data quickly
	if status.retries < 3 then
		-- Blizzard doesn't resolve the GUID -> name of the owner until GetAuctionItemInfo is called for it
		-- meaning will call it for everything on the list then if we had any bad data will requery
		local badData
		for i=1, shown do
			local name, _, _, _, _, _, _, _, _, _, _, owner = GetAuctionItemInfo("list", i)     
			if not name or not owner then
				badData = true
			end
		end
		
		if badData then
			-- Hard retry
			if status.hardRetry then
				status.retries = status.retries + 1
				Scan:SendMessage("TSMAuc_QUERY_UPDATE", "retry", status.filter, status.page + 1, totalPages, status.retries, 3)
				Scan:SendQuery()
			-- Soft retry
			else
				status.timeDelay = status.timeDelay + BASE_DELAY
				TSMAPI:CreateTimeDelay("scanDelay", BASE_DELAY, Scan.ScanAuctions)
	
				-- If after 4 seconds of retrying we still don't have data, will go and requery to try and solve the issue
				-- if we still don't have data, then we are going to go through with scanning it anyway
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
	
	-- Find the lowest auction (if any) out of this list
	for i=1, shown do
		local name, texture, quantity, _, _, _, bid, _, buyout, _, _, owner = GetAuctionItemInfo("list", i)
		-- if this is a gem, get the correct link for the gem, otherwise just get the link for the auction item
		local newGemLink = select(2, GetItemInfo(TSMAPI:GetNewGem(TSMAPI:GetItemID(GetAuctionItemLink("list", i))) or ""))
		local link = newGemLink or GetAuctionItemLink("list", i)
		Scan:AddAuctionRecord(name, TSMAuc:GetItemString(link), (owner or ""), quantity, bid, buyout)
	end

	-- This query has more pages to scan
	if shown == NUM_AUCTION_ITEMS_PER_PAGE then
		status.page = status.page + 1
		Scan:SendMessage("TSMAuc_QUERY_UPDATE", "page", status.filter, status.page + 1, totalPages)
		Scan:SendQuery()
		return
	end

	-- Finished with the filter
	Scan:SendMessage("TSMAuc_QUERY_UPDATE", "done", status.filter, totalPages, totalPages)
	
	-- Scanned all the pages for this filter, remove what we were just looking for then
	if status.isScanning == "item" then
		for i=#(status.filterList), 1, -1 do
			if status.filterList[i].itemID == status.filter.itemID then
				table.remove(status.filterList, i)
				break
			end
		end
		
		status.filter = status.filterList[1]
	end
	
	-- Query the next filter if we have one
	if status.filter then
		status.page = 0
		Scan:SendMessage("TSMAuc_QUERY_UPDATE", "next", status.filter, #(status.filterList), status.startFilter)
		Scan:SendQuery()
		return
	end
	
	Scan:StopScanning()
end

-- This gets how many auctions are posted specifically on this tier, it does not get how many of the items they up at this tier
-- but purely the number of auctions
function Scan:GetPlayerAuctionCount(link, findBuyout, findBid)
	findBuyout = math.floor(findBuyout)
	findBid = math.floor(findBid)
	
	local quantity = 0
	for i=1, GetNumAuctionItems("owner") do
		local name, _, stack, _, _, _, bid, _, buyout, _, _, _, wasSold = GetAuctionItemInfo("owner", i)
		local itemID = TSMAuc:GetItemString(GetAuctionItemLink("owner", i))
		if wasSold == 0 and itemID == link and findBuyout == math.floor(buyout / stack) and findBid == math.floor(bid / stack) then
			quantity = quantity + 1
		end
	end
	
	return quantity
end

function Scan:GetTotalItemQuantity(link)
	return auctionData[link] and auctionData[link].quantity or nil
end

function Scan:GetPlayerItemQuantity(link)
	if not auctionData[link] then return 0 end
	
	local total = 0
	for _, record in pairs(auctionData[link].records) do
		if record.isPlayer then
			total = total + record.quantity
		end
	end
	
	return total
end

function Scan:IsPlayerOnly(link)
	return auctionData[link] and auctionData[link].onlyPlayer
end

-- Check what the second lowest auction is and returns the difference as a percent
function Scan:CompareLowestToSecond(link, lowestBuyout)
	if not auctionData[link] then return end
	
	local buyout, bid, owner
	for _, record in pairs(auctionData[link].records) do
		if (not buyout or record.buyout < buyout) and record.buyout > lowestBuyout then
			buyout, bid, owner = record.buyout, record.bid, record.owner
		end
	end
	
	if buyout then
		local fallback = TSMAuc.Config:GetConfigValue(link, "fallback") * TSMAuc.Config:GetConfigValue(link, "fallbackCap")
		if fallback < buyout then return 0 end
	end
	
	return buyout and (buyout - lowestBuyout) / buyout or 0
end

function Scan:GetSecondLowest(link, lowestBuyout)
	if not auctionData[link] then return end
	
	local buyout, bid, owner
	for _, record in pairs(auctionData[link].records) do
		if (not buyout or record.buyout < buyout) and record.buyout > lowestBuyout then
			buyout, bid, owner = record.buyout, record.bid, record.owner
		end
	end
	
	return buyout, bid, owner
end

-- Find out the lowest price for this auction
function Scan:GetLowestAuction(itemID)
	if not auctionData[itemID] then return end
	
	-- Find lowest
	local buyout, bid, owner
	for _, record in pairs(auctionData[itemID].records) do
		if not buyout or record.buyout < buyout or (record.buyout == buyout and record.bid < bid) then
			buyout, bid, owner = record.buyout, record.bid, record.owner
		end
	end

	-- Now that we know the lowest, find out if this price "level" is a friendly person
	-- the reason we do it like this, is so if Apple posts an item at 50g, Orange posts one at 50g
	-- but you only have Apple on your white list, it'll undercut it because Orange posted it as well
	local isWhitelist, isPlayer = true, true
	for _, record in pairs(auctionData[itemID].records) do
		if not record.isPlayer and record.buyout == buyout then
			isPlayer = nil
			if not TSMAuc.db.factionrealm.whitelist[string.lower(record.owner)] then
				isWhitelist = nil
			end
			
			-- If the lowest we found was from the player, but someone else is matching it (and they aren't on our white list)
			-- then we swap the owner to that person
			buyout, bid, owner = record.buyout, record.bid, record.owner
		end
	end

	return buyout, bid, owner, isWhitelist, isPlayer
end

-- For advanced logging
function Scan:GetUndercuts(itemID)
	if not auctionData[itemID] then return end
	local data = {}
	local highest=0, lowestPlayer, lowest
	for _,record in pairs(auctionData[itemID].records) do
		if record.buyout > highest then highest = record.buyout end
	end
	lowestPlayer = highest
	lowest = highest
	for _,record in pairs(auctionData[itemID].records) do
		if record.buyout < lowest then lowest = record.buyout end
		if record.isPlayer and record.buyout < lowestPlayer then lowestPlayer = record.buyout end
	end
	for _,record in pairs(auctionData[itemID].records) do
		if record.buyout < lowestPlayer and record.buyout > lowest then
			tinsert(data, {buyout=record.buyout, bid=record.bid, owner=record.owner})
		end
	end
	return data
end

function Scan:StatusStats(itemID)
	if not auctionData[itemID] then return end
	mean = 0
	volume = 0
	i = 0
	for _,record in pairs(auctionData[itemID].records) do
		i=i+1
		volume=volume+record.quantity
		mean = mean + record.buyout
	end
	mean=mean/i
	return volume, mean
end
