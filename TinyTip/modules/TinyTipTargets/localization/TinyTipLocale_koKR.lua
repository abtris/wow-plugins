--[[-------------------------------------------------------
-- TinyTip Localization : Korean
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
-- Contributors:
--]]

if GetLocale() ~= "koKR" then return end

TinyTipLocale = setmetatable({
    ["Targeting"] = "현재 대상",
    ["<<YOU>>"] = "너", -- babelfish
    ["Targeted by"] = "대상지정자",
    ["PARTY"] = string.format("명의 %s", TUTORIAL_TITLE19),
    ["RAID"] = string.format("명의 %s원", RAID),
    ["Unknown"] = "알수없음",
}, {__index=TinyTipLocale})
