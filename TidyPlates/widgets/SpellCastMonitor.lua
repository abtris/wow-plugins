-------------------------------------------------------------------------
-- Spell Cast Event Watcher.
-------------------------------------------------------------------------
local CombatCastEventWatcher
local CombatEventHandlers = {}
local StartCastAnimationOnNameplate = TidyPlates.StartCastAnimationOnNameplate		-- If you don't define a local reference, the Tidy Plates table will get passed to the function.

local function SearchNameplateByGUID(SearchFor)
	local VisiblePlate, UnitGUID
	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
		UnitGUID = VisiblePlate.extended.unit.guid
		if UnitGUID and UnitGUID == SearchFor then									-- BY GUID
			return VisiblePlate
		end
	end
end

local function SearchNameplateByName(SearchFor)
	local VisiblePlate
	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.name == SearchFor then										-- BY NAME
			return VisiblePlate
		end
	end
end
--------------------------------------
-- Handle "SPELL_CAST_START" events
--  Send cast event to an available nameplate
--------------------------------------
function CombatEventHandlers.SPELL_CAST_START(...)
	local timestamp, combatevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellid, spellname = ...
	local FoundPlate
	
	if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then 
		if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then 
			--	destination plate, by name
			FoundPlate = SearchNameplateByName(sourceName)
		elseif bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then 
			--	destination plate, by GUID
			FoundPlate = SearchNameplateByGUID(sourceGUID)
		else return	end
	else return end

	local currentTime = GetTime()
	local spell, displayName, icon, castTime
	
	-- If the unit's nameplate is visible, engage the cast bar, warp 6!
	if FoundPlate then 
		FoundPlateUnit = FoundPlate.extended.unit
		if FoundPlateUnit.isTarget then return end
		-- Gather Spell Info
		spell, displayName, icon, _, _, _, castTime, _, _ = GetSpellInfo(spellid)
		castTime = (castTime / 1000)	-- Convert to seconds
		StartCastAnimationOnNameplate(FoundPlate, spell, spell, icon, currentTime, currentTime+castTime, false, false)
		--print("Starting Cast Animation on", SearchFor, spell, spell, icon, currentTime, currentTime+castTime)
	end
end

--------------------------------------
-- Handle "SPELL_CAST_STOP" events
--  Need to handle STOP events, and interuptions, if possible
-- http://www.wowwiki.com/API_COMBAT_LOG_EVENT
--[[
_CAST_START
_CAST_FAILED	"Interrupted:
_INTERRUPT
--]]
--------------------------------------
	
--------------------------------------
-- Watch Combat Log Events
--------------------------------------
local function OnCombatEvent(self, event, ...)
	local timestamp, combatevent = ...
	if CombatEventHandlers[combatevent] then CombatEventHandlers[combatevent]( ...) end		
end

-----------------------------------
-- External control functions
-----------------------------------

--/run TidyPlates:StartSpellCastWatcher()
local function StartSpellCastWatcher()
	if not CombatCastEventWatcher then CombatCastEventWatcher = CreateFrame("Frame") end
	CombatCastEventWatcher:SetScript("OnEvent", OnCombatEvent) 
	CombatCastEventWatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	--print("Enabling Tidy Plates Spell Cast Monitor")
end

local function StopSpellCastWatcher()
	if CombatCastEventWatcher then 
		CombatCastEventWatcher:SetScript("OnEvent", nil)
		CombatCastEventWatcher:UnregisterAllEvents()
		CombatCastEventWatcher = nil
	end
end

TidyPlates.StartSpellCastWatcher = StartSpellCastWatcher
TidyPlates.StopSpellCastWatcher = StopSpellCastWatcher

-- To test spell cast: /run TestTidyPlatesCastBar("Boognish", 133)		-- The spell ID number of Fireball is 133
function TestTidyPlatesCastBar(SearchFor, SpellID)
	local VisiblePlate, FoundPlate
	local currentTime = GetTime()
	local spell, displayName, icon, _, _, _, castTime, _, _ = GetSpellInfo(SpellID)
	
	print("Testing Spell Cast on", SearchFor)
	-- Search for the nameplate, by name (you could also search by GUID)
	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
	   if VisiblePlate.extended.unit.name == SearchFor then
		  FoundPlate = VisiblePlate
	   end
	end

	-- If found, display the cast bar
	if FoundPlate then StartCastAnimationOnNameplate(FoundPlate, spell, spell, icon, currentTime, currentTime+(castTime/1000), false, false) end
end