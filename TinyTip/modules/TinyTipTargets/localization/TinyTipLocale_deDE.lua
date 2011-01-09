--[[-------------------------------------------------------
-- TinyTip Localization : German
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
-- Contributors: Slayman
--]]

if GetLocale() ~= "deDE" then return end

TinyTipLocale = setmetatable({
    ["Targeting"] = "Ziel",
    ["<<YOU>>"] = "<<DU>>",
    ["Targeted by"] = "im Ziel von",
}, {__index=TinyTipLocale})
