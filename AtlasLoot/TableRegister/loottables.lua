--[[
loottables.en.lua
This file assigns a title to every loot table.  The primary use of this table
is in the search function, as when iterating through the loot tables there is no
inherant title to the loot table, given the origins of the mod as an Atlas plugin.
]]

-- Invoke libraries
local AL = LibStub("AceLocale-3.0"):GetLocale("AtlasLoot");
local BabbleBoss = AtlasLoot_GetLocaleLibBabble("LibBabble-Boss-3.0")
local BabbleInventory = AtlasLoot_GetLocaleLibBabble("LibBabble-Inventory-3.0")
local BabbleFaction = AtlasLoot_GetLocaleLibBabble("LibBabble-Faction-3.0")
local BabbleZone = AtlasLoot_GetLocaleLibBabble("LibBabble-Zone-3.0")

-- Using alchemy skill to get localized rank
local JOURNEYMAN = select(2, GetSpellInfo(3101));
local EXPERT = select(2, GetSpellInfo(3464));
local ARTISAN = select(2, GetSpellInfo(11611));
local MASTER = select(2, GetSpellInfo(28596));

local ALCHEMY, APPRENTICE = GetSpellInfo(2259);
local BLACKSMITHING = GetSpellInfo(2018);
local ARMORSMITH = GetSpellInfo(9788);
local WEAPONSMITH = GetSpellInfo(9787);
local AXESMITH = GetSpellInfo(17041);
local HAMMERSMITH = GetSpellInfo(17040);
local SWORDSMITH = GetSpellInfo(17039);
local COOKING = GetSpellInfo(2550);
local ENCHANTING = GetSpellInfo(7411);
local ENGINEERING = GetSpellInfo(4036);
local GNOMISH = GetSpellInfo(20220);
local GOBLIN = GetSpellInfo(20221);
local FIRSTAID = GetSpellInfo(3273);
local FISHING = GetSpellInfo(63275);
local INSCRIPTION = GetSpellInfo(45357);
local JEWELCRAFTING = GetSpellInfo(25229);
local LEATHERWORKING = GetSpellInfo(2108);
local DRAGONSCALE = GetSpellInfo(10656);
local ELEMENTAL = GetSpellInfo(10658);
local TRIBAL = GetSpellInfo(10660);
local MINING = GetSpellInfo(2575);
local TAILORING = GetSpellInfo(3908);
local MOONCLOTH = GetSpellInfo(26798);
local SHADOWEAVE = GetSpellInfo(26801);
local SPELLFIRE = GetSpellInfo(26797);

AtlasLoot_LootTableRegister = {
	["Instances"] = {

---------------------------
--- Cataclysm Instances ---
---------------------------

	---- Dungeons
	
		["BlackrockCaverns"] = {
			["Bosses"] = {
				{ "BlackrockCavernsRomogg", 2 },
				{ "BlackrockCavernsCorla", 3 },
				{ "BlackrockCavernsSteelbender", 4 },
				{ "BlackrockCavernsBeauty", 5 },
				{ "BlackrockCavernsLordObsidius", 6 },
				{ "BlackrockCavernsTrash", 9 },
			},
			["Info"] = { BabbleZone["Blackrock Caverns"], "AtlasLootCataclysm", mapname = "BlackrockCaverns" },
		},

		["ThroneOfTheTides"] = {
			["Bosses"] = {
				{ "ToTNazjar", 3 },
				{ "ToTUlthok",  4 },
				{ "ToTStonespeaker", 5 },
				{ "ToTOzumat", 6 },
				{ "ToTTrash", 8 },
			},
			["Info"] = { BabbleZone["Throne of the Tides"], "AtlasLootCataclysm", mapname = "ThroneOfTheTides" },
		},

		["TheStonecore"] = {
			["Bosses"] = {
				{ "StonecoreCorborus", 4 },
				{ "StonecoreSlabhide", 5 },
				{ "StonecoreOzruk", 6 },
				{ "StonecoreAzil", 7 },
				{ "StonecoreTrash", 9 },
			},
			["Info"] = { BabbleZone["The Stonecore"], "AtlasLootCataclysm", mapname = "TheStonecore" },
		},

		["TheVortexPinnacle"] = {
			["Bosses"] = {
				{ "VPErtan", 3 },
				{ "VPAltarius", 4 },
				{ "VPAsimalAkir", 5 },
				{ "VPTrash", 7 },
			},
			["Info"] = { BabbleZone["The Vortex Pinnacle"], "AtlasLootCataclysm", mapname = "SkywallDungeon" },
		},

		["LostCityOfTolvir"] = {
			["Bosses"] = {
				{ "LostCityHusam", 3 },
				{ "LostCityBarim", 4 },
				{ "LostCityLockmaw", 5 },
				{ "LostCitySiamat", 6 },
				{ "LostCityTrash", 8 },
			},
			["Info"] = { BabbleZone["Lost City of the Tol'vir"], "AtlasLootCataclysm", mapname = "LostCityofTolvir" },
		},

		["GrimBatol"] = {
			["Bosses"] = {
				{ "GBUmbriss", 2 },
				{ "GBThrongus", 3 },
				{ "GBDrahga", 4 },
				{ "GBErudax", 5 },
				{ "GBTrash", 10 },
			},
			["Info"] = { BabbleZone["Grim Batol"], "AtlasLootCataclysm", mapname = "GrimBatol" },
		},

		["HallsOfOrigination"] = {
			["Bosses"] = {
				{ "HoOAnhuur", 2 },
				{ "HoOPtah", 3 },
				{ "HoOAnraphet", 4 },
				{ "HoOIsiset", 5 },
				{ "HoOAmmunae", 6 },
				{ "HoOSetesh", 7 },
				{ "HoORajh", 8 },
				{ "HoOTrash", 11 },
			},
			["Info"] = { BabbleZone["Halls of Origination"], "AtlasLootCataclysm", mapname = "HallsOfOrigination" },
		},

	---- Raids

		["TheBastionOfTwilight"] = {
			["Bosses"] = {
				{ "BoTWyrmbreaker", 3 },
				{ "BoTValionaTheralion", 4 },
				{ "BoTCouncil", 5 },
				{ "BoTChogall", 6  },
				{ "BoTSinestra", 7 },
				{ "BoTTrash", 9 },
			},
			["Info"] = { BabbleZone["The Bastion of Twilight"], "AtlasLootCataclysm", mapname = "TheBastionofTwilight" },
		},

		["BlackwingDescent"] = {
			["Bosses"] = {
				{ "BDMagmaw", 2 },
				{ "BDOmnotron", 3 },
				{ "BDMaloriak", 4 },
				{ "BDAtramedes", 5 },
				{ "BDChimaeron", 6 },
				{ "BDNefarian", 7 },
				{ "BDTrash", 9 },
			},
			["Info"] = { BabbleZone["Blackwing Descent"], "AtlasLootCataclysm", mapname = "BlackwingDescent" },
		},

		["BaradinHold"] = {
			["Bosses"] = {
				{ "Argaloth", 2 },
			},
			["Info"] = { BabbleZone["Baradin Hold"], "AtlasLootCataclysm", mapname = "Baradinhold" },
		},

		["ThroneOfTheFourWinds"] = {
			["Bosses"] = {
				{ "TFWConclave", 2 },
				{ "TFWAlAkir", 3 },
			},
			["Info"] = { BabbleZone["Throne of the Four Winds"], "AtlasLootCataclysm" },
		},

-----------------------
--- WotLK Instances ---
-----------------------

	---- Dungeons

		["AhnKahet"] = {
			["Bosses"] = {
				{ "AhnkahetNadox", 3 },
				{ "AhnkahetTaldaram", 4 },
				{ "AhnkahetAmanitar", 5 },
				{ "AhnkahetJedoga", 6 },
				{ "AhnkahetVolazj", 7 },
				{ "AhnkahetTrash", 10 },
			},
			["Info"] = { BabbleZone["Ahn'kahet: The Old Kingdom"], "AtlasLootWotLK", mapname = "Ahnkahet" },
		},

		["AzjolNerub"] = {
			["Bosses"] = {
				{ "AzjolNerubKrikthir", 4 },
				{ "AzjolNerubHadronox", 8 },
				{ "AzjolNerubAnubarak", 9 },
				{ "LunarFestival", 10, hide = true },
				{ "AzjolNerubTrash", 12 },
			},
			["Info"] = { BabbleZone["Azjol-Nerub"], "AtlasLootWotLK", mapname = "AzjolNerub" },
		},

		["CoTOldStratholme"] = {
			["Bosses"] = {
				{ "CoTStratholmeMeathook", 5 },
				{ "CoTStratholmeSalramm", 6 },
				{ "CoTStratholmeEpoch", 7 },
				{ "CoTStratholmeInfiniteCorruptor", 8 },
				{ "CoTStratholmeMalGanis", 10 },
				{ "CoTStratholmeTrash", 14 },
			},
			["Info"] = { BabbleZone["Old Stratholme"], "AtlasLootWotLK", mapname = "CoTStratholme" },
		},

		["DrakTharonKeep"] = {
			["Bosses"] = {
				{ "DrakTharonKeepTrollgore", 3 },
				{ "DrakTharonKeepNovos", 4 },
				{ "DrakTharonKeepKingDred", 5 },
				{ "DrakTharonKeepTharonja", 6 },
				{ "LunarFestival", 8, hide = true },
				{ "DrakTharonKeepTrash", 11 },
			},
			["Info"] = { BabbleZone["Drak'Tharon Keep"], "AtlasLootWotLK", mapname = "DrakTharonKeep" },
		},

		["FHTheForgeOfSouls"] = {
			["Bosses"] = {
				{ "FoSBronjahm", 3 },
				{ "FoSDevourer", 4 },
				{ "FHTrashMobs", 12 },
			},
			["Info"] = { BabbleZone["The Forge of Souls"], "AtlasLootWotLK", mapname = "TheForgeofSouls" },
		},

		["FHHallsOfReflection"] = {
			["Bosses"] = {
				{ "HoRFalric", 4 },
				{ "HoRMarwyn", 5 },
				{ "HoRLichKing", {6,7} },
				{ "FHTrashMobs", 13 },
			},
			["Info"] = { BabbleZone["Halls of Reflection"], "AtlasLootWotLK", mapname = "HallsofReflection" },
		},

		["FHPitOfSaron"] = {
			["Bosses"] = {
				{ "PoSGarfrost", 4 },
				{ "PoSKrickIck", 7 },
				{ "PoSTyrannus", 8 },
				{ "FHTrashMobs", 17 },
			},
			["Info"] = { BabbleZone["Pit of Saron"], "AtlasLootWotLK", mapname = "PitofSaron" },
		},

		["Gundrak"] = {
			["Bosses"] = {
				{ "GundrakSladran", 3 },
				{ "GundrakColossus", 4 },
				{ "GundrakMoorabi", 5 },
				{ "GundrakEck", 6 },
				{ "GundrakGaldarah", 7 },
				{ "LunarFestival", 8, hide = true },
				{ "GundrakTrash", 10 },
			},
			["Info"] = { BabbleZone["Gundrak"], "AtlasLootWotLK", mapname = "Gundrak" },
		},

		["TheNexus"] = {
			["Bosses"] = {
				{ "TheNexusKolurgStoutbeard", {2,3} },
				{ "TheNexusTelestra", 5 },
				{ "TheNexusAnomalus", 6 },
				{ "TheNexusOrmorok", 7 },
				{ "TheNexusKeristrasza", 8 },
				{ "LunarFestival", 9, hide = true },
			},
			["Info"] = { BabbleZone["The Nexus"], "AtlasLootWotLK", mapname = "TheNexus" },
		},

		["TheOculus"] = {
			["Bosses"] = {
				{ "OcuDrakos", 3 },
				{ "OcuCloudstrider", 4 },
				{ "OcuUrom", 5 },
				{ "OcuEregos", {6,8} },
				{ "OcuTrash", 10 },
			},
			["Info"] = { BabbleZone["The Oculus"], "AtlasLootWotLK", mapname = "Nexus80" },
		},

		["TrialOfTheChampion"] = {
			["Bosses"] = {
				{ "TrialoftheChampionChampions", 2 },
				{ "TrialoftheChampionEadricthePure", 15 },
				{ "TrialoftheChampionConfessorPaletress", 16 },
				{ "TrialoftheChampionBlackKnight", 17 },
			},
			["Info"] = { BabbleZone["Trial of the Champion"], "AtlasLootWotLK", mapname = "TheArgentColiseum" },
		},

		["UlduarHallsofStone"] = {
			["Bosses"] = {
				{ "HallsofStoneKrystallus", 2 },
				{ "HallsofStoneMaiden", 3 },
				{ "HallsofStoneTribunal", {4,5} },
				{ "HallsofStoneSjonnir", 6 },
				{ "LunarFestival", 7, hide = true },
				{ "HallsofStoneTrash", 10 },
			},
			["Info"] = { BabbleZone["Halls of Stone"], "AtlasLootWotLK", mapname = "Ulduar77" },
		},

		["UlduarHallsofLightning"] = {
			["Bosses"] = {
				{ "HallsofLightningBjarngrim", 2 },
				{ "HallsofLightningVolkhan", 3 },
				{ "HallsofLightningIonar", 4 },
				{ "HallsofLightningLoken", 5 },
				{ "HallsofLightningTrash", 7 },
			},
			["Info"] = { BabbleZone["Halls of Lightning"], "AtlasLootWotLK", mapname = "HallsofLightning" },
		},

		["UtgardeKeep"] = {
			["Bosses"] = {
				{ "UtgardeKeepKeleseth", 4 },
				{ "UtgardeKeepSkarvald", {5,6} },
				{ "UtgardeKeepIngvar", 7 },
				{ "LunarFestival", 8, hide = true },
				{ "UtgardeKeepTrash", 10 },
			},
			["Info"] = { BabbleZone["Utgarde Keep"], "AtlasLootWotLK", mapname = "UtgardeKeep" },
		},

		["UtgardePinnacle"] = {
			["Bosses"] = {
				{ "UPSorrowgrave", 3 },
				{ "UPPalehoof", 4 },
				{ "UPSkadi", 5 },
				{ "UPYmiron", 6 },
				{ "LunarFestival", 7, hide = true },
				{ "UPTrash", 9 },
			},
			["Info"] = { BabbleZone["Utgarde Pinnacle"], "AtlasLootWotLK", mapname = "UtgardePinnacle" },
		},

		["VioletHold"] = {
			["Bosses"] = {
				{ "WrathKeys", 1, hide = true },
				{ "VioletHoldErekem", 3 },
				{ "VioletHoldZuramat", 4 },
				{ "VioletHoldXevozz", 5 },
				{ "VioletHoldIchoron", 6 },
				{ "VioletHoldMoragg", 7 },
				{ "VioletHoldLavanthor", 8 },
				{ "VioletHoldCyanigosa", 9 },
				{ "VioletHoldTrash", 11 },
			},
			["Info"] = { BabbleZone["The Violet Hold"], "AtlasLootWotLK", mapname = "VioletHold" },
		},

	---- Raids

		["IcecrownCitadelA"] = "IcecrownCitadel",
		["IcecrownCitadelB"] = "IcecrownCitadel",
		["IcecrownCitadelC"] = "IcecrownCitadel",
		["IcecrownCitadel"] = {
			["IcecrownCitadelA"] = {
				{ "TheAshenVerdict", 1, hide = true},
				{ "ICCLordMarrowgar", 5},
				{ "ICCLadyDeathwhisper", 6},
				{ "ICCGunshipBattle", {7,8}},
				{ "ICCSaurfang", 9},
				{ "ICCTrash", 15, hide = true},
			},
			["IcecrownCitadelB"] = {
				{ "TheAshenVerdict", 1, hide = true},
				{ "ICCFestergut", 7},
				{ "ICCRotface", 8},
				{ "ICCPutricide", 9},
				{ "ICCCouncil", {10,11,12,13} },
				{ "ICCLanathel", 14},
				{ "ICCValithria", 15},
				{ "ICCSindragosa", 16},
				{ "ICCTrash", 20, hide = true},
			},
			["IcecrownCitadelC"] = {
				{ "TheAshenVerdict", 1, hide = true},
				{ "ICCLichKing", 3},
				{ "ICCTrash", 5},
			},
			["Info"] = { BabbleZone["Icecrown Citadel"], "AtlasLootWotLK", sortOrder = { "IcecrownCitadelA", "IcecrownCitadelB", "IcecrownCitadelC" }, mapname = "IcecrownCitadel" },
		},

		["Naxxramas"] = {
			["Bosses"] = {
				{ "Naxx80Patchwerk", 4 },
				{ "Naxx80Grobbulus", 5 },
				{ "Naxx80Gluth", 6 },
				{ "Naxx80Thaddius", 7 },
				{ "Naxx80AnubRekhan", 11 },
				{ "Naxx80Faerlina", 12 },
				{ "Naxx80Maexxna", 13 },
				{ "Naxx80Razuvious", 15 },
				{ "Naxx80Gothik", 16 },
				{ "Naxx80FourHorsemen", {17,22} },
				{ "Naxx80Noth", 24 },
				{ "Naxx80Heigan", 25 },
				{ "Naxx80Loatheb", 26 },
				{ "Naxx80Sapphiron", 28 },
				{ "Naxx80KelThuzad", 29 },
				{ "Naxx80Trash", 33 },
				{ "T7T8SET", 34, hide = true },
			},
			["Info"] = { BabbleZone["Naxxramas"], "AtlasLootWotLK", mapname = "IcecrownCitadel", mapname = "Naxxramas" },
		},

		["ObsidianSanctum"] = {
			["Bosses"] = {
				{ "Sartharion", 6 },
			},
			["Info"] = { BabbleZone["The Obsidian Sanctum"], "AtlasLootWotLK", mapname = "Naxxramas", mapname = "TheObsidianSanctum" },
		},

		["OnyxiasLair"] = {
			["Bosses"] = {
				{ "Onyxia", 2 },
			},
			["Info"] = { BabbleZone["Onyxia's Lair"], "AtlasLootWotLK", mapname = "OnyxiasLair" },
		},

		["RubySanctum"] = {
			["Bosses"] = {
				{ "Halion", 6 },
			},
			["Info"] = { BabbleZone["The Ruby Sanctum"], "AtlasLootWotLK", mapname = "TheRubySanctum" },
		},

		["TheEyeOfEternity"] = {
			["Bosses"] = {
				{ "WrathKeys", 1, hide = true },
				{ "Malygos", 3 },
			},
			["Info"] = { BabbleZone["The Eye of Eternity"], "AtlasLootWotLK", mapname = "TheEyeOfEternity" },
		},

		["TrialOfTheCrusader"] = {
			["Bosses"] = {
				{ "TrialoftheCrusaderNorthrendBeasts", 4 },
				{ "TrialoftheCrusaderLordJaraxxus", 9 },
				{ "TrialoftheCrusaderFactionChampions", 10 },
				{ "TrialoftheCrusaderTwinValkyrs", 11 },
				{ "TrialoftheCrusaderAnubarak", 14 },
				{ "TrialoftheCrusaderPatterns", 16 },
			},
			["Info"] = { BabbleZone["Trial of the Crusader"], "AtlasLootWotLK", mapname = "TheArgentColiseum" },
		},

		["UlduarA"] = "Ulduar",
		["UlduarB"] = "Ulduar",
		["UlduarC"] = "Ulduar",
		["UlduarD"] = "Ulduar",
		["UlduarE"] = "Ulduar",
		["Ulduar"] = {
			["UlduarA"] = {
				{ "UlduarLeviathan", 7 },
				{ "UlduarRazorscale", 8},
				{ "UlduarIgnis", 9 },
				{ "UlduarDeconstructor", 10 },
				{ "UlduarTrash", 16, hide = true},
				{ "UlduarPatterns", 17, hide = true},
				{ "T7T8SET", 18 , hide = true},
			},
			["UlduarB"] = {
				{ "WrathKeys", 1, hide = true },
				{ "UlduarIronCouncil", 4 },
				{ "UlduarKologarn", 8 },
				{ "UlduarAlgalon", 9 },
				{ "UlduarPatterns", 15, hide = true },
				{ "UlduarTrash", 14, hide = true },
				{ "T7T8SET", 16, hide = true },
			},
			["UlduarC"] = {
				{ "UlduarAuriaya", 4 },
				{ "UlduarHodir", 5 },
				{ "UlduarThorim", 6 },
				{ "UlduarFreya", 8 },
				{ "UlduarTrash", 15, hide = true },
				{ "UlduarPatterns", 16, hide = true },
				{ "T7T8SET", 17, hide = true },
			},
			["UlduarD"] = {
				{ "UlduarMimiron", 2 },
				{ "UlduarTrash", 5, hide = true },
				{ "UlduarPatterns", 6, hide = true },
				{ "T7T8SET", 7, hide = true },
			},
			["UlduarE"] = {
				{ "UlduarVezax", 2 },
				{ "UlduarYoggSaron", 3 },
				{ "UlduarTrash", 7 },
				{ "UlduarPatterns", 8 },
				{ "T7T8SET", 9, hide = true },
			},
			["Info"] = { BabbleZone["Ulduar"], "AtlasLootWotLK", sortOrder = { "UlduarA", "UlduarB", "UlduarC", "UlduarD", "UlduarE" }, mapname = "Ulduar" },
		},

		["VaultOfArchavon"] = {
			["Bosses"] = {
				{ "VaultofArchavonArchavon", 2 },
				{ "VaultofArchavonEmalon", 3 },
				{ "VaultofArchavonKoralon", 4 },
				{ "VaultofArchavonToravon", 5 },
			},
			["Info"] = { BabbleZone["Vault of Archavon"], "AtlasLootWotLK", mapname = "VaultofArchavon" },
		},

--------------------
--- BC Instances ---
--------------------

	---- Dungeons

		["AuchAuchenaiCrypts"] = {
			["Bosses"] = {
				{ "LowerCity", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "AuchCryptsShirrak", 4 },
				{ "AuchCryptsExarch", 5 },
				{ "AuchCryptsAvatar", 6 },
				{ "AuchTrash", 9 },
			},
			["Info"] = { BabbleZone["Auchenai Crypts"], "AtlasLootBurningCrusade" },
		},

		["AuchManaTombs"] = {
			["Bosses"] = {
				{ "Consortium", 1, hide = true },
				{ "BCKeys", {2,3}, hide = true },
				{ "AuchManaPandemonius", 5 },
				{ "AuchManaTavarok", 7 },
				{ "AuchManaNexusPrince", 8 },
				{ "AuchManaYor", 9 },
				{ "AuchTrash", 14 },
			},
			["Info"] = { BabbleZone["Mana-Tombs"], "AtlasLootBurningCrusade" },
		},

		["AuchSethekkHalls"] = {
			["Bosses"] = {
				{ "LowerCity", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "AuchSethekkDarkweaver", 4 },
				{ "AuchSethekkRavenGod", 6 },
				{ "AuchTrash", 7, hide = true },
				{ "AuchSethekkTalonKing", 8 },
				{ "AuchTrash", 10 },
			},
			["Info"] = { BabbleZone["Sethekk Halls"], "AtlasLootBurningCrusade" },
		},

		["AuchShadowLabyrinth"] = {
			["Bosses"] = {
				{ "LowerCity", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "AuchShadowHellmaw", 4 },
				{ "AuchShadowBlackheart", 5 },
				{ "AuchShadowGrandmaster", 6 },
				{ "AuchShadowMurmur", 8 },
				{ "AuchTrash", 10, hide = true },
				{ "AuchTrash", 13 },
			},
			["Info"] = { BabbleZone["Shadow Labyrinth"], "AtlasLootBurningCrusade" },
		},

		["CoTOldHillsbrad"] = {
			["Bosses"] = {
				{ "KeepersofTime", 3, hide = true },
				{ "BCKeys", 4, hide = true },
				{ "CoTHillsbradDrake", 11 },
				{ "CoTHillsbradSkarloc", 13 },
				{ "CoTHillsbradHunter", 16 },
				{ "CoTTrash", {19,21,22}, hide = true },
				{ "CoTTrash", 26 },
			},
			["Info"] = { BabbleZone["Old Hillsbrad Foothills"], "AtlasLootBurningCrusade" },
		},

		["CoTBlackMorass"] = {
			["Bosses"] = {
				{ "KeepersofTime", 3, hide = true },
				{ "BCKeys", 4, hide = true },
				{ "CoTMorassDeja", 8 },
				{ "CoTMorassTemporus", 9 },
				{ "CoTMorassAeonus", 10 },
				{ "CoTTrash", 14 },	
			},
			["Info"] = { BabbleZone["The Black Morass"], "AtlasLootBurningCrusade" },
		},

		["CFRTheSlavePens"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "CFRSlaveMennu", 4 },
				{ "CFRSlaveRokmar", 5 },
				{ "CFRSlaveQuagmirran", 6 },
				{ "LordAhune", 7, hide = true },
			},
			["Info"] = { BabbleZone["The Slave Pens"], "AtlasLootBurningCrusade" },
		},

		["CFRTheSteamvault"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "CFRSteamThespia", 4 },
				{ "CFRSteamSteamrigger", 6 },
				{ "CFRSteamWarlord", 8 },
				{ "CFRSteamTrash", 10, hide = true },
				{ "CFRSteamTrash", 12 },
			},
			["Info"] = { BabbleZone["The Steamvault"], "AtlasLootBurningCrusade" },
		},

		["CFRTheUnderbog"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "CFRUnderHungarfen", 4 },
				{ "CFRUnderGhazan", 6 },
				{ "CFRUnderSwamplord", 7 },
				{ "CFRUnderStalker", 9 },
			},
			["Info"] = { BabbleZone["The Underbog"], "AtlasLootBurningCrusade" },
		},
		
		["HCHellfireRamparts"] = {
			["Bosses"] = {
				{ "HonorHold", 1, hide = true },
				{ "Thrallmar", 2, hide = true },
				{ "BCKeys", 3, hide = true },
				{ "HCRampWatchkeeper", 5 },
				{ "HCRampOmor", 6 },
				{ "HCRampVazruden", {7,9} },
			},
			["Info"] = { BabbleZone["Hellfire Ramparts"], "AtlasLootBurningCrusade" },
		},

		["HCBloodFurnace"] = {
			["Bosses"] = {
				{ "HonorHold", 1, hide = true },
				{ "Thrallmar", 2, hide = true },
				{ "BCKeys", 3, hide = true },
				{ "HCFurnaceMaker", 5 },
				{ "HCFurnaceBroggok", 6 },
				{ "HCFurnaceBreaker", 7 },
			},
			["Info"] = { BabbleZone["The Blood Furnace"], "AtlasLootBurningCrusade" },
		},

		["HCTheShatteredHalls"] = {
			["Bosses"] = {
				{ "HonorHold", 1, hide = true },
				{ "Thrallmar", 2, hide = true },
				{ "BCKeys", 3, hide = true },
				{ "HCHallsNethekurse", 5 },
				{ "HCHallsPorung", 6 },
				{ "HCHallsOmrogg", 7 },
				{ "HCHallsKargath", 8 },
				{ "HCHallsTrash", 9, hide = true },
				{ "HCHallsTrash", 19 },
			},
			["Info"] = { BabbleZone["The Shattered Halls"], "AtlasLootBurningCrusade" },
		},

		["MagistersTerrace"] = {
			["Bosses"] = {
				{ "SunOffensive", 1, hide = true },
				{ "SMTFireheart", 4 },
				{ "SMTVexallus", 6 },
				{ "SMTDelrissa", 7 },
				{ "SMTKaelthas", 18 },
				{ "SMTTrash", 23 },
			},
			["Info"] = { BabbleZone["Magisters' Terrace"], "AtlasLootBurningCrusade" },
		},

		["TempestKeepArcatraz"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "TKArcUnbound", 4 },
				{ "TKArcDalliah", 5 },
				{ "TKArcScryer", 6 },
				{ "TKArcHarbinger", 7 },
				{ "TKTrash", 11, hide = true },
				{ "TKTrash", 14 },
			},
			["Info"] = { BabbleZone["The Arcatraz"], "AtlasLootBurningCrusade" },
		},

		["TempestKeepBotanica"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "TKBotSarannis", 5 },
				{ "TKBotFreywinn", 6 },
				{ "TKBotThorngrin", 7 },
				{ "TKBotLaj", 8 },
				{ "TKBotSplinter", 9 },
				{ "TKTrash", 11 },
			},
			["Info"] = { BabbleZone["The Botanica"], "AtlasLootBurningCrusade" },
		},

		["TempestKeepMechanar"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "TKMechCacheoftheLegion", 5, hide = true },
				{ "TKMechCacheoftheLegion", 6, hide = true },
				{ "TKMechCapacitus", 7 },
				{ "TKTrash", 8, hide = true },
				{ "TKMechSepethrea", 9 },
				{ "TKMechCalc", 10 },
				{ "TKMechCacheoftheLegion", 11 },
				{ "TKTrash", 13 },
			},
			["Info"] = { BabbleZone["The Mechanar"], "AtlasLootBurningCrusade" },
		},

	---- Raids

		["BlackTempleStart"] = "BlackTemple",
		["BlackTempleBasement"] = "BlackTemple",
		["BlackTempleTop"] = "BlackTemple",
		["BlackTemple"] = {
			["BlackTempleStart"] = {
				{ "Ashtongue", 1, hide = true },
				{ "BTNajentus", 6 },
				{ "BTSupremus", 7 },
				{ "BTAkama", 8 },
				{ "BTPatterns", 15, hide = true },
				{ "BTTrash", 16, hide = true },
			},
			["BlackTempleBasement"] = {
				{ "Ashtongue", 1, hide = true },
				{ "BTBloodboil", 4 },
				{ "BTReliquaryofSouls", 5 },
				{ "BTGorefiend", 9 },
				{ "BTPatterns", 11, hide = true },
				{ "BTTrash", 12, hide = true },
			},
			["BlackTempleTop"] = {
				{ "Ashtongue", 1, hide = true },
				{ "BTShahraz", 4 },
				{ "BTCouncil", 5 },
				{ "BTIllidanStormrage", 10 },
				{ "BTPatterns", 12 },
				{ "BTTrash", 13 },
			},
			["Info"] = { BabbleZone["Black Temple"], "AtlasLootBurningCrusade", sortOrder = { "BlackTempleStart", "BlackTempleBasement", "BlackTempleTop" } },
		},

		["CoTHyjal"] = {
			["Bosses"] = {
				{ "ScaleSands", 2, hide = true },
				{ "MountHyjalWinterchill", 9 },
				{ "MountHyjalAnetheron", 10 },
				{ "MountHyjalKazrogal", 11 },
				{ "MountHyjalAzgalor", 12 },
				{ "MountHyjalArchimonde", 13 },
				{ "MountHyjalTrash", 15 },
			},
			["Info"] = { BabbleZone["Hyjal"], "AtlasLootBurningCrusade" },
		},

		["CFRSerpentshrineCavern"] = {
			["Bosses"] = {
				{ "CExpedition", 1, hide = true },
				{ "CFRSerpentHydross", 3 },
				{ "CFRSerpentLurker", 4 },
				{ "CFRSerpentLeotheras", 5 },
				{ "CFRSerpentKarathress", 6 },
				{ "CFRSerpentMorogrim", 8 },
				{ "CFRSerpentVashj", 9 },
				{ "CFRSerpentTrash", 11 },
			},
			["Info"] = { BabbleZone["Serpentshrine Cavern"], "AtlasLootBurningCrusade" },
		},

		["GruulsLair"] = {
			["Bosses"] = {
				{ "GruulsLairHighKingMaulgar", 2 },
				{ "GruulGruul", 7 },
			},
			["Info"] = { BabbleZone["Gruul's Lair"], "AtlasLootBurningCrusade" },
		},

		["HCMagtheridonsLair"] = {
			["Bosses"] = {
				{ "HCMagtheridon", 2 },
			},
			["Info"] = { BabbleZone["Magtheridon's Lair"], "AtlasLootBurningCrusade" },
		},

		["KarazhanEnt"] = "KarazhanEaI",
		["KarazhanStart"] = "KarazhanEaI",
		["KarazhanEnd"] = "KarazhanEaI",
		["KarazhanEaI"] = {
			["KarazhanEnt"] = {
				{ "KaraCharredBoneFragment", 8, hide = true },
			},
			["KarazhanStart"] = {
				{ "VioletEye", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "KaraAttumen", 5 },
				{ "KaraMoroes", 7 },
				{ "KaraMaiden", 14 },
				{ "KaraOperaEvent", 15 },
				{ "KaraNightbane", 28 },
				{ "KaraNamed", {30,31,32,33} },
				{ "KaraTrash", 39, hide = true },
				{ "KaraTrash", 44, hide = true },
			},
			["KarazhanEnd"] = {
				{ "VioletEye", 1, hide = true },
				{ "BCKeys", 2, hide = true },
				{ "KaraCurator", 11 },
				{ "KaraIllhoof", 12 },
				{ "KaraAran", 14 },
				{ "KaraNetherspite", 15 },
				{ "KaraChess", {16,17} },
				{ "KaraPrince", 18 },
				{ "KaraTrash", 25 },
			},
			["Info"] = { BabbleZone["Karazhan"], "AtlasLootBurningCrusade", sortOrder = { "KarazhanEnt", "KarazhanStart", "KarazhanEnd" } },
		},

		["SunwellPlateau"] = {
			["Bosses"] = {
				{ "SPKalecgos", 2 },
				{ "SPBrutallus", 4 },
				{ "SPFelmyst", 5 },
				{ "SPEredarTwins", 7 },
				{ "SPMuru", 10 },
				{ "SPKiljaeden", 12 },
				{ "SPPatterns", 14 },
				{ "SPTrash", 15 },
			},
			["Info"] = { BabbleZone["Sunwell Plateau"], "AtlasLootBurningCrusade" },
		},

		["TempestKeepTheEye"] = {
			["Bosses"] = {
				{ "Shatar", 1, hide = true },
				{ "TKEyeAlar", 3 },
				{ "TKEyeVoidReaver", 4 },
				{ "TKEyeSolarian", 5 },
				{ "TKEyeKaelthas", 6 },
				{ "TKEyeTrash", 12 },
			},
			["Info"] = { BabbleZone["The Eye"], "AtlasLootBurningCrusade" },
		},

		["ZulAman"] = {
			["Bosses"] = {
				{ "ZANalorakk", 3 },
				{ "ZAAkilZon", 6 },
				{ "ZAJanAlai", 8 },
				{ "ZAHalazzi", 10 },
				{ "ZAMalacrass", 12 },
				{ "ZAZuljin", 21 },
				{ "ZATimedChest", 34 },
				{ "ZATrash", 35 },	
			},
			["Info"] = { BabbleZone["Zul'Aman"], "AtlasLootBurningCrusade" },
		},

-------------------------
--- Classic Instances ---
-------------------------

		["BlackfathomDeeps"] = {
			["Bosses"] = {
				{ "Blackfathom#1", {3,4,5,7,8,11} },
				{ "Blackfathom#2", {9,12,13}, hide = true },
			},
			["Info"] = { BabbleZone["Blackfathom Deeps"], "AtlasLootClassicWoW", mapname = "BlackFathomDeeps" },
		},

		["BlackrockDepths"] = {
			["Bosses"] = {
				{ "OldKeys", 1, hide = true },
				{ "BRDHighInterrogatorGerstahn", 7 },
				{ "BRDLordRoccor", 8 },
				{ "BRDHoundmaster", 9 },
				{ "BRDBaelGar", 10 },
				{ "BRDLordIncendius", 11 },
				{ "BRDFineousDarkvire", 13 },
				{ "BRDTheVault", 14 },
				{ "BRDWarderStilgiss", 15 },
				{ "BRDVerek", 16 },
				{ "BRDPyromantLoregrain", 18 },
				{ "BRDArena", {19,21,22,23,24,25,26} },
				{ "LunarFestival", 27, hide = true },
				{ "BRDGeneralAngerforge", 28 },
				{ "BRDGolemLordArgelmach", 29 },
				{ "BRDBSPlans", {31,58}, hide = true },
				{ "BRDGuzzler", {32,34,35,36} },
				{ "CorenDirebrew", 33, hide = true },
				{ "BRDFlamelash", 38 },
				{ "BRDTomb", 39 },
				{ "BRDMagmus", 40 },
				{ "BRDImperatorDagranThaurissan", 41 },
				{ "BRDPrincess", 42 },
				{ "BRDPanzor", 70 },
				{ "BRDLyceum", },
				{ "BRDTrash", 72 },
				{ "VWOWSets#1", 73, hide = true },
			},
			["Info"] = { BabbleZone["Blackrock Depths"], "AtlasLootClassicWoW", mapname = "BlackrockDepths" },
		},

		["BlackrockMountainEnt"] = {
			["Bosses"] = {
				{ "BlackrockMountainEntLoot", {10,11} },
			},
			["Info"] = { BabbleZone["Blackrock Mountain"], "AtlasLootClassicWoW" },
		},

		["BlackrockSpireLower"] = {
			["Bosses"] = {
				{ "LBRSOmokk", 4 },
				{ "LBRSVosh", 5 },
				{ "LBRSVoone", 6 },
				{ "LBRSSmolderweb", 7 },
				{ "LBRSDoomhowl", 8 },
				{ "LBRSZigris", 10 },
				{ "LBRSHalycon", 11 },
				{ "LBRSSlavener", 12 },
				{ "LBRSWyrmthalak", 13 },
				{ "LBRSGrimaxe", 14 },
				{ "LunarFestival", 17, hide = true },
				{ "LBRSQuestItems", {18,19,20}, hide = true },
				{ "LBRSSpirestoneButcher", 22 },
				{ "LBRSSpirestoneLord", 23 },
				{ "LBRSLordMagus", 24 },
				{ "LBRSCrystalFang", 29 },
				{ "LBRSBashguud", 30 },
				{ "LBRSFelguard", 31 },
				{ "LBRSTrash", 33 },
				{ "T0SET", 34, hide = true },
				{ "VWOWSets#3", 35, hide = true },
			},
			["Info"] = { BabbleZone["Lower Blackrock Spire"], "AtlasLootClassicWoW", mapname = "BlackrockSpire" },
		},

		["BlackrockSpireUpper"] = {
			["Bosses"] = {
				{ "UBRSEmberseer", 5 },
				{ "UBRSSolakar", 6 },
				{ "UBRSAnvilcrack", 7 },
				{ "UBRSRend", 8 },
				{ "UBRSGyth", 9 },
				{ "UBRSBeast", 10 },
				{ "UBRSDrakkisath", 12 },
				{ "UBRSFLAME", 15 },
				{ "UBRSQuestItems", {18,19}, hide = true },
				{ "UBRSRunewatcher", 20 },
				{ "UBRSTrash", 22 },
				{ "T0SET", 23, hide = true },
				{ "VWOWSets#3", 24, hide = true },
			},
			["Info"] = { BabbleZone["Upper Blackrock Spire"], "AtlasLootClassicWoW", mapname = "BlackrockSpire" },
		},	

		["BlackwingLair"] = {
			["Bosses"] = {
				{ "BWLRazorgore", 6 },
				{ "BWLVaelastrasz", 7 },
				{ "BWLLashlayer", 8 },
				{ "BWLFiremaw", 9 },
				{ "BWLEbonroc", 10 },
				{ "BWLFlamegor", 11 },
				{ "BWLChromaggus", 12 },
				{ "BWLNefarian", 13 },
				{ "BWLTrashMobs",  17 },
				{ "T1T2T3SET", 18, hide = true },
			},
			["Info"] = { BabbleZone["Blackwing Lair"], "AtlasLootClassicWoW", mapname = "BlackwingLair" },
		},

		["DireMaulEnt"] = {
			["Bosses"] = {
				{ "LunarFestival", 7, hide = true },
			},
			["Info"] = { BabbleZone["Dire Maul"], "AtlasLootWorldEvents" },
		},

		["DireMaulNorth"] = {
			["Bosses"] = {
				{ "DMNGuardMoldar", 2 },
				{ "DMNStomperKreeg", 3 },
				{ "DMNGuardFengus", 4 },
				{ "DMNGuardSlipkik", 5 },
				{ "DMNThimblejack", 6 },
				{ "DMNCaptainKromcrush", 7 },
				{ "DMNKingGordok", 8 },
				{ "DMNChoRush", 9 }, 
				{ "DMNTRIBUTERUN", 11 },
				{ "DMBooks", 12 },
			},
			["Info"] = { BabbleZone["Dire Maul (North)"], "AtlasLootClassicWoW", mapname = "DireMaul" },
		},

		["DireMaulEast"] = {
			["Bosses"] = {
				{ "DMELethtendrisPimgib", {6,7} },
				{ "DMEHydro", 8 },
				{ "DMEZevrimThornhoof", 9 },
				{ "DMEAlzzin", 10 },
				{ "DMEPusillin", {11,12} },
				{ "DMETrash", 15 },
				{ "DMBooks", 16 },
			},
			["Info"] = { BabbleZone["Dire Maul (East)"], "AtlasLootClassicWoW", mapname = "DireMaul" },
		},

		["DireMaulWest"] = {
			["Bosses"] = {
				{ "OldKeys", 1, hide = true },
				{ "DMWTendrisWarpwood", 4 },
				{ "DMWMagisterKalendris", 5 },
				{ "DMWIllyannaRavenoak", 6 },
				{ "DMWImmolthar", 8 },
				{ "DMWHelnurath", 9 },
				{ "DMWPrinceTortheldrin", 10 },
				{ "DMWTrash", 20, hide = true },
				{ "DMWTsuzee", 22 },
				{ "DMWTrash", 24 },
				{ "DMBooks", 25 },
			},
			["Info"] = { BabbleZone["Dire Maul (West)"], "AtlasLootClassicWoW", mapname = "DireMaul" },
		},

		["Maraudon"] = {
			["Bosses"] = {
				{ "MaraudonLoot#1", {4,5,6,8,16} },
				{ "MaraudonLoot#2", {7,9,10,11,12,13}, hide = true }, 
				{ "LunarFestival", 14, hide = true },
			},
			["Info"] = { BabbleZone["Maraudon"], "AtlasLootClassicWoW", mapname = "Maraudon" },
		},

		["Uldaman"] = {
			["Bosses"] = {
				{ "UldShovelphlange", },
				{ "OldKeys", 1, hide = true },
				{ "UldBaelog", {5,6,7,8} },
				{ "UldRevelosh", 9 },
				{ "UldIronaya", 10 },
				{ "UldObsidianSentinel", 11 },
				{ "UldAncientStoneKeeper", 12 },
				{ "UldGalgannFirehammer", 13 },
				{ "UldGrimlok", 14 },
				{ "UldArchaedas", 15 },
				{ "UldTrash", 23 },
			},
			["Info"] = { BabbleZone["Uldaman"], "AtlasLootClassicWoW", mapname = "Uldaman" },
		},

		["StratholmeCrusader"] = {
			["Bosses"] = {
				{ "ArgentDawn", 1, hide = true },
				{ "STRATStratholmeCourier", {2,12}, hide = true },
				{ "STRATSkull", },
				{ "STRATTheUnforgiven", 4 },
				{ "STRATTimmytheCruel", 5 },
				{ "STRATWilleyHopebreaker", 7 },
				{ "STRATMalorsStrongbox", 8 },
				{ "STRATInstructorGalford", 9 },
				{ "STRATBalnazzar", 11 },
				{ "STRATFrasSiabi", 13 },
				{ "STRATHearthsingerForresten", 14 },
				{ "STRATRisenHammersmith", {15,16} },
				{ "LunarFestival", 19, hide = true },
				{ "STRATTrash", 23 },
				{ "VWOWSets#2", {17,18,20,21}, hide = true },
			},
			["Info"] = { BabbleZone["Stratholme"].." - "..AL["Crusader's Square"], "AtlasLootClassicWoW", mapname = "Stratholme" },
		},

		["StratholmeGauntlet"] = {
			["Bosses"] = {
				{ "ArgentDawn", 1, hide = true },
				{ "STRATStratholmeCourier", 2, hide = true },
				{ "STRATBaronessAnastari", 4 },
				{ "STRATNerubenkan", 5 },
				{ "STRATMalekithePallid", 6 },
				{ "STRATMagistrateBarthilas", 7 },
				{ "STRATRamsteintheGorger", 8 },
				{ "STRATLordAuriusRivendare", 9 },
				{ "STRATBlackGuardSwordsmith", {10,11} },
				{ "STRATStonespine", },
				{ "STRATTrash", 14 },
				{ "VWOWSets#2", 12, hide = true },
			},
			["Info"] = { BabbleZone["Stratholme"].." - "..AL["The Gauntlet"], "AtlasLootClassicWoW", mapname = "Stratholme" },
		},

		["RazorfenDowns"] = {
			["Bosses"] = {
				{ "RazorfenDownsLoot#1", {2,3,4,8,10} },
				{ "RazorfenDownsLoot#2", {5,6}, hide = true },
			},
			["Info"] = { BabbleZone["Razorfen Downs"], "AtlasLootClassicWoW", mapname = "RazorfenDowns" },
		},

		["RazorfenKraul"] = {
			["Bosses"] = {
				{ "RazorfenKraulLoot#1", {2,3,4,5,6,8,12} }, 
				{ "RazorfenKraulLoot#2", {7,13}, hide = true }, 
			},
			["Info"] = { BabbleZone["Razorfen Kraul"], "AtlasLootClassicWoW", mapname = "RazorfenKraul" },
		},

		["TheSunkenTemple"] = {
			["Bosses"] = { 
				{ "STAvatarofHakkar", 3 },
				{ "STJammalanandOgom", {4,5} },
				{ "STHazzasandMorphaz", {6,7} },
				{ "STEranikus", 8 },
				{ "LunarFestival", 10, hide = true },
				{ "STTrash", 12 },
			},
			["Info"] = { BabbleZone["Sunken Temple"], "AtlasLootClassicWoW", mapname = "TempleOfAtalHakkar" },
		},

		["RagefireChasm"] = {
			["Bosses"] = {
				{ "RagefireChasmLoot", {2,3,4,5,6} },
			},
			["Info"] = { BabbleZone["Ragefire Chasm"], "AtlasLootClassicWoW", mapname = "Ragefire" },
		},

		["MoltenCore"] = {
			["Bosses"] = {
				{ "BloodsailHydraxian", 2, hide = true },
				{ "MCLucifron", 4 },
				{ "MCMagmadar", 5 },
				{ "MCGehennas", 6 },
				{ "MCGarr", 7 },
				{ "MCShazzrah", 8 },
				{ "MCGeddon", 9 },
				{ "MCGolemagg", 10 },
				{ "MCSulfuron", 11 },
				{ "MCMajordomo", 12 },
				{ "MCRagnaros", 13 },
				{ "T1T2T3SET", 15, hide = true },
				{ "MCRANDOMBOSSDROPPS", 16 },
				{ "MCTrashMobs", 17 },
			},
			["Info"] = { BabbleZone["Molten Core"], "AtlasLootClassicWoW", mapname = "MoltenCore" },
		},

		["TheTempleofAhnQiraj"] = {
			["Bosses"] = {
				{ "AQBroodRings", 1, hide = true },
				{ "AQ40Skeram", 4 },
				{ "AQ40BugFam", {5,6,7,8} },
				{ "AQ40Sartura", 9 },
				{ "AQ40Fankriss", 10 },
				{ "AQ40Viscidus", 11 },
				{ "AQ40Huhuran", 12 },
				{ "AQ40Emperors", {13,14,15} },
				{ "AQ40Ouro", 16 },
				{ "AQ40CThun", {17,18} },
				{ "AQ40Trash", 26 },
				{ "AQ40Sets", 27, hide = true },
				{ "AQEnchants", 28 },
			},
			["Info"] = { BabbleZone["Temple of Ahn'Qiraj"], "AtlasLootClassicWoW", mapname = "TempleofAhnQiraj" },
		},

		["ShadowfangKeep"] = {
			["Bosses"] = {
				{ "ShadowfangAshbury", 3 },
				{ "ShadowfangSilverlaine", 4 },
				{ "ShadowfangSpringvale", 6 },
				{ "ShadowfangWalden", 7 },
				{ "ShadowfangGodfrey", 8 },
				{ "Valentineday#3", 9, hide = true },
			},
			["Info"] = { BabbleZone["Shadowfang Keep"], {"AtlasLootClassicWoW", "AtlasLootCataclysm"}, mapname = "ShadowfangKeep" },
		},

		["Gnomeregan"] = {
			["Bosses"] = {
				{ "GnomereganLoot#1", {4,7,8,10} },
				{ "GnomereganLoot#2", {11}, hide = true },
			},
			["Info"] = { BabbleZone["Gnomeregan"], "AtlasLootClassicWoW", mapname = "Gnomeregan" },
		},

		["SMArmory"] = {
			["Bosses"] = {
				{ "SMArmoryLoot", 2 },
				{ "SMTrash", 4 },
				{ "VWOWSets#1", 5, hide = true },
			},
			["Info"] = { BabbleZone["Scarlet Monastery"]..": "..BabbleZone["Armory"], "AtlasLootClassicWoW", mapname = "ScarletMonastery" },
		},

		["SMCathedral"] = {
			["Bosses"] = {
				{ "SMCathedralLoot", {2,3,4} },
				{ "SMTrash", 6 },
				{ "VWOWSets#1", 7, hide = true },
			},
			["Info"] = { BabbleZone["Scarlet Monastery"]..": "..BabbleZone["Cathedral"], "AtlasLootClassicWoW", mapname = "ScarletMonastery" },
		},

		["SMLibrary"] = {
			["Bosses"] = {
				{ "SMLibraryLoot", {2,3} },
				{ "SMTrash", 5 },
				{ "VWOWSets#1", 6, hide = true },
			},
			["Info"] = { BabbleZone["Scarlet Monastery"]..": "..BabbleZone["Library"], "AtlasLootClassicWoW", mapname = "ScarletMonastery" },
		},

		["SMGraveyard"] = {
			["Bosses"] = {
				{ "SMGraveyardLoot", {2,4} },
				{ "HeadlessHorseman", 5, hide = true },
				{ "SMTrash", 8 },
				{ "VWOWSets#1", 10, hide = true },
			},
			["Info"] = { BabbleZone["Scarlet Monastery"]..": "..BabbleZone["Graveyard"], "AtlasLootClassicWoW", mapname = "ScarletMonastery" },
		},

		["Scholomance"] = {
			["Bosses"] = {
				{ "ArgentDawn", 1, hide = true },
				{ "OldKeys", {2,3}, hide = true },
				{ "SCHOLOKirtonostheHerald", 6 },
				{ "SCHOLOJandiceBarov", 7 },
				{ "SCHOLORattlegore", 8 },
				{ "SCHOLODeathKnight", 9 },
				{ "SCHOLORasFrostwhisper", 10 },
				{ "SCHOLOLorekeeperPolkelt", 11 },
				{ "SCHOLODoctorTheolenKrastinov", 12 },
				{ "SCHOLOInstructorMalicia", 13 },
				{ "SCHOLOLadyIlluciaBarov", 14 },
				{ "SCHOLOLordAlexeiBarov", 15 },
				{ "SCHOLOQuestItems", {16,22,24,25}, hide = true },
				{ "SCHOLOTheRavenian", 17 },
				{ "SCHOLODarkmasterGandling", 18 },
				{ "SCHOLOMardukVectus", {19,20} },
				{ "SCHOLOBloodStewardofKirtonos", 21 },
				{ "SCHOLOTrash", 30 },
				{ "VWOWScholo", 31, hide = true },
			},
			["Info"] = { BabbleZone["Scholomance"], "AtlasLootClassicWoW", mapname = "Scholomance" },
		},

		["TheDeadminesEnt"] = "TheDeadminesEaI",
		["TheDeadmines"] = "TheDeadminesEaI",
		["TheDeadminesEaI"] = {
			["TheDeadminesEnt"] = {
				{ "DeadminesEntrance", {4,5}, hide = true },
			},
			["TheDeadmines"] = {
				{ "DeadminesGlubtok", 3 },
				{ "DeadminesGearbreaker", 5 },
				{ "DeadminesFoeReaper", 6 },
				{ "DeadminesRipsnarl", 7 },
				{ "DeadminesCookie", 8 },
				{ "DeadminesVanessa", 9 },
			},
			["Info"] = { BabbleZone["The Deadmines"], {"AtlasLootClassicWoW", "AtlasLootCataclysm"}, sortOrder = { "TheDeadminesEnt", "TheDeadmines" }, mapname = "TheDeadmines" },
		},

		["WailingCavernsEnt"] = "WailingCavernsEaI",
		["WailingCaverns"] = "WailingCavernsEaI",
		["WailingCavernsEaI"] = {
			["WailingCavernsEnt"] = {
				{ "WailingCavernsLoot#1", 3, hide = true },
			},
			["WailingCaverns"] = {
				{ "WailingCavernsLoot#1", {2,3,4} },
				{ "WailingCavernsLoot#2", {5,6,7,8,9,12}, hide = true },
				{ "VWOWSets#1", 14, hide = true },
			},
			["Info"] = { BabbleZone["Wailing Caverns"], "AtlasLootClassicWoW", sortOrder = { "WailingCavernsEnt", "WailingCaverns" }, mapname = "WailingCaverns" },
		},

		["TheStockade"] = {
			["Bosses"] = {
				{ "Stockade", {2,3,4} },
			},
			["Info"] = { BabbleZone["The Stockade"], "AtlasLootClassicWoW", mapname = "TheStockade" },
		},

		["TheRuinsofAhnQiraj"] = {
			["Bosses"] = {
				{ "CenarionCircle", 1, hide = true },
				{ "AQ20Kurinnaxx", 3 },
				{ "AQ20Rajaxx", {6,7,8,9,10,11,12,13} },
				{ "AQ20Moam", 14 },
				{ "AQ20Buru", 15 },
				{ "AQ20Ayamiss", 16 },
				{ "AQ20Ossirian", 17 },
				{ "AQ20Trash", 20 },
				{ "AQ20Sets", 21, hide = true },
				{ "AQEnchants", 22 },
			},
			["Info"] = { BabbleZone["Ruins of Ahn'Qiraj"], "AtlasLootClassicWoW", mapname = "RuinsofAhnQiraj" },
		},

		["ZulFarrak"] = {
			["Bosses"] = {
				{ "ZFGahzrilla", 2 },
				{ "ZFSandfury", 3 },
				{ "ZFSergeantBly", 5 },
				{ "ZFSezzziz", 9 },
				{ "ZFNekrumGutchewer", 10 },
				{ "ZFChiefUkorzSandscalp", 11 },
				{ "ZFWitchDoctorZumrah", 13 },
				{ "ZFAntusul", 14 },
				{ "ZFHydromancerVelratha", 15 },
				{ "ZFThekatheMartyr", 16 },
				{ "LunarFestival", 17, hide = true },
				{ "ZFDustwraith", 19 },
				{ "ZFZerillis", 20 },
				{ "ZFTrash", 23 },
			},
			["Info"] = { BabbleZone["Zul'Farrak"], "AtlasLootClassicWoW", mapname = "ZulFarrak" },
		},
	},

---------------------
--- Battlegrounds ---
---------------------

	["Battlegrounds"] = {

		["AlteracValleyNorth"] = {
			["Bosses"] = {
				{ "AlteracFactions", 1 },
				{ "AVMisc", 48 },
				{ "AVBlue", 49 },
			},
			["Info"] = { BabbleZone["Alterac Valley"], "AtlasLootClassicWoW" },
		},

		["AlteracValleySouth"] = {
			["Bosses"] = {
				{ "AlteracFactions", 1 },
				{ "AVMisc", 31 },
				{ "AVBlue", 32 },
			},
			["Info"] = { BabbleZone["Alterac Valley"], "AtlasLootClassicWoW" },
		},

		["ArathiBasin"] = {
			["Bosses"] = {
				{ "MiscFactions", {1,2} },
				{ "AB2039", 11 },
				{ "AB4049", 12 },
				{ "ABSets", 13 },
				{ "ABMisc", 14 },
			},
			["Info"] = { BabbleZone["Arathi Basin"], "AtlasLootClassicWoW" },
		},

		["HalaaPvP"] = {
			["Bosses"] = {
				{ "Nagrand", 1 },
			},
			["Info"] = { BabbleZone["Nagrand"]..": "..AL["Halaa"], "AtlasLootBurningCrusade" },
		},

		["HellfirePeninsulaPvP"] = {
			["Bosses"] = {
				{ "Hellfire", 1 },
			},
			["Info"] = { BabbleZone["Hellfire Peninsula"]..": "..AL["Hellfire Fortifications"], "AtlasLootBurningCrusade" },
		},

		["TerokkarForestPvP"] = {
			["Bosses"] = {
				{ "Terokkar", 1 },
			},
			["Info"] = { BabbleZone["Terokkar Forest"]..": "..AL["Spirit Towers"], "AtlasLootBurningCrusade" },
		},

		["ZangarmarshPvP"] = {
			["Bosses"] = {
				{ "Zangarmarsh", 1 },
			},
			["Info"] = { BabbleZone["Zangarmarsh"]..": "..AL["Twin Spire Ruins"], "AtlasLootBurningCrusade" },
		},

		["WintergraspPvP"] = {
			["Bosses"] = {
				{ "LakeWintergrasp", 1 },
			},
			["Info"] = { BabbleZone["Wintergrasp"], "AtlasLootWotLK" },
		},

		["TolBarad"] = {
			["Bosses"] = {
				{ "BaradinsWardens", 1 },
				{ "HellscreamsReach", 2 },
			},
			["Info"] = { BabbleZone["Tol Barad"], "AtlasLootCataclysm" },
		},

		["TwinPeaks"] = {
			["Bosses"] = {
				{ "WildhammerClan", 1 },
				{ "DragonmawClan", 2 },
			},
			["Info"] = { BabbleZone["Twin Peaks"], "AtlasLootCataclysm" },
		},
	},

--------------------
--- World Bosses ---
--------------------

	["WorldBosses"] = {

		["DoomLordKazzak"] = {
			["Bosses"] = {
				{ "WorldBossesBC", 1 },
				{ "Thrallmar", 5 },
			},
			["Info"] = { BabbleBoss["Doom Lord Kazzak"], "AtlasLootBurningCrusade" },
		},

		["Doomwalker"] = {
			["Bosses"] = {
				{ "WorldBossesBC", 1 },
			},
			["Info"] = { BabbleBoss["Doomwalker"], "AtlasLootBurningCrusade" },
		},

		["Skettis"] = {
			["Bosses"] = {
				{ "Terokk", 9 },
				{ "DarkscreecherAkkarai", 18 },
				{ "GezzaraktheHuntress", 19 },
				{ "Karrog", 20 },
				{ "VakkiztheWindrager", 21 },
			},
			["Info"] = { AL["Skettis"], "AtlasLootWorldEvents" },
		},
	},

--------------------
--- World Events ---
--------------------

	["WorldEvents"] = {

		["Brewfest"] = {
			["Bosses"] = {
				{ "Brewfest" },
				{ "BrewoftheMonthClub" },
				{ "CorenDirebrew" },
			},
			["Info"] = { AL["Brewfest"], "AtlasLootWorldEvents"},
		},

		["Halloween"] = {
			["Bosses"] = {
				{ "Halloween" },
				{ "HeadlessHorseman" },
			},
			["Info"] = { AL["Hallow's End"], "AtlasLootWorldEvents"},
		},

		["MidsummerFestival"] = {
			["Bosses"] = {
				{ "MidsummerFestival" },
				{ "LordAhune" },
			},
			["Info"] = { AL["Midsummer Fire Festival"], "AtlasLootWorldEvents"},
		},
	},

----------------
--- Crafting ---
----------------

	["Crafting"] = {

		["Blacksmithing"] = {
			["Bosses"] = {
				{ "SmithingArmorOld" },
				{ "SmithingArmorBC" },
				{ "SmithingArmorWrath" },
				{ "SmithingArmorCata" },
				{ "SmithingWeaponOld" },
				{ "SmithingWeaponBC" },
				{ "SmithingWeaponWrath" },
				{ "SmithingWeaponCata" },
				{ "SmithingEnhancement" },
				{ "SmithingMisc" },
				{ "Armorsmith" },
				{ "Weaponsmith" },
				{ "Axesmith" },
				{ "Hammersmith" },
				{ "Swordsmith" },
			},
			["Info"] = { BLACKSMITHING, "AtlasLootCrafting"},
		},

		["Enchanting"] = {
			["Bosses"] = {
				{ "EnchantingBoots" },
				{ "EnchantingBracer" },
				{ "EnchantingChest" },
				{ "EnchantingCloak" },
				{ "EnchantingGloves" },
				{ "EnchantingRing" },
				{ "EnchantingShield" },
				{ "Enchanting2HWeapon" },
				{ "EnchantingWeapon" },
				{ "EnchantingStaff" },
				{ "EnchantingMisc" },
			},
			["Info"] = { ENCHANTING, "AtlasLootCrafting"},
		},

		["Leatherworking"] = {
			["Bosses"] = {
				{ "Dragonscale" },
				{ "Elemental" },
				{ "Tribal" },
			},
			["Info"] = { LEATHERWORKING, "AtlasLootCrafting"},
		},

		["Tailoring"] = {
			["Bosses"] = {
				{ "Mooncloth" },
				{ "Shadoweave" },
				{ "Spellfire" },
			},
			["Info"] = { TAILORING, "AtlasLootCrafting"},
		},

		["BlacksmithingMail"] = {
			["Bosses"] = {
				{ "BlacksmithingMailBloodsoulEmbrace" },
				{ "BlacksmithingMailFelIronChain" },
			},
			["Info"] = { BLACKSMITHING..": "..BabbleInventory["Mail"], "AtlasLootCrafting"},
		},

		["BlacksmithingPlate"] = {
			["Bosses"] = {
				{ "BlacksmithingPlateImperialPlate" },
				{ "BlacksmithingPlateTheDarksoul" },
				{ "BlacksmithingPlateFelIronPlate" },
				{ "BlacksmithingPlateAdamantiteB" },
				{ "BlacksmithingPlateFlameG" },
				{ "BlacksmithingPlateEnchantedAdaman" },
				{ "BlacksmithingPlateKhoriumWard" },
				{ "BlacksmithingPlateFaithFelsteel" },
				{ "BlacksmithingPlateBurningRage" },
				{ "BlacksmithingPlateOrnateSaroniteBattlegear" },
				{ "BlacksmithingPlateSavageSaroniteBattlegear" },
			},
			["Info"] = { BLACKSMITHING..": "..BabbleInventory["Plate"], "AtlasLootCrafting"},
		},

		["LeatherworkingLeather"] = {
			["Bosses"] = {
				{ "LeatherworkingLeatherVolcanicArmor" },
				{ "LeatherworkingLeatherIronfeatherArmor" },
				{ "LeatherworkingLeatherStormshroudArmor" },
				{ "LeatherworkingLeatherDevilsaurArmor" },
				{ "LeatherworkingLeatherBloodTigerH" },
				{ "LeatherworkingLeatherPrimalBatskin" },
				{ "LeatherworkingLeatherWildDraenishA" },
				{ "LeatherworkingLeatherThickDraenicA" },
				{ "LeatherworkingLeatherFelSkin" },
				{ "LeatherworkingLeatherSClefthoof" },
				{ "LeatherworkingLeatherPrimalIntent" },
				{ "LeatherworkingLeatherWindhawkArmor" },
				{ "LeatherworkingLeatherBoreanEmbrace" },
				{ "LeatherworkingLeatherIceborneEmbrace" },
				{ "LeatherworkingLeatherEvisceratorBattlegear" },
				{ "LeatherworkingLeatherOvercasterBattlegear" },
			},
			["Info"] = { LEATHERWORKING..": "..BabbleInventory["Leather"], "AtlasLootCrafting"},
		},

		["LeatherworkingMail"] = {
			["Bosses"] = {
				{ "LeatherworkingMailGreenDragonM" },
				{ "LeatherworkingMailBlueDragonM" },
				{ "LeatherworkingMailBlackDragonM" },
				{ "LeatherworkingMailScaledDraenicA" },
				{ "LeatherworkingMailFelscaleArmor" },
				{ "LeatherworkingMailFelstalkerArmor" },
				{ "LeatherworkingMailNetherFury" },
				{ "LeatherworkingMailNetherscaleArmor" },
				{ "LeatherworkingMailNetherstrikeArmor" },
				{ "LeatherworkingMailFrostscaleBinding" },
				{ "LeatherworkingMailNerubianHive" },
				{ "LeatherworkingMailStormhideBattlegear" },
				{ "LeatherworkingMailSwiftarrowBattlefear" },
			},
			["Info"] = { LEATHERWORKING..": "..BabbleInventory["Mail"], "AtlasLootCrafting"},
		},

		["TailoringSets"] = {
			["Bosses"] = {
				{ "TailoringBloodvineG" },
				{ "TailoringNeatherVest" },
				{ "TailoringImbuedNeather" },
				{ "TailoringArcanoVest" },
				{ "TailoringTheUnyielding" },
				{ "TailoringWhitemendWis" },
				{ "TailoringSpellstrikeInfu" },
				{ "TailoringBattlecastG" },
				{ "TailoringSoulclothEm" },
				{ "TailoringPrimalMoon" },
				{ "TailoringShadowEmbrace" },
				{ "TailoringSpellfireWrath" },
				{ "TailoringFrostwovenPower" },
				{ "TailoringDuskweaver" },
				{ "TailoringFrostsavageBattlegear" },
			},
			["Info"] = { TAILORING..": "..BabbleInventory["Cloth"], "AtlasLootCrafting"},
		},
	},

	["Misc"] = {
		["Pets"] = {
			["Bosses"] = {
				{ "PetsMerchant" },
				{ "PetsQuest" },
				{ "PetsCrafted" },
				{ "PetsAchievementFaction" },
				{ "PetsRare" },
				{ "PetsEvent" },
				{ "PetsPromotionalCardGame" },
				{ "PetsPetStore" },
				{ "PetsRemoved" },
				{ "PetsAccessories" },
				{ "PetsCata" },
			},
			["Info"] = { BabbleInventory["Companions"], "AtlasLootCataclysm"},
		},

		["WorldEpics"] = {
			["Bosses"] = {
				{ "WorldEpics80" },
				{ "WorldEpics70" },
				{ "WorldEpics5060" },
				{ "WorldEpics4049" },
				{ "WorldEpics3039" },
			},
			["Info"] = { AL["BoE World Epics"], "AtlasLootWotLK"},
		},
	},

	["PVP"] = {
		["PvP70Accessories"] = {
			["Bosses"] = {
				{ "PvP70Accessories" },
				{ "PvP70Accessories2" },
			},
			["Info"] = { AL["PvP Accessories"].." "..AL["Level 70"], "AtlasLootBurningCrusade"},
		},

		["AlteracValley"] = {
			["Bosses"] = {
				{ "AVMisc" },
				{ "AVBlue" },
			},
			["Info"] = { BabbleZone["Alterac Valley"].." "..AL["Rewards"], "AtlasLootClassicWoW"},
		},

		["WarsongGulch"] = {
			["Bosses"] = {
				{ "WSGMisc", 6 },
				{ "WSGAccessories", 7 },
				{ "WSGWeapons", 8 },
				{ "WSGArmor", 10 },
			},
			["Info"] = { BabbleZone["Warsong Gulch"].." "..AL["Rewards"], "AtlasLootClassicWoW"},
		},
	},

	["Sets"] = {
		["EmblemofTriumph"] = {
			["Bosses"] = {
				{ "EmblemofTriumph" },
				{ "EmblemofTriumph2" },
			},
			["Info"] = { AL["Emblem of Triumph"].." - "..AL["Rewards"], "AtlasLootWotLK"},
		},
	},	
}