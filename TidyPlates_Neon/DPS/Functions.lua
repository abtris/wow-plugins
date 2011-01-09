local WidgetLib = TidyPlatesWidgets
local LocalVars = TidyPlatesNeonDPSVariables
local theme = TidyPlatesThemeList["Neon/DPS"]
local valueToString = TidyPlatesUtility.abbrevNumber

---------------
-- Text Delegates
---------------

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
	return HealthTextFunctions[LocalVars.HealthText](unit.health, unit.healthmax, unit.targetOf, unit.guid)
end

---------------
-- Graphics Delegates
---------------
local function DPSScale(unit)
	--if unit.name == "Relikan" then return 1.4 end

	if InCombatLockdown() and unit.reaction == "HOSTILE" and  unit.threatSituation ~= "LOW" and unit.type == "NPC" then
		if LocalVars.ScaleIgnoreNonElite then
			if unit.isElite then return LocalVars.ScaleDanger end
		else return LocalVars.ScaleDanger end 
	end
	return LocalVars.ScaleGeneral
end
	
local function DPSAlpha(unit)

	if unit.isTarget then return 1
	else 	
		if unit.name == "Fanged Pit Viper" then return 0 end
		if LocalVars.OpacityHideNeutral and unit.reaction == "NEUTRAL" then return 0 end
		if LocalVars.OpacityHideNonElites and not unit.isElite then return 0 end
		if not UnitExists("target") then return 1 end
		return LocalVars.OpacityNonTarget, true
	end
	

end

local currentcolor
local function HealthColorDelegate(unit)
	if LocalVars.AggroHealth then
		if InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
				if unit.threatSituation ~= "LOW"  then 
					currentcolor = LocalVars.AggroDangerColor
					return currentcolor.r, currentcolor.g, currentcolor.b
				else 
					currentcolor = LocalVars.AggroSafeColor
					return currentcolor.r, currentcolor.g, currentcolor.b 
				end

		end
	end
	return unit.red, unit.green, unit.blue
end

local function ThreatColorDelegate(unit)
	if LocalVars.AggroBorder then
		if InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
			if unit.threatSituation ~= "LOW" then 
				currentcolor = LocalVars.AggroDangerColor
				return currentcolor.r, currentcolor.g, currentcolor.b, 1
			end
		end
	end
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

local function OnContextUpdateDelegate(plate, unit)
	-- Combo Points
	if LocalVars.WidgetCombo then plate.widgets.WidgetCombo:UpdateContext(unit) end
	-- Tug-o-Threat
	if LocalVars.WidgetTug then plate.widgets.WidgetTug:UpdateContext(unit) end
end

local function OnInitializeDelegate(plate)
	-- Tug-o-Threat
	if LocalVars.WidgetTug then
		if not plate.widgets.WidgetTug then 
			plate.widgets.WidgetTug = WidgetLib.CreateThreatLineWidget(plate)
			plate.widgets.WidgetTug:SetPoint("CENTER", plate, 0, 4)
			plate.widgets.WidgetTug._LowColor = LocalVars.TugWidgetLooseColor
			plate.widgets.WidgetTug._HighColor = LocalVars.TugWidgetAggroColor
		end
	end
	
	-- Threat Wheel
	if LocalVars.WidgetWheel then
		if not plate.widgets.WidgetWheel then 
			plate.widgets.WidgetWheel = WidgetLib.CreateThreatWheelWidget(plate)
			--plate.widgets.WidgetWheel:SetPoint("CENTER", plate, 30, 18)
			plate.widgets.WidgetWheel:SetPoint("CENTER", plate, 36, 12)
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
	
	-- Range
	if LocalVars.WidgetRange and (not plate.widgets.RangeWidget) then
			plate.widgets.RangeWidget = WidgetLib.CreateRangeWidget(plate)
			plate.widgets.RangeWidget:SetPoint("CENTER", 0, 0)
	end

end


local function OnUpdateDelegate(plate, unit)
	-- Short Debuffs
	if LocalVars.WidgetDebuff then plate.widgets.AuraIcon:Update(unit) 	end
	-- Range
	if LocalVars.WidgetRange then plate.widgets.RangeWidget:Update(unit) end
	-- Threat Wheel
	if LocalVars.WidgetWheel then plate.widgets.WidgetWheel:Update(unit) end
	-- Class Icon
	if LocalVars.WidgetClassIcon then plate.widgets.ClassWidget:Update(unit) end
end

---------------
-- Function Assignment - DPS Mode
---------------
theme.SetCustomText = HealthTextDelegate
theme.SetScale = DPSScale
theme.SetAlpha = DPSAlpha
theme.OnUpdate = OnUpdateDelegate
theme.OnInitialize = OnInitializeDelegate
theme.SetHealthbarColor = HealthColorDelegate
theme.SetThreatColor = ThreatColorDelegate
theme.OnContextUpdate = OnContextUpdateDelegate		-- 5.14
--theme.OnActivateTheme = OnActivateTheme			-- 6.0



