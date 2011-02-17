local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster_Shopping", "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local debugLog = {}
function TSM:Debug(...)
	local args = {...}
	for i=1, #args do
		if type(args[i]) ~= "string" and type(args[i]) ~= "number" then
			args[i] = ""
		end
	end
	tinsert(debugLog, table.concat(args, " "))
end

function TSMShoppingDebugLogDump(num)
	num = num or 10
	if num > #debugLog then num = #debugLog end
	for i=(#debugLog-num+1), #debugLog do
		if not debugLog[i] then break end
		
		print(debugLog[i])
	end
end

local savedDBDefaults = {
	global = {
		itemNames = {},
		neverShopFor = {},
		DealfinderList = {},
		blockAuc = true
	},
	profile = {
		fullStacksOnly = true,
	},
}

function TSMNeverShopFor(item, toRemove)
	local ok, _, link = pcall(GetItemInfo(item))
	if not ok then return TSM:Print("Invalid Item.") end
	local itemID = TSMAPI:GetItemID(link)
	if not itemID then return TSM:Print("Unable to lookup item. Try finding the itemID on wowhead.com and using that.") end

	if toRemove then
		TSM.db.global.neverShopFor[itemID] = nil
	else
		TSM.db.global.neverShopFor[itemID] = true
	end
end

function TSM:OnEnable()
	TSM.db = LibStub("AceDB-3.0"):New("TradeSkillMaster_ShoppingDB",savedDBDefaults)
	local version = GetAddOnMetadata("TradeSkillMaster_Shopping", "X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster_Shopping", "version")
	TSMAPI:RegisterModule("TradeSkillMaster_Shopping", version, GetAddOnMetadata("TradeSkillMaster_Shopping", "author"), GetAddOnMetadata("TradeSkillMaster_Shopping", "notes"), 1)
	
	TSM.Scan = TSM.modules.Scan
	TSM.GUI = TSM.modules.GUI
	TSM.Destroying = TSM.modules.Destroying
	TSM.General = TSM.modules.General
	TSM.Automatic = TSM.modules.Automatic
	TSM.Dealfinder = TSM.modules.Dealfinder
	TSM.Config = TSM.modules.Config
	
	-- move the deal finder list from profile to global
	if TSM.db.profile.DealfinderList then
		TSM.db.global.DealfinderList = CopyTable(TSM.db.profile.DealfinderList)
		TSM.db.profile.DealfinderList = nil
	end
	
	--TSMAPI:RegisterIcon("Shopping Options", "Interface\\Icons\\Inv_Misc_Token_ArgentDawn2", function(...) TSMAuc.Config:Load(...) end, "TradeSkillMaster_Shopping", "options")
end

-- converts an itemID into the name of the item.
function TSM:GetItemName(itemID)
	if not tonumber(itemID) then return print("NOT A NUMBER", itemID) end
	
	TSM.db.global.itemNames[itemID] = TSM.db.global.itemNames[itemID] or GetItemInfo(itemID)
	
	return TSM.db.global.itemNames[itemID]
end

local GOLD_TEXT = "|cffffd700g|r"
local SILVER_TEXT = "|cffc7c7cfs|r"
local COPPER_TEXT = "|cffeda55fc|r"

function TSM:FormatTextMoney(money)
	local money = tonumber(money)
	if not money then return end
	local gold = math.floor(money / COPPER_PER_GOLD)
	local silver = math.floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = math.floor(money%COPPER_PER_SILVER)
	local text = ""
	
	-- Add gold
	if gold > 0 then
		text = string.format("%d%s ", gold, GOLD_TEXT)
	end
	
	-- Add silver
	if silver > 0 then
		text = string.format("%s%d%s ", text, silver, SILVER_TEXT)
	end
	
	-- Add copper if we have no silver/gold found, or if we actually have copper
	if copper > 0 then
		text = string.format("%s%d%s ", text, copper, COPPER_TEXT)
	end
	
	return string.trim(text)
end

function TSM:UnformatTextMoney(value)
	value = gsub(value, "|cffffd700g|r", "g")
	value = gsub(value, "|cffc7c7cfs|r", "s")
	value = gsub(value, "|cffeda55fc|r", "c")
	local gold = tonumber(string.match(value, "([0-9]+)g"))
	local silver = tonumber(string.match(value, "([0-9]+)s"))
	local copper = tonumber(string.match(value, "([0-9]+)c"))
	
	if not gold and not silver and not copper then
		return
	else
		-- Convert it all into copper
		return (copper or 0) + ((gold or 0) * COPPER_PER_GOLD) + ((silver or 0) * COPPER_PER_SILVER)
	end
end

-- sorts the auctions scanned by the various shopping functions
-- sorts by items in the priorityList with the item at index 1 having highest priority
function TSM:SortAuctions(auctions, priorityList)
	local function sortFunc(a, b)
		for _, property in ipairs(priorityList) do
			if a[property] ~= b[property] then
				return a[property] < b[property]
			end
		end
	end
	
	sort(auctions, sortFunc)
end