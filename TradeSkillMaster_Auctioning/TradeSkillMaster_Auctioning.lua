local TSMAuc = select(2, ...)
TSMAuc = LibStub("AceAddon-3.0"):NewAddon(TSMAuc, "TradeSkillMaster_Auctioning", "AceEvent-3.0", "AceConsole-3.0")
TSMAuc.status = {}
TSMAuc.version = GetAddOnMetadata("TradeSkillMaster_Auctioning","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster_Auctioning", "Version") -- current version of the addon

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
TSMAuc.itemReverseLookup = {}
TSMAuc.groupReverseLookup = {}
local status = TSMAuc.status
local statusLog, logIDs, lastSeenLogID = {}, {}

-- versionKey is used to ensure inter-module compatibility when new features are added
local versionKey = 1


function TSMAuc:CopySettings(otherDB)
	local profileSettings = {
		noCancel = {default = false},
		undercut = {default = 1},
		postTime = {default = 12},
		bidPercent = {default = 1.0},
		fallback = {default = 50000},
		fallbackCap = {default = 5},
		threshold = {default = 10000},
		postCap = {default = 4},
		perAuction = {default = 1},
		perAuctionIsCap = {default = false},
		priceThreshold = {default = 10},
	}
	local globalSettings = {
		showStatus = false,
		smartUndercut = false,
		smartCancel = true,
		cancelWithBid = false,
		hideHelp = false,
		hideGray = false,
		blockAuc = true,
	}
	local factionrealmSettings = {
		player = {},
		whitelist = {},
	}
	
	for i in pairs(profileSettings) do
		for group, value in pairs(otherDB.profile[i]) do
			TSMAuc.db.profile[i][strlower(group)] = value
		end
	end
	TSMAuc.db.profile.ignoreStacksOver = CopyTable(otherDB.profile.ignoreStacks)
	
	for i in pairs(globalSettings) do
		TSMAuc.db.global[i] = otherDB.global[i]
	end
	
	for i in pairs(factionrealmSettings) do
		TSMAuc.db.factionrealm[i] = CopyTable(otherDB.factionrealm[i])
	end
	
	for name, data in pairs(otherDB.global.groups) do
		TSMAuc.db.profile.groups[strlower(name)] = CopyTable(data)
	end
	for _, group in pairs(TSMAuc.db.profile.groups) do
		local temp = CopyTable(group)
		for oldID, value in pairs(temp) do
			if type(oldID) ~= "number" then
				local newID = gsub(oldID, "item:", "")
				newID = tonumber(newID)
				if newID then
					group[newID] = value
					group[oldID] = nil
				end
			end
		end
	end
end

-- Addon loaded
function TSMAuc:OnInitialize()
	local defaults = {
		profile = {
			noCancel = {default = false},
			undercut = {default = 1},
			postTime = {default = 12},
			bidPercent = {default = 1.0},
			fallback = {default = 50000},
			fallbackPercent = {},
			fallbackPriceMethod = {default = "gold"},
			fallbackCap = {default = 5},
			threshold = {default = 10000},
			thresholdPercent = {},
			thresholdPriceMethod = {default = "gold"},
			postCap = {default = 4},
			perAuction = {default = 1},
			perAuctionIsCap = {default = false},
			priceThreshold = {default = 10},
			ignoreStacksOver = {default = 1000},
			ignoreStacksUnder = {default = 1},
			reset = {default = "none"},
			resetPrice = {default = 30000},
			groups = {},
			categories = {},
		},
		global = {
			infoID = -1,
			showStatus = false,
			smartUndercut = false,
			smartCancel = true,
			cancelWithBid = false,
			hideHelp = false,
			hideGray = false,
			hideAdvanced = nil,
			addItemsAsIcons = 3,
			treeGroupStatus = {treewidth = 200, groups={[2]=true}},
		},
		factionrealm = {
			player = {},
			whitelist = {},
		},
	}
	
	TSMAuc.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_AuctioningDB", defaults, true)
	TSMAuc.Cancel = TSMAuc.modules.Cancel
	TSMAuc.Config = TSMAuc.modules.Config
	TSMAuc.Log = TSMAuc.modules.Log
	TSMAuc.Post = TSMAuc.modules.Post
	TSMAuc.Scan = TSMAuc.modules.Scan
	TSMAuc.Manage = TSMAuc.modules.Manage
	TSMAuc.Status = TSMAuc.modules.Status
	
	-- Add this character to the alt list so it's not undercut by the player
	TSMAuc.db.factionrealm.player[UnitName("player")] = true
	
	if TSMAuc.db.profile.ignoreStacks then
		TSMAuc.db.profile.ignoreStacksOver = CopyTable(TSMAuc.db.profile.ignoreStacks)
		TSMAuc.db.profile.ignoreStacks = nil
	end
	
	-- converts itemIDs to itemStrings in the savedDB
	-- this shouldn't be deleted for a long time...
	local temp = {}
	for name, items in pairs(TSMAuc.db.profile.groups) do
		for itemID, value in pairs(items) do
			if type(itemID) == "number" then
				local itemString = TSMAuc:GetItemString(itemID)
				tinsert(temp, {name, itemID, itemString, value})
			end
		end
	end
	for _, data in ipairs(temp) do
		TSMAuc.db.profile.groups[data[1]][data[2]] = nil
		TSMAuc.db.profile.groups[data[1]][data[3]] = data[4]
	end
	
	if TSMAuc.db.profile.autoFallback then
		for group, value in pairs(TSMAuc.db.profile.autoFallback) do
			if value then
				TSMAuc.db.profile.reset[group] = "fallback"
			end
		end
		TSMAuc.db.profile.autoFallback = nil
	end
	
	for _, items in pairs(TSMAuc.db.profile.groups) do
		local fix = {}
		for itemString in pairs(items) do
			if #{(":"):split(itemString)} > 8 then
				tinsert(fix, itemString)
			end
		end
		for _, itemString in ipairs(fix) do
			items[itemString] = nil
			local newItemString = TSMAuc:GetItemString(itemString)
			if newItemString then
				items[newItemString] = true
			end
		end
	end
	
	-- Wait for auction house to be loaded
	TSMAuc:RegisterEvent("ADDON_LOADED", function(event, addon)
		if addon == "Blizzard_AuctionUI" then
			TSMAuc:UnregisterEvent("ADDON_LOADED")
			AuctionsTitle:Hide()
		end
	end)
	
	if IsAddOnLoaded("Blizzard_AuctionUI") then
		TSMAuc:UnregisterEvent("ADDON_LOADED")
		AuctionsTitle:Hide()
	end
	
	TSMAuc:ShowInfoPanel()
	TSMAPI:RegisterModule("TradeSkillMaster_Auctioning", TSMAuc.version, GetAddOnMetadata("TradeSkillMaster_Auctioning", "Author"),
		GetAddOnMetadata("TradeSkillMaster_Auctioning", "Notes"), versionKey)
	TSMAPI:RegisterIcon(L["Auctioning Groups/Options"], "Interface\\Icons\\Racial_Dwarf_FindTreasure", function(...) TSMAuc.Config:LoadOptions(...) end, "TradeSkillMaster_Auctioning", "options")
	TSMAuc:RegisterMessage("TSMAUC_NEW_GROUP_ITEM")
	TSMAPI:RegisterData("auctioningGroups", TSMAuc.GetGroups)
	TSMAPI:RegisterData("auctioningCategories", TSMAuc.GetCategories)
	TSMAPI:RegisterData("auctioningGroupItems", TSMAuc.GetGroupItems)
end

function TSMAuc:OnDisable()
	TSMAuc.db.global.treeGroupStatus = TSM.Config.treeGroup.frame.obj.status.groups
end

function TSMAuc:ShowInfoPanel()
	local messages = {
		L["Welcome to TradeSkillMaster_Auctioning!\n\nPlease click on the OK button below to enable APM and then reload your UI so your settings can be transferred!"],
		L["Welcome to TradeSkillMaster_Auctioning!\n\nPlease click on the OK button below to transfer your settings, disable APM, and reload your UI!"],
		L["TradeSkillMaster_Auctioning has detected that you have APM/ZA/QA3 running.\n\nPlease disable APM/ZA/QA3 by clicking on the OK button below."]
	}
	
	if not select(2, GetAddOnInfo("AuctionProfitMaster")) or TSMAuc.db.global.infoID == 1 and not select(4, GetAddOnInfo("AuctionProfitMaster")) or TSMAuc.db.global.infoID == 2 then
		return
	end
	
	local needToDisable
	if TSMAuc.db.global.infoID == 1 and (select(4, GetAddOnInfo("AuctionProfitMaster")) or select(4, GetAddOnInfo("ZeroAuctions")) or select(4, GetAddOnInfo("QuickAuctions"))) then
		needToDisable = true
	elseif select(4, GetAddOnInfo("AuctionProfitMaster")) then
		TSMAuc.db.global.infoID = 0
	end
	
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("HIGH")
	frame:SetToplevel(true)
	frame:SetWidth(400)
	frame:SetHeight(285)
	frame:SetBackdrop({
		  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		  edgeSize = 26,
		  insets = {left = 9, right = 9, top = 9, bottom = 9},
	})
	frame:SetBackdropColor(0, 0, 0, 0.85)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

	frame.titleBar = frame:CreateTexture(nil, "ARTWORK")
	frame.titleBar:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	frame.titleBar:SetPoint("TOP", 0, 8)
	frame.titleBar:SetWidth(405)
	frame.titleBar:SetHeight(45)

	frame.title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	frame.title:SetPoint("TOP", 0, 0)
	frame.title:SetText("TradeSkillMaster_Auctioning")
	
	local text = L["Important! Please read!"].."\n\n"
	if TSMAuc.db.global.infoID == -1 then
		text = text .. messages[1]
	elseif TSMAuc.db.global.infoID == 0 then
		text = text .. messages[2]
	elseif needToDisable then
		text = text .. messages[3]
	end

	frame.text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	frame.text:SetText(text)
	frame.text:SetPoint("TOPLEFT", 12, -22)
	frame.text:SetWidth(frame:GetWidth() - 20)
	frame.text:SetJustifyH("LEFT")
	frame:SetHeight(frame.text:GetHeight() + 70)

	frame.transfer = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.transfer:SetText("OK")
	frame.transfer:SetHeight(20)
	frame.transfer:SetWidth(100)
	frame.transfer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 8)
	frame.transfer:SetScript("OnClick", function(self)
		if TSMAuc.db.global.infoID == -1 then
			TSMAuc.db.global.infoID = 0
			EnableAddOn("AuctionProfitMaster")
			ReloadUI()
		elseif TSMAuc.db.global.infoID == 0 then
			if not select(4, GetAddOnInfo("AuctionProfitMaster")) then
				TSMAuc.db.global.infoID = -1
			else
				local APMDB = LibStub("AceAddon-3.0"):GetAddon("AuctionProfitMaster").db
				TSMAuc:CopySettings(APMDB)
				TSMAuc.db.global.infoID = 1
				DisableAddOn("AuctionProfitMaster")
				ReloadUI()
			end
		elseif needToDisable then
			DisableAddOn("AuctionProfitMaster")
			ReloadUI()
		else
			TSMAuc.db.global.infoID = 1
		end
		self:GetParent():Hide()
	end)
	
	frame.hide = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.hide:SetText("Cancel")
	if needToDisable then frame.hide:SetText("Hide Forever") end
	frame.hide:SetHeight(20)
	frame.hide:SetWidth(100)
	frame.hide:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 156, 8)
	frame.hide:SetScript("OnClick", function(self)
		self:GetParent():Hide()
		if needToDisable then
			TSMAuc.db.global.infoID = 2
		end
	end)
	
	TSMAuc.InfoFrame = frame
end

local GOLD_TEXT = "|cffffd700g|r"
local SILVER_TEXT = "|cffc7c7cfs|r"
local COPPER_TEXT = "|cffeda55fc|r"

-- Truncate tries to save space, after 300g stop showing copper, after 3000g stop showing silver
function TSMAuc:FormatTextMoney(money, truncate, noColor)
	if not money then return end
	local gold = math.floor(money / COPPER_PER_GOLD)
	local silver = math.floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = math.floor(math.fmod(money, COPPER_PER_SILVER))
	local text = ""
	
	-- Add gold
	if gold > 0 then
		text = string.format("%d%s ", gold, (not noColor and GOLD_TEXT or "g"))
	end
	
	-- Add silver
	if silver > 0 and (not truncate or gold < 1000) then
		text = string.format("%s%d%s ", text, silver, (not noColor and SILVER_TEXT or "s"))
	end
	
	-- Add copper if we have no silver/gold found, or if we actually have copper
	if text == "" or (copper > 0 and (not truncate or gold < 100)) then
		text = string.format("%s%d%s ", text, copper, (not noColor and COPPER_TEXT or "c"))
	end
	
	return string.trim(text)
end

-- Makes sure this bag is an actual bag and not an ammo, soul shard, etc bag
function TSMAuc:IsValidBag(bag)
	if bag == 0 or bag == -1 then return true end
	
	-- family 0 = bag with no type, family 1/2/4 are special bags that can only hold certain types of items
	local itemFamily = GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)))
	return itemFamily and ( itemFamily == 0 or itemFamily > 4 )
end

function TSMAuc:UpdateItemReverseLookup()
	wipe(TSMAuc.itemReverseLookup)
	
	for group, items in pairs(TSMAuc.db.profile.groups) do
		for itemID in pairs(items) do
			TSMAuc.itemReverseLookup[itemID] = group
		end
	end
end

function TSMAuc:UpdateGroupReverseLookup()
	wipe(TSMAuc.groupReverseLookup)
	
	for category, groups in pairs(TSMAuc.db.profile.categories) do
		for groupName in pairs(groups) do
			TSMAuc.groupReverseLookup[groupName] = category
		end
	end
end

-- returns a table of all Auctioning categories
function TSMAuc:GetCategories()
	return CopyTable(TSMAuc.db.profile.categories)
end

-- returns a nicely formatted table of all Auctioning groups
function TSMAuc:GetGroups()
	local groups = CopyTable(TSMAuc.db.profile.groups)
	local temp = {}
	for groupName, items in pairs(groups) do
		for itemString, value in pairs(items) do
			local s1 = gsub(gsub(itemString, "item:", ""), "enchant:", "")
			local itemID = tonumber(strsub(s1, 1, strfind(s1, ":")-1))
			if itemID then
				tinsert(temp, {groupName, itemString, itemID, value})
			end
		end
	end
	
	for _, data in ipairs(temp) do
		groups[data[1]][data[2]] = nil
		groups[data[1]][data[3]] = data[4]
	end
	
	return groups
end

-- returns the items in the passed group
function TSMAuc:GetGroupItems(name)
	local groups = TSMAuc:GetGroups()
	if not groups[name] then return end
	local temp = {}
	for itemID in pairs(groups[name]) do
		tinsert(temp, itemID)
	end
	return temp
end

-- message handler that fires when Crafting creates a new group (or adds an item to one)
function TSMAuc:TSMAUC_NEW_GROUP_ITEM(_, groupName, itemID, isNewGroup, category)
	itemID = itemID and select(2, GetItemInfo(itemID)) or itemID
	groupName = strlower(groupName or "")
	if not groupName or groupName == "" then return end
	if isNewGroup then
		if not TSMAuc.db.profile.groups[groupName] then
			TSMAuc.db.profile.groups[groupName] = {}
			if category then
				TSMAuc.db.profile.categories[category][groupName] = true
			end
		else
			TSMAuc:Print(format(L["Group named \"%s\" already exists! Item not added."], groupName))
			return
		end
	else
		if not TSMAuc.db.profile.groups[groupName] then
			TSMAuc:Print(format(L["Group named \"%s\" does not exist! Item not added."], groupName))
			return
		end
	end
	if itemID then
		local itemString = TSMAuc:GetItemString(itemID)
		if itemString then
			TSMAuc:UpdateItemReverseLookup()
			if TSMAuc.itemReverseLookup[itemString] then
				TSMAuc.db.profile.groups[TSMAuc.itemReverseLookup[itemString]][itemString] = nil
			end
			TSMAuc.db.profile.groups[groupName][itemString] = true
		else
			TSMAuc:Print(L["Item failed to add to group."])
		end
	end
end

function TSMAuc:GetItemString(itemLink)
	if not itemLink then return end
	local link = select(2, GetItemInfo(itemLink))
	if not link then
		if tonumber(itemLink) then
			return "item:"..itemLink..":0:0:0:0:0:0"
		else
			return
		end
	end
	local _, _, _, t, itemID, id1, id2, id3, id4, id5, id6 = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return t..":"..itemID..":"..id1..":"..id2..":"..id3..":"..id4..":"..id5..":"..id6
end

function TSMAuc:ItemStringToID(itemString)
	local sNum = strfind(itemString, ":")
	local eNum = strfind(itemString, ":", sNum+1)
	return tonumber(strsub(itemString, sNum+1, eNum-1))
end

local function GetItemCost(source, itemString)
	local itemID = TSMAuc:ItemStringToID(itemString)
	local itemLink = select(2, GetItemInfo(itemID))

	if source == "dbmarket" then
		return TSMAPI:GetData("market", itemID)
	elseif source == "dbminbuyout" then
		return select(5, TSMAPI:GetData("market", itemID))
	elseif source == "crafting" then
		return TSMAPI:GetData("craftingcost", itemID)
	elseif source == "aucappraiser" and AucAdvanced then
		return AucAdvanced.Modules.Util.Appraiser.GetPrice(itemLink)
	elseif source == "aucminbuyout" and AucAdvanced then
		return select(6, AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems(itemLink))
	elseif source == "aucmarket" and AucAdvanced then
		return AucAdvanced.API.GetMarketValue(itemLink)
	elseif source == "iacost" and IAapi then
		return max(select(2, IAapi.GetItemCost(itemLink)), (select(11, GetItemInfo(itemLink)) or 0))
	end
end

function TSMAuc:GetMarketValue(group, percent, method)
	local cost = 0
	
	if TSMAuc.db.profile.groups[group] then
		for itemString in pairs(TSMAuc.db.profile.groups[group]) do
			local newCost = GetItemCost(method, itemString)
			if newCost and newCost > cost then
				cost = newCost
			end
		end
	end
	
	return cost*(percent or 1)
end