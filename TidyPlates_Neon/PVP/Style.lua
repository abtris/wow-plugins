-----------------------------------------------------
-- Tidy Plates: Neon/PVP - Theme Definition
-----------------------------------------------------
TidyPlatesThemeList["Neon/PVP"] = {}

---------------
-- Config
---------------


---------------
-- Style Assignment (Uses default art)
---------------
local artpath = "Interface\\Addons\\TidyPlates_Neon\\Media\\"
local castadjust = -21
local nameadjust = -8
local theme = TidyPlatesThemeList["Neon/PVP"]

theme.hitbox = {
	width = 105,
	height = 20,
}

theme.frame = {
	x = 0,
	y = 4,
}

theme.healthborder = {
	texture		 =				artpath.."Neon_HealthOverlay",
	glowtexture =					artpath.."Neon_Highlight",
	elitetexture =					artpath.."Neon_HealthOverlayEliteStar",
	width = 128,
	height = 32,
	y = 0,
}

theme.raidicon = {
	width = 32,
	height = 32,
	x = -48,
	y = 0,
	anchor = "CENTER",
}

theme.healthbar = {
	texture =					 artpath.."Neon_Bar",
	--backdrop = 				artpath.."Neon_Bar_Backdrop",
	width = 100,
	height = 32,
	x = 0,
	y = 0,
}

theme.castborder = {
	texture =					artpath.."Neon_CastOverlayBlue",
	width = 128,
	height = 32,
	x = 0,
	y = castadjust,
}

theme.castnostop = {
	texture =					artpath.."Neon_CastOverlayRed",
	width = 128,
	height = 32,
	x = 0,
	y = castadjust,
}


theme.castbar = {
	texture =					 artpath.."Neon_Bar",
	width = 100,
	height = 32,
	x = 0,
	y = castadjust,
	anchor = "CENTER",
	orientation = "HORIZONTAL",
}

theme.threatborder = {
	texture =				artpath.."Neon_AggroOverlayWhite",
	--elitetexture =				artpath.."Neon_Empty",
	elitetexture =			artpath.."Neon_AggroOverlayWhite",
	width = 256,
	height = 64,
	y = 1,
}

theme.spellicon = {
	width = 17,
	height = 17,
	x = 26,
	y = -3+castadjust,
	anchor = "CENTER",
}

theme.name = {
	typeface = artpath.."Qlassik_TB.ttf",
	size = 13,
	width = 200,
	height = 11,
	x = 0,
	y = nameadjust,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
}

theme.level = {
	typeface = artpath.."Qlassik_TB.ttf",
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
}

theme.dangerskull = {
	width = 14,
	height = 14,
	x = 5,
	y = 5,
	anchor = "LEFT",
}

theme.specialText = {
typeface = artpath.."Qlassik_TB.ttf",
	size = 11,
	width = 150,
	height = 11,
	x = 26,
	y = -19+castadjust,
	align = "CENTER",
	anchor = "CENTER",
	vertical = "CENTER",
	shadow = true,
}

theme.specialText2 = {
typeface = artpath.."Qlassik_TB.ttf",
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
}

theme.options = {
	showName = true,
	showLevel = false,
	showDangerSkull = true,
	showSpecialText = true,
	showSpecialText2 = true,
	showSpecialArt = true,
	useCustomHealthbarColor = true,
	forceAlpha = true,
}






