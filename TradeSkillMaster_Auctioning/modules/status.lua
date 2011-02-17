local TSMAuc = select(2, ...)
local Status = TSMAuc:NewModule("Status", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
local statusList = {}


function Status:Scan()
	local tempList = {}
	wipe(statusList)
	
	TSMAuc:UpdateItemReverseLookup()
	TSMAuc:UpdateGroupReverseLookup()
	
	-- Add items from the player's bags
	for bag=0, 4 do
		if TSMAuc:IsValidBag(bag) then
			for slot=1, GetContainerNumSlots(bag) do
				local itemID = TSMAuc:GetItemString(GetContainerItemLink(bag, slot))
				if itemID and TSMAuc.itemReverseLookup[itemID] then
					tempList[itemID] = true
				end
			end
		end
	end
	
	-- Add items which the player has on the AH
	for i=1, GetNumAuctionItems("owner") do
		if select(13, GetAuctionItemInfo("owner", i)) == 0 then
			local itemID = TSMAuc:GetItemString(GetAuctionItemLink("owner", i))
			if itemID and TSMAuc.itemReverseLookup[itemID] then
				tempList[itemID] = true
			end
		end
	end
	
	for itemID in pairs(tempList) do
		tinsert(statusList, {name=GetItemInfo(itemID), itemID=itemID})
	end
	
	if #(statusList) == 0 then
		TSMAuc.Log:AddMessage(L["No auctions or inventory items found that are managed by Auction Profit Master that can be scanned."], "statusstatusmushroommushroom")
		return
	end
	TSMAuc.Log:AddMessage({scanType="Status", isHeader=true, scanData={}},"header")
	Status:RegisterMessage("TSMAuc_QUERY_UPDATE")
	Status:RegisterMessage("TSMAuc_STOP_SCAN")
	TSMAPI:LockSidebar()
	TSMAuc.Scan:StartItemScan(CopyTable(statusList))
end

-- Log handler
function Status:TSMAuc_QUERY_UPDATE(event, type, filter, ...)
	if not filter then return end
	filter = filter.name
	
	if type == "retry" then	
		local page, totalPages, retries, maxRetries = ...
		TSMAuc.Log:AddMessage(string.format(L["Retry %s of %s for %s"], "|cfffed000"..retries.."|r", "|cfffed000"..maxRetries.."|r", filter), filter)
	elseif type == "page" then
		local page, totalPages = ...
		TSMAuc.Log:AddMessage(string.format(L["Scanning page %s of %s for %s"], "|cfffed000"..page.."|r", "|cfffed000"..totalPages.."|r", filter), filter)
	elseif type == "done" then
		local page, totalPages = ...
		TSMAuc.Log:AddMessage(string.format(L["Scanned page %s of %s for %s"], "|cfffed000"..page.."|r", "|cfffed000"..totalPages.."|r", filter), filter)
	elseif type == "next" then
		TSMAuc.Log:AddMessage(string.format(L["Scanning %s"], filter), filter)
	end
end

function Status:TSMAuc_STOP_SCAN(event, interrupted)
	Status:UnregisterMessage("TSMAuc_QUERY_UPDATE")
	Status:UnregisterMessage("TSMAuc_STOP_SCAN")

	if interrupted then
		TSMAuc.Log:AddMessage(L["Scan interrupted before it could finish"], "scaninterrupt")
		return
	end

	TSMAuc.Log:AddMessage(L["Scan finished!"], "scandone")
	
	Status:OutputResults()
end

function Status:OutputResults()
	table.sort(statusList, function(a, b) return TSMAuc.itemReverseLookup[a.itemID] < TSMAuc.itemReverseLookup[b.itemID] end)
	
	for _, data in pairs(statusList) do
		local itemID = data.itemID
		local itemLink = select(2, GetItemInfo(itemID))
		local lowestBuyout, lowestBid, lowestOwner = TSMAuc.Scan:GetLowestAuction(itemID)
		local volume, mean = TSMAuc.Scan:StatusStats(itemID)
		local msgTable={scanType="Status", itemID=itemID, scanData={lowestBuyout=lowestBuyout, lowestBid=lowestBid, lowestBuyoutOwner=lowestOwner, lowestBuyoutOwners=TSMAuc.Scan:GetUndercuts(itemID), marketVolume=volume, currentMarketMean=mean, postedAmount=TSMAuc.Scan:GetPlayerItemQuantity(itemID)}}
		if lowestBuyout then
			local quantity = TSMAuc.Scan:GetTotalItemQuantity(itemID)
			local playerQuantity = TSMAuc.Scan:GetPlayerItemQuantity(itemID)
			TSMAuc.Log:AddMessage(msgTable, select(1, GetItemInfo(itemID)))
		else
			TSMAuc.Log:AddMessage(string.format(L["Cannot find data for %s."], itemLink or data.name), itemID .. "statusres")
		end
	end
	
	TSMAuc.Log:AddMessage(L["Finished status report"], "statusresdone")
	TSMAPI:UnlockSidebar()
	TSMAuc.Log:WipeLog()
	wipe(statusList)
end