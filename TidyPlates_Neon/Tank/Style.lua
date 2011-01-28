-----------------------------------------------------
-- Tidy Plates: Neon/Tank - Theme Definition
-----------------------------------------------------
TidyPlatesThemeList["Neon/Tank"] = {}
local Theme = TidyPlatesThemeList["Neon/Tank"]


---------------------------------------------
-- Variables Definition
---------------------------------------------
TidyPlatesNeonTankSavedVariables = {}
TidyPlatesNeonTankVariables = {
	-- Opacity
	--OpacityNoTargetSelected = 1,
	OpacityNonTarget = .5,
	OpacityHideNeutral = false,
	OpacityHideNonElites = false,
	-- Health Text Mode
	HealthText = 1,
	-- Show Level Text
	LevelText = false,
	-- Scale
	ScaleGeneral = 1,				-- ScaleGeneral
	ScaleLoose = 1.2,				-- Scale
	ScaleIgnoreNonElite = false,
	--ScaleAggroOnMe = 1.2,			
	--ScaleAggroOnOtherTank = 1.2,			
	-- Aggro Indicators
	AggroHealth = true, 
	AggroBorder = false,
	AggroOnOtherTank = false, 		-- 
	-- Health Bar Coloring
	AggroTankedColor = {r = 15/255, g = 133/255, b = 255/255},	
	AggroOtherColor = {r = 255/255, g = 128/255, b = 0,},	
	AggroLooseColor = {r = 255/255, g = 128/255, b = 0,},	
	-- Tug-O-Threat Widget Colors
	WidgetTug = true,
	TugWidgetLooseColor = { r = .14, g = .75, b = 1},
	TugWidgetAggroColor = {r = 1, g = .67, b = .14},
	TugWidgetSafeColor = { r = 0, g = .9, b = .1},
	-- Debuff Widget
	WidgetDebuff = false,
	WidgetDebuffList = { ["Rip"] = true, ["Rake"] = true, ["Lacerate"] = true, },
	WidgetDebuffMode = 1,
	-- Range Widget
	WidgetRange	= false,
	RangeMode = 1,
	-- Other Widgets
	WidgetWheel = false,
	WidgetSelect = true,
	WidgetCombo = false,
	WidgetClassIcon = false,
}
local LocalVars = TidyPlatesNeonTankVariables

---------------------------------------------
-- Style Definition
---------------------------------------------
local ArtworkPath = "Interface\\Addons\\TidyPlates_Neon\\Media\\"
local EmptyTexture = ArtworkPath.."Neon_Empty"
local CastBarVerticalAdjustment = -23
local NameTextVerticalAdjustment = -8

---------------------------------------------
-- Default Style
---------------------------------------------
--local DefaultStyle = Theme
local DefaultStyle = {}


DefaultStyle.frame = {
	x = 0,
	y = 12,
}

DefaultStyle.highlight = {
	texture =					ArtworkPath.."Neon_Highlight",
}

DefaultStyle.healthborder = {
	texture		 =				ArtworkPath.."Neon_HealthOverlay",
	width = 128,
	height = 32,
	y = 0,
	show = true,
}

DefaultStyle.healthbar = {
	texture =					 ArtworkPath.."Neon_Bar",
	width = 100,
	height = 32,
	x = 0,
	y = 0,
}

DefaultStyle.castborder = {
	texture =					ArtworkPath.."Cast_Normal",
	--texture =					ArtworkPath.."Neon_HealthOverlay",
	width = 128,
	height = 32,
	x = 0,
	y = CastBarVerticalAdjustment,
	show = true,
}

DefaultStyle.castnostop = {
	texture =					ArtworkPath.."Cast_Shield",
	width = 128,
	height = 32,
	x = 0,
	y = CastBarVerticalAdjustment,
	show = true,
}


DefaultStyle.castbar = {
	texture =					 ArtworkPath.."Neon_Bar",
	width = 100,
	height = 32,
	x = 0,
	y = CastBarVerticalAdjustment,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

DefaultStyle.threatborder = {
	texture =				ArtworkPath.."Neon_AggroOverlayWhite",
	--elitetexture =				ArtworkPath.."Neon_Empty",
	elitetexture =			ArtworkPath.."Neon_AggroOverlayWhite",
	width = 256,
	height = 64,
	y = 1,
	show = true,
}


DefaultStyle.target = {
	texture = "Interface\\Addons\\TidyPlates_Neon\\Media\\Neon_Select",
	width = 128,
	height = 32,
	x = 0,
	y = 0,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.spellicon = {
	width = 15,
	height = 15,
	x = 24,
	y = CastBarVerticalAdjustment,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.raidicon = {
	width = 32,
	height = 32,
	x = -48,
	y = 3,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.eliteicon = {
	texture = ArtworkPath.."Neon_EliteIcon",
	width = 14,
	height = 14,
	x = -44,
	y = 5,
	anchor = "CENTER",
	show = true,
}

DefaultStyle.name = {
	typeface = ArtworkPath.."Qlassik_TB.ttf",
	size = 13,
	width = 200,
	height = 11,
	x = 0,
	y = NameTextVerticalAdjustment,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
}

DefaultStyle.level = {
	typeface = ArtworkPath.."Qlassik_TB.ttf",
	size = 9,
	width = 22,
	height = 11,
	x = 5,
	y = 5,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "CENTER",
	flags = "OUTLINE",
	shadow = false,
	show = false,
}

DefaultStyle.skullicon = {
	--texture = "",
	width = 14,
	height = 14,
	x = 5,
	y = 5,
	anchor = "LEFT",
	show = false,
}

DefaultStyle.spelltext = {
	typeface = ArtworkPath.."Qlassik_TB.ttf",
	size = 11,
	width = 150,
	height = 11,
	x = 26,
	y = -19+CastBarVerticalAdjustment,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
	show = true,
}

DefaultStyle.customtext = {
	typeface = ArtworkPath.."Qlassik_TB.ttf",
	size = 9,
	width = 150,
	height = 11,
	x = 0,
	y = 1,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = false,
	flags = "OUTLINE",
	show = true,
}


local CopyTable = TidyPlatesUtility.copyTable

-- No Bar
local NameOnlyStyle = CopyTable(DefaultStyle)
NameOnlyStyle.healthborder.texture = EmptyTexture
NameOnlyStyle.healthbar.texture = EmptyTexture

-- 58
local CompactStyle = CopyTable(DefaultStyle)
CompactStyle.healthborder.texture = ArtworkPath.."Neon_HealthOverlay_Stubby"
CompactStyle.healthbar.width = 58
CompactStyle.highlight.texture = ArtworkPath.."Neon_Stubby_Highlight"
CompactStyle.target.texture = ArtworkPath.."Neon_Stubby_Target"

-- 38
local MiniStyle = CopyTable(DefaultStyle)
MiniStyle.healthborder.texture = ArtworkPath.."Neon_HealthOverlay_Very_Stubby"
MiniStyle.healthbar.width = 38
--MiniStyle.name.show = false
MiniStyle.highlight.texture = ArtworkPath.."Neon_Very_Stubby_Highlight"
MiniStyle.target.texture = ArtworkPath.."Neon_Very_Stubby_Target"

-- Styles
Theme["Default"] = DefaultStyle
Theme["Compact"] = CompactStyle
Theme["Mini"] = MiniStyle
Theme["NameOnly"] = NameOnlyStyle

local function UpdateStyleElements(self, var)
	Theme["Default"].level.show = (LocalVars.LevelText == true)
	Theme["Default"].target.show = (LocalVars.WidgetSelect == true)
	if LocalVars.AggroOnOtherTank then TidyPlatesWidgets.EnableTankWatch()
	else TidyPlatesWidgets.DisableTankWatch() end
	
end

Theme.UpdateStyleElements = UpdateStyleElements

local IsTotem = TidyPlatesUtility.IsTotem

local function StyleDelegate(unit)
	if IsTotem(unit.name) then return "Mini"
	--elseif not unit.isInCombat then return "Compact"
	--elseif (not unit.isElite) and unit.reaction ~= "HOSTILE" then return "Compact"
	else return "Default" end
end

Theme.SetStyle = StyleDelegate



--/run TestTidyPlatesCastBar("Boognish", 133, true)

--[[
---------------
-- Neon/Veev
---------------
local CopyTable = TidyPlatesUtility.copyTable
TidyPlatesThemeList["Neon/Veev"] = CopyTable(Theme)
local Veev = TidyPlatesThemeList["Neon/Veev"]
Veev.name.y = 11
--]]



















