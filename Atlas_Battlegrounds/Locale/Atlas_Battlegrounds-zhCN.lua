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

-- Atlas Localization Data (Chinese)
-- Initial translation by DiabloHu
-- Version : Chinese (by DiabloHu)
-- $Date: 2011-01-27 11:16:25 +0100 (Do, 27. Jan 2011) $
-- $Revision: 1217 $
-- http://ngacn.cc


local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("Atlas_Battlegrounds", "zhCN", false);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas_Battlegrounds", "deDE", false);

if AL then
	--Common
	AL["Battleground Maps"] = "战场地图";
	AL["Entrance"] = "入口";
	AL["Meeting Stone"] = "集合石";
	AL["North"] = "北部";
	AL["Orange"] = "橙色";
	AL["Red"] = "红色";
	AL["Reputation"] = "阵营";
	AL["Rescued"] = "被营救";
	AL["South"] = "南部";
	AL["Start"] = "起始点";
	AL["Summon"] = "召唤";
	AL["White"] = "白色";

	--Places
	AL["AV"] = "AV"; -- Alterac Valley
	AL["AB"] = "AB"; -- Arathi Basin
	AL["EotS"] = "EotS";
	AL["IoC"] = "IoC"; -- Isle of Conquest
	AL["SotA"] = "SotA"; -- Strand of the Ancients
	AL["WSG"] = "WSG"; -- Warsong Gulch

	--Alterac Valley (North)
	AL["Vanndar Stormpike <Stormpike General>"] = "范达尔·雷矛 <雷矛将军>";
	AL["Dun Baldar North Marshal"] = "丹巴达尔北部统帅";
	AL["Dun Baldar South Marshal"] = "丹巴达尔南部统帅";
	AL["Icewing Marshal"] = "冰翼统帅";
	AL["Stonehearth Marshal"] = "石炉统帅";
	AL["Prospector Stonehewer"] = "勘查员塔雷·石镐";
	AL["Morloch"] = "莫洛克";
	AL["Umi Thorson"] = "乌米·索尔森";
	AL["Keetar"] = "基塔尔";
	AL["Arch Druid Renferal"] = "大德鲁伊雷弗拉尔";
	AL["Dun Baldar North Bunker"] = "丹巴达尔北部碉堡";
	AL["Wing Commander Mulverick"] = "空军指挥官穆维里克";--omitted from AVS
	AL["Murgot Deepforge"] = "莫高特·深炉";
	AL["Dirk Swindle <Bounty Hunter>"] = "德尔克 <赏金猎人>";
	AL["Athramanis <Bounty Hunter>"] = "亚斯拉玛尼斯 <赏金猎人>";
	AL["Lana Thunderbrew <Blacksmithing Supplies>"] = "兰纳·雷酒 <锻造供应商>";
	AL["Stormpike Aid Station"] = "雷矛急救站";
	AL["Stormpike Stable Master <Stable Master>"] = "雷矛兽栏管理员 <兽栏管理员>";
	AL["Stormpike Ram Rider Commander"] = "雷矛山羊骑兵指挥官";
	AL["Svalbrad Farmountain <Trade Goods>"] = "斯瓦尔布莱德·远山 <商人>";
	AL["Kurdrum Barleybeard <Reagents & Poison Supplies>"] = "库德拉姆·麦须 <毒药和材料>";
	AL["Stormpike Quartermaster"] = "雷矛军需官";
	AL["Jonivera Farmountain <General Goods>"] = "约尼维拉·远山 <杂货商>";
	AL["Brogus Thunderbrew <Food & Drink>"] = "布罗古斯·雷酒 <食物和饮料>";
	AL["Wing Commander Ichman"] = "空军指挥官艾克曼";--omitted from AVS
	AL["Wing Commander Slidore"] = "空军指挥官斯里多尔";--omitted from AVS
	AL["Wing Commander Vipore"] = "空军指挥官维波里";--omitted from AVS
	AL["Dun Baldar South Bunker"] = "丹巴达尔南部碉堡";
	AL["Corporal Noreg Stormpike"] = "诺雷格·雷矛中尉";
	AL["Gaelden Hammersmith <Stormpike Supply Officer>"] = "盖尔丁 <雷矛军需官>";
	AL["Stormpike Banner"] = "雷矛军旗";
	AL["Stormpike Lumber Yard"] = "雷矛伐木场";
	AL["Wing Commander Jeztor"] = "空军指挥官杰斯托";--omitted from AVS
	AL["Wing Commander Guse"] = "空军指挥官古斯";--omitted from AVS
	AL["Stormpike Ram Rider Commander"] = "雷矛山羊骑兵指挥官";
	AL["Captain Balinda Stonehearth <Stormpike Captain>"] = "巴琳达·斯通赫尔斯 <雷矛上尉>";
	AL["Ichman's Beacon"] = "艾克曼的信号灯";
	AL["Mulverick's Beacon"] = "穆维里克的信号灯";
	AL["Ivus the Forest Lord"] = "森林之王伊弗斯";
	AL["Western Crater"] = "西部平原";
	AL["Vipore's Beacon"] = "维波里的信号灯";
	AL["Jeztor's Beacon"] = "杰斯托的信号灯";
	AL["Eastern Crater"] = "东部平原";
	AL["Slidore's Beacon"] = "斯里多尔的信号灯";
	AL["Guse's Beacon"] = "古斯的信号灯";
	AL["Graveyards, Capturable Areas"] = "墓地, 可占领区域";--omitted from AVS
	AL["Bunkers, Towers, Destroyable Areas"] = "碉堡, 哨塔, 可摧毁区域";--omitted from AVS
	AL["Assault NPCs, Quest Areas"] = "相关NPC, 任务区域";--omitted from AVS

	--Alterac Valley (South)
	AL["Drek'Thar <Frostwolf General>"] = "德雷克塔尔 <霜狼将军>";
	AL["Duros"] = "杜洛斯";
	AL["Drakan"] = "德拉卡";
	AL["West Frostwolf Warmaster"] = "霜狼西部将领";
	AL["East Frostwolf Warmaster"] = "东部霜狼将领";
	AL["Tower Point Warmaster"] = "哨塔高地将领";
	AL["Iceblood Warmaster"] = "冰血将领";
	AL["Lokholar the Ice Lord"] = "冰雪之王洛克霍拉";
	AL["Captain Galvangar <Frostwolf Captain>"] = "加尔范上尉 <霜狼上尉>";
	AL["Iceblood Tower"] = "冰血哨塔";
	AL["Tower Point"] = "哨塔高地";
	AL["Taskmaster Snivvle"] = "工头斯尼维尔";
	AL["Masha Swiftcut"] = "玛莎";
	AL["Aggi Rumblestomp"] = "埃其";
	AL["Jotek"] = "乔泰克";
	AL["Smith Regzar"] = "铁匠雷格萨";
	AL["Primalist Thurloga"] = "指挥官瑟鲁加";
	AL["Sergeant Yazra Bloodsnarl"] = "亚斯拉·血矛";
	AL["Frostwolf Stable Master <Stable Master>"] = "霜狼兽栏管理员 <兽栏管理员>";
	AL["Frostwolf Wolf Rider Commander"] = "霜狼骑兵指挥官";
	AL["Frostwolf Quartermaster"] = "霜狼军需官";
	AL["West Frostwolf Tower"] = "西部霜狼哨塔";
	AL["East Frostwolf Tower"] = "东部霜狼哨塔";
	AL["Frostwolf Relief Hut"] = "霜狼急救站";
	AL["Frostwolf Banner"] = "霜狼军旗";

	--Arathi Basin

	--Eye of the Storm
	AL["Flag"] = "旗帜";

	--Isle of Conquest
	AL["The Refinery"] = "精炼厂";
	AL["The Docks"] = "码头";
	AL["The Workshop"] = "工坊";
	AL["The Hangar"] = "机棚";
	AL["The Quarry"] = "矿场";
	AL["Contested Graveyards"] = "争夺中的墓地";
	AL["Horde Graveyard"] = "部落墓地";
	AL["Alliance Graveyard"] = "联盟墓地";
	AL["Gates are marked with red bars."] = "闸门以红条标记.";
	AL["Overlord Agmar"] = "霸主阿格玛";
	AL["High Commander Halford Wyrmbane <7th Legion>"] = "最高指挥官海弗德•龙祸";

	--Strand of the Ancients
	AL["Attacking Team"] = "进攻方";
	AL["Defending Team"] = "防守方";
	AL["Massive Seaforium Charge"] = "大型爆盐炸弹";
	AL["Battleground Demolisher"] = "战场攻城车";
	AL["Resurrection Point"] = "复活点";
	AL["Graveyard Flag"] = "墓地旗帜";
	AL["Titan Relic"] = "泰坦圣物";
	AL["Gates are marked with their colors."] = "大门以其颜色进行了标记。";

	--Warsong Gulch

	-- Hellfire Peninsula PvP 
	AL["Hellfire Fortifications"] = "防御工事";

	-- Zangarmarsh PvP
	AL["West Beacon"] = "West Beacon"; -- Need translation
	AL["East Beacon"] = "East Beacon"; -- Need translation
	AL["Twinspire Graveyard"] = "Twinspire Graveyard"; -- Need translation
	AL["Alliance Field Scout"] = "Alliance Field Scout"; -- Need translation
	AL["Horde Field Scout"] = "Horde Field Scout"; -- Need translation

	-- Terokkar Forest PvP
	AL["Auchindoun Spirit Towers"] = "Auchindoun Spirit Towers"; -- Need translation

	-- Halaa
	AL["Wyvern Camp"] = "Wyvern Camp"; -- Need translation
	AL["Quartermaster Jaffrey Noreliqe"] = "Quartermaster Jaffrey Noreliqe"; -- Need translation
	AL["Quartermaster Davian Vaclav"] = "Quartermaster Davian Vaclav"; -- Need translation
	AL["Chief Researcher Amereldine"] = "Chief Researcher Amereldine"; -- Need translation
	AL["Chief Researcher Kartos"] = "Chief Researcher Kartos"; -- Need translation
	AL["Aldraan <Blade Merchant>"] = "Aldraan <Blade Merchant>"; -- Need translation
	AL["Banro <Ammunition>"] = "Banro <Ammunition>"; -- Need translation
	AL["Cendrii <Food & Drink>"] = "Cendrii <Food & Drink>"; -- Need translation
	AL["Coreiel <Blade Merchant>"] = "Coreiel <Blade Merchant>"; -- Need translation
	AL["Embelar <Food & Drink>"] = "Embelar <Food & Drink>"; -- Need translation
	AL["Tasaldan <Ammunition>"] = "Tasaldan <Ammunition>"; -- Need translation

	-- Wintergrasp
	AL["Fortress Vihecal Workshop (E)"] = "Fortress Vihecal Workshop (E)"; -- Need translation
	AL["Fortress Vihecal Workshop (W)"] = "Fortress Vihecal Workshop (W)"; -- Need translation
	AL["Sunken Ring Vihecal Workshop"] = "Sunken Ring Vihecal Workshop"; -- Need translation
	AL["Broken Temple Vihecal Workshop"] = "Broken Temple Vihecal Workshop"; -- Need translation
	AL["Eastspark Vihecale Workshop"] = "Eastspark Vihecale Workshop"; -- Need translation
	AL["Westspark Vihecale Workshop"] = "Westspark Vihecale Workshop"; -- Need translation
	AL["Wintergrasp Graveyard"] = "Wintergrasp Graveyard"; -- Need translation
	AL["Sunken Ring Graveyard"] = "Sunken Ring Graveyard"; -- Need translation
	AL["Broken Temple Graveyard"] = "Broken Temple Graveyard"; -- Need translation
	AL["Southeast Graveyard"] = "Southeast Graveyard"; -- Need translation
	AL["Southwest Graveyard"] = "Southwest Graveyard"; -- Need translation

	-- Silithus - The Silithyst Must Flow
	AL["The Silithyst Must Flow"] = "The Silithyst Must Flow"; -- Need translation
	AL["Alliance's Camp"] = "Alliance's Camp"; -- Need translation
	AL["Horde's Camp"] = "Horde's Camp"; -- Need translation
end
