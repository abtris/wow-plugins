-----------------------------------------------------
-- Tidy Plates: Neon/DPS - Theme Definition
-----------------------------------------------------
TidyPlatesThemeList["Neon/DPS"] = {}
local Theme = TidyPlatesThemeList["Neon/DPS"]

---------------
-- Config
---------------
TidyPlatesNeonDPSVariables = {
	OpacityNonTarget = .5,
	OpacityHideNeutral = false,
	OpacityHideNonElites = false,
	ScaleGeneral = 1,
	ScaleDanger = 1.2,
	ScaleIgnoreNonElite = false,
	WidgetTug = true,
	WidgetSelect = true,
	WidgetCombo = false,
	WidgetDebuff = false,
	WidgetDebuffList = { ["Rip"] = true, ["Rake"] = true, ["Lacerate"] = true, },
	WidgetDebuffMode = 1,
	WidgetRange	= false,
	WidgetWheel = false,
	WidgetClassIcon = false,
	RangeMode = 1,
	HealthText = 1,
	LevelText = false,
	AggroHealth = true, 
	AggroBorder = false,
	TugWidgetLooseColor = { r = .14, g = .75, b = 1},
	TugWidgetAggroColor = {r = 1, g = .67, b = .14},
	AggroSafeColor = {r = 15/255, g = 133/255, b = 255/255},
	AggroDangerColor = {r = 255/255, g = 128/255, b = 0},
}

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



local function UpdateStyleElements(self, var)
	Theme.level.show = (TidyPlatesNeonDPSVariables.LevelText == true)
	Theme.target.show = (TidyPlatesNeonDPSVariables.WidgetSelect == true)
end

Theme.UpdateStyleElements = UpdateStyleElements



