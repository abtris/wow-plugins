-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --


-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Data = TSM:NewModule("Data", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local debug = function(...) TSM:Debug(...) end -- for debugging

-- initialize all the data tables
function Data:Initialize()
	Data:RegisterEvent("CHAT_MSG_SYSTEM")

	for _, data in pairs(TSM.tradeSkills) do
		-- load all the crafts into Data.crafts
		TSM.db.profile[data.name] = TSM.db.profile[data.name] or {}
		Data[data.name] = TSM.db.profile[data.name]
		Data[data.name].mats = Data[data.name].mats or {}
		Data[data.name].crafts = Data[data.name].crafts or {}
		Data.onAH = {}
		
		local toRemove = {}
		for itemID, craft in pairs(Data[data.name].crafts) do
			craft.group = TSM[data.name]:GetSlot(itemID) or craft.group
			craft.sell = nil
			craft.posted = nil
			if craft.enabled == nil then craft.enabled = true end
			if data.name == "Inscription" and TSM.Inscription.slot1[itemID] == 10 then
				tinsert(toRemove, itemID)
			end
		end
		for _, id in pairs(toRemove) do
			Data[data.name].crafts[id] = nil
		end
		
		-- add any materials that aren't in the default table to the data table
		for id in pairs(Data[data.name].mats) do
			id = tonumber(id)
			-- the id is going to be the key (and the value is the cost of that material which we don't care about)
			local NeedToAdd = nil -- keep track of whether or not this needs to be added to the data table
			for itemID, chant in pairs(Data[data.name].crafts) do
				-- for every craft in the data table...
				for mat in pairs(chant.mats) do
					-- check to see if the mat (corresponding to the 'id' variable) is used by the craft
					if id == tonumber(mat) then
						-- if so, we must add it to TSM's internal list of itemIDs for materials
						NeedToAdd = true
					end
				end
			end
			
			-- remove the mat from the savedDB if it is unused
			if not NeedToAdd then
				Data[data.name].mats[id] = nil
			end
		end
	end
end

function Data:ReGroup()
	for itemID, craft in pairs(Data["Inscription"].crafts) do
		craft.group = TSM.Inscription:GetSlot(itemID) or craft.group
	end
end

local idCache = {}
-- calulates the cost, buyout, and profit for a crafted item
function Data:CalcPrices(craft, forCrafting)
	if not craft then return end
	local itemID
	
	local mode = TSM.mode
	if forCrafting then
		mode = TSM.Crafting.mode or mode
	end

	if type(craft) == "number" then
		itemID = craft
		craft = Data[mode].crafts[craft]
		idCache[craft.spellID] = itemID
	end
	
	itemID = itemID or idCache[craft.spellID]
	
	if not itemID then
		for sID, data in pairs(Data[mode].crafts) do
			if data.spellID == craft.spellID then
				idCache[craft.spellID] = sID
				itemID = idCache[craft.spellID]
				break
			end
		end
		if not itemID then return end
	end

	-- first, we calculate the cost of crafting that crafted item based off the cost of the individual materials
	local cost = 0
	for id, matQuantity in pairs(craft.mats) do
		TSM.Data[mode].mats[id] = TSM.Data[mode].mats[id] or {}
		TSM.Data[mode].mats[tonumber(id)].cost = Data[mode].mats[tonumber(id)].cost or 1
		cost = cost + matQuantity*TSM.db.profile[mode].mats[tonumber(id)].cost
	end
	cost = math.floor(cost/(craft.numMade or 1) + 0.5) --rounds to nearest gold
	
	-- next, we get the buyout from the auction scan data table and calculate the profit
	local buyout, profit
	local sell = Data:GetMarketPrice(itemID, "craft")
	if sell then
		-- grab the buyout price and calculate the profit if the buyout price exists and is a valid number
		buyout = sell
		profit = buyout - buyout*TSM.db.profile.profitPercent - cost
		profit = math.floor(profit + 0.5) -- rounds to the nearest gold
	end
	
	-- return the results
	return cost, buyout, profit
end

-- Calculates the weight of grouped mats (given by itemIDs)
-- itemIDs = { {id = 43044, weight = 1.7}, {id = 34044, weight = 7.1}, ... }
function Data:WeightGroupedMats(itemIDs)
	if not itemIDs then return end
	
	local costs = {}
	for i,v in ipairs(itemIDs) do
		tinsert(costs, {id=v.id, cost=v.weight*(Data:GetMarketPrice(v.id, "mat") or 1/0)})
	end
	sort(costs, function(a, b) return a.cost<b.cost end)
	if costs[2] and costs[2].cost ~= 1/0 then
		if TSM:GetMode() ~= "Inscription" or #(itemIDs) <= 2 then 
			return costs[1].cost -- idk
		end
		return costs[2].cost
	else
		return costs[1].cost
	end
end

-- Calculate mat costs of the current mode from current data.
function Data:CalculateCosts(mode)
	local result = 0
	local value, volume, lastSeen, stdDev
	local groupedMats = {}
	mode = mode or TSM:GetMode()
	local matList = TSM.Data:GetMats(mode)
	local function FillGroups(groupedMats, itemID, w)
		tinsert(groupedMats, {id = itemID, weight = 1})
		for i2,v2 in ipairs(Data[mode].crafts[itemID].mats) do
			tinsert(groupedMats, {id = i2, weight = w*v2})
			if Data[mode].crafts[i2] then FillGroups(groupedMats, v2, w*v2) end
		end
	end
	
	for _, itemID in ipairs(matList) do
		wipe(groupedMats)
		result = Data:GetMarketPrice(itemID, "mat")
		-- This is where grouped mats for custom cost evaluation goes.
		if mode == "Inscription" and TSM.Inscription:GetInkMats(itemID) then
			local inkMats = TSM.Inscription:GetInkMats(itemID)
			for _,herb in ipairs(inkMats.herbs) do
				tinsert(groupedMats, {id = herb.itemID, weight = inkMats.pigmentPerInk/(herb.pigmentPerMill/5)})
			end
			tinsert(groupedMats, {id = inkMats.pigment, weight = inkMats.pigmentPerInk}) -- the pigment itself
			tinsert(groupedMats, {id = itemID, weight = 1}) -- The ink itself
			if itemID ~= 61978 then
				if itemID == 61981 then -- inferno ink
					inkMats = TSM.Inscription:GetInkMats(61978)
					for _,herb in ipairs(inkMats.herbs) do
						tinsert(groupedMats, {id = herb.itemID, weight = 0.1*inkMats.pigmentPerInk/(herb.pigmentPerMill/5)})
					end
					tinsert(groupedMats, {id = inkMats.pigment, weight = 0.1*inkMats.pigmentPerInk})
					tinsert(groupedMats, {id = 61978, weight = 0.1})
				else
					inkMats = TSM.Inscription:GetInkMats(61978)
					for _,herb in ipairs(inkMats.herbs) do
						tinsert(groupedMats, {id = herb.itemID, weight = inkMats.pigmentPerInk/(herb.pigmentPerMill/5)})
					end
					tinsert(groupedMats, {id = inkMats.pigment, weight = inkMats.pigmentPerInk})
					tinsert(groupedMats, {id = 61978, weight = 1})
				end
			end
			result = Data:WeightGroupedMats(groupedMats)
		end
		if TSM:GetVendorPrice(itemID) then
			result = TSM:GetVendorPrice(itemID)
		end
		if Data[mode].crafts[itemID] and mode ~= "Inscription" then -- We have an intermediary!
			FillGroups(groupedMats, itemID, 1)
			result = Data:WeightGroupedMats(groupedMats) or result
		end
		
		if result and Data[mode].mats[itemID] and not TSM.db.profile.matLock[itemID] then
			Data[mode].mats[itemID].cost = result
		elseif result and not Data[mode].mats[itemID] then
			local name = TSM:GetName(itemID)
			if name then
				Data[mode].mats[itemID] = {name=name, cost=result}
			end
		end
	end
end
	
-- Gets the market price of an item based on the profile
function Data:GetMarketPrice(itemID, itemType)
	if type(itemID) ~= "number" then itemID = tonumber(itemID) end
	if not itemID then return end
	
	local source = (itemType == "mat" and TSM.db.profile.matCostSource) or (itemType == "craft" and TSM.db.profile.craftCostSource)
	local itemLink = select(2, GetItemInfo(itemID)) or itemID
	local cost
	
	if TSM.db.profile.matLock[itemID] then
		if Data[TSM:GetMode()].mats[itemID] then
			return Data[TSM:GetMode()].mats[itemID].cost
		end
	end
	
	if source == "DBMarket" then
		cost = TSMAPI:GetData("market", itemID)
	elseif source == "DBMinBuyout" then
		cost = select(5, TSMAPI:GetData("market", itemID))
	elseif source == "AucAppraiser" and AucAdvanced and select(4, GetAddOnInfo("Auc-Advanced")) == 1 then
		cost = AucAdvanced.Modules.Util.Appraiser.GetPrice(itemLink)
	elseif source == "AucMinBuyout" and AucAdvanced and select(4, GetAddOnInfo("Auc-Advanced")) == 1 then
		cost = select(6, AucAdvanced.Modules.Util.SimpleAuction.Private.GetItems(itemLink))
	elseif source == "AucMarket" and AucAdvanced and select(4, GetAddOnInfo("Auc-Advanced")) == 1 then
		cost = AucAdvanced.API.GetMarketValue(itemLink)
	end
	
	if cost then
		return tonumber(string.format("%.2f", cost/COPPER_PER_GOLD))
	elseif Data[TSM:GetMode()].mats[itemID] then
		return Data[TSM:GetMode()].mats[itemID].cost
	end
end

-- returns a table containing a list of materials that excludes those only needed for hidden crafts
function Data:GetMats(mode)
	local matTemp = {} -- stores boolean values corresponding to whether or not each material is valid (being used)
	local returnTbl = {} -- properly formatted table to be returned
	mode = mode or TSM:GetMode()
	
	-- check each craft and make sure it is shown in the 'manage crafts' section of the options
	-- if it is, set all of its materials to valid because they are being used by the addon
	for _, chant in pairs(Data[mode].crafts) do
		for matID in pairs(chant.mats) do
			matTemp[matID] = true 
		end
	end
	
	local num = 1
	
	-- the matTemp table is indexed by itemID of the materials
	-- this must be changed to remain consistent with the Data.matList table so that the itemID is the value
	-- this loop does that
	for matID in pairs(matTemp) do
		tinsert(returnTbl, tonumber(matID))
	end
	
	-- sort the table so that the mats are displayed in a somewhat logical order (by itemID)
	sort(returnTbl)
	
	return returnTbl
end

-- resets all of the data when the "Reset Craft Queue" button is pressed
function Data:ResetData()
	-- reset the number queued of every craft back to 0
	for _, data in pairs(TSM.Data[TSM:GetMode()].crafts) do
		data.queued = 0
	end
	
	CloseTradeSkill() -- close the enchanting trade skill window
	TSM.Crafting:TRADE_SKILL_CLOSE() -- cleans up the Enchanting module
	wipe(TSM.GUI.queueList) -- clears the craft queue data table
	TSM:Print(L["Craft Queue Reset"]) -- prints out a nice message
end

-- returns the Data.crafts table as a 2D array with a slot index (chants[slot][chant] instead of chants[chant])
function Data:GetDataByGroups(mode)
	local craftsByGroup = {}
	for itemID, data in pairs(Data[mode or TSM.mode].crafts) do
		if data.group then
			craftsByGroup[data.group] = craftsByGroup[data.group] or {}
			craftsByGroup[data.group][itemID] = CopyTable(data)
		end
	end
	
	return craftsByGroup
end

function Data:GetSortedData(oTable, sortFunc)
	local temp = {}
	for index, data in pairs(oTable) do
		local tTemp = {}
		for i, v in pairs(data) do tTemp[i] = v end
		tTemp.originalIndex = index
		tinsert(temp, tTemp)
	end
	
	sort(temp, sortFunc)
	
	return temp
end

function Data:GetShoppingData(forModule)
	local matTotals = {}
	local results = {}
	local total = {}
	local mode = {}
	local queued = {}
	
	if forModule == "crafting" then
		tinsert(mode, TSM.Crafting.mode or TSM.mode)
	elseif forModule == "shopping" then
		for _, data in pairs(TSM.tradeSkills) do
			tinsert(mode, data.name)
		end
	elseif forModule then
		tinsert(mode, forModule)
	else
		tinsert(mode, TSM.mode)
	end

	for _, profession in pairs(mode) do
		-- Goes through every material and every craft and adds up the matTotals.
		for itemID, data in pairs(Data[profession].crafts) do
			if data.queued and data.queued > 0 then -- if the craft is queued...
				for matItemID, matQuantity in pairs(data.mats) do
					-- add the correct number of that material to the totals table
					matTotals[matItemID] = (matTotals[matItemID] or 0) + matQuantity*data.queued
				end
				queued[itemID] = data.queued
			end
		end
	end
		
	local extra = {}
	for itemID, quantity in pairs(matTotals) do
		if queued[itemID] then
			quantity = quantity - queued[itemID]
		end
		local bags, bank, auctions = Data:GetPlayerNum(itemID)
		local numHave = Data:GetAltNum(itemID) + bags + bank + auctions
		local numNeed = quantity
		if TSM.Enchanting.greaterEssence[itemID] then -- we are on lesser _ essence
			if numHave > numNeed then
				extra[TSM.Enchanting.greaterEssence[itemID]] = math.floor((numHave - numNeed) / 3)
			end
		elseif TSM.Enchanting.lesserEssence[itemID] then -- we are on greater _ essence
			if numHave > numNeed then
				extra[TSM.Enchanting.lesserEssence[itemID]] = (numHave - numNeed) * 3
			end
		end
		if quantity > 0 then
			tinsert(total, {itemID, quantity})
			local need = quantity - numHave - (extra[itemID] or 0)
			
			if need > 0 or forModule == "crafting" then
				tinsert(results, {itemID, need, TSM:GetVendorPrice(itemID) and true})
			end
		end
	end
	
	if forModule == "crafting" then
		return results, total
	elseif forModule == "shopping" then
		return results, total
	elseif forModule then
		return total, results
	else
		return results
	end
end

function Data:BuildCraftQueue(queueType)
	local mode = TSM:GetMode()
	Data:CalculateCosts()
	if queueType == "restock" then
		for itemID, data in pairs(TSM.Data[mode].crafts) do
			if data.enabled then
				local minRestock = TSM:GetDBValue("minRestockQuantity", mode, data.group, itemID)
				local maxRestock = TSM:GetDBValue("maxRestockQuantity", mode, data.group, itemID)
				local bags, bank, auctions = Data:GetPlayerNum(itemID)
				local numHave = Data:GetAltNum(itemID) + bags + bank + auctions
				local numCanQueue = maxRestock - numHave
				local link = select(2, GetItemInfo(itemID))
				local seenCount
				if AucAdvanced and TSM.db.profile.seenCountSource == "Auctioneer" then
					seenCount = select(2, AucAdvanced.API.GetMarketValue(link))
				elseif TSM.db.profile.seenCountSource == "AuctionDB" then
					seenCount = TSMAPI:GetData("seenCount", itemID)
				end
				
				if TSM.db.profile.dontQueue[itemID] or (seenCount and not TSM.db.profile.ignoreSeenCountFilter[itemID] and seenCount < TSM.db.profile.seenCountFilter) then
					numCanQueue = 0
				end
				
				local pMethod = TSM:GetDBValue("queueProfitMethod", mode, data.group, itemID)
				if pMethod == "none" or TSM.db.profile.alwaysQueue[itemID] then
					data.queued = numCanQueue
				elseif pMethod == "percent" then
					local cost, _, profit = TSM.Data:CalcPrices(data, true)
					local minProfit = TSM:GetDBValue("queueMinProfitPercent", mode, data.group, itemID)
					minProfit = cost*minProfit
					if profit and profit >= minProfit then
						data.queued = numCanQueue
					else
						data.queued = 0
					end
				elseif pMethod == "gold" then
					local _, _, profit = TSM.Data:CalcPrices(data, true)
					local minProfit = TSM:GetDBValue("queueMinProfitGold", mode, data.group, itemID)
					if profit and profit >= minProfit then
						data.queued = numCanQueue
					else
						data.queued = 0
					end
				elseif pMethod == "both" then
					local cost, _, profit = TSM.Data:CalcPrices(data, true)
					local minProfit = TSM:GetDBValue("queueMinProfitGold", mode, data.group, itemID)
					local percent = TSM:GetDBValue("queueMinProfitPercent", mode, data.group, itemID)
					minProfit = minProfit + cost*percent
					if profit and profit >= minProfit then
						data.queued = numCanQueue
					else
						data.queued = 0
					end
				end
				
				if minRestock > maxRestock then
					local link = select(2, GetItemInfo(itemID)) or data.name
					TSM:Print(format(L["%s not queued! Min restock of %s is higher than max restock of %s"], link, minRestock, maxRestock))
				end
				
				if data.queued < 0 then data.queued = 0 end
				if data.queued < minRestock then
					data.queued = 0
				end
			end
		end
	else
		local sortedData = Data:GetSortedData(TSM.Data[mode].crafts, function(a, b)
				local defaultValue = 1/0
				local acost, _, aprofit = TSM.Data:CalcPrices(a, true)
				local bcost, _, bprofit = TSM.Data:CalcPrices(b, true)
				aprofit = aprofit or defaultValue
				bprofit = bprofit or defaultValue
				return aprofit > bprofit
			end)
		
		local usedMats = {}
		for _, sData in pairs(sortedData) do
			local itemID = sData.originalIndex
			local data = TSM.Data[mode].crafts[itemID]
			local quantity = 0
			
			if data.enabled then
				local maxRestock = (TSM.db.profile.maxRestockQuantity[itemID] or TSM.db.profile.maxRestockQuantity.default)
				local bags, bank, auctions = Data:GetPlayerNum(itemID)
				local numHave = Data:GetAltNum(itemID) + bags + bank + auctions
				local numCanQueue = maxRestock - numHave
				local seenCount
				if AucAdvanced and TSM.db.profile.seenCountSource == "Auctioneer" then
					local link = select(2, GetItemInfo(itemID))
					seenCount = select(2, AucAdvanced.API.GetMarketValue(link))
				elseif TSM.db.profile.seenCountSource == "AuctionDB" then
					seenCount = TSMAPI:GetData("seenCount", itemID)
				end
				
				if TSM.db.profile.dontQueue[itemID] or (seenCount and not TSM.db.profile.ignoreSeenCountFilter[itemID] and seenCount < TSM.db.profile.seenCountFilter) then
					numCanQueue = 0
				end
				
				-- make sure somehow they didn't queue 0.76 of a craft or a negative number of crafts
				data.queued = floor(data.queued + 0.5) 
				if data.queued < 0 then data.queued = 0 end
			
				while(true) do
					local t = TSM.Crafting:GetOrderIndex({spellID=data.spellID, quantity=quantity+1}, usedMats)
					if t ~= 3 or quantity >= numCanQueue then
						break
					else
						quantity = quantity + 1
					end
				end
				
				for matID, mQuantity in pairs(data.mats) do
					usedMats[matID] = (usedMats[matID] or 0) + quantity*mQuantity
				end
				
				data.queued = quantity
			end
		end
	end
	TSM.GUI:UpdateQueue(true)
end

function Data:GetAltNum(itemID)
	local count = 0
	if TSM.db.profile.altAddon == "DataStore" and select(4, GetAddOnInfo("DataStore_Containers")) == 1 and DataStore then
		for account in pairs(DataStore:GetAccounts()) do
			for characterName, character in pairs(DataStore:GetCharacters(nil, account)) do
				if characterName ~= UnitName("Player") and TSM.db.profile.altCharacters[characterName] then
					local bagCount, bankCount = DataStore:GetContainerItemCount(character, itemID)
					count = count + bagCount
					count = count + bankCount
				end
			end
			for guildName, guild in pairs(DataStore:GetGuilds(nil, account)) do
				if TSM.db.profile.altGuilds[guildName] then
					local itemCount = DataStore:GetGuildBankItemCount(guild, itemID)
					count = count + itemCount
				end
			end
		end
	elseif TSM.db.profile.altAddon == "Gathering" and select(4, GetAddOnInfo("TradeSkillMaster_Gathering")) == 1 then
		for _, player in pairs(TSMAPI:GetData("playerlist") or {}) do
			if player ~= UnitName("player") and TSM.db.profile.altCharacters[player] then
				local bags = TSMAPI:GetData("playerbags", player)
				local bank = TSMAPI:GetData("playerbank", player)
				count = count + (bags[itemID] or 0)
				count = count + (bank[itemID] or 0)
			end
		end
		for _, guild in pairs(TSMAPI:GetData("guildlist") or {}) do
			if TSM.db.profile.altGuilds[guild] then
				local bank = TSMAPI:GetData("guildbank", guild)
				count = count + (bank[itemID] or 0)
			end
		end
	end
	
	if TSM.db.profile.altAddon == "DataStore" and select(4, GetAddOnInfo("DataStore_Auctions")) == 1 and DataStore then
		for account in pairs(DataStore:GetAccounts()) do
			for characterName, character in pairs(DataStore:GetCharacters(nil, account)) do
				if TSM.db.profile.altCharacters[characterName] and characterName ~= UnitName("player") then
					local lastVisit = (DataStore:GetAuctionHouseLastVisit(character) or 1/0) - time()
					if lastVisit < 48*60*60 then
						count = count + (DataStore:GetAuctionHouseItemCount(character, itemID) or 0)
					end
				end
			end
		end
	elseif select(4, GetAddOnInfo("TradeSkillMaster_AuctionDB")) == 1 then
		for _, name in pairs(TSMAPI:GetData("auctionplayers") or {}) do
			if name ~= UnitName("player") and TSM.db.profile.altCharacters[name] then
				count = count + TSMAPI:GetData("playerauctions", itemID, name)
			end
		end
	end
	
	return count
end

function Data:GetPlayerNum(itemID)
	local bags = GetItemCount(itemID)
	local bank = GetItemCount(itemID, true) - bags
	local auctions = 0
	
	if TSM.db.profile.restockAH then
		if select(4, GetAddOnInfo("DataStore_Auctions")) == 1 and DataStore then
			auctions = DataStore:GetAuctionHouseItemCount(DataStore:GetCharacter(), itemID) or 0
		else
			auctions = TSMAPI:GetData("playerauctions", itemID) or 0
		end
	end
	
	if TSM.db.profile.altAddon == "DataStore" and select(4, GetAddOnInfo("DataStore_Containers")) == 1 and DataStore then
		for account in pairs(DataStore:GetAccounts()) do
			for characterName, character in pairs(DataStore:GetCharacters(nil, account)) do
				if characterName == UnitName("player") then
					bags, bank = DataStore:GetContainerItemCount(character, itemID)
					break
				end
			end
		end
	elseif TSM.db.profile.altAddon == "Gathering" and select(4, GetAddOnInfo("TradeSkillMaster_Gathering")) == 1 then
		bags = (TSMAPI:GetData("playerbags", UnitName("player")) or {})[itemID] or bags
		bank = (TSMAPI:GetData("playerbank", UnitName("player")) or {})[itemID] or bank
	end
	
	return bags, bank, auctions
end

function Data:ShowScanningFrame()
	if not TradeSkillFrame then return end
	if not Data.scanningFrame then
		local frame = CreateFrame("Frame", nil, TradeSkillFrame)
		frame:SetAllPoints(TradeSkillFrame)
		frame:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8X8",
			tile = false,
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 24,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		})
		frame:SetBackdropColor(0, 0, 0.05, 1)
		frame:SetBackdropBorderColor(0,0,1,1)
		frame:SetFrameLevel(TradeSkillFrame:GetFrameLevel() + 10)
		frame:EnableMouse(true)
		
		local tFile, tSize = GameFontNormalLarge:GetFont()
		local titleText = frame:CreateFontString(nil, "Overlay", "GameFontNormalLarge")
		titleText:SetFont(tFile, tSize-2, "OUTLINE")
		titleText:SetTextColor(1, 1, 1, 1)
		titleText:SetPoint("CENTER", frame, "CENTER", 0, 0)
		titleText:SetText(L["TradeSkillMaster_Crafting - Scanning..."])
		Data.scanningFrame = frame
	end
	Data.scanningFrame:Show()
end

function Data:ScanProfession(mode)
	local openProfession = TSM.Crafting:GetCurrentTradeskill()
	if openProfession then
		Data.wasOpen = openProfession
	else
		Data.wasOpen = nil
	end
	CloseTradeSkill()
	for _, data in pairs(TSM.tradeSkills) do
		if data.name == TSM.mode then
			local spellName = GetSpellInfo(data.spellID)
			local delay = CreateFrame("Frame")
			delay:RegisterEvent("TRADE_SKILL_UPDATE")
			delay:RegisterEvent("TRADE_SKILL_SHOW")
			delay:SetScript("OnEvent", function(self, event)
					self:UnregisterEvent(event)
					if event == "TRADE_SKILL_UPDATE" then
						if self.ready then
							self:Hide()
							TSMAPI:CreateTimeDelay("professionscan", 0.2, Data.StartProfessionScan)
						else
							self.ready = true
						end
					elseif event == "TRADE_SKILL_SHOW" then
						Data:ShowScanningFrame()
						if TradeSkillFilterBarExitButton and TradeSkillFilterBarExitButton:IsVisible() then
							TradeSkillFilterBarExitButton:Click()
						end
						for i=GetNumTradeSkills(), 1, -1 do
							local _, lineType, _, isExpanded = GetTradeSkillInfo(i)
							if lineType == "header" and not isExpanded then
								ExpandTradeSkillSubClass(i)
							end
						end
						if self.ready then
							self:Hide()
							TSMAPI:CreateTimeDelay("professionscan", 0.2, Data.StartProfessionScan)
						else
							self.ready = true
						end
					end
				end)
			
			CastSpellByName(spellName) -- opens the profession
			break
		end
	end
end

function Data:StartProfessionScan()
	scanCoroutine = coroutine.create(Data.ScanCrafts)
	local driver = CreateFrame("Frame")
	driver.timeout = 10
	driver:SetScript("OnUpdate", function(self, elapsed)
			self.timeLeft = (self.timeLeft or 0.05) - elapsed
			self.timeout = self.timeout - elapsed
			if self.timeLeft <= 0 then
				self.timeLeft = nil
				local status = coroutine.status(scanCoroutine)
				if status == "suspended" then
					coroutine.resume(scanCoroutine)
				elseif status == "dead" then
					Data.scanningFrame:Hide()
					self:Hide()
					if Data.wasOpen ~= TSM.mode then
						CloseTradeSkill()
					end
				end
			elseif self.timeout <= 0 then
				Data.scanningFrame:Hide()
				scanCoroutine = nil
				self:Hide()
				if Data.wasOpen ~= TSM.mode then
					CloseTradeSkill()
				end
			end
		end)
end

function Data:ScanCrafts()
	local matsTemp = {}
	local enchantsTemp = {}
	
	for index=2, GetNumTradeSkills() do
		local dataTemp = {mats={}, itemID=nil, spellID=nil, queued=0, group=nil, name=nil}
		if TSM.mode == "Enchanting" then
			dataTemp.spellID = TSMAPI:GetItemID(GetTradeSkillItemLink(index))
			dataTemp.itemID = TSM.Enchanting.itemID[tonumber(dataTemp.spellID)]
			if dataTemp.spellID and dataTemp.itemID and TSM[TSM.mode]:GetSlot(dataTemp.itemID) then
				while true do
					dataTemp.name = GetSpellInfo(dataTemp.spellID)
					if dataTemp.name then
						break
					else
						coroutine.yield()
					end
				end
			end
		else
			dataTemp.spellID = TSMAPI:GetItemID(GetTradeSkillRecipeLink(index))
			local link = GetTradeSkillItemLink(index)
			if link then 
				dataTemp.itemID = TSMAPI:GetItemID(link)
				if dataTemp.itemID and TSM[TSM.mode]:GetSlot(dataTemp.itemID) then
					while true do
						dataTemp.name = GetItemInfo(dataTemp.itemID)
						if dataTemp.name then
							break
						else
							coroutine.yield()
						end
					end
				end
			end
		end
		if dataTemp.name then
			-- figure out how many of this item is made per craft (almost always 1)
			local lNum, hNum = GetTradeSkillNumMade(index)
			dataTemp.numMade = floor(((lNum or 1) + (hNum or 1))/2)
			
			dataTemp.group = TSM[TSM.mode]:GetSlot(dataTemp.itemID)
			if TSM.mode == "Enchanting" then
				dataTemp.mats[TSM.Enchanting.vellumID] = 1
				matsTemp[TSM.Enchanting.vellumID] = {name = TSM:GetName(TSM.Enchanting.vellumID), cost = 5}
			end
			
			local valid = false
			
			while true do
				valid = true
				-- loop over every material for the selected craft and gather itemIDs and quantities for the mats
				for i=1, GetTradeSkillNumReagents(index) do
					local link = GetTradeSkillReagentItemLink(index, i)
					local matID = TSMAPI:GetItemID(link)
					if not matID then
						valid = false
						break
					end
					local name, _, quantity = GetTradeSkillReagentInfo(index, i)
					if not name then
						valid = false
						break
					end
					dataTemp.mats[matID] = quantity
					matsTemp[matID] = {name = name, cost = 5}
				end
				
				if not valid then
					coroutine.yield()
				else
					break
				end
			end
			if TSM.Inscription.slot1[dataTemp.itemID] == 10 then valid = false end
			if valid then
				local itemID = dataTemp.itemID
				dataTemp.itemID = nil
				
				if not TSM.Data[TSM.mode].crafts[itemID] then
					TSM.Data[TSM.mode].crafts[itemID] = CopyTable(dataTemp)
					TSM.Data[TSM.mode].crafts[itemID].enabled = not TSM.db.profile.lastScan[TSM.mode]
				else
					-- mats change every so often so make sure they are up to date
					TSM.Data[TSM.mode].crafts[itemID].mats = CopyTable(dataTemp.mats)
					-- make sure the number each cast makes is correct
					TSM.Data[TSM.mode].crafts[itemID].numMade = dataTemp.numMade
				end
			end
		end
		if index%20 == 0 then coroutine.yield() end
	end
	local matList = TSM.Data:GetMats()
	for ID, matData in pairs(matsTemp) do
		TSM.Data[TSM.mode].mats[ID] = TSM.Data[TSM.mode].mats[ID] or matData
	end
	TSM.db.profile.lastScan[TSM.mode] = time()
end

local newCraftMsg = gsub(ERR_LEARN_RECIPE_S, "%%s", "")
function Data:CHAT_MSG_SYSTEM(_, msg)
	if msg:match(newCraftMsg) then
		for name, data in pairs(TSM.db.profile.lastScan) do
			TSM.db.profile.lastScan[name] = -1/0
		end
	end
end

function Data:GetCraftingCost(itemID)
	for _, skill in pairs(TSM.tradeSkills) do
		local mode = skill.name
		if Data[mode].crafts[itemID] then
			local cost = 0
			for id, matQuantity in pairs(Data[mode].crafts[itemID].mats) do
				Data[mode].mats[id] = Data[mode].mats[id] or {}
				Data[mode].mats[tonumber(id)].cost = Data[mode].mats[tonumber(id)].cost or 1
				cost = cost + matQuantity*Data[mode].mats[tonumber(id)].cost
			end
			return cost*COPPER_PER_GOLD
		end
		if Data[mode].mats[itemID] then
			Data:CalculateCosts(mode)
			return Data[mode].mats[itemID].cost*COPPER_PER_GOLD
		end
	end
end