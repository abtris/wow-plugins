-- $Id: Atlas_Battlegrounds.lua 1217 2011-01-27 10:16:25Z dynaletik $
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

-- Atlas, an instance map browser
-- Initiator and previous author: Dan Gilbert, loglow@gmail.com
-- Maintainers: Lothaer, Dynaletik, Arith, Deadca7

local BF = Atlas_GetLocaleLibBabble("LibBabble-Faction-3.0");
local BZ = Atlas_GetLocaleLibBabble("LibBabble-SubZone-3.0");
local AL = LibStub("AceLocale-3.0"):GetLocale("Atlas_Battlegrounds");

local BLUE = "|cff6666ff";
local GREN = "|cff66cc33";
local LBLU = "|cff33cccc";
local _RED = "|cffcc3333";
local ORNG = "|cffcc9933";
local PINK = "|ccfcc33cc";
local PURP = "|cff9900ff";
local WHIT = "|cffffffff";
local YLOW = "|cffcccc33";
local INDENT = "      ";
local BULLET = " - ";

local myCategory = AL["Battleground Maps"];

local myData = {
	AlteracValleyNorth = {
		ZoneName = { BZ["Alterac Valley"].." ("..AL["North"]..", "..BF["Alliance"]..")" };
		Location = { BZ["Alterac Mountains"] };
		LevelRange = "45-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "45";
		PlayerLimit = "40";
		Acronym = AL["AV"];
		{ ORNG..AL["Reputation"]..": "..BF["Stormpike Guard"] };
		{ BLUE.."A) "..AL["Entrance"] };
		{ BLUE.."B) "..BZ["Dun Baldar"] };
		{ GREN..INDENT..AL["Vanndar Stormpike <Stormpike General>"] };
		{ GREN..INDENT..AL["Prospector Stonehewer"] };
		{ _RED.."1) "..AL["Dun Baldar North Bunker"] };
		{ GREN..INDENT..AL["Wing Commander Mulverick"].." ("..BF["Horde"]..")" };
		{ _RED.."2) "..AL["Dun Baldar South Bunker"] };
		{ GREN..INDENT..AL["Gaelden Hammersmith <Stormpike Supply Officer>"] };
		{ _RED.."3) "..BZ["Icewing Cavern"] };
		{ GREN..INDENT..AL["Stormpike Banner"] };
		{ _RED.."4) "..AL["Stormpike Lumber Yard"] };
		{ GREN..INDENT..AL["Wing Commander Jeztor"].." ("..BF["Horde"]..")" };
		{ _RED.."5) "..BZ["Icewing Bunker"] };
		{ GREN..INDENT..AL["Wing Commander Guse"].." ("..BF["Horde"]..")" };
		{ _RED.."6) "..BZ["Stonehearth Outpost"] };
		{ GREN..INDENT..AL["Captain Balinda Stonehearth <Stormpike Captain>"] };
		{ _RED.."7) "..BZ["Stonehearth Bunker"] };
		{ _RED.."8) "..AL["Western Crater"] };
		{ GREN..INDENT..AL["Vipore's Beacon"] };
		{ GREN..INDENT..AL["Jeztor's Beacon"].." ("..BF["Horde"]..")" };
		{ _RED.."9) "..AL["Eastern Crater"] };
		{ GREN..INDENT..AL["Slidore's Beacon"] };
		{ GREN..INDENT..AL["Guse's Beacon"].." ("..BF["Horde"]..")" };
		{ GREN.."1) "..BZ["Irondeep Mine"] };
		{ GREN.."1') "..AL["Arch Druid Renferal"] };
		{ GREN.."2') "..AL["Murgot Deepforge"] };
		{ GREN..INDENT..AL["Lana Thunderbrew <Blacksmithing Supplies>"] };
		{ GREN.."3') "..AL["Stormpike Stable Master <Stable Master>"] };
		{ GREN..INDENT..AL["Stormpike Ram Rider Commander"] };
		{ GREN..INDENT..AL["Svalbrad Farmountain <Trade Goods>"] };
		{ GREN..INDENT..AL["Kurdrum Barleybeard <Reagents & Poison Supplies>"] };
		{ GREN.."4') "..AL["Stormpike Quartermaster"] };
		{ GREN..INDENT..AL["Jonivera Farmountain <General Goods>"] };
		{ GREN..INDENT..AL["Brogus Thunderbrew <Food & Drink>"] };
		{ GREN.."5') "..AL["Wing Commander Ichman"].." ("..AL["Rescued"]..")" };
		{ GREN..INDENT..AL["Wing Commander Slidore"].." ("..AL["Rescued"]..")" };
		{ GREN..INDENT..AL["Wing Commander Vipore"].." ("..AL["Rescued"]..")" };
		{ GREN.."6') "..AL["Stormpike Ram Rider Commander"] };
		{ GREN.."7') "..AL["Ivus the Forest Lord"].." ("..AL["Summon"]..")" };
		{ ORNG.."1) "..AL["Stormpike Aid Station"] };
		{ ORNG.."2) "..BZ["Stormpike Graveyard"] };
		{ ORNG.."3) "..BZ["Stonehearth Graveyard"] };
		{ ORNG.."4) "..BZ["Snowfall Graveyard"] };
		{ GREN..INDENT..AL["Ichman's Beacon"] };
		{ GREN..INDENT..AL["Mulverick's Beacon"].." ("..BF["Horde"]..")" };
	};
	AlteracValleySouth = {
		ZoneName = { BZ["Alterac Valley"].." ("..AL["South"]..", "..BF["Horde"]..")" };
		Location = { BZ["Hillsbrad Foothills"] };
		LevelRange = "45-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "45";
		PlayerLimit = "40";
		Acronym = AL["AV"];
		{ ORNG..AL["Reputation"]..": "..BF["Frostwolf Clan"] };
		{ BLUE.."A) "..AL["Entrance"].." ("..BF["Horde"]..")" };
		{ BLUE.."B) "..BZ["Frostwolf Keep"] };
		{ GREN..INDENT..AL["Drek'Thar <Frostwolf General>"] };
		{ _RED.."1) "..BZ["Iceblood Garrison"] };
		{ GREN..INDENT..AL["Captain Galvangar <Frostwolf Captain>"] };
		{ _RED.."2) "..AL["Iceblood Tower"] };
		{ _RED.."3) "..AL["Tower Point"] };
		{ GREN..INDENT..AL["Wing Commander Slidore"].." ("..BF["Alliance"]..")" };
		{ _RED.."4) "..AL["West Frostwolf Tower"] };
		{ GREN..INDENT..AL["Wing Commander Ichman"].." ("..BF["Alliance"]..")" };
		{ _RED.."5) "..AL["East Frostwolf Tower"] };
		{ _RED.."6) "..BZ["Wildpaw Cavern"] };
		{ GREN..INDENT..AL["Frostwolf Banner"] };
		{ GREN.."1) "..BZ["Coldtooth Mine"] };
		{ GREN.."1') "..AL["Lokholar the Ice Lord"].." ("..AL["Summon"]..")" };
		{ GREN.."2') "..AL["Wing Commander Vipore"].." ("..BF["Alliance"]..")" };
		{ GREN..INDENT..AL["Jotek"] };
		{ GREN..INDENT..AL["Smith Regzar"] };
		{ GREN..INDENT..AL["Primalist Thurloga"] };
		{ GREN.."3') "..AL["Frostwolf Stable Master <Stable Master>"] };
		{ GREN..INDENT..AL["Frostwolf Wolf Rider Commander"] };
		{ GREN.."4') "..AL["Frostwolf Quartermaster"] };
		{ GREN.."5') "..AL["Wing Commander Guse"].." ("..AL["Rescued"]..")" };
		{ GREN..INDENT..AL["Wing Commander Jeztor"].." ("..AL["Rescued"]..")" };
		{ GREN..INDENT..AL["Wing Commander Mulverick"].." ("..AL["Rescued"]..")" };
		{ ORNG.."1) "..BZ["Iceblood Graveyard"] };
		{ ORNG.."2) "..BZ["Frostwolf Graveyard"] };
		{ ORNG.."3) "..AL["Frostwolf Relief Hut"] };
	};
	ArathiBasin = {
		ZoneName = { BZ["Arathi Basin"] };
		Location = { BZ["Arathi Highlands"] };
		LevelRange = "10-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "10";
		PlayerLimit = "15";
		Acronym = AL["AB"];
		{ ORNG..AL["Reputation"]..": "..BF["The League of Arathor"].." ("..BF["Alliance"]..")" };
		{ ORNG..AL["Reputation"]..": "..BF["The Defilers"].." ("..BF["Horde"]..")" };
		{ BLUE.."A) "..BZ["Trollbane Hall"].." ("..BF["Alliance"]..")" };
		{ BLUE.."B) "..BZ["Defiler's Den"].." ("..BF["Horde"]..")" };
		{ GREN.."1) "..BZ["Stables"] };
		{ GREN.."2) "..BZ["Gold Mine"] };
		{ GREN.."3) "..BZ["Blacksmith"] };
		{ GREN.."4) "..BZ["Lumber Mill"] };
		{ GREN.."5) "..BZ["Farm"] };
	};
	WarsongGulch = {
		ZoneName = { BZ["Warsong Gulch"] };
		Location = { BZ["Ashenvale"].." / "..BZ["Northern Barrens"] };
		LevelRange = "10-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "10";
		PlayerLimit = "10";
		Acronym = AL["WSG"];
		{ ORNG..AL["Reputation"]..": "..BF["Silverwing Sentinels"].." ("..BF["Alliance"]..")" };
		{ ORNG..AL["Reputation"]..": "..BF["Warsong Outriders"].." ("..BF["Horde"]..")" };
		{ BLUE.."A) "..BZ["Silverwing Hold"].." ("..BF["Alliance"]..")" };
		{ BLUE.."B) "..BZ["Warsong Lumber Mill"].." ("..BF["Horde"]..")" };
	};
	SilithystMustFlow = {
		ZoneName = { BZ["Silithus"].." - "..AL["The Silithyst Must Flow"] };
		--Location = { BZ["Silithus"] };
		LevelRange = "55-85";
		MinLevel = "55";
		{ ORNG.."PvP: "..AL["The Silithyst Must Flow"] };
		{ BLUE.."A) "..BZ["Cenarion Hold"] };
		{ BLUE.."B) "..AL["Alliance's Camp"] };
		{ BLUE.."C) "..AL["Horde's Camp"] };
	};
	EyeOfTheStorm = {
		ZoneName = { BZ["Eye of the Storm"] };
		Location = { BZ["Netherstorm"] };
		LevelRange = "35-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "35";
		PlayerLimit = "15";
		Acronym = AL["EotS"];
		{ BLUE.."A) "..AL["Entrance"].." ("..BF["Alliance"]..")" };
		{ BLUE.."B) "..AL["Entrance"].." ("..BF["Horde"]..")" };
		{ _RED.."1) "..AL["Flag"] };
		{ GREN.."1) "..BZ["Mage Tower"] };
		{ GREN.."2) "..BZ["Draenei Ruins"] };
		{ GREN.."3) "..BZ["Fel Reaver Ruins"] };
		{ GREN.."4) "..BZ["Blood Elf Tower"] };
		{ ORNG.."1) "..AL["Graveyard"] };
	};
	HalaaPvP = {
		ZoneName = { BZ["Nagrand"].." - "..BZ["Halaa"] };
		Location = { BZ["Nagrand"] };
		LevelRange = "64-85";
		MinLevel = "64";
		{ ORNG.."PvP: "..BZ["Halaa"] };
		{ GREN.."1) "..BZ["Halaa"] };
		{ GREN..INDENT..BF["Alliance"] };
		{ GREN..INDENT..BULLET..AL["Quartermaster Davian Vaclav"] };
		{ GREN..INDENT..BULLET..AL["Chief Researcher Kartos"] };
		{ GREN..INDENT..BULLET..AL["Aldraan <Blade Merchant>"] };
		{ GREN..INDENT..BULLET..AL["Cendrii <Food & Drink>"] };
		{ GREN..INDENT..BF["Horde"] };
		{ GREN..INDENT..BULLET..AL["Quartermaster Jaffrey Noreliqe"] };
		{ GREN..INDENT..BULLET..AL["Chief Researcher Amereldine"] };
		{ GREN..INDENT..BULLET..AL["Coreiel <Blade Merchant>"] };
		{ GREN..INDENT..BULLET..AL["Embelar <Food & Drink>"] };
		{ GREN.."2) "..AL["Wyvern Camp"] };
	};
	HellfirePeninsulaPvP = {
		ZoneName = { BZ["Hellfire Peninsula"].." - "..AL["Hellfire Fortifications"] };
		Location = { BZ["Hellfire Peninsula"] };
		LevelRange = "58-85";
		MinLevel = "58";
		{ ORNG.."PvP: "..AL["Hellfire Fortifications"] };
		{ GREN.."1) "..BZ["The Stadium"] };
		{ GREN.."2) "..BZ["The Overlook"] };
		{ GREN.."3) "..BZ["Broken Hill"] };
	};
	TerokkarForestPvP = {
		ZoneName = { BZ["Terokkar Forest"].." - "..AL["Spirit Towers"] };
		Location = { BZ["The Bone Wastes"]..", "..BZ["Terokkar Forest"] };
		LevelRange = "62-85";
		MinLevel = "62";
		{ ORNG.."PvP: "..BZ["Auchindoun"].." "..AL["Spirit Towers"] };
		{ GREN.."1) "..AL["Spirit Towers"] };
	};
	ZangarmarshPvP = {
		ZoneName = { BZ["Zangarmarsh"].." - "..BZ["Twin Spire Ruins"] };
		Location = { BZ["Zangarmarsh"] };
		LevelRange = "60-85";
		MinLevel = "60";
		{ ORNG.."PvP: "..BZ["Twin Spire Ruins"] };
		{ GREN.."1) "..AL["West Beacon"] };
		{ GREN.."2) "..AL["East Beacon"] };
		{ GREN.."1') "..AL["Horde Field Scout"] };
		{ GREN.."2') "..AL["Alliance Field Scout"] };
		{ ORNG.."1) "..AL["Twinspire Graveyard"] };
	};
	IsleOfConquest = {
		ZoneName = { BZ["Isle of Conquest"] };
		Location = { BZ["Icecrown"] };
		LevelRange = "75-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "75";
		PlayerLimit = "40";
		Acronym = AL["IoC"];
		{ ORNG..AL["Gates are marked with red bars."] };
		{ BLUE.."A) "..AL["Start"].." ("..BF["Horde"]..")" };
		{ GREN..INDENT..AL["Overlord Agmar"] };
		{ BLUE.."B) "..AL["Start"].." ("..BF["Alliance"]..")" };
		{ GREN..INDENT..AL["High Commander Halford Wyrmbane <7th Legion>"] };
		{ GREN.."1) "..AL["The Refinery"] };
		{ GREN.."2) "..AL["The Docks"] };
		{ GREN.."3) "..AL["The Workshop"] };
		{ GREN.."4) "..AL["The Hangar"] };
		{ GREN.."5) "..AL["The Quarry"] };
		{ ORNG.."1) "..AL["Contested Graveyards"] };
		{ ORNG.."2) "..AL["Horde Graveyard"] };
		{ ORNG.."3) "..AL["Alliance Graveyard"] };
	};
	StrandOfTheAncients = {
		ZoneName = { BZ["Strand of the Ancients"] };
		Location = { BZ["Dragonblight"] };
		LevelRange = "65-84 ("..AL["Span of 5"]..") / 85";
		MinLevel = "65";
		PlayerLimit = "15";
		Acronym = AL["SotA"];
		{ ORNG..AL["Gates are marked with their colors."] };
		{ BLUE.."A) "..AL["Start"].." ("..AL["Attacking Team"]..")" };
		{ BLUE.."B) "..AL["Start"].." ("..AL["Defending Team"]..")" };
		{ _RED.."1) "..AL["Massive Seaforium Charge"] };
		{ _RED.."2) "..AL["Titan Relic"] };
		{ GREN.."1) "..AL["Battleground Demolisher"] };
		{ GREN.."2) "..AL["Graveyard Flag"] };
		{ ORNG.."1) "..AL["Resurrection Point"] };
	};
	WintergraspPvP = {
		ZoneName = { BZ["Wintergrasp"] };
		--Location = { BZ["Wintergrasp"] };
		LevelRange = "73-85";
		MinLevel = "73";
		{ ORNG.."PvP: "..BZ["Wintergrasp"] };
		{ BLUE.."A) "..BZ["Wintergrasp Fortress"] };
		{ BLUE..INDENT..BZ["Vault of Archavon"] };
		{ BLUE.."B) "..BZ["Valiance Landing Camp"] };
		{ BLUE.."C) "..BZ["Warsong Camp"] };
		{ GREN.."1) "..BZ["Wintergrasp Fortress"] };
		{ GREN..INDENT..AL["Fortress Vihecal Workshop (E)"] };
		{ GREN..INDENT..AL["Fortress Vihecal Workshop (W)"] };
		{ GREN.."2) "..BZ["The Sunken Ring"] };
		{ GREN..INDENT..AL["Sunken Ring Vihecal Workshop"] };
		{ GREN.."3) "..BZ["The Broken Temple"] };
		{ GREN..INDENT..AL["Broken Temple Vihecal Workshop"] };
		{ GREN.."4) "..BZ["Eastspark Workshop"] };
		{ GREN..INDENT..AL["Eastspark Vihecale Workshop"] };
		{ GREN.."5) "..BZ["Westspark Workshop"] };
		{ GREN..INDENT..AL["Westspark Vihecale Workshop"] };
		{ _RED.."1) "..BZ["Flamewatch Tower"] };
		{ _RED.."2) "..BZ["Winter's Edge Tower"] };
		{ _RED.."3) "..BZ["Shadowsight Tower"] };
		{ ORNG.."1) "..AL["Wintergrasp Graveyard"] };
		{ ORNG.."2) "..AL["Sunken Ring Graveyard"] };
		{ ORNG.."3) "..AL["Broken Temple Graveyard"] };
		{ ORNG.."4) "..AL["Southeast Graveyard"] };
		{ ORNG.."5) "..AL["Southwest Graveyard"] };
	};
	TheBattleForGilneas = {
		ZoneName = { BZ["Gilneas"].." - "..BZ["The Battle for Gilneas"] };
		--Location = { BZ["Gilneas"] };
		LevelRange = "85+";
		MinLevel = "85";
		{ BLUE.."A) "..BZ["Gilnean Stronghold"].." ("..BF["Alliance"]..")" };
		{ ORNG..INDENT..AL["Alliance Graveyard"] };
		{ BLUE.."B) "..BZ["Horde Landing"].." ("..BF["Horde"]..")" };
		{ GREN.."1) "..BZ["Mines"] };
		{ GREN.."2) "..BZ["Lighthouse"] };
		{ GREN.."3) "..BZ["Waterworks"] };
		{ ORNG.."1) "..AL["Horde Graveyard"] };
		{ ORNG.."2) "..AL["Contested Graveyards"] };
	};
	TolBarad = {
		ZoneName = { BZ["Tol Barad"] };
		--Location = { BZ["Tol Barad"] };
		LevelRange = "80-85";
		MinLevel = "80";
		{ ORNG..AL["Reputation"]..": "..BF["Baradin's Wardens"].." ("..BF["Alliance"]..")" };
		{ ORNG..AL["Reputation"]..": "..BF["Hellscream's Reach"].." ("..BF["Horde"]..")" };
		{ BLUE.."A) "..AL["Attackers"] };
		{ BLUE.."B) "..BZ["Baradin Hold"] };
		{ GREN..INDENT..BF["Alliance"] };
		{ GREN..INDENT..BULLET..AL["Sergeant Parker <Baradin's Wardens>"]};
		{ GREN..INDENT..BULLET..AL["2nd Lieutenant Wansworth <Baradin's Wardens>"]};
		{ GREN..INDENT..BULLET..AL["Commander Stevens <Baradin's Wardens>"]};
		{ GREN..INDENT..BULLET..AL["Marshal Fallows <Baradin's Wardens>"]};
		{ GREN..INDENT..BF["Horde"] };
		{ GREN..INDENT..BULLET..AL["Commander Zanoth <Hellscream's Reach>"] };
		{ GREN..INDENT..BULLET..AL["Drillmaster Razgoth <Hellscream's Reach>"] };
		{ GREN..INDENT..BULLET..AL["Private Garnoth <Hellscream's Reach>"] };
		{ GREN..INDENT..BULLET..AL["Staff Sergeant Lazgar <Hellscream's Reach>"] };
		{ GREN.."1) "..BZ["Ironclad Garrison"] };
		{ GREN.."2) "..BZ["Warden's Vigil"] };
		{ GREN.."3) "..BZ["Slagworks"] };
		{ GREN.."1') "..AL["Meeting Stone"] };
		{ _RED.."1) "..BZ["West Spire"] };
		{ _RED.."2) "..BZ["East Spire"] };
		{ _RED.."3) "..BZ["South Spire"] };
		{ ORNG.."1) "..AL["Graveyard"] };
	};
	TwinPeaks = {
		ZoneName = { BZ["Twin Peaks"] };
		Location = { BZ["Twilight Highlands"] };
		LevelRange = "85+";
		MinLevel = "85";
		{ ORNG..AL["Reputation"]..": "..BF["Wildhammer Clan"].." ("..BF["Alliance"]..")" };
		{ ORNG..AL["Reputation"]..": "..BF["Dragonmaw Clan"].." ("..BF["Horde"]..")" };
		{ BLUE.."A) "..AL["Wildhammer Longhouse"].." ("..BF["Alliance"]..")" };
		{ BLUE.."B) "..AL["Dragonmaw Clan Compound"].." ("..BF["Horde"]..")" };
		{ ORNG.."1) "..AL["Alliance Graveyard"] };
		{ ORNG.."2) "..AL["Horde Graveyard"] };
	};
};

Atlas_RegisterPlugin("Atlas_Battlegrounds", myCategory, myData);
