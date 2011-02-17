-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data", "AceEvent-3.0")

local CURRENT_PLAYER, CURRENT_GUILD = UnitName("player"), GetGuildInfo("player")
local BUCKET_TIME = 0.2 -- wait at least this amount of time between throttled events firing
local throttleFrames = {}
local isScanning = false

function Data:LoadData()
	Data:RegisterEvent("BAG_UPDATE", "EventHandler")
	Data:RegisterEvent("BANKFRAME_OPENED", "EventHandler")
	Data:RegisterEvent("PLAYERBANKSLOTS_CHANGED", "EventHandler")
	Data:RegisterEvent("GUILDBANKFRAME_OPENED", "EventHandler")
	Data:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", "EventHandler")
	
	TSMAPI:RegisterData("playerlist", Data.GetPlayers)
	TSMAPI:RegisterData("guildlist", Data.GetGuilds)
	TSMAPI:RegisterData("playerbags", Data.GetPlayerBags)
	TSMAPI:RegisterData("playerbank", Data.GetPlayerBank)
	TSMAPI:RegisterData("guildbank", Data.GetGuildBank)
	
	Data:StoreCurrentGuildInfo()
end

local guildThrottle = CreateFrame("frame")
guildThrottle:Hide()
guildThrottle.attemptsLeft = 20
guildThrottle:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			self.attemptsLeft = self.attemptsLeft - 1
			Data:StoreCurrentGuildInfo(self.attemptsLeft == 0)
		end
	end)

function Data:StoreCurrentGuildInfo(noDelay)
	CURRENT_GUILD = GetGuildInfo("player")
	if CURRENT_GUILD then
		TSM.guilds[CURRENT_GUILD] = TSM.guilds[CURRENT_GUILD] or {items={}, characters={CURRENT_PLAYER=true}}
		TSM.guilds[CURRENT_GUILD].characters = TSM.guilds[CURRENT_GUILD].characters or {}
		TSM.guilds[CURRENT_GUILD].items = TSM.guilds[CURRENT_GUILD].items or {}
		if not TSM.guilds[CURRENT_GUILD].characters[CURRENT_PLAYER] then
			TSM.guilds[CURRENT_GUILD].characters[CURRENT_PLAYER] = true
		end
		for guildName, data in pairs(TSM.guilds) do
			data.characters = data.characters or {}
			if guildName ~= CURRENT_GUILD and data.characters[CURRENT_PLAYER] then
				data.characters[CURRENT_PLAYER] = nil
			end
		end
		TSM:Debug("loaded guild", CURRENT_GUILD)
		guildThrottle:Hide()
	elseif not noDelay then
		guildThrottle.timeLeft = 0.5
		guildThrottle:Show()
	else
		guildThrottle:Hide()
	end
	TSM.characters[CURRENT_PLAYER].guild = CURRENT_GUILD
end

function Data:ThrottleEvent(event)
	if not throttleFrames[event] then
		local frame = CreateFrame("Frame")
		frame.baseTime = BUCKET_TIME
		frame.event = event
		frame:Hide()
		frame:SetScript("OnShow", function(self) Data:UnregisterEvent(self.event) self.timeLeft = self.baseTime end)
		frame:SetScript("OnUpdate", function(self, elapsed)
				self.timeLeft = self.timeLeft - elapsed
				if self.timeLeft <= 0 then
					Data:EventHandler(self.event, "FIRE")
					self:Hide()
					Data:RegisterEvent(self.event, "EventHandler")
				end
			end)
		throttleFrames[event] = frame
	end
	
	-- resets the delay time on the frame
	throttleFrames[event]:Hide()
	throttleFrames[event]:Show()
end

function Data:EventHandler(event, fire)
	if isScanning then return end
	if not (fire and fire == "FIRE") then
		Data:ThrottleEvent(event)
	else
		if event == "BAG_UPDATE" then
			Data:GetBagData()
		elseif event == "PLAYERBANKSLOTS_CHANGED" or event == "BANKFRAME_OPENED" then
			Data:GetBankData()
		elseif event == "GUILDBANKBAGSLOTS_CHANGED" or event == "GUILDBANKFRAME_OPENED" then
			Data:GetGuildBankData()
		end
	end
end

-- scan the player's bags
function Data:GetBagData()
	wipe(TSM.characters[CURRENT_PLAYER].bags)
	for bag=0, NUM_BAG_SLOTS do
		for slot=1, GetContainerNumSlots(bag) do
			local itemID = TSMAPI:GetItemID(GetContainerItemLink(bag, slot))
			if itemID and not TSM:IsSoulbound(bag, slot, itemID) then
				local quantity = select(2, GetContainerItemInfo(bag, slot))
				TSM.characters[CURRENT_PLAYER].bags[itemID] = (TSM.characters[CURRENT_PLAYER].bags[itemID] or 0) + quantity
			end
		end
	end
end

-- scan the player's bank
function Data:GetBankData()
	local locationList = {}
	wipe(TSM.characters[CURRENT_PLAYER].bank)
	
	local function ScanBankBag(bag)
		for slot=1, GetContainerNumSlots(bag) do
			local itemID = TSMAPI:GetItemID(GetContainerItemLink(bag, slot))
			if itemID and not TSM:IsSoulbound(bag, slot, itemID) then
				locationList[itemID] = locationList[itemID] or {}
				local quantity = select(2, GetContainerItemInfo(bag, slot))
				TSM.characters[CURRENT_PLAYER].bank[itemID] = (TSM.characters[CURRENT_PLAYER].bank[itemID] or 0) + quantity
				tinsert(locationList[itemID], {bag=bag, slot=slot, quantity=quantity})
			end
		end
	end
	
	for bag=NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
		ScanBankBag(bag)
	end
	ScanBankBag(-1)
	
	Data:SendMessage("TSMBANK", locationList)
end

-- scan the guild bank
function Data:GetGuildBankData()
	if not CURRENT_GUILD then
		Data:StoreCurrentGuildInfo(true)
		if not CURRENT_GUILD then return end
	end
	wipe(TSM.guilds[CURRENT_GUILD].items)
	isScanning = true
	local initialTab = GetCurrentGuildBankTab()
	for tab=1, GetNumGuildBankTabs() do
		if select(4, GetGuildBankTabPermissions(tab)) > 0 or IsGuildLeader(UnitName("player")) then
			QueryGuildBankTab(tab)
		end
	end
	QueryGuildBankTab(initialTab)
	
	local delay = CreateFrame("Frame")
	delay:Hide()
	delay.time = 0.3
	delay:SetScript("OnUpdate", function(self, elapsed)
			self.time = self.time - elapsed
			if self.time > 0 then return end
			local locationList = {}
			for tab=1, GetNumGuildBankTabs() do
				if select(4, GetGuildBankTabPermissions(tab)) > 0 or IsGuildLeader(UnitName("player")) then
					for slot=1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
						local itemID = TSMAPI:GetItemID(GetGuildBankItemLink(tab, slot))
						if itemID then
							locationList[itemID] = locationList[itemID] or {}
							local quantity = select(2, GetGuildBankItemInfo(tab, slot))
							TSM.guilds[CURRENT_GUILD].items[itemID] = (TSM.guilds[CURRENT_GUILD].items[itemID] or 0) + quantity
							tinsert(locationList[itemID], {tab=tab, slot=slot, quantity=quantity})
						end
					end
				end
			end
			self:Hide()
			Data:SendMessage("TSMGUILDBANK", locationList)
			isScanning = false
		end)
	delay:Show()
end


-- functions for getting data through TSMAPI:GetData()

function Data:GetPlayers()
	local temp = {}
	for name in pairs(TSM.characters) do
		tinsert(temp, name)
	end
	return temp
end

function Data:GetGuilds()
	local temp = {}
	for name in pairs(TSM.guilds) do
		tinsert(temp, name)
	end
	return temp
end

function Data:GetPlayerBags(player)
	player = player or CURRENT_PLAYER
	if not player or not TSM.characters[player] then return end
	
	return CopyTable(TSM.characters[player].bags)
end

function Data:GetPlayerBank(player)
	player = player or CURRENT_PLAYER
	if not player or not TSM.characters[player] then return end
	
	return CopyTable(TSM.characters[player].bank)
end

function Data:GetGuildBank(guild)
	guild = guild or CURRENT_GUILD
	if not guild or not TSM.guilds[guild] then return end
	
	return CopyTable(TSM.guilds[guild].items)
end