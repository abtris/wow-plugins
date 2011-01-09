------------------------------
-- Auras to Track (experimental)
------------------------------
local TrackedAuras = {}
TrackedAuras["Necrotic Plague"] = {color = {r = .1,g = 1, b = 0, a = 1},}

------------------------------
-- Debuff and Roster Handler
------------------------------
local UnitLookupTable = {}
local DangerWatcher
	
-- Event Handler
local function DangerEvents(frame, event, unit)
	local isUnitInParty = UnitPlayerOrPetInParty(unit)
	local isUnitInRaid = UnitInRaid(unit)
	local isUnitPet = (unit == "pet")
	
	if isUnitInParty or isUnitInRaid or isUnitPet then
		local name = UnitName(unit)
		UnitLookupTable[name] = unit
		TidyPlates:Update()		-- Theoretically, this should not 'double-call' since it's queued
	end
end


local function CheckGroupMemberAggro(name)	
	local unitid = UnitLookupTable[name]
	if unitid then
		local unitaggro = UnitThreatSituation(unitid)
		if unitaggro and unitaggro > 1 then return true end
	end
end

local function CheckGroupMemberDebuffs(name)
	local unitid = UnitLookupTable[name]
	local debuffName, debuffType, debuffColor, debuffReference, debuffIndex, _
	local debuffPriority = 0
	
	if unitid then
		for debuffIndex = 1, 40 do
			debuffName, _, _, _, debuffType = UnitDebuff(unitid,debuffIndex)					-- Operational
			--debuffName, debuffType, _, _, _, _, _, _ = UnitBuff(unitid,debuffIndex)		-- For testing 

			if debuffName then
				debuffReference = TrackedAuras[debuffName] or TrackedAuras[debuffType]
				if debuffReference then
					debuffColor = debuffReference.color
					return debuffColor
				end
				
			end			
		end
	end
	return nil
end

local function EnableAggroWatch()
	if not DangerWatcher then DangerWatcher = CreateFrame("Frame") end
	DangerWatcher:SetScript("OnEvent", DangerEvents)
	DangerWatcher:RegisterEvent("UNIT_AURA")
	DangerWatcher:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
end

local function DisableAggroWatch() 
	DangerWatcher:SetScript("OnEvent", nil)
	DangerWatcher:UnregisterAllEvents()
	DangerWatcher = nil
end

TidyPlatesWidgets.EnableAggroWatch = EnableAggroWatch
TidyPlatesWidgets.DisableAggroWatch = DisableAggroWatch










local function TestThreatColorDelegate(unit)
	--[[	Experimental
	if unit.reaction == "FRIENDLY" then
		--local color = CheckGroupMemberDebuffs(unit.name)		-- -- Do something!  Either return the color, or activate the debuff widget
		if CheckGroupMemberAggro(unit.name) then return 1, 0, 0, 1 end
		
		if color then
			return color.r, color.g, color.b, color.a
		end		
	end
	--]]	

	return 0, 0, 0, 0
end
