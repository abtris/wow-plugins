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
	Sceleton for performing auction scans. The processing is done in ScanModules.
--]]
vendor.ScanTask = {}
vendor.ScanTask.prototype = {}
vendor.ScanTask.metatable = {__index = vendor.ScanTask.prototype}

local log = vendor.Debug:new("ScanTask")

local L = vendor.Locale.GetInstance()

local SCAN_PAGE_NONE = 0 -- not interested in scanning pages
local SCAN_PAGE_WAIT = 1 -- waiting to scan next page
local SCAN_PAGE_PERFORM = 2 -- got permission to scan

local function _GetAuctionItemInfo(self, typ, index)
	local getsPerSecond = self.getsPerSecond
	if (not self.getAll) then
		getsPerSecond = 400
	end
	while (true) do
		local now = GetTime()
    	local sec = math.floor(now)
    	local secPassed = now - sec
    	if (not self.throttleSecond or sec ~= self.throttleSecond) then
    		self.throttleSecond = sec
    		self.getCalls = 0
    		break
    	else
        	if ((self.getCalls + 1) > (getsPerSecond * secPassed)) then
        		--log:Debug("have to throttle calls [%s] passed [%s] allowed [%s]", self.getCalls, secPassed, (getsPerSecond * secPassed))
       			coroutine.yield()
       		else
       			self.getCalls = self.getCalls + 1
       			break
        	end
    	end
	end
	return GetAuctionItemInfo(typ, index)
end
    			
local function _StopScan(self, complete)
	log:Debug("_StopScan cancelled [%s] complete [%s]", self.cancelled, complete)
	if (not self.stopped) then
		vendor.Seller:SetProgress("", 0)
		if (not self.silent) then
			vendor.Scanner.scanFrame:ScanFinished()
		end
		if (self.getAll) then
			vendor.Vendor:Print(L["Scan finished after %s"]:format(SecondsToTime(GetTime() - self.startedAt)))
		end
		for i=1,#self.modules do
			self.modules[i]:StopScan(complete)
		end
		vendor.Scanner:AbandonScan(complete)
		self.stopped = true
	end
end
 
--[[
	Waits until the owner is available or the the timeout time is reached.
--]]
local function _WaitForOwners(self, timeoutTime)
	local doCheck, now, lastCheck, owner
	-- init the missing owner index
	local index = wipe(self.ownerIndex)
	local numBatchAuctions = GetNumAuctionItems("list")
	for i=1,numBatchAuctions do
		owner = select(12, _GetAuctionItemInfo(self, "list", i))
		if (not owner) then
			table.insert(index, i)
		end
	end
	-- wait for missing owners
	while (#index > 0 and self.running) do
		now = GetTime()
		if (not lastCheck or (now - lastCheck) >= 0.2) then
			lastCheck = now
    		for i=#index,1,-1 do
    			owner = select(12, _GetAuctionItemInfo(self, "list", index[i]))
    			if (owner) then
    				table.remove(index, i)
    			end
    		end
    	end
		if (now >= timeoutTime) then
			break
		end
		coroutine.yield()
	end
	if (#index > 0) then
		log:Debug("[%s] owners not found", #index)
	end
	return #index == 0
end

local function _UpdateStatus(self)
	if (not self.silent) then
    	local now = GetTime()
    	local passed = now - self.startedAt
    	local t = (self.total * passed) / self.currentIndex
    	local remaining = t - passed 
    	local restTime = SecondsToTime(math.max(1, remaining))
    	local msg = L["Scan auction %s/%s - time left: %s"]:format(self.currentIndex, self.total, restTime)
    	
--   		log:Debug("_UpdateStatus silent [%s] started [%s] page [%s] maxPages [%s] currentIndex [%s] total [%s] percent [%s] msg [%s] remaining [%s] t[%s]",
--		self.silent, self.startedAt, self.page, self.maxPages, self.currentIndex, self.total, self.currentIndex / self.total, msg, remaining, t)

    	vendor.Scanner.scanFrame:SetProgress(msg, self.currentIndex / self.total)
    	vendor.Seller:SetProgress(msg, self.currentIndex / self.total)
    end
end

--[[ 
	Reads in the list of auction items.
--]]
local function _ReadPage(self)
	log:Debug("_ReadPage")
	local status = 0
	for i = 1, #self.modules do
		status = math.max(status, self.modules[i]:StartPage(self.page) or 0)
	end
	if (status == 1 or self.waitForOwners) then
		log:Debug("waitForOnwers")
		if (not self.getAll) then
			_WaitForOwners(self, GetTime() + 7)
		end
	end
	local numBatchAuctions, total = GetNumAuctionItems("list")
	log:Debug("numBatchAuction [%s] total [%s]", numBatchAuctions, total)
	self.total = total
	if (numBatchAuctions == total) then
		self.maxPages = 1
	else
		self.maxPages = math.ceil(total / NUM_AUCTION_ITEMS_PER_PAGE)
	end
	local batch = 0
	self.currentIndex = 0
	for index = numBatchAuctions, 1, -1 do
		if (not self.running) then
			break
		end
		local itemLink = GetAuctionItemLink("list", index)
		local timeLeft = GetAuctionItemTimeLeft("list", index)
		if (itemLink) then
			local itemLinkKey = vendor.Items:GetItemLinkKey(itemLink)
			if (not (self.itemLinkKey and self.itemLinkKey ~= itemLinkKey)) then
    			local name, texture, count, quality, canUse, level, 
    			minBid, minIncrement, buyoutPrice, bidAmount, 
    			highBidder, owner, saleStatus = _GetAuctionItemInfo(self, "list", index)
				for i=1,#self.modules do
					self.modules[i]:NotifyAuction(itemLinkKey, itemLink, index, name, texture, count, 
							quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, 
							owner, saleStatus, timeLeft)
				end
			end
		end
		self.currentIndex = self.currentIndex + 1
		batch = batch + 1
		if (batch >= 100) then
			if (self.getAll) then
				_UpdateStatus(self)
			end
			batch = 0
		end
	end
	local status = 0
	for i=1,#self.modules do
		status = math.max(status, self.modules[i]:StopPage() or 0)
	end
	if (status == 1) then
		-- read the same page again
		self.page = self.page - 1
	end
	if (numBatchAuctions == total) then
		self.currentIndex = math.max(1, total)
	else
		self.currentIndex = self.page * NUM_AUCTION_ITEMS_PER_PAGE + 1
	end
	_UpdateStatus(self)
end

local function _BlockForAuctionListUpdate(self)
	log:Debug("_BlockForAuctionListUpdate pendingAuctionListUpdate [%s]", self.pendingAuctionListUpdate)
   	while (self.pendingAuctionListUpdate and self.running) do
   		coroutine.yield()
   	end
   	log:Debug("_BlockForAuctionListUpdate exit pendingAuctionListUpdate [%s]", self.pendingAuctionListUpdate)
end

local function _BlockForCanSendAuctionQuery(self)
	while (self.running and not vendor.Scanner:MaySendAuctionQuery()) do
		coroutine.yield()
	end
end

local function _GetAllScan(self)
	-- query auctions
	self.getAll = true
	
	vendor.Scanner.scanFrame:SetProgress(L["Performing getAll scan. This may last up to several minutes..."], 0)
	QueryAuctionItems("", 0, 0, 0, 0, 0, 0, 0, 0, true)
	
	vendor.Scanner.db.profile.lastGetAll = GetTime()
	
	-- wait for result
	_BlockForCanSendAuctionQuery(self)
	
	-- read complete auction house
   	if (self.running) then
    	_ReadPage(self)
    end
end

local function _PagedScan(self, info)
	log:Debug("_PagedScan enter")
	self.batchScan = true
	self.page = 0
	local info = self.queryInfo
	
	-- perhaps we have to shorten the name
	local name = info.name
	if (name) then
		-- too long names may cause a disconnect
		name = string.sub(name, 1, 62)
	end
	
	-- loop all pages
	while (self.running) do
		
		_BlockForCanSendAuctionQuery(self)
		
		if (self.running) then
		
    		self.pendingAuctionListUpdate = true
    		QueryAuctionItems(name, info.minLevel, info.maxLevel, info.invTypeIndex, 
    				info.classIndex, info.subclassIndex, self.page, info.isUsable, info.qualityIndex)
    		
    		_BlockForAuctionListUpdate(self)
    		
    		if (self.running) then
    			_ReadPage(self)
    			
        		-- prepare next page
        		self.page = self.page + 1
        		if (self.page > self.maxPages) then
        			break
        		end
        	end
        end
	end
	log:Debug("_PagedScan exit")
end

--[[ 
	Creates a new instance with the given name (scanId) and a query description containing the fields:
	itemLinkKey, name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex
	At the end several ScanModules may be added. 
--]]
function vendor.ScanTask:new(scanId, queryInfo, ...)
	local instance = setmetatable({}, self.metatable)
	instance.queryInfo = queryInfo
	instance.running = true
	instance.scanId = scanId
	instance.ownerIndex = {}
	instance.modules = {}
	instance.getsPerSecond = vendor.ScanFrame.SPEEDS[vendor.Scanner.db.profile.scanSpeed or vendor.ScanFrame.SCAN_SPEED_FAST]
	for i=1,select('#', ...) do
		local module = select(i, ...)
		table.insert(instance.modules, module)
	end
	return instance
end

--[[
	Run function of the task, performs the scan.
--]]
function vendor.ScanTask.prototype:Run()
	log:Debug("Run enter")
	self.getCalls = 0
	self.startedAt = GetTime()
	for i = 1, #self.modules do
		self.modules[i]:StartScan(self.queryInfo, "list")
	end
	
	if (self.running) then
    	local _, getAll = vendor.Scanner:MaySendAuctionQuery()
    	local scanSpeedOff = vendor.ScanFrame.SCAN_SPEED_OFF == vendor.Scanner.db.profile.scanSpeed
    	if (getAll and self.queryInfo.getAll and not scanSpeedOff) then
    		vendor.Scanner:UnregisterAuctionListUpdate()
    		_GetAllScan(self)
    	else
    		vendor.Scanner:RegisterAuctionListUpdate()
    		_PagedScan(self)
    	end
    end
	log:Debug("exit name [%s] failed [%s] canceled [%s]", self.queryInfo.name, self.failed, self.cancelled)
	_StopScan(self, not self.cancelled)
	log:Debug("Run exit")
end

--[[
	Cancels the task and leaves it as soon as possible. 
--]]
function vendor.ScanTask.prototype:Cancel()
	log:Debug("Cancel")
	self.cancelled = true
	self.running = nil
end

--[[
	Returns whether the task was canecelled.
--]]
function vendor.ScanTask.prototype:IsCancelled()
	return self.cancelled
end

--[[ 
	Reads in the list of auction items, will be called by the Scanner.
--]]
function vendor.ScanTask.prototype:AuctionListUpdate()
	log:Debug("AuctionListUpdate")
	self.pendingAuctionListUpdate = nil
end

--[[
	Will be called by the TaskQueue, if the task has failed with an 
	unexpected error.
--]]
function vendor.ScanTask.prototype:Failed()
	log:Debug("Failed")
	self.failed = true
	self:Cancel()
	_StopScan(self)
end

--[[
	Returns the unique scanId.
--]]
function vendor.ScanTask.prototype:GetScanId()
	return self.scanId
end

--[[
	Returns the result as a map with: scanId
--]]
function vendor.ScanTask.prototype:GetResult()
	return {scanId = self.scanId, cancelled = self.cancelled}
end
