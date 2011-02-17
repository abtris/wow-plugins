-- $Id: Atlas-zhTW.lua 1220 2011-01-28 13:36:29Z dynaletik $
--[[

	Atlas, a World of Warcraft instance map browser
	Copyright 2005-2010 Dan Gilbert <dan.b.gilbert@gmail.com>
	Copyright 2010-2011 Lothaer <lothayer@gmail.com >, Atlas Team

	This file is part of Atlas.

	Atlas is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Atlas is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Atlas; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

--]]

local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("Atlas", "zhTW", false);

-- Atlas Traditional Chinese Localization
if ( GetLocale() == "zhTW" ) then
-- Define the leading strings to be ignored while sorting
-- Ex: The Stockade
AtlasSortIgnore = {};

AtlasZoneSubstitutions = {
	["The Temple of Atal'Hakkar"] = "沈沒的神廟";
	["Ahn'Qiraj"] = "安其拉神廟";
	["Karazhan"] = "卡拉贊 - 1.開始";
	["Black Temple"] = "黑暗神廟 - 1.開始";
};
end


if AL then
--************************************************
-- UI terms and common strings
--************************************************
	AL["ATLAS_TITLE"] = "Atlas 地圖集";

	AL["BINDING_HEADER_ATLAS_TITLE"] = "Atlas 按鍵設定";
	AL["BINDING_NAME_ATLAS_TOGGLE"] = "開啟/關閉 Atlas";
	AL["BINDING_NAME_ATLAS_OPTIONS"] = "切換設定";
	AL["BINDING_NAME_ATLAS_AUTOSEL"] = "自動選擇";

	AL["ATLAS_SLASH"] = "/atlas";
	AL["ATLAS_SLASH_OPTIONS"] = "選項";

	AL["ATLAS_STRING_LOCATION"] = "位置";
	AL["ATLAS_STRING_LEVELRANGE"] = "等級範圍";
	AL["ATLAS_STRING_PLAYERLIMIT"] = "人數上限";
	AL["ATLAS_STRING_SELECT_CAT"] = "選擇類別";
	AL["ATLAS_STRING_SELECT_MAP"] = "選擇地圖";
	AL["ATLAS_STRING_SEARCH"] = "搜尋";
	AL["ATLAS_STRING_CLEAR"] = "清除";
	AL["ATLAS_STRING_MINLEVEL"] = "最低等級";

	AL["ATLAS_OPTIONS_BUTTON"] = "選項";
	AL["ATLAS_OPTIONS_SHOWBUT"] = "在小地圖旁顯示 Atlas 按鈕";
	AL["ATLAS_OPTIONS_SHOWBUT_TIP"] = "在小地圖旁顯示 Atlas 按鈕";
	AL["ATLAS_OPTIONS_AUTOSEL"] = "自動選擇副本地圖";
	AL["ATLAS_OPTIONS_AUTOSEL_TIP"] = "Atlas 可偵測您目前所在的副區域以判定您所在的副本, 開啟 Atlas 時將會自動選擇到該副本地圖";
	AL["ATLAS_OPTIONS_BUTPOS"] = "按鈕位置";
	AL["ATLAS_OPTIONS_TRANS"] = "透明度";
	AL["ATLAS_OPTIONS_RCLICK"] = "點擊滑鼠右鍵開啟世界地圖";
	AL["ATLAS_OPTIONS_RCLICK_TIP"] = "啟用在 Atlas 視窗中按下滑鼠右鍵自動切換到魔獸的世界地圖";
	AL["ATLAS_OPTIONS_RESETPOS"] = "重設位置";
	AL["ATLAS_OPTIONS_ACRONYMS"] = "顯示副本縮寫";
	AL["ATLAS_OPTIONS_ACRONYMS_TIP"] = "在地圖的詳盡敘述中顯示副本的縮寫";
	AL["ATLAS_OPTIONS_SCALE"] = "視窗大小比率";
	AL["ATLAS_OPTIONS_BUTRAD"] = "按鈕半徑範圍";
	AL["ATLAS_OPTIONS_CLAMPED"] = "使 Atlas 視窗不超出遊戲畫面";
	AL["ATLAS_OPTIONS_CLAMPED_TIP"] = "使 Atlas 視窗被拖曳時不會超出遊戲主畫面的邊界, 關閉此選項則可將 Atlas 視窗拖曳並超出遊戲畫面邊界";
	AL["ATLAS_OPTIONS_CTRL"] = "按住 Ctrl 鍵以顯示工具提示";
	AL["ATLAS_OPTIONS_CTRL_TIP"] = "勾選後, 當滑鼠移到地圖資訊欄位時, 按下 Ctrl 控制鍵, 則會將資訊的完整資訊以提示型態顯示. 當資訊過長而被截斷時很有用.";

	AL["ATLAS_BUTTON_TOOLTIP_TITLE"] = "Atlas 副本地圖";
	AL["ATLAS_BUTTON_TOOLTIP_HINT"] = "左鍵開啟 Atlas.\n中鍵開啟 Atlas 選項.\n右鍵並拖曳以移動圖示按鈕位置.";
	AL["ATLAS_LDB_HINT"] = "左鍵開啟 Atlas.\n中鍵開啟 Atlas 選項.\n右鍵打開顯示選單.";

	AL["ATLAS_OPTIONS_CATDD"] = "副本地圖分類方式:";
	AL["ATLAS_DDL_CONTINENT"] = "大陸";
	AL["ATLAS_DDL_CONTINENT_EASTERN"] = "東部王國副本";
	AL["ATLAS_DDL_CONTINENT_KALIMDOR"] = "卡林多副本";
	AL["ATLAS_DDL_CONTINENT_OUTLAND"] = "外域副本";
	AL["ATLAS_DDL_CONTINENT_NORTHREND"] = "北裂境副本";
	AL["ATLAS_DDL_CONTINENT_DEEPHOLM"] = "地深之源副本";
	AL["ATLAS_DDL_LEVEL"] = "等級";
	AL["ATLAS_DDL_LEVEL_UNDER45"] = "副本等級低於 45";
	AL["ATLAS_DDL_LEVEL_45TO60"] = "副本等級介於 45-60";
	AL["ATLAS_DDL_LEVEL_60TO70"] = "副本等級介於 60-70";
	AL["ATLAS_DDL_LEVEL_70TO80"] = "副本等級介於 70-80";
	AL["ATLAS_DDL_LEVEL_80TO85"] = "副本等級介於 80-85";
	AL["ATLAS_DDL_LEVEL_85PLUS"] = "副本等級大於 85";
	AL["ATLAS_DDL_PARTYSIZE"] = "隊伍人數";
	AL["ATLAS_DDL_PARTYSIZE_5_AE"] = "5 人副本 1/3";
	AL["ATLAS_DDL_PARTYSIZE_5_FS"] = "5 人副本 2/3";
	AL["ATLAS_DDL_PARTYSIZE_5_TZ"] = "5 人副本 3/3";
	AL["ATLAS_DDL_PARTYSIZE_10_AN"] = "10 人副本 1/2";
	AL["ATLAS_DDL_PARTYSIZE_10_OZ"] = "10 人副本 2/2";
	AL["ATLAS_DDL_PARTYSIZE_20TO40"] = "20-40 人副本";
	AL["ATLAS_DDL_EXPANSION"] = "資料片";
	AL["ATLAS_DDL_EXPANSION_OLD_AO"] = "舊世界副本 1/2";
	AL["ATLAS_DDL_EXPANSION_OLD_PZ"] = "舊世界副本 2/2";
	AL["ATLAS_DDL_EXPANSION_BC"] = "燃燒的遠征副本";
	AL["ATLAS_DDL_EXPANSION_WOTLK"] = "巫妖王之怒副本";
	AL["ATLAS_DDL_EXPANSION_CATA"] = "浩劫與重生副本";
	AL["ATLAS_DDL_TYPE"] = "類型";
	AL["ATLAS_DDL_TYPE_INSTANCE_AC"] = "副本 1/3";
	AL["ATLAS_DDL_TYPE_INSTANCE_DR"] = "副本 2/3";
	AL["ATLAS_DDL_TYPE_INSTANCE_SZ"] = "副本 3/3";
	AL["ATLAS_DDL_TYPE_ENTRANCE"] = "入口";

	AL["ATLAS_INSTANCE_BUTTON"] = "副本";
	AL["ATLAS_ENTRANCE_BUTTON"] = "入口";
	AL["ATLAS_SEARCH_UNAVAIL"] = "搜尋功能停用";

	AL["ATLAS_DEP_MSG1"] = "Atlas 偵測到過期的模組";
	AL["ATLAS_DEP_MSG2"] = "這些模組已從這個角色被停用";
	AL["ATLAS_DEP_MSG3"] = "請將這些模組從 AddOns 目錄移除";
	AL["ATLAS_DEP_OK"] = "OK";

--************************************************
-- Zone Names, Acronyms, and Common Strings
--************************************************

	--Common strings
	AL["East"] = "東";
	AL["North"] = "北";
	AL["South"] = "南";
	AL["West"] = "西";

	--World Events, Festival
	AL["Brewfest"] = "啤酒節";
	AL["Hallow's End"] = "萬鬼節";
	AL["Love is in the Air"] = "愛就在身邊";
	AL["Lunar Festival"] = "新年慶典";
	AL["Midsummer Festival"] = "仲夏節慶";
	--Misc strings
	AL["Adult"] = "成年";
	AL["AKA"] = "又稱";
	AL["Arcane Container"] = "秘法容器";
	AL["Arms Warrior"] = "武戰";
	AL["Attunement Required"] = "需完成傳送門/鑰匙前置任務";
	AL["Back"] = "後方";
	AL["Basement"] = "地下室";
	AL["Blacksmithing Plans"] = "黑鐵鍛造圖樣";
	AL["Boss"] = "首領";
	AL["Chase Begins"] = "追逐開始";
	AL["Chase Ends"] = "追逐結束";
	AL["Child"] = "幼年";
	AL["Connection"] = "通道";
	AL["DS2"] = "副本套裝2";
	AL["Elevator"] = "電梯";
	AL["End"] = "結束";
	AL["Engineer"] = "工程師";
	AL["Entrance"] = "入口";
	AL["Event"] = "事件";
	AL["Exalted"] = "崇拜";
	AL["Exit"] = "出口";
	AL["Fourth Stop"] = "第四停留點";
	AL["Front"] = "前方";
	AL["Ghost"] = "鬼魂";
	AL["Graveyard"] = "墓地";
	AL["Heroic"] = "英雄";
	AL["Holy Paladin"] = "神聖聖騎";
	AL["Holy Priest"] = "神聖牧師";
	AL["Hunter"] = "獵人";
	AL["Imp"] = "小鬼";
	AL["Inside"] = "內部";
	AL["Key"] = "鑰匙";
	AL["Lower"] = "下層";
	AL["Mage"] = "法師";
	AL["Meeting Stone"] = "集合石";
	AL["Middle"] = "中間";
	AL["Monk"] = "僧侶";
	AL["Moonwell"] = "月井";
	AL["Optional"] = "可選擇";
	AL["Orange"] = "橙";
	AL["Outside"] = "戶外";
	AL["Paladin"] = "聖騎士";
	AL["Portal"] = "入口/傳送門";
	AL["Priest"] = "牧師";
	AL["Protection Warrior"] = "防戰";
	AL["Purple"] = "紫";
	AL["Random"] = "隨機";
	AL["Rare"] = "稀有";
	AL["Reputation"] = "聲望";
	AL["Repair"] = "修理";
	AL["Retribution Paladin"] = "懲戒聖騎";
	AL["Rewards"] = "獎勵";
	AL["Rogue"] = "盜賊";
	AL["Second Stop"] = "第二停留點";
	AL["Shadow Priest"] = "暗影牧師";
	AL["Shaman"] = "薩滿";
	AL["Side"] = "側邊";
	AL["Spawn Point"] = "生成點";
	AL["Start"] = "開始";
	AL["Summon"] = "召喚";
	AL["Teleporter"] = "傳送";
	AL["Third Stop"] = "第三停留點";
	AL["Tiger"] = "虎";
	AL["Top"] = "上方";
	AL["Underwater"] = "水下";
	AL["Unknown"] = "未知";
	AL["Upper"] = "上層";
	AL["Varies"] = "多處";
	AL["Wanders"] = "徘徊";
	AL["Warlock"] = "術士";
	AL["Warrior"] = "戰士";
	AL["Wave 5"] = "第 5 波";
	AL["Wave 6"] = "第 6 波";
	AL["Wave 10"] = "第 10 波";
	AL["Wave 12"] = "第 12 波";
	AL["Wave 18"] = "第 18 波";	

	--Classic Acronyms
	AL["AQ"] = "AQ"; -- Ahn'Qiraj 安其拉
	AL["AQ20"] = "AQ20"; -- Ruins of Ahn'Qiraj 安其拉廢墟
	AL["AQ40"] = "AQ40"; -- Temple of Ahn'Qiraj 安其拉神廟
	AL["Armory"] = "軍械庫";  -- Armory 軍械庫
	AL["BFD"] = "BFD/黑淵"; -- Blackfathom Deeps 黑暗深淵
	AL["BRD"] = "BRD/黑石淵"; -- Blackrock Depths 黑石深淵
	AL["BRM"] = "黑石山"; -- Blackrock Mountain 黑石山
	AL["BWL"] = "BWL/黑翼"; -- Blackwing Lair 黑翼之巢
	AL["Cath"] = "教堂"; -- Cathedral 大教堂
	AL["DM"] = "DM/厄運"; -- Dire Maul 厄運之槌
	AL["Gnome"] = "Gnome/諾姆"; -- Gnomeregan 諾姆瑞根
	AL["GY"] = "GY"; -- Graveyard 墓園
	AL["LBRS"] = "LBRS/黑下";  -- Lower Blackrock Spire 黑石塔下層
	AL["Lib"] = "Lib"; -- Library 圖書館
	AL["Mara"] = "Mara/瑪拉"; -- Maraudon 瑪拉頓
	AL["MC"] = "MC"; -- Molten Core 熔火之心
	AL["RFC"] = "RFC/怒焰"; -- Ragefire Chasm 怒焰裂谷
	AL["RFD"] = "RFD"; -- Razorfen Downs 剃刀高地
	AL["RFK"] = "RFK"; -- Razorfen Kraul 剃刀沼澤
	AL["Scholo"] = "Scholo/通靈"; -- Scholomance 通靈學院
	AL["SFK"] = "SFK/影牙"; -- Shadowfang Keep 影牙城堡
	AL["SM"] = "SM/血色"; -- Scarlet Monastery 血色修道院
	AL["ST"] = "ST/神廟"; -- Sunken Temple 沉沒的神廟
	AL["Strat"] = "Strat/斯坦"; -- Stratholme 斯坦索姆
	AL["Stocks"] = "監獄"; -- The Stockade 監獄
	AL["UBRS"] = "UBRS/黑上"; -- Upper Blackrock Spire 黑石塔上層
	AL["Ulda"] = "Ulda"; -- Uldaman 奧達曼
	AL["VC"] = "VC/死礦"; -- The Deadmines 死亡礦坑
	AL["WC"] = "WC/哀嚎"; -- Wailing Caverns 哀嚎洞穴
	AL["ZF"] = "ZF/祖法"; -- Zul'Farrak 祖爾法拉克

	--BC Acronyms
	AL["AC"] = "AC"; -- Auchenai Crypts 奧奇奈地穴
	AL["Arca"] = "Arca 亞克"; -- The Arcatraz 亞克崔茲
	AL["Auch"] = "Auch"; -- Auchindoun 奧齊頓
	AL["BF"] = "BF"; -- The Blood Furnace 血熔爐
	AL["BT"] = "BT/黑廟"; -- Black Temple 黑暗神廟
	AL["Bota"] = "Bota/波塔"; -- The Botanica 波塔尼卡
	AL["CoT"] = "CoT"; -- Caverns of Time 時光之穴
	AL["CoT1"] = "CoT1/舊址"; -- Old Hillsbrad Foothills 希爾斯布萊德丘陵舊址
	AL["CoT2"] = "CoT2/黑沼"; -- The Black Morass 黑色沼澤
	AL["CoT3"] = "CoT3/海山"; -- Hyjal Summit 海加爾山
	AL["CR"] = "CR/盤牙"; -- Coilfang Reservoir
	AL["GL"] = "GL/戈魯爾"; -- Gruul's Lair 戈魯爾之巢
	AL["HC"] = "HC/火堡"; -- Hellfire Citadel 地獄火堡壘
	AL["Kara"] = "Kara/卡拉"; -- Karazhan 卡拉贊
	AL["MaT"] = "MT/博學"; -- Magisters' Terrace 博學者殿堂
	AL["Mag"] = "Mag/瑪瑟"; -- Magtheridon's Lair 瑪瑟里頓的巢穴
	AL["Mech"] = "Mech/麥克"; -- The Mechanar 麥克納爾
	AL["MT"] = "MT/法力"; -- Mana-Tombs 法力墓地
	AL["Ramp"] = "Ramp"; -- Hellfire Ramparts 地獄火壁壘
	AL["SC"] = "SC/毒蛇"; -- Serpentshrine Cavern 毒蛇神殿洞穴
	AL["Seth"] = "Seth/塞司克"; -- Sethekk Halls 塞司克大廳
	AL["SH"] = "SH/破碎"; -- The Shattered Halls 破碎大廳
	AL["SL"] = "SL/迷宮"; -- Shadow Labyrinth 暗影迷宮
	AL["SP"] = "SP"; -- The Slave Pens 奴隸監獄
	AL["SuP"] = "SP/太陽井"; -- Sunwell Plateau 太陽之井高地
	AL["SV"] = "SV/蒸汽"; -- The Steamvault 蒸汽洞窟
	AL["TK"] = "TK/風暴"; -- Tempest Keep 風暴要塞
	AL["UB"] = "UB/深幽"; -- The Underbog 深幽泥沼
	AL["ZA"] = "ZA"; -- Zul'Aman 祖阿曼

	--WotLK Acronyms
	AL["AK, Kahet"] = "AK/安卡"; -- Ahn'kahet -- 安卡罕特
	AL["AN, Nerub"] = "AN/奈幽"; -- Azjol-Nerub -- 阿茲歐-奈幽
	AL["Champ"] = "勇士"; -- Trial of the Champion -- 勇士試煉
	AL["CoT-Strat"] = "CoT斯坦"; -- Culling of Stratholme -- 斯坦索姆的抉擇
	AL["Crus"] = "十字軍"; -- Trial of the Crusader --十字軍試煉
	AL["DTK"] = "DTK/德拉克"; -- Drak'Tharon Keep -- 德拉克薩隆要塞
	AL["FoS"] = "FoS/熔爐"; 
	AL["FH1"] = "FH1"; -- The Forge of Souls -- 眾魂熔爐
	AL["Gun"] = "Gun/剛德"; -- Gundrak -- 剛德拉克
	AL["HoL"] = "HoL/雷光"; -- Halls of Lightning --雷光大廳
	AL["HoR"] = "HoR/倒影"; 
	AL["FH3"] = "FH3"; -- Halls of Reflection -- 倒影大廳
	AL["HoS"] = "HoS/石廳"; -- Halls of Stone -- 石之大廳
 	AL["IC"] = "ICC/冰冠"; -- Icecrown Citadel -- 冰冠城塞
	AL["Nax"] = "Nax/納克"; -- Naxxramas -- 納克薩瑪斯
	AL["Nex, Nexus"] = "Nex/奧心"; -- The Nexus -- 奧核之心
	AL["Ocu"] = "Ocu/奧眼"; -- The Oculus -- 奧核之眼
	AL["Ony"] = "Ony/黑龍"; -- Onyxia's Lair 奧妮克希亞的巢穴
	AL["OS"] = "OS/黑曜"; -- The Obsidian Sanctum -- 黑曜聖所
	AL["PoS"] = "PoS"; 
	AL["FH2"] = "FH2"; -- Pit of Saron -- 薩倫之淵
	AL["RS"] = "RS/晶紅"; -- The Ruby Sanctum
	AL["TEoE"] = "TEoE/永恆"; -- The Eye of Eternity--永恆之眼
	AL["UK, Keep"] = "UK/俄塞"; -- Utgarde Keep -- 俄特加德要塞
	AL["Uldu"] = "Uldu/奧杜亞"; -- Ulduar-- 奧杜亞
	AL["UP, Pinn"] = "UP/俄巔"; -- Utgarde Pinnacl -- 俄特加德之巔
	AL["VH"] = "VH/紫堡"; -- The Violet Hold -- 紫羅蘭堡
	AL["VoA"] = "VoA/亞夏"; -- Vault of Archavon--亞夏梵穹殿

	--Zones not included in LibBabble-Zone
	AL["Crusaders' Coliseum"] = "銀白大競技場";

	--Cataclysm Acronyms
	--AL["AM"] = "AM"; --Abyssal Maw
	AL["BH"] = "BH"; --Baradin Hold 巴拉丁堡
	AL["BoT"] = "BoT"; --Bastion of Twilight 暮光堡壘
	AL["BRC"] = "BRC"; --Blackrock Caverns 黑石洞穴
	AL["BWD"] = "BWD"; --Blackwing Descent 黑翼陷窟
	--AL["CoT-WA"] = "CoT-WA"; --War of the Ancients 先祖之戰
	AL["GB"] = "GB"; --Grim Batol 格瑞姆巴托
	AL["HoO"] = "HoO"; --Halls of Origination 起源大廳
	AL["LCoT"] = "LCoT"; --Lost City of the Tol'vir 托維爾的失落之城
	--AL["SK"] = "SK"; --Sulfuron Keep
	AL["TSC"] = "TSC"; --The Stonecore 石岩之心
	AL["TWT"] = "TWT"; --Throne of the Four Winds 四風王座
	AL["ToTT"] = "ToTT"; --Throne of the Tides 海潮王座
	AL["VP"] = "VP"; --The Vortex Pinnacle 漩渦尖塔

--************************************************
-- Instance Entrance Maps
--************************************************

	--Auchindoun (Entrance)
	AL["Ha'Lei"] = "哈勒";
	AL["Greatfather Aldrimus"] = "大祖父阿爾崔瑪斯";
	AL["Clarissa"] = "克萊瑞莎";
	AL["Ramdor the Mad"] = "瘋狂者藍姆多";
	AL["Horvon the Armorer <Armorsmith>"] = "護甲匠霍沃 <護甲鍛造師>";
	AL["Nexus-Prince Haramad"] = "奈薩斯王子哈拉瑪德";
	AL["Artificer Morphalius"] = "工匠莫法利厄司";
	AL["Mamdy the \"Ologist\""] = "學家瑪姆迪";
	AL["\"Slim\" <Shady Dealer>"] = "『瘦子』 <黑市商人>";
	AL["\"Captain\" Kaftiz"] = "隊長卡夫提茲";
	AL["Isfar"] = "伊斯法";
	AL["Field Commander Mahfuun"] = "戰場元帥瑪赫范";
	AL["Spy Grik'tha"] = "間諜葛瑞克薩";
	AL["Provisioner Tsaalt"] = "糧食供應者·茲索特";
	AL["Dealer Tariq <Shady Dealer>"] = "商人塔爾利奎 <黑市商人>";

	--Blackfathom Deeps (Entrance)

	--Blackrock Mountain (Entrance)
	AL["Bodley"] = "布德利";
	AL["Lothos Riftwaker"] = "洛索斯·天痕";
	AL["Orb of Command"] = "命令寶珠";
	AL["Scarshield Quartermaster <Scarshield Legion>"] = "裂盾軍需官 <裂盾軍團>";
	AL["The Behemoth"] = "貝希摩斯";

	--Caverns of Time (Entrance)
	AL["Steward of Time <Keepers of Time>"] = "時間服務員 <時光守望者>";
	AL["Alexston Chrome <Tavern of Time>"] = "艾力克斯頓·科洛米 <時間酒館>";
	AL["Yarley <Armorer>"] = "亞利 <護甲商>";
	AL["Bortega <Reagents & Poison Supplies>"] = "伯特卡 <施法材料和毒藥供應商>";
	AL["Alurmi <Keepers of Time Quartermaster>"] = "阿勒米 <時光守望者軍需官>";
	AL["Galgrom <Provisioner>"] = "卡葛隆姆 <物資供應者>";
	AL["Zaladormu"] = "薩拉多姆";
	AL["Soridormi <The Scale of Sands>"] = "索芮朵蜜 <流沙之鱗>";
	AL["Arazmodu <The Scale of Sands>"] = "阿拉斯莫杜 <流沙之鱗>";
	AL["Andormu <Keepers of Time>"] = "安杜姆 <時光守望者>";
	AL["Nozari <Keepers of Time>"] = "諾札瑞 <時光守望者>";
	AL["Anachronos <Keepers of Time>"] = "安納克羅斯 <時光守望者>";

	--Caverns of Time: Hyjal (Entrance)
	AL["Indormi <Keeper of Ancient Gem Lore>"] = "隱多米 <寶石傳說的守護者>";
	AL["Tydormu <Keeper of Lost Artifacts>"] = "提多姆 <失落的神器看管者>";

	--Coilfang Reservoir (Entrance)
	AL["Watcher Jhang"] = "看守者詹汗格";
	AL["Mortog Steamhead"] = "莫塔格·史提海德";

	--Dire Maul (Entrance)
	AL["Dire Pool"] = "厄運之池";
	AL["Dire Maul Arena"] = "厄運競技場";
	AL["Elder Mistwalker"] = "霧行長者";

	--Gnomeregan (Entrance)
	AL["Torben Zapblast <Teleportation Specialist>"] = "托爾班·速轟 <傳送專家>";

	--Hellfire Citadel (Entrance)
	AL["Steps and path to the Blood Furnace"] = "通往血熔爐的階梯與通道";
	AL["Path to the Hellfire Ramparts and Shattered Halls"] = "通往地獄火壁壘與破碎大廳的通道";
	AL["Meeting Stone of Magtheridon's Lair"] = "集合石 - 瑪瑟里頓的巢穴";
	AL["Meeting Stone of Hellfire Citadel"] = "集合石 - 地獄火堡壘";

	--Icecrown Citadel (Entrance)

	--Karazhan (Entrance)
	AL["Archmage Leryda"] = "大法師利瑞達";
	AL["Archmage Alturus"] = "大法師艾特羅斯";
	AL["Apprentice Darius"] = "學徒達瑞爾斯";
	AL["Stairs to Underground Pond"] = "通往地底池塘的階梯";
	AL["Stairs to Underground Well"] = "通往地底水井的階梯";
	AL["Charred Bone Fragment"] = "燒焦的白骨碎片";

	--Maraudon (Entrance)
	AL["The Nameless Prophet"] = "無名預言者";

	--Scarlet Monastery (Entrance)

	--The Deadmines (Entrance)

	--Sunken Temple (Entrance)
	AL["Priestess Udum'bra"] = "女祭師烏丹姆布拉";
	AL["Gomora the Bloodletter"] = "『放血者』高摩拉";

	--Uldaman (Entrance)

	--Ulduar (Entrance)
	AL["Shavalius the Fancy <Flight Master>"] = "『狂想』夏瓦利厄斯 <飛行管理員>";
	AL["Chester Copperpot <General & Trade Supplies>"] = "查斯特·銅壺 <一般與貿易供應商>";
	AL["Slosh <Food & Drink>"] = "斯洛許 <食物和飲料>";

	--Wailing Caverns (Entrance)

--************************************************
-- Kalimdor Instances (Classic)
--************************************************

	--Blackfathom Deeps
	AL["Shrine of Gelihast"] = "格里哈斯特神殿";
	AL["Fathom Stone"] = "深淵之石";
	AL["Lorgalis Manuscript"] = "洛迦里斯手稿";
	AL["Scout Thaelrid"] = "斥候塞爾瑞德";
	AL["Flaming Eradicator"] = "火焰根除者";
	AL["Altar of the Deeps"] = "瑪塞斯特拉祭壇";
	AL["Ashelan Northwood"] = "阿謝蘭·北木";
	AL["Relwyn Shadestar"] = "芮爾溫·影星";
	AL["Sentinel Aluwyn"] = "哨兵阿露溫";
	AL["Sentinel-trainee Issara"] = "哨兵受訓員伊薩拉";
	AL["Je'neu Sancrea <The Earthen Ring>"] = "耶努薩克雷 <陶土議會>";
	AL["Zeya"] = "仄亞";

	--Dire Maul (East)
	AL["\"Ambassador\" Dagg'thol"] = "達格索大使";
	AL["Furgus Warpwood"] = "佛格斯·扭木";
	AL["Old Ironbark"] = "埃隆巴克";
	AL["Ironbark the Redeemed"] = "贖罪的鐵朴";

	--Dire Maul (North)
	AL["Druid of the Talon"] = "猛禽德魯伊";
	AL["Stonemaul Ogre"] = "石槌巨魔";
	AL["Knot Thimblejack"] = "諾特·希姆加克";

	--Dire Maul (West)
	AL["J'eevee's Jar"] = "耶維爾的瓶子";
	AL["Ferra"] = "費拉";
	AL["Estulan <The Highborne>"] = "艾斯圖蘭";
	AL["Shen'dralar Watcher"] = "辛德拉看守者";
	AL["Pylons"] = "水晶塔";
	AL["Ancient Equine Spirit"] = "上古聖馬之魂";
	AL["Shen'dralar Ancient"] = "辛德拉古靈";
	AL["Falrin Treeshaper"] = "法琳·樹形者";
	AL["Lorekeeper Lydros"] = "博學者萊德羅斯";
	AL["Lorekeeper Javon"] = "博學者亞沃";
	AL["Lorekeeper Kildrath"] = "博學者基爾達斯";
	AL["Lorekeeper Mykos"] = "博學者麥庫斯";
	AL["Shen'dralar Provisioner"] = "辛德拉聖職者";

	--Maraudon	
	AL["Elder Splitrock"] = "劈石長者";

	--Ragefire Chasm
	AL["Bovaal Whitehorn"] = "波瓦爾·白角";
	AL["Stone Guard Kurjack"] = "石衛士療舉";

	--Razorfen Downs
	AL["Koristrasza"] = "柯莉史卓莎";
	AL["Belnistrasz"] = "貝尼斯特拉茲";

	--Razorfen Kraul
	AL["Auld Stonespire"] = "奧爾德·石塔";
	AL["Razorfen Spearhide"] = "剃刀沼澤刺鬃守衛";
	AL["Spirit of Agamaggan <Ancient>"] = "阿迦瑪甘之靈 <先祖>";
	AL["Willix the Importer"] = "進口商威利克斯";

	--Ruins of Ahn'Qiraj
	AL["Four Kaldorei Elites"] = "四個卡多雷精英";
	AL["Captain Qeez"] = "奎茲上尉";
	AL["Captain Tuubid"] = "圖畢德上尉";
	AL["Captain Drenn"] = "德蘭上尉";
	AL["Captain Xurrem"] = "瑟瑞姆上尉";
	AL["Major Yeggeth"] = "葉吉斯少校";
	AL["Major Pakkon"] = "帕康少校";
	AL["Colonel Zerran"] = "澤朗上校";
	AL["Safe Room"] = "安全的空間";

	--Temple of Ahn'Qiraj
	AL["Andorgos <Brood of Malygos>"] = "安多葛斯 <瑪里苟斯的後裔>";
	AL["Vethsera <Brood of Ysera>"] = "溫瑟拉 <伊瑟拉的後裔>";
	AL["Kandrostrasz <Brood of Alexstrasza>"] = "坎多斯塔茲 <雅立史卓莎的後裔>";
	AL["Arygos"] = "亞雷戈斯";
	AL["Caelestrasz"] = "凱雷斯特拉茲";
	AL["Merithra of the Dream"] = "夢境之龍麥琳瑟拉";

	--Wailing Caverns
	AL["Disciple of Naralex"] = "納拉雷克斯的信徒";

	--Zul'Farrak
	AL["Chief Engineer Bilgewhizzle <Gadgetzan Water Co.>"] = "首席工程師膨嘯 <加基森水業公司>";
	AL["Mazoga's Spirit"] = "瑪柔伽的靈魂";
	AL["Tran'rek"] = "特蘭雷克";
	AL["Weegli Blastfuse"] = "維格利";
	AL["Raven"] = "拉文";
	AL["Elder Wildmane"] = "蠻鬃長者";

--****************************
-- Eastern Kingdoms Instances (Classic)
--****************************

	--Blackrock Depths
	AL["Relic Coffer Key"] = "古物寶庫鑰匙";
	AL["Dark Keeper Key"] = "黑暗守衛者鑰匙";
	AL["The Black Anvil"] = "黑鐵砧";
	AL["The Vault"] = "地窖";
	AL["Watchman Doomgrip"] = "衛兵杜格瑞普";
	AL["High Justice Grimstone"] = "裁決者格里斯通";
	AL["Elder Morndeep"] = "深晨長者";
	AL["Schematic: Field Repair Bot 74A"] = "結構圖:戰地修理機器人74A型";
	AL["Private Rocknot"] = "羅克諾特下士";
	AL["Mistress Nagmara"] = "娜瑪拉小姐";
	AL["Summoner's Tomb"] = "召喚者之墓";
	AL["Jalinda Sprig <Morgan's Militia>"] = "加琳達 <摩根的民兵>";
	AL["Oralius <Morgan's Militia>"] = "奧拉留斯 <摩根的民兵>";
	AL["Thal'trak Proudtusk <Kargath Expeditionary Force>"] = "薩特拉克·長齒 <卡加斯遠征軍>";
	AL["Galamav the Marksman <Kargath Expeditionary Force>"] = "『神射手』賈拉瑪弗 <卡加斯遠征軍>";
	AL["Maxwort Uberglint"] = "麥克斯沃特·尤柏格林";
	AL["Tinkee Steamboil"] = "丁奇·斯迪波爾";
	AL["Yuka Screwspigot <Engineering Supplies>"] = "尤卡·斯庫比格特 <工程學供應商>";
	AL["Abandonded Mole Machine"] = "棄置的鑽地機";
	AL["Kevin Dawson <Morgan's Militia>"] = "凱文·多森 <摩根的民兵>";
	AL["Lexlort <Kargath Expeditionary Force>"] = "雷克斯洛特 <卡加斯遠征軍>";
	AL["Prospector Seymour <Morgan's Militia>"] = "勘查員希摩爾 <摩根的民兵>";
	AL["Razal'blade <Kargath Expeditionary Force>"] = "拉札布雷德 <卡加斯遠征軍>";
	AL["The Shadowforge Lock"] = "暗爐之鎖";
	AL["Mayara Brightwing <Morgan's Militia>"] = "瑪亞拉·亮翼 <摩根的民兵>";
	AL["Hierophant Theodora Mulvadania <Kargath Expeditionary Force>"] = "祭師塞朵拉·穆瓦丹尼 <卡加斯遠征軍>";
	AL["Lokhtos Darkbargainer <The Thorium Brotherhood>"] = "羅克圖斯·暗契 <瑟銀兄弟會>";
	AL["Mountaineer Orfus <Morgan's Militia>"] = "巡山人歐弗斯 <摩根的民兵>";
	AL["Thunderheart <Kargath Expeditionary Force>"] = "桑德哈特 <卡加斯遠征軍>";
	AL["Marshal Maxwell <Morgan's Militia>"] = "麥斯威爾元帥 <摩根的民兵>";
	AL["Warlord Goretooth <Kargath Expeditionary Force>"] = "督軍高圖斯 <卡加斯遠征軍>";
	AL["The Black Forge"] = "黑熔爐";
	AL["Core Fragment"] = "熔核碎片";
	AL["Shadowforge Brazier"] = "暗爐火盆";

	--Blackrock Spire (Lower)
	AL["Urok's Tribute Pile"] = "烏洛克的貢品堆";
	AL["Acride <Scarshield Legion>"] = "裂盾滲透者 <裂盾軍團>";
	AL["Elder Stonefort"] = "石壘長者";
	AL["Roughshod Pike"] = "尖銳長矛";

	--Blackrock Spire (Upper)
	AL["Finkle Einhorn"] = "芬克·恩霍爾";
	AL["Drakkisath's Brand"] = "達基薩斯徽記";
	AL["Father Flame"] = "烈焰之父";

	--Blackwing Lair
	AL["Orb of Domination"] = "統禦寶珠";
	AL["Master Elemental Shaper Krixix"] = "大元素師克里希克";

	--Gnomeregan
	AL["Chomper"] = "咀嚼者";
	AL["Blastmaster Emi Shortfuse"] = "爆破專家艾米·短線";
	AL["Murd Doc <S.A.F.E.>"] = "哮·狼的護腿 <S.A.F.E.>";
	AL["Tink Sprocketwhistle <Engineering Supplies>"] = "丁克·鐵哨 <工程學供應商>";
	AL["The Sparklematic 5200"] = "超級清潔器5200型！";
	AL["Mail Box"] = "鎖甲箱";
	AL["B.E Barechus <S.A.F.E.>"] = "怪怪頭 <S.A.F.E.>";
	AL["Face <S.A.F.E.>"] = "小白臉 <S.A.F.E.>";
	AL["Hann Ibal <S.A.F.E.>"] = "漢·泥巴 <S.A.F.E.>";

	--Molten Core

	--Scholomance
	AL["Blood of Innocents"] = "鑰匙: 無辜者之血";
	AL["Divination Scryer"] = "鑰匙: 預言水晶球";
	AL["Alexi Barov <House of Barov>"] = "阿萊克斯·巴羅夫 <巴羅夫家族>";
	AL["Weldon Barov <House of Barov>"] = "維爾頓·巴羅夫 <巴羅夫家族>";
	AL["Eva Sarkhoff"] = "伊娃·薩克霍夫";
	AL["Lucien Sarkhoff"] = "盧森·薩克霍夫";
	AL["The Deed to Caer Darrow"] = "凱爾達隆地契";
	AL["The Deed to Southshore"] = "南海鎮地契";
	AL["Torch Lever"] = "火炬";
	AL["The Deed to Tarren Mill"] = "塔倫米爾地契";
	AL["The Deed to Brill"] = "布瑞爾地契";

	--Shadowfang Keep 影牙城堡
	AL["Apothecary Trio"] = "藥劑師三人組";
	AL["Apothecary Hummel <Crown Chemical Co.>"] = "藥劑師胡默爾 <王冠化學製藥公司>";
	AL["Apothecary Baxter <Crown Chemical Co.>"] = "藥劑師巴克斯特 <王冠化學製藥公司>";
	AL["Apothecary Frye <Crown Chemical Co.>"] = "藥劑師弗萊伊 <王冠化學製藥公司>";
	AL["Packleader Ivar Bloodfang"] = "狼群首領伊瓦·血牙";
	AL["Deathstalker Commander Belmont"] = "亡靈哨兵指揮官貝爾蒙特";
	AL["Haunted Stable Hand"] = "鬼怪獸欄僕人";
	AL["Investigator Fezzen Brasstacks"] = "調查員菲贊·銅釘";

	--SM: Armory
	AL["Joseph the Crazed"] = "發瘋的約瑟夫";
	AL["Dark Ranger Velonara"] = "黑暗遊俠薇蘿娜拉";
	AL["Dominic"] = "多明尼克";

	--SM: Cathedral
	AL["Cathedral"] = "大教堂"; -- Subzone of Scarlet Monastery
	AL["Joseph the Insane <Scarlet Champion>"] = "瘋掉的約瑟夫 <血色勇士>";

	--SM: Graveyard
	AL["Vorrel Sengutz"] = "沃瑞爾·森古斯";
	AL["Pumpkin Shrine"] = "無頭騎士南瓜";
	AL["Joseph the Awakened"] = "甦醒的約瑟夫";

	--SM: Library
	AL["Library"] = "圖書館"; -- The Library appeared in the Dire Maul and Scarlet Monastery
	AL["Compendium of the Fallen"] = "墮落者綱要";

	--Stratholme - Crusader's Square
	AL["Various Postbox Keys"] = "郵箱鑰匙";
	AL["Crusade Commander Eligor Dawnbringer <Brotherhood of the Light>"] = "指揮官艾利格·黎明使者 <聖光兄弟會>";
	AL["Master Craftsman Wilhelm <Brotherhood of the Light>"] = "工匠大師維爾海姆 <聖光兄弟會>";
	AL["Packmaster Stonebruiser <Brotherhood of the Light>"] = "軍需籌備官石漢 <聖光兄弟會>";
	AL["Stratholme Courier"] = "斯坦索姆信差";
	AL["Fras Siabi's Postbox"] = "弗拉斯·希亞比的郵箱";
	AL["King's Square Postbox"] = "國王廣場郵箱";
	AL["Festival Lane Postbox"] = "節日小道郵箱";
	AL["Elder Farwhisper"] = "遙語長者";
	AL["Market Row Postbox"] = "市場郵箱";
	AL["Crusaders' Square Postbox"] = "十字軍廣場郵箱";

	--Stratholme - The Gauntlet
	AL["Elders' Square Postbox"] = "長者廣場郵箱";
	AL["Archmage Angela Dosantos <Brotherhood of the Light>"] = "大法師安琪拉·多桑杜 <聖光兄弟會>";
	AL["Crusade Commander Korfax <Brotherhood of the Light>"] = "『聖光勇士』柯菲斯 <聖光兄弟會>";

	--The Deadmines
	AL["Lumbering Oaf"] = "笨重的歐弗";
	AL["Lieutenant Horatio Laine"] = "何瑞修·萊恩中尉";
	AL["Kagtha"] = "卡格薩";
	AL["Slinky Sharpshiv"] = "史琳琪·利刀";
	AL["Quartermaster Lewis <Quartermaster>"] = "軍需官路易斯 <軍需官>";
	AL["Miss Mayhem"] = "暴行小姐";
	AL["Vend-O-Tron D-Luxe"] = "高級自動販賣機";

	--The Stockade
	AL["Rifle Commander Coe"] = "步槍指揮官寇伊";
	AL["Warden Thelwater"] = "典獄官塞爾沃特";
	AL["Nurse Lillian"] = "護士莉蓮";

	--The Sunken Temple
	AL["Lord Itharius"] = "伊薩里奧斯領主";
	AL["Elder Starsong"] = "星歌長者";

	--Uldaman
	AL["Staff of Prehistoria"] = "史前法杖";
	AL["Baelog's Chest"] = "巴爾洛戈的箱子";
	AL["Kand Sandseeker <Explorer's League>"] = "坎德·覓沙 <探險者協會>";
	AL["Lead Prospector Durdin <Explorer's League>"] = "首席勘察員杜爾丁 <探險者協會>";
	AL["Olga Runesworn <Explorer's League>"] = "歐嘉·符誓 <探險者協會>";
	AL["Aoren Sunglow <The Reliquary>"] = "安歐連·日耀";
	AL["High Examiner Tae'thelan Bloodwatcher <The Reliquary>"] = "高階審查員泰瑟連·血腥看守者 <聖匣守護者>";
	AL["Lidia Sunglow <The Reliquary>"] = "莉蒂雅·日耀";
	AL["Ancient Treasure"] = "古代寶藏";
	AL["The Discs of Norgannon"] = "諾甘農圓盤";

--*******************
-- Burning Crusade Instances
--*******************

	--Auch: Auchenai Crypts
	AL["Auchenai Key"] = "奧奇奈鑰匙";
	AL["Avatar of the Martyred"] = "馬丁瑞德的化身";
	AL["D'ore"] = "迪歐瑞";

	--Auch: Mana-Tombs
	AL["The Eye of Haramad"] = "哈拉瑪德之眼";
	AL["Shadow Lord Xiraxis"] = "暗影領主希瑞西斯";
	AL["Ambassador Pax'ivi"] = "帕克西維大使";
	AL["Cryo-Engineer Sha'heen"] = "工程師薩希恩";
	AL["Ethereal Transporter Control Panel"] = "虛空傳送者控制面板";

	--Auch: Sethekk Halls
	AL["Lakka"] = "拉卡";
	AL["The Saga of Terokk"] = "泰洛克的傳說";

	--Auch: Shadow Labyrinth
	AL["The Codex of Blood"] = "血之聖典";
	AL["First Fragment Guardian"] = "第一碎片守衛者";
	AL["Spy To'gun"] = "間諜·吐剛";

	--Black Temple (Start)
	AL["Towards Reliquary of Souls"] = "通往靈魂聖盒";
	AL["Towards Teron Gorefiend"] = "通往泰朗·血魔";
	AL["Towards Illidan Stormrage"] = "通往伊利丹";
	AL["Spirit of Olum"] = "歐蘭的靈魂";
	AL["Spirit of Udalo"] = "烏達羅之靈";
	AL["Aluyen <Reagents>"] = "阿魯焰 <施法材料>";
	AL["Okuno <Ashtongue Deathsworn Quartermaster>"] = "歐庫諾 <灰舌死亡誓言者軍需官>";
	AL["Seer Kanai"] = "先知卡奈";

	--Black Temple (Basement)

	--Black Temple (Top)

	--CFR: Serpentshrine Cavern
	AL["Seer Olum"] = "先知歐蘭";

	--CFR: The Slave Pens
	AL["Reservoir Key"] = "蓄湖之鑰";
	AL["Weeder Greenthumb"] = "威德·綠指";
	AL["Skar'this the Heretic"] = "異教徒司卡利斯";
	AL["Naturalist Bite"] = "博物學家·拜特";

	--CFR: The Steamvault
	AL["Main Chambers Access Panel"] = "主房間通道面板";
	AL["Second Fragment Guardian"] = "第二碎片守衛者";

	--CFR: The Underbog
	AL["The Underspore"] = "地孢";
	AL["Earthbinder Rayge"] = "縛地者瑞吉";

	--CoT: The Black Morass
	AL["Opening of the Dark Portal"] = "開啟黑暗之門";
	AL["Key of Time"] = "時光之鑰";
	AL["Sa'at <Keepers of Time>"] = "塞特 <時光守望者>";
	AL["The Dark Portal"] = "黑暗之門";

	--CoT: Hyjal Summit
	AL["Battle for Mount Hyjal"] = "海加爾山戰場";
	AL["Alliance Base"] = "聯盟營地";
	AL["Lady Jaina Proudmoore"] = "珍娜·普勞德摩爾女士";
	AL["Horde Encampment"] = "部落營地";
	AL["Thrall <Warchief>"] = "索爾 <首領>";
	AL["Night Elf Village"] = "夜精靈村";
	AL["Tyrande Whisperwind <High Priestess of Elune>"] = "泰蘭妲·語風 <伊露恩的高階女祭司>";

	--CoT: Old Hillsbrad Foothills
	AL["Escape from Durnholde Keep"] = "逃離敦霍爾德";
	AL["Erozion"] = "伊洛森";
	AL["Brazen"] = "布瑞茲恩";
	AL["Landing Spot"] = "降落點";
	AL["Thrall"] = "索爾";
	AL["Taretha"] = "塔蕾莎";
	AL["Don Carlos"] = "卡洛斯大爺";
	AL["Guerrero"] = "葛雷洛";
	AL["Thomas Yance <Travelling Salesman>"] = "湯瑪斯·陽斯 <旅行商人>";
	AL["Aged Dalaran Wizard"] = "年邁的達拉然法師";
	AL["Jonathan Revah"] = "強納森·瑞瓦";
	AL["Jerry Carter"] = "傑瑞·卡特";
	AL["Helcular"] = "赫爾庫拉";
	AL["Farmer Kent"] = "農夫肯特";
	AL["Sally Whitemane"] = "莎麗·白鬃";
	AL["Renault Mograine"] = "雷諾·莫根尼";
	AL["Little Jimmy Vishas"] = "小吉米·維希斯";
	AL["Herod the Bully"] = "流氓希洛特";
	AL["Nat Pagle"] = "納特·帕格";
	AL["Hal McAllister"] = "哈爾·馬克奧里斯特";
	AL["Zixil <Aspiring Merchant>"] = "吉克希爾 <高級商人>";
	AL["Overwatch Mark 0 <Protector>"] = "守候者零型 <保衛者>";
	AL["Southshore Inn"] = "南海鎮旅館";
	AL["Captain Edward Hanes"] = "隊長艾德華·漢尼斯";
	AL["Captain Sanders"] = "桑德斯船長";
	AL["Commander Mograine"] = "指揮官莫格萊尼";
	AL["Isillien"] = "伊斯利恩";
	AL["Abbendis"] = "阿比迪斯";
	AL["Fairbanks"] = "費爾班克";
	AL["Taelan"] = "泰蘭";
	AL["Barkeep Kelly <Bartender>"] = "酒吧老闆凱利 <酒保>";
	AL["Frances Lin <Barmaid>"] = "法蘭斯·林 <酒吧女服務員>";
	AL["Chef Jessen <Speciality Meat & Slop>"] = "廚師傑森 <特殊肉品和食物>";
	AL["Stalvan Mistmantle"] = "斯塔文·密斯特曼托";
	AL["Phin Odelic <The Kirin Tor>"] = "費恩·奧德利克 <祈倫托>";
	AL["Magistrate Henry Maleb"] = "赫尼·馬雷布鎮長";
	AL["Raleigh the True"] = "純真者洛歐欸";
	AL["Nathanos Marris"] = "納薩諾斯·瑪瑞斯";
	AL["Bilger the Straight-laced"] = "嚴厲者畢歐吉";
	AL["Innkeeper Monica"] = "旅店老闆莫妮卡";
	AL["Julie Honeywell"] = "喬莉·哈妮威爾";
	AL["Jay Lemieux"] = "杰·黎米厄斯";
	AL["Young Blanchy"] = "小馬布蘭契";

	--Gruul's Lair

	--HFC: The Blood Furnace
	AL["Flamewrought Key"] = "火鑄之鑰";

	--HFC: Hellfire Ramparts
	AL["Reinforced Fel Iron Chest"] = "強化惡魔鐵箱";

	--HFC: Magtheridon's Lair

	--HFC: The Shattered Halls
	AL["Shattered Hand Executioner"] = "破碎之手劊子手";
	AL["Private Jacint"] = "士兵賈辛特";
	AL["Rifleman Brownbeard"] = "槍兵伯朗畢爾";
	AL["Captain Alina"] = "隊長阿蓮娜";
	AL["Scout Orgarr"] = "斥候歐卡爾";
	AL["Korag Proudmane"] = "科洛特·波特曼";
	AL["Captain Boneshatter"] = "隊長碎骨";
	AL["Randy Whizzlesprocket"] = "藍迪·威索洛克";
	AL["Drisella"] = "崔賽拉";

	--Karazhan Start
	AL["The Master's Key"] = "主人鑰匙";
	AL["Baroness Dorothea Millstipe"] = "女爵朵洛希·米爾斯泰普";
	AL["Lady Catriona Von'Indi"] = "凱崔娜·瓦映迪女士";
	AL["Lady Keira Berrybuck"] = "凱伊拉·拜瑞巴克女士";
	AL["Baron Rafe Dreuger"] = "男爵洛夫·崔克爾";
	AL["Lord Robin Daris"] = "貴族羅賓·達利斯";
	AL["Lord Crispin Ference"] = "貴族克利斯平·費蘭斯";
	AL["Red Riding Hood"] = "小紅帽";
	AL["Wizard of Oz"] = "綠野仙蹤";
	AL["The Master's Terrace"] = "大師的露臺";
	AL["Servant Quarters"] = "伺從區";
	AL["Hastings <The Caretaker>"] = "哈斯丁 <照料者>";
	AL["Berthold <The Doorman>"] = "勃特霍德 <看門人>";
	AL["Calliard <The Nightman>"] = "卡利卡 <夜間工作者>";
	AL["Koren <The Blacksmith>"] = "卡爾侖 <鐵匠>";
	AL["Bennett <The Sergeant at Arms>"] = "班尼特 <待命中的中士>";
	AL["Keanna's Log"] = "琪安娜的日誌";
	AL["Ebonlocke <The Noble>"] = "埃伯洛克 <貴族>";
	AL["Sebastian <The Organist>"] = "塞巴斯汀 <風琴演奏家>";
	AL["Barnes <The Stage Manager>"] = "巴奈斯 <舞台管理員>";

	--Karazhan End
	AL["Path to the Broken Stairs"] = "通往損壞的階梯的通道";
	AL["Broken Stairs"] = "損壞的階梯";
	AL["Ramp to Guardian's Library"] = "通往管理員圖書館的斜坡";
	AL["Suspicious Bookshelf"] = "神秘的書架";
	AL["Ramp up to the Celestial Watch"] = "通往天文觀測台的斜坡";
	AL["Ramp down to the Gamesman's Hall"] = "通往投機者大廳的斜坡";
	AL["Ramp to Medivh's Chamber"] = "通往麥迪文房間的斜坡";
	AL["Spiral Stairs to Netherspace"] = "通往虛空空間的螺旋梯";
	AL["Wravien <The Mage>"] = "瑞依恩 <法師>";
	AL["Gradav <The Warlock>"] = "葛瑞戴 <術士>";
	AL["Kamsis <The Conjurer>"] = "康席斯 <咒術師>";
	AL["Ythyar"] = "伊斯亞爾";
	AL["Echo of Medivh"] = "麥迪文的回音";

	--Magisters Terrace
	AL["Fel Crystals"] = "惡魔水晶";
	AL["Apoko"] = "阿波考";
	AL["Eramas Brightblaze"] = "依拉瑪·火光";
	AL["Ellrys Duskhallow"] = "艾爾里斯·聖暮";
	AL["Fizzle"] = "費索";
	AL["Garaxxas"] = "卡拉克薩斯";
	AL["Sliver <Garaxxas' Pet>"] = "割裂者 <卡拉克薩斯的寵物>";
	AL["Kagani Nightstrike"] = "卡嘉尼·夜擊";
	AL["Warlord Salaris"] = "督軍沙拉利思";
	AL["Yazzai"] = "耶賽";
	AL["Zelfan"] = "塞爾汎";
	AL["Tyrith"] = "提里斯";
	AL["Scrying Orb"] = "索蘭尼亞的占卜寶珠";

	--Sunwell Plateau
	AL["Madrigosa"] = "瑪德里茍沙";

	--TK: The Arcatraz
	AL["Warpforged Key"] = "扭曲鍛造鑰匙";
	AL["Millhouse Manastorm"] = "米歐浩斯·曼納斯頓";
	AL["Third Fragment Guardian"] = "第三碎片守衛者";
	AL["Udalo"] = "先知烏達羅";

	--TK: The Botanica

	--TK: The Mechanar
	AL["Overcharged Manacell"] = "滿溢的法力容器";

	--TK: The Eye

	--Zul'Aman
	AL["Harrison Jones"] = "哈利森·瓊斯";
	AL["Tanzar"] = "坦札爾";
	AL["The Map of Zul'Aman"] = "祖阿曼地圖";
	AL["Harkor"] = "哈克爾";
	AL["Kraz"] = "卡拉茲";
	AL["Ashli"] = "阿西利";
	AL["Thurg"] = "瑟吉";
	AL["Gazakroth"] = "葛薩克羅司";
	AL["Lord Raadan"] = "領主雷阿登";
	AL["Darkheart"] = "黑心";
	AL["Alyson Antille"] = "艾利森·安第列";
	AL["Slither"] = "史立塞";
	AL["Fenstalker"] = "沼群巡者";
	AL["Koragg"] = "可拉格";
	AL["Zungam"] = "祖剛";
	AL["Forest Frogs"] = "森林樹蛙";
	AL["Kyren <Reagents>"] = "凱倫 <施法材料>";
	AL["Gunter <Food Vendor>"] = "甘特 <食物商人>";
	AL["Adarrah"] = "阿達拉";
	AL["Brennan"] = "布里納";
	AL["Darwen"] = "達爾溫";
	AL["Deez"] = "迪滋";
	AL["Galathryn"] = "加拉瑟林";
	AL["Mitzi"] = "米特辛";
	AL["Mannuth"] = "曼努斯";

--*****************
-- WotLK Instances
--*****************

	--Azjol-Nerub: Ahn'kahet: The Old Kingdom
	AL["Ahn'kahet Brazier"] = "安卡罕特火盆";

	--Azjol-Nerub: Azjol-Nerub
	AL["Watcher Gashra"] = "看守者賈西拉";
	AL["Watcher Narjil"] = "看守者納吉爾";
	AL["Watcher Silthik"] = "看守者席爾希克";
	AL["Elder Nurgen"] = "訥金長者";

	--Caverns of Time: The Culling of Stratholme
	AL["The Culling of Stratholme"] = "斯坦索姆的抉擇";
	AL["Scourge Invasion Points"] = "天譴軍團地點";
	AL["Guardian of Time"] = "時光守護者";
	AL["Chromie"] = "克羅米";

	--Drak'Tharon Keep
	AL["Kurzel"] = "庫賽爾";
	AL["Elder Kilias"] = "奇里亞斯長者";
	AL["Drakuru's Brazier"] = "德拉庫魯的火盆";

	--The Frozen Halls: Halls of Reflection
	--3 beginning NPCs omitted, see The Forge of Souls
	AL["Wrath of the Lich King"] = "巫妖王之怒";
	AL["The Captain's Chest"] = "船長的箱子";

	--The Frozen Halls: Pit of Saron
	--6 beginning NPCs omitted, see The Forge of Souls
	AL["Martin Victus"] = "馬汀·維特斯";
	AL["Gorkun Ironskull"] = "葛剛·鐵顱";
	AL["Rimefang"] = "霜牙";

	--The Frozen Halls: The Forge of Souls
	--Lady Jaina Proudmoore omitted, in Hyjal Summit
	AL["Archmage Koreln <Kirin Tor>"] = "大法師寇瑞倫 <祈倫托>";
	AL["Archmage Elandra <Kirin Tor>"] = "大法師伊蘭卓 <祈倫托>";
	AL["Lady Sylvanas Windrunner <Banshee Queen>"] = "希瓦娜斯·風行者女士 <女妖之王>";
	AL["Dark Ranger Loralen"] = "黑暗遊俠洛拉倫";
	AL["Dark Ranger Kalira"] = "黑暗遊俠卡麗菈";

	--Gundrak
	AL["Elder Ohanzee"] = "歐漢茲長者";

	--Icecrown Citadel
	AL["To next map"] = "到下一個地圖";
	AL["From previous map"] = "到前一個地圖";
	AL["Upper Spire"] = "冰冠尖塔";
	AL["Sindragosa's Lair"] = "辛德拉苟莎之巢";
	AL["Stinky"] = "臭皮";
	AL["Precious"] = "普萊瑟斯";

	--Naxxramas
	AL["Mr. Bigglesworth"] = "畢勾沃斯先生";
	AL["Frostwyrm Lair"] = "冰霜巨龍的巢穴";
	AL["Teleporter to Middle"] = "傳送到中間的傳送門"; -- Needs review

	--The Obsidian Sanctum
	AL["Black Dragonflight Chamber"] = "黑龍軍團密室";

	--Onyxia's Lair

	--The Ruby Sanctum
	AL["Red Dragonflight Chamber"] = "紅龍軍團密室";

	--The Nexus: The Eye of Eternity
	AL["Key to the Focusing Iris"] = "聚源虹膜之鑰";

	--The Nexus: The Nexus
	AL["Berinand's Research"] = "貝瑞那德的研究";
	AL["Elder Igasho"] = "伊加修長者";

	--The Nexus: The Oculus
	AL["Centrifuge Construct"] = "離心傀儡";
	AL["Cache of Eregos"] = "伊瑞茍斯的貯藏箱";	

	--Trial of the Champion
	AL["Champions of the Alliance"] = "聯盟大勇士";
	AL["Marshal Jacob Alerius"] = "傑科布·亞雷瑞斯元帥";
	AL["Ambrose Boltspark"] = "安布羅斯·拴炫";
	AL["Colosos"] = "克羅索斯";
	AL["Jaelyne Evensong"] = "潔琳·晚歌";
	AL["Lana Stouthammer"] = "菈娜·頑錘";
	AL["Champions of the Horde"] = "部落大勇士";

	--Trial of the Crusader
	AL["Heroic: Trial of the Grand Crusader"] = "英雄: 大十字軍試煉";
	AL["Cavern Entrance"] = "洞穴入口";

	--Ulduar General
	AL["Celestial Planetarium Key"] = "星穹渾天儀之鑰";
	AL["The Siege"] = "攻城區";
	AL["The Keepers"] = "守護者"

	--Ulduar A
	AL["Tower of Life"] = "生命之塔";
	AL["Tower of Flame"] = "烈焰之塔";
	AL["Tower of Frost"] = "冰霜之塔";
	AL["Tower of Storms"] = "風暴之塔";

	--Ulduar B
	AL["Prospector Doren"] = "勘察員多倫";
	AL["Archivum Console"] = "大資料庫控制臺";

	--Ulduar C
	AL["Sif"] = "希芙";

	--Ulduar D

	--Ulduar E

	--Ulduar: Halls of Lightning

	--Ulduar: Halls of Stone
	AL["Tribunal Chest"] = "議庭之箱";
	AL["Elder Yurauk"] = "由羅克長者";	
	AL["Brann Bronzebeard"] = "布萊恩·銅鬚";

	--Utgarde Keep: Utgarde Keep
	AL["Dark Ranger Marrah"] = "黑暗遊俠瑪拉";
	AL["Elder Jarten"] = "加坦長者";

	--Utgarde Keep: Utgarde Pinnacle
	AL["Brigg Smallshanks"] = "布里格·細柄";
	AL["Elder Chogan'gada"] = "修干加達長者";

	--Vault of Archavon

	--The Violet Hold
	AL["The Violet Hold Key"] = "紫羅蘭堡鑰匙";

--*********************
-- Cataclysm Instances
--*********************

	--Abyssal Maw
	--AL["TBD"] = "TBD"; --To Be Determined

	--Baradin Hold

	--Blackrock Caverns

	--Blackwing Descent

	--Caverns of Time: War of the Ancients

	--Grim Batol
	AL["Baleflame"] = "罪火";
	AL["Farseer Tooranu <The Earthen Ring>"] = "先知圖拉奴 <陶土議會>";
	AL["Velastrasza"] = "維菈史卓莎";

	--Halls of Origination

	--Lost City of the Tol'vir
	AL["Captain Hadan"] = "哈丹隊長";
	AL["Augh"] = "奧各";

	--Sulfuron Keep

	--The Bastion of Twilight

	--The Stonecore
	AL["Earthwarden Yrsa <The Earthen Ring>"] = "大地守望者伊爾薩 <陶土議會>";

	--The Vortex Pinnacle
	AL["Itesh"] = "伊塔許";

	--Throne of the Four Winds

	--Throne of the Tides
	AL["Captain Taylor"] = "泰勒隊長";
	AL["Legionnaire Nazgrim"] = "軍團士兵納茲格寧姆";
	AL["Neptulon"] = "奈普圖隆";

end
