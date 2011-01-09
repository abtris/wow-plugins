-- ForteXorcist v1.965.3 by Xus 05-10-2010 for 3.3.5 & 4.0.1

--[[
"frFR": French
"deDE": German
"esES": Spanish
"enUS": American english
"enGB": British english
"zhCN": Simplified Chinese
"zhTW": Traditional Chinese
"ruRU": Russian
"koKR": korean

!! Make sure to keep this saved as UTF-8 format !!

]]

--[[>> still needs translating]]

local FWL = FW.L;

-- THESE ARE INTERFACE STRINGS ONLY AND TRANSLATING THEM IS OPTIONAL

-- French
if GetLocale() == "frFR" then
	FWL.GET_SH_UPDATE = "Get an update of warlock shard status now. Will only fully work when someone with the addon is promoted!";

	FWL.SHARD_SPY = "Shard Spy";
	FWL.LITTLE_SHARDS = "Little shards";
	FWL.MANY_SHARDS = "Many shards";
	FWL.UNKNOWN_N = "Unknown";

	FWL.SH_ENABLE_TT = "Enable the Shard Spy.";

	FWL.SHARD_CHECK_TIME = "Shard check";
	FWL.SHARD_DRAW_INTERVAL = "Shard draw interval";

	FWL._TOTAL = "%d total";

-- Russian
elseif GetLocale() == "ruRU" then

	FWL.GET_SH_UPDATE = "Обновить количество Осколков душ у чернокнижников. Польностью функционально, только если кто-нибудь с аддоном является лидером или ассистентом!";

	FWL.SHARD_SPY = "Монитор Осколков душ";
	FWL.LITTLE_SHARDS = "Мало Осколков";
	FWL.MANY_SHARDS = "Много Осколков";
	FWL.UNKNOWN_N = "Неизвестно";

	FWL.SH_ENABLE_TT = "Включить монитор Осколков душ.";

	FWL.SHARD_CHECK_TIME = "Проверка Осколков";
	FWL.SHARD_DRAW_INTERVAL = "Интервал отображения Осколков";

	FWL._TOTAL = "Всего %d";

-- simple chinese
elseif GetLocale() == "zhCN" then

	FWL.GET_SH_UPDATE = "扫描碎片数据. 装了FW的同志有团队权限才能实现所有功能!";

	FWL.SHARD_SPY = "碎片助手";
	FWL.LITTLE_SHARDS = "碎片少";
	FWL.MANY_SHARDS = "碎片多";
	FWL.UNKNOWN_N = "未知";

	FWL.SH_ENABLE_TT = "启用碎片助手.";

	FWL.SHARD_CHECK_TIME = "碎片检查";
	FWL.SHARD_DRAW_INTERVAL = "碎片检查间隔";

	FWL._TOTAL = "共有 %d";

-- tradition chinese
elseif GetLocale() == "zhTW" then

	FWL.GET_SH_UPDATE = "掃描碎片資料. 裝了FW的隊員有團隊許可權才能實現所有功能!";

	FWL.SHARD_SPY = "碎片助手";
	FWL.LITTLE_SHARDS = "碎片少";
	FWL.MANY_SHARDS = "碎片多";
	FWL.UNKNOWN_N = "未知";

	FWL.SH_ENABLE_TT = "啟用碎片助手.";

	FWL.SHARD_CHECK_TIME = "碎片檢查";
	FWL.SHARD_DRAW_INTERVAL = "碎片檢查間隔";

	FWL._TOTAL = "共有 %d";
	
-- DE by DeaTHCorE (found a error? have a better translation? send me a email at dhaft@gmx.de)
elseif GetLocale() == "deDE" then
	FWL.GET_SH_UPDATE = "Aktualisiert den Status der Seelensplitter. Die volle Funktionalität ist nur gegeben wenn ein Spieler in der Gruppe mit diesem Addon die Leitung oder Assistentsrechte hat!";

	FWL.SHARD_SPY = "Splitterüberwachung";
	FWL.LITTLE_SHARDS = "Wenige Splitter";
	FWL.MANY_SHARDS = "Viele Splitter";
	FWL.UNKNOWN_N = "Unbekannt";

	FWL.SH_ENABLE_TT = "Aktiviere die Seelensplitterüberwachung.";

	FWL.SHARD_CHECK_TIME = "Seelensplitter prüfen";
	FWL.SHARD_DRAW_INTERVAL = "Seelensplitter-Aktualisierungsintervall";

	FWL._TOTAL = "Gesamt: %d";
	
	-- korean
elseif GetLocale() == "koKR" then
	FWL.GET_SH_UPDATE = "흑마법사 조각 보유 상황을 점검하고 관리할 수 있습니다.";

	FWL.SHARD_SPY = "조각관리자";
	FWL.LITTLE_SHARDS = "조각 부족!";
	FWL.MANY_SHARDS = "조각 충분!";
	FWL.UNKNOWN_N = "파악 불가";

	FWL.SH_ENABLE_TT = "조각관리자 활성화";

	FWL.SHARD_CHECK_TIME = "조각 체크 시간";
	FWL.SHARD_DRAW_INTERVAL = "조각 획득 간격";

	FWL._TOTAL = "%d 합계";	
	
-- ENGLISH
else
	FWL.GET_SH_UPDATE = "Get an update of warlock shard status now. Will only fully work when someone with the addon is promoted!";

	FWL.SHARD_SPY = "Shard Spy";
	FWL.LITTLE_SHARDS = "Little shards";
	FWL.MANY_SHARDS = "Many shards";
	FWL.UNKNOWN_N = "Unknown";

	FWL.SH_ENABLE_TT = "Enable the Shard Spy.";

	FWL.SHARD_CHECK_TIME = "Shard check";
	FWL.SHARD_DRAW_INTERVAL = "Shard draw interval";

	FWL._TOTAL = "%d total";

end
