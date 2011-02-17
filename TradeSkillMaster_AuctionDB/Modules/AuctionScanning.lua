--[[
	This file is licensed separate from the license governing use of this addon as a whole.
	The license for this file is the GNU General Public License version 2 (GPLv2) as the code
	within this file is mostly taken from the code for LibAuctionScan-1.0
	(http://www.wowace.com/addons/libauctionscan/) which is licensed under a different license than
	the TradeSkillMaster addon. If you have any questions, please contact Sapu94 (sapu94@gmail.com).
]]

local TSM = select(2, ...)
local lib = {}
TSM.AuctionScanning = lib

-- LUA/WOW API functions
local type, assert, error, select, unpack = type, assert, error, select, unpack
local pairs, ipairs, tinsert = pairs, ipairs, tinsert
local strlower = strlower
local CanSendAuctionQuery, GetAuctionItemInfo, GetNumAuctionItems, QueryAuctionItems = CanSendAuctionQuery, GetAuctionItemInfo, GetNumAuctionItems, QueryAuctionItems

local BASE_DELAY = 0.1

lib.private = lib.private or {toResolve = {}, ahOpen = false}
local private = lib.private

lib.callbacks = lib.callbacks or {results={}, resolved={}, unlocked={}}
lib.locks = lib.locks or {}
lib.embeds = lib.embeds or {}


--[[
	----------------------Helper Functions----------------------
]]

-- checks if the event is one that can be registered to
local events = {"results", "resolved", "unlocked"}
function private.validateEvent(event)
	event = strlower(event)
	for i, v in ipairs(events) do
		if v == event then
			return event
		end
	end
end

-- frame used to resolve items
private.resolveFrame = CreateFrame("Frame")
private.resolveFrame:Hide()
private.resolveFrame.resetRetries = function(self) self.softRetries = 5 self.hardRetries = 3 end
private.resolveFrame:resetRetries()
private.resolveFrame:SetScript("OnUpdate", function(self, elapsed)
	self.timeLeft = (self.timeLeft or BASE_DELAY) - elapsed
	if self.timeLeft <= 0 then
		self.timeLeft = nil
		self:Hide()
		if self.softRetries > 0 then
			-- solf retry
			private.resolve(self.mode)
		else
			-- hard retry
			QueryAuctionItems(unpack(lib.currentQuery))
			self.softRetries = 4
			self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
			self:SetScript("OnEvent", function(self)
				self:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
				private.resolve(self.mode)
			end)
		end
	end
end)

-- resolves items in the current result set
function private.resolve(rType)
	if lib:IsResolved(rType) then
		if lib.locks[lib] then lib:Unlock() end
		private.toResolve[rType] = nil
		private.sendCallbacks("resolved", rType)
		
		for resolve in pairs(private.toResolve) do
			private.resolve(resolve)
			break
		end
	else
		private.toResolve[rType] = true
		if not lib.locks[lib] then
			private.resolveFrame:resetRetries()
			private.resolveFrame.mode = rType
			lib:Lock()
		end
		private.resolveFrame:Show()
	end
end

-- Manages results / resolved callbacks
function private.sendCallbacks(rType, arg)
	if rType == "results" then
		lib.frame:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		lib:Unlock()
	end

	for _, func in ipairs(lib.callbacks[rType]) do
		func(rType, arg)
	end
end

-- frame to catch AUCTION_ITEM_LIST_UPDATE events
lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:SetScript("OnEvent", function(self, event)
	if event == "AUCTION_ITEM_LIST_UPDATE" then
		private.sendCallbacks("results")
	elseif event == "AUCTION_HOUSE_SHOW" then
		private.ahOpen = true
	elseif event == "AUCTION_HOUSE_CLOSED" then
		private.ahOpen = false
	end
end)
lib.frame:RegisterEvent("AUCTION_HOUSE_SHOW")
lib.frame:RegisterEvent("AUCTION_HOUSE_CLOSED")



--[[
	--------------------Library API Functions--------------------
]]

-- embeds the library functions into the passed object
local mixins = {"Lock", "Unlock", "RegisterCallback"}
function lib:Embed(target)
	for _, name in pairs(mixins) do
		target[name] = lib[name]
	end
	lib.embeds[target] = true
	return target
end

-- Hook of QueryAuctionItems function
-- returns true if the query was sent (if we can query)
function lib:QueryAuctionItems(...)
	if lib:CanSendAuctionQuery() then
		lib.currentQuery = {...}
		QueryAuctionItems(...)
		lib.frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
		lib:Lock()
		return true
	else
		return false
	end
end

-- check if we can query the auction house or not
function lib:CanSendAuctionQuery()
	local canRegScan, canGetAll = CanSendAuctionQuery()
	return canRegScan and not lib:IsLocked(), canRegScan, canGetAll
end

-- check if LibAuctionScan is locked or not
function lib:IsLocked()
	for obj, lockStatus in pairs(lib.locks) do
		if lockStatus then
			return true
		end
	end
	return false
end

-- register an addon to be informed of a LibAuctionScan event
function lib.RegisterCallback(obj, event, callback, ...)
	assert(type(event)=="string", "Attempted to register to invalid event type.")
	event = private.validateEvent(event)
	callback = callback or event
	args = {...}
	
	if event then
		local cbFunc
		if type(callback) == "string" and type(obj) == "table" then
			if type(obj[callback]) == "function" then
				cbFunc = function(...) obj[callback](obj, ...) end
			else
				error("Could not find "..callback.." function on passed object.")
			end
		else
			cbFunc = callback
		end
		
		tinsert(lib.callbacks[event], function(...) cbFunc(..., unpack(args)) end)
	else
		error("Attempted to register to an invalid event. Expected \"results\"/\"resolved\"/\"unlocked\".")
	end
end

-- check if the items are resolved in the current query's results
function lib:IsResolved(rType)
	if rType == "items" then
		for i=1, GetNumAuctionItems("list") do
			local name, tex, _, _, _, ilvl = GetAuctionItemInfo("list", i)
			if not (name and tex and ilvl) then
				return false
			end
		end
	else
		error("Invalid type. Expected \"items\".")
	end
	
	return true
end

-- Preforms item resolution on the query results
function lib:ResolveAuctions(rType)
	if rType == "items" then
		private.resolve(rType)
	else
		error("Invalid type. Expected \"items\".")
	end
end

-- Puts a lock on the query results so a new query can not be sent.
function lib.Lock(obj)
	if not private.ahOpen then return end -- can't lock if AH is closed
	
	lib.locks[obj] = true
end

-- Remove the passed obj's lock on the query results
function lib.Unlock(obj)
	if not private.ahOpen then return end -- can't unlock if AH is closed
	
	lib.locks[obj] = nil
	
	local noLocks = true
	for _ in pairs(lib.locks) do
		noLocks = false
	end
	
	if noLocks and obj ~= lib then
		private.sendCallbacks("unlocked")
	end
end

-- Update embeds
for target in pairs(lib.embeds) do
	lib:Embed(target)
end