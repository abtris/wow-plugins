--[[-------------------------------------------------------
-- TinyTip Localization : Chinese
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

if GetLocale() ~= "zhCN" then return end

TinyTipLocale = setmetatable({
        ["Targeting"] = "当前目标",
        ["<< YOU >>"] = ">>你<<",
        ["Targeted by"] = "关注",
}, {__index=TinyTipLocale})
