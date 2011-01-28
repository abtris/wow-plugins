--[[
	Adds a new tab to the auction house for more convinient selling of items.
	Enables the selling of many items at once, prefills the desired prizes and
	remembers them.
	
	Copyright (C) Udorn (Blackhand)
	
	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.	
--]]

vendor.Seller = vendor.Vendor:NewModule("Seller", "AceEvent-3.0", "AceHook-3.0");
local L = vendor.Locale.GetInstance()
local self = vendor.Seller;
local log = vendor.Debug:new("Seller")

vendor.Seller.PRIZE_MODEL_FIX = 1
vendor.Seller.PRIZE_MODEL_MARKET = 2
vendor.Seller.PRIZE_MODEL_CURRENT = 3
vendor.Seller.PRIZE_MODEL_UNDERCUT = 4
vendor.Seller.PRIZE_MODEL_MULTIPLIER = 5
vendor.Seller.PRIZE_MODEL_LOWER = 6

local SELLER_TAB = "seller"
local INVENTORY_LINE_HEIGHT = 27
local INVENTORY_LINES = 11
local DURATIONS = {1, 2, 3}
local STACK_DROPDOWN_ID = 1
local COUNT_DROPDOWN_ID = 2
local PRIZING_DROPDOWN_ID = 3
local DURATION_DROPDOWN_ID = 5
local MARKET_PERCENT = 2
local SELLER_VERSION = 5
local BID_TYPES = {L["Per item"], L["Stack"], L["Overall"]} 
local UPDATE_INTERVAL = 1

--[[
	Migrates the database.
--]]
local function _MigrateDb(self)
	if (not self.db.profile.version or self.db.profile.version < 5) then
		self.db.profile.buyoutMod = {}
		self.db.profile.buyoutMod[self.PRIZE_MODEL_MARKET] = {percent = self.db.profile.marketBuyoutMul or 150, modType = 1}
		self.db.profile.buyoutMod[self.PRIZE_MODEL_CURRENT] = {percent = self.db.profile.currentBuyoutMul or 100, modType = 1}
		self.db.profile.buyoutMod[self.PRIZE_MODEL_UNDERCUT] = {percent = self.db.profile.undercutBuyoutMul or 99, modType = 1}
		self.db.profile.buyoutMod[self.PRIZE_MODEL_LOWER] = {percent = self.db.profile.lowerBuyoutMul or 99, modType = 1}
		self.db.profile.buyoutMod[self.PRIZE_MODEL_MULTIPLIER] = {percent = self.db.profile.multiplierBuyoutMul or 250, modType = 1}
		self.db.profile.defaultDuration = 3
		self.db.profile.marketBuyoutMul = nil
		self.db.profile.currentBuyoutMul = nil
		self.db.profile.undercutBuyoutMul = nil
		self.db.profile.lowerBuyoutMul = nil
		self.db.profile.multiplierBuyoutMul = nil
	end	
	self.db.profile.version = SELLER_VERSION
end
    	
--[[
	Updates some fonts.
--]]
local function _UpdateFonts(self)
	if (self.buyoutFont) then
		self.buyoutFont:SetText(L["Buyout Price"].." |cff808080("..BID_TYPES[self.db.profile.bidType]..")|r")
	end
	if (self.minBidFont) then
		self.minBidFont:SetText(L["Starting Price"].." |cff808080("..BID_TYPES[self.db.profile.bidType]..")|r")
	end
end

local function _FindItemInBag(itemLink)
	local itemKey = vendor.Items:GetItemLinkKey(itemLink)
	for bag = 0, 4 do
   		for slot = 1, GetContainerNumSlots(bag) do
	   		local slotLink = GetContainerItemLink(bag, slot);
	   		if (slotLink) then
		   		local slotKey = vendor.Items:GetItemLinkKey(slotLink);
				if (itemKey == slotKey) then
					return bag, slot
				end
			end
		end
	end
	return nil
end

local function _Sell(itemLink, minBid, buyout, runTime, stackSize, stackCount)
	log:Debug("_Sell stackSize [%s] stackCount [%s]", stackSize, stackCount)
	ClearCursor()
	vendor.clickAuctionSellItemButton()
	ClearCursor()
	
	local bag, slot = _FindItemInBag(itemLink, reverse) 
	if (bag and slot) then
		PickupContainerItem(bag, slot)
		vendor.clickAuctionSellItemButton()
		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo()
		local itemName = GetItemInfo(itemLink)
		log:Debug("_Sell itemName [%s] name [%s] count [%s]", itemName, name, count)
		if (not itemName or not name or itemName ~= name) then
			vendor.Vendor:Error(L["Failed to create stack of %d items."]:format(stackSize))
		else
			StartAuction(minBid * stackSize, buyout * stackSize, runTime, stackSize, stackCount)
			vendor.clickAuctionSellItemButton()
		end
		ClearCursor()
	end
end

--[[
	New ScanSet has arrived.
--]]
local function _ScanSetUpdate(self, scanSet)
	if (scanSet) then
    	log:Debug("_ScanSetUpdate")
    	if (scanSet:Size() == 0) then
    		self.itemTable:SetFadingText(L["No matching auctions found."])
    	end
    	local prizeModel = self.prizingDropDown:GetSelectedValue()
    	if (prizeModel ~= self.PRIZE_MODEL_FIX) then
    		self.auto:Update()
    		self:RefreshPrices()
    	end
    	local key
    	if (self.item) then
    		key = self.item.itemLinkKey
    	elseif (self.lastItem) then
    		key = self.lastItem.itemLinkKey
    	end
    	log:Debug("_ScanSetUpdate our key: %s scanSetKey: %s", key or "na", scanSet:GetItemLinkKey())
    	if (key and key == scanSet:GetItemLinkKey()) then
    		log:Debug("set new scanset of size [%s]", scanSet:Size())
    		self.itemModel:SetScanSet(scanSet)
    		self.itemTable:Show()
    	end
    --	_PrintUpToDateness(self)
    end
    log:Debug("_ScanSetUpdate exit");
end

--[[
	The refresh button has been clicked. A scan will be triggered.
--]]
local function _RefreshClicked(self)
	log:Debug("_RefreshClicked enter")
	local waitForOwners
	for _,id in pairs(self.db.profile.itemTableCfg.selected) do
		if (id == vendor.ScanSetItemModel.OWNER) then
			waitForOwners = true
			break
		end
	end		
	if (self.item) then
		log:Debug("_RefreshClicked key1: %s", self.item.itemLinkKey)
		--self.itemModel:SetScanSet(vendor.ScanSet:new({}, vendor.AuctionHouse:IsNeutral(), self.item.itemLinkKey))
		vendor.Scanner:Scan(self.item.link, false, nil, nil, nil, waitForOwners)
	elseif (self.lastItem) then
		log:Debug("_RefreshClicked key2: %s", self.lastItem.itemLinkKey)
		self.itemModel:SetScanSet(vendor.ScanSet:new({}, vendor.AuctionHouse:IsNeutral(), self.lastItem.itemLinkKey))
		vendor.Scanner:Scan(self.lastItem.link, false, nil, nil, nil, waitForOwners)
	end
	self.itemTable:Show()
	log:Debug("_RefreshClicked exit")
end
	
--[[
	Cancels the selected list of items.
--]]
local function _CancelAuctions(self)
	local auctions = {}
	for _,row in pairs(self.itemModel:GetSelectedItems()) do
		local itemLinkKey, itemLink, _, count, minBid, _, buyout, bidAmount = self.itemModel:Get(row)
		table.insert(auctions, {itemLinkKey = itemLinkKey, itemLink = itemLink, count = count, minBid = minBid, buyout = buyout, bidAmount = bidAmount})
	end
	vendor.OwnAuctions:CancelAuctions(auctions)
end

--[[
	Bids on the selected list of items.
--]]
local function _Bid(self)
	local auctions = {}
	for _,row in pairs(self.itemModel:GetSelectedItems()) do
		local itemLinkKey, itemLink, _, count, minBid, minIncrement, buyout, bidAmount = self.itemModel:Get(row)
   		local bid = minBid
   		if (bidAmount and bidAmount > 0) then
   			bid = bidAmount + (minIncrement or 0) 
   		end
   		local itemLink = vendor.Items:GetItemLink(itemLinkKey)
		local name = GetItemInfo(itemLink)
   		local info = {itemLink = itemLink, name = name, count = count, bidAmount = bidAmount, minBid = minBid, buyout = buyout, bid = bid, doBid = true, reason = L["Bid"]}
   		table.insert(auctions, info)
	end
	vendor.Scanner:BuyScan(auctions, _RefreshClicked, self)
end

--[[
	Buys the selected list of items.
--]]
local function _Buyout(self)
	local auctions = {}
	local rows = {}
	for _,row in pairs(self.itemModel:GetSelectedItems()) do
		table.insert(rows, row)
		local itemLinkKey, _, _, count, minBid, _, buyout, bidAmount = self.itemModel:Get(row)
   		local itemLink = vendor.Items:GetItemLink(itemLinkKey)
		local name = GetItemInfo(itemLink)
   		local info = {itemLink = itemLink, name = name, count = count, bidAmount = bidAmount, minBid = minBid, buyout = buyout, bid = buyout, doBuyout = true, reason = L["Buy"]}
   		table.insert(auctions, info)
	end
	vendor.Scanner:BuyScan(auctions, _RefreshClicked, self)
end

local CMDS = {
	refresh = {
		title = L["Refresh"],
		tooltip = L["Scans the auction house for the item to be sold."],
		alignLeft = true,
		arg1 = vendor.Seller,
		func = function(arg1) _RefreshClicked(arg1) end,
		enabledFunc = function(self)
			return self.itemModel:GetScanSet()
		end,
		order = 9
	},
	bid = {
		title = L["Bid"],
		tooltip = L["Bids on all selected items."].." "..L["Auctions may be selected with left clicks. Press the ctrl button, if you want to select multiple auctions. Press the shift button, if you want to select a range of auctions."],
		arg1 = vendor.Seller,
		func = function(arg1) _Bid(arg1) end,
		enabledFunc = function(self)
			local rtn = false
			for _,row in pairs(self.itemModel:GetSelectedItems()) do
				rtn = true
				local _, _, _, _, _, _, _, _, owner = self.itemModel:Get(row)
				if (self.playerName == owner) then
					rtn = false
					break
				end
			end
			return rtn
		end,
		order = 10
	},
	buy = {
		title = L["Buyout"],
		tooltip = L["Buys all selected items."].." "..L["Auctions may be selected with left clicks. Press the ctrl button, if you want to select multiple auctions. Press the shift button, if you want to select a range of auctions."],
		arg1 = vendor.Seller,
		func = function(arg1) _Buyout(arg1) end,
		enabledFunc = function(self)
			local rtn = false
			for _,row in pairs(self.itemModel:GetSelectedItems()) do
				rtn = true
				local _, _, _, _, _, _, buyoutPrice, _, owner = self.itemModel:Get(row)
				if (not buyoutPrice or buyoutPrice == 0 or self.playerName == owner) then
					rtn = false
					break
				end
			end
			return rtn
		end,
		order = 11
	},
	cancel = {
		title = L["Cancel Auctions"],
		tooltip = L["Cancels all own auctions that has been selected."].." "..L["Auctions may be selected with left clicks. Press the ctrl button, if you want to select multiple auctions. Press the shift button, if you want to select a range of auctions."],
		arg1 = vendor.Seller,
		width = 125,
		func = function(arg1) _CancelAuctions(self) end,
		enabledFunc = function(self)
			local rtn = false
			for _,row in pairs(self.itemModel:GetSelectedItems()) do
				rtn = true
				local _, _, _, _, _, _, _, _, owner = self.itemModel:Get(row)
				if (not owner or owner ~= self.playerName) then
					rtn = false
					break
				end
			end
			return rtn
		end,
		order = 12
	}
}

--[[
	Tries to retrieve a link for an item with the given name in the inventory.
--]]
local function _FindInventoryItemLink(name)
   	for bag = 0, 4 do
      	for slot = 1, GetContainerNumSlots(bag) do
	 		local itemLink = GetContainerItemLink(bag, slot);
	 		if (itemLink) then
	    		local itemName = GetItemInfo(itemLink);
	    		if (name and name == itemName) then
	    			return itemLink; -- don't like this, but we need to get out of two loops
	    		end
	 		end
      	end
   	end
   	return nil;
end

--[[
	Returns "minBid, buyOut" for the given item, if known.
--]]
local function _GetItemAuctionSellValues(itemLink)
	local itemLinkKey = vendor.Items:GetItemLinkKey(itemLink)
	if (vendor.Items:GetItemInfo(itemLinkKey, self.itemInfo, vendor.AuctionHouse:IsNeutral())) then
		return self.itemInfo.minBid, self.itemInfo.buyout
	end
	return nil;
end

--[[
	Returns "avgBid, avgBuyout" for the given item, if known.
--]] 
local function _GetItemAuctionAvgValues(itemLink)
	return vendor.Gatherer:GetAuctionInfo(itemLink, vendor.AuctionHouse:IsNeutral())
end

--[[
	Modifies the given minBid and buyout prices by the given modifier.
--]]
local function _ModifyPrices(minBid, buyout)
	--log:Debug("ModifyPrices minBid: %d buyout: %d", minBid or 0, buyout or 0)
	if (minBid and minBid > 0) then
		minBid = math.max(1, minBid)
		if (self.db.profile.bidCalc) then
			minBid = self.buyoutMul:ModifyBuyout(minBid, self.item.itemSettings)
		end
		if (buyout and buyout > 0) then
			buyout = self.buyoutMul:ModifyBuyout(buyout, self.item.itemSettings)
		end
	end
	if (not self.db.profile.bidCalc and buyout and buyout > 0) then
		minBid = math.floor(buyout * (self.db.profile.bidMul / 100.0) + 0.5)
		minBid = math.max(1, minBid)
	end
	if (self.startPrize and (not minBid or (self.startPrize > minBid))) then
		minBid = self.startPrize
	end
	if (minBid and buyout and buyout > 0 and minBid > buyout) then
		buyout = minBid; 
	end
	--log:Debug("ModifyPrices exit minBid: %d buyout: %d", minBid or 0, buyout or 0)
	return minBid, buyout;	
end

--[[
	Returns item's current price calculation for current auctions.
--]] 
local function _GetCurrentPrice(self, itemLink)
	local minBid, buyout = vendor.Statistic:GetCurrentAuctionInfo(itemLink, vendor.AuctionHouse:IsNeutral())
	return _ModifyPrices(minBid, buyout)
end

--[[
	Returns item's undercut calculation for current auctions.
--]] 
local function _GetUndercutPrice(self, itemLink)
	local _, _, minBid, buyout = vendor.Statistic:GetCurrentAuctionInfo(itemLink, vendor.AuctionHouse:IsNeutral(), true)
	return _ModifyPrices(minBid, buyout)
end

--[[
	Returns item's mulltiplier calculation for current auctions.
--]] 
local function _GetMultiplierPrice(self, itemLink)
	local minBid = self.startPrize
	local buyout = self.startPrize
	return _ModifyPrices(minBid, buyout)
end

--[[
	Returns item's market price calculation for current auctions.
--]] 
local function _GetMarketPrice(self, itemLink)
	local minBid, buyout = _GetItemAuctionAvgValues(itemLink)
	return _ModifyPrices(minBid, buyout)
end

--[[
	Returns item's lower market price calculation for current auctions.
--]] 
local function _GetLowerPrice(self, itemLink)
	local itemLinkKey = vendor.Items:GetItemLinkKey(itemLink)
	local result = vendor.Gatherer:GetCurrentAuctions(itemLinkKey, vendor.AuctionHouse:IsNeutral())
	--log:Debug("_GetLowerPrice size: %d", result:Size())
	local minBid = nil
	local buyout = nil
	if (result:Size() > 0) then
		-- search for first auction above lower market threshold
		local avgMinBid, avgBuyout = _GetItemAuctionAvgValues(itemLink)
		--log:Debug("_GetLowerPrice avgMinBid: %d avgBuyout: %d", avgMinBid or 0, avgBuyout or 0)
		if (avgBuyout and avgBuyout > 0) then
			local limit = avgBuyout * (self.db.profile.lowerMarketThreshold / 100.0)
			--log:Debug("_GetLowerPrice limit: %d", limit)
			minBid = limit	
    		for i = 1, result:Size() do
    			local _, time, timeLeft, count, m, minIncrement, b = result:Get(i)
    			--log:Debug("_GetLowerPrice minBid: %d buyout: %d", m or 777, b or 777)
				if (b and b > 0) then
					b = b / count
				 	if (b > limit and (not buyout or buyout > b)) then
						buyout = b
					end 
				end
    		end
		end
	end
	return _ModifyPrices(minBid, buyout)
end

--[[
	Refreshes the deposit.
--]]
local function _UpdateDeposit(self)
	--log:Debug("_UpdateDeposit")
	local deposit
	if (self.item) then
    	deposit = self.deposits[self.duration]
    	local stackCount = self.countDropDown:GetSelectedValue()
    	if (type(stackCount) == "string") then
    		deposit = deposit * self.item.count
    	else
    		local stackSize = self.stackDropDown:GetSelectedValue()
    		deposit = deposit * stackSize * stackCount
    	end
    end
	self.sellingPrice:SetDeposit(deposit)
	self.sellInfo:Update()
end

--[[
	Returns current values for:
	local stackSize, numStacks, backlog = _GetCounts(self)
--]]
local function _GetCounts(self)
	local stackSize = self.stackDropDown:GetSelectedValue()
   	local stackCount = self.countDropDown:GetSelectedValue()
   	local backlog = 0
   	if (type(stackCount) == "string") then
   		stackCount = select(3, string.find(stackCount, "^(%d+).*"))
		backlog = self.item.count - (stackCount * stackSize)
   	end
   	return stackSize, stackCount, backlog
end

--[[
	Update the prices and sell info display.
--]]
local function _UpdatePrices(self)
	if (not self.item) then
		self.sellInfo:Clear()
	else
    	local stackSize, numStacks, backlog = _GetCounts(self)
    	self.sellingPrice:SetStackSize(stackSize)
    	self.sellingPrice:SetNumStacks(numStacks)
    	self.sellingPrice:SetBacklog(backlog)
    	local minBid, buyout = self.sellingPrice:GetPrices(vendor.Seller.db.profile.bidType)
    	minBid = math.floor(minBid + 0.5)
    	buyout = math.floor(buyout + 0.5)
    	self.lastMinBid = minBid
		self.lastBuyout = buyout
		--log:Debug("_UpdatePrices minBid: %d buyout: %s", minBid, buyout or 0)
		MoneyInputFrame_SetCopper(self.startPriceBut, minBid)
		MoneyInputFrame_SetCopper(self.buyoutPriceBut, buyout)
    	_UpdateDeposit(self)
    	self.sellInfo:Update()
    end
end

--[[
	Updates the count dropdown button
--]]
local function _UpdateCountDropDown(self)
	--log:Debug("_UpdateCountDropDown enter")
	if (not self.item) then
		return;
	end
	local counts = {};
	local stackSize = self.stackDropDown:GetSelectedValue();
	local n = self.item.count / stackSize;
	if (n < 1) then
		n = 1;
	end
	n = math.floor(n);
--	local hasAdd = self.item.count > n * stackSize;
	local select = n;
--	if (hasAdd) then
--		select = ""..n.."+";
--	end
	local i = 1;
	local prev = nil;
	-- add all integral stack sizes
	while i <= n do
		table.insert(counts, i);
		prev = i;
		i = i * 2;
	end
	-- add the last if there are more items
	if (hasAdd or prev and prev < n) then
		if (hasAdd) then
			table.insert(counts, select);
		else
			table.insert(counts, n);
		end
	end
	if (type(select) == "string") then
		--log:Debug("_UpdateCountDropDown select: %s", select)
		self.countDropDown:SetRange(1, n, {[select] = true})
	else
		if (self.item.preferedAmount > 0 and self.item.preferedAmount < select) then
			select = self.item.preferedAmount
		end
		--log:Debug("_UpdateCountDropDown select: %d", n)
		self.countDropDown:SetRange(1, n)
	end
	--log:Debug("_UpdateCountDropDown reset count dropdown")
	self.lastCount = select
	self.countDropDown:SetItems(counts, select)
	self.sellingPrice:SetStackSize(stackSize)
	if (type(select) == "string") then
		self.sellingPrice:SetNumStacks(n)
		self.sellingPrice:SetBacklog(self.item.count - (n * stackSize))
	else
		self.sellingPrice:SetNumStacks(n)
		self.sellingPrice:SetBacklog(0)
	end
	--log:Debug("_UpdateCountDropDown exit")
end

--[[
	Updates the dropdown buttons accoring to the selected item
--]]
local function _UpdateDropDowns(self)
	--log:Debug("_UpdateDropDowns enter")
	-- stacksize
	local stackSize = math.min(self.item.stackCount, self.item.count);
	local stackSizes = self.stackSizes[stackSize];
	if (not stackSizes) then
		stackSizes = {};
		self.stackSizes[stackSize] = stackSizes;
		local i = 1;
		local prev = nil;
		while i <= stackSize do
			table.insert(stackSizes, i);
			prev = i;
			if (i < 5) then
				i = i + 1;
			else
				i = i * 2;
			end
		end
		if (prev and prev < stackSize) then
			table.insert(stackSizes, stackSize);
		end
	end
	if (self.item.preferedStackSize > 0 and self.item.preferedStackSize <= stackSize) then
		self.stackDropDown:SetItems(stackSizes, self.item.preferedStackSize);
	else
		self.stackDropDown:SetItems(stackSizes, stackSize);
	end
	self.stackDropDown:SetRange(1, stackSize)
	self.sellingPrice:SetStackSize(stackSize)
	-- stack count
	_UpdateCountDropDown(self);
	--log:Debug("_UpdateDropDowns exit")
end

--[[
	Shows information if mouse is over the selected item
--]]
local function _OnEnterItem(self, motion)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (self.ctrl.item) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip.itemCount = self.ctrl.item.count
		GameTooltip:SetHyperlink(self.ctrl.item.link);
	else
		GameTooltip:SetText(L["Drag an item here to auction it"]);
	end
end

--[[
	Checks whether the current auction is valid and shows an error messages
	or enables the sell button accordingly.
--]]
local function _ValidateAuction(self)
	log:Debug("_ValidateAuction enter")
	self.createBut:Show()
	self.createBut:Disable()
	self.buyoutErrorText:Hide()
	if (self.item) then
    	local startPrize = MoneyInputFrame_GetCopper(self.startPriceBut)
    	local buyoutPrize = MoneyInputFrame_GetCopper(self.buyoutPriceBut)
    	log:Debug("_ValidateAuction startPrize [%s] buyoutPrize [%s]", startPrize, buyoutPrize)
    	-- Buyout price is less than the start price
    	if (buyoutPrize > 0 and startPrize > buyoutPrize) then
    		log:Debug("_ValidateAuction disable")
    		self.createBut:Hide()
    		self.buyoutErrorText:Show()
    	else
        	-- Start price is 0 or greater than the max allowed
        	if (not (startPrize < 1 or startPrize > MAXIMUM_BID_PRICE)) then
        		log:Debug("_ValidateAuction enable")
        		self.createBut:Enable()
        	else
        		log:Debug("_ValidateAuction startPrize illegal")
        	end
        end
    end
    log:Debug("_ValidateAuction exit")
end

--[[
	Prizing model was selected.
--]]
local function _PrizingSelected(self, value, keepPrices)
	--log:Debug("_PrizingSelected enter")
	self.sellingPrice:ClearUserDefined()
	if (self.PRIZE_MODEL_CURRENT == value) then
		self.buyoutMul:SelectPriceModel(value)
--		self.buyoutMul:Show()
	elseif (self.PRIZE_MODEL_MARKET == value) then
		self.buyoutMul:SelectPriceModel(value)
--		self.buyoutMul:Show()
	elseif (self.PRIZE_MODEL_UNDERCUT == value) then
		self.buyoutMul:SelectPriceModel(value)
--		self.buyoutMul:Show()
	elseif (self.PRIZE_MODEL_MULTIPLIER == value) then
		self.buyoutMul:SelectPriceModel(value)
--		self.buyoutMul:Show()
	elseif (self.PRIZE_MODEL_LOWER == value) then
		self.buyoutMul:SelectPriceModel(value)
--		self.buyoutMul:Show()
--	else
--		self.buyoutMul:Hide()
	end
	self:RefreshPrices()
end

--[[
	A money field has been changed (by user or programatically)
--]]
local function _OnMoneyChange()
	local minBid = MoneyInputFrame_GetCopper(self.startPriceBut) or 0
	local buyout = MoneyInputFrame_GetCopper(self.buyoutPriceBut) or 0
	if (self.item and (minBid ~= self.lastMinBid or buyout ~= self.lastBuyout)) then
		-- user has selected a new value
		log:Debug("_OnMoneyChange user typed new selling price")
		--self:SelectPricingModel(self.PRIZE_MODEL_FIX, true)
		self.sellingPrice:SetPrices(minBid, buyout, self.db.profile.bidType, true)
		_UpdatePrices(self)
		_ValidateAuction(self)
	end
end

--[[
	Auction duration radio button has been clicked
--]]
local function _DurationSelected(self, id)
	log:Debug("duration selected");
	PlaySound("igMainMenuOptionCheckBoxOn");
	if (id == 1) then
		self.duration = DURATIONS[1];
		log:Debug("short");
	elseif (id == 2) then
		self.duration = DURATIONS[2];
		log:Debug("medium duration");
	else
		self.duration = DURATIONS[3];
		log:Debug("long duration");
	end
	_UpdateDeposit(self)
end

--[[
	Prints the uptodateness of the currenlty selected scanset.
--]]
--local function _PrintUpToDateness(self)
--	local scanResult = self.itemModel:GetScanSet()
--	if (scanResult and scanResult:Size() > 0) then
--		-- 0 seconds lead to an empty string
--		local secs = SecondsToTime(scanResult:GetUpToDateness() + 1)
--		local msg = L["Up-to-dateness: <= "]..secs
--		local itemLink = scanResult:GetItemLink()
--		if (itemLink) then
--			-- get averages
--			local minBid, buyout = vendor.Statistic:GetCurrentAuctionInfo(itemLink, vendor.AuctionHouse:IsNeutral())
--			local minBidMsg = "-"
--			local buyoutMsg = "-"
--			if (minBid and minBid > 0) then
--				minBidMsg = vendor.Format.FormatMoney(minBid)
--			end
--			if (buyout and buyout > 0) then
--				buyoutMsg = vendor.Format.FormatMoney(buyout)
--			end
--			if (GetLocale() == "zhTW" or GetLocale() == "zhCN" ) then
--				msg = msg.." - ("..minBidMsg.."/"..buyoutMsg..")"
--			else
--				msg = msg.." - Ø("..minBidMsg.."/"..buyoutMsg..")"
--			end
--		end
--		self.statusText:SetText(msg)
--	else
--		self.statusText:SetText("")
--	end
--end

--[[
	Selects the given itemLink for selling
--]]
local function _SelectItem(self, itemLink)
	log:Debug("_SelectItem enter")
	self.sellingPrice:Clear()
	if (not itemLink) then
		SalesFrameItemName:SetText("");
		SalesFrameItemCount:Hide();
		SalesFrameItem:SetNormalTexture(nil);
		self.lastItem = self.item;
		self.item = nil;
		self.stackDropDown:SetValidating(false)
		self.countDropDown:SetValidating(false)
	else
		self.stackDropDown:SetValidating(true)
		self.countDropDown:SetValidating(true)
		local name, link, stackCount, texture, count = self.inventory:GetItemInfo(itemLink);
		if (name) then
			SalesFrameItem:SetNormalTexture(texture);
			SalesFrameItemName:SetText(name);
			if (count > 1) then
				SalesFrameItemCount:SetText(count);
				SalesFrameItemCount:Show();
			else
				SalesFrameItemCount:Hide();
			end
			local itemLinkKey = vendor.Items:GetItemLinkKey(itemLink);
			local preferedStackSize = 0
			local preferedAmount = 0
			local itemInfo = self.itemInfo
			local itemSettings = self.itemSettings
			vendor.ItemSettings:GetItemSettings(itemLink, itemSettings)
			if (not vendor.Items:GetItemInfo(itemLinkKey, itemInfo, vendor.AuctionHouse:IsNeutral())) then
				itemInfo = nil
			end
			if (itemSettings.general.rememberStacksize and itemInfo and itemInfo.stackSize <= count) then
				preferedStackSize = itemInfo.stackSize;
			elseif (itemSettings.general.stacksize) then
				preferedStackSize = itemSettings.general.stacksize
			end
			if (itemSettings.general.rememberAmount and itemInfo and itemInfo.amount > 0 and itemInfo.amount <= count) then
				log:Debug("take remembered amount [%s]", itemInfo.amount)
				preferedAmount = itemInfo.amount
			elseif (itemSettings.general.amount and itemSettings.general.amount > 0) then
				log:Debug("take prefered amount [%s]", itemSettings.general.amount)
				preferedAmount = itemSettings.general.amount
			end
			if (itemSettings.general.rememberDuration and itemInfo and itemInfo.duration and itemInfo.duration > 0) then
				log:Debug("select duration: "..itemInfo.duration)
				self.durationDropDown:SelectValue(itemInfo.duration)
				_DurationSelected(self, itemInfo.duration)
			elseif (itemSettings.general.duration) then
				self.durationDropDown:SelectValue(itemSettings.general.duration)
				_DurationSelected(self, itemSettings.general.duration)
			else
				log:Debug("select default duration: %s", self.db.profile.defaultDuration)
				log:Debug("id: %d", self.db.profile.defaultDuration)
				self.durationDropDown:SelectValue(self.db.profile.defaultDuration)
				_DurationSelected(self, self.db.profile.defaultDuration)
			end
			if (itemSettings.pricingModel.rememberPricingModel and itemInfo and itemInfo.priceModel and itemInfo.priceModel > 0) then
				log:Debug("select priceModel: "..itemInfo.priceModel)
				self.prizingDropDown:SelectValue(itemInfo.priceModel)
				_PrizingSelected(self, itemInfo.priceModel)
			elseif (itemSettings.pricingModel.pricingModel) then
				self.prizingDropDown:SelectValue(itemSettings.pricingModel.pricingModel)
				_PrizingSelected(self, itemSettings.pricingModel.pricingModel)
			end
			self.item = {name = name, link = link, stackCount = stackCount, texture = texture, count = count, preferedStackSize = preferedStackSize, preferedAmount = preferedAmount, itemLinkKey = itemLinkKey, itemSettings = itemSettings};
			_UpdateDropDowns(self);
			self.auto:SetItem(itemLink)
		else
			-- item disappaered after it had been selected
			_SelectItem(self, nil);
		end
	end
	self:RefreshPrices()
	_ValidateAuction(self);
	log:Debug("_SelectItem exit")
end

--[[
	Picks the given item for selling.
--]]
local function _PickItem(self, itemLink)
	-- use blizzard's auction slot to calculate deposit and start prize
	vendor.clickAuctionSellItemButton()
	local _, _, count, _, _, price = GetAuctionSellItemInfo();
	self.deposits = {};
	for _, duration in ipairs(DURATIONS) do
		self.deposits[duration] = CalculateAuctionDeposit(duration) / count;
	end;
	self.startPrize = math.max(1, price / count)
	log:Debug("_PickItem stratPrize [%s]", self.startPrize)
	_SelectItem(self, itemLink);
	-- now free blizzard's auction slot
	vendor.clickAuctionSellItemButton()
	ClearCursor();
	_RefreshClicked(self)
end

--[[
	Picks the currently dragged item for selling.
--]]
local function _PickItemFromCursor(self)
	local type, _, itemLink = GetCursorInfo();
	if (type and type == "item" and itemLink) then
		_PickItem(self, itemLink)
	end
end

--[[
	Updates the list of inventory items.
--]]
local function _UpdateInventory(self)
	if (self.frame and self.frame:IsVisible()) then
		self.inventory:Update();
		if (self.item) then
			_SelectItem(self, self.item.link);
		end
	 end
end

--[[
	Creates an auction with the currently selected item.
--]]
local function _CreateAuction(self)
	log:Debug("CreateAuction 1")
	if (self.item) then
	log:Debug("CreateAuction 2")
		local itemLink = self.item.link;
		local runTime = self.duration;
		local stackSize = self.stackDropDown:GetSelectedValue();
		log:Debug("CreateAuction 3")
		if (not self.stackDropDown:IsValid() or not self.countDropDown:IsValid()) then
			vendor.Vendor:Error(L["Please correct the drop downs first!"])
			return nil
		end
		log:Debug("CreateAuction 4")
		-- remember several dropdown button values for next time
  		local itemInfo = self.itemInfo
		if (not vendor.Items:GetItemInfo(self.item.itemLinkKey, itemInfo, vendor.AuctionHouse:IsNeutral())) then
			vendor.Items:InitItemInfo(itemInfo)
		end
		if (self.selectedStackSize) then
			-- a stackSize was selected manually, remember it
			itemInfo.stackSize = self.selectedStackSize;
		end
		log:Debug("CreateAuction 5")
		local stackCount = self.countDropDown:GetSelectedValue()
    	if (type(stackCount) ~= "string") then
    		itemInfo.amount = stackCount
		end
		log:Debug("CreateAuction 6")
		itemInfo.priceModel = self.prizingDropDown:GetSelectedValue()
		itemInfo.duration = self.durationDropDown:GetSelectedValue()
 		vendor.Items:PutItemInfo(self.item.itemLinkKey, vendor.AuctionHouse:IsNeutral(), itemInfo);
		self.selectedStackSize = nil;
		log:Debug("CreateAuction7 ")
		-- create sell task
		self:RefreshPrices()
		local minBid, buyout = self.sellingPrice:GetPrices(vendor.SellingPrice.BID_TYPE_PER_ITEM)
		local stackSize, stackCount, backlog = _GetCounts(self)
		
--		local task = vendor.SellTask:new(self.inventory, itemLink, minBid, buyout, runTime, stackSize, stackCount, backlog)
--		vendor.TaskQueue:AddTask(task);
		_Sell(itemLink, minBid, buyout, runTime, stackSize, stackCount)
		
		log:Debug("CreateAuction 8")
		-- clear focus of edit boxes
		self.stackDropDown:ClearFocus()
		self.countDropDown:ClearFocus()
		log:Debug("CreateAuction 9")
	end
end

--[[
	Updates the item model according to curent own auctions list.
--]]
local function _UpdateItemModel(self)
	log:Debug("_UpdateItemModel enter")
	local scanSet = self.itemModel:GetScanSet()
	if (scanSet) then
		scanSet:UpdateOwnAuctions()
		self.itemModel:SetScanSet(scanSet)
		self.itemTable:Show()
	end
	log:Debug("_UpdateItemModel exit")
end

--[[
	Update gui callback.
--]]
local function _OnUpdate(self, diff)
--	self.updateCountdown = self.updateCountdown - diff
--	if (self.updateCountdown <= 0) then
--		self.updateCountdown = UPDATE_INTERVAL
--		if (not vendor.Scanner:IsScanning()) then
--    		if (self.updateItemModel and self.updateItemModel > 0) then
--   				log:Debug("update now")
--   				_UpdateItemModel(self)
--    			self.updateItemModel = self.updateItemModel - 1
--    		end
--    	end
--	end
end

local function _Edit(but)
	local self = but.obj
	if (self.item) then
		vendor.ItemSettings:SelectItem(self.item.link)
	else
		vendor.ItemSettings:SelectItem(nil)
	end
	vendor.ItemSettings:Toggle("TOPLEFT", but, "BOTTOMRIGHT", 0, 90)
end

--[[
	Creates the auction buttons.
--]]
local function _CreateAuctionButtons(self)
	-- edit
	local but = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
	but.obj = self
	but:SetText(L["Edit"])
	but:SetWidth(80)
	but:SetHeight(20)
	but:SetPoint("TOPLEFT", 120, -137)
	--but:SetNormalTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-Panel-Button-Up-green")
	but:SetScript("OnClick", _Edit)
	--vendor.GuiTools.AddTooltip(but, L["Scans the auction house for updating statistics and sniping items. Uses a fast \"GetAll\" scan, if the scan button is displayed with a green background. This is only possible each 15 minutes."])

	-- item to be sold
	local texture = vendor.GuiTools.CreateTexture(nil, self.frame, "ARTWORK", "Interface\\Addons\\AuctionMaster\\src\\resources\\ItemContainer", 256, 64)
	texture:SetPoint("TOPLEFT", 27, -92)
	local f = self.frame:CreateFontString("SalesFrameItemText", "ARTWORK", "GameFontHighlightSmall");
	f:SetText(L["Auction Item"]);
	f:SetPoint("TOPLEFT", 28, -79);
	self.itemBut = CreateFrame("Button", "SalesFrameItem", self.frame);
	self.itemBut.ctrl = self; 
	self.itemBut:SetWidth(37);
	self.itemBut:SetHeight(37);
	self.itemBut:SetPoint("TOPLEFT", 28, -94);
	local f = self.itemBut:CreateFontString("SalesFrameItemName", "BACKGROUND", "GameFontNormal");
	f:SetWidth(124);
	f:SetHeight(30);
	f:SetPoint("TOPLEFT", self.itemBut, "TOPRIGHT", 5, 0);
	local f = self.itemBut:CreateFontString("SalesFrameItemCount", "OVERLAY", "NumberFontNormal");
	f:SetJustifyH("RIGHT");
	f:SetPoint("BOTTOMRIGHT", -5, 2);
	self.itemBut:RegisterForDrag("LeftButton");
	self.itemBut:SetScript("OnClick", function(but) _PickItemFromCursor(but.ctrl); _ValidateAuction(but.ctrl); end);
	self.itemBut:SetScript("OnDragStart", function(but) _PickItemFromCursor(but.ctrl); _ValidateAuction(but.ctrl); end);
	self.itemBut:SetScript("OnReceiveDrag", function(but) _PickItemFromCursor(but.ctrl); end);
	self.itemBut:SetScript("OnEnter", _OnEnterItem);
	self.itemBut:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	self.itemBut:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");

	-- duration of auction
	log:Debug("create durations")
	self.durationDropDown = vendor.DropDownButton:new("SalesFrameDuration", self.frame, 85, L["Auction Duration"], "");
	self.durationDropDown:SetPoint("TOPLEFT", 10, -174);
 	self.durationDropDown:SetId(DURATION_DROPDOWN_ID);
	self.durationDropDown:SetListener(self);
    local durations = {};
	table.insert(durations, {value = 1, text = "12 "..GetText("HOURS", nil, 12)});
	table.insert(durations, {value = 2, text = "24 "..GetText("HOURS", nil, 24)});
	table.insert(durations, {value = 3, text = "48 "..GetText("HOURS", nil, 48)});
	self.durationDropDown:SetItems(durations, self.db.profile.defaultDuration)
	self.duration = DURATIONS[self.db.profile.defaultDuration]

	-- stacksize
	self.stackDropDown = vendor.DropDownButton:new("SalesFrameStackSize", self.frame, 50, L["Stack size"], L["Selects the size of the stacks to be sold."]);
	self.stackDropDown:SetPoint("TOPLEFT", 118, -174);
	self.stackDropDown:SetId(STACK_DROPDOWN_ID);
	self.stackDropDown:SetListener(self);
	self.stackDropDown:SetEditable(true)
	self.stackDropDown:SetNumeric(true)
	
	-- count of "stacks"
	self.countDropDown = vendor.DropDownButton:new("SalesFrameCount", self.frame, 50, L["Amount"], L["Selects the number of stacks to be sold.\nThe number with the +-suffix sells\nalso any remaining items."]);
	self.countDropDown:SetPoint("TOPLEFT", SalesFrameStackSize, "BOTTOMLEFT", 0, -16);
 	self.countDropDown:SetId(COUNT_DROPDOWN_ID);
	self.countDropDown:SetListener(self);
	self.countDropDown:SetEditable(true)
	self.countDropDown:SetNumeric(true)
	
	-- prizing model
	self.prizingDropDown = vendor.DropDownButton:new("SalesFramePrizing", self.frame, 85, L["Price calculation"], L["Selects the mode for calculating the sell prices.\nThe default mode Fixed price just select the last sell price."]);
	self.prizingDropDown:SetPoint("TOPLEFT", SalesFrameDuration, "BOTTOMLEFT", 0, -16);
 	self.prizingDropDown:SetId(PRIZING_DROPDOWN_ID);
	self.prizingDropDown:SetListener(self);
    local prizeModels = {};
	table.insert(prizeModels, {value = self.PRIZE_MODEL_FIX, text = L["Fixed price"]});
	table.insert(prizeModels, {value = self.PRIZE_MODEL_CURRENT, text = L["Current price"]});
	table.insert(prizeModels, {value = self.PRIZE_MODEL_UNDERCUT, text = L["Undercut"]})
	table.insert(prizeModels, {value = self.PRIZE_MODEL_LOWER, text = L["Lower market threshold"]})
	table.insert(prizeModels, {value = self.PRIZE_MODEL_MULTIPLIER, text = L["Selling price"]})
	table.insert(prizeModels, {value = self.PRIZE_MODEL_MARKET, text = L["Market price"]});
	self.prizingDropDown:SetItems(prizeModels, self.PRIZE_MODEL_FIX);
		
	self.buyoutMul = vendor.BuyoutModifier:new()
	--self.buyoutMul:SetPoint("TOPLEFT", SalesFramePrizing, "BOTTOMLEFT", 24, -6)
	
	self.auto:CreateFrame(self.frame)
	
	-- hrule to separate the sections
	local texture = vendor.GuiTools.CreateTexture(nil, self.frame, "ARTWORK", "Interface\\Addons\\AuctionMaster\\src\\resources\\HRule", 256, 16)
	texture:SetPoint("TOPLEFT", 23, -255)
	
	-- starting prize
	f = self.frame:CreateFontString("SalesFramePriceText", "ARTWORK", "GameFontHighlightSmall");
	f:SetPoint("TOPLEFT", 28, -268);
	self.minBidFont = f
	self.startPriceBut = CreateFrame("Frame", "SalesFrameStartPrice", self.frame, "MoneyInputFrameTemplate");
	self.startPriceBut:SetPoint("TOPLEFT", SalesFramePriceText, "BOTTOMLEFT", 3, -2);
	self.startPriceBut.controller = self;
	MoneyInputFrame_SetOnValueChangedFunc(self.startPriceBut, _OnMoneyChange)
	local frameName = self.startPriceBut:GetName();
	local goldBut = getglobal(frameName.."GoldButton");
	SalesFrameStartPriceGold:SetMaxLetters(6);
	
	-- buyout prize
	f = self.frame:CreateFontString("SalesFrameBuyoutText", "ARTWORK", "GameFontHighlightSmall");
	self.buyoutFont = f
	f:SetPoint("TOPLEFT", SalesFramePriceText, 0, -35);
	self.buyoutPriceBut = CreateFrame("Frame", "SalesFrameBuyoutPrice", self.frame, "MoneyInputFrameTemplate");
	self.buyoutPriceBut:SetPoint("TOPLEFT", 31, -317);
	self.buyoutPriceBut.controller = self;
	MoneyInputFrame_SetOnValueChangedFunc(self.buyoutPriceBut, _OnMoneyChange)
	SalesFrameBuyoutPriceGold:SetMaxLetters(6);
	
	-- hrule to separate the sections
	local texture = vendor.GuiTools.CreateTexture(nil, self.frame, "ARTWORK", "Interface\\Addons\\AuctionMaster\\src\\resources\\HRule", 256, 16)
	texture:SetPoint("TOPLEFT", 23, -338)
	
	-- area for sell information
	self.sellInfo = vendor.SellInfo:new(self.frame, self.sellingPrice)
	self.sellInfo:SetPoint("TOPLEFT", 25, -347)
	
	-- Set focus rules
	self.stackDropDown:SetPrevFocus(SalesFrameBuyoutPriceCopper)
	self.stackDropDown:SetNextFocus(self.countDropDown:GetEditBox())
	self.countDropDown:SetPrevFocus(self.stackDropDown:GetEditBox())
	self.countDropDown:SetNextFocus(SalesFrameStartPriceGold)
	MoneyInputFrame_SetPreviousFocus(SalesFrameStartPrice, self.countDropDown:GetEditBox())
	MoneyInputFrame_SetNextFocus(SalesFrameStartPrice, SalesFrameBuyoutPriceGold)
	MoneyInputFrame_SetPreviousFocus(SalesFrameBuyoutPrice, SalesFrameStartPriceCopper)
	MoneyInputFrame_SetNextFocus(SalesFrameBuyoutPrice, self.stackDropDown:GetEditBox())
	
	-- total deposit
	f = self.frame:CreateFontString("SalesFrameDepositText", "ARTWORK", "GameFontNormal");
	f:SetText(L["Deposit:"]);
	f:SetPoint("TOPLEFT", 28, -364);
	f:Hide()
	self.depositBut = CreateFrame("Frame", "SalesFrameDeposit", self.frame, "DepositFrameTemplate");
	self.depositBut:SetPoint("LEFT", SalesFrameDepositText, "RIGHT", 5, 0);
	self.depositBut.controller = self;
	self.depositBut:Hide()
	
	-- up-to-dateness of the item list
--	f = self.frame:CreateFontString("SalesFrameUpToDatenessText", "ARTWORK", "GameFontNormal");
--	f:SetText("");
--	f:SetPoint("BOTTOMLEFT", 300, 20);
--	self.statusText = f;
	
	-- auction creation
	self.createBut = CreateFrame("Button", "SalesFrameCreate", self.frame, "UIPanelButtonTemplate");
	self.createBut:SetText(L["Create Auction"]);
	self.createBut:SetWidth(191);
	self.createBut:SetHeight(20);
	self.createBut:SetPoint("BOTTOMLEFT", 18, 39);
	self.createBut.ctrl = self;
	self.createBut:SetScript("OnClick", function(but) _CreateAuction(but.ctrl) end);
	
	-- auction creation not possible error text
	self.buyoutErrorText = self.frame:CreateFontString("SalesFrameBuyoutErrorText", "ARTWORK", "GameFontRedSmall");
	self.buyoutErrorText:SetText(L["Buyout < bid"]);
	self.buyoutErrorText:SetPoint("TOPLEFT", self.createBut, "TOPLEFT", 15, -5);
	
	-- scan progress
	-- status bar 
	local statusBar = CreateFrame("StatusBar", nil, self.frame, "TextStatusBar")
	self.statusBar = statusBar
	statusBar.obj = self
	statusBar:SetHeight(14)
	statusBar:SetWidth(622)
	statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	statusBar:SetPoint("TOPLEFT", 70, -17)
	statusBar:SetMinMaxValues(0, 1)
	statusBar:SetValue(1)
	statusBar:SetStatusBarColor(0, 1, 0)
	
	-- status bar text
	local text = statusBar:CreateFontString(nil, "ARTWORK")
	self.statusBarText = text
	text:SetPoint("CENTER", statusBar)
	text:SetFontObject("GameFontHighlight")
	self:SetProgress("", 0)
	
	_UpdateFonts(self)
end

--[[
	Creates the central close etc. buttons.
--]]
local function _CreateFrameButtons(self)
	self.closeBut = vendor.AuctionHouse:CreateCloseButton(self.frame, "SalesFrameClose");
end

--[[
	Updates according to current settings.
--]]
local function _ApplySettings(self)
	log:Debug("_ApplySettings neter")
	if (self.db.profile.pickupByClick and not self:IsHooked("ContainerFrameItemButton_OnModifiedClick")) then
		self:RawHook("ContainerFrameItemButton_OnModifiedClick", true)
	end
	if (not self.db.profile.pickupByClick and self:IsHooked("ContainerFrameItemButton_OnModifiedClick")) then
		self:Unhook("ContainerFrameItemButton_OnModifiedClick")
	end
	if (self.item) then
		_UpdatePrices(self)
	end
	if (self.db.profile.bidCalc) then
		vendor.Vendor.options2.args.seller.args.bidMul.disabled = true
	else
		vendor.Vendor.options2.args.seller.args.bidMul.disabled = nil
	end
	_UpdateFonts(self)
	if (self.item) then
		self:RefreshPrices()
	end
end

--[[
	Sets the given value in the profile.
--]]
local function _SetValue(info, value)
	self.db.profile[info.arg] = value;
	_ApplySettings(self)
end

--[[
	Returns the given value from the profile.
--]]
local function _GetValue(info)
	return self.db.profile[info.arg]
end

--[[
	One of the item tables should be resized.
--]]
local function _ItemTableResize(itemTable, self, value)
	if (self.itemTable.name == itemTable.name) then
		log:Debug("resize auctions itemTable")
		self.inventorySeller:SetSize(100 - value)
	else
		log:Debug("resize inventory itemTable")
		self.itemTable:SetSize(100 - value)
	end
end

--[[
	Options for this module.
--]]
local function _CreateOptions()
	vendor.Vendor.options2.args.seller = {
		type = "group",
		name = L["Seller"],
		desc = L["Seller"],
		args = {
			editDesc = {
				type = "description",
				order = 1,
				name = L["Many of the selling settings has to be given by pressing \"Edit\" in the sell tab. Here are only a few general settings left over."],
			},
			autoMode ={
				type = "group",
				name = L["Auto selling"],
				desc = L["Settings for automatically selecting the best fitting price model."],
				order = 2,
				args = {
					aboveMarketThreshold = {
						type = "range",
        				name = L["Upper market threshold"],
        				desc = L["Minimal needed percentage of buyouts compared to market price, until they are assumed to be considerably above the market price."],
        				min = 101,
        				max = 500,
        				step = 1,
        				get = _GetValue,
        				set = _SetValue,
        				arg = "upperMarketThreshold",
        				order = 1,
        			},
					underMarketThreshold = {
						type = "range",
        				name = L["Lower market threshold"],
        				desc = L["Maximal allowed percentage of buyouts compared to market price, until they are assumed to be considerably under the market price."],
        				min = 1,
        				max = 99,
        				step = 1,
        				get = _GetValue,
        				set = _SetValue,
        				arg = "lowerMarketThreshold",
        				order = 10,
        			},
        		},
        	},
			pickupByClick = {
				type = "toggle",
				name = L["Pickup by click"],
				desc = L["Pickup items to be soled, when they are shift left clicked."],
				get = _GetValue,
				set = _SetValue,
				arg = "pickupByClick",
				order = 20,
			},
			bidType = {
				type = "select",
				name = L["Bid type"],
				desc = L["Selects which prices should be shown in the bid and buyout input fields."],
				get = _GetValue,
				set = _SetValue,
				values = BID_TYPES, 
				arg = "bidType",
				order = 70,
			},
			bidCalcDesc = {
				type = "description",
				order = 72,
				name = L["Should the starting price be calculated? Otherwise it is dependant from the buyout price."],
			},
			bidCalc = {
				type = "toggle",
				name = L["Calculate starting price"],
				desc = L["Should the starting price be calculated? Otherwise it is dependant from the buyout price."],
				get = _GetValue,
				set = _SetValue,
				arg = "bidCalc",
				order = 75,
			},																		
			bidMul = {
				type = "range",
				name = L["Bid multiplier"],
				desc = L["Selects the percentage of the buyout price the bid value should be set to. A value of 100 will set it to the equal value as the buyout price. It will never fall under blizzard's suggested starting price, which is based on the vendor selling value of the item."],
				min = 1,
				max = 100,
				step = 1,
				get = _GetValue,
				set = _SetValue,
				arg = "bidMul",
				order = 80,
			},
		}
	}
	vendor.Vendor.AceConfigRegistry:RegisterOptionsTable("AuctionMaster Seller", vendor.Vendor.options2.args.seller)
	vendor.Vendor.AceConfigDialog:AddToBlizOptions("AuctionMaster Seller", L["Seller"], "AuctionMaster")
end

--[[
	Initializes the module.
--]]
function vendor.Seller:OnInitialize()
	self.db = vendor.Vendor.db:RegisterNamespace("Seller", {
		profile = {
    		pickupByClick = true,
    		rememberStackSize = true,
    		rememberDuration = true,
    		rememberPriceModel = true,
    		upperMarketThreshold = 200,
    		lowerMarketThreshold = 30,
    		autoPriceModel = true,		
    		defaultDuration = 3,
    		bidType = 1,
    		itemTableCfg = {
    			size = 100,
    			rowHeight = 14,
				selected = {
					[1] = vendor.ScanSetItemModel.NAME,
					[2] = vendor.ScanSetItemModel.COUNT,
					[3] = vendor.ScanSetItemModel.BID,
					[4] = vendor.ScanSetItemModel.BUYOUT,
				},
    		},
    		inventoryTableCfg = {
    			size = 0,
    			rowHeight = 26,
				selected = {
					[1] = vendor.InventoryItemModel.TEXTURE,
					[2] = vendor.InventoryItemModel.NAME,
					[3] = vendor.InventoryItemModel.CURRENT_AUCTIONS,
					[4] = vendor.InventoryItemModel.BID,
					[5] = vendor.InventoryItemModel.BUYOUT,
				},
    		},
    		bidCalc = false,
    		bidMul = 90,
    	}
	});
	_MigrateDb(self)
	_CreateOptions();
	self.updateCountdown = UPDATE_INTERVAL
	self.itemInfo = {} -- prevent too much garbage
	self.itemSettings = {} -- prevent too much garbage
	self.auto = vendor.AutomaticPriceModel:new()
	self.sellingPrice = vendor.SellingPrice:new()	
end

--[[
	Initializes the module.
--]]
function vendor.Seller:OnEnable()
	_ApplySettings(self)
	self.playerName = UnitName("player")
	self.isScanning = false
	self.stackSizes = {}
	self.inventory = vendor.InventoryHandle:new()
	self.lastItem = nil
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("AUCTION_HOUSE_CLOSED")
	self:RegisterEvent("NEW_AUCTION_UPDATE")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
	self:RegisterMessage("AUCTION_STATISTIC_UPDATE")
	self:RegisterMessage("ITEM_SETTINGS_UPDATED")
   	self:Hook("StartAuction", true);
	-- register for new ScanResults
	self.frame = vendor.AuctionHouse:CreateTabFrame("AuctionFrameVendor", "AuctionMaster", L["Sell"], self);
	self.frame.obj = self
	self.frame:SetScript("OnUpdate", function(f, diff) _OnUpdate(f.obj, diff) end)
	--self.vendorTabButton = vendor.AuctionHouse:CreateTabButton(L["Seller"], 4);
	_CreateFrameButtons(self);
	_CreateAuctionButtons(self);
	local itemModel = vendor.ScanSetItemModel:new()
	self.itemModel = itemModel
	local cmds = vendor.Vendor:OrderTable(CMDS)
	local cfg = {
		name = "AMSellerAuctions",
		parent = self.frame,
		itemModel = itemModel,
		cmds = cmds,
		config = self.db.profile.itemTableCfg,
		width = 609,
		height = 358,
		xOff = 214,
		yOff = -51,
		upperList = true, 
		sortButtonBackground = false,
		resizeFunc = _ItemTableResize, 
		resizeArg = self,
		sizable = true
	}
	local itemTable = vendor.ItemTable:new(cfg)
	self.itemTable = itemTable
	self.inventorySeller = vendor.InventorySeller:new(self.frame, self.db.profile.inventoryTableCfg, _ItemTableResize, self)
	self.itemModel.ownerHighlight = self.itemTable:AddHighlight(0.6, 1, 1, 0.8)
	self.itemModel.playerHasBidHighlight = self.itemTable:AddHighlight(1, 0.6, 0.6, 0.8)	
end

--[[
	Updates the gui for displaying the frame (Interface method).
--]]
function vendor.Seller:UpdateTabFrame()
	log:Debug("Seller:UpdateTabFrame enter")
--	AuctionFrameTopLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-AuctionFrame-Auction-TopLeft")
--	--AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top")
--	AuctionFrameTop:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-AuctionFrame-Auction-Top")
--	--AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight")
--	AuctionFrameTopRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-AuctionFrame-Auction-TopRight")
--	AuctionFrameBotLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-AuctionFrame-Auction-BotLeft")
--	--AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot")
--	AuctionFrameBot:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-AuctionFrame-Auction-Bot")
--	AuctionFrameBotRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-AuctionFrame-Auction-BotRight")

	--AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopLeft")	
	AuctionFrameTopLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\Seller-TopLeft")
	AuctionFrameTop:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-Top")
	AuctionFrameTopRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-TopRight")
	AuctionFrameBotLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\Seller-BotLeft")
	--AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotLeft")
	AuctionFrameBot:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-Bot")
	AuctionFrameBotRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-BotRight")

	self.auto:SetItem(nil)
	log:Debug("Seller:UpdateTabFrame exit")
end

--[[
	Returns the type of this auction house tab.
--]]
function vendor.Seller:GetTabType()
	return SELLER_TAB;
end
	
--[[
	Shows the tabbed frame (Interface method).
--]]
function vendor.Seller:ShowTabFrame()
	log:Debug("Seller:ShowTabFrame enter")
	self.frame:Show();
	_UpdateInventory(self);
	self.inventorySeller:UpdateInventory()
	self.itemTable:Show()
	self.inventorySeller:Show()
	log:Debug("Seller:ShowTabFrame exit")
end

--[[
	Hides the tabbed frame (Interface method).
--]]
function vendor.Seller:HideTabFrame()
	log:Debug("Seller:HideTabFrame enter")
	self.frame:Hide();
	log:Debug("Seller:HideTabFrame exit")
end

--[[
	Interface method for DropDownButton.
--]]
function vendor.Seller:DropDownButtonSelected(button, value)
	log:Debug("DropDownButtonSelected enter");
	local id = button:GetId();
	log:Debug("id: "..id);	
	if (id == DURATION_DROPDOWN_ID) then
		log:Debug("duration selected");
		-- duration has been selected
		_DurationSelected(self, value)
	elseif (id == PRIZING_DROPDOWN_ID) then
		log:Debug("prizing selected");
		_PrizingSelected(self, value)
	elseif (self.item) then
		local stackSize = self.stackDropDown:GetSelectedValue();
		log:Debug("DropDownButtonSelected stackSize: %d", stackSize)
		if (id == STACK_DROPDOWN_ID) then
			log:Debug("stack selected");
			-- new stacksize has been selected
			_UpdateCountDropDown(self);
			self.selectedStackSize = stackSize;
--			-- only change the prizes, if they are shown per stack
--			keepPrices = self.db.profile.bidType ~= vendor.SellingPrice.BID_TYPE_PER_STACK
		elseif (id == COUNT_DROPDOWN_ID) then
			log:Debug("count selected");
--			-- change only needed if bid type is set to all
--			keepPrices = self.db.profile.bidType ~= vendor.SellingPrice.BID_TYPE_ALL and value ~= self.lastCount
		end
		log:Debug("DropDownButtonSelected refresh keepPrices: %s", keepPrices or false)
		self:RefreshPrices()
	end
end

--[[
	BAG_UPDATe event has been triggered.
--]]
function vendor.Seller:BAG_UPDATE()
	_UpdateInventory(self)
end

--[[
	Auction house has been closed
--]]
function vendor.Seller:AUCTION_HOUSE_CLOSED()
	_SelectItem(self, nil);
	self.item = nil
	self.lastItem = nil
	self.itemModel:SetScanSet(nil)
end

--[[
	Refresh scanset if auctions changes.
--]]
function vendor.Seller:CHAT_MSG_SYSTEM(event, message)
	if (message == ERR_AUCTION_REMOVED) then
		self.updateItemModel = 10
	elseif (message == ERR_AUCTION_STARTED) then
		self.updateItemModel = 10
	elseif (message == ERR_AUCTION_BID_PLACED) then
		self.updateItemModel = 10
	end
end

--[[
	Refresh scanset if auctions changes.
--]]
function vendor.Seller:AUCTION_OWNED_LIST_UPDATE()
	self.updateItemModel = 10
end

--[[
	Hooks the StartAuction function to remember the prizes.
--]]
function vendor.Seller:StartAuction(minBid, buyoutPrize, runTime, stackSize, numStacks)
   	-- we want to remember the "minBid" and "buyoutPrice" for the next time
   	local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount = GetAuctionSellItemInfo()
   	log:Debug("StartAuction stackSize [%s] numStacks [%s] minBid [%s]", stackSize, numStacks, minBid)
   	if (name) then
      	-- unfortunately we need the itemLink, we have to scan the inventory
      	local itemLink = _FindInventoryItemLink(name);
      	if (itemLink) then
      		local itemLinkKey = vendor.Items:GetItemLinkKey(itemLink);
      		local itemInfo = self.itemInfo
			if (not vendor.Items:GetItemInfo(itemLinkKey, itemInfo, vendor.AuctionHouse:IsNeutral())) then
				vendor.Items:InitItemInfo(itemInfo)
			end
	 		itemInfo.minBid = math.floor(minBid / stackSize);
	 		itemInfo.buyout = math.floor(buyoutPrize / stackSize);
	 		log:Debug("remember minBid [%s] buyout [%s]", itemInfo.minBid, itemInfo.buyout)
	 		vendor.Items:PutItemInfo(itemLinkKey, vendor.AuctionHouse:IsNeutral(), itemInfo);
      	end
   	end
end

--[[
	Event callback for filling in last auction prizes for the given item.
--]]
function vendor.Seller:NEW_AUCTION_UPDATE()
	MoneyInputFrame_SetCopper(StartPrice, 0);
	MoneyInputFrame_SetCopper(BuyoutPrice, 0);
	-- we want to fill in old "minBid" and "buyoutPrice"
	local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
	if (name) then
		-- unfortunately we need the itemLink, we have to scan the inventory
		local itemLink = _FindInventoryItemLink(name);
		if (itemLink) then
			local itemInfo = self.itemInfo
			if (vendor.Items:GetItemInfo(itemLinkKey, itemInfo, vendor.AuctionHouse:IsNeutral())) then
				if (itemInfo.minBid > 0) then
					MoneyInputFrame_SetCopper(StartPrice, itemInfo.minBid * count);
	 			end
	 			if (itemInfo.buyout > 0) then
	    			MoneyInputFrame_SetCopper(BuyoutPrice, itemInfo.buyout * count);
	 			end
      		end
      	end
   	end
end

function vendor.Seller:AUCTION_STATISTIC_UPDATE(msg, itemLinkKey)
	log:Debug("Seller:AUCTION_STATISTIC_UPDATE itemLinkKey: %s", itemLinkKey)
	local myItemLinkKey
	if (self.item) then
		myItemLinkKey = self.item.itemLinkKey
	end
	if (not myItemLinkKey and self.lastItem) then
		myItemLinkKey = self.lastItem.itemLinkKey
	end
	log:Debug("myItemLinkKey [%s]", myItemLinkKey)
   	if (myItemLinkKey and ((itemLinkKey and itemLinkKey == myItemLinkKey) or not itemLinkKey)) then
		local scanSet = vendor.Gatherer:GetCurrentAuctions(myItemLinkKey, vendor.AuctionHouse:IsNeutral())
		_ScanSetUpdate(self, scanSet)
	end
end

function vendor.Seller:ITEM_SETTINGS_UPDATED()
	log:Debug("ITEM_SETTINGS_UPDATED")
	if (self.item and self.item.link) then
		_SelectItem(self, self.item.link)
	end
end

--[[
	Returns information about the currently selected item, if any.
	@return itemName, itemLink
--]]
function vendor.Seller:GetSelectedItemInfo()
	if (self.item) then
		return self.item.name, self.item.link;
	end
	return nil;
end	

--[[
	Returns whether the seller frame is currently visible.
--]]
function vendor.Seller:IsSellerFrameVisible()
	return vendor.AuctionHouse:IsAuctionHouseTabShown(SELLER_TAB)
end

--[[
	Inventory item was clicked, we pick it up for the seller frame, if appropriate. 
--]]
function vendor.Seller:ContainerFrameItemButton_OnModifiedClick(frame, button, ...)
	-- some addons forget to pass the button parameter :-(
	log:Debug("OnModifiedClick")
	local but = button or "LeftButton"
	if (((but == "RightButton") or (but == "LeftButton" and IsShiftKeyDown())) and self:IsSellerFrameVisible() and not CursorHasItem()) then
		local itemLink = GetContainerItemLink(frame:GetParent():GetID(), frame:GetID())
		if (itemLink) then
			-- we have to pickup for deposit calculation
			PickupContainerItem(frame:GetParent():GetID(), frame:GetID())
			_PickItem(self, itemLink)
		end
	else
		self.hooks["ContainerFrameItemButton_OnModifiedClick"](frame, button, ...)
	end
end

--[[
	Selects the given pricing model.
--]]
function vendor.Seller:SelectPricingModel(id, keepPrices)
	log:Debug("Seller:SelectPricingModel enter id: "..(id or "NA"))
	self.prizingDropDown:SelectValue(id)
	_PrizingSelected(self, id, keepPrices)
	log:Debug("Seller:SelectPricingModel exit")
end

--[[
	Refreshes the prices for minbid resp. buyout. 
--]]
function vendor.Seller:RefreshPrices()
	--log:Debug("RefreshPrizes")
	if (not self.sellingPrice:IsUserDefined()) then
    	local minBid = 0
    	local buyout = 0
    	if (not self.stackDropDown:IsValid()) then
    		--log:Debug("RefreshPrizes exit because of invalid stack drop down")
    		return nil
    	end
    	if (not self.countDropDown:IsValid()) then
    		--log:Debug("RefreshPrizes exit because of invalid count drop down")
    		return nil
    	end
    	if (self.item) then
    		-- determine prizing model
    		local prizeModel = self.prizingDropDown:GetSelectedValue()
    		if (prizeModel == self.PRIZE_MODEL_FIX) then
				minBid, buyout = _GetItemAuctionSellValues(self.item.link)
    		elseif (prizeModel == self.PRIZE_MODEL_MARKET) then
    			minBid, buyout = _GetMarketPrice(self, self.item.link)
    		elseif (prizeModel == self.PRIZE_MODEL_CURRENT) then
    			minBid, buyout = _GetCurrentPrice(self, self.item.link)
    		elseif (prizeModel == self.PRIZE_MODEL_UNDERCUT) then
    			minBid, buyout = _GetUndercutPrice(self, self.item.link)
    		elseif (prizeModel == self.PRIZE_MODEL_MULTIPLIER) then
    			minBid, buyout = _GetMultiplierPrice(self, self.item.link)
    		elseif (prizeModel == self.PRIZE_MODEL_LOWER) then
    			minBid, buyout = _GetLowerPrice(self, self.item.link)
    		end
    		if (not minBid or minBid <= 0) then
    			minBid = self.startPrize
    		end
    		if (not buyout or buyout <= 0) then
    			buyout = minBid * 2
    		end
    	end
    	self.sellingPrice:SetPrices(minBid, buyout, vendor.SellingPrice.BID_TYPE_PER_ITEM, false)
    	--log:Debug("RefreshPrizes minBidPerItem [%s] buyoutPerItem [%s] item [%s] startPrice [%s]", minBid, buyout or 0, self.item, self.startPrize)
    end
    _UpdatePrices(self)
end

--[[
	Selects the given inventory item for selling.
--]]
function vendor.Seller:SelectInventoryItem(itemLink)
	_PickItem(self, itemLink)
end

--[[
	Sets the progress together with the given message.
--]]
function vendor.Seller:SetProgress(msg, percent)
	--log:Debug("SetProgress msg [%s] percent [%s]", msg, percent)
--	self:Show()
	if (msg and strlen(msg) > 0) then
		self.title:Hide()
		self.statusBar:Show()
		self.statusBarText:Show()
		self.statusBar:SetValue(percent)
		self.statusBarText:SetText(msg)
	else
		self.title:Show()
		self.statusBar:Hide()
		self.statusBarText:Hide()
	end
end

