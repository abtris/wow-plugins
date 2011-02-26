local TSMAuc = select(2, ...)
local Cancel = TSMAuc:NewModule("Cancel", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0")

local debug = function(...)
	if TSMDEBUG then
		print(...)
	end
end

local cancelQueue, currentItem, status = {}, {}, {}
local totalToCancel, totalCanceled, count = 0, 0, 0
local totalToScan, totalScanned = 0, 0
local isScanning, cancelError
local tempIndexList = {}

function Cancel:CancelMatch(match)
	status.type = "match"
	local scanList, tempList = {}, {}
	totalToCancel, totalCanceled, count = 0, 0, 0
	totalScanned, totalToScan = 1, 1
	wipe(cancelQueue)
	wipe(currentItem)
	cancelError = nil

	TSMAuc:UpdateItemReverseLookup()
	TSMAuc:UpdateGroupReverseLookup()
	
	local itemID = string.match(match, "item:(%d+)")
	if itemID then
		match = GetItemInfo(itemID)
	end
	status.info = match
	
	for i=GetNumAuctionItems("owner"), 1, -1 do
		local name, _, quantity, _, _, _, bid, _, buyout, _, _, _, wasSold = GetAuctionItemInfo("owner", i)
		local itemLink = GetAuctionItemLink("owner", i)
		local itemID = TSMAuc:GetItemString(itemLink)
		if wasSold == 0 and string.match(string.lower(name), string.lower(match)) then
			if not tempList[name] then
				tempList[name] = true
				TSMAuc.Log:AddMessage(string.format(L["Cancelled %s"], itemLink), name)
			end
			
			totalToCancel = totalToCancel + 1
			tinsert(cancelQueue, {itemID=itemID, stackSize=quantity, buyout=buyout, bid=bid, index=i})
		end
	end
	
	if totalToCancel == 0 then
		TSMAuc.Log:AddMessage(string.format(L["Nothing to cancel. No matches found for \"%s\""], match), "cancelstatus")
		TSMAuc:Print(L["Nothing to cancel"])
		return Cancel:StopCanceling()
	end
	
	Cancel:StartCancelScanning()
end

function Cancel:CancelAll(filter)
	local parsedArg = string.trim(string.lower(filter or ""))
	local group, duration, price
	if tonumber(parsedArg) then
		parsedArg = tonumber(parsedArg)
		if parsedArg ~= 12 and parsedArg ~= 2 then
			TSMAuc:Print(string.format(L["Invalid time entered, should either be 12 or 2 you entered \"%s\""], parsedArg))
			return Cancel:StopCanceling()
		end
		duration = parsedArg == 12 and 3 or 2 --3 = <12 hours, 2 = <2 hours
	elseif string.find(parsedArg, "([0-9]+)g") or string.find(parsedArg, "([0-9]+)s") or string.find(parsedArg, "([0-9]+)c") then
		local gold = tonumber(string.match(parsedArg, "([0-9]+)g"))
		local silver = tonumber(string.match(parsedArg, "([0-9]+)s"))
		local copper = tonumber(string.match(parsedArg, "([0-9]+)c"))
		price = (copper or 0) + ((gold or 0) * COPPER_PER_GOLD) + ((silver or 0) * COPPER_PER_SILVER)
		group = nil
	elseif parsedArg ~= "" then
		for name in pairs(TSMAuc.db.profile.groups) do
			if string.lower(name) == parsedArg then
				group = name
				break
			end
		end
		if not group then
			TSMAuc:Print(string.format(L["No group named %s exists."], parsedArg))
			return Cancel:StopCanceling()
		end
	end

	status.type = "all"
	status.info = {group, duration, price}
	local scanList, tempList = {}, {}
	totalToCancel, totalCanceled, count = 0, 0, 0
	totalScanned, totalToScan = 1, 1
	wipe(cancelQueue)
	wipe(currentItem)
	cancelError = nil

	TSMAuc:UpdateItemReverseLookup()
	TSMAuc:UpdateGroupReverseLookup()
	
	if duration then
		TSMAuc.Log:AddMessage(string.format(L["Mass cancelling posted items with less than %d hours left"], duration == 3 and 12 or 2), "masscancel")
	elseif group then
		TSMAuc.Log:AddMessage(string.format(L["Mass cancelling posted items in the group %s"], "|cfffed000"..group.."|r"), "masscancel")
	elseif price then
		TSMAuc.Log:AddMessage(string.format(L["Mass cancelling posted items below %s"], TSMAuc:FormatTextMoney(price)), "masscancel")
	else
		TSMAuc.Log:AddMessage(L["Mass cancelling posted items"], "masscancel")
	end
	TSMAuc.Log:AddMessage({scanType="Cancel", isHeader=true, scanData={}},"header")
	
	for i=GetNumAuctionItems("owner"), 1, -1 do
		local name, _, quantity, _, _, _, bid, _, buyout, _, _, _, wasSold = GetAuctionItemInfo("owner", i) 
		local timeLeft = GetAuctionItemTimeLeft("owner", i)
		local itemLink = GetAuctionItemLink("owner", i)
		local itemID = TSMAuc:GetItemString(itemLink)
		if wasSold == 0 and (group and TSMAuc.itemReverseLookup[itemID] == group or not group) and (duration and timeLeft <= duration or not duration) and (price and buyout <= price or not price) then
			if itemID and not tempList[itemID] then
				tempList[itemID] = true
				TSMAuc.Log:AddMessage({scanType="Cancel", itemID=itemID, scanData={postedBid=bid, postedBuyout=buyout}}, itemID)
			end
			
			totalToCancel = totalToCancel + 1
			tinsert(cancelQueue, {itemID=itemID, stackSize=quantity, buyout=buyout, bid=bid, index=i})
		end
	end
	
	if totalToCancel == 0 then
		TSMAuc.Log:AddMessage(L["Nothing to cancel"], "cancelstatus")
		TSMAuc:Print(L["Nothing to cancel"])
		return Cancel:StopCanceling()
	end
	
	Cancel:StartCancelScanning()
end

function Cancel:StartScan()
	status.type = "scan"
	local scanList, tempList = {}, {}
	totalToCancel, totalCanceled, count = 0, 0, 0
	totalScanned, totalToScan = 0, 0
	wipe(cancelQueue)
	wipe(currentItem)
	isScanning = true
	cancelError = nil

	TSMAuc:UpdateItemReverseLookup()
	TSMAuc:UpdateGroupReverseLookup()

	-- Add a scan based on items in the AH that match
	for i=GetNumAuctionItems("owner"), 1, -1 do
		if select(13, GetAuctionItemInfo("owner", i)) == 0 then
			local itemID = TSMAuc:GetItemString(GetAuctionItemLink("owner", i))
			if TSMAuc.itemReverseLookup[itemID] and not tempList[itemID] and TSMAuc.Config:ShouldScan(itemID, isCancel) then
				local name = GetItemInfo(itemID)
				tinsert(scanList, {name=name, itemID=itemID})
				tempList[itemID] = true
			end
		end
	end
	
	if #(scanList) == 0 then
		TSMAuc.Log:AddMessage(L["Nothing to cancel, you have no unsold auctions up."], "cancelstatus")
		return Cancel:StopCanceling()
	end
	totalToScan = #scanList
	TSMAuc.Log:AddMessage({scanType="Cancel", isHeader=true, scanData={}},"header")
	
	Cancel:StartCancelScanning(true)
	TSMAuc.Scan:StartItemScan(scanList)
end

function Cancel:StartCancelScanning(normalScan)
	Cancel:RegisterMessage("TSMAuc_AH_CLOSED", "MessageHandler")
	TSMAPI:ShowSidebarStatusBar()
	TSMAPI:SetSidebarStatusBarText(L["Scanning"])
	TSMAPI:UpdateSidebarStatusBar(0, true)
	TSMAPI:CreateTimeDelay("updateCancelStatus", 0, function()
			local cancelStatus = floor((totalScanned/totalToScan)*(count/totalToCancel)*100)
			if totalToCancel == 0 or totalToScan == 0 then cancelStatus = 0 end
			TSMAPI:UpdateSidebarStatusBar(cancelStatus)
		end, 0.3)
	
	if normalScan then
		Cancel:RegisterMessage("TSMAuc_QUERY_UPDATE", "MessageHandler")
		Cancel:RegisterMessage("TSMAuc_STOP_SCAN", "MessageHandler")
		TSMAuc.Manage.stopCancelingButton:Show()
		TSMAuc.Manage.cancelScanning:Show()
		TSMAPI:LockSidebar()
	else
		TSMAPI:SetSidebarStatusBarText(L["Canceling"])
		Cancel:UpdateCancelFrame()
	end
end

function Cancel:MessageHandler(msg, ...)
	if msg == "TSMAuc_QUERY_UPDATE" then
		local text, item = ...
		if text == "done" then
			totalScanned = totalScanned + 1
			TSMAPI:UpdateSidebarStatusBar((totalScanned/totalToScan)*100, true)
			Cancel:QueueItemToCancel(item.itemID)
		end
	elseif msg == "TSMAuc_STOP_SCAN" then
		isScanning = false
		TSMAPI:SetSidebarStatusBarText(L["Canceling"])
		local interrupted = ...
		if interrupted or totalToCancel == 0 then
			cancelError = nil
			Cancel:StopCanceling()
		else
			if TSMAuc.db.global.enableSounds then
				PlaySound("ReadyCheck")
			end
		end
	elseif msg == "TSMAuc_AH_CLOSED" then
		cancelError = nil
		Cancel:StopCanceling()
	end
end

function Cancel:QueueItemToCancel(itemID, noLog)
	local tempList = {}

	for i=GetNumAuctionItems("owner"), 1, -1 do
		local sID = TSMAuc:GetItemString(GetAuctionItemLink("owner", i))
		if itemID == sID then
			tinsert(tempList, i)
		end
	end

	for _, index in pairs(tempList) do
		local name, _, quantity, _, _, _, bid, _, buyout, activeBid, highBidder, _, wasSold = GetAuctionItemInfo("owner", index)     
		local itemLink = GetAuctionItemLink("owner", index)
		local itemID = TSMAuc:GetItemString(itemLink)
		local lowestBuyout, lowestBid, lowestOwner, isWhitelist, isPlayer = TSMAuc.Scan:GetLowestAuction(itemID)
		local lowestBuyouts = TSMAuc.Scan:GetUndercuts(itemID)
		local msgTable = {scanType="Cancel", itemID=itemID, scanData={lowestBuyout=lowestBuyout, lowestBid=lowestBid, lowestBuyoutOwner=lowestOwner, lowestBuyoutOwners=lowestBuyouts, postedBid=bid, postedBuyout=buyout}}
		if wasSold == 0 and lowestOwner then
			-- The item is in a group that's not supposed to be cancelled
			if TSMAuc.Config:GetBoolConfigValue(itemID, "noCancel") or TSMAuc.Config:GetBoolConfigValue(itemID, "disabled") then
				if not noLog then
					msgTable.scanData.action="Skip"
					TSMAuc.Log:AddMessage(msgTable, name.."notcancel")
				end
			elseif TSMAuc.Config:GetConfigValue(itemID, "reset") ~= "none" and lowestBuyout <= TSMAuc.Config:GetConfigValue(itemID, "threshold") then
				if not noLog then
					msgTable.scanData.action="Skip"
					TSMAuc.Log:AddMessage(msgTable, name.."notcancel")
				end
			-- It is supposed to be cancelled!
			else
				buyout = buyout / quantity
				bid = bid / quantity
				
				local threshold = TSMAuc.Config:GetConfigValue(itemID, "threshold")
				local fallback = TSMAuc.Config:GetConfigValue(itemID, "fallback")
				local priceDifference = TSMAuc.Scan:CompareLowestToSecond(itemID, lowestBuyout)
				local priceThreshold = TSMAuc.Config:GetConfigValue(itemID, "priceThreshold")
				
				-- Lowest is the player, and the difference between the players lowest and the second lowest are too far apart
				if isPlayer and priceDifference and priceDifference >= priceThreshold then
					-- The item that the difference is too high is actually on the tier that was too high as well
					-- so cancel it, the reason this check is done here is so it doesn't think it undercut itself.
					local undercut = TSMAuc.Config:GetConfigValue(itemID, "undercut")
					if math.floor(lowestBuyout) == math.floor(buyout) and undercut ~= 0 then
						if not noLog then
							msgTable.scanData.action="Cancel"
							TSMAuc.Log:AddMessage(msgTable, name.."cancel")
						end
						
						totalToCancel = totalToCancel + 1
						tinsert(cancelQueue, {itemID=itemID, stackSize=quantity, buyout=buyout*quantity, bid=bid*quantity, index=index})
					end
					
				-- They aren't us (The player posting), or on our whitelist so easy enough
				-- They are on our white list, but they undercut us, OR they matched us but the bid is lower
				-- The player is the only one with it on the AH and it's below the threshold
				elseif (not isPlayer and not isWhitelist) or
					isWhitelist and (buyout > lowestBuyout or (buyout == lowestBuyout and lowestBid < bid)) or
					TSMAuc.db.global.smartCancel and TSMAuc.Scan:IsPlayerOnly(itemID) and buyout < fallback then
					
					local undercutBuyout, undercutBid, undercutOwner
					if TSMAuc.db.factionrealm.player[lowestOwner] then
						undercutBuyout, undercutBid, undercutOwner = TSMAuc.Scan:GetSecondLowest(itemID, lowestBuyout)
					end

					undercutBuyout = undercutBuyout or lowestBuyout
					undercutBid = undercutBid or lowestBid
					undercutOwner = undercutOwner or lowestOwner
					
					-- Don't cancel if the buyout is equal, or below our threshold
					if TSMAuc.db.global.smartCancel and lowestBuyout <= threshold and not TSMAuc.Scan:IsPlayerOnly(itemID) then
						if not noLog then
							msgTable.scanData.action="Skip"
							TSMAuc.Log:AddMessage(msgTable, name.."notcancel")
						end
					-- Don't cancel an auction if it has a bid and we're set to not cancel those
					elseif not TSMAuc.db.global.cancelWithBid and activeBid > 0 then
						if not noLog then
							msgTable.scanData.action="Skip"
							TSMAuc.Log:AddMessage(msgTable, name.."notcancel")
						end
					else
						if not noLog then
							msgTable.scanData.action="Cancel"
							TSMAuc.Log:AddMessage(msgTable, name.."cancel")
						end
						
						totalToCancel = totalToCancel + 1
						tinsert(cancelQueue, {itemID=itemID, stackSize=quantity, buyout=buyout*quantity, bid=bid*quantity, index=index})
						Cancel:UpdateCancelFrame()
					end
				else
					if not noLog then
						msgTable.scanData.action="Skip"
						TSMAuc.Log:AddMessage(msgTable, name.."cancel")
					end
				end
			end
		end
	end
end

-- updates the cancel frame's icon and text with the current item
-- builds the frame / starts cancling if we aren't already canceling / the frame isn't shown
function Cancel:UpdateCancelFrame()
	if not Cancel.frame then
		if not isScanning and not (cancelQueue and cancelQueue[1]) then return end -- ensure the cancelQueue is available / being loaded
		TSMAuc.Manage:BuildAHFrame("Cancel")
	end
	
	if not Cancel.frame:IsVisible() then
		if not isScanning and not (cancelQueue and cancelQueue[1]) then return end
		Cancel:StartCanceling()
	end
	TSMAuc.Manage.stopCancelingButton:Hide()
	TSMAuc.Manage.cancelScanning:Hide()
	
	Cancel.frame.button:SetText(format(L["Cancel Auction %s / %s"], totalCanceled, totalToCancel))
	if currentItem.itemID then
		local _,link,_,_,_,_,_,_,_,texture = GetItemInfo(currentItem.itemID)
		
		Cancel.frame.link:SetText(link)
		Cancel.frame.stackSize:SetText(format(L["Stack Size: %s"], currentItem.stackSize))
		Cancel.frame.bid:SetText(format(L["Bid: %s"], TSMAuc:FormatTextMoney(currentItem.bid)))
		Cancel.frame.buyout:SetText(format(L["Buyout: %s"], TSMAuc:FormatTextMoney(currentItem.buyout)))
		
		if texture then
			Cancel.frame.iconButton:SetNormalTexture(texture)
		end
		Cancel.frame.iconButton.link = link
	end
end

-- register events and queue up the first item to cancel
function Cancel:StartCanceling()
	Cancel.frame:Show()
	TSMAuc.Manage.doneCanceling:Hide()
	Cancel:RegisterEvent("CHAT_MSG_SYSTEM")
	Cancel:RegisterEvent("UI_ERROR_MESSAGE")
	Cancel:UpdateItem()
end

-- Check if an auction was canceled and move on if so
function Cancel:CHAT_MSG_SYSTEM(_, msg)
	if msg == ERR_AUCTION_REMOVED then
		count = count + 1
	end
end

-- "Item Not Found" error
function Cancel:UI_ERROR_MESSAGE(event, msg)
	if msg == ERR_ITEM_NOT_FOUND then
		cancelError = true
		count = count + 1
	end
end

-- cancel the current item (gets called when the button is pressed
function Cancel:CancelItem()
	if not cancelQueue or not cancelQueue[1] then
		return
	end
	local index, backupIndex
	-- make sure the currentItem is accurate
	if cancelQueue[1].itemID ~= currentItem.itemID then
		Cancel:UpdateItem()
	end
	
	-- figure out which index the item goes to
	for i=GetNumAuctionItems("owner"), 1, -1 do
		local _, _, quantity, _, _, _, bid, _, buyout, activeBid = GetAuctionItemInfo("owner", i)
		local itemID = TSMAuc:GetItemString(GetAuctionItemLink("owner", i))
		if itemID == currentItem.itemID and buyout == currentItem.buyout and bid == currentItem.bid and (not TSMAuc.db.global.cancelWithBid and activeBid == 0 or TSMAuc.db.global.cancelWithBid) then
			if not tempIndexList[itemID..buyout..bid..i] then
				tempIndexList[itemID..buyout..bid..i] = true
				index = i
				break
			else
				backupIndex = i
			end
		end
	end
	
	-- if we found an index then cancel the item
	if index then
		CancelAuction(index)
	elseif backupIndex then
		CancelAuction(backupIndex)
	end
	
	-- disable the button and move onto the next item
	Cancel.frame.button:Disable()
	tremove(cancelQueue, 1)
	Cancel:UpdateItem()
end

local delay = 0
local function CountFrame()
	delay = delay + 1
	if count == totalToCancel then
		TSMAPI:CancelFrame("cancelCountFrame")
		Cancel:StopCanceling()
	elseif delay >= 30 then
		delay = 0
	end
end

local function DelayFrame()
	if not isScanning and #(cancelQueue) == 0 then
		TSMAPI:CreateFunctionRepeat("cancelCountFrame", CountFrame)
		TSMAPI:CancelFrame("cancelDelayFrame")
	elseif #(cancelQueue) > 0 then
		Cancel:UpdateItem()
		TSMAPI:CancelFrame("cancelDelayFrame")
	end
end

-- gets called when the "Skip Item" button is pressed
function Cancel:SkipItem()
	tremove(cancelQueue, 1)
	count = count + 1
	Cancel:UpdateItem()
end

-- updates the current item to the first one in the list
function Cancel:UpdateItem()
	if #(cancelQueue) == 0 then
		if isScanning then
			TSMAPI:CreateFunctionRepeat("cancelDelayFrame", DelayFrame)
		else
			TSMAPI:CreateFunctionRepeat("cancelCountFrame", CountFrame)
		end
		return
	end
	
	sort(cancelQueue, function(a, b) return (a.index or 0)>(b.index or 0) end)

	totalCanceled = totalCanceled + 1
	wipe(currentItem)
	currentItem = cancelQueue[1]
	Cancel:UpdateCancelFrame()
	Cancel.frame.button:Enable()
end

-- we are done canceling (maybe)
function Cancel:StopCanceling()
	wipe(tempIndexList)
	if not cancelError then -- didn't get "item not found" for any cancels so we are done
		TSMAPI:CancelFrame("cancelCountFrame")
		TSMAPI:CancelFrame("cancelDelayFrame")
		TSMAPI:CancelFrame("updateCancelStatus")
		TSMAPI:CancelFrame("enableDelay")
		pcall(TSMAPI.HideSidebarStatusBar)
		TSMAuc.Manage.doneCanceling:Show()
		TSMAuc.Manage.cancelScanning:Hide()
		TSMAuc.Manage.stopCancelingButton:Hide()
		TSMAuc.Log:AddMessage(L["Finished Canceling"], "finished")
		TSMAuc.Log:WipeLog()
		if Cancel.frame then Cancel.frame:Hide() end
		TSMAPI:UnlockSidebar()
	
		Cancel:UnregisterEvent("CHAT_MSG_SYSTEM")
		Cancel:UnregisterMessage("TSMAuc_QUERY_UPDATE")
		Cancel:UnregisterMessage("TSMAuc_STOP_SCAN")
		Cancel:UnregisterMessage("TSMAuc_AH_CLOSED")
		wipe(currentItem)
		wipe(status)
		totalToCancel, totalCanceled = 0, 0
		isScanning = false
	else -- got an "item not found" so requeue ones that we missed
		count = totalToCancel
		cancelError = nil
		local tempList = {}
		for i=GetNumAuctionItems("owner"), 1, -1 do
			local link = GetAuctionItemLink("owner", i)
			local itemID = TSMAuc:GetItemString(link)
			if status.type == "scan" then
				Cancel:QueueItemToCancel(itemID, true)
			elseif status.type == "all" then
				local group, duration, price = unpack(status.info)
				local name, _, quantity, _, _, _, bid, _, buyout, _, _, _, wasSold = GetAuctionItemInfo("owner", i) 
				local timeLeft = GetAuctionItemTimeLeft("owner", i)
				local itemLink = GetAuctionItemLink("owner", i)
				local itemID = TSMAuc:GetItemString(itemLink)
				if wasSold == 0 and (group and TSMAuc.itemReverseLookup[itemID] == group or not group) and (duration and timeLeft <= duration or not duration) and (price and buyout <= price or not price) then
					if itemID and not tempList[itemID] then
						tempList[itemID] = true
					end
					
					totalToCancel = totalToCancel + 1
					tinsert(cancelQueue, {itemID=itemID, stackSize=quantity, buyout=buyout, bid=bid, index=i})
				end
			elseif status.type == "match" then
				local name, _, quantity, _, _, _, bid, _, buyout, _, _, _, wasSold = GetAuctionItemInfo("owner", i)
				local itemLink = GetAuctionItemLink("owner", i)
				local itemID = TSMAuc:GetItemString(itemLink)
				if wasSold == 0 and string.match(string.lower(name), string.lower(status.info)) then
					if not tempList[name] then
						tempList[name] = true
					end
					
					totalToCancel = totalToCancel + 1
					tinsert(cancelQueue, {itemID=itemID, stackSize=quantity, buyout=buyout, bid=bid, index=i})
				end
			end
		end
		isScanning = false
		Cancel:UpdateItem()
	end
end