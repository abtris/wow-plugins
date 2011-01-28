----------------------
-- PolledHideIn() - Registers a callback, which polls the frame until it expires, then hides the frame and removes the callback
----------------------
local PolledHideIn
do
	local Framelist = {}			-- Key = Frame, Value = Expiration Time
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0
	
	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + 1
		-- Cycle through the watchlist, hiding frames which are timed-out
		for frame, expiration in pairs(Framelist) do
			-- If expired...
			--print("Exp", expiration)
			if expiration < curTime then frame:Hide(); Framelist[frame] = nil
			-- If active...
			else 
				-- Update the frame
				frame:Poll(expiration)
				framecount = framecount + 1 
			end
		end
		-- If no more frames to watch, unregister the OnUpdate script
		if framecount == 0 then Watcherframe:SetScript("OnUpdate", nil); WatcherframeActive = false end
	end
	
	function PolledHideIn(frame, expiration)
	
		if expiration == 0 then 
			
			frame:Hide()
			Framelist[frame] = nil
		else
			--print("Hiding in", expiration - GetTime())
			Framelist[frame] = expiration
			frame:Show()
			
			if not WatcherframeActive then 
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end
end

local CrowdControlMonitor = CreateFrame("Frame")

-- List of Widget Frames
local WidgetList = {}
-- GUIDs 			
local CrowdControlledUnits = {}
local CrowdControlExpirationTimes = {}
-- Raid Icon to GUID 		-- ex.  ByRaidIcon["SKULL"] = GUID
local ByRaidIcon = {}
-- Name to GUID
local ByName = {}

-- ID and Normal Duration (PvP MAX is 10 seconds)
local CrowdControlSpells = {}
CrowdControlSpells[339] = true		-- Entangling Roots


local function CrowdControlAura_Update(targetguid, targetname, sourceguid, sourcename, spellid, spellname)
	local targetUnitId
	if sourceguid == UnitGUID("player") then 
		targetUnitId = "target"
	else targetUnitId = TidyPlatesUtility.GroupMembers.UnitId[sourcename].."target" end

	-- Register Crowd Control to Target GUID
	CrowdControlledUnits[targetguid] = spellid
	
	-- Attempt to gather Expiration time from Caster, or use 10 seconds (A table of times might be another option)
	if targetUnitId then	
		local name, rank, icon, count, dispelType, duration, expires = UnitDebuff(targetUnitId, spellname)
		CrowdControlExpirationTimes[targetguid] = expires
	else
		CrowdControlExpirationTimes[targetguid] = GetTime() + 10
	end
end

local function CrowdControlAura_Remove(targetguid, ...) 
	CrowdControlledUnits[targetguid] = nil
	CrowdControlExpirationTimes[targetguid] = 0
end

local CombatLogEvents = {
	-- Refresh Expire Time
	["SPELL_AURA_APPLIED"] = CrowdControlAura_Update,
	["SPELL_AURA_REFRESH"] = CrowdControlAura_Update,
	-- Expires Aura
	["SPELL_AURA_BROKEN"] = CrowdControlAura_Remove,
	["SPELL_AURA_BROKEN_SPELL"] = CrowdControlAura_Remove,
	["SPELL_AURA_REMOVED"] = CrowdControlAura_Remove,
}

local RaidIconBit = {
	["STAR"] = 0x00100000,
	["CIRCLE"] = 0x00200000,
	["DIAMOND"] = 0x00400000,
	["TRIANGLE"] = 0x00800000,
	["MOON"] = 0x01000000,
	["SQUARE"] = 0x02000000,
	["CROSS"] = 0x04000000,
	["SKULL"] = 0x08000000,
}


local function CrowdControlEventHandler(frame, event, timestamp, combatevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, ...)
	local CombatLogFunction = CombatLogEvents[combatevent]

	--print(destName, tostring(destFlags), bit.band(destFlags, RaidIconBit.SKULL))
	
	if CombatLogFunction and (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0) then 
			--print("Aura Detected", spellId, destGUID)
			if CrowdControlSpells[spellId] then 
				
				-- Cache Unit Name
				if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then 
					ByName[destName] = destGUID
				end
				
				-- Cache Raid Icon Data
				for iconname, bitmask in pairs(RaidIconBit) do
					if bit.band(destFlags, bitmask) > 0  then
						--print("Raid Icon", iconname, destGUID)
						ByRaidIcon[iconname] = destGUID
						break
					end
				end	
			
				-- Update Data Table
				CombatLogFunction(destGUID, destName,  sourceGUID, sourceName, spellId, spellName) 
				
				-- Update Widget
				for widget in pairs(WidgetList) do
					--if (widget.Unit.guid == destGUID) or (widget.Unit.name == destName) or then
						widget:UpdateIcon()
					--end
				end
			end
	end
end


local function Enable()
	CrowdControlMonitor:SetScript("OnEvent", CrowdControlEventHandler)
	CrowdControlMonitor:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	--CrowdControlMonitor:RegisterEvent("PLAYER_TARGET")
end

local function Disable() 
	CrowdControlMonitor:SetScript("OnEvent", nil)
	CrowdControlMonitor:UnregisterAllEvents()
end

------------------------------------------------- Widget Frames

-- Polled by PolledHideIn
local function UpdateWidgetTime(frame, expiration)
	local timeleft = ceil(expiration-GetTime())
	frame.TimeLeft:SetText(timeleft)
	
	if timeleft < 3 then frame:SetScale(1.2) else frame:SetScale(1) end
	
	--[[
	local green, yellow, red = "|cFF84FF00", "|cFFFFB400", "|cFFFF0000"
	local textcolor
	if timeleft > 60 then frame.TimeLeft:SetText(green..ceil(timeleft/60).."m")
	else 
		if timeleft < 3 then textcolor = red 
		elseif timeleft < 5 then textcolor = yellow
		else textcolor = green end
		frame.TimeLeft:SetText(textcolor..ceil(timeleft)) 
	end
	--]]
	-- This is where the text gets changed, coloring, and any scaling get done
end

local function UpdateWidgetIcon(frame)
	local unit = frame.Unit
	local guid, spellid, expiration
	if unit.reaction == "HOSTILE" then
		if unit.guid then
			guid = unit.guid
		else
			if unit.type == "PLAYER" then
				guid = ByName[unit.name]
			elseif unit.isMarked then
				guid = ByRaidIcon[unit.raidIcon]
			end
		end

		if guid then
			spellid = CrowdControlledUnits[guid]
			expiration = CrowdControlExpirationTimes[guid]
			if spellid then
				frame:Show()
				local name, rank, icon = GetSpellInfo(spellid)
				frame.Icon:SetTexture(icon)
				if expiration then
					frame.TimeLeft:SetText(ceil(expiration-GetTime()))
					PolledHideIn(frame, expiration)
				end
				
				return true
			end
		end
	end
	frame:Hide()
end

-- Context Update (mouseover, target change)
local function UpdateWidgetContext(frame, unit)
	-- Context Update
	frame.Unit = unit
	WidgetList[frame] = true
	
	-- Update widget *now*, depending on context
	if unit.isTarget or unit.isMouseover or unit.isMarked then
		-- Update data directly, using UnitAura?
	
		-- Update Widget
		frame:UpdateIcon()
	end
end

local function ClearWidgetContext(frame)
	WidgetList[frame] = nil
end

local borderart = "Interface\\AddOns\\TidyPlates\\widgets\\Aura\\AuraFrame"
local font = "Interface\\Addons\\TidyPlates\\Media\\DefaultFont.ttf"
local function CreateCrowdControlWidget(parent)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetWidth(26); frame:SetHeight(14)
		-- Icon
		frame.Icon = frame:CreateTexture(nil, "OVERLAY")
		frame.Icon:SetAllPoints(frame)
		frame.Icon:SetTexCoord(.07, 1-.07, .23, 1-.23)  -- obj:SetTexCoord(left,right,top,bottom)
		-- Border
		frame.Border = frame:CreateTexture(nil, "ARTWORK")
		frame.Border:SetWidth(32); frame.Border:SetHeight(32)
		frame.Border:SetPoint("CENTER", 1, -2)
		frame.Border:SetTexture(borderart)
		-- [[
		-- Text
		frame.TimeLeft = frame:CreateFontString(nil, "OVERLAY")
		frame.TimeLeft:SetFont(font, 9, "OUTLINE")
		frame.TimeLeft:SetShadowOffset(1, -1)
		frame.TimeLeft:SetShadowColor(0,0,0,1)
		frame.TimeLeft:SetPoint("RIGHT", 0, 8)
		frame.TimeLeft:SetWidth(26)
		frame.TimeLeft:SetHeight(16)
		frame.TimeLeft:SetJustifyH("RIGHT")
		--]]
		-- Functions
		frame.UpdateContext = UpdateWidgetContext
		frame.UpdateIcon = UpdateWidgetIcon
		frame.Poll = UpdateWidgetTime
		frame._Hide = frame.Hide
		frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end
		frame:Hide()
		return frame
end


TidyPlatesWidgets.CreateCrowdControlWidget = CreateCrowdControlWidget
TidyPlatesWidgets.EnableCrowdControlWatcher = Enable
TidyPlatesWidgets.DisableCrowdControlWatcher = Disable

Enable()

--[[

http://www.wowpedia.org/Diminishing_returns
http://www.wowpedia.org/Crowd_control
--]]
