-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster_AuctionDB", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

TSM.version = GetAddOnMetadata("TradeSkillMaster_AuctionDB","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster_AuctionDB", "Version") -- current version of the addon
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

local savedDBDefaults = {
	factionrealm = {
		playerAuctions = {},
		scanData = "",
		time = 0,
	},
	profile = {
		scanSelections = {},
		getAll = false,
		tooltip = true,
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_AuctionDBDB", savedDBDefaults, true)
	TSM.Scan = TSM.modules.Scan
	TSM.GUI = TSM.modules.GUI
	
	TSM:Deserialize(TSM.db.factionrealm.scanData)
	TSM.playerAuctions = TSM.db.factionrealm.playerAuctions
	
	TSM:RegisterEvent("PLAYER_LOGOUT", TSM.OnDisable)
	TSM:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", "ScanPlayerAuctions")

	TSMAPI:RegisterModule("TradeSkillMaster_AuctionDB", TSM.version, GetAddOnMetadata("TradeSkillMaster_AuctionDB", "Author"), GetAddOnMetadata("TradeSkillMaster_AuctionDB", "Notes"))
	TSMAPI:RegisterIcon(L["AuctionDB"], "Interface\\Icons\\Inv_Misc_Platnumdisks", function(...) TSM.GUI:LoadGUI(...) end, "TradeSkillMaster_AuctionDB")
	TSMAPI:RegisterSlashCommand("adbreset", TSM.Reset, L["resets the data"], true)
	TSMAPI:RegisterData("market", TSM.GetData)
	TSMAPI:RegisterData("playerauctions", TSM.GetPlayerAuctions)
	TSMAPI:RegisterData("auctionplayers", TSM.GetPlayers)
	TSMAPI:RegisterData("seenCount", TSM.GetSeenCount)
	
	if TSM.db.profile.tooltip then
		TSMAPI:RegisterTooltip("TradeSkillMaster_AuctionDB", function(...) return TSM:LoadTooltip(...) end)
	end
	
	local toRemove = {}
	for index, data in pairs(TSM.playerAuctions) do
		if type(index) ~= "string" or index == "time" then
			tinsert(toRemove, index)
		elseif type(data) == "table" then
			local toRemove2 = {}
			for i, v in pairs(data) do
				if v == 0 then tinsert(toRemove2, i) end
			end
			for _, i in ipairs(toRemove2) do
				data[i] = nil
			end
		end
	end
	
	for _, index in ipairs(toRemove) do
		TSM.playerAuctions[index] = nil
	end
	
	TSM.db.factionrealm.time = 10 -- because AceDB won't save if we don't do this...
	TSM.db.factionrealm.testData = nil
end

function TSM:OnDisable()
	local sTime = GetTime()
	TSM:Serialize(TSM.data)
	TSM.db.factionrealm.time = GetTime() - sTime
end

local function FormatMoneyText(c)
	local GOLD_TEXT = "\124cFFFFD700g\124r"
	local SILVER_TEXT = "\124cFFC7C7CFs\124r"
	local COPPER_TEXT = "\124cFFEDA55Fc\124r"
	local g = floor(c/10000)
	local s = floor(mod(c/100,100))
	c = floor(mod(c, 100))
	local moneyString = ""
	if g > 0 then
		moneyString = format("%s%s", "|cffffffff"..g.."|r", GOLD_TEXT)
	end
	if s > 0 and (g < 100) then
		moneyString = format("%s%s%s", moneyString, "|cffffffff"..s.."|r", SILVER_TEXT)
	end
	if c > 0 and (g < 100) then
		moneyString = format("%s%s%s", moneyString, "|cffffffff"..c.."|r", COPPER_TEXT)
	end
	if moneyString == "" then moneyString = "0"..COPPER_TEXT end
	return moneyString
end

function TSM:LoadTooltip(itemID)
	local marketValue, currentQuantity, lastScan, totalSeen, minBuyout = TSMAPI:GetData("market", itemID)
	
	if marketValue and minBuyout and totalSeen then
		return {L["AuctionDB Market Value:"].." |cffffffff"..FormatMoneyText(marketValue),
			L["AuctionDB Min Buyout:"].." |cffffffff"..FormatMoneyText(minBuyout),
			L["AuctionDB Seen Count:"].." |cffffffff"..totalSeen}
	end
end

function TSM:Reset()
	for i in pairs(TSM.data) do
		TSM.data[i] = nil
	end
	print("Reset Data")
end

function TSM:GetData(itemID)
	if not itemID then return end
	itemID = TSMAPI:GetNewGem(itemID) or itemID
	if not TSM.data[itemID] then return end
	
	return TSM.data[itemID].marketValue, TSM.data[itemID].currentQuantity, TSM.data[itemID].lastScan, TSM.data[itemID].seen, TSM.data[itemID].minBuyout
end

-- function TSMADBTest()
	-- local test = {100,200,200,300,300,300,300,400,400,400,400,400,400,400,500,500,500,500,600,600,700, 12000}
	-- local records = {}
	
	-- for i=0, 1 do
		-- TSM.data[1] = nil
		-- wipe(records)
		-- for _, num in ipairs(test) do
			-- tinsert(records, {buyout=num, quantity=1})
		-- end
		-- TSM:ProcessData({[1]={minBuyout=1, quantity=21, records=records}}, true)
		-- local dTemp = TSM.data[1].marketValue
	
		-- TSM.data[1].lastScan = TSM.data[1].lastScan - 60*60*12*i
		
		-- for num, data in ipairs(records) do
			-- data.buyout = data.buyout + 400
		-- end
		
		-- TSM:ProcessData({[1]={minBuyout=1, quantity=21, records=records}}, true)
		-- print(i, TSM.data[1].marketValue, dTemp)
	-- end
-- end

function TSM:ProcessData(scanData, isTest)
	if not isTest then
		-- wipe all the minBuyout data
		for itemID, data in pairs(TSM.data) do
			data.minBuyout = nil
		end
	end
	
	-- go through each item and figure out the market value / update the data table
	for itemID, data in pairs(scanData) do
		local records = {}
		for _, record in pairs(data.records) do
			for i=1, record.quantity do
				tinsert(records, record.buyout)
			end
		end
	
		local marketValue, num = TSM:CalculateMarketValue(records, itemID)
		
		if TSM.data[itemID] and TSM.data[itemID].lastScan and TSM.data[itemID].marketValue then
			local dTime = time() - TSM.data[itemID].lastScan
			local weight = TSM:GetWeight(dTime, TSM.data[itemID].seen+num)*0.5
			marketValue = (1-weight)*marketValue + weight*TSM.data[itemID].marketValue
		end
		
		TSM.data[itemID] = {marketValue=floor(marketValue+0.5),
			seen=((TSM.data[itemID] and TSM.data[itemID].seen or 0) + num),
			currentQuantity=data.quantity,
			lastScan=time(),
			minBuyout=data.minBuyout}
	end
end

function TSM:CalculateMarketValue(records, itemID)
	local totalNum, totalBuyout = 0, 0
	
	for i=1, #records do
		totalNum = i - 1
		if not (i == 1 or i < (#records)*0.5 or records[i] < 1.5*records[i-1]) then
			break
		end
		
		totalBuyout = totalBuyout + records[i]
		if i == #records then
			totalNum = i
		end
	end
	
	local uncorrectedMean = totalBuyout / totalNum
	local varience = 0
	
	for i=1, totalNum do
		varience = varience + (records[i]-uncorrectedMean)^2
	end
	
	if uncorrectedMean == 1/0 or uncorrectedMean == 0 then print("ERROR", totalBuyout, totalNum) end
	
	local stdDev = sqrt(varience/totalNum)
	local correctedTotalNum, correctedTotalBuyout = 1, uncorrectedMean
	
	for i=1, totalNum do
		if abs(uncorrectedMean - records[i]) < 1.5*stdDev then
			correctedTotalNum = correctedTotalNum + 1
			correctedTotalBuyout = correctedTotalBuyout + records[i]
		end
	end
	
	local correctedMean = correctedTotalBuyout / correctedTotalNum
	
	return correctedMean, totalNum
end

function TSM:GetWeight(dTime, i)
	-- k here is valued for w value of 0.5 after 2 days
	-- k = -172800 / log_0.5(i/2)
	-- a "good" idea would be to precalculate k for values of i either at addon load or with a script
	--   to cut down on processing time.  Also note that as i -> 2, k -> negative infinity
	--   so we'd like to avoid i <= 2
	if dTime < 3600 then return (i-1)/i end
	local s = 2*24*60*60 -- 2 days
	local k = -s/(log(i/2)/log(0.5))
	return (i-i^(dTime/(dTime + k)))/i
end

function TSM:Serialize()
	local results = {}
	for id, v in pairs(TSM.data) do
		if v.marketValue then
			tinsert(results, "q" .. id .. "," .. v.seen .. "," .. v.marketValue .. "," .. v.lastScan .. "," .. (v.currentQuantity or 0) .. "," .. (v.minBuyout or "n"))
		end
	end
	TSM.db.factionrealm.scanData = table.concat(results)
end

local function OldDeserialize(data)
	TSM.data = TSM.data or {}
	for k,a,b,c,d,g,h,i,j in string.gmatch(data, "d([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^d]+)") do
		TSM.data[tonumber(k)] = {seen=tonumber(a),marketValue=tonumber(c),lastScan=tonumber(g),currentQuantity=tonumber(i),minBuyout=tonumber(j)}
	end
end

function TSM:Deserialize(data)
	if strsub(data, 1, 1) == "d" then
		return OldDeserialize(data)
	end
	
	TSM.data = TSM.data or {}
	for k,a,b,c,d,f in string.gmatch(data, "q([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^q]+)") do
		TSM.data[tonumber(k)] = {seen=tonumber(a),marketValue=tonumber(b),lastScan=tonumber(c),currentQuantity=tonumber(d),minBuyout=tonumber(f)}
	end
end

function TSM:ScanPlayerAuctions()
	local currentPlayer = UnitName("player")
	TSM.playerAuctions[currentPlayer] = TSM.playerAuctions[currentPlayer] or {}
	wipe(TSM.playerAuctions[currentPlayer])
	TSM.playerAuctions[currentPlayer].time = time()
	
	for i=1, GetNumAuctionItems("owner") do
		local itemID = TSMAPI:GetItemID(GetAuctionItemLink("owner", i))
		local _, _, quantity, _, _, _, _, _, _, _, _, _, wasSold = GetAuctionItemInfo("owner", i)
		if wasSold == 0 and itemID then
			TSM.playerAuctions[currentPlayer][itemID] = (TSM.playerAuctions[currentPlayer][itemID] or 0) + quantity
		end
	end
end

function TSM:GetPlayers()
	local temp = {}
	for name in pairs(TSM.playerAuctions) do
		tinsert(temp, name)
	end
	return temp
end

function TSM:GetPlayerAuctions(itemID, player)
	if not itemID then return "Invalid argument" end
	player = player or UnitName("player")
	if not TSM.playerAuctions[player] or (time() - (TSM.playerAuctions[player].time or 0)) > (48*60*60) then return 0 end -- data is old
	return TSM.playerAuctions[player][itemID] or 0
end

function TSM:GetSeenCount(itemID)
	if not TSM.data[itemID] then return end
	return TSM.data[itemID].seen
end



-- -- fun with converting number bases to try and save space
-- -- (uses about 40% less space but not worth it at this point)
-- local alpha = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmoprstuvwxyz!@#&()-_+=`~':;<>.?{}[]|\127\128\129\130\131\132\133\134\135\136\137\138\139\140\141\142\143\144\145\146\147\148\149\150\151\152\153\154\155\156\157\158\159\160\161\162\163\164\165\166\167\168\169\170\171\172\173\174\175\176\177\178\179\180\181\182\183\184\185\186\187\188\189\190\191\192\193\194\195\196\197\198\199\200\201\202\203\204\205\206\207\208\209\210\211\212\213\214\215\216\217\218\219\220\221\222\223\224\225"
-- local base = strlen(alpha)
-- function toDecimal(h)
	-- local result = 0
	
	-- local i = strlen(h) - 1
	-- for w in string.gmatch(h, "([\033-\126])") do
		-- result = result + (strfind(alpha, w)-1)*(base^i)
		-- i = i - 1
	-- end
	
	-- return result
-- end

-- function toHex(d)
	-- local r = d % base
	-- local result
	-- if d-r == 0 then
		-- result = toChar(r+1)
	-- else 
		-- result = toHex((d-r)/base) .. toChar(r+1)
	-- end
	-- return result
-- end
 
-- function toChar(n)
	-- return strsub(alpha, n, n)
-- end

-- function adbtest()
	-- TSM.db.factionrealm.testData = ""
	
	-- local results = {}
	-- for id, v in pairs(TSM.data) do
		-- tinsert(results, "q" .. toHex(id) .. "," .. toHex(v.seen) .. "," .. toHex(v.marketValue) .. "," .. toHex(v.lastScan) .. "," .. (toHex(v.currentQuantity or 0)) .. "," .. (v.minBuyout and toHex(v.minBuyout) or "n"))
	-- end
	-- TSM.db.factionrealm.testData = table.concat(results)
-- end