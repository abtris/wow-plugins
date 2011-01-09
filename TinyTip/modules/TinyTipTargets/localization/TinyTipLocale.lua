--[[-------------------------------------------------------
-- TinyTipTargets Localization : Default
-----------------------------------------------------------
-- Any wrong translations, change them here.
-- This file must be saved as UTF-8 compatible.
--
-- To get your client's locale, type in:
--
-- /script DEFAULT_CHAT_FRAME:AddMessage( GetLocale() )
--
-- Do not repost without permission from the author. If you
-- want to add a translation, contact the author.
--
--]]

local t = {
        ["Targeting"] = "Targeting",
        ["<< YOU >>"] = "<< YOU >>",
        ["Targeted by"] = "Targeted by",
        ["PARTY"] = TUTORIAL_TITLE19,
        ["RAID"] = RAID,
        ["Unknown"] = UNKNOWN,
        ["UnknownEntity"] = UKNOWNBEING,
}

-- support for TinyTipModuleCore
TinyTipLocale = (TinyTipLocale and setmetatable(t, {__index=TinyTipLocale})) or t
t = nil
