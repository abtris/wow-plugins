-- $Id: Atlas-zhCN.lua 1213 2011-01-25 14:30:18Z arithmandar $
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
local AL = AceLocale:NewLocale("Atlas", "zhCN", false);

-- Atlas Localization Data (Chinese)
-- Initial translation by DiabloHu
-- Maintained by DiabloHu, arith
-- $Date: 2011-01-25 15:30:18 +0100 (Di, 25. Jan 2011) $
-- $Revision: 1213 $


if ( GetLocale() == "zhCN" ) then
-- Define the leading strings to be ignored while sorting
-- Ex: The Stockade
AtlasSortIgnore = {};

AtlasZoneSubstitutions = {
	["Ahn'Qiraj"] = "安其拉神殿";
	["The Temple of Atal'Hakkar"] = "沉没的神庙";
	["Old Hillsbrad Foothills"] = "时光之穴 - 旧希尔斯布莱德";
	["The Eye"] = "风暴要塞 - 风暴之眼";
};
end


if AL then
--************************************************
-- UI terms and common strings
--************************************************
	AL["ATLAS_TITLE"] = "Atlas";

	AL["BINDING_HEADER_ATLAS_TITLE"] = "Atlas 按键设置";
	AL["BINDING_NAME_ATLAS_TOGGLE"] = "开启/关闭 Atlas";
	AL["BINDING_NAME_ATLAS_OPTIONS"] = "切换设置";
	AL["BINDING_NAME_ATLAS_AUTOSEL"] = "自动选择";

	AL["ATLAS_SLASH"] = "/atlas";
	AL["ATLAS_SLASH_OPTIONS"] = "options";

	AL["ATLAS_STRING_LOCATION"] = "所属区域";
	AL["ATLAS_STRING_LEVELRANGE"] = "等级跨度";
	AL["ATLAS_STRING_PLAYERLIMIT"] = "人数上限";
	AL["ATLAS_STRING_SELECT_CAT"] = "选择分类";
	AL["ATLAS_STRING_SELECT_MAP"] = "选择地图";
	AL["ATLAS_STRING_SEARCH"] = "搜索";
	AL["ATLAS_STRING_CLEAR"] = "重置";
	AL["ATLAS_STRING_MINLEVEL"] = "需要等级";

	AL["ATLAS_OPTIONS_BUTTON"] = "设置";
	AL["ATLAS_OPTIONS_SHOWBUT"] = "在小地图周围显示Atlas图标";
	AL["ATLAS_OPTIONS_SHOWBUT_TIP"] = "在小地图旁显示 Atlas 按钮";
	AL["ATLAS_OPTIONS_AUTOSEL"] = "自动选择副本地图";
	AL["ATLAS_OPTIONS_AUTOSEL_TIP"] = "Atlas 可侦测您目前所在的副区域以判定您所在的副本, 开启 Atlas 时将会自动选择到该副本地图";
	AL["ATLAS_OPTIONS_BUTPOS"] = "图标位置";
	AL["ATLAS_OPTIONS_TRANS"] = "透明度";
	AL["ATLAS_OPTIONS_RCLICK"] = "点击右键打开世界地图";
	AL["ATLAS_OPTIONS_RCLICK_TIP"] = "启用在 Atlas 窗口中按下鼠标右键自动切换到魔兽的世界地图";
	AL["ATLAS_OPTIONS_RESETPOS"] = "重置位置";
	AL["ATLAS_OPTIONS_ACRONYMS"] = "显示简称";
	AL["ATLAS_OPTIONS_ACRONYMS_TIP"] = "在地图的详尽叙述中显示副本的缩写";
	AL["ATLAS_OPTIONS_SCALE"] = "窗口大小";
	AL["ATLAS_OPTIONS_BUTRAD"] = "图标半径";
	AL["ATLAS_OPTIONS_CLAMPED"] = "使 Atlas 不超出游戏画面";
	AL["ATLAS_OPTIONS_CLAMPED_TIP"] = "使 Atlas 窗口被拖曳时不会超出游戏主画面的边界, 关闭此选项则可将 Atlas 窗口拖曳并超出游戏画面边界";
	AL["ATLAS_OPTIONS_CTRL"] = "弹出工具说明 (按住CTRL指向内容)";
	AL["ATLAS_OPTIONS_CTRL_TIP"] = "勾选后, 当鼠标移到地图信息字段时, 按下 Ctrl 控制键, 则会将信息的完整信息以提示型态显示. 当信息过长而被截断时很有用.";

	AL["ATLAS_BUTTON_TOOLTIP_TITLE"] = "Atlas";
	AL["ATLAS_BUTTON_TOOLTIP_HINT"] = "单击打开 Atlas\n中键单击打开设置\n按住右键可移动这个按钮";
	AL["ATLAS_LDB_HINT"] = "单击打开 Atlas\n右键点击打开设置";

	AL["ATLAS_OPTIONS_CATDD"] = "副本地图排序方式";
	AL["ATLAS_DDL_CONTINENT"] = "所属大陆";
	AL["ATLAS_DDL_CONTINENT_EASTERN"] = "东部王国副本";
	AL["ATLAS_DDL_CONTINENT_KALIMDOR"] = "卡利姆多副本";
	AL["ATLAS_DDL_CONTINENT_OUTLAND"] = "外域副本";
	AL["ATLAS_DDL_CONTINENT_NORTHREND"] = "诺森德副本";
	AL["ATLAS_DDL_CONTINENT_DEEPHOLM"] = "地深之源副本"; -- Needs review
	AL["ATLAS_DDL_LEVEL"] = "副本等级";
	AL["ATLAS_DDL_LEVEL_UNDER45"] = "45 级以下副本";
	AL["ATLAS_DDL_LEVEL_45TO60"] = "45-60 级副本";
	AL["ATLAS_DDL_LEVEL_60TO70"] = "60-70 级副本";
	AL["ATLAS_DDL_LEVEL_70TO80"] = "70-80 级副本";
	AL["ATLAS_DDL_LEVEL_80TO85"] = "80-85 级副本";
	AL["ATLAS_DDL_LEVEL_85PLUS"] = "85 级以上副本";
	AL["ATLAS_DDL_PARTYSIZE"] = "副本规模";
	AL["ATLAS_DDL_PARTYSIZE_5_AE"] = "5 人副本 (第一页)";
	AL["ATLAS_DDL_PARTYSIZE_5_FS"] = "5 人副本 (第二页)";
	AL["ATLAS_DDL_PARTYSIZE_5_TZ"] = "5 人副本 (第三页)";
	AL["ATLAS_DDL_PARTYSIZE_10_AN"] = "10 人副本 (第一页)";
	AL["ATLAS_DDL_PARTYSIZE_10_OZ"] = "10 人副本 (第二页)";
	AL["ATLAS_DDL_PARTYSIZE_20TO40"] = "20-40 人副本";
	AL["ATLAS_DDL_EXPANSION"] = "资料片";
	AL["ATLAS_DDL_EXPANSION_OLD_AO"] = "旧世界副本 (第一页)";
	AL["ATLAS_DDL_EXPANSION_OLD_PZ"] = "旧世界副本 (第二页)";
	AL["ATLAS_DDL_EXPANSION_BC"] = "《燃烧的远征》副本";
	AL["ATLAS_DDL_EXPANSION_WOTLK"] = "《巫妖王之怒》副本";
	AL["ATLAS_DDL_EXPANSION_CATA"] = "《大灾变》副本";
	AL["ATLAS_DDL_TYPE"] = "类型";
	AL["ATLAS_DDL_TYPE_INSTANCE_AC"] = "副本 (第一页)";
	AL["ATLAS_DDL_TYPE_INSTANCE_DR"] = "副本 (第二页)";
	AL["ATLAS_DDL_TYPE_INSTANCE_SZ"] = "副本 (第三页)";
	AL["ATLAS_DDL_TYPE_ENTRANCE"] = "入口";

	AL["ATLAS_INSTANCE_BUTTON"] = "副本";
	AL["ATLAS_ENTRANCE_BUTTON"] = "入口";
	AL["ATLAS_SEARCH_UNAVAIL"] = "搜索不可用";

	AL["ATLAS_DEP_MSG1"] = "检测到过期的 Atlas 扩展插件。";
	AL["ATLAS_DEP_MSG2"] = "这些插件已经被禁用。";
	AL["ATLAS_DEP_MSG3"] = "请从插件目录（AddOns）中将其删除。";
	AL["ATLAS_DEP_OK"] = "确定";

--************************************************
-- Zone Names, Acronyms, and Common Strings
--************************************************

	--Common strings
	AL["East"] = "东";
	AL["North"] = "北";
	AL["South"] = "南";
	AL["West"] = "西";

	--World Events, Festival
	AL["Brewfest"] = "美酒节";
	AL["Hallow's End"] = "万圣节";
	AL["Love is in the Air"] = "情人节";
	AL["Lunar Festival"] = "春节庆典";
	AL["Midsummer Festival"] = "仲夏火焰节";
	--Misc strings
	AL["Adult"] = "成年";
	AL["AKA"] = "亦作";
	AL["Arcane Container"] = "奥术容器";
	AL["Arms Warrior"] = "武器战士";
	AL["Attunement Required"] = "需要完成入口任务";
	AL["Back"] = "后门";
	AL["Basement"] = "底层";
	AL["Blacksmithing Plans"] = "锻造设计图";
	AL["Boss"] = "首领";
	AL["Chase Begins"] = "追捕开始";
	AL["Chase Ends"] = "追捕结束";
	AL["Child"] = "幼年";
	AL["Connection"] = "通道";
	AL["DS2"] = "地下城套装2";
	AL["Elevator"] = "升降梯";
	AL["End"] = "尾部";
	AL["Engineer"] = "工程师";
	AL["Entrance"] = "入口";
	AL["Event"] = "事件";
	AL["Exalted"] = "崇拜";
	AL["Exit"] = "出口";
	AL["Fourth Stop"] = "第四次止步";
	AL["Front"] = "前门";
	AL["Ghost"] = "幽灵";
	AL["Graveyard"] = "墓地";
	AL["Heroic"] = "英雄模式";
	AL["Holy Paladin"] = "神圣圣骑士";
	AL["Holy Priest"] = "神圣牧师";
	AL["Hunter"] = "猎人";
	AL["Imp"] = "小鬼";
	AL["Inside"] = "内部";
	AL["Key"] = "钥匙";
	AL["Lower"] = "下层";
	AL["Mage"] = "法师";
	AL["Meeting Stone"] = "集合石";
	AL["Middle"] = "中间";
	AL["Monk"] = "僧侣";
	AL["Moonwell"] = "月亮井";
	AL["Optional"] = "可跳过";
	AL["Orange"] = "橙色";
	AL["Outside"] = "室外";
	AL["Paladin"] = "圣骑士";
	AL["Portal"] = "传送";
	AL["Priest"] = "牧师";
	AL["Protection Warrior"] = "防护战士";
	AL["Purple"] = "紫色";
	AL["Random"] = "随机";
	AL["Rare"] = "稀有";
	AL["Reputation"] = "阵营";
	AL["Repair"] = "修理";
	AL["Retribution Paladin"] = "惩戒圣骑士";
	AL["Rewards"] = "奖励";
	AL["Rogue"] = "潜行者";
	AL["Second Stop"] = "第二次止步";
	AL["Shadow Priest"] = "暗影牧师";
	AL["Shaman"] = "萨满祭司";
	AL["Side"] = "旁门";
	AL["Spawn Point"] = "刷新点";
	AL["Start"] = "起始";
	AL["Summon"] = "召唤";
	AL["Teleporter"] = "传送";
	AL["Third Stop"] = "第三次止步";
	AL["Tiger"] = "猛虎";
	AL["Top"] = "顶层";
	AL["Underwater"] = "水下";
	AL["Unknown"] = "未知";
	AL["Upper"] = "上层";
	AL["Varies"] = "多个位置";
	AL["Wanders"] = "游荡";
	AL["Warlock"] = "术士";
	AL["Warrior"] = "战士";
	AL["Wave 5"] = "第5波";
	AL["Wave 6"] = "第6波";
	AL["Wave 10"] = "第10波";
	AL["Wave 12"] = "第12波";
	AL["Wave 18"] = "第18波";

	--Classic Acronyms
	AL["AQ"] = "AQ"; -- Ahn'Qiraj
	AL["AQ20"] = "AQ20"; -- Ruins of Ahn'Qiraj
	AL["AQ40"] = "AQ40"; -- Temple of Ahn'Qiraj
	AL["Armory"] = "Armory"; -- Armory
	AL["BFD"] = "BFD"; -- Blackfathom Deeps
	AL["BRD"] = "BRD"; -- Blackrock Depths
	AL["BRM"] = "BRM"; -- Blackrock Mountain
	AL["BWL"] = "BWL"; -- Blackwing Lair
	AL["Cath"] = "Cath"; -- Cathedral
	AL["DM"] = "DM"; -- Dire Maul
	AL["Gnome"] = "Gnome"; -- Gnomeregan
	AL["GY"] = "GY"; -- Graveyard
	AL["LBRS"] = "LBRS"; -- Lower Blackrock Spire
	AL["Lib"] = "Lib"; -- Library
	AL["Mara"] = "Mara"; -- Maraudon
	AL["MC"] = "MC"; -- Molten Core
	AL["RFC"] = "RFC"; -- Ragefire Chasm
	AL["RFD"] = "RFD"; -- Razorfen Downs
	AL["RFK"] = "RFK"; -- Razorfen Kraul
	AL["Scholo"] = "Scholo"; -- Scholomance
	AL["SFK"] = "SFK"; -- Shadowfang Keep
	AL["SM"] = "SM"; -- Scarlet Monastery
	AL["ST"] = "ST"; -- Sunken Temple
	AL["Strat"] = "Strat"; -- Stratholme
	AL["Stocks"] = "Stocks"; -- The Stockade
	AL["UBRS"] = "UBRS"; -- Upper Blackrock Spire
	AL["Ulda"] = "Ulda"; -- Uldaman
	AL["VC"] = "VC"; -- The Deadmines
	AL["WC"] = "WC"; -- Wailing Caverns
	AL["ZF"] = "ZF"; -- Zul'Farrak

	--BC Acronyms
	AL["AC"] = "AC"; -- Auchenai Crypts
	AL["Arca"] = "Arca"; -- The Arcatraz
	AL["Auch"] = "Auch"; -- Auchindoun
	AL["BF"] = "BF"; -- The Blood Furnace
	AL["BT"] = "BT"; -- Black Temple
	AL["Bota"] = "Bota"; -- The Botanica
	AL["CoT"] = "CoT"; -- Caverns of Time
	AL["CoT1"] = "CoT1"; -- Old Hillsbrad Foothills
	AL["CoT2"] = "CoT2"; -- The Black Morass
	AL["CoT3"] = "CoT3"; -- Hyjal Summit
	AL["CR"] = "CR"; -- Coilfang Reservoir
	AL["GL"] = "GL"; -- Gruul's Lair
	AL["HC"] = "HC"; -- Hellfire Citadel
	AL["Kara"] = "Kara"; -- Karazhan
	AL["MaT"] = "MT"; -- Magisters' Terrace
	AL["Mag"] = "Mag"; -- Magtheridon's Lair
	AL["Mech"] = "Mech"; -- The Mechanar
	AL["MT"] = "MT"; -- Mana-Tombs
	AL["Ramp"] = "Ramp"; -- Hellfire Ramparts
	AL["SC"] = "SC"; -- Serpentshrine Cavern
	AL["Seth"] = "Seth"; -- Sethekk Halls
	AL["SH"] = "SH"; -- The Shattered Halls
	AL["SL"] = "SL"; -- Shadow Labyrinth
	AL["SP"] = "SP"; -- The Slave Pens
	AL["SuP"] = "SP"; -- Sunwell Plateau
	AL["SV"] = "SV"; -- The Steamvault
	AL["TK"] = "TK"; -- Tempest Keep
	AL["UB"] = "UB"; -- The Underbog
	AL["ZA"] = "ZA"; -- Zul'Aman

	--WotLK Acronyms
	AL["AK, Kahet"] = "AK, 安卡"; -- Ahn'kahet
	AL["AN, Nerub"] = "AN, 艾卓"; -- Azjol-Nerub
	AL["Champ"] = "Champ, 试炼"; -- Trial of the Champion
	AL["CoT-Strat"] = "CoT-Strat"; -- Culling of Stratholme
	AL["Crus"] = "Crus, ToC"; -- Trial of the Crusader
	AL["DTK"] = "DTK"; -- Drak'Tharon Keep
	AL["FoS"] = "FoS"; 
	AL["FH1"] = "FH1"; -- The Forge of Souls
	AL["Gun"] = "Gun"; -- Gundrak
	AL["HoL"] = "HoL"; -- Halls of Lightning
	AL["HoR"] = "HoR"; 
	AL["FH3"] = "FH3"; -- Halls of Reflection
	AL["HoS"] = "HoS"; -- Halls of Stone
	AL["IC"] = "IC"; -- Icecrown Citadel
	AL["Nax"] = "Nax"; -- Naxxramas
	AL["Nex, Nexus"] = "Nex, Nexus"; -- The Nexus
	AL["Ocu"] = "Ocu"; -- The Oculus
	AL["Ony"] = "Ony"; -- Onyxia's Lair
	AL["OS"] = "OS"; -- The Obsidian Sanctum
	AL["PoS"] = "PoS"; 
	AL["FH2"] = "FH2"; -- Pit of Saron
	AL["RS"] = "RS"; -- The Ruby Sanctum
	AL["TEoE"] = "TEoE"; -- The Eye of Eternity
	AL["UK, Keep"] = "UK, Keep"; -- Utgarde Keep
	AL["Uldu"] = "Uldu"; -- Ulduar
	AL["UP, Pinn"] = "UP, Pinn"; -- Utgarde Pinnacle
	AL["VH"] = "VH"; -- The Violet Hold
	AL["VoA"] = "VoA"; -- Vault of Archavon

	--Zones not included in LibBabble-Zone
	AL["Crusaders' Coliseum"] = "十字军大竞技场";

--************************************************
-- Instance Entrance Maps
--************************************************

	--Auchindoun (Entrance)
	AL["Ha'Lei"] = "哈雷";
	AL["Greatfather Aldrimus"] = "奥德里姆斯宗父";
	AL["Clarissa"] = "克拉里萨";
	AL["Ramdor the Mad"] = "疯狂的拉姆杜尔";
	AL["Horvon the Armorer <Armorsmith>"] = "铸甲匠霍尔冯 <护甲锻造师>";
	AL["Nexus-Prince Haramad"] = "节点亲王哈拉迈德";
	AL["Artificer Morphalius"] = "工匠莫法鲁斯";
	AL["Mamdy the \"Ologist\""] = "“杂学家”玛姆迪";
	AL["\"Slim\" <Shady Dealer>"] = "“瘦子” <毒药商>";
	AL["\"Captain\" Kaftiz"] = "“上尉”卡弗提兹";
	AL["Isfar"] = "伊斯法尔";
	AL["Field Commander Mahfuun"] = "战地指挥官玛弗恩";
	AL["Spy Grik'tha"] = "间谍格利克萨";
	AL["Provisioner Tsaalt"] = "补给官塔萨尔特";
	AL["Dealer Tariq <Shady Dealer>"] = "商人塔利基 <毒药商>";

	--Blackfathom Deeps (Entrance)

	--Blackrock Mountain (Entrance)
	AL["Bodley"] = "伯德雷";
	AL["Lothos Riftwaker"] = "洛索斯·天痕";
	AL["Orb of Command"] = "命令宝珠";
	AL["Scarshield Quartermaster <Scarshield Legion>"] = "裂盾军需官 <裂盾军团>";
	AL["The Behemoth"] = "贝哈默斯";

	--Caverns of Time (Entrance)
	AL["Steward of Time <Keepers of Time>"] = "时间管理者 <时光守护者>";
	AL["Alexston Chrome <Tavern of Time>"] = "阿历克斯顿·克罗姆 <时间旅店>";
	AL["Yarley <Armorer>"] = "亚尔雷 <护甲商>";
	AL["Bortega <Reagents & Poison Supplies>"] = "波特加 <材料与毒药商>";
	AL["Alurmi <Keepers of Time Quartermaster>"] = "艾鲁尔米 <时光守护者军需官>";
	AL["Galgrom <Provisioner>"] = "加尔戈罗姆 <供给商人>";
	AL["Zaladormu"] = "扎拉多姆";
	AL["Soridormi <The Scale of Sands>"] = "索莉多米 <流沙之鳞>";
	AL["Arazmodu <The Scale of Sands>"] = "阿拉兹姆多 <流沙之鳞>";
	AL["Andormu <Keepers of Time>"] = "安多姆 <时光守护者>";
	AL["Nozari <Keepers of Time>"] = "诺萨莉 <时光守护者>";
	AL["Anachronos <Keepers of Time>"] = "阿纳克洛斯 <时光守护者>";

	--Caverns of Time: Hyjal (Entrance)
	AL["Indormi <Keeper of Ancient Gem Lore>"] = "因多米 <上古宝石保管者>";
	AL["Tydormu <Keeper of Lost Artifacts>"] = "泰多姆 <失落神器的保管者>";

	--Coilfang Reservoir (Entrance)
	AL["Watcher Jhang"] = "观察者杰哈恩";
	AL["Mortog Steamhead"] = "莫尔托格";

	--Dire Maul (Entrance)
	AL["Dire Pool"] = "厄运之池";
	AL["Dire Maul Arena"] = "厄运之槌竞技场";
	AL["Elder Mistwalker"] = "迷雾长者";

	--Gnomeregan (Entrance)
	AL["Torben Zapblast <Teleportation Specialist>"] = "托尔班•速轰 <传送专家>"; -- Needs review

	--Hellfire Citadel (Entrance)
	AL["Steps and path to the Blood Furnace"] = "通往鲜血熔炉的阶梯与通道";
	AL["Path to the Hellfire Ramparts and Shattered Halls"] = "通往地狱火城墙与破碎大厅的通道";
	AL["Meeting Stone of Magtheridon's Lair"] = "集合石 - 玛瑟里顿的巢穴";
	AL["Meeting Stone of Hellfire Citadel"] = "集合石 - 地狱火堡垒";

	--Icecrown Citadel (Entrance)

	--Karazhan (Entrance)
	AL["Archmage Leryda"] = "大法师蕾尔达";
	AL["Archmage Alturus"] = "大法师奥图鲁斯";
	AL["Apprentice Darius"] = "学徒达里乌斯";
	AL["Stairs to Underground Pond"] = "通往地下水池的楼梯";
	AL["Stairs to Underground Well"] = "通往地下水井的楼梯";
	AL["Charred Bone Fragment"] = "焦骨碎块";

	--Maraudon (Entrance)
	AL["The Nameless Prophet"] = "无名预言者";

	--Scarlet Monastery (Entrance)

	--The Deadmines (Entrance)

	--Sunken Temple (Entrance)
	AL["Priestess Udum'bra"] = "女祭师乌丹姆布拉";	-- Needs review after Cataclysm is available in China
	AL["Gomora the Bloodletter"] = "『放血者』高摩拉";	-- Needs review after Cataclysm is available in China

	--Uldaman (Entrance)

	--Ulduar (Entrance)
	AL["Shavalius the Fancy <Flight Master>"] = "古怪的沙瓦留斯 <飞行管理员>";
	AL["Chester Copperpot <General & Trade Supplies>"] = "切斯特·考伯特 <杂货商>";
	AL["Slosh <Food & Drink>"] = "斯洛什 <食物与饮料>";

	--Wailing Caverns (Entrance)

--************************************************
-- Kalimdor Instances (Classic)
--************************************************

	--Blackfathom Deeps
	AL["Shrine of Gelihast"] = "格里哈斯特神殿";
	AL["Fathom Stone"] = "深渊之核";
	AL["Lorgalis Manuscript"] = "潮湿的便笺";
	AL["Scout Thaelrid"] = "斥候塞尔瑞德";	-- Needs review after Cataclysm is available in China
	AL["Flaming Eradicator"] = "火焰根除者";	-- Needs review after Cataclysm is available in China
	AL["Altar of the Deeps"] = "玛塞斯特拉祭坛";
	AL["Ashelan Northwood"] = "阿谢兰•北木";	-- Needs review after Cataclysm is available in China
	AL["Relwyn Shadestar"] = "芮尔温•影星";	-- Needs review after Cataclysm is available in China
	AL["Sentinel Aluwyn"] = "哨兵阿露温";	-- Needs review after Cataclysm is available in China
	AL["Sentinel-trainee Issara"] = "哨兵受训员伊萨拉";	-- Needs review after Cataclysm is available in China
	AL["Je'neu Sancrea <The Earthen Ring>"] = "耶努萨克雷 <陶土议会>";	-- Needs review after Cataclysm is available in China
	AL["Zeya"] = "仄亚";	-- Needs review after Cataclysm is available in China

	--Dire Maul (East)
	AL["Old Ironbark"] = "埃隆巴克";
	AL["Ironbark the Redeemed"] = "赎罪的埃隆巴克";

	--Dire Maul (North)
	AL["Knot Thimblejack"] = "诺特·希姆加可";

	--Dire Maul (West)
	AL["J'eevee's Jar"] = "耶维尔的瓶子";
	AL["Ferra"] = "费拉";
	AL["Pylons"] = "水晶塔";
	AL["Ancient Equine Spirit"] = "上古圣马之魂";
	AL["Shen'dralar Ancient"] = "辛德拉古灵";
	AL["Falrin Treeshaper"] = "法尔林·树影";
	AL["Lorekeeper Lydros"] = "博学者莱德罗斯";
	AL["Lorekeeper Javon"] = "博学者亚沃";
	AL["Lorekeeper Kildrath"] = "博学者基尔达斯";
	AL["Lorekeeper Mykos"] = "博学者麦库斯";
	AL["Shen'dralar Provisioner"] = "辛德拉圣职者";

	--Maraudon	
	AL["Elder Splitrock"] = "碎石长者";

	--Ragefire Chasm

	--Razorfen Downs
	AL["Koristrasza"] = "柯莉史卓莎";	-- Needs review after Cataclysm is available in China
	AL["Belnistrasz"] = "奔尼斯特拉兹";

	--Razorfen Kraul
	AL["Auld Stonespire"] = "奥尔德·石塔 ";
	AL["Razorfen Spearhide"] = "剃刀沼泽刺鬃守卫";
	AL["Spirit of Agamaggan <Ancient>"] = "阿迦玛甘之灵 <先祖>";	-- Needs review after Cataclysm is available in China
	AL["Willix the Importer"] = "进口商威利克斯";

	--Ruins of Ahn'Qiraj
	AL["Four Kaldorei Elites"] = "卡多雷四精英";
	AL["Captain Qeez"] = "奎兹上尉";
	AL["Captain Tuubid"] = "图比德上尉";
	AL["Captain Drenn"] = "德雷恩上尉";
	AL["Captain Xurrem"] = "库雷姆上尉";
	AL["Major Yeggeth"] = "耶吉斯少校";
	AL["Major Pakkon"] = "帕库少校";
	AL["Colonel Zerran"] = "泽兰上校";
	AL["Safe Room"] = "安全房间";

	--Temple of Ahn'Qiraj
	AL["Andorgos <Brood of Malygos>"] = "安多葛斯 <玛里苟斯的后裔>";
	AL["Vethsera <Brood of Ysera>"] = "温瑟拉 <伊瑟拉的后裔>";
	AL["Kandrostrasz <Brood of Alexstrasza>"] = "坎多斯特拉兹 <阿莱克丝塔萨的后裔>";
	AL["Arygos"] = "亚雷戈斯";
	AL["Caelestrasz"] = "凯雷斯特拉兹";
	AL["Merithra of the Dream"] = "梦境之龙麦琳瑟拉";

	--Wailing Caverns
	AL["Disciple of Naralex"] = "纳拉雷克斯的信徒";

	--Zul'Farrak
	AL["Chief Engineer Bilgewhizzle <Gadgetzan Water Co.>"] = "首席工程师沙克斯·比格维兹 <加基森水业公司>";
	AL["Mazoga's Spirit"] = "玛柔伽的灵魂";	-- Needs review after Cataclysm is available in China
	AL["Tran'rek"] = "特兰雷克";
	AL["Weegli Blastfuse"] = "维格利";
	AL["Raven"] = "拉文";
	AL["Elder Wildmane"] = "蛮鬃长者";

--****************************
-- Eastern Kingdoms Instances (Classic)
--****************************

	--Blackrock Depths
	AL["Relic Coffer Key"] = "遗物宝箱钥匙";
	AL["Dark Keeper Key"] = "黑暗守护者钥匙";
	AL["The Black Anvil"] = "黑铁砧";
	AL["The Vault"] = "黑色宝库";
	AL["Watchman Doomgrip"] = "卫兵杜格瑞普";
	AL["High Justice Grimstone"] = "裁决者格里斯通";
	AL["Elder Morndeep"] = "黎明长者";
	AL["Schematic: Field Repair Bot 74A"] = "修理机器人74A型";
	AL["Private Rocknot"] = "罗克诺特下士";
	AL["Mistress Nagmara"] = "娜玛拉小姐";
	AL["Summoner's Tomb"] = "召唤者之墓";
	AL["The Shadowforge Lock"] = "暗炉之锁";
	AL["Lokhtos Darkbargainer <The Thorium Brotherhood>"] = "罗克图斯·暗契 <瑟银兄弟会>";
	AL["The Black Forge"] = "黑熔炉";

	--Blackrock Spire (Lower)
	AL["Urok's Tribute Pile"] = "乌洛克的贡品堆";
	AL["Elder Stonefort"] = "石墙长者";
	AL["Roughshod Pike"] = "尖锐长矛";

	--Blackrock Spire (Upper)
	AL["Finkle Einhorn"] = "芬克·恩霍尔";
	AL["Drakkisath's Brand"] = "达基萨斯的烙印";
	AL["Father Flame"] = "烈焰之父";

	--Blackwing Lair
	AL["Master Elemental Shaper Krixix"] = "大元素师克里希克";

	--Gnomeregan
	AL["Chomper"] = "咀嚼者";
	AL["Blastmaster Emi Shortfuse"] = "爆破专家艾米·短线";
	AL["Tink Sprocketwhistle <Engineering Supplies>"] = "丁克·铁哨 <工程学供应商>";
	AL["The Sparklematic 5200"] = "超级清洁器5200型";
	AL["Mail Box"] = "邮箱";

	--Molten Core

	--Scholomance
	AL["Blood of Innocents"] = "无辜者之血";
	AL["Divination Scryer"] = "预言水晶球";
	AL["The Deed to Caer Darrow"] = "凯尔达隆地契";
	AL["The Deed to Southshore"] = "南海镇地契";
	AL["Torch Lever"] = "火炬";
	AL["The Deed to Tarren Mill"] = "塔伦米尔地契";
	AL["The Deed to Brill"] = "布瑞尔地契";

	--Shadowfang Keep
	AL["Apothecary Trio"] = "药剂师三人组"; -- Needs review
	AL["Apothecary Hummel <Crown Chemical Co.>"] = "药剂师胡默尔 <王冠化学制药公司>"; -- Needs review
	AL["Apothecary Baxter <Crown Chemical Co.>"] = "药剂师巴克斯特 <王冠化学制药公司>"; -- Needs review
	AL["Apothecary Frye <Crown Chemical Co.>"] = "药剂师弗莱伊 <王冠化学制药公司>"; -- Needs review
	AL["Investigator Fezzen Brasstacks"] = "调查员菲赞•铜钉"; -- Needs review

	--SM: Armory

	--SM: Cathedral

	--SM: Graveyard
	AL["Vorrel Sengutz"] = "沃瑞尔·森加斯";
	AL["Pumpkin Shrine"] = "南瓜神龛";

	--SM: Library

	--Stratholme - Crusader's Square
	AL["Various Postbox Keys"] = "邮箱钥匙";
	AL["Stratholme Courier"] = "斯坦索姆信使";
	AL["Fras Siabi's Postbox"] = "弗拉斯·希亚比的邮箱";
	AL["King's Square Postbox"] = "国王广场邮箱";
	AL["Festival Lane Postbox"] = "节日小道邮箱";
	AL["Elder Farwhisper"] = "远风长者";
	AL["Market Row Postbox"] = "市场邮箱";
	AL["Crusaders' Square Postbox"] = "十字军广场邮箱";

	--Stratholme - The Gauntlet
	AL["Elders' Square Postbox"] = "长者广场邮箱";

	--The Deadmines

	--The Stockade

	--The Sunken Temple
	AL["Elder Starsong"] = "星歌长者";

	--Uldaman
	AL["Staff of Prehistoria"] = "史前法杖";
	AL["Baelog's Chest"] = "巴尔洛戈的箱子";
	AL["Ancient Treasure"] = "古代宝藏";
	AL["The Discs of Norgannon"] = "诺甘农圆盘";

--*******************
-- Burning Crusade Instances
--*******************

	--Auch: Auchenai Crypts
	AL["Auchenai Key"] = "奥金尼钥匙";
	AL["Avatar of the Martyred"] = "殉难者的化身";
	AL["D'ore"] = "德欧里";

	--Auch: Mana-Tombs
	AL["The Eye of Haramad"] = "哈拉迈德之眼";
	AL["Shadow Lord Xiraxis"] = "暗影领主希拉卡希斯";
	AL["Ambassador Pax'ivi"] = "帕克希维大使";
	AL["Cryo-Engineer Sha'heen"] = "低温工程师沙赫恩";
	AL["Ethereal Transporter Control Panel"] = "虚灵传送器控制台";

	--Auch: Sethekk Halls
	AL["Lakka"] = "拉卡";
	AL["The Saga of Terokk"] = "泰罗克的传说";

	--Auch: Shadow Labyrinth
	AL["The Codex of Blood"] = "鲜血法典";
	AL["First Fragment Guardian"] = "第一块碎片的守护者";
	AL["Spy To'gun"] = "间谍托古恩";

	--Black Temple (Start)
	AL["Towards Reliquary of Souls"] = "通往灵魂之匣";
	AL["Towards Teron Gorefiend"] = "通往塔隆·血魔";
	AL["Towards Illidan Stormrage"] = "通往伊利丹·怒风";
	AL["Spirit of Olum"] = "奥鲁姆之魂";
	AL["Spirit of Udalo"] = "乌达鲁之魂";
	AL["Aluyen <Reagents>"] = "奥鲁尤 <材料商>";
	AL["Okuno <Ashtongue Deathsworn Quartermaster>"] = "沃库诺 <灰舌死誓者军需官>";
	AL["Seer Kanai"] = "先知坎奈";

	--Black Temple (Basement)

	--Black Temple (Top)

	--CFR: Serpentshrine Cavern
	AL["Seer Olum"] = "先知奥鲁姆";

	--CFR: The Slave Pens
	AL["Reservoir Key"] = "水库钥匙";
	AL["Weeder Greenthumb"] = "除草者格林萨姆";
	AL["Skar'this the Heretic"] = "异教徒斯卡希斯";
	AL["Naturalist Bite"] = "博学者拜特";

	--CFR: The Steamvault
	AL["Main Chambers Access Panel"] = "主厅控制面板";
	AL["Second Fragment Guardian"] = "第二块碎片的守护者";

	--CFR: The Underbog
	AL["The Underspore"] = "幽暗孢子";
	AL["Earthbinder Rayge"] = "缚地者雷葛";

	--CoT: The Black Morass
	AL["Opening of the Dark Portal"] = "开启黑暗之门";
	AL["Key of Time"] = "时光之匙";
	AL["Sa'at <Keepers of Time>"] = "萨艾特 <时光守护者>";
	AL["The Dark Portal"] = "黑暗之门";

	--CoT: Hyjal Summit
	AL["Battle for Mount Hyjal"] = "海加尔之战";
	AL["Alliance Base"] = "联盟基地";
	AL["Lady Jaina Proudmoore"] = "吉安娜·普罗德摩尔";
	AL["Horde Encampment"] = "部落营地";
	AL["Thrall <Warchief>"] = "萨尔 <酋长>";
	AL["Night Elf Village"] = "暗夜精灵村庄";
	AL["Tyrande Whisperwind <High Priestess of Elune>"] = "泰兰德·语风 <艾露恩的高阶女祭司>";

	--CoT: Old Hillsbrad Foothills
	AL["Escape from Durnholde Keep"] = "逃离敦霍尔德堡";
	AL["Erozion"] = "伊洛希恩";
	AL["Brazen"] = "布拉森";
	AL["Landing Spot"] = "着陆点";
	AL["Thrall"] = "萨尔";
	AL["Taretha"] = "塔蕾莎";
	AL["Don Carlos"] = "卡洛斯";
	AL["Guerrero"] = "古雷罗";
	AL["Thomas Yance <Travelling Salesman>"] = "托马斯·杨斯 <旅行商人>";
	AL["Aged Dalaran Wizard"] = "老迈的达拉然巫师";
	AL["Jonathan Revah"] = "乔纳森·雷瓦";
	AL["Jerry Carter"] = "杰瑞·卡特尔";
	AL["Helcular"] = "赫尔库拉";
	AL["Farmer Kent"] = "农夫肯特";
	AL["Sally Whitemane"] = "萨莉·怀特迈恩";
	AL["Renault Mograine"] = "雷诺·莫格莱尼";
	AL["Little Jimmy Vishas"] = "吉米·维沙斯";
	AL["Herod the Bully"] = "赫洛德";
	AL["Nat Pagle"] = "纳特·帕格";
	AL["Hal McAllister"] = "哈尔·马克奥里斯特";
	AL["Zixil <Aspiring Merchant>"] = "吉克希尔 <有抱负的商人>";
	AL["Overwatch Mark 0 <Protector>"] = "守候者零型 <保护者>";
	AL["Southshore Inn"] = "南海镇旅馆";
	AL["Captain Edward Hanes"] = "爱德华·汉斯";
	AL["Captain Sanders"] = "杉德尔船长";
	AL["Commander Mograine"] = "指挥官莫格莱尼";
	AL["Isillien"] = "伊森利恩";
	AL["Abbendis"] = "阿比迪斯";
	AL["Fairbanks"] = "法尔班克斯";
	AL["Taelan"] = "泰兰";
	AL["Barkeep Kelly <Bartender>"] = "酒吧招待凯利 <调酒师>";
	AL["Frances Lin <Barmaid>"] = "弗兰斯·林 <招待员>";
	AL["Chef Jessen <Speciality Meat & Slop>"] = "厨师杰森 <美食大师>";
	AL["Stalvan Mistmantle"] = "斯塔文·密斯特曼托";
	AL["Phin Odelic <The Kirin Tor>"] = "费恩·奥德利克 <肯瑞托>";
	AL["Magistrate Henry Maleb"] = "赫尼·马雷布镇长";
	AL["Raleigh the True"] = "虔诚的莱雷恩";
	AL["Nathanos Marris"] = "纳萨诺斯·玛瑞斯";
	AL["Bilger the Straight-laced"] = "古板的比格尔";
	AL["Innkeeper Monica"] = "旅店老板莫妮卡";
	AL["Julie Honeywell"] = "朱丽·哈尼维尔";
	AL["Jay Lemieux"] = "贾森·雷缪克斯";
	AL["Young Blanchy"] = "小马布兰契";

	--Gruul's Lair

	--HFC: The Blood Furnace
	AL["Flamewrought Key"] = "焰铸钥匙";--omitted from other HFC

	--HFC: Hellfire Ramparts
	AL["Reinforced Fel Iron Chest"] = "强化魔铁箱";

	--HFC: Magtheridon's Lair

	--HFC: The Shattered Halls
	AL["Shattered Hand Executioner"] = "碎手斩杀者";
	AL["Private Jacint"] = "列兵亚森特";
	AL["Rifleman Brownbeard"] = "火枪手布隆恩·棕须";
	AL["Captain Alina"] = "奥琳娜上尉";
	AL["Scout Orgarr"] = "斥候奥贾尔";
	AL["Korag Proudmane"] = "克拉格·傲鬃";
	AL["Captain Boneshatter"] = "沙塔·碎骨上尉";
	AL["Randy Whizzlesprocket"] = "兰迪·维兹普罗克";
	AL["Drisella"] = "德雷希拉";

	--Karazhan Start
	AL["The Master's Key"] = "麦迪文的钥匙";--omitted from Karazhan End
	AL["Baroness Dorothea Millstipe"] = "杜萝希·米尔斯提女伯爵";
	AL["Lady Catriona Von'Indi"] = "卡翠欧娜·冯因迪女伯爵";
	AL["Lady Keira Berrybuck"] = "吉拉·拜瑞巴克女伯爵";
	AL["Baron Rafe Dreuger"] = "拉弗·杜格尔男爵";
	AL["Lord Robin Daris"] = "罗宾·达瑞斯伯爵";
	AL["Lord Crispin Ference"] = "克里斯宾·费伦斯伯爵";
	AL["Red Riding Hood"] = "小红帽";
	AL["Wizard of Oz"] = "绿野仙踪";
	AL["The Master's Terrace"] = "主宰的露台";
	AL["Servant Quarters"] = "仆人区";
	AL["Hastings <The Caretaker>"] = "哈斯汀斯 <看管者>";
	AL["Berthold <The Doorman>"] = "伯特霍德 <门卫>";
	AL["Calliard <The Nightman>"] = "卡利亚德 <清洁工>";
	AL["Koren <The Blacksmith>"] = "库雷恩 <铁匠>";
	AL["Bennett <The Sergeant at Arms>"] = "本内特 <警卫>";
	AL["Keanna's Log"] = "金娜的日记";
	AL["Ebonlocke <The Noble>"] = "埃伯洛克 <贵族>";
	AL["Sebastian <The Organist>"] = "塞巴斯蒂安 <风琴手>";
	AL["Barnes <The Stage Manager>"] = "巴内斯 <舞台管理员>";

	--Karazhan End
	AL["Path to the Broken Stairs"] = "通往破碎阶梯的通道";--omitted from Karazhan End
	AL["Broken Stairs"] = "破碎阶梯";
	AL["Ramp to Guardian's Library"] = "通往守护者的图书馆的斜坡";
	AL["Suspicious Bookshelf"] = "奇怪的书架";
	AL["Ramp up to the Celestial Watch"] = "通往观星大厅的斜坡";
	AL["Ramp down to the Gamesman's Hall"] = "通往象棋大厅的斜坡";
	AL["Ramp to Medivh's Chamber"] = "通往麦迪文房间的斜坡";
	AL["Spiral Stairs to Netherspace"] = "通往虚空异界的楼梯";
	AL["Wravien <The Mage>"] = "拉维恩 <法师>";
	AL["Gradav <The Warlock>"] = "格拉达夫 <术士>";
	AL["Kamsis <The Conjurer>"] = "卡姆希丝 <咒术师>";
	AL["Ythyar"] = "伊萨尔";
	AL["Echo of Medivh"] = "麦迪文的回音";

	--Magisters Terrace
	AL["Fel Crystals"] = "邪能水晶";
	AL["Apoko"] = "埃波克";
	AL["Eramas Brightblaze"] = "埃拉玛斯·炽光";
	AL["Ellrys Duskhallow"] = "艾尔蕾丝";
	AL["Fizzle"] = "菲兹尔";
	AL["Garaxxas"] = "贾拉克萨斯";
	AL["Sliver <Garaxxas' Pet>"] = "脆皮 <贾拉克萨斯的宠物>";
	AL["Kagani Nightstrike"] = "卡加尼·夜锋";
	AL["Warlord Salaris"] = "督军沙拉利斯";
	AL["Yazzai"] = "亚赛";
	AL["Zelfan"] = "扎尔凡";
	AL["Tyrith"] = "塔雷斯";
	AL["Scrying Orb"] = "占卜宝珠";

	--Sunwell Plateau
	AL["Madrigosa"] = "玛蒂苟萨";

	--TK: The Arcatraz
	AL["Warpforged Key"] = "星船钥匙";--omitted from other TK
	AL["Millhouse Manastorm"] = "米尔豪斯·法力风暴";
	AL["Third Fragment Guardian"] = "第三块碎片的守护者";
	AL["Udalo"] = "先知乌达鲁";

	--TK: The Botanica

	--TK: The Mechanar
	AL["Overcharged Manacell"] = "超载的魔法晶格";

	--TK: The Eye

	--Zul'Aman
	AL["Harrison Jones"] = "哈里森·琼斯";
	AL["Tanzar"] = "坦扎尔";
	AL["The Map of Zul'Aman"] = "巴德的祖阿曼地图";
	AL["Harkor"] = "哈考尔";
	AL["Kraz"] = "克拉斯";
	AL["Ashli"] = "阿什莉";
	AL["Thurg"] = "索尔格";
	AL["Gazakroth"] = "卡扎克洛斯";
	AL["Lord Raadan"] = "兰尔丹";
	AL["Darkheart"] = "黑心";
	AL["Alyson Antille"] = "阿莱松·安提雷";
	AL["Slither"] = "滑行者";
	AL["Fenstalker"] = "沼泽猎手";
	AL["Koragg"] = "库拉格";
	AL["Zungam"] = "苏加姆";
	AL["Forest Frogs"] = "丛林蛙, 其原型为: ";
	AL["Kyren <Reagents>"] = "凯雷 <材料商>";
	AL["Gunter <Food Vendor>"] = "冈特尔 <食物商人>";
	AL["Adarrah"] = "埃达尔拉";
	AL["Brennan"] = "布雷南";
	AL["Darwen"] = "达尔文";
	AL["Deez"] = "迪斯";
	AL["Galathryn"] = "加拉瑟林";
	AL["Mitzi"] = "米兹";
	AL["Mannuth"] = "曼努斯";

--*****************
-- WotLK Instances
--*****************

	--Azjol-Nerub: Ahn'kahet: The Old Kingdom
	AL["Ahn'kahet Brazier"] = "安卡赫特火盆";

	--Azjol-Nerub: Azjol-Nerub
	AL["Watcher Gashra"] = "看守者加什拉";
	AL["Watcher Narjil"] = "看守者纳尔伊";
	AL["Watcher Silthik"] = "看守者希尔希克";
	AL["Elder Nurgen"] = "长者努尔根";

	--Caverns of Time: The Culling of Stratholme
	AL["The Culling of Stratholme"] = "净化斯坦索姆";
	AL["Scourge Invasion Points"] = "天灾入侵点";
	AL["Guardian of Time"] = "时光守护者";
	AL["Chromie"] = "克罗米";

	--Drak'Tharon Keep
	AL["Kurzel"] = "库塞尔";
	AL["Elder Kilias"] = "长者基里亚斯";
	AL["Drakuru's Brazier"] = "达库鲁的火盆";

	--The Frozen Halls: Halls of Reflection
	--3 beginning NPCs omitted, see The Forge of Souls
	AL["Wrath of the Lich King"] = "巫妖王之怒";
	AL["The Captain's Chest"] = "船长的箱子";

	--The Frozen Halls: Pit of Saron
	--6 beginning NPCs omitted, see The Forge of Souls
	AL["Martin Victus"] = "马汀·维特斯";
	AL["Gorkun Ironskull"] = "葛刚·铁颅";
	AL["Rimefang"] = "霜牙";

	--The Frozen Halls: The Forge of Souls
	--Lady Jaina Proudmoore omitted, in Hyjal Summit
	AL["Archmage Koreln <Kirin Tor>"] = "大法师寇瑞伦 <肯瑞托>";
	AL["Archmage Elandra <Kirin Tor>"] = "大法师伊兰卓 <肯瑞托>";
	AL["Lady Sylvanas Windrunner <Banshee Queen>"] = "希瓦娜斯·风行者女士 <女妖之王>";
	AL["Dark Ranger Loralen"] = "黑暗游侠洛拉伦";
	AL["Dark Ranger Kalira"] = "黑暗游侠卡丽菈";

	--Gundrak
	AL["Elder Ohanzee"] = "Elder Ohanzee";

	--Icecrown Citadel
	AL["To next map"] = "到下一个地图";
	AL["From previous map"] = "到前一个地图";
	AL["Upper Spire"] = "冰冠尖塔"; -- Needs review after WoW 3.3.3 is available in China
	AL["Sindragosa's Lair"] = "辛达苟萨之巢"; -- Needs review after WoW 3.3.3 is available in China

	--Naxxramas
	AL["Mr. Bigglesworth"] = "比格沃斯";
	AL["Frostwyrm Lair"] = "冰霜巨龙巢穴";

	--The Obsidian Sanctum
	AL["Black Dragonflight Chamber"] = "黑龙军团巢穴";

	--Onyxia's Lair

	--The Ruby Sanctum
	AL["Red Dragonflight Chamber"] = "红龙庭"; -- Needs review after WoW 3.3.5 is available in China

	--The Nexus: The Eye of Eternity
	AL["Key to the Focusing Iris"] = "聚焦之虹的钥匙";

	--The Nexus: The Nexus
	AL["Berinand's Research"] = "伯林纳德的研究笔记";
	AL["Elder Igasho"] = "长者伊加苏";

	--The Nexus: The Oculus
	AL["Centrifuge Construct"] = "离心构造体";
	AL["Cache of Eregos"] = "埃雷苟斯的宝箱";

	--Trial of the Champion
	AL["Champions of the Alliance"] = "联盟冠军";
	AL["Marshal Jacob Alerius"] = "雅克布·奥勒留斯元帅";
	AL["Ambrose Boltspark"] = "安布罗斯·雷钉";
	AL["Colosos"] = "克罗索斯";
	AL["Jaelyne Evensong"] = "娅琳·永歌";
	AL["Lana Stouthammer"] = "拉娜·硬锤";
	AL["Champions of the Horde"] = "部落冠军";

	--Trial of the Crusader
	AL["Heroic: Trial of the Grand Crusader"] = "英雄: 大十字军的试炼";
	AL["Cavern Entrance"] = "洞穴入口";

	--Ulduar General
	AL["Celestial Planetarium Key"] = "天文馆钥匙";
	AL["The Siege"] = "城墙";
	AL["The Keepers"] = "守护者"; --C

	--Ulduar A
	AL["Tower of Life"] = "生命之塔";
	AL["Tower of Flame"] = "烈焰之塔";
	AL["Tower of Frost"] = "冰霜之塔";
	AL["Tower of Storms"] = "风暴之塔";

	--Ulduar B
	AL["Prospector Doren"] = "勘察员多伦";
	AL["Archivum Console"] = "大数据库控制台";

	--Ulduar C

	--Ulduar D

	--Ulduar E

	--Ulduar: Halls of Lightning

	--Ulduar: Halls of Stone
	AL["Tribunal Chest"] = "远古法庭宝箱";
	AL["Elder Yurauk"] = "由罗克长者"; -- needs review
	AL["Brann Bronzebeard"] = "布莱恩·铜须";

	--Utgarde Keep: Utgarde Keep
	AL["Dark Ranger Marrah"] = "黑暗游侠玛尔拉";
	AL["Elder Jarten"] = "加坦长者"; -- needs review

	--Utgarde Keep: Utgarde Pinnacle
	AL["Brigg Smallshanks"] = "布雷格";
	AL["Elder Chogan'gada"] = "长者甘达加";

	--Vault of Archavon

	--The Violet Hold
	AL["The Violet Hold Key"] = "紫罗兰监狱钥匙";

end
