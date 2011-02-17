-- $Id: Atlas-enUS.lua 1220 2011-01-28 13:36:29Z dynaletik $
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
local AL = AceLocale:NewLocale("Atlas", "enUS", true);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas", "deDE", false);

-- Atlas English Localization
--if ( GetLocale() ==	"enUS" ) then
-- Define the leading strings to be ignored while sorting
-- Ex: The Stockade
AtlasSortIgnore = {"the (.+)"};

AtlasZoneSubstitutions = {
	["Ahn'Qiraj"] = "Temple of Ahn'Qiraj";
	["The Temple of Atal'Hakkar"] = "Sunken Temple";
};
--end


if AL then
--************************************************
-- UI terms and common strings
--************************************************
	AL["ATLAS_TITLE"] = "Atlas";

	AL["BINDING_HEADER_ATLAS_TITLE"] = "Atlas Bindings";
	AL["BINDING_NAME_ATLAS_TOGGLE"] = "Toggle Atlas";
	AL["BINDING_NAME_ATLAS_OPTIONS"] = "Toggle Options";
	AL["BINDING_NAME_ATLAS_AUTOSEL"] = "Auto-Select";

	AL["ATLAS_SLASH"] = "/atlas";
	AL["ATLAS_SLASH_OPTIONS"] = "options";

	AL["ATLAS_STRING_LOCATION"] = "Location";
	AL["ATLAS_STRING_LEVELRANGE"] = "Level Range";
	AL["ATLAS_STRING_PLAYERLIMIT"] = "Player Limit";
	AL["ATLAS_STRING_SELECT_CAT"] = "Select Category";
	AL["ATLAS_STRING_SELECT_MAP"] = "Select Map";
	AL["ATLAS_STRING_SEARCH"] = "Search";
	AL["ATLAS_STRING_CLEAR"] = "Clear";
	AL["ATLAS_STRING_MINLEVEL"] = "Minimum Level";

	AL["ATLAS_OPTIONS_BUTTON"] = "Options";
	AL["ATLAS_OPTIONS_SHOWBUT"] = "Show Button on Minimap";
	AL["ATLAS_OPTIONS_SHOWBUT_TIP"] = "Show Atlas button around the minimap.";
	AL["ATLAS_OPTIONS_AUTOSEL"] = "Auto-Select Instance Map";
	AL["ATLAS_OPTIONS_AUTOSEL_TIP"] = "Auto-select instance map, Atlas will detect your location to choose the best instance map for you.";
	AL["ATLAS_OPTIONS_BUTPOS"] = "Button Position";
	AL["ATLAS_OPTIONS_TRANS"] = "Transparency";
	AL["ATLAS_OPTIONS_RCLICK"] = "Right-Click for World Map";
	AL["ATLAS_OPTIONS_RCLICK_TIP"] = "Enable the Right-Click in Atlas window to switch to WoW World Map.";
	AL["ATLAS_OPTIONS_RESETPOS"] = "Reset Position";
	AL["ATLAS_OPTIONS_ACRONYMS"] = "Display Acronyms";
	AL["ATLAS_OPTIONS_ACRONYMS_TIP"] = "Display the instance's acronym in the map details.";
	AL["ATLAS_OPTIONS_SCALE"] = "Scale";
	AL["ATLAS_OPTIONS_BUTRAD"] = "Button Radius";
	AL["ATLAS_OPTIONS_CLAMPED"] = "Clamp window to screen";
	AL["ATLAS_OPTIONS_CLAMPED_TIP"] = "Clamp Atlas window to screen, disable to allow Atlas window can be dragged outside the game screen.";
	AL["ATLAS_OPTIONS_CTRL"] = "Hold down Control for tooltips";
	AL["ATLAS_OPTIONS_CTRL_TIP"] = "Enable to show tooltips text while hold down control key and mouse over the map info. Useful when the text is too long to be displayed in the window.";

	AL["ATLAS_BUTTON_TOOLTIP_TITLE"] = "Atlas";
	AL["ATLAS_BUTTON_TOOLTIP_HINT"] = "Left-click to open Atlas.\nMiddle-click for Atlas options.\nRight-click and drag to move this button.";
	AL["ATLAS_LDB_HINT"] = "Left-Click to open Atlas.\nRight-Click for Atlas options.";

	AL["ATLAS_OPTIONS_CATDD"] = "Sort Instance Maps by:";
	AL["ATLAS_DDL_CONTINENT"] = "Continent";
	AL["ATLAS_DDL_CONTINENT_EASTERN"] = "Eastern Kingdoms Instances";
	AL["ATLAS_DDL_CONTINENT_KALIMDOR"] = "Kalimdor Instances";
	AL["ATLAS_DDL_CONTINENT_OUTLAND"] = "Outland Instances";
	AL["ATLAS_DDL_CONTINENT_NORTHREND"] = "Northrend Instances";
	AL["ATLAS_DDL_CONTINENT_DEEPHOLM"] = "Deepholm Instances";
	AL["ATLAS_DDL_LEVEL"] = "Level";
	AL["ATLAS_DDL_LEVEL_UNDER45"] = "Instances Under Level 45";
	AL["ATLAS_DDL_LEVEL_45TO60"] = "Instances Level 45-60";
	AL["ATLAS_DDL_LEVEL_60TO70"] = "Instances Level 60-70";
	AL["ATLAS_DDL_LEVEL_70TO80"] = "Instances Level 70-80";
	AL["ATLAS_DDL_LEVEL_80TO85"] = "Instances Level 80-85";
	AL["ATLAS_DDL_LEVEL_85PLUS"] = "Instances Level 85+";
	AL["ATLAS_DDL_PARTYSIZE"] = "Party Size";
	AL["ATLAS_DDL_PARTYSIZE_5_AE"] = "Instances for 5 Players A-E";
	AL["ATLAS_DDL_PARTYSIZE_5_FS"] = "Instances for 5 Players F-S";
	AL["ATLAS_DDL_PARTYSIZE_5_TZ"] = "Instances for 5 Players T-Z";
	AL["ATLAS_DDL_PARTYSIZE_10_AN"] = "Instances for 10 Players A-N";
	AL["ATLAS_DDL_PARTYSIZE_10_OZ"] = "Instances for 10 Players O-Z";
	AL["ATLAS_DDL_PARTYSIZE_20TO40"] = "Instances for 20-40 Players";
	AL["ATLAS_DDL_EXPANSION"] = "Expansion";
	AL["ATLAS_DDL_EXPANSION_OLD_AO"] = "Old World Instances A-O";
	AL["ATLAS_DDL_EXPANSION_OLD_PZ"] = "Old World Instances P-Z";
	AL["ATLAS_DDL_EXPANSION_BC"] = "Burning Crusade Instances";
	AL["ATLAS_DDL_EXPANSION_WOTLK"] = "Wrath of the Lich King Instances";
	AL["ATLAS_DDL_EXPANSION_CATA"] = "Cataclysm Instances";
	AL["ATLAS_DDL_TYPE"] = "Type";
	AL["ATLAS_DDL_TYPE_INSTANCE_AC"] = "Instances A-C";
	AL["ATLAS_DDL_TYPE_INSTANCE_DR"] = "Instances D-R";
	AL["ATLAS_DDL_TYPE_INSTANCE_SZ"] = "Instances S-Z";
	AL["ATLAS_DDL_TYPE_ENTRANCE"] = "Entrances";

	AL["ATLAS_INSTANCE_BUTTON"] = "Instance";
	AL["ATLAS_ENTRANCE_BUTTON"] = "Entrance";
	AL["ATLAS_SEARCH_UNAVAIL"] = "Search Unavailable";

	AL["ATLAS_DEP_MSG1"] = "Atlas has detected outdated module(s).";
	AL["ATLAS_DEP_MSG2"] = "They have been disabled for this character.";
	AL["ATLAS_DEP_MSG3"] = "Delete them from your AddOns folder.";
	AL["ATLAS_DEP_OK"] = "Ok";

--************************************************
-- Zone Names, Acronyms, and Common Strings
--************************************************

	--Common strings
	AL["East"] = "East";
	AL["North"] = "North";
	AL["South"] = "South";
	AL["West"] = "West";

	--World Events, Festival
	AL["Brewfest"] = "Brewfest";
	AL["Hallow's End"] = "Hallow's End";
	AL["Love is in the Air"] = "Love is in the Air";
	AL["Lunar Festival"] = "Lunar Festival";
	AL["Midsummer Festival"] = "Midsummer Festival";
	--Misc strings
	AL["Adult"] = "Adult";
	AL["AKA"] = "AKA";
	AL["Arcane Container"] = "Arcane Container";
	AL["Arms Warrior"] = "Arms Warrior";
	AL["Attunement Required"] = "Attunement Required";
	AL["Back"] = "Back";
	AL["Basement"] = "Basement";
	AL["Blacksmithing Plans"] = "Blacksmithing Plans";
	AL["Boss"] = "Boss";
	AL["Chase Begins"] = "Chase Begins";
	AL["Chase Ends"] = "Chase Ends";
	AL["Child"] = "Child";
	AL["Connection"] = "Connection";
	AL["DS2"] = "DS2";
	AL["Elevator"] = "Elevator";
	AL["End"] = "End";
	AL["Engineer"] = "Engineer";
	AL["Entrance"] = "Entrance";
	AL["Event"] = "Event";
	AL["Exalted"] = "Exalted";
	AL["Exit"] = "Exit";
	AL["Fourth Stop"] = "Fourth Stop";
	AL["Front"] = "Front";
	AL["Ghost"] = "Ghost";
	AL["Graveyard"] = "Graveyard";
	AL["Heroic"] = "Heroic";
	AL["Holy Paladin"] = "Holy Paladin";
	AL["Holy Priest"] = "Holy Priest";
	AL["Hunter"] = "Hunter";
	AL["Imp"] = "Imp";
	AL["Inside"] = "Inside";
	AL["Key"] = "Key";
	AL["Lower"] = "Lower";
	AL["Mage"] = "Mage";
	AL["Meeting Stone"] = "Meeting Stone";
	AL["Middle"] = "Middle";
	AL["Monk"] = "Monk";
	AL["Moonwell"] = "Moonwell";
	AL["Optional"] = "Optional";
	AL["Orange"] = "Orange";
	AL["Outside"] = "Outside";
	AL["Paladin"] = "Paladin";
	AL["Portal"] = "Portal";
	AL["Priest"] = "Priest";
	AL["Protection Warrior"] = "Protection Warrior";
	AL["Purple"] = "Purple";
	AL["Random"] = "Random";
	AL["Rare"] = "Rare";
	AL["Reputation"] = "Reputation";
	AL["Repair"] = "Repair";
	AL["Retribution Paladin"] = "Retribution Paladin";
	AL["Rewards"] = "Rewards";
	AL["Rogue"] = "Rogue";
	AL["Second Stop"] = "Second Stop";
	AL["Shadow Priest"] = "Shadow Priest";
	AL["Shaman"] = "Shaman";
	AL["Side"] = "Side";
	AL["Spawn Point"] = "Spawn Point";
	AL["Start"] = "Start";
	AL["Summon"] = "Summon";
	AL["Teleporter"] = "Teleporter";
	AL["Third Stop"] = "Third Stop";
	AL["Tiger"] = "Tiger";
	AL["Top"] = "Top";
	AL["Underwater"] = "Underwater";
	AL["Unknown"] = "Unknown";
	AL["Upper"] = "Upper";
	AL["Varies"] = "Varies";
	AL["Wanders"] = "Wanders";
	AL["Warlock"] = "Warlock";
	AL["Warrior"] = "Warrior";
	AL["Wave 5"] = "Wave 5";
	AL["Wave 6"] = "Wave 6";
	AL["Wave 10"] = "Wave 10";
	AL["Wave 12"] = "Wave 12";
	AL["Wave 18"] = "Wave 18";

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
	AL["AK, Kahet"] = "AK, Kahet"; -- Ahn'kahet
	AL["AN, Nerub"] = "AN, Nerub"; -- Azjol-Nerub
	AL["Champ"] = "Champ"; -- Trial of the Champion
	AL["CoT-Strat"] = "CoT-Strat"; -- Culling of Stratholme
	AL["Crus"] = "Crus"; -- Trial of the Crusader
	AL["DTK"] = "DTK"; -- Drak'Tharon Keep
	AL["FoS"] = "FoS"; -- The Forge of Souls
	AL["FH1"] = "FH1"; -- The Forge of Souls
	AL["Gun"] = "Gun"; -- Gundrak
	AL["HoL"] = "HoL"; -- Halls of Lightning
	AL["HoR"] = "HoR"; -- Halls of Reflection
	AL["FH3"] = "FH3"; -- Halls of Reflection
	AL["HoS"] = "HoS"; -- Halls of Stone
	AL["IC"] = "IC"; -- Icecrown Citadel
	AL["Nax"] = "Nax"; -- Naxxramas
	AL["Nex, Nexus"] = "Nex, Nexus"; -- The Nexus
	AL["Ocu"] = "Ocu"; -- The Oculus
	AL["Ony"] = "Ony"; -- Onyxia's Lair
	AL["OS"] = "OS"; -- The Obsidian Sanctum
	AL["PoS"] = "PoS"; -- Pit of Saron
	AL["FH2"] = "FH2"; -- Pit of Saron
	AL["RS"] = "RS"; -- The Ruby Sanctum
	AL["TEoE"] = "TEoE"; -- The Eye of Eternity
	AL["UK, Keep"] = "UK, Keep"; -- Utgarde Keep
	AL["Uldu"] = "Uldu"; -- Ulduar
	AL["UP, Pinn"] = "UP, Pinn"; -- Utgarde Pinnacle
	AL["VH"] = "VH"; -- The Violet Hold
	AL["VoA"] = "VoA"; -- Vault of Archavon

	--Zones not included in LibBabble-Zone
	AL["Crusaders' Coliseum"] = "Crusaders' Coliseum"; 

	--Cataclysm Acronyms
	--AL["AM"] = "AM"; --Abyssal Maw
	AL["BH"] = "BH"; --Baradin Hold
	AL["BoT"] = "BoT"; --Bastion of Twilight
	AL["BRC"] = "BRC"; --Blackrock Caverns
	AL["BWD"] = "BWD"; --Blackwing Descent
	--AL["CoT-WA"] = "CoT-WA"; --War of the Ancients
	AL["GB"] = "GB"; --Grim Batol
	AL["HoO"] = "HoO"; --Halls of Origination
	AL["LCoT"] = "LCoT"; --Lost City of the Tol'vir 
	--AL["SK"] = "SK"; --Sulfuron Keep
	AL["TSC"] = "TSC"; --The Stonecore
	AL["TWT"] = "TWT"; --Throne of the Four Winds
	AL["ToTT"] = "ToTT"; --Throne of the Tides
	AL["VP"] = "VP"; --The Vortex Pinnacle

--************************************************
-- Instance Entrance Maps
--************************************************

	--Auchindoun (Entrance)
	AL["Ha'Lei"] = "Ha'Lei";
	AL["Greatfather Aldrimus"] = "Greatfather Aldrimus";
	AL["Clarissa"] = "Clarissa";
	AL["Ramdor the Mad"] = "Ramdor the Mad";
	AL["Horvon the Armorer <Armorsmith>"] = "Horvon the Armorer <Armorsmith>";
	AL["Nexus-Prince Haramad"] = "Nexus-Prince Haramad";
	AL["Artificer Morphalius"] = "Artificer Morphalius";
	AL["Mamdy the \"Ologist\""] = "Mamdy the \"Ologist\"";
	AL["\"Slim\" <Shady Dealer>"] = "\"Slim\" <Shady Dealer>";
	AL["\"Captain\" Kaftiz"] = "\"Captain\" Kaftiz";
	AL["Isfar"] = "Isfar";
	AL["Field Commander Mahfuun"] = "Field Commander Mahfuun";
	AL["Spy Grik'tha"] = "Spy Grik'tha";
	AL["Provisioner Tsaalt"] = "Provisioner Tsaalt";
	AL["Dealer Tariq <Shady Dealer>"] = "Dealer Tariq <Shady Dealer>";

	--Blackfathom Deeps (Entrance)

	--Blackrock Mountain (Entrance)
	AL["Bodley"] = "Bodley";
	AL["Lothos Riftwaker"] = "Lothos Riftwaker";
	AL["Orb of Command"] = "Orb of Command";
	AL["Scarshield Quartermaster <Scarshield Legion>"] = "Scarshield Quartermaster <Scarshield Legion>";
	AL["The Behemoth"] = "The Behemoth";

	--Caverns of Time (Entrance)
	AL["Steward of Time <Keepers of Time>"] = "Steward of Time <Keepers of Time>";
	AL["Alexston Chrome <Tavern of Time>"] = "Alexston Chrome <Tavern of Time>";
	AL["Yarley <Armorer>"] = "Yarley <Armorer>";
	AL["Bortega <Reagents & Poison Supplies>"] = "Bortega <Reagents & Poison Supplies>";
	AL["Alurmi <Keepers of Time Quartermaster>"] = "Alurmi <Keepers of Time Quartermaster>";
	AL["Galgrom <Provisioner>"] = "Galgrom <Provisioner>";
	AL["Zaladormu"] = "Zaladormu";
	AL["Soridormi <The Scale of Sands>"] = "Soridormi <The Scale of Sands>";
	AL["Arazmodu <The Scale of Sands>"] = "Arazmodu <The Scale of Sands>";
	AL["Andormu <Keepers of Time>"] = "Andormu <Keepers of Time>";
	AL["Nozari <Keepers of Time>"] = "Nozari <Keepers of Time>";
	AL["Anachronos <Keepers of Time>"] = "Anachronos <Keepers of Time>";

	--Caverns of Time: Hyjal (Entrance)
	AL["Indormi <Keeper of Ancient Gem Lore>"] = "Indormi <Keeper of Ancient Gem Lore>";
	AL["Tydormu <Keeper of Lost Artifacts>"] = "Tydormu <Keeper of Lost Artifacts>";

	--Coilfang Reservoir (Entrance)
	AL["Watcher Jhang"] = "Watcher Jhang";
	AL["Mortog Steamhead"] = "Mortog Steamhead";

	--Dire Maul (Entrance)
	AL["Dire Pool"] = "Dire Pool";
	AL["Dire Maul Arena"] = "Dire Maul Arena";
	AL["Elder Mistwalker"] = "Elder Mistwalker";

	--Gnomeregan (Entrance)
	AL["Torben Zapblast <Teleportation Specialist>"] = "Torben Zapblast <Teleportation Specialist>";

	--Hellfire Citadel (Entrance)
	AL["Steps and path to the Blood Furnace"] = "Steps and path to the Blood Furnace";
	AL["Path to the Hellfire Ramparts and Shattered Halls"] = "Path to the Hellfire Ramparts and Shattered Halls";
	AL["Meeting Stone of Magtheridon's Lair"] = "Meeting Stone of Magtheridon's Lair";
	AL["Meeting Stone of Hellfire Citadel"] = "Meeting Stone of Hellfire Citadel";

	--Icecrown Citadel (Entrance)

	--Karazhan (Entrance)
	AL["Archmage Leryda"] = "Archmage Leryda";
	AL["Archmage Alturus"] = "Archmage Alturus";
	AL["Apprentice Darius"] = "Apprentice Darius";
	AL["Stairs to Underground Pond"] = "Stairs to Underground Pond";
	AL["Stairs to Underground Well"] = "Stairs to Underground Well";
	AL["Charred Bone Fragment"] = "Charred Bone Fragment";

	--Maraudon (Entrance)
	AL["The Nameless Prophet"] = "The Nameless Prophet";

	--Scarlet Monastery (Entrance)

	--The Deadmines (Entrance)

	--Sunken Temple (Entrance)
	AL["Priestess Udum'bra"] = "Priestess Udum'bra";
	AL["Gomora the Bloodletter"] = "Gomora the Bloodletter";

	--Uldaman (Entrance)

	--Ulduar (Entrance)
	AL["Shavalius the Fancy <Flight Master>"] = "Shavalius the Fancy <Flight Master>";
	AL["Chester Copperpot <General & Trade Supplies>"] = "Chester Copperpot <General & Trade Supplies>";
	AL["Slosh <Food & Drink>"] = "Slosh <Food & Drink>";

	--Wailing Caverns (Entrance)

--************************************************
-- Kalimdor Instances (Classic)
--************************************************

	--Blackfathom Deeps
	AL["Shrine of Gelihast"] = "Shrine of Gelihast";
	AL["Fathom Stone"] = "Fathom Stone";
	AL["Lorgalis Manuscript"] = "Lorgalis Manuscript";
	AL["Scout Thaelrid"] = "Scout Thaelrid";
	AL["Flaming Eradicator"] = "Flaming Eradicator";
	AL["Altar of the Deeps"] = "Altar of the Deeps";
	AL["Ashelan Northwood"] = "Ashelan Northwood";
	AL["Relwyn Shadestar"] = "Relwyn Shadestar";
	AL["Sentinel Aluwyn"] = "Sentinel Aluwyn";
	AL["Sentinel-trainee Issara"] = "Sentinel-trainee Issara";
	AL["Je'neu Sancrea <The Earthen Ring>"] = "Je'neu Sancrea <The Earthen Ring>";
	AL["Zeya"] = "Zeya";

	--Dire Maul (East)
	AL["\"Ambassador\" Dagg'thol"] = "\"Ambassador\" Dagg'thol";
	AL["Furgus Warpwood"] = "Furgus Warpwood";
	AL["Old Ironbark"] = "Old Ironbark";
	AL["Ironbark the Redeemed"] = "Ironbark the Redeemed";

	--Dire Maul (North)
	AL["Druid of the Talon"] = "Druid of the Talon";
	AL["Stonemaul Ogre"] = "Stonemaul Ogre";
	AL["Knot Thimblejack"] = "Knot Thimblejack";

	--Dire Maul (West)
	AL["J'eevee's Jar"] = "J'eevee's Jar";
	AL["Ferra"] = "Ferra";
	AL["Estulan <The Highborne>"] = "Estulan <The Highborne>";
	AL["Shen'dralar Watcher"] = "Shen'dralar Watcher";
	AL["Pylons"] = "Pylons";
	AL["Ancient Equine Spirit"] = "Ancient Equine Spirit";
	AL["Shen'dralar Ancient"] = "Shen'dralar Ancient";
	AL["Falrin Treeshaper"] = "Falrin Treeshaper";
	AL["Lorekeeper Lydros"] = "Lorekeeper Lydros";
	AL["Lorekeeper Javon"] = "Lorekeeper Javon";
	AL["Lorekeeper Kildrath"] = "Lorekeeper Kildrath";
	AL["Lorekeeper Mykos"] = "Lorekeeper Mykos";
	AL["Shen'dralar Provisioner"] = "Shen'dralar Provisioner";

	--Maraudon	
	AL["Elder Splitrock"] = "Elder Splitrock";

	--Ragefire Chasm
	AL["Bovaal Whitehorn"] = "Bovaal Whitehorn";
	AL["Stone Guard Kurjack"] = "Stone Guard Kurjack";

	--Razorfen Downs
	AL["Koristrasza"] = "Koristrasza";
	AL["Belnistrasz"] = "Belnistrasz";

	--Razorfen Kraul
	AL["Auld Stonespire"] = "Auld Stonespire";
	AL["Razorfen Spearhide"] = "Razorfen Spearhide";
	AL["Spirit of Agamaggan <Ancient>"] = "Spirit of Agamaggan <Ancient>";
	AL["Willix the Importer"] = "Willix the Importer";

	--Ruins of Ahn'Qiraj
	AL["Four Kaldorei Elites"] = "Four Kaldorei Elites";
	AL["Captain Qeez"] = "Captain Qeez";
	AL["Captain Tuubid"] = "Captain Tuubid";
	AL["Captain Drenn"] = "Captain Drenn";
	AL["Captain Xurrem"] = "Captain Xurrem";
	AL["Major Yeggeth"] = "Major Yeggeth";
	AL["Major Pakkon"] = "Major Pakkon";
	AL["Colonel Zerran"] = "Colonel Zerran";
	AL["Safe Room"] = "Safe Room";

	--Temple of Ahn'Qiraj
	AL["Andorgos <Brood of Malygos>"] = "Andorgos <Brood of Malygos>";
	AL["Vethsera <Brood of Ysera>"] = "Vethsera <Brood of Ysera>";
	AL["Kandrostrasz <Brood of Alexstrasza>"] = "Kandrostrasz <Brood of Alexstrasza>";
	AL["Arygos"] = "Arygos";
	AL["Caelestrasz"] = "Caelestrasz";
	AL["Merithra of the Dream"] = "Merithra of the Dream";

	--Wailing Caverns
	AL["Disciple of Naralex"] = "Disciple of Naralex";

	--Zul'Farrak
	AL["Chief Engineer Bilgewhizzle <Gadgetzan Water Co.>"] = "Chief Engineer Bilgewhizzle <Gadgetzan Water Co.>";
	AL["Mazoga's Spirit"] = "Mazoga's Spirit";
	AL["Tran'rek"] = "Tran'rek";
	AL["Weegli Blastfuse"] = "Weegli Blastfuse";
	AL["Raven"] = "Raven";
	AL["Elder Wildmane"] = "Elder Wildmane";

--****************************
-- Eastern Kingdoms Instances (Classic)
--****************************

	--Blackrock Depths
	AL["Relic Coffer Key"] = "Relic Coffer Key";
	AL["Dark Keeper Key"] = "Dark Keeper Key";
	AL["The Black Anvil"] = "The Black Anvil";
	AL["The Vault"] = "The Vault";
	AL["Watchman Doomgrip"] = "Watchman Doomgrip";
	AL["High Justice Grimstone"] = "High Justice Grimstone";
	AL["Elder Morndeep"] = "Elder Morndeep";
	AL["Schematic: Field Repair Bot 74A"] = "Schematic: Field Repair Bot 74A";
	AL["Private Rocknot"] = "Private Rocknot";
	AL["Mistress Nagmara"] = "Mistress Nagmara";
	AL["Summoner's Tomb"] = "Summoner's Tomb";
	AL["Jalinda Sprig <Morgan's Militia>"] = "Jalinda Sprig <Morgan's Militia>";
	AL["Oralius <Morgan's Militia>"] = "Oralius <Morgan's Militia>";
	AL["Thal'trak Proudtusk <Kargath Expeditionary Force>"] = "Thal'trak Proudtusk <Kargath Expeditionary Force>";
	AL["Galamav the Marksman <Kargath Expeditionary Force>"] = "Galamav the Marksman <Kargath Expeditionary Force>";
	AL["Maxwort Uberglint"] = "Maxwort Uberglint";
	AL["Tinkee Steamboil"] = "Tinkee Steamboil";
	AL["Yuka Screwspigot <Engineering Supplies>"] = "Yuka Screwspigot <Engineering Supplies>";
	AL["Abandonded Mole Machine"] = "Abandonded Mole Machine";
	AL["Kevin Dawson <Morgan's Militia>"] = "Kevin Dawson <Morgan's Militia>";
	AL["Lexlort <Kargath Expeditionary Force>"] = "Lexlort <Kargath Expeditionary Force>";
	AL["Prospector Seymour <Morgan's Militia>"] = "Prospector Seymour <Morgan's Militia>";
	AL["Razal'blade <Kargath Expeditionary Force>"] = "Razal'blade <Kargath Expeditionary Force>";
	AL["The Shadowforge Lock"] = "The Shadowforge Lock";
	AL["Mayara Brightwing <Morgan's Militia>"] = "Mayara Brightwing <Morgan's Militia>";
	AL["Hierophant Theodora Mulvadania <Kargath Expeditionary Force>"] = "Hierophant Theodora Mulvadania <Kargath Expeditionary Force>";
	AL["Lokhtos Darkbargainer <The Thorium Brotherhood>"] = "Lokhtos Darkbargainer <The Thorium Brotherhood>";
	AL["Mountaineer Orfus <Morgan's Militia>"] = "Mountaineer Orfus <Morgan's Militia>";
	AL["Thunderheart <Kargath Expeditionary Force>"] = "Thunderheart <Kargath Expeditionary Force>";
	AL["Marshal Maxwell <Morgan's Militia>"] = "Marshal Maxwell <Morgan's Militia>";
	AL["Warlord Goretooth <Kargath Expeditionary Force>"] = "Warlord Goretooth <Kargath Expeditionary Force>";
	AL["The Black Forge"] = "The Black Forge";
	AL["Core Fragment"] = "Core Fragment";
	AL["Shadowforge Brazier"] = "Shadowforge Brazier";

	--Blackrock Spire (Lower)
	AL["Urok's Tribute Pile"] = "Urok's Tribute Pile";
	AL["Acride <Scarshield Legion>"] = "Acride <Scarshield Legion>";
	AL["Elder Stonefort"] = "Elder Stonefort";
	AL["Roughshod Pike"] = "Roughshod Pike";

	--Blackrock Spire (Upper)
	AL["Finkle Einhorn"] = "Finkle Einhorn";
	AL["Drakkisath's Brand"] = "Drakkisath's Brand";
	AL["Father Flame"] = "Father Flame";

	--Blackwing Lair
	AL["Orb of Domination"] = "Orb of Domination";
	AL["Master Elemental Shaper Krixix"] = "Master Elemental Shaper Krixix";

	--Gnomeregan
	AL["Chomper"] = "Chomper";
	AL["Blastmaster Emi Shortfuse"] = "Blastmaster Emi Shortfuse";
	AL["Murd Doc <S.A.F.E.>"] = "Murd Doc <S.A.F.E.>";
	AL["Tink Sprocketwhistle <Engineering Supplies>"] = "Tink Sprocketwhistle <Engineering Supplies>";
	AL["The Sparklematic 5200"] = "The Sparklematic 5200";
	AL["Mail Box"] = "Mail Box";
	AL["B.E Barechus <S.A.F.E.>"] = "B.E Barechus <S.A.F.E.>";
	AL["Face <S.A.F.E.>"] = "Face <S.A.F.E.>";
	AL["Hann Ibal <S.A.F.E.>"] = "Hann Ibal <S.A.F.E.>";

	--Molten Core

	--Scholomance
	AL["Blood of Innocents"] = "Blood of Innocents";
	AL["Divination Scryer"] = "Divination Scryer";
	AL["Alexi Barov <House of Barov>"] = "Alexi Barov <House of Barov>";
	AL["Weldon Barov <House of Barov>"] = "Weldon Barov <House of Barov>";
	AL["Eva Sarkhoff"] = "Eva Sarkhoff";
	AL["Lucien Sarkhoff"] = "Lucien Sarkhoff";
	AL["The Deed to Caer Darrow"] = "The Deed to Caer Darrow";	
	AL["The Deed to Southshore"] = "The Deed to Southshore";
	AL["Torch Lever"] = "Torch Lever";
	AL["The Deed to Tarren Mill"] = "The Deed to Tarren Mill";
	AL["The Deed to Brill"] = "The Deed to Brill";

	--Shadowfang Keep
	AL["Apothecary Trio"] = "Apothecary Trio";
	AL["Apothecary Hummel <Crown Chemical Co.>"] = "Apothecary Hummel <Crown Chemical Co.>";
	AL["Apothecary Baxter <Crown Chemical Co.>"] = "Apothecary Baxter <Crown Chemical Co.>";
	AL["Apothecary Frye <Crown Chemical Co.>"] = "Apothecary Frye <Crown Chemical Co.>";
	AL["Packleader Ivar Bloodfang"] = "Packleader Ivar Bloodfang";
	AL["Deathstalker Commander Belmont"] = "Deathstalker Commander Belmont";
	AL["Haunted Stable Hand"] = "Haunted Stable Hand";
	AL["Investigator Fezzen Brasstacks"] = "Investigator Fezzen Brasstacks";

	--SM: Armory
	AL["Joseph the Crazed"] = "Joseph the Crazed";
	AL["Dark Ranger Velonara"] = "Dark Ranger Velonara";
	AL["Dominic"] = "Dominic";

	--SM: Cathedral
	AL["Cathedral"] = "Cathedral"; -- Subzone of Scarlet Monastery
	AL["Joseph the Insane <Scarlet Champion>"] = "Joseph the Insane <Scarlet Champion>";

	--SM: Graveyard
	AL["Vorrel Sengutz"] = "Vorrel Sengutz";
	AL["Pumpkin Shrine"] = "Pumpkin Shrine";
	AL["Joseph the Awakened"] = "Joseph the Awakened";

	--SM: Library
	AL["Library"] = "Library";
	AL["Compendium of the Fallen"] = "Compendium of the Fallen";

	--Stratholme - Crusader's Square
	AL["Various Postbox Keys"] = "Various Postbox Keys";
	AL["Crusade Commander Eligor Dawnbringer <Brotherhood of the Light>"] = "Crusade Commander Eligor Dawnbringer <Brotherhood of the Light>";
	AL["Master Craftsman Wilhelm <Brotherhood of the Light>"] = "Master Craftsman Wilhelm <Brotherhood of the Light>";
	AL["Packmaster Stonebruiser <Brotherhood of the Light>"] = "Packmaster Stonebruiser <Brotherhood of the Light>";
	AL["Stratholme Courier"] = "Stratholme Courier";
	AL["Fras Siabi's Postbox"] = "Fras Siabi's Postbox";
	AL["King's Square Postbox"] = "King's Square Postbox";
	AL["Festival Lane Postbox"] = "Festival Lane Postbox";
	AL["Elder Farwhisper"] = "Elder Farwhisper";
	AL["Market Row Postbox"] = "Market Row Postbox";
	AL["Crusaders' Square Postbox"] = "Crusaders' Square Postbox";

	--Stratholme - The Gauntlet
	AL["Elders' Square Postbox"] = "Elders' Square Postbox";
	AL["Archmage Angela Dosantos <Brotherhood of the Light>"] = "Archmage Angela Dosantos <Brotherhood of the Light>";
	AL["Crusade Commander Korfax <Brotherhood of the Light>"] = "Crusade Commander Korfax <Brotherhood of the Light>";

	--The Deadmines
	AL["Lumbering Oaf"] = "Lumbering Oaf";
	AL["Lieutenant Horatio Laine"] = "Lieutenant Horatio Laine";
	AL["Kagtha"] = "Kagtha";
	AL["Slinky Sharpshiv"] = "Slinky Sharpshiv";
	AL["Quartermaster Lewis <Quartermaster>"] = "Quartermaster Lewis <Quartermaster>";
	AL["Miss Mayhem"] = "Miss Mayhem";
	AL["Vend-O-Tron D-Luxe"] = "Vend-O-Tron D-Luxe";

	--The Stockade
	AL["Rifle Commander Coe"] = "Rifle Commander Coe";
	AL["Warden Thelwater"] = "Warden Thelwater";
	AL["Nurse Lillian"] = "Nurse Lillian";

	--The Sunken Temple
	AL["Lord Itharius"] = "Lord Itharius";
	AL["Elder Starsong"] = "Elder Starsong";

	--Uldaman
	AL["Staff of Prehistoria"] = "Staff of Prehistoria";
	AL["Baelog's Chest"] = "Baelog's Chest";
	AL["Kand Sandseeker <Explorer's League>"] = "Kand Sandseeker <Explorer's League>";
	AL["Lead Prospector Durdin <Explorer's League>"] = "Lead Prospector Durdin <Explorer's League>";
	AL["Olga Runesworn <Explorer's League>"] = "Olga Runesworn <Explorer's League>";
	AL["Aoren Sunglow <The Reliquary>"] = "Aoren Sunglow <The Reliquary>";
	AL["High Examiner Tae'thelan Bloodwatcher <The Reliquary>"] = "High Examiner Tae'thelan Bloodwatcher <The Reliquary>";
	AL["Lidia Sunglow <The Reliquary>"] = "Lidia Sunglow <The Reliquary>";
	AL["Ancient Treasure"] = "Ancient Treasure";
	AL["The Discs of Norgannon"] = "The Discs of Norgannon";

--*******************
-- Burning Crusade Instances
--*******************

	--Auch: Auchenai Crypts
	AL["Auchenai Key"] = "Auchenai Key";
	AL["Avatar of the Martyred"] = "Avatar of the Martyred";
	AL["D'ore"] = "D'ore";

	--Auch: Mana-Tombs
	AL["The Eye of Haramad"] = "The Eye of Haramad";
	AL["Shadow Lord Xiraxis"] = "Shadow Lord Xiraxis";
	AL["Ambassador Pax'ivi"] = "Ambassador Pax'ivi";
	AL["Cryo-Engineer Sha'heen"] = "Cryo-Engineer Sha'heen";
	AL["Ethereal Transporter Control Panel"] = "Ethereal Transporter Control Panel";

	--Auch: Sethekk Halls
	AL["Lakka"] = "Lakka";
	AL["The Saga of Terokk"] = "The Saga of Terokk";

	--Auch: Shadow Labyrinth
	AL["The Codex of Blood"] = "The Codex of Blood";
	AL["First Fragment Guardian"] = "First Fragment Guardian";
	AL["Spy To'gun"] = "Spy To'gun";

	--Black Temple (Start)
	AL["Towards Reliquary of Souls"] = "Towards Reliquary of Souls";
	AL["Towards Teron Gorefiend"] = "Towards Teron Gorefiend";
	AL["Towards Illidan Stormrage"] = "Towards Illidan Stormrage";
	AL["Spirit of Olum"] = "Spirit of Olum";
	AL["Spirit of Udalo"] = "Spirit of Udalo";
	AL["Aluyen <Reagents>"] = "Aluyen <Reagents>";
	AL["Okuno <Ashtongue Deathsworn Quartermaster>"] = "Okuno <Ashtongue Deathsworn Quartermaster>";
	AL["Seer Kanai"] = "Seer Kanai";

	--Black Temple (Basement)

	--Black Temple (Top)

	--CFR: Serpentshrine Cavern
	AL["Seer Olum"] = "Seer Olum";

	--CFR: The Slave Pens
	AL["Reservoir Key"] = "Reservoir Key";
	AL["Weeder Greenthumb"] = "Weeder Greenthumb";
	AL["Skar'this the Heretic"] = "Skar'this the Heretic";
	AL["Naturalist Bite"] = "Naturalist Bite";

	--CFR: The Steamvault
	AL["Main Chambers Access Panel"] = "Main Chambers Access Panel";
	AL["Second Fragment Guardian"] = "Second Fragment Guardian";

	--CFR: The Underbog
	AL["The Underspore"] = "The Underspore";
	AL["Earthbinder Rayge"] = "Earthbinder Rayge";

	--CoT: The Black Morass
	AL["Opening of the Dark Portal"] = "Opening of the Dark Portal";
	AL["Key of Time"] = "Key of Time";
	AL["Sa'at <Keepers of Time>"] = "Sa'at <Keepers of Time>";
	AL["The Dark Portal"] = "The Dark Portal";

	--CoT: Hyjal Summit
	AL["Battle for Mount Hyjal"] = "Battle for Mount Hyjal";
	AL["Alliance Base"] = "Alliance Base";
	AL["Lady Jaina Proudmoore"] = "Lady Jaina Proudmoore";
	AL["Horde Encampment"] = "Horde Encampment";
	AL["Thrall <Warchief>"] = "Thrall <Warchief>";
	AL["Night Elf Village"] = "Night Elf Village";
	AL["Tyrande Whisperwind <High Priestess of Elune>"] = "Tyrande Whisperwind <High Priestess of Elune>";

	--CoT: Old Hillsbrad Foothills
	AL["Escape from Durnholde Keep"] = "Escape from Durnholde Keep";
	AL["Erozion"] = "Erozion";
	AL["Brazen"] = "Brazen";
	AL["Landing Spot"] = "Landing Spot";
	AL["Thrall"] = "Thrall";
	AL["Taretha"] = "Taretha";
	AL["Don Carlos"] = "Don Carlos";
	AL["Guerrero"] = "Guerrero";
	AL["Thomas Yance <Travelling Salesman>"] = "Thomas Yance <Travelling Salesman>";
	AL["Aged Dalaran Wizard"] = "Aged Dalaran Wizard";
	AL["Jonathan Revah"] = "Jonathan Revah";
	AL["Jerry Carter"] = "Jerry Carter";
	AL["Helcular"] = "Helcular";
	AL["Farmer Kent"] = "Farmer Kent";
	AL["Sally Whitemane"] = "Sally Whitemane";
	AL["Renault Mograine"] = "Renault Mograine";
	AL["Little Jimmy Vishas"] = "Little Jimmy Vishas";
	AL["Herod the Bully"] = "Herod the Bully";
	AL["Nat Pagle"] = "Nat Pagle";
	AL["Hal McAllister"] = "Hal McAllister";
	AL["Zixil <Aspiring Merchant>"] = "Zixil <Aspiring Merchant>";
	AL["Overwatch Mark 0 <Protector>"] = "Overwatch Mark 0 <Protector>";
	AL["Southshore Inn"] = "Southshore Inn";
	AL["Captain Edward Hanes"] = "Captain Edward Hanes";
	AL["Captain Sanders"] = "Captain Sanders";
	AL["Commander Mograine"] = "Commander Mograine";
	AL["Isillien"] = "Isillien";
	AL["Abbendis"] = "Abbendis";
	AL["Fairbanks"] = "Fairbanks";
	AL["Taelan"] = "Taelan";
	AL["Barkeep Kelly <Bartender>"] = "Barkeep Kelly <Bartender>";
	AL["Frances Lin <Barmaid>"] = "Frances Lin <Barmaid>";
	AL["Chef Jessen <Speciality Meat & Slop>"] = "Chef Jessen <Speciality Meat & Slop>";
	AL["Stalvan Mistmantle"] = "Stalvan Mistmantle";
	AL["Phin Odelic <The Kirin Tor>"] = "Phin Odelic <The Kirin Tor>";
	AL["Magistrate Henry Maleb"] = "Magistrate Henry Maleb";
	AL["Raleigh the True"] = "Raleigh the True";
	AL["Nathanos Marris"] = "Nathanos Marris";
	AL["Bilger the Straight-laced"] = "Bilger the Straight-laced";
	AL["Innkeeper Monica"] = "Innkeeper Monica";
	AL["Julie Honeywell"] = "Julie Honeywell";
	AL["Jay Lemieux"] = "Jay Lemieux";
	AL["Young Blanchy"] = "Young Blanchy";

	--Gruul's Lair

	--HFC: The Blood Furnace
	AL["Flamewrought Key"] = "Flamewrought Key";

	--HFC: Hellfire Ramparts
	AL["Reinforced Fel Iron Chest"] = "Reinforced Fel Iron Chest";

	--HFC: Magtheridon's Lair

	--HFC: The Shattered Halls
	AL["Shattered Hand Executioner"] = "Shattered Hand Executioner";
	AL["Private Jacint"] = "Private Jacint";
	AL["Rifleman Brownbeard"] = "Rifleman Brownbeard";
	AL["Captain Alina"] = "Captain Alina";
	AL["Scout Orgarr"] = "Scout Orgarr";
	AL["Korag Proudmane"] = "Korag Proudmane";
	AL["Captain Boneshatter"] = "Captain Boneshatter";
	AL["Randy Whizzlesprocket"] = "Randy Whizzlesprocket";
	AL["Drisella"] = "Drisella";

	--Karazhan Start
	AL["The Master's Key"] = "The Master's Key";
	AL["Baroness Dorothea Millstipe"] = "Baroness Dorothea Millstipe";
	AL["Lady Catriona Von'Indi"] = "Lady Catriona Von'Indi";
	AL["Lady Keira Berrybuck"] = "Lady Keira Berrybuck";
	AL["Baron Rafe Dreuger"] = "Baron Rafe Dreuger";
	AL["Lord Robin Daris"] = "Lord Robin Daris";
	AL["Lord Crispin Ference"] = "Lord Crispin Ference";
	AL["Red Riding Hood"] = "Red Riding Hood";
	AL["Wizard of Oz"] = "Wizard of Oz";
	AL["The Master's Terrace"] = "The Master's Terrace";
	AL["Servant Quarters"] = "Servant Quarters";
	AL["Hastings <The Caretaker>"] = "Hastings <The Caretaker>";
	AL["Berthold <The Doorman>"] = "Berthold <The Doorman>";
	AL["Calliard <The Nightman>"] = "Calliard <The Nightman>";
	AL["Koren <The Blacksmith>"] = "Koren <The Blacksmith>";
	AL["Bennett <The Sergeant at Arms>"] = "Bennett <The Sergeant at Arms>";
	AL["Keanna's Log"] = "Keanna's Log";
	AL["Ebonlocke <The Noble>"] = "Ebonlocke <The Noble>";
	AL["Sebastian <The Organist>"] = "Sebastian <The Organist>";
	AL["Barnes <The Stage Manager>"] = "Barnes <The Stage Manager>";

	--Karazhan End
	AL["Path to the Broken Stairs"] = "Path to the Broken Stairs";
	AL["Broken Stairs"] = "Broken Stairs";
	AL["Ramp to Guardian's Library"] = "Ramp to Guardian's Library";
	AL["Suspicious Bookshelf"] = "Suspicious Bookshelf";
	AL["Ramp up to the Celestial Watch"] = "Ramp up to the Celestial Watch";
	AL["Ramp down to the Gamesman's Hall"] = "Ramp down to the Gamesman's Hall";
	AL["Ramp to Medivh's Chamber"] = "Ramp to Medivh's Chamber";
	AL["Spiral Stairs to Netherspace"] = "Spiral Stairs to Netherspace";
	AL["Wravien <The Mage>"] = "Wravien <The Mage>";
	AL["Gradav <The Warlock>"] = "Gradav <The Warlock>";
	AL["Kamsis <The Conjurer>"] = "Kamsis <The Conjurer>";
	AL["Ythyar"] = "Ythyar";
	AL["Echo of Medivh"] = "Echo of Medivh";

	--Magisters Terrace
	AL["Fel Crystals"] = "Fel Crystals";
	AL["Apoko"] = "Apoko";
	AL["Eramas Brightblaze"] = "Eramas Brightblaze";
	AL["Ellrys Duskhallow"] = "Ellrys Duskhallow";
	AL["Fizzle"] = "Fizzle";
	AL["Garaxxas"] = "Garaxxas";
	AL["Sliver <Garaxxas' Pet>"] = "Sliver <Garaxxas' Pet>";
	AL["Kagani Nightstrike"] = "Kagani Nightstrike";
	AL["Warlord Salaris"] = "Warlord Salaris";
	AL["Yazzai"] = "Yazzai";
	AL["Zelfan"] = "Zelfan";
	AL["Tyrith"] = "Tyrith";
	AL["Scrying Orb"] = "Scrying Orb";

	--Sunwell Plateau
	AL["Madrigosa"] = "Madrigosa";

	--TK: The Arcatraz
	AL["Warpforged Key"] = "Warpforged Key";
	AL["Millhouse Manastorm"] = "Millhouse Manastorm";
	AL["Third Fragment Guardian"] = "Third Fragment Guardian";
	AL["Udalo"] = "Udalo";

	--TK: The Botanica

	--TK: The Mechanar
	AL["Overcharged Manacell"] = "Overcharged Manacell";

	--TK: The Eye

	--Zul'Aman
	AL["Harrison Jones"] = "Harrison Jones";
	AL["Tanzar"] = "Tanzar";
	AL["The Map of Zul'Aman"] = "The Map of Zul'Aman";
	AL["Harkor"] = "Harkor";
	AL["Kraz"] = "Kraz";
	AL["Ashli"] = "Ashli";
	AL["Thurg"] = "Thurg";
	AL["Gazakroth"] = "Gazakroth";
	AL["Lord Raadan"] = "Lord Raadan";
	AL["Darkheart"] = "Darkheart";
	AL["Alyson Antille"] = "Alyson Antille";
	AL["Slither"] = "Slither";
	AL["Fenstalker"] = "Fenstalker";
	AL["Koragg"] = "Koragg";
	AL["Zungam"] = "Zungam";
	AL["Forest Frogs"] = "Forest Frogs";
	AL["Kyren <Reagents>"] = "Kyren <Reagents>";
	AL["Gunter <Food Vendor>"] = "Gunter <Food Vendor>";
	AL["Adarrah"] = "Adarrah";
	AL["Brennan"] = "Brennan";
	AL["Darwen"] = "Darwen";
	AL["Deez"] = "Deez";
	AL["Galathryn"] = "Galathryn";
	AL["Mitzi"] = "Mitzi";
	AL["Mannuth"] = "Mannuth";

--*****************
-- WotLK Instances
--*****************

	--Azjol-Nerub: Ahn'kahet: The Old Kingdom
	AL["Ahn'kahet Brazier"] = "Ahn'kahet Brazier";

	--Azjol-Nerub: Azjol-Nerub
	AL["Watcher Gashra"] = "Watcher Gashra";
	AL["Watcher Narjil"] = "Watcher Narjil";
	AL["Watcher Silthik"] = "Watcher Silthik";
	AL["Elder Nurgen"] = "Elder Nurgen";	

	--Caverns of Time: The Culling of Stratholme
	AL["The Culling of Stratholme"] = "The Culling of Stratholme";
	AL["Scourge Invasion Points"] = "Scourge Invasion Points";
	AL["Guardian of Time"] = "Guardian of Time";
	AL["Chromie"] = "Chromie";

	--Drak'Tharon Keep
	AL["Kurzel"] = "Kurzel";
	AL["Elder Kilias"] = "Elder Kilias";
	AL["Drakuru's Brazier"] = "Drakuru's Brazier";

	--The Frozen Halls: Halls of Reflection
	--3 beginning NPCs omitted, see The Forge of Souls
	AL["Wrath of the Lich King"] = "Wrath of the Lich King";
	AL["The Captain's Chest"] = "The Captain's Chest";

	--The Frozen Halls: Pit of Saron
	--6 beginning NPCs omitted, see The Forge of Souls
	AL["Martin Victus"] = "Martin Victus";
	AL["Gorkun Ironskull"] = "Gorkun Ironskull";
	AL["Rimefang"] = "Rimefang";

	--The Frozen Halls: The Forge of Souls
	--Lady Jaina Proudmoore omitted, in Hyjal Summit
	AL["Archmage Koreln <Kirin Tor>"] = "Archmage Koreln <Kirin Tor>";
	AL["Archmage Elandra <Kirin Tor>"] = "Archmage Elandra <Kirin Tor>";
	AL["Lady Sylvanas Windrunner <Banshee Queen>"] = "Lady Sylvanas Windrunner <Banshee Queen>";
	AL["Dark Ranger Loralen"] = "Dark Ranger Loralen";
	AL["Dark Ranger Kalira"] = "Dark Ranger Kalira";

	--Gundrak
	AL["Elder Ohanzee"] = "Elder Ohanzee";

	--Icecrown Citadel
	AL["To next map"] = "To next map";
	AL["From previous map"] = "From previous map";
	AL["Upper Spire"] = "Upper Spire";
	AL["Sindragosa's Lair"] = "Sindragosa's Lair";
	AL["Stinky"] = "Stinky";
	AL["Precious"] = "Precious";

	--Naxxramas
	AL["Mr. Bigglesworth"] = "Mr. Bigglesworth";
	AL["Frostwyrm Lair"] = "Frostwyrm Lair";
	AL["Teleporter to Middle"] = "Teleporter to Middle";

	--The Obsidian Sanctum
	AL["Black Dragonflight Chamber"] = "Black Dragonflight Chamber";

	--Onyxia's Lair

	--The Ruby Sanctum
	AL["Red Dragonflight Chamber"] = "Red Dragonflight Chamber";

	--The Nexus: The Eye of Eternity
	AL["Key to the Focusing Iris"] = "Key to the Focusing Iris";

	--The Nexus: The Nexus
	AL["Berinand's Research"] = "Berinand's Research";
	AL["Elder Igasho"] = "Elder Igasho";

	--The Nexus: The Oculus
	AL["Centrifuge Construct"] = "Centrifuge Construct";
	AL["Cache of Eregos"] = "Cache of Eregos";

	--Trial of the Champion
	AL["Champions of the Alliance"] = "Champions of the Alliance";
	AL["Marshal Jacob Alerius"] = "Marshal Jacob Alerius";
	AL["Ambrose Boltspark"] = "Ambrose Boltspark";
	AL["Colosos"] = "Colosos";
	AL["Jaelyne Evensong"] = "Jaelyne Evensong";
	AL["Lana Stouthammer"] = "Lana Stouthammer";
	AL["Champions of the Horde"] = "Champions of the Horde";

	--Trial of the Crusader
	AL["Heroic: Trial of the Grand Crusader"] = "Heroic: Trial of the Grand Crusader";
	AL["Cavern Entrance"] = "Cavern Entrance";

	--Ulduar General
	AL["Celestial Planetarium Key"] = "Celestial Planetarium Key";
	AL["The Siege"] = "The Siege";
	AL["The Keepers"] = "The Keepers";

	--Ulduar A
	AL["Tower of Life"] = "Tower of Life";
	AL["Tower of Flame"] = "Tower of Flame";
	AL["Tower of Frost"] = "Tower of Frost";
	AL["Tower of Storms"] = "Tower of Storms";

	--Ulduar B
	AL["Prospector Doren"] = "Prospector Doren";
	AL["Archivum Console"] = "Archivum Console";

	--Ulduar C
	AL["Sif"] = "Sif";

	--Ulduar D

	--Ulduar E

	--Ulduar: Halls of Lightning

	--Ulduar: Halls of Stone
	AL["Tribunal Chest"] = "Tribunal Chest";
	AL["Elder Yurauk"] = "Elder Yurauk";
	AL["Brann Bronzebeard"] = "Brann Bronzebeard";

	--Utgarde Keep: Utgarde Keep
	AL["Dark Ranger Marrah"] = "Dark Ranger Marrah";
	AL["Elder Jarten"] = "Elder Jarten";

	--Utgarde Keep: Utgarde Pinnacle
	AL["Brigg Smallshanks"] = "Brigg Smallshanks";
	AL["Elder Chogan'gada"] = "Elder Chogan'gada";

	--Vault of Archavon

	--The Violet Hold
	AL["The Violet Hold Key"] = "The Violet Hold Key";

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
	AL["Baleflame"] = "Baleflame";
	AL["Farseer Tooranu <The Earthen Ring>"] = "Farseer Tooranu <The Earthen Ring>";
	AL["Velastrasza"] = "Velastrasza";

	--Halls of Origination

	--Lost City of the Tol'vir
	AL["Captain Hadan"] = "Captain Hadan";
	AL["Augh"] = "Augh";

	--Sulfuron Keep

	--The Bastion of Twilight

	--The Stonecore
	AL["Earthwarden Yrsa <The Earthen Ring>"] = "Earthwarden Yrsa <The Earthen Ring>";

	--The Vortex Pinnacle
	AL["Itesh"] = "Itesh";

	--Throne of the Four Winds

	--Throne of the Tides
	AL["Captain Taylor"] = "Captain Taylor";
	AL["Legionnaire Nazgrim"] = "Legionnaire Nazgrim";
	AL["Neptulon"] = "Neptulon";

--[[
-- Cataclysm Zone Names	
--
-- Not for translation, they will be included in Lib-Babble-Zone or Lib-Babble-SubZone in the near future
]]

	--AL["Sulfuron Keep"] = "Sulfuron Keep";
	--AL["War of the Ancients"] = "War of the Ancients";
end