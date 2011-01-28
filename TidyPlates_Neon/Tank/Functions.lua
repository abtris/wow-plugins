local LocalVars = TidyPlatesNeonTankVariables
local theme = TidyPlatesThemeList["Neon/Tank"]

---------------
-- External Function Links
---------------
local WidgetLib = TidyPlatesWidgets
local valueToString = TidyPlatesUtility.abbrevNumber
local EnableTankWatch = TidyPlatesWidgets.EnableTankWatch
local DisableTankWatch = TidyPlatesWidgets.DisableTankWatch
local IsTankedByAnotherTank = TidyPlatesWidgets.IsTankedByAnotherTank

local CreateThreatLineWidget = WidgetLib.CreateThreatLineWidget
local CreateAuraWidget = WidgetLib.CreateAuraWidget
local CreateClassWidget = WidgetLib.CreateClassWidget
local CreateRangeWidget = WidgetLib.CreateRangeWidget
local CreateComboPointWidget = WidgetLib.CreateComboPointWidget

---------------
-- Colors
---------------
local OrangeHexColor = "|cFFfc551b"
local PaleGreenHexColor = "|cFF3cee35"
local GreenHexColor = "|cFF00FF00"
local RedHexColor = "|cFFFF0000"
local GoldHexColor = "|cFFfcb41b"
local YellowHexColor = "|cFFFFFF00"
local PaleBlueHexColor = "|cFF5cb8ff"
local BlueHexColor = "|cFF0000ff"

---------------
-- Text Delegates
---------------
local function DiscreteNameText(unit)
	if unit.reaction == "FRIENDLY" then
		if unit.type == "NPC" then
		return GreenHexColor..unit.name
		else return BlueHexColor..unit.name end
	elseif unit.reaction == "HOSTILE" then
		return RedHexColor..unit.name
	else return YellowHexColor..unit.name end
end

local HealthTextFunctions = {
	--HEALTH_NONE
	function (health, healthmax) return "" end,
	--HEALTH_PCT
	function (health, healthmax) if health ~= healthmax then return "%"..ceil(100*(health/healthmax)) else return nil end end,
	--HEALTH_TOTAL
	function (health, healthmax) return valueToString(health) end,
	--HEALTH_DEF
	function (health, healthmax) if health ~= healthmax then return "-"..valueToString(healthmax - health) end end,
	--HEALTH_TOT_PCT
	function (health, healthmax) return valueToString(health).." / "..valueToString(healthmax).." ("..ceil(100*(health/healthmax)).."%)" end,
	--Health_Total_Pct_Def
	function (health, healthmax) return "+"..valueToString(health).." ("..ceil(100*(health/healthmax)).."%) -"..valueToString(healthmax - health) end,
}

local function HealthTextDelegate(unit)  
	return HealthTextFunctions[LocalVars.HealthText](unit.health, unit.healthmax, unit.targetOf)
end

---------------
-- Graphics Delegates
---------------
local function TankScale(unit)
	if InCombatLockdown() and unit.reaction == "HOSTILE" and  unit.threatSituation ~= "HIGH" and unit.type == "NPC"  then
		if IsTankedByAnotherTank(unit) and LocalVars.AggroOnOtherTank then return LocalVars.ScaleGeneral end
		if LocalVars.ScaleIgnoreNonElite and not unit.isElite then return LocalVars.ScaleGeneral end
		return LocalVars.ScaleLoose
	end
	return LocalVars.ScaleGeneral
end
	
local function TankAlpha(unit)
	if unit.isTarget then return 1
	else 	
		if unit.name == "Fanged Pit Viper" then return 0 end
		if LocalVars.OpacityHideNeutral and unit.reaction == "NEUTRAL" then return 0 end
		if LocalVars.OpacityHideNonElites and not unit.isElite then return 0 end
		if not UnitExists("target") then return 1 end
		return LocalVars.OpacityNonTarget, true
	end
end


-----------------
-- Combat Coloring
-----------------
local currentcolor
local function HealthColorDelegate(unit)
	if LocalVars.AggroHealth then
		if InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
				if unit.threatSituation ~= "HIGH"  and unit.health > 1 then 
					if IsTankedByAnotherTank(unit) and LocalVars.AggroOnOtherTank then currentcolor = LocalVars.AggroOtherColor 	-- Tank by another Raid Tank
					else currentcolor = LocalVars.AggroLooseColor	end -- Not Tanked
					--currentcolor = LocalVars.AggroLooseColor	-- Not Tanked
				else 	
					currentcolor = LocalVars.AggroTankedColor		-- Tanked By Me
				end
			return currentcolor.r, currentcolor.g, currentcolor.b
		end	
	end
	return unit.red, unit.green, unit.blue
end

local function ThreatColorDelegate(unit)

	if LocalVars.AggroBorder then
		if InCombatLockdown() and unit.reaction ~= "FRIENDLY" and unit.type == "NPC" then
			if unit.threatSituation ~= "HIGH" and unit.health > 1 then 
				currentcolor = LocalVars.AggroLooseColor		-- Default/Simple
				if IsTankedByAnotherTank(unit) and LocalVars.AggroOnOtherTank then return 0, 0, 0, 0 end
				return currentcolor.r, currentcolor.g, currentcolor.b, 1
			end
		end
	end
	return 0, 0, 0, 0
end

--local function SetCastbarColorDelegate(unit, spell)
--end

theme.SetCastbarColor = SetCastbarColorDelegate

---------------
-- Widgets
---------------
-- Widget Constants
local DEBUFFMODE_ALL, DEBUFFMODE_FILTER = 1, 2
local RangeModeRef = { 9, 15, 28, 40 }

local function DebuffFilter(debuff)
	if LocalVars.WidgetDebuffMode == DEBUFFMODE_FILTER then
		if LocalVars.WidgetDebuffList[debuff.name] then return true end
	else return true end
end

local function OnInitializeDelegate(plate)
	-- Tug-o-Threat
	if LocalVars.WidgetTug and (not plate.widgets.WidgetTug) then 
			plate.widgets.WidgetTug = CreateThreatLineWidget(plate)
			plate.widgets.WidgetTug:SetPoint("CENTER", plate, 0, 4)
			plate.widgets.WidgetTug._LowColor = LocalVars.TugWidgetLooseColor
			plate.widgets.WidgetTug._HighColor = LocalVars.TugWidgetAggroColor
			plate.widgets.WidgetTug._TankedColor = LocalVars.TugWidgetSafeColor
	end
		-- Threat Wheel
	if LocalVars.WidgetWheel then
		if not plate.widgets.WidgetWheel then 
			plate.widgets.WidgetWheel = WidgetLib.CreateThreatWheelWidget(plate)
			--plate.widgets.WidgetWheel:SetPoint("CENTER", plate, 30, 18)
			plate.widgets.WidgetWheel:SetPoint("CENTER", plate, 36, 12)
		end
	end
	-- Short Debuffs
	if LocalVars.WidgetDebuff then
		if not plate.widgets.AuraIcon then
			plate.widgets.AuraIcon =  CreateAuraWidget(plate)
			plate.widgets.AuraIcon:SetPoint("CENTER", plate, 15, 20)
			plate.widgets.AuraIcon:SetFrameLevel(plate:GetFrameLevel())
			-- For Filtering
			plate.widgets.AuraIcon.Filter = DebuffFilter
		end
	end
	-- Class 
	if LocalVars.WidgetClassIcon and (not plate.widgets.ClassWidget) then 
		plate.widgets.ClassWidget = CreateClassWidget(plate)
		plate.widgets.ClassWidget:SetPoint("TOP", plate, 0, 3)
		plate.widgets.ClassWidget:SetScale(1.2)
	end
	-- Range
	if LocalVars.WidgetRange and (not plate.widgets.Range) then
			plate.widgets.Range = CreateRangeWidget(plate)
			plate.widgets.Range:SetPoint("CENTER", 0, 0)
	end
	-- Combo Point 
	if LocalVars.WidgetCombo then
		if not plate.widgets.WidgetCombo then 
			plate.widgets.WidgetCombo = CreateComboPointWidget(plate)
			plate.widgets.WidgetCombo:SetPoint("CENTER", plate, 0, 10)
			plate.widgets.WidgetCombo:SetFrameLevel(plate:GetFrameLevel()+2)
		end
	end	
end

local function OnContextUpdateDelegate(plate, unit)
	-- Combo Points
	if LocalVars.WidgetCombo then plate.widgets.WidgetCombo:UpdateContext(unit) end
	-- Tug-o-Threat
	if LocalVars.WidgetTug then plate.widgets.WidgetTug:UpdateContext(unit) end
end

local function OnUpdateDelegate(plate, unit)	
	-- Range Check
	if LocalVars.WidgetRange then plate.widgets.Range:Update(unit,RangeModeRef[LocalVars.RangeMode]) end
	-- Class Icon
	if LocalVars.WidgetClassIcon then plate.widgets.ClassWidget:Update(unit) end
	-- Short Debuffs
	if LocalVars.WidgetDebuff then plate.widgets.AuraIcon:Update(unit) 	end
	-- Threat Wheel
	if LocalVars.WidgetWheel then plate.widgets.WidgetWheel:Update(unit) end
end

---------------
-- Theme Activation Events
---------------
local function OnActivateTheme(themetable, themename)
	-- This is where you activate and deactivate watcher frames, depending on your theme
	if themename == "Neon/Tank" and LocalVars.AggroOnOtherTank then
		EnableTankWatch()
	else
		DisableTankWatch()
	end
end


---------------
-- Function Assignment - Tank Mode
---------------
theme.SetCustomText = HealthTextDelegate
theme.SetScale = TankScale
theme.SetAlpha = TankAlpha
theme.OnUpdate = OnUpdateDelegate
theme.OnInitialize = OnInitializeDelegate
theme.SetHealthbarColor = HealthColorDelegate
theme.SetThreatColor = ThreatColorDelegate
theme.OnContextUpdate = OnContextUpdateDelegate		-- 5.14
theme.OnActivateTheme = OnActivateTheme			-- 6.0




