--[[
	Gathers statistics for the auctions found.
	
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

vendor.Statistic = vendor.Vendor:NewModule("Statistic");
local L = vendor.Locale.GetInstance()
local AceEvent = LibStub("AceEvent-3.0")
local self = vendor.Statistic;
local log = vendor.Debug:new("Statistic")

--[[
	Sets the given value in the profile.
--]]
local function _SetValue(info, value)
	self.db.profile[info.arg] = value;
end

--[[
	Returns the given value from the profile.
--]]
local function _GetValue(info)
	return self.db.profile[info.arg]
end

--[[
	Update the statistic for given item.
--]]
--local function _UpdateStatistic(self, itemLinkKey, minBids, buyouts, isNeutral)
--	-- calculate the minbid average
--	table.sort(minBids);
--	table.sort(buyouts);
--	vendor.Math.CleanupByStandardDeviation(minBids, self.db.profile.smallerStdDevMul, self.db.profile.largerStdDevMul)
--	vendor.Math.CleanupByStandardDeviation(buyouts, self.db.profile.smallerStdDevMul, self.db.profile.largerStdDevMul)
--	local avgMinBid = vendor.Math.GetMedian(minBids);
--	local avgBuyout = vendor.Math.GetMedian(buyouts);
--	local itemInfo = self.itemInfo
--	if (not vendor.Items:GetItemInfo(itemLinkKey, itemInfo, isNeutral)) then
--		vendor.Items:InitItemInfo(itemInfo)
--	end
--	if (avgMinBid > 0) then
--		-- update moving average of the medians
--		if (itemInfo.avgMinBid > 0) then
--			itemInfo.avgMinBid = vendor.Math.UpdateAverage(itemInfo.avgMinBid, self.db.profile.movingAverage, avgMinBid, 1);
--		else
--			itemInfo.avgMinBid = avgMinBid;
--		end
--	end
--	if (avgBuyout > 0) then
--		-- update moving average of the medians
--		if (itemInfo.avgBuyout > 0) then
--			itemInfo.avgBuyout = vendor.Math.UpdateAverage(itemInfo.avgBuyout, self.db.profile.movingAverage, avgBuyout, 1);
--		else
--			itemInfo.avgBuyout = avgBuyout;
--		end
--	end
--	-- write back item
--	vendor.Items:PutItemInfo(itemLinkKey, isNeutral, itemInfo);
--	AceEvent:SendMessage("AUCTION_STATISTIC_UPDATE", itemLinkKey)
--end

--[[
	Returns avgMinBid, avgBuyout, minMinBid and minBuyout for the given scan result.
--]]
local function _GetAvgs(result, deactivateStdDev)
	local minBids = {};
	local buyouts = {};
	for i = 1, result:Size() do
		local itemLinkKey, time, timeLeft, count, minBid, minIncrement, buyout = result:Get(i);
		if (itemLinkKey) then
			if (minBid and minBid > 0) then
				table.insert(minBids, math.floor(minBid / count + 0.5));
			end
			if (buyout and buyout > 0) then
				table.insert(buyouts, math.floor(buyout / count + 0.5));
			end
		end
	end
	table.sort(minBids);
	table.sort(buyouts);
	if (not deactivateStdDev) then
		vendor.Math.CleanupByStandardDeviation(minBids, self.db.profile.smallerStdDevMul, self.db.profile.largerStdDevMul)
		vendor.Math.CleanupByStandardDeviation(buyouts, self.db.profile.smallerStdDevMul, self.db.profile.largerStdDevMul)
	end
	local avgMinBid = vendor.Math.GetMedian(minBids);
	local avgBuyout = vendor.Math.GetMedian(buyouts);
	local minMinBid = nil
	local minBuyout = nil
	if (table.getn(minBids) > 0) then
	 	minMinBid = minBids[1]
	end
	if (table.getn(buyouts) > 0) then
		minBuyout = buyouts[1]
	end
	return avgMinBid, avgBuyout, minMinBid, minBuyout;
end
	
--[[
	Appends the given money description to the tooltip
--]]
local function _AddMoney(self, tooltip, prompt, bid, buyout)
	local msg = vendor.Format.FormatMoney(bid, true).."/"..vendor.Format.FormatMoney(buyout, true)
	tooltip:AddDoubleLine(prompt, msg)
end

--[[
	Adds auction information to the GameTooltip of the currently available snapshot.
--]]
local function _AddCurrentAuctionInfo(self, tooltip, itemInfo, itemLink, count, isNeutral)
	local avgBid, avgBuyout, lowerBid, lowerBuyout, upperBid, upperBuyout, numAuctions, numBuyouts
		= vendor.Gatherer:GetCurrentAuctionInfo(itemLink, neutralAh, vendor.TooltipHook.db.profile.adjustCurrentPrices)
	if (numAuctions > 0) then
		local msg1, msg2
		if (vendor.TooltipHook.db.profile.showCurrentLabel) then
			tooltip:AddLine(L["Current auctions [%s]"]:format(numAuctions));
		end
		if (vendor.TooltipHook.db.profile.showCurrentMinBid) then
			-- avg minbid
			if (avgBid > 0) then
				if (count > 1) then
					msg1 = L["Bid (%d)"]:format(count);
					msg2 = vendor.Format.FormatMoneyValues(avgBid, avgBid * count, true)
				else
					msg1 = L["Bid"];
					msg2 = vendor.Format.FormatMoney(avgBid, true);
				end
				tooltip:AddDoubleLine(msg1, msg2);
			end
		end
		if (vendor.TooltipHook.db.profile.showLowerMinBid) then
			if (lowerBid > 0) then
				if (count > 1) then
					msg1 = L["Lower bid (%d)"]:format(count);
					msg2 = vendor.Format.FormatMoneyValues(lowerBid, lowerBid * count, true)
				else
					msg1 = L["Lower bid"];
					msg2 = vendor.Format.FormatMoney(lowerBid, true);
				end
				tooltip:AddDoubleLine(msg1, msg2);
			end
		end
		if (vendor.TooltipHook.db.profile.showCurrentBuyout) then
			if (avgBuyout > 0) then
				-- avg buyout
				if (count > 1) then
					msg1 = L["Buyout (%d)"]:format(count);
					msg2 = vendor.Format.FormatMoneyValues(avgBuyout, avgBuyout * count, true)
				else
					msg1 = L["Buyout"];
					msg2 = vendor.Format.FormatMoney(avgBuyout, true);
				end
				tooltip:AddDoubleLine(msg1, msg2);
			end
		end
		if (vendor.TooltipHook.db.profile.showLowerBuyout) then
			if (lowerBuyout and lowerBuyout > 0) then
				if (count > 1) then
					msg1 = L["Lower buyout (%d)"]:format(count);
					msg2 = vendor.Format.FormatMoneyValues(lowerBuyout, lowerBuyout * count, true)
				else
					msg1 = L["Lower buyout"];
					msg2 = vendor.Format.FormatMoney(lowerBuyout, true);
				end
				tooltip:AddDoubleLine(msg1, msg2);
			end
		end
	end
end

--[[
	Adds auction information to the GameTooltip.
--]]
local function _AddAuctionInfo(self, tooltip, itemInfo, itemLink, count, isNeutral)
	if (vendor.TooltipHook.db.profile.showAllTimeLabel) then
		tooltip:AddLine(L["All time auctions [%s]"]:format(itemInfo.numAuctions));
	end
	local msg1, msg2;
	-- avg minbid
	if (vendor.TooltipHook.db.profile.showAvgMinBid) then
		if (itemInfo.avgBid > 0) then
			if (count > 1) then
				msg1 = L["Bid (%d)"]:format(count);
				msg2 = vendor.Format.FormatMoneyValues(itemInfo.avgBid, itemInfo.avgBid * count, true)
			else
				msg1 = L["Bid"];
				msg2 = vendor.Format.FormatMoney(itemInfo.avgBid, true)
			end
			tooltip:AddDoubleLine(msg1, msg2);
		end
	end
	if (vendor.TooltipHook.db.profile.showAvgBuyout) then
		if (itemInfo.avgBuyout > 0) then
			-- avg buyout
			if (count > 1) then
				msg1 = L["Buyout (%d)"]:format(count);
				msg2 = vendor.Format.FormatMoneyValues(itemInfo.avgBuyout, itemInfo.avgBuyout * count, true)
			else
				msg1 = L["Buyout"];
				msg2 = vendor.Format.FormatMoney(itemInfo.avgBuyout, true)
			end
			tooltip:AddDoubleLine(msg1, msg2);
		end
	end
end

--[[
	Options for this module.
--]]
local function _CreateOptions()
	vendor.Vendor.options2.args.statistic = {
		type = "group",
		name = L["Statistics"],
		desc = L["Statistics"],
		args = {
			movAvg = {
				type = "range",
				name = L["Moving average"],
				desc = L["Selects the number of (approximated) values, that should be taken for the moving average of the historically auction scan statistics."],
				min = 2,
				max = 256,
				step = 1,
				get = _GetValue,
				set = _SetValue,
				arg = "movingAverage",
				order = 3,
			},
			smallerStdDevMul = {
				type = "range",
				name = L["< standard deviation multiplicator"],
				desc = L["Selects the standard deviation multiplicator for statistical values to be removed, which are smaller than the average. The larger the multiplicator is selected, the lesser values are removed from the average calculation."],
				min = 1,
				max = 10,
				step = 0.1,
				get = _GetValue,
				set = _SetValue,
				arg = "smallerStdDevMul",
				order = 4,
			},
			largerStdDevMul = {
				type = "range",
				name = L["> standard deviation multiplicator"],
				desc = L["Selects the standard deviation multiplicator for statistical values to be removed, which are larger than the average. The larger the multiplicator is selected, the lesser values are removed from the average calculation."],
				min = 1,
				max = 10,
				step = 0.1,
				get = _GetValue,
				set = _SetValue,
				arg = "largerStdDevMul",
				order = 5,
			},			
		}
	}
	vendor.Vendor.AceConfigRegistry:RegisterOptionsTable("AuctionMaster Statistic", vendor.Vendor.options2.args.statistic)
	vendor.Vendor.AceConfigDialog:AddToBlizOptions("AuctionMaster Statistic", L["Statistics"], "AuctionMaster")
end

--[[
	Initializes the module.
--]]
function vendor.Statistic:OnInitialize()
	self.db = vendor.Vendor.db:RegisterNamespace("Statistic", {
		profile = {
    		movingAverage = 12,
    		smallerStdDevMul = 2,
    		largerStdDevMul = 2,
    	}
	});
	self.itemInfo = {} -- caching the table
	_CreateOptions();	
end

--[[
	Initializes the module.
--]]
function vendor.Statistic:OnEnable()
	vendor.TooltipHook:AddAppender(self, 20);
--	_ApplySettings(self)
end

--[[
	ScanResultListener interface method for new or updated
	Scansnapshots.
	The complete new scan will be considered, not only the difference, because we are
	working with the median.
--]]
--function vendor.Statistic:ScanSnapshotUpdated(snapshot, isNeutral)
--	vendor.Vendor:Debug("scan update enter");
--	local currentItem = nil; -- current entry for gathering stats
--	local minBids = {}; -- minbids collected for current item
--	local buyouts = {}; -- buyouts collected for current item
--   	for i = 1, snapshot:Size() do
--      	local itemLinkKey, time, timeLeft, count, minBid, minIncrement, buyoutPrice = snapshot:Get(i);
--      	if (itemLinkKey) then
--      		if (currentItem and currentItem ~= itemLinkKey) then
--      			-- a new item, handle the old one
--				_UpdateStatistic(self, currentItem, minBids, buyouts, isNeutral);
--				minBids = {}; -- need table:clear(), or sort(table, n)
--				buyouts = {};
--			end
--			currentItem = itemLinkKey;
--			if (minBid > 0) then
--				table.insert(minBids, math.floor(minBid / count + 0.5));
--      		end
--			if (buyoutPrice > 0) then
--				table.insert(buyouts, math.floor(buyoutPrice / count + 0.5));
--   			end
--      	end
--   	end
--	if (currentItem) then
--		_UpdateStatistic(self, currentItem, minBids, buyouts, isNeutral);
--	end
--	vendor.Vendor:Debug("Statistic:ScanSnapshotUpdated leave");
--end

--[[
	Callback for GameTooltip integration.
--]]
function vendor.Statistic:AppendToGameTooltip(tooltip, itemLink, itemName, count)
	local itemLinkKey = vendor.Items:GetItemLinkKey(itemLink);
	local isNeutral = vendor.AuctionHouse:IsNeutral();
	local itemInfo = self.itemInfo
	
	if (vendor.TooltipHook.db.profile.compactAuctionInfo) then
		local msg1, msg2
		local msg3, msg4
		local _, _, _, lowerBuyout, _, _, numAuctions = vendor.Gatherer:GetCurrentAuctionInfo(itemLink, isNeutral, vendor.TooltipHook.db.profile.adjustCurrentPrices)
		local currentAuctions = false
		if (numAuctions > 0 and lowerBuyout and lowerBuyout > 0) then
			if (count > 1) then
				msg1 = L["Current auctions [%s](%d)"]:format(numAuctions, count)
				msg2 = vendor.Format.FormatMoneyValues(lowerBuyout, lowerBuyout * count, true)
			else
				msg1 = L["Current auctions [%s]"]:format(numAuctions)
				msg2 = vendor.Format.FormatMoney(lowerBuyout, true)
			end
			currentAuctions = true
		end
		if (not currentAuctions or vendor.TooltipHook.db.profile.compactMarketPrice) then
			local _, avgBuyout, numAuctions = vendor.Gatherer:GetAuctionInfo(itemLink, isNeutral, vendor.TooltipHook.db.profile.adjustCurrentPrices)
			if (numAuctions > 0 and avgBuyout and avgBuyout > 0) then
				msg3 = ""
				if (not currentAuctions) then
					msg3 = vendor.Format.GetFontColorCode(vendor.TooltipHook.db.profile.compactColor)
				end
    			if (count > 1) then
    				msg3 = msg3..L["All time auctions [%s](%d)"]:format(numAuctions, count)
    				msg4 = vendor.Format.FormatMoneyValues(avgBuyout, avgBuyout * count, true)
    			else
    				msg3 = msg3..L["All time auctions [%s]"]:format(numAuctions)
    				msg4 = vendor.Format.FormatMoney(avgBuyout, true)
    			end
    			if (not currentAuctions) then
    				msg3 = msg3..FONT_COLOR_CODE_CLOSE
    			end
			end
		end
		if (msg3) then
			tooltip:AddDoubleLine(msg3, msg4)
		end
		if (msg1) then
			tooltip:AddDoubleLine(msg1, msg2)
		end
	else
		local avgBid, avgBuyout, numAuctions, numBuyouts = vendor.Gatherer:GetAuctionInfo(itemLink, isNeutral)
		if (numAuctions > 0) then
			_AddAuctionInfo(self, tooltip, {avgBid = avgBid, avgBuyout = avgBuyout, numAuctions = numAuctions}, itemLink, count, isNeutral);
   		end
		_AddCurrentAuctionInfo(self, tooltip, itemInfo, itemLink, count, isNeutral);
	end
end

--[[
	Returns avgMinBid, avgBuyout, minMinBid, minBuyout, numAuctions for the current 
	auctions for the specified item or nil. The results may be cleaned up
	by a standard deviation.
--]]
function vendor.Statistic:GetCurrentAuctionInfo(itemLink, isNeutral, deactivateStdDev)
	-- TODO std-dev
	local avgBid, avgBuyout, lowerBid, lowerBuyout, _, _, numAuctions = vendor.Gatherer:GetCurrentAuctionInfo(itemLink, isNeutral, not deactivateStdDev)
	return avgBid, avgBuyout, lowerBid, lowerBuyout, numAuctions
--
--	local result = vendor.Scanner:GetScanSet(isNeutral, itemLink);
--	if (result and result:Size() > 0) then
--		local avgMinBid, avgBuyout, minMinBid, minBuyout = _GetAvgs(result, deactivateStdDev) 
--		return avgMinBid, avgBuyout, minMinBid, minBuyout, result:Size()
--	end
--	return nil, nil, nil, nil, 0;
end
