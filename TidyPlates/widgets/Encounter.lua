local EncounterWatcherFrame = CreateFrame("Frame")
local UnitEventHandlers = {}
local UnitLookupTable = {}
local TrackedAuras = {}

-- Widget Event Handler
local function EventHandler(frame, unit)
	UnitLookupTable[UnitName(unit)] = unit
	local debuffIndex, debuffName, debuffType
	
	-- Only send update if the aura is something you're looking for
	for debuffIndex = 1, 40 do
		debuffName, _, _, _, debuffType = UnitDebuff(unitid,auraindex)
		if debuffName and (TrackedAuras[debuffName] or TrackedAuras[debuffType]) then
			TidyPlates:Update()
			return
		end			
	end
end

EncounterWatcherFrame:SetScript("OnEvent", EventHandler)
EncounterWatcherFrame:RegisterEvent("UNIT_AURA")

-- In-Theme
local function GetIndicatorColor(name)
	local unitid = UnitLookupTable[name]
	local debuffName, debuffType, debuffColor, debuffReference, debuffIndex
	local debuffPriority = 0
	if unitid then
		for debuffIndex = 1, 40 do
			debuffName, _, _, _, debuffType = UnitDebuff(unitid,auraindex)
			if debuffName then
				debuffReference = TrackedAuras[debuffName] or TrackedAuras[debuffType]
				if debuffReference and debuffReference.priority > debuffPriority then
					debuffColor = debuffReference.color
					debuffPriority = debuffReference.priority
				end
				
			end			
		end
	end
	return debuffColor
end


