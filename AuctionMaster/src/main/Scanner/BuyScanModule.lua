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
	ScanModule to be integrated in a ScanTask for buying auctions.
--]]
vendor.BuyScanModule = {}
vendor.BuyScanModule.prototype = {}
vendor.BuyScanModule.metatable = {__index = vendor.BuyScanModule.prototype}

local log = vendor.Debug:new("BuyScanModule")

--[[ 
	Creates a new instance.
--]]
function vendor.BuyScanModule:new(auctions)
	local instance = setmetatable({}, self.metatable)
	instance.index = {}
	instance.auctions = {}
	vendor.Tables.Copy(auctions, instance.auctions)
	table.sort(instance.auctions, function(a, b)
			return a.bid > b.bid
		end
	)
	return instance
end

--[[
	Notifies the beginning of the scan. The info struct contains:
	itemLinkKey, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex
--]]
function vendor.BuyScanModule.prototype:StartScan(info, ahType)
	log:Debug("StartScan name [%s]", info.name)
	self.info = info
	self.ahType = ahType
end

--[[
	Notifies the termination of the scan.
--]]
function vendor.BuyScanModule.prototype:StopScan(complete)
	log:Debug("StopScan name [%s] complete [%s] itemLinkKey [%s]", self.info.name, complete, self.info.itemLinkKey)
end

--[[
	Notifies the ScanModule that a page is about to be read. The ScanModule
	may return:
	1 for letting the ScanTask wait for the owners.
--]]
function vendor.BuyScanModule.prototype:StartPage(page)
	log:Debug("StartPage enter")
	wipe(self.index)
	log:Debug("StartPage exit")
end

--[[
	Notifies the ScanModule that a page is now finished. The ScanModule
	may return:
	1 for scanning the same page again (perhaps something was bought, which modified the current page)
--]]
function vendor.BuyScanModule.prototype:StopPage()
--	log:Debug("StopPage enter")
--	if (#self.index > 0) then
--		log:Debug("[%s]", #self.index)
--		-- ask the user
--		log:Debug("dialog [%s]", vendor.Scanner.buyDialog)
--		local buy = vendor.Scanner.buyDialog:AskToBuy(self.ahType, self.index)
--		log:Debug("buy [%s]", buy)
--		log:Debug("StopPage exit 1")
--		return 1
--	end
--	log:Debug("StopPage exit")
end

--[[
	Notifies about the given auction data read. The auctions will be notified once for each index.
--]]
function vendor.BuyScanModule.prototype:NotifyAuction(itemLinkKey, itemLink, index, name, texture, count, 
		quality, canUse, level, minBid, minIncrement, buyout, bidAmount, highBidder, owner, saleStatus, 
		timeLeft)
		
	for i=#self.auctions,1,-1 do
		local info = self.auctions[i]
		if (info.name == name and info.count == count) then
		    
		    local bid = minBid
		    if (bidAmount and bidAmount > 0) then
		    	bid = bidAmount
		    end
		    local doBuyout = info.doBuyout and buyout and buyout > 0 and info.bid >= buyout
    		local doBid = info.doBid and info.bid >= bid and not doBuyout
    		if (doBid or doBuyout) then
    			log:Debug("bid %s buyout %s doBuyout %s doBid %s ibuyout %s ibid %s", bid, buyout, doBid, doBuyout, info.buyout, info.bid)
            	if (not self.scanDialog) then
            		self.scanDialog = vendor.ScanDialog:new()
            	end
        		self.scanDialog:AskToBuy(itemLink, count, minBid, bidAmount, minIncrement, buyout, info.reason, 
        				index, doBid, doBuyout, highBidder)
    			table.insert(self.index, info)
    			table.remove(self.auctions, i)
    			break
        	end
		end
	end
	if (#self.auctions == 0) then
		log:Debug("stop")
		vendor.Scanner:StopScan()
	end
end
