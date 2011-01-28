-- ForteXorcist v1.974.2 by Xus 18-01-2011 for 4.0.3

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



if FW.CLASS == "MAGE" then
	local FWL = FW.L;

	-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

	-- French
	if GetLocale() == "frFR" then
		FWL.BREAK_FADE = "Break/Fade";
		FWL.BREAK_FADE_HINT1 = "The time you set in the fade string defines when it is displayed.";
		FWL.POLYMORPH_BREAK = "Polymorph Break";
		FWL.POLYMORPH_FADE = "Polymorph Fade";
		
	-- Russian
	elseif GetLocale() == "ruRU" then
	--[[>>]]FWL.BREAK_FADE = "Break/Fade";
	--[[>>]]FWL.BREAK_FADE_HINT1 = "The time you set in the fade string defines when it is displayed.";
	--[[>>]]FWL.POLYMORPH_BREAK = "Polymorph Break";
	--[[>>]]FWL.POLYMORPH_FADE = "Polymorph Fade";
		
	-- simplified chinese
	elseif GetLocale() == "zhCN" then
		
		FWL.BREAK_FADE = "打断/消退";
		FWL.BREAK_FADE_HINT1 = "变形术打断/消退时显示字符.";
		FWL.POLYMORPH_BREAK = "变形术打断";
		FWL.POLYMORPH_FADE = "变形术消退";

	-- traditional chinese
	elseif GetLocale() == "zhTW" then
		
		FWL.BREAK_FADE = "打斷/消退";
		FWL.BREAK_FADE_HINT1 = "變形術打斷/消退時顯示字元.";
		FWL.POLYMORPH_BREAK = "變形術打斷";
		FWL.POLYMORPH_FADE = "變形術消退";
		
	-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
	elseif GetLocale() == "deDE" then
		
		FWL.BREAK_FADE = "Unterbrochen/Endet";
	--[[>>]]FWL.BREAK_FADE_HINT1 = "Die Zeit die du in der Textzeile einsetzt bestimmt wann sie angezeigt wird. (Korrekte übersetzung? Originaltext: The time you set in the fade string defines when it is displayed.)";
	--[[>>]]FWL.POLYMORPH_BREAK = "Polymorph Break";
	--[[>>]]FWL.POLYMORPH_FADE = "Polymorph Fade";
		
	--Korean
	elseif GetLocale() == "koKR" then

		FWL.BREAK_FADE = "풀림/사라짐";
		FWL.BREAK_FADE_HINT1 = "변이가 사라지기 전 설정한 시간이 되면 알림이 표시됩니다.";
		FWL.POLYMORPH_BREAK = "변이 풀림";
		FWL.POLYMORPH_FADE = "변이 사라짐";		
		
	-- ENGLISH
	else	-- standard english version

		FWL.BREAK_FADE = "Break/Fade";
		FWL.BREAK_FADE_HINT1 = "The time you set in the fade string defines when it is displayed.";
		FWL.POLYMORPH_BREAK = "Polymorph Break";
		FWL.POLYMORPH_FADE = "Polymorph Fade";

	end
end
	