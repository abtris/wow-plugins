-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Gathering - AddOn by Sapu94				 	 --
--   http://wow.curse.com/downloads/wow-addons/details/TradeSkillMaster_Gathering.aspx  --
-- ------------------------------------------------------------------------------------- --

-- ===================================================================================== --


-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster_Gathering", "AceEvent-3.0", "AceConsole-3.0")

TSM.version = GetAddOnMetadata("TradeSkillMaster_Gathering","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster_Gathering", "Version") -- current version of the addon
local CURRENT_PLAYER, CURRENT_GUILD = UnitName("player"), GetGuildInfo("player")

local function debug(...)
	if TSMGDEBUG then
		print(...)
	end
end

function TSM:Debug(...)
	debug(...)
end

-- default values for the savedDB
-- list of different types of saved variables at the top of http://www.wowace.com/addons/ace3/pages/api/ace-db-3-0/
local savedDBDefaults = {
	-- any global 
	global = {
	},
	
	-- data that is stored per realm/faction combination
	factionrealm = {
		characters = {},
		guilds = {},
		tasks = {},
		currentProfession = nil,
		currentCrafter = nil
	},
	
	-- data that is stored per user profile
	profile = {
	},
}

local characterDefaults = { -- anything added to the characters table will have these defaults
	bags = {},
	bank = {},
	guild = nil,
}
local guildDefaults = {
	items = {},
	characters = {},
}

-- Called once the player has loaded into the game
-- Anything that needs to be done in order to initialize the addon should go here
function TSM:OnInitialize()
	TSM.Data = TSM.modules.Data
	TSM.Config = TSM.modules.Config
	TSM.GUI = TSM.modules.GUI
	TSM.Gather = TSM.modules.Gather
	TSM.Mail = TSM.modules.Mail
	
	-- load the saved variables table into TSM.db
	if not TradeSkillMaster_GatheringDB and TradeSkillMaster_DestroyingDB then
		TradeSkillMaster_GatheringDB = CopyTable(TradeSkillMaster_DestroyingDB)
	end
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_GatheringDB", savedDBDefaults, true)
	TSM.characters = TSM.db.factionrealm.characters
	TSM.guilds = TSM.db.factionrealm.guilds
	
	-- register the module with TSM
	TSMAPI:RegisterModule("TradeSkillMaster_Gathering", TSM.version, GetAddOnMetadata("TradeSkillMaster_Gathering", "Author"),
		GetAddOnMetadata("TradeSkillMaster_Gathering", "Notes"), 1)
		
	TSMAPI:RegisterIcon("Gathering", "Interface\\Icons\\INV_Misc_Bag_SatchelofCenarius",
		function(...) TSM.Config:Load(...) end, "TradeSkillMaster_Gathering")
		
	if not TSM.characters[CURRENT_PLAYER] then
		TSM.characters[CURRENT_PLAYER] = characterDefaults
	end
	if CURRENT_GUILD and not TSM.guilds[CURRENT_GUILD] then
		TSM.guilds[CURRENT_GUILD] = guildDefaults
	end
	
	TSM.tasks = TSM.db.factionrealm.tasks
	TSM.GUI:Create()
	TSM.Data:LoadData()
	
	if TSM.tasks[1] then
		if TSM.tasks[1].location == "LOGON" and TSM.tasks[1].player == UnitName("player") then
			TSM:NextTask()
		elseif TSM.tasks[1].player and TSM.tasks[1].player ~= UnitName("player") then
			tinsert(TSM.tasks, 1, {location="LOGON", player=TSM.tasks[1].player})
		end
		TSM.GUI:UpdateFrame()
	end
end

function TSM:NextTask()
	tremove(TSM.tasks, 1)
	if #(TSM.tasks) == 0 then TSM:Print("Done Gathering") end
	TSM.GUI:UpdateFrame()
end

function TSM:StopGathering()
	wipe(TSM.tasks)
	TSM.GUI:UpdateFrame()
end

-- scan the tooltip to make sure the item isn't soulbound
local scanTooltip
local resultsCache = {}
function TSM:IsSoulbound(bag, slot, itemID)
	if resultsCache[bag .. slot .. itemID] ~= nil then return resultsCache[bag .. slot .. itemID] end
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", "TSMAucScanTooltip", UIParent, "GameTooltipTemplate")
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")	
	end
	
	scanTooltip:ClearLines()
	scanTooltip:SetBagItem(bag, slot)
	
	for id=1, scanTooltip:NumLines() do
		local text = _G["TSMAucScanTooltipTextLeft" .. id]
		if text and text:GetText() and text:GetText() == ITEM_SOULBOUND then
			resultsCache[bag .. slot .. itemID] = true
			return true
		end
	end
	
	resultsCache[bag .. slot .. itemID] = nil
	return false
end

function TSM:BuildTaskList(profession, crafter)
	if not (profession and crafter) then return end
	TSM.db.factionrealm.currentProfession = profession
	TSM.db.factionrealm.currentCrafter = crafter
	wipe(TSM.tasks)
	
	-- items[i] = {itemID, quantity}
	local items = CopyTable(TSMAPI:GetData("shopping", profession)) or {}
	local players = TSM:GetPlayersWithMats(items)
	local toGather, usedGuild, totalItems = {}, {}, {}
	playerTasks = {num=0}
	
	for _, data in pairs(items) do
		local itemID, quantity = data[1], data[2]
		toGather[itemID] = quantity
	end
	
	for _, data in ipairs(players) do
		playerTasks[data.name] = {}
		totalItems[data.name] = {}
	
		-- add up items in the player's bags
		local bagTask = {player=data.name, location="BAGS"}
		for itemID, quantity in pairs(TSM.characters[data.name].bags) do
			if toGather[itemID] and toGather[itemID] > 0 then
				if quantity > toGather[itemID] then
					quantity = toGather[itemID]
				end
				
				toGather[itemID] = toGather[itemID] - quantity
				bagTask.items = bagTask.items or {}
				bagTask.items[itemID] = quantity
				totalItems[data.name][itemID] = (totalItems[data.name][itemID] or 0) + quantity
			end
		end
		
		-- add up items in the player's bank and create a task
		local bankTask = {player=data.name, location="BANK"}
		for itemID, quantity in pairs(TSM.characters[data.name].bank) do
			if toGather[itemID] and toGather[itemID] > 0 then
				if quantity > toGather[itemID] then
					quantity = toGather[itemID]
				end
				
				toGather[itemID] = toGather[itemID] - quantity
				bankTask.items = bankTask.items or {}
				bankTask.items[itemID] = quantity
				totalItems[data.name][itemID] = (totalItems[data.name][itemID] or 0) + quantity
			end
		end
		
		-- add up items in the player's guild bank and create a task
		local gbankTask = {player=data.name, location="GUILDBANK"}
		local guildName = TSM:GetGuild(data.name)
		if guildName and not usedGuild[guildName] then
			for itemID, quantity in pairs(TSM.guilds[guildName].items) do
				if toGather[itemID] and toGather[itemID] > 0 then
					if quantity > toGather[itemID] then
						quantity = toGather[itemID]
					end
					
					toGather[itemID] = toGather[itemID] - quantity
					gbankTask.items = gbankTask.items or {}
					gbankTask.items[itemID] = quantity
					totalItems[data.name][itemID] = (totalItems[data.name][itemID] or 0) + quantity
					usedGuild[guildName] = true
				end
			end
		end
		
		if bankTask.items then
			tinsert(playerTasks[data.name], bankTask)
			playerTasks.num = playerTasks.num + 1
		end
		if gbankTask.items then
			tinsert(playerTasks[data.name], gbankTask)
			playerTasks.num = playerTasks.num + 1
		end
		if not (gbankTask.items or bankTask.items) and bagTask.items then
			tinsert(playerTasks[data.name], bagTask)
			playerTasks.num = playerTasks.num + 1
		end
	end
	
	local onPlayer = UnitName("player")
	if playerTasks.num > 0 then
		for i, data in ipairs(players) do
			local playerName = data.name
			if playerTasks[playerName] then
				if playerName ~= onPlayer then
					tinsert(TSM.tasks, {player=playerName, location="LOGON"})
					onPlayer = playerName
				end
				for _, task in ipairs(playerTasks[playerName]) do
					if task.location ~= "BAGS" then
						tinsert(TSM.tasks, task)
					end
				end
				if playerName ~= TSM.db.factionrealm.currentCrafter then
					tinsert(TSM.tasks, {location="MAIL", items=totalItems[playerName]})
				end
			end
		end
	end
	
	if onPlayer ~= TSM.db.factionrealm.currentCrafter then
		tinsert(TSM.tasks, {location="LOGON", player=TSM.db.factionrealm.currentCrafter})
	end
	
	if #(TSM.tasks) == 0 then
		TSM:Print("No Gathering Required")
	end
	
	TSM.GUI:UpdateFrame()
end

function TSM:GetPlayersWithMats(items)
	local results = {}
	
	for i, playerName in ipairs(TSM.Data:GetPlayers()) do
		results[i] = {name=playerName, isPlayer=(playerName==UnitName("player")), items={}, numItems = 0}
		for _, item in pairs(items) do
			local itemID = item[1]
			local quantity = TSM:GetNumOnPlayer(playerName, itemID)
			if quantity > 0 then
				results[i].items[itemID] = quantity
				results[i].numItems = results[i].numItems + 1
			end
		end
	end
	
	for i=#(results), 1, -1 do
		if results[i].numItems == 0 then
			tremove(results, i)
		end
	end
	
	sort(results, function(a, b)
			if a.isPlayer then
				return true
			end
			if b.isPlayer then
				return false
			end
			return a.numItems > b.numItems
		end)
	return results
end

function TSM:GetNumOnPlayer(name, itemID)
	local num = 0
	
	if TSM.characters[name] then
		num = num + (TSM.characters[name].bags[itemID] or 0)
		num = num + (TSM.characters[name].bank[itemID] or 0)
	end
	
	local guildName = TSM:GetGuild(name)
	if TSM.guilds[guildName] then
		num = num + (TSM.guilds[guildName].items[itemID] or 0)
		debug("found", itemID, TSM.guilds[guildName].items[itemID])
	else
		debug("no guild data")
	end
	return num
end

function TSM:GetGuild(playerName)
	if not TSM.characters[playerName].guild then
		for guildName, guild in pairs(TSM.guilds) do
			if guild.characters and guild.characters[playerName] then
				TSM.characters[playerName].guild = guildName
				break
			end
		end
	end
	TSM.characters[playerName].guild = TSM.characters[playerName].guild or GetGuildInfo("player")
	debug("player, guild =", playerName, TSM.characters[playerName].guild)
	return TSM.characters[playerName].guild
end