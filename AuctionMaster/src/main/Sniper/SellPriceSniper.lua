--[[
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

--[[
	Snipe using bookmarks.
--]]
vendor.SellPriceSniper = {}
vendor.SellPriceSniper.prototype = {}
vendor.SellPriceSniper.metatable = {__index = vendor.SellPriceSniper.prototype}

local L = vendor.Locale.GetInstance()

--[[ 
	Creates a new instance.
--]]
function vendor.SellPriceSniper:new(auctions)
	local instance = setmetatable({}, self.metatable)
	instance.auctions = auctions
	return instance
end

--[[
	Checks whether to snipe for the item and returns doBuy, reason
--]]
function vendor.SellPriceSniper.prototype:Snipe(itemLink, itemName, count, bid, buyout, highBidder)
	local minProf = vendor.Scanner.db.profile.minimumProfit * 100
	local sellPrice = select(11, GetItemInfo(itemLink))
	if (sellPrice and sellPrice > 0) then
		sellPrice = sellPrice * count
		local money = GetMoney()
		if (buyout and buyout > 0 and buyout <= money and sellPrice > (buyout + minProf)) then
			local profit = vendor.Format.FormatMoney(sellPrice - buyout, true)
			local percent = math.floor(100.0 * (sellPrice - buyout) / buyout + 0.5)
			local reason = L["Buyout is %s less than sell price (%d%%)."]:format(profit, percent)
			return true, reason
		elseif (bid and bid <= money and sellPrice > (bid + minProf) and not highBidder) then
			local profit = vendor.Format.FormatMoney(sellPrice - bid, true)
			local percent = math.floor(100.0 * (sellPrice - bid) / bid + 0.5)
			local reason = L["Bid is %s less than sell price (%d%%)."]:format(profit, percent)
			return true, reason
		end		
	end
	return false
end

--[[
	Returns the unique identifier of the sniper.
--]]
function vendor.SellPriceSniper.prototype:GetId()
	return "sellPriceSniper"
end

--[[
	Returns the name to be displayed for this sniper module.
--]]
function vendor.SellPriceSniper.prototype:GetDisplayName()
	return L["Sell prices"]
end

--[[
	Returns an ordering information for the sniper. Lower numbers will be executed first.
--]]
function vendor.SellPriceSniper.prototype:GetOrder()
	return 2
end
