local WidgetLib = TidyPlatesWidgets
local theme = TidyPlatesThemeList["Neon/PVP"]
local valueToString = TidyPlatesUtility.abbrevNumber

--[[
TidyPlatesUtility:EnableHealerDetection()
local CurrentTargetHealers = TidyPlatesUtility.CurrentTargetHealers
local EnemyHealerList = TidyPlatesUtility.EnemyHealerList









--]]

--[[
To Do:

- Healer Detection
- Roster Monitor, to keep track of friendly classes
- Class Color Icon for friendlies
--]]

---------------
-- Target Widget
---------------
local targetwidgetimage = "Interface\\Addons\\TidyPlates_Neon\\Media\\Neon_Select"
local function CreateTargetWidget(frame)
	local icon = frame.bars.healthbar:CreateTexture(nil, 'BACKGROUND')
	icon:SetTexture(targetwidgetimage)
	icon:SetWidth(128)
	icon:SetHeight(32)
	icon:Hide()
	icon.SetTarget = function (self, value) 
		if value then icon:Show() else icon:Hide() end 
	end
	return icon
end

---------------
-- Text Delegates
---------------
local function SpellTextDelegate(unit)
	local spellname
	if unit.isCasting then 
		spellname = UnitCastingInfo("target") or UnitChannelInfo("target") or unit.spellName or ""
		return spellname
	else return "" end
end

local HealthTextFunctions = {
	--HEALTH_NONE
	function (health, healthmax) return "" end,
	--HEALTH_PCT
	function (health, healthmax) if health ~= healthmax then return ceil(100*(health/healthmax)).."%" else return nil end end,
	--HEALTH_TOTAL
	function (health, healthmax) return valueToString(health) end,
	--HEALTH_DEF
	function (health, healthmax) if health ~= healthmax then return "-"..valueToString(healthmax - health) end end,
	--HEALTH_TOT_PCT
	function (health, healthmax) return valueToString(health).." / "..valueToString(healthmax).." ("..ceil(100*(health/healthmax)).."%)" end,
	--Health_Total_Pct_Def
	function (health, healthmax) return "+"..valueToString(health).." ("..ceil(100*(health/healthmax)).."%) -"..valueToString(healthmax - health) end,
	--Level
	function (health, healthmax, targetOf) return targetOf or "" end,
	--GUID
	function (health, healthmax, targetOf, guid) return guid or "" end,
}

local function HealthTextDelegate(unit)  
	return HealthTextFunctions[1](unit.health, unit.healthmax, unit.targetOf, unit.guid)
end

---------------
-- Graphics Delegates
---------------
local function ScaleDelegate(unit)
	if InCombatLockdown() and unit.reaction ~= "FRIENDLY" then
		return 1.2
	end
	return 1
end
	
local function AlphaDelegate(unit)
	if (not UnitExists("target")) or unit.isTarget  then return 1 end
	return .5
end

local function HealthColorDelegate(unit)
	return unit.red, unit.green, unit.blue
end


local function ThreatColorDelegate(unit)
	-- Find-The-Healers Table Goes here...
	
	--return 1, .7, 0, 1	-- Goldish
	return 0, 0, 0, 0
end

---------------
-- Widgets
---------------

local DEBUFFMODE_ALL, DEBUFFMODE_FILTER = 1, 2

local function DebuffFilter(debuff)
	if LocalVars.WidgetDebuffMode == DEBUFFMODE_FILTER then
		if LocalVars.WidgetDebuffList[debuff.name] then return true end
	else return true end
end


local function OnInitializeDelegate(plate)
	-- Target Selection Box
	if LocalVars.WidgetSelect then
		if not plate.widgets.targetbox then 
			plate.widgets.targetbox = CreateTargetWidget(plate)
			plate.widgets.targetbox:SetPoint("CENTER", 0, 0)
		end
	end
	
	-- Combo Point Wheel
	if LocalVars.WidgetCombo then
		if not plate.widgets.WidgetCombo then 
			plate.widgets.WidgetCombo = WidgetLib.CreateComboPointWidget(plate)
			plate.widgets.WidgetCombo:SetPoint("CENTER", plate, 0, 10)
			plate.widgets.WidgetCombo:SetFrameLevel(plate:GetFrameLevel()+2)
		end
	end	
	
	-- Short Debuffs
	if LocalVars.WidgetDebuff then
		if not plate.widgets.AuraIcon then
			plate.widgets.AuraIcon =  WidgetLib.CreateAuraWidget(plate)
			--plate.widgets.AuraIcon:SetPoint("CENTER", plate, 0, 28)
			plate.widgets.AuraIcon:SetPoint("CENTER", plate, 15, 20)
			plate.widgets.AuraIcon:SetFrameLevel(plate:GetFrameLevel())
			
						
			-- For Filtering
			plate.widgets.AuraIcon.Filter = DebuffFilter
			
		end
	end
	-- Class 
	if LocalVars.WidgetClassIcon and (not plate.widgets.ClassWidget) then 
		plate.widgets.ClassWidget = WidgetLib.CreateClassWidget(plate)
		plate.widgets.ClassWidget:SetPoint("TOP", plate, 0, 3)
		plate.widgets.ClassWidget:SetScale(1.2)
	end


--[[	if not plate.widgets.TotemIcon then 
		plate.widgets.TotemIcon = WidgetLib.CreateTotemIconWidget(plate)
		plate.widgets.TotemIcon:SetPoint("CENTER", 0, 0)
	end
	--]]

end


local function OnUpdateDelegate(plate, unit)

	-- Target Selection Box
	if LocalVars.WidgetSelect then plate.widgets.targetbox:SetTarget(unit.isTarget) end
	-- Short Debuffs
	if LocalVars.WidgetDebuff then plate.widgets.AuraIcon:Update(unit) 	end
	-- Combo Points
	if LocalVars.WidgetCombo then plate.widgets.WidgetCombo:UpdateContext(unit) end
	-- Class Icon
	if LocalVars.WidgetClassIcon then plate.widgets.ClassWidget:Update(unit) end
	--plate.widgets.TotemIcon:Update(unit)
end

---------------
-- Function Assignment - PVP Mode
---------------
theme.SetSpecialText = SpellTextDelegate
theme.SetSpecialText2 = HealthTextDelegate
theme.SetScale = ScaleDelegate
theme.SetAlpha = AlphaDelegate
--theme.OnUpdate = OnUpdateDelegate
--theme.OnInitialize = OnInitializeDelegate
theme.SetHealthbarColor = HealthColorDelegate
theme.SetThreatColor = ThreatColorDelegate




