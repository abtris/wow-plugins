--[[-------------------------------------------------------
-- TinyTip Localization : French
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
-- Contributors: Adirelle
--]]

if GetLocale() ~= "frFR" then return end

TinyTipLocale = setmetatable({
    ["Targeting"] = "Cibl\195\169",
    ["<<YOU>>"] = "<<VOUS>>",
    ["Targeted by"] = "Cibl\195\169 par", -- babelfish
}, {__index=TinyTipLocale})

