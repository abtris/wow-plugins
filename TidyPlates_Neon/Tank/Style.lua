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
local CastBarVerticalAdjustment = -21
local NameTextVerticalAdjustment = -8

---------------------------------------------
-- Default Style
---------------------------------------------
local DefaultStyle = Theme
--local DefaultStyle = {}
--local DefaultStyle = {}
--[[
DefaultStyle.hitbox = {
	width = 105,
	height = 20,
}
--]]

DefaultStyle.frame = {
	x = 0,
	y = 12,
}

DefaultStyle.highlight = {
	texture =					ArtworkPath.."Neon_Highlight",
}

DefaultStyle.healthborder = {
	texture		 =				ArtworkPath.."Neon_HealthOverlay",
	--glowtexture =					ArtworkPath.."Neon_Highlight",
	--elitetexture =					ArtworkPath.."Neon_HealthOverlayEliteStar",
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
	texture =					ArtworkPath.."Neon_CastOverlayBlue",
	width = 128,
	height = 32,
	x = 0,
	y = CastBarVerticalAdjustment,
	show = true,
}

DefaultStyle.castnostop = {
	texture =					ArtworkPath.."Neon_CastOverlayRed",
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
	width = 17,
	height = 17,
	x = 26,
	y = -3+CastBarVerticalAdjustment,
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



-- /run TidyPlates:ForceUpdate(); TidyPlatesThemeList["Neon/Test"].name.y = 8
-- /run TestTidyPlatesCastBar("Boognish", 133)

--[[
local CopyTable = TidyPlatesUtility.copyTable

---------------------------------------------
-- No Health-Bar Style
-- Replaces the Spell Text with Name Text (For Color)
---------------------------------------------
local NoHealthBarStyle = CopyTable(DefaultStyle)

NoHealthBarStyle.healthborder.texture = EmptyTexture
NoHealthBarStyle.healthborder.glowtexture = EmptyTexture
NoHealthBarStyle.healthborder.elitetexture = EmptyTexture

NoHealthBarStyle.healthbar.texture = EmptyTexture

NoHealthBarStyle.customtext.typeface = ArtworkPath.."Qlassik_TB.ttf"
NoHealthBarStyle.customtext.size = 12
NoHealthBarStyle.customtext.width = 200
NoHealthBarStyle.customtext.height = 11
NoHealthBarStyle.customtext.x = 0
NoHealthBarStyle.customtext.y = NameTextVerticalAdjustment + 8
NoHealthBarStyle.customtext.align = "CENTER"
NoHealthBarStyle.customtext.anchor = "CENTER"
NoHealthBarStyle.customtext.vertical = "CENTER"
NoHealthBarStyle.customtext.shadow = true
	
local function StyleDelegate(unit)
	-- DefaultStyle or NoHealthBarStyle
	if unit.reaction == "FRIENDLY" then return "NoHealthBarStyle"
	else return "DefaultStyle" end
end

Theme.SetStyle = StyleDelegate

Theme["DefaultStyle"] = DefaultStyle
Theme["NoHealthBarStyle"] = NoHealthBarStyle

--]]

local function UpdateStyleElements(self, var)
	Theme.level.show = (LocalVars.LevelText == true)
	Theme.target.show = (LocalVars.WidgetSelect == true)
	if LocalVars.AggroOnOtherTank then TidyPlatesWidgets.EnableTankWatch()
	else TidyPlatesWidgets.DisableTankWatch() end
	
end

Theme.UpdateStyleElements = UpdateStyleElements








---------------
-- Neon/Veev
---------------
local CopyTable = TidyPlatesUtility.copyTable
TidyPlatesThemeList["Neon/Veev"] = CopyTable(Theme)
local Veev = TidyPlatesThemeList["Neon/Veev"]
Veev.name.y = 11




















