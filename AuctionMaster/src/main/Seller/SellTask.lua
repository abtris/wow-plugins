--[[
	Task for selling an item.
	
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

vendor.SellTask = {}
vendor.SellTask.prototype = {}
vendor.SellTask.metatable = {__index = vendor.SellTask.prototype}

local L = vendor.Locale.GetInstance()

local log = vendor.Debug:new("SellTask")

--[[
	Sells a stack of the given size and returns whether the operation
	succeeded.
--]]
local function _Sell(self, stackSize)
	log:Debug("_Sell 1")
	-- ensure that the auction slot is free, just in case...
	ClearCursor();
	log:Debug("_Sell 2")
	vendor.clickAuctionSellItemButton()
	ClearCursor()
	log:Debug("_Sell 3")
	-- try to get stack
	local rtn = false;
	local bag, slot = self.inventoryHandle:PickupItemStack(self.itemLink, stackSize); 
	if (bag) then
	log:Debug("_Sell 4")
		vendor.clickAuctionSellItemButton()
		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo()
		local itemName = GetItemInfo(self.itemLink)
		log:Debug("_Sell 5")
		if (not itemName or not name or itemName ~= name or count ~= stackSize) then
			vendor.Vendor:Error(L["Failed to create stack of %d items."]:format(stackSize))
		else
			log:Debug("_Sell 6")
			StartAuction(self.minBidPerItem * stackSize, self.buyoutPerItem * stackSize, self.runTime);
			vendor.clickAuctionSellItemButton()
			rtn = not CursorHasItem();
			log:Debug("_Sell 7")
			if (not rtn) then
				vendor.Vendor:Error(L["Failed to sell item"]);
			else
				-- wait for the item to disappear from the bag
				self.inventoryHandle:WaitForEmptySlot(bag, slot, GetTime() + 7);
			end
		end
		ClearCursor()
	end
	log:Debug("_Sell exit")
	return rtn;
end

--[[
	Constructor.
	@param backlog number of items to sell, if all stacks where sold.
--]]
local function _Init(self, inventoryHandle, itemLink, minBidPerItem, buyoutPerItem, runTime, stackSize, numStacks, backlog)
	self.inventoryHandle = inventoryHandle;
	self.itemLink = itemLink;
	self.minBidPerItem = minBidPerItem;
	self.buyoutPerItem = buyoutPerItem;
	self.runTime = runTime;
	self.stackSize = stackSize;
	self.numStacks = numStacks;
	self.backlog = backlog;
end

--[[ 
	Creates a new instance.
--]]
function vendor.SellTask:new(inventoryHandle, itemLink, minBidPerItem, buyoutPerItem, runTime, stackSize, numStacks, backlog)
	local instance = setmetatable({}, self.metatable)
	_Init(instance, inventoryHandle, itemLink, minBidPerItem, buyoutPerItem, runTime, stackSize, numStacks, backlog)
	return instance
end

--[[
	Method to execute the task.
--]]
function vendor.SellTask.prototype:Run()
	for i = 1, self.numStacks do
		vendor.OwnAuctions.delay = GetTime()
		if (not _Sell(self, self.stackSize)) then
			return nil
		end
	end
	if (self.backlog and self.backlog > 0) then
		vendor.OwnAuctions.delay = GetTime()
		_Sell(self, self.backlog);
	end
	vendor.OwnAuctions.delay = nil
end
