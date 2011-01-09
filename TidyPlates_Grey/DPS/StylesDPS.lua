-----------------------------------------------------
-- Tidy Plates: Grey\DPS - Theme Definition
-----------------------------------------------------
TidyPlatesThemeList["Grey/DPS"] = {}

---------------
-- Config
---------------
TidyPlatesGreyDPSVariables = {
	OpacityNonTarget = .5,
	OpacityHideNeutral = false,
	OpacityHideNonElites = false,
	ScaleGeneral = 1,
	ScaleDanger = 1.5,
	ScaleIgnoreNonElite = false,
	WidgetTug = true,
	WidgetCombo = false,
	WidgetSelect = true,
	WidgetDebuff = false,
	LevelText = false,
	HealthText = 1,
	AggroHealth = false,
	AggroBorder = true,								
	AggroSafeColor = {r = .6, g = 1, b = 0, a = 1,},
	AggroDangerColor = {r = 1, g = 0, b = 0, a= 1,},
}

---------------
-- Style Assignment
---------------
local theme = TidyPlatesThemeList["Grey/DPS"]

local defaultArtPath = "Interface\\Addons\\TidyPlates_Grey\\Media"
local font =					defaultArtPath.."\\LiberationSans-Regular.ttf"
local nameplate_verticalOffset = -5
local castBar_verticalOffset = -6 -- Adjust Cast Bar distance

theme.hitbox = { width = 140, height = 35, }

theme.healthborder = {
	texture		 =				defaultArtPath.."\\RegularBorder",
	glowtexture =					defaultArtPath.."\\Highlight",
	--texture =					defaultArtPath.."\\EliteBorder",
	width = 128,
	height = 64,
	x = 0,
	y = nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.eliteicon = {
	texture = defaultArtPath.."\\EliteIcon",
	width = 14,
	height = 14,
	x = -51,
	y = 17,
	anchor = "CENTER",
	show = true,
}

theme.target = {
	texture = defaultArtPath.."\\TargetBox",
	width = 128,
	height = 64,
	x = 0,
	y = nameplate_verticalOffset,
	anchor = "CENTER",
	show = true,
}

theme.threatborder = {
	texture =			defaultArtPath.."\\RegularThreat",
	elitetexture =			defaultArtPath.."\\EliteThreat",
	width = 128,
	height = 64,
	x = 0,
	y = nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.castborder = {
	texture =					defaultArtPath.."\\CastStoppable",
	width = 128,
	height = 64,
	x = 0,
	y = 0 +castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.castnostop = {
	texture = 				defaultArtPath.."\\CastNotStoppable",
	width = 128,
	height = 64,
	x = 0,
	y = 0+castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.name = {
	typeface =					font,
	size = 9,
	width = 100,
	height = 10,
	x = 0,
	y = 6+nameplate_verticalOffset,
	align = "LEFT",
	anchor = "LEFT",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

theme.level = {
	typeface =					font,
	size = 9,
	width = 25,
	height = 10,
	x = 36,
	y = 6+nameplate_verticalOffset,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
}

theme.healthbar = {
	texture =					 defaultArtPath.."\\Statusbar",
	backdrop = 				defaultArtPath.."\\Empty",
	--backdrop = 				defaultArtPath.."\\Statusbar",
	height = 12,
	width = 101,
	x = 0,
	y = 15+nameplate_verticalOffset,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

theme.castbar = {
	texture =					defaultArtPath.."\\Statusbar",
	backdrop = 				defaultArtPath.."\\Empty",
	--backdrop = 				defaultArtPath.."\\Statusbar",
	height = 12,
	width = 99,
	x = 0,
	y = -8+castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

theme.customtext = {
	typeface =					font,
	size = 9,
	width = 93,
	height = 10,
	x = 0,
	y = 16+nameplate_verticalOffset,
	align = "RIGHT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

theme.spelltext = {
	typeface =					font,
	size = 8,
	width = 100,
	height = 10,
	x = 1,
	y = castBar_verticalOffset-8+nameplate_verticalOffset,
	align = "LEFT",
	anchor = "CENTER",
	vertical = "BOTTOM",
	shadow = true,
	flags = "NONE",
	show = true,
}

theme.spellicon = {
	width = 18,
	height = 18,
	x = 62,
	y = -8+castBar_verticalOffset+nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.raidicon = {
	width = 20,
	height = 20,
	x = -35,
	y = 12+nameplate_verticalOffset,
	anchor = "TOP",
}

theme.dangerskull = {
	width = 14,
	height = 14,
	x = 44,
	y = 8+nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.frame = {
	width = 101,
	height = 45,
	x = 0,
	y = 0+nameplate_verticalOffset,
	anchor = "CENTER",
}

theme.threatcolor = {
	LOW = {r = .6, g = 1, b = 0, a = 1,},
	MEDIUM = {r = .6, g = 1, b = 0, a = 1,},
	HIGH = {r = 1, g = 0, b = 0, a= 1,},  }












