﻿-- ForteXorcist v1.974 by Xus 09-01-2011 for 4.0.3

--[[
"frFR": French
"deDE": German
"esES": Spanish
"enUS": American english
"enGB": British english
"zhCN": Simplified Chinese
"zhTW": Traditional Chinese
"ruRU": Russian
"koKR": Korean

!! Make sure to keep this saved as UTF-8 format !!

]]

--[[>> still needs translating]]

if FW.CLASS == "HUNTER" then
	local FWL = FW.L;
	if GetLocale() == "ruRU" then
	-- FR
	elseif GetLocale() == "frFR" then
	-- DE 
	elseif GetLocale() == "deDE" then
	-- SPANISH
	elseif GetLocale() == "esES" then
	-- Simple Chinese
	elseif GetLocale() == "zhCN" then
	-- tradition Chinese
	elseif GetLocale() == "zhTW" then
	-- ENGLISH
	else
	end
	FWL.SNAKE1 = "Viper";
	--FWL.SNAKE2 = "Venomous Snake";
end
