-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --


-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster_Crafting", "AceEvent-3.0", "AceConsole-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
TSM.version = GetAddOnMetadata("TradeSkillMaster_Crafting","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster_Crafting", "Version") -- current version of the addon

-- stuff for debugging TSM
function TSM:Debug(...)
	if TSMCRAFTINGDEBUG then
		print(...)
	end
end
local debug = function(...) TSM:Debug(...) end

-- default values for the savedDB
local savedDBDefaults = {
	global = {
		treeStatus = {[2] = true, [5] = true},
	},
	-- data that is stored per user profile
	profile = {
		matLock = {}, -- table of which material costs are locked ('lock mat costs' tab)
		profitPercent = 0, -- percentage to subtract from buyout when calculating profit (5% = AH cut)
		matCostSource = "DBMarket", -- how to calculate the cost of materials
		craftCostSource = "DBMarket",
		craftHistory = {}, -- stores a history of what crafts were crafted
		queueMinProfitGold = {default = 50},
		queueMinProfitPercent = {default = 0.5},
		restockAH = true,
		altAddon = "Gathering",
		altGuilds = {},
		altCharacters = {},
		queueProfitMethod = {default = "gold"},
		doubleClick = 5,
		maxRestockQuantity = {default = 3},
		seenCountFilterSource = "",
		seenCountFilter = 0,
		ignoreSeenCountFilter = {},
		minRestockQuantity = {default = 1},
		dontQueue = {},
		craftManagementWindowScale = 1,
		inscriptionGrouping = 2,
		closeTSMWindow = true,
		lastScan = {},
		alwaysQueue = {},
		craftSortMethod = {default = "name"},
		craftSortOrder = {default = "ascending"},
		unknownProfitMethod = {default = "unknown"}
	},
}

-- Called once the player has loaded WOW.
function TSM:OnEnable()
	TSM.tradeSkills = {{name="Enchanting", spellID=7411}, {name="Inscription", spellID=45357},
		{name="Jewelcrafting", spellID=25229}, {name="Alchemy", spellID=2259},
		{name="Blacksmithing", spellID=2018}, {name="Leatherworking", spellID=2108},
		{name="Tailoring", spellID=3908}, {name="Engineering", spellID=4036},
		{name="Cooking", spellID=2550}}--, {name="Smelting", spellID=2656}}
	
	-- load TradeSkillMaster_Crafting's modules
	TSM.Data = TSM.modules.Data
	TSM.Scan = TSM.modules.Scan
	TSM.GUI = TSM.modules.GUI
	TSM.Crafting = TSM.modules.Crafting
	
	-- load all the profession modules
	for _, data in pairs(TSM.tradeSkills) do
		TSM[data.name] = TSM.modules[data.name]
	end
	
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_CraftingDB", savedDBDefaults, true)
	TSM.Data:Initialize() -- setup TradeSkillMaster_Crafting's internal data table using some savedDB data

	local origProfile = TSM.db:GetCurrentProfile()
	for _, name in pairs(TSM.db:GetProfiles()) do
		TSM.db:SetProfile(name)
		if type(TSM.db.profile.queueProfitMethod) == "string" then
			TSM.db.profile.queueProfitMethod = {default=TSM.db.profile.queueProfitMethod}
		end
		if type(TSM.db.profile.queueMinProfitGold) == "number" then
			TSM.db.profile.queueMinProfitGold = {default=TSM.db.profile.queueMinProfitGold}
		end
		if type(TSM.db.profile.queueMinProfitPercent) == "number" then
			TSM.db.profile.queueMinProfitPercent = {default=TSM.db.profile.queueMinProfitPercent}
		end
		if type(TSM.db.profile.queueProfitMethod.default) == "table" then
			TSM.db.profile.queueProfitMethod.default = "gold"
		end
		if type(TSM.db.profile.queueMinProfitGold.default) == "table" then
			TSM.db.profile.queueMinProfitGold.default = 50
		end
		if type(TSM.db.profile.queueMinProfitPercent.default) == "table" then
			TSM.db.profile.queueMinProfitPercent.default = 0.5
		end
	end
	TSM.db:SetProfile(origProfile)
	
	TSMAPI:RegisterModule("TradeSkillMaster_Crafting", TSM.version, GetAddOnMetadata("TradeSkillMaster_Crafting", "Author"),
		GetAddOnMetadata("TradeSkillMaster_Crafting", "Notes"))
	TSMAPI:RegisterData("shopping", function(_, mode) return TSM.Data:GetShoppingData(mode or "shopping") end)
	TSMAPI:RegisterData("craftingcost", function(_, itemID) return TSM.Data:GetCraftingCost(itemID) end)
end

function TSM:OnDisable()
	TSM.db.global.treeStatus = TSM.GUI.TreeGroup.frame.obj.status.groups
end

-- converts an itemID into the name of the item.
function TSM:GetName(sID)
	if not sID then return end
	
	if not tonumber(sID) then return sID end
	
	local cachedName = TSM:GetNameFromGlobalNameCache(sID)
	if cachedName then return cachedName end

	local queriedName = GetItemInfo(sID)
	
	if not queriedName then
		queriedName = TSM:GetNameFromMatsForCurrentMode(sID)
		queriedName = TSM:GetNameFromCraftsForCurrentMode(sID)
		if not queriedName and sID == 38682 and GetLocale() == "enUS" then
			queriedName = "Enchanting Vellum"
		end
	end
	
	if queriedName then
		TSM:StoreNameInGlobalNameCache(sID, queriedName)
		
		if TSM:GetMatForCurrentMode(sID) and not TSM:GetMatForCurrentMode(sID).name then
			TSM:GetMatForCurrentMode(sID).name = queriedName
		end
		return queriedName
	else
		-- sad face :(
		TSM:Print(format("TradeSkillMaster imploded on itemID %s. This means you have not seen this " ..
			"item since the last patch and TradeSkillMaster_Crafting doesn't have a record of it. Try to find this " ..
			"item in game and then TradeSkillMaster_Crafting again. If you continue to get this error message please " ..
			"report this to the author (include the itemID in your message).", sID))
	end
end


function TSM:GetMode()
	local mode
	if TSM.Crafting.frame and TSM.Crafting.frame:IsVisible() then
		mode = TSM.Crafting.mode or TSM.mode
	else
		mode = TSM.mode
	end
	
	return mode
end

function TSM:GetNameFromGlobalNameCache(sID)
	if TSM.db.global[sID] then -- check to see if we have the name stored already in the saved DB
		if TSM.db.global[sID] == "Armor Vellum" then
			TSM.db.global[sID] = "Enchanting Vellum"
		end
		return TSM.db.global[sID]
	end
end
   
function TSM:StoreNameInGlobalNameCache(itemID, queriedName)
	TSM.db.global[itemID] = queriedName
end

function TSM:GetNameFromMatsForCurrentMode(itemID)
	local mode = TSM:GetMode()
	if TSM.Data[mode].mats[itemID] then
		return TSM.Data[mode].mats[itemID].name
	end
end

function TSM:GetNameFromCraftsForCurrentMode(itemID)
	local mode = TSM:GetMode()
	if TSM.Data[mode].crafts[itemID] then
		return TSM.Data[mode].crafts[itemID].name
	end
end

function TSM:GetMatForCurrentMode(itemID)
	local mode = TSM:GetMode()
	return TSM.Data[mode].mats[itemID]
end

local vendorMats = {[2324]=0.0025, [2325]=0.1, [6260]=0.005, [2320]=0.001, [38426]=3, [2321]=0.001, [4340]=0.035, [2605]=0.001,
		[8343]=0.2, [6261]=0.01, [10290]=0.25, [4342]=0.25, [2604]=0.005, [14341]=0.5, [4291]=0.05, [4341]=0.05, [38682] = 0.1,
		[39354]=0, [10648]=0.01, [39501]=0.12, [39502]=0.5, [3371]=0.01, [3466]=0.2, [2880]=0.01, [44835]=0.001, [62786]=0.1,
		[62788]=0.1, [58274]=1.1, [17194]=0.001, [17196]=0.005, [44853]=0.0025, [2678]=0.001, [62787]=0.1, [30817]=0.0025,
		[34412]=0.1, [58278]=1.6, [35949]=0.85, [17020]=0.1, [10647]=0.2, [39684]=0.9, [4400]=0.2, [4470]=0.0038, [11291]=0.45,
		[40533]=5, [4399]=0.02, [52188]=1.5, [4289]=0.005}

function TSM:GetVendorPrice(itemID)
	return vendorMats[itemID]
end

function TSM:GetDBValue(key, profession, itemID)
	return (itemID and TSM.db.profile[key][itemID]) or (profession and TSM.db.profile[key][profession]) or TSM.db.profile[key].default
end

function TSM:GoldToGoldSilverCopper(oGold, noCopper)
	if not oGold then return end
	local gold = floor(oGold)
	local silver, copper
	
	if noCopper then
		silver = floor(oGold*SILVER_PER_GOLD+0.5)%SILVER_PER_GOLD
	else
		silver = floor(oGold*SILVER_PER_GOLD)%SILVER_PER_GOLD
		copper = floor(oGold*COPPER_PER_GOLD)%COPPER_PER_SILVER
	end
	
	return gold, silver, copper
end