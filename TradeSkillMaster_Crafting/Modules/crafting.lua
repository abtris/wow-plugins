-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --


-- create a local reference to the TradeSkillMaster_Crafting table and register a new module
local TSM = select(2, ...)
local Crafting = TSM:NewModule("Crafting", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local debug = function(...) TSM:Debug(...) end -- for debugging

-- intialize some internal-global variables
local ROW_HEIGHT_CRAFTING = 16
local ROW_HEIGHT_SHOPPING = 12
local ROW_HEIGHT_QUEUING = 12
local MAX_ROWS_CRAFTING = 16
local MAX_ROWS_SHOPPING = 12
local MAX_ROWS_QUEUING = 20
local FRAME_HEIGHT = 500
local FRAME_WIDTH = 870

-- color codes
local CYAN = "|cff99ffff"
local BLUE = "|cff5555ff"
local GREEN = "|cff00ff00"
local RED = "|cffff0000"
local WHITE = "|cffffffff"
local GOLD = "|cffffbb00"
local YELLOW = "|cffffd000"

local groupShown = {}

Crafting.isCrafting = 0

local eventThrottle = CreateFrame("Frame")
eventThrottle.baseTime = 0.3
eventThrottle:Hide()
eventThrottle:SetScript("OnShow", function(self) Crafting:UnregisterEvent(self.event) self.timeLeft = self.baseTime end)
eventThrottle:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			Crafting[self.event]()
			self:Hide()
			Crafting:RegisterEvent(self.event)
		end
	end)

function Crafting:OnInitialize()
	Crafting:AddHookForAdvancedTradeSkillWindowAddOn()
	
	Crafting:RegisterEvent("TRADE_SKILL_SHOW")
	Crafting:RegisterEvent("TRADE_SKILL_CLOSE")
end

-- opens the craft queue and initializes it if it hasn't previously been shown
function Crafting:OpenFrame(mode)
	Crafting:OpenCrafting(Crafting.PrepareFrame, mode)
end
	
function Crafting:PrepareFrame(hide)
	TSM.Data:CalculateCosts()
	Crafting:UpdateFrame(hide and Crafting.frame and hide == "hide")
	local toHide = (hide and Crafting.frame and hide == "hide")
	if toHide then Crafting.frame:Hide() end
	Crafting.openCloseButton:Show()
	
	-- register events and collect some data
	Crafting:RegisterEvent("TRADE_SKILL_FILTER_UPDATE")
	Crafting:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	Crafting:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	Crafting:RegisterEvent("BAG_UPDATE")
	Crafting.frame.text:SetText("Crafting ("..TSM.version..") - "..(Crafting.mode or ""))
	Crafting.frame.titleBackground:SetWidth(Crafting.frame.text:GetWidth()+10)
	
	-- update the frame for the first time and then show it
	if not toHide then
		Crafting:UpdateShopping()
		Crafting:UpdateQueuing()
		TSMAPI:CreateTimeDelay("updateCrafting121", 0.2, Crafting.UpdateCrafting)
	end
end

function Crafting:UpdateAllScrollFrames()
	Crafting:UpdateCrafting()
	Crafting:UpdateShopping()
	Crafting:UpdateQueuing()
end

-- initializes the craft queue frame when it is shown for the first time
function Crafting:UpdateFrame(hidden)
	if not Crafting.frame then
		Crafting:LayoutFrame()
		hidden = true
	end
	
	Crafting:PositionFrameAndButton(hidden)
	Crafting.frame:Show()
end

function Crafting:LayoutFrame()
	Crafting.openCloseButton = Crafting:CreateOpenCloseButton()

	Crafting.frame = Crafting:CreateCraftingFrame()
	Crafting.frame.titleBackground = Crafting:CreateTitleBackground()
	Crafting.frame.text = Crafting:CreateTitleText()
	
	Crafting.frame.craftingScroll = Crafting:CreateCraftingScrollFrame()
	Crafting.frame.noCrafting = Crafting:CreateCraftingDisabledMessage()

	Crafting:LayoutButtons()
	Crafting:LayoutBars()
	
	Crafting.craftRows = Crafting:CreateCraftRows()

	Crafting:LayoutShoppingFrame()
	Crafting:LayoutQueuingFrame()
end

function Crafting:LayoutButtons()
	Crafting.button = Crafting:CreateWhiteButton(L["Craft Next"], "TSMCraftNextButton", "SecureActionButtonTemplate", 40, -16, Crafting.frame.craftingScroll, "BOTTOMLEFT", -6, "BOTTOMRIGHT", 25, -2, Crafting.frame)
	
	Crafting.restockQueueButton = Crafting:CreateWhiteButton(L["Restock Queue"], nil, "UIPanelButtonTemplate", 40, 0, Crafting.frame, "TOPLEFT", FRAME_WIDTH-330, "TOPRIGHT", -6, -36)
	Crafting.restockQueueButton:SetScript("OnClick", function() TSM.Data:BuildCraftQueue("restock") Crafting:UpdateAllScrollFrames() end)

	Crafting.onHandQueueButton = Crafting:CreateWhiteButton(L["On-Hand Queue"], nil, "UIPanelButtonTemplate", 30, -20, Crafting.frame, "TOPLEFT", FRAME_WIDTH-240, "TOPRIGHT", -96, -86)
	Crafting.onHandQueueButton:SetScript("OnClick", function() TSM.Data:BuildCraftQueue("onhand") Crafting:UpdateAllScrollFrames() end)

	Crafting.clearQueueButton = Crafting:CreateWhiteButton(L["Clear Queue"], nil, "UIPanelButtonTemplate", 30, -20, Crafting.frame, "TOPLEFT", FRAME_WIDTH-240, "TOPRIGHT", -96, -116)
	Crafting.clearQueueButton:SetScript("OnClick", function() TSM.GUI:ClearQueue() Crafting:UpdateAllScrollFrames() end)
end

function Crafting:LayoutBars()
	Crafting.frame.verticalBarFrame = Crafting:CreateVerticalBarFrame()
	Crafting.frame.verticalBarTexture = Crafting:CreateVerticalBarTexture()

	Crafting.frame.horizontalBarFrame = Crafting:CreateHorizontalBarFrame()
	Crafting.frame.horizontalBarTexture = Crafting:CreateHorizontalBarTexture()

	Crafting.frame.horizontalBarFrame2 = Crafting:CreateHorizontalBarFrame2()
	Crafting.frame.horizontalBarTexture2 = Crafting:CreateHorizontalBarTexture2()
end
  
function Crafting:LayoutShoppingFrame()
	Crafting.frame.shoppingScroll = Crafting:CreateShoppingScrollFrame()
	Crafting.frame.shoppingScroll.titleRow = Crafting:CreateShoppingTitleRow()
	Crafting.shoppingRows = Crafting:CreateShoppingRows()
end

function Crafting:LayoutQueuingFrame()
	Crafting.frame.queuingScroll = Crafting:CreateQueuingScrollFrame()	
	Crafting.frame.queuingScroll.titleRow = Crafting:CreateQueuingTitleRow()
	Crafting.queuingRows = Crafting:CreateQueueingRows()
end

local function HasCurrentProfessionOpen()
	if GetTradeSkillLine() == Crafting.mode then return true end
	for _, data in pairs(TSM.tradeSkills) do
		if GetSpellInfo(data.spellID) == GetTradeSkillLine() then return true end
	end
end

-- gets called to update the craft queue frame whenever something changes
function Crafting:UpdateCrafting()
	if not Crafting.mode then return end
	for _, row in pairs(Crafting.craftRows) do row:Hide() end
	if not (Crafting.mode and TSM[Crafting.mode]:HasProfession()) then
		Crafting.frame.noCrafting:Show()
		Crafting.frame.noCrafting.text:SetText(L[(Crafting.mode or "Profession") .. " was not found so the craft queue has been disabled."])
		Crafting.frame.noCrafting.button:Hide()
		return
	elseif Crafting.mode and TSM[Crafting.mode]:HasProfession() and not HasCurrentProfessionOpen() then
		Crafting.frame.noCrafting:Show()
		Crafting.frame.noCrafting.button:Show()
		Crafting.frame.noCrafting.button:SetText(L["Open "..Crafting.mode])
		Crafting.frame.noCrafting.text:SetText(L["You must have your profession window open in order to use the craft queue. Click on the button below to open it."])
		return
	end
	Crafting.frame.noCrafting:Hide()
	Crafting.frame.craftingScroll:Show()
	Crafting.button:Show()
	
	TSM.GUI:UpdateQueue(nil, Crafting.mode)
	
	-- Update the scroll bar
	FauxScrollFrame_Update(Crafting.frame.craftingScroll, TSM.GUI.queueInTotal, MAX_ROWS_CRAFTING-1, ROW_HEIGHT_CRAFTING)
	
	-- Now display the correct rows
	local offset = FauxScrollFrame_GetOffset(Crafting.frame.craftingScroll)
	local displayIndex = 0
	
	if #TSM.GUI.queueList == 0 then
		Crafting.button:Disable()
	end
	
	for index, data in ipairs(TSM.GUI.queueList) do
		-- if the craft should be displayed based on the scope of the scrollframe
		if( index >= offset and displayIndex < MAX_ROWS_CRAFTING ) then
			local mats = TSM.Data[Crafting.mode].crafts[data.itemID].mats
			local haveMats, needEssence, essenceID = Crafting:GetOrderIndex(data)
			local color
			
			if haveMats == 3 then
				color = "|cff00ff00"
			elseif haveMats == 2 then
				color = "|cffffff00"
			else
				color = "|cffff0000"
			end
			
			-- catches any craft which the player can't craft
			local cIndex = Crafting:GetIndex(data.spellID)
			if cIndex then
				displayIndex = displayIndex + 1
				Crafting.craftRows[displayIndex]:SetText(color .. (data.name or L["Craft"]) .. " (x" .. data.quantity .. ")|r")
			
				-- sets up the macro commands which get called when the player clicks on the craft name
				Crafting.craftRows[displayIndex]:SetAttribute("type", "macro")
				
				local velName = ""
				local quantity = data.quantity
				local essence -- FOR SPLITTING / COMBINING ESSENCES
				if Crafting.mode == "Enchanting" then
					velName = "\n/use " .. TSM:GetName(TSM.Enchanting.vellumID)
					quantity = 1
					for k=1, math.floor(needEssence) do
						essence = (essence or "") .. "/use " .. TSM:GetName(essenceID) .. "\n"
					end
				end
				
				Crafting.craftRows[displayIndex]:SetAttribute("macrotext", string.format("/script DoTradeSkill(%d,%d)%s", cIndex, quantity, velName))
				Crafting.craftRows[displayIndex]:SetScript("PostClick", function(self) Crafting.isCrafting = quantity end)
				
				if displayIndex == 1 then
					-- setup the "Craft Next craft" button
					Crafting.button:SetAttribute("type", "macro")
					if essence then
						Crafting.button:SetText(L["Combine / Split Essences"])
						Crafting.button:SetAttribute("macrotext", essence)
						Crafting.button:SetScript("PostClick", function(self)
								Crafting.isCrafting = 0
								self:Disable()
								self:RegisterEvent("BAG_UPDATE", function()
										Crafting.button:UnregisterEvent("BAG_UPDATE")
										self:Enable()
									end)
							end)
					else
						Crafting.button:SetText(L["Craft Next"])
						Crafting.button.spellID = data.spellID
						Crafting.button:SetAttribute("macrotext", string.format("/script DoTradeSkill(%d,%d)%s", cIndex, quantity, velName))
						Crafting.button:SetScript("PostClick", function(self)
								Crafting.isCrafting = quantity
								self:Disable()
							end)
					end
					
					if haveMats == 3 and not UnitCastingInfo("player") and Crafting.isCrafting == 0 then
						Crafting.button:Enable()
					else
						Crafting.button:Disable()
					end
				end
				
				Crafting.craftRows[displayIndex]:Show()
				Crafting.craftRows[displayIndex]:SetScript("OnEnter", function(frame)			
						GameTooltip:SetOwner(frame, "ANCHOR_NONE")
						GameTooltip:SetPoint("LEFT", frame, "RIGHT")
						GameTooltip:AddLine(data.name)
						for itemID, nQuantity in pairs(mats) do
							local name = TSM:GetName(itemID)
							local inventory = TSM.Data:GetPlayerNum(itemID)
							local need = nQuantity * data.quantity
							local color
							if inventory >= need then color = "|cff00ff00" else color = "|cffff0000" end
							name = color .. inventory .. "/" .. need .. "|r " .. name
							GameTooltip:AddLine(name)
						end
						GameTooltip:Show()
					end)
				Crafting.craftRows[displayIndex]:SetScript("OnLeave", function()
						GameTooltip:ClearLines()
						GameTooltip:Hide()
					end)
			end
		end
	end
	if displayIndex < MAX_ROWS_CRAFTING then
		FauxScrollFrame_Update(Crafting.frame.craftingScroll, displayIndex, MAX_ROWS_CRAFTING-1, ROW_HEIGHT_CRAFTING)
	end
end

function Crafting:UpdateShopping()
	if not Crafting.mode then return end
	for _, row in pairs(Crafting.shoppingRows) do row:Hide() end
	local need, total = TSM.Data:GetShoppingData("crafting")
	
	-- Update the scroll bar
	FauxScrollFrame_Update(Crafting.frame.shoppingScroll, #(total), MAX_ROWS_SHOPPING-1, ROW_HEIGHT_SHOPPING)
	
	-- Now display the correct rows
	local offset = FauxScrollFrame_GetOffset(Crafting.frame.shoppingScroll)
	local displayIndex = 0
	
	local temp = {}
	
	-- HORRIBLE CODE (but it sorts the shopping list hopefully)
	sort(total, function(a, b)
			if not temp[a[1]] or not temp[b[1]] then
				for _, v in pairs(need) do
					if v[1] == a[1] then
						temp[a[1]] = {}
						temp[a[1]].need = v[2]
					end
					if v[1] == b[1] then
						temp[b[1]] = {}
						temp[b[1]].need = v[2]
					end
				end
			end
			
			if temp[a[1]].need == temp[b[1]].need then
				if not temp[a[1]].bags then
					temp[a[1]].bags = TSM.Data:GetPlayerNum(a[1])
				end
				if not temp[b[1]].bags then
					temp[b[1]].bags = TSM.Data:GetPlayerNum(b[1])
				end
				if temp[a[1]].bags == temp[b[1]].bags then
					return a[1] < b[1]
				else
					return temp[a[1]].bags > temp[b[1]].bags
				end
			else
				return temp[a[1]].need < temp[b[1]].need
			end
		end)
	
	for index, data in pairs(total) do
		-- if the craft should be displayed based on the scope of the scrollframe
		if( index >= offset and displayIndex < MAX_ROWS_SHOPPING ) then
			local needNum = 0
			for _, v in pairs(need) do
				if v[1] == data[1] then
					needNum = v[2]
				end
			end
			
			local itemID = data[1]
			local name = TSM.Data[Crafting.mode].mats[itemID].name
			local cost = TSM.Data[Crafting.mode].mats[itemID].cost
			local totalNum = data[2]
			
			if not name then
				TSM.Data[Crafting.mode].mats[itemID].name = TSM:GetName(itemID)
				name = TSM.Data[Crafting.mode].mats[itemID].name
			end
			
			if needNum < 0 then needNum = 0 end
			
			if needNum == 0 and TSM.Data:GetPlayerNum(itemID) >= totalNum then
				needNum = 0
				color = "|cff00ff00"
			elseif needNum == 0 then
				color = "|cffffff00"
			else
				color = "|cffff0000"
			end
			
			local bGold = floor(cost)
			local bSilver = floor((cost - floor(cost))*100 + 0.5)
			local formattedBSilver = "|cffeeeeee" .. bSilver .. "s|r"
			if bSilver == 0 then
				formattedBSilver = ""
			end
			cost = "|cffffffff" .. bGold .. "|r" .. GOLD .. "g|r" .. formattedBSilver
			
			displayIndex = displayIndex + 1
			
			local row = Crafting.shoppingRows[displayIndex]
			row.itemID = itemID
			row:SetScript("OnClick", function() SetItemRef("item:" .. itemID, itemID) end)
			row.name:SetText(color .. name .. "|r")
			row.total:SetText(color .. totalNum .. "|r")
			row.value:SetText(cost)
			row.need:SetText(color .. needNum .. "|r")
			row.bags:SetText(color .. TSM.Data:GetPlayerNum(itemID) .. "|r")
			row:Show()
		end
	end
end

local profitCache = {time = GetTime()}
function Crafting:UpdateQueuing()
	if not Crafting.mode then return end
	for _, row in pairs(Crafting.queuingRows) do row:Hide() end
	
	-- Now display the correct rows
	local offset = FauxScrollFrame_GetOffset(Crafting.frame.queuingScroll)
	local displayIndex = 0
	local rowDisplay = {}

	local groupedData = TSM.Data:GetDataByGroups(Crafting.mode)
	
	local sortedGroupedData = {}
	for i in pairs(groupedData) do
		groupedData[i] = groupedData[i] or {}
		local disabled = {}
		for itemID, data in pairs(groupedData[i]) do
			if not data.enabled then
				tinsert(disabled, itemID)
			end
		end
		for _, itemID in pairs(disabled) do
			groupedData[i][itemID] = nil
		end
		if profitCache.time < (GetTime() - 2) then wipe(profitCache) profitCache.time = GetTime() end
		sortedGroupedData[i] = TSM.Data:GetSortedData(groupedData[i], function(a, b)
				if not profitCache[a.spellID] then profitCache[a.spellID] = select(3, TSM.Data:CalcPrices(a, true)) or 1/0 end
				if not profitCache[b.spellID] then profitCache[b.spellID] = select(3, TSM.Data:CalcPrices(b, true)) or 1/0 end
				return (profitCache[a.spellID]>profitCache[b.spellID])
			end)
	end
	
	local numPairs = 0
	for _ in pairs(sortedGroupedData) do
		numPairs = numPairs + 1
	end
	
	local slotList = TSM[Crafting.mode].slotList
	if Crafting.mode == "Inscription" then
		slotList = TSM.Inscription:GetSlotList()
	end
	
	local allRows = {{name=L["All"], isParent=true, group=0}}
	if numPairs == #sortedGroupedData then
		-- Add the index we will want in the correct order, so we can do offsets easily
		for group, crafts in ipairs(sortedGroupedData) do
			local parentRow = {}
			parentRow.name = slotList[group]
			parentRow.isParent = true
			parentRow.group = group
			
			local tempData = {}
			for _, sData in pairs(crafts) do
				local itemID = sData.originalIndex
				local item = TSM.Data[Crafting.mode].crafts[itemID]
				local data = {}
				
				data.name = data.name
				data.buyout, data.profit = select(2, TSM.Data:CalcPrices(item, true))
				data.itemID = itemID
				
				tinsert(tempData, data)
			end
			
			if #tempData > 0 then
				tinsert(rowDisplay, parentRow)
				
				if groupShown[group] or groupShown[0] then
					for _, data in pairs(tempData) do
						if groupShown[group] then
							tinsert(rowDisplay, data)
						elseif groupShown[0] then
							tinsert(allRows, data)
						end
					end
				end
			end
		end
	else
		-- Add the index we will want in the correct order, so we can do offsets easily
		for group, crafts in pairs(sortedGroupedData) do
			local parentRow = {}
			parentRow.name = slotList[group]
			parentRow.isParent = true
			parentRow.group = group
			
			tinsert(rowDisplay, parentRow)
			
			if groupShown[group] or groupShown[0] then
				for _, sData in pairs(crafts) do
					local itemID = sData.originalIndex
					local item = TSM.Data[Crafting.mode].crafts[itemID]
					local data = {}
					
					data.name = data.name
					data.buyout, data.profit = select(2, TSM.Data:CalcPrices(item, true))
					data.itemID = itemID
					
					if groupShown[group] then
						tinsert(rowDisplay, data)
					elseif groupShown[0] then
						tinsert(allRows, data)
					end
				end
			end
		end
	end
	
	sort(allRows, function(a, b) return (a.profit or 1/0) > (b.profit or 1/0) end)
	for i, v in pairs(rowDisplay) do tinsert(allRows, v) end
	
	-- Update the scroll bar
	FauxScrollFrame_Update(Crafting.frame.queuingScroll, #(allRows), MAX_ROWS_QUEUING-1, ROW_HEIGHT_QUEUING)
	
	-- Now display
	local offset = FauxScrollFrame_GetOffset(Crafting.frame.queuingScroll)
	local displayIndex = 0
	
	for index, data in pairs(allRows) do
		debug("loopC", index)
		if index >= offset and displayIndex < MAX_ROWS_QUEUING then
			displayIndex = displayIndex + 1
			
			local row = Crafting.queuingRows[displayIndex]
			local item = TSM.Data[Crafting.mode].crafts[data.itemID]
			row.itemID = data.itemID
			
			row.button.group = data.group
			row.tooltipData = nil
			
			if not data.isParent then
				local numInBags, numInBank, numOnAH = TSM.Data:GetPlayerNum(data.itemID)
				local numOnAlts = TSM.Data:GetAltNum(data.itemID)
				
				-- sets up the colors of the text
				local c1 = GREEN
				local c2 = GREEN
				local c3 = GREEN
				local c4 = GREEN
				if numOnAH == "?" then c1 = WHITE
				elseif numOnAH > 0 then c1 = RED end
				if numInBags > 0 then c2 = RED end
				if numOnAlts > 0 then c3 = RED end
				if numInBank > 0 then c4 = RED end
				row.quantity:SetText(string.format("%s%s|r/%s%s|r/%s%s|r/%s%s|r", c1, numOnAH, c2, numInBags, c4, numInBank, c3, numOnAlts))
			else
				row.quantity:SetText("")
			end
			
			local cost, buyout, profit = TSM.Data:CalcPrices(item, true)
			local oProfit = (profit or 0)*COPPER_PER_GOLD
			if buyout and profit then
				local bGold = floor(buyout)
				local bSilver = floor((buyout - floor(buyout))*100 + 0.5)
				local formattedBSilver = "|cffeeeeee" .. bSilver .. "s|r"
				if bSilver == 0 then
					formattedBSilver = ""
				end
				buyout = "|cffffffff" .. bGold .. "|r" .. GOLD .. "g|r" .. formattedBSilver
				if profit > 0 then
					profit = GREEN .. profit .. "|r" .. GOLD .. "g|r"
				else
					profit = RED .. profit .. "|r" .. GOLD .. "g|r"
				end
			else
				buyout = nil
				profit = nil
			end

			if buyout then
				row.buyout:SetText(buyout)
			elseif data.isParent then
				row.buyout:SetText("")
			else
				row.buyout:SetText("----")
			end
			
			if profit then
				row.profit:SetText(profit)
			elseif data.isParent then
				row.profit:SetText("")
			else
				row.profit:SetText("----")
			end
			
			-- Displaying a parent
			if data.isParent then
				row.name:SetText(data.name)
				row.name:ClearAllPoints()
				row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
				row.name:SetPoint("TOPRIGHT", row, "TOPLEFT", 200, 0)

				row:Show()
				row.button:Show()

				row.buyout:ClearAllPoints()
				row.buyout:SetPoint("TOPRIGHT", row, "TOPRIGHT", -14, 0)
				
				row.quantity:ClearAllPoints()
				row.quantity:SetPoint("TOPRIGHT", row, "TOPRIGHT", -160, 0)

				-- Is the button supposed to be + or -?
				if groupShown[row.button.group] then
					row.button:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
					row.button:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN")
					row.button:SetHighlightTexture("Interface\\Buttons\\UI-MinusButton-Hilight", "ADD")
				else
					row.button:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP")
					row.button:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN")
					row.button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
				end
				
			-- Orrr a child
			else
				local link = select(2, GetItemInfo(data.itemID))
				local craftQuantity = ""
				
				if item.queued > 0 then
					craftQuantity = string.format("%s%dx|r", GREEN, item.queued)
				end
				
				row.name:ClearAllPoints()
				row.name:SetPoint("TOPLEFT", row, "TOPLEFT", -2, 0)
				row.name:SetPoint("TOPRIGHT", row, "TOPLEFT", 200, 0)

				row.name:SetFormattedText("%s|r%s", craftQuantity, item.name)
				row:Show()
				row.button:Hide()
				
				row.buyout:ClearAllPoints()
				row.buyout:SetPoint("TOPLEFT", row, "TOPLEFT", 340, 0)
				
				row.profit:ClearAllPoints()
				row.profit:SetPoint("TOPLEFT", row, "TOPLEFT", 430, 0)

				row.quantity:ClearAllPoints()
				row.quantity:SetPoint("TOPLEFT", row, "TOPLEFT", 220, 0)
			end
		end
	end
end

function Crafting:TRADE_SKILL_FILTER_UPDATE()
	if not eventThrottle:IsVisible() then
		eventThrottle.event = "TRADE_SKILL_FILTER_UPDATE"
		eventThrottle:Show()
		return
	end
	Crafting:UpdateCrafting()
end

function Crafting:BAG_UPDATE()
	if not eventThrottle:IsVisible() then
		eventThrottle.event = "BAG_UPDATE"
		eventThrottle:Show()
		return
	end
	if Crafting.frame and Crafting.frame:IsVisible() then
		TSM.GUI:UpdateQueue(true)
		Crafting:UpdateAllScrollFrames()
	end
end

function Crafting:TRADE_SKILL_SHOW()
	if Crafting.frame then Crafting.frame:Hide() end
	if Crafting.openCloseButton then Crafting.openCloseButton:Hide() end
	if not TSM[Crafting:GetCurrentTradeskill()] then return end
	Crafting.horribleHackVar = true
	Crafting.mode = Crafting:GetCurrentTradeskill()
	Crafting:PrepareFrame("hide")
	if Crafting.nextFunc and Crafting.nextFunc ~= function() end then
		Crafting.horribleHackVar = false
		Crafting.nextFunc()
		Crafting.nextFunc = function() end
	end
end

-- cleans up the tables used and unregisters events when the trade skill window is closed
function Crafting:TRADE_SKILL_CLOSE(mode)
	if Crafting.frame and Crafting.frame:IsVisible() then
		Crafting.openCloseButton:SetParent(Crafting.frame)
		Crafting:UpdateCrafting()
	else
		Crafting.mode = nil
	end
	
	Crafting:UnregisterEvent("TRADE_SKILL_FILTER_UPDATE")
	Crafting:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	Crafting:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
end

-- detects when crafts are successfully cast and removes that item from the queue
function Crafting:UNIT_SPELLCAST_SUCCEEDED(event, unit, _, _, _, spellID)
	-- verifies that we are interested in this spellcast
	if unit ~= "player" then
		return
	end
	
	for _, data in pairs(TSM.Data[Crafting.mode].crafts) do
		if spellID == data.spellID then
			-- decrements the number of this craft that are queued to be crafted
			data.queued = data.queued - 1
			TSM.db.profile.craftHistory[spellID] = (TSM.db.profile.craftHistory[spellID] or 0) + 1
			-- updates the craft queue
			TSM.GUI:UpdateQueue(true)
			Crafting.isCrafting = Crafting.isCrafting - 1
			if data.queued <= 0 then
				Crafting.button:Enable()
			end
			Crafting:UpdateAllScrollFrames()
			return
		end
	end
end

function Crafting:UNIT_SPELLCAST_INTERRUPTED(event, unit, name, _, _, spellID)
	-- verifies that we are interested in this spellcast
	if unit ~= "player" then
		return
	end
	
	if spellID == Crafting.button.spellID and not Crafting.button:IsEnabled() then
		Crafting.button:Enable()
		Crafting.isCrafting = 0
	end
end

-- returns the trade skill index for a given craft name
function Crafting:GetIndex(sSpellID)
	local numSkills = GetNumTradeSkills()
	
	-- iterate over every craft in the trade skill window until we find the one with the name we are looking for
	for i=1, numSkills do
		local eSpellID = TSMAPI:GetItemID(GetTradeSkillRecipeLink(i))
		if eSpellID == sSpellID then
			-- store and then return the index of the craft we were looking for in the trade skill window
			return i
		end
	end
end

local matLookup = {}
local function UpdateMatLookup(mode)
	for itemID, eData in pairs(TSM.Data[mode].crafts) do
		matLookup[eData.spellID] = eData.mats
	end
end

function Crafting:GetOrderIndex(data, usedMats)
	usedMats = usedMats or {}
	local mode = TSM:GetMode()
	if not matLookup[data.spellID] then
		UpdateMatLookup(mode)
	end
	local mats = matLookup[data.spellID]
	local needEssence = 0
	local essenceID = 0
	local haveMats = nil
	if not mats then return end
	for itemID, nQuantity in pairs(mats) do
		local numHave = TSM.Data:GetPlayerNum(itemID) - (usedMats[itemID] or 0)
		local numHaveTotal = TSM.Data:GetPlayerNum(itemID, true)
		local need = nQuantity * data.quantity
		
		if mode == "Enchanting" then
			if TSM.Enchanting.lesserEssence[itemID] and need > numHave then -- need more greaters
				local diff = need - numHave
				if (TSM.Data:GetPlayerNum(TSM.Enchanting.lesserEssence[itemID] - (usedMats[TSM.Enchanting.lesserEssence[itemID]] or 0)) / 3) >= diff then
					numHave = need
					needEssence = diff
					essenceID = TSM.Enchanting.lesserEssence[itemID]
				end
			elseif TSM.Enchanting.greaterEssence[itemID] and need > numHave then -- need more lessers
				local diff = need - numHave
				if TSM.Data:GetPlayerNum(TSM.Enchanting.greaterEssence[itemID]) - (usedMats[TSM.Enchanting.greaterEssence[itemID]] or 0) >= (diff / 3) then
					numHave = need
					needEssence = math.ceil(diff / 3)
					essenceID = TSM.Enchanting.greaterEssence[itemID]
				end
			end
		end
		
		if numHave < need then
			if not haveMats or haveMats == 3 then
				if numHaveTotal > need then
					haveMats = 2
				else
					haveMats = 1
				end
			end
			if haveMats == 2 and numHaveTotal < need then
				haveMats = 1
			end
		else
			if not haveMats then
				haveMats = 3
			end
		end
	end
	return haveMats, needEssence, essenceID
end

-- opens the crafting window
function Crafting:OpenCrafting(nextFunc, mode)
	CloseTradeSkill()
	for _, data in pairs(TSM.tradeSkills) do
		if data.name == (mode or TSM.mode) then
			local spellName = GetSpellInfo(data.spellID)
			Crafting.nextFunc = nextFunc
			if not TSM[mode or TSM.mode]:HasProfession() then
				Crafting.mode = Crafting:GetCurrentTradeskill() or TSM.mode
				Crafting:PrepareFrame()
			else
				CastSpellByName(spellName) -- opens the profession
			end
			
			break
		end
	end
end

function Crafting:GetCurrentTradeskill()
	local currentName = GetTradeSkillLine()
	for _, data in pairs(TSM.tradeSkills) do
		local professionName = GetSpellInfo(data.spellID)
		if professionName == currentName then
			return data.name
		end
	end
end

function Crafting:AddHookForAdvancedTradeSkillWindowAddOn()
	if select(4, GetAddOnInfo("AdvancedTradeSkillWindow")) == 1 then
		local oldShow = ATSW_ShowWindow
		ATSW_ShowWindow = function()
				oldShow()
				Crafting:PrepareFrame()
				Crafting.mode = Crafting.mode or Crafting:GetCurrentTradeskill()
			end
	end
end

function Crafting:UserHasProfessionForCurrentMode()
	return Crafting.mode and TSM[Crafting.mode]:HasProfession()
end

function Crafting:GetTradeSkillFrameAndOffsets()
	local tsframe, ofsx, ofsy, bofsx, bofsy
	if ATSWFrame then
		tsframe, ofsx, ofsy = ATSWFrame, 0, -10
		bofsx, bofsy = 0, 12
	elseif SkilletFrame then
		tsframe, ofsx, ofsy = SkilletFrame, 0, 0
		bofsx, bofsy = 0, 12
	elseif GnomeWorks then
		tsframe, ofsx, ofsy = GnomeWorks:GetMainFrame(), 0, 0
		bofsx, bofsy = 0, 12
	else
		tsframe, ofsx, ofsy = TradeSkillFrame, 0, 9
		--bofsx, bofsy = 0, 30
		bofsx, bofsy = 53, 20
	end
	return tsframe, ofsx, ofsy, bofsx, bofsy
end

function Crafting:PositionFrameAndButton(hidden)
	local tsframe, ofsx, ofsy, bofsx, bofsy = Crafting:GetTradeSkillFrameAndOffsets()
	
	Crafting.openCloseButton:ClearAllPoints()
	Crafting.frame:ClearAllPoints()
	if Crafting:UserHasProfessionForCurrentMode() then
		Crafting.frame.craftingScroll:Show()
		Crafting.button:Show()
		Crafting.frame:SetParent(UIParent)
		Crafting.frame:SetPoint("TOPLEFT", tsframe, "TOPLEFT", ofsx, ofsy)
		Crafting.openCloseButton:SetParent(tsframe)
		Crafting.openCloseButton:SetPoint("TOPLEFT", tsframe, "TOPLEFT", bofsx, bofsy)
		if not Crafting.horribleHackVar then
			Crafting.horribleHackVar = false
			Crafting.openCloseButton:ClearAllPoints()
			Crafting.openCloseButton:SetPoint("BOTTOMRIGHT", Crafting.frame, "TOPRIGHT", 0, 2)
			Crafting.openCloseButton:SetScale(TSM.db.profile.craftManagementWindowScale)
		end
	else
		Crafting.frame.craftingScroll:Hide()
		Crafting.button:Hide()
		Crafting.frame:SetParent(UIParent)
		Crafting.frame:SetPoint("CENTER", UIParent, "CENTER", -100, 100)
		Crafting.openCloseButton:SetParent(Crafting.frame)
		Crafting.openCloseButton:SetScale(TSM.db.profile.craftManagementWindowScale)
		Crafting.openCloseButton:SetPoint("BOTTOMRIGHT", Crafting.frame, "TOPRIGHT", 0, 2)
	end
	Crafting.openCloseButton:SetHeight(25)
	Crafting.openCloseButton:SetWidth(250)
	Crafting.openCloseButton:SetFrameStrata(Crafting.openCloseButton:GetParent():GetFrameStrata())
	Crafting.openCloseButton:SetFrameLevel(Crafting.openCloseButton:GetParent():GetFrameLevel()+1)
	Crafting.frame:SetWidth(FRAME_WIDTH)
	Crafting.frame:SetHeight(FRAME_HEIGHT)
	Crafting.frame:SetScale(TSM.db.profile.craftManagementWindowScale)
	Crafting.frame:SetFrameStrata("High")
	if not hidden then
		Crafting:UpdateCrafting()
	end
end

function Crafting:CreateOpenCloseButton()
	local tsframe, ofsx, ofsy, bofsx, bofsy = Crafting:GetTradeSkillFrameAndOffsets()
	
	-- Toggle showing the queue frame thing
	local openCloseButton = Crafting:CreateButton(L["Close TradeSkillMaster_Crafting"], nil, tsframe, "UIPanelButtonTemplate", 25, GameFontHighlight, 0)
	openCloseButton:SetWidth(250)
	openCloseButton:SetPoint("TOPLEFT", tsframe, "TOPLEFT", bofsx, bofsy)
	openCloseButton:SetScript("OnClick", function(self)
		if Crafting.frame:IsVisible() then
			Crafting.frame:Hide()
			Crafting:TRADE_SKILL_CLOSE(Crafting.mode)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", tsframe, "TOPLEFT", bofsx, bofsy)
			openCloseButton:SetHeight(25)
			openCloseButton:SetWidth(250)
		else
			TSM.Crafting:OpenFrame(Crafting:GetCurrentTradeskill())
			self:ClearAllPoints()
			self:SetPoint("BOTTOMRIGHT", Crafting.frame, "TOPRIGHT", 0, 2)
			openCloseButton:SetHeight(25)
			openCloseButton:SetWidth(250)
		end
	end)
	openCloseButton:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 18,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	Crafting:ApplyTexturesToButton(openCloseButton, true)
	return openCloseButton
end

function Crafting:CreateCraftingFrame()
	local tsframe, ofsx, ofsy, bofsx, bofsy = Crafting:GetTradeSkillFrameAndOffsets()
	
	-- Queue Frame GUI
	local frame = CreateFrame("Frame", "TSMCraftingFrame", UIParent)
	frame:SetWidth(FRAME_WIDTH)
	frame:SetHeight(FRAME_HEIGHT)
	frame:SetPoint("TOPLEFT", tsframe, "TOPLEFT", ofsx, ofsy)
	frame:SetFrameStrata("High")
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", frame.StartMoving)
	frame:SetScript("OnMouseUp", frame.StopMovingOrSizing)
	frame:SetScript("OnShow", function() Crafting.openCloseButton:SetText(L["Close TradeSkillMaster_Crafting"]) end)
	frame:SetScript("OnHide", function() Crafting:UnregisterEvent("BAG_UPDATE") Crafting.openCloseButton:SetText(L["Open TradeSkillMaster_Crafting"]) end)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		tile = false,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 24,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	frame:SetBackdropColor(0, 0, 0.05, 1)
	frame:SetBackdropBorderColor(0,0,1,1)
	tinsert(UISpecialFrames, frame:GetName())
	return frame
end

function Crafting:CreateTitleBackground()
	local titlebg = CreateFrame("Frame", nil, Crafting.frame)
	titlebg:EnableMouse(true)
	titlebg:SetScript("OnMouseDown", function(self) self:GetParent():StartMoving() end)
	titlebg:SetScript("OnMouseUp", function(self) self:GetParent():StopMovingOrSizing() end)
	titlebg:SetWidth(360)
	titlebg:SetHeight(30)
	titlebg:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		tile = false,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = {left = 2, right = 2, top = 2, bottom = 2},
	})
	titlebg:SetBackdropColor(0, 0, 0.05, 1)
	titlebg:SetBackdropBorderColor(0, 0, 0.7, 1)
	titlebg:SetPoint("TOP", 0, 28)
	return titlebg
	
end

function Crafting:CreateTitleText()
	-- Tittle frame which contains the tittle text
	local tFile, tSize = GameFontNormalLarge:GetFont()
	local titleText = Crafting.frame.titleBackground:CreateFontString(nil, "Overlay", "GameFontNormalLarge")
	titleText:SetFont(tFile, tSize, "OUTLINE")
	titleText:SetTextColor(1, 1, 1, 1)
	titleText:SetPoint("CENTER", Crafting.frame.titleBackground, "CENTER", 0, 0)
	titleText:SetText("Crafting ("..TSM.version..") - ")
	return titleText
end

function Crafting:CreateCraftingScrollFrame()
	-- Scroll frame to contain all the queued crafts
	local craftingScroll = CreateFrame("ScrollFrame", "TSMCraftingScrollCrafting", Crafting.frame, "FauxScrollFrameTemplate")
	craftingScroll:SetPoint("TOPLEFT", Crafting.frame, "TOPLEFT", FRAME_WIDTH-330, -166)
	craftingScroll:SetPoint("BOTTOMRIGHT", Crafting.frame, "BOTTOMRIGHT", -30, 46)
	craftingScroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT_CRAFTING, Crafting.UpdateCrafting) 
	end)
	return craftingScroll
end

function Crafting:CreateCraftingDisabledMessage()
	local frame = CreateFrame("Frame", nil, Crafting.frame)
	frame:SetWidth(280)
	frame:SetHeight(100)
	frame:SetPoint("BOTTOMRIGHT", -40, 150)
	frame:SetScript("OnShow", function() Crafting.button:Hide() Crafting.frame.craftingScroll:Hide() end)
	
	local tFile, tSize = GameFontNormalLarge:GetFont()
	local text = frame:CreateFontString(nil, "Overlay", "GameFontNormalLarge")
	text:SetFont(tFile, tSize-4, "OUTLINE")
	text:SetTextColor(1, 1, 1, 1)
	text:SetWidth(280)
	text:SetPoint("TOP")
	text:SetText("")
	frame.text = text
	
	local delayFrame = CreateFrame("Frame")
	delayFrame:Hide()
	delayFrame:RegisterEvent("TRADE_SKILL_SHOW")
	delayFrame:SetScript("OnEvent", function(self)
			self.timeLeft = 0.1
		end)
	delayFrame:SetScript("OnUpdate", function(self, elapsed)
			if self.timeLeft then
				self.timeLeft = self.timeLeft - elapsed
				if self.timeLeft <= 0 then
					self:Hide()
					self:UnregisterAllEvents()
					Crafting.openCloseButton:SetParent(Crafting:GetTradeSkillFrameAndOffsets())
					Crafting:RegisterEvent("TRADE_SKILL_SHOW")
					Crafting:UpdateCrafting()
				end
			end
		end)
	
	local btn = Crafting:CreateWhiteButton("", nil, "UIPanelButtonTemplate", 30, -20, frame, "BOTTOMLEFT", 50, "BOTTOMRIGHT", -50, 0)
	btn:Hide()
	btn:SetScript("OnClick", function()
			delayFrame:Show()
			Crafting:UnregisterEvent("TRADE_SKILL_SHOW")
			for _, data in pairs(TSM.tradeSkills) do
				if Crafting.mode == data.name then
					local name = GetSpellInfo(data.spellID)
					CastSpellByName(name)
					break
				end
			end
		end)
	frame.button = btn
	return frame
end

function Crafting:ApplyTexturesToButton(btn, isopenCloseButton)
	local texture = "Interface\\TokenFrame\\UI-TokenFrame-CategoryButton"
	local offset = 6
	if isopenCloseButton then
		offset = 5
		texture = "Interface\\Buttons\\UI-AttributeButton-Encourage-Hilight"
	end
	
	local normalTex = btn:CreateTexture()
	normalTex:SetTexture(texture)
	normalTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -offset, -offset)
	normalTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", offset, offset)
	
	local disabledTex = btn:CreateTexture()
	disabledTex:SetTexture(texture)
	disabledTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -offset, -offset)
	disabledTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", offset, offset)
	disabledTex:SetVertexColor(0.1, 0.1, 0.1, 1)
	
	local highlightTex = btn:CreateTexture()
	highlightTex:SetTexture(texture)
	highlightTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -offset, -offset)
	highlightTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", offset, offset)
	
	local pressedTex = btn:CreateTexture()
	pressedTex:SetTexture(texture)
	pressedTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -offset, -offset)
	pressedTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", offset, offset)
	pressedTex:SetVertexColor(1, 1, 1, 0.5)
	
	if isopenCloseButton then
		normalTex:SetTexCoord(0.041, 0.975, 0.129, 1.00)
		disabledTex:SetTexCoord(0.049, 0.931, 0.008, 0.121)
		highlightTex:SetTexCoord(0, 1, 0, 1)
		highlightTex:SetVertexColor(0.9, 0.9, 0.9, 0.9)
		pressedTex:SetTexCoord(0.035, 0.981, 0.014, 0.670)
	btn:SetPushedTextOffset(0, -1)
	else
		normalTex:SetTexCoord(0.049, 0.958, 0.066, 0.244)
		disabledTex:SetTexCoord(0.049, 0.958, 0.066, 0.244)
		highlightTex:SetTexCoord(0.005, 0.994, 0.613, 0.785)
		highlightTex:SetVertexColor(0.3, 0.3, 0.3, 0.7)
		pressedTex:SetTexCoord(0.0256, 0.743, 0.017, 0.158)
	btn:SetPushedTextOffset(0, -3)
	end
	
	btn:SetNormalTexture(normalTex)
	btn:SetDisabledTexture(disabledTex)
	btn:SetHighlightTexture(highlightTex)
	btn:SetPushedTexture(pressedTex)
end

function Crafting:CreateButton(text, frameName, parentFrame, inheritsFrame, height, baseFont, relativeSize)
	local btn = CreateFrame("Button", frameName, parentFrame, inheritsFrame)
	btn:SetHeight(height)
	btn:SetText(text)
	btn:GetFontString():SetPoint("CENTER")
	local tFile, tSize = baseFont:GetFont()
	btn:GetFontString():SetFont(tFile, tSize + relativeSize, "OUTLINE")
	return btn
end

function Crafting:CreateWhiteButton(text, frameName, inheritsFrame, height, relativeSize, relativeFrame, topLeftRelativePoint, topLeftXOffset, topRightRelativePoint, topRightXOffset, topYOffset, parent)
	local btn = Crafting:CreateButton(text, frameName, parent or relativeFrame, inheritsFrame, height, ZoneTextFont, relativeSize)
	btn:GetFontString():SetTextColor(1, 1, 1, 1)
	btn:SetPushedTextOffset(0, 0)
	btn:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 24,
		insets = {left = 2, right = 2, top = 4, bottom = 4},
	})
	btn:SetScript("OnDisable", function(self) self:GetFontString():SetTextColor(0.5, 0.5, 0.5, 1) end)
	btn:SetScript("OnEnable", function(self) self:GetFontString():SetTextColor(1, 1, 1, 1) end)	
	btn:SetPoint("TOPLEFT", relativeFrame, topLeftRelativePoint, topLeftXOffset, topYOffset)
	btn:SetPoint("TOPRIGHT", relativeFrame, topRightRelativePoint, topRightXOffset, topYOffset)
	Crafting:ApplyTexturesToButton(btn)	
	return btn
end

function Crafting:CreateVerticalBarFrame()
	local verticalBarFrame = CreateFrame("Frame", "TESTTSMFRAME", Crafting.frame)
	verticalBarFrame:SetPoint("TOPLEFT", Crafting.frame, "TOPLEFT", FRAME_WIDTH-340, -4)
	verticalBarFrame:SetPoint("BOTTOMLEFT", Crafting.frame, "BOTTOMLEFT", FRAME_WIDTH-340, 4)
	verticalBarFrame:SetWidth(8)	
	return verticalBarFrame
end

function Crafting:CreateVerticalBarTexture()
	local verticalBarTex = Crafting.frame.verticalBarFrame:CreateTexture()
	verticalBarTex:SetAllPoints(Crafting.frame.verticalBarFrame)
	verticalBarTex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	verticalBarTex:SetTexCoord(0.254, 0.301, 0.083, 0.928)
	verticalBarTex:SetVertexColor(0, 0, 0.7, 1)
	return verticalBarTex
end

function Crafting:CreateHorizontalBarFrame()
	local horizontalBarFrame = CreateFrame("Frame", "TESTTSMFRAME", Crafting.frame)
	horizontalBarFrame:SetPoint("BOTTOMLEFT", Crafting.frame.craftingScroll, "TOPLEFT", -5, 0)
	horizontalBarFrame:SetPoint("BOTTOMRIGHT", Crafting.frame.craftingScroll, "TOPRIGHT", 26, 0)
	horizontalBarFrame:SetHeight(6)
	return horizontalBarFrame
end

function Crafting:CreateHorizontalBarTexture()
	local horizontalBarTex = Crafting.frame.horizontalBarFrame:CreateTexture()
	horizontalBarTex:SetAllPoints(Crafting.frame.horizontalBarFrame)
	horizontalBarTex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	horizontalBarTex:SetTexCoord(0.577, 0.683, 0.145, 0.309)
	horizontalBarTex:SetVertexColor(0, 0, 0.7, 1)
	return horizontalBarTex
end

function Crafting:CreateHorizontalBarFrame2()
	local horizontalBarFrame2 = CreateFrame("Frame", "TESTTSMFRAME", Crafting.frame)
	horizontalBarFrame2:SetPoint("TOPLEFT", Crafting.frame, "TOPLEFT", 4, -300)
	horizontalBarFrame2:SetPoint("TOPRIGHT", Crafting.frame.verticalBarFrame, "TOPRIGHT", -4, -311)
	horizontalBarFrame2:SetHeight(6)
	return horizontalBarFrame2
end

function Crafting:CreateHorizontalBarTexture2()
	local horizontalBarTex2 = Crafting.frame.horizontalBarFrame2:CreateTexture()
	horizontalBarTex2:SetAllPoints(Crafting.frame.horizontalBarFrame2)
	horizontalBarTex2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	horizontalBarTex2:SetTexCoord(0.577, 0.683, 0.145, 0.309)
	horizontalBarTex2:SetVertexColor(0, 0, 0.7, 1)
	return horizontalBarTex2
end

function Crafting:CreateCraftRows()
	-- rows of the scrollframe containing the crafts in the queue
	-- each row is the clickable name of a craft (we set up the script to craft the craft later)
	local craftRows = {}
	for count=1, MAX_ROWS_CRAFTING do
		local row = CreateFrame("Button", nil, Crafting.frame, "SecureActionButtonTemplate")
		row:SetHeight(ROW_HEIGHT_CRAFTING)
		row:SetNormalFontObject(GameFontHighlight)
		row:SetText("*")
		row:GetFontString():SetPoint("LEFT", row, "LEFT", 0, 0)
		row:SetPushedTextOffset(0, 0)
		row:SetScript("PreClick", function() TSM.GUI:UpdateQueue() Crafting:UpdateCrafting() end)
		
		if( count > 1 ) then
			row:SetPoint("TOPLEFT", craftRows[count - 1], "BOTTOMLEFT", 0, -2)
			row:SetPoint("TOPRIGHT", Crafting.frame.craftingScroll, "BOTTOMRIGHT", 0, -2)
		else
			row:SetPoint("TOPLEFT", Crafting.frame.craftingScroll, "TOPLEFT", 0, 0)
			row:SetPoint("TOPRIGHT", Crafting.frame.craftingScroll, "TOPRIGHT", -12, 0)
		end
		
		craftRows[count] = row
	end
	return craftRows
end

function Crafting:ShowTooltip(row)
	if row.tooltip then
		GameTooltip:SetOwner(row, "ANCHOR_TOPLEFT")
		GameTooltip:SetText(row.tooltip, nil, nil, nil, nil, true)
		GameTooltip:Show()
	elseif row.itemID then
		if row.button and row.button:IsVisible()  then
			GameTooltip:SetOwner(row.button, "ANCHOR_RIGHT")
		else
			GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
		end
		
		local link = select(2, GetItemInfo(row.itemID))
		if link then
			GameTooltip:SetHyperlink(link)
		end
		
		if row.extraTooltip then
			GameTooltip:AddLine(YELLOW..row.extraTooltip, nil, nil, nil, true)
		end
		
		GameTooltip:Show()
	end
end

function Crafting:HideTooltip(row)
	GameTooltip:Hide()
end

function Crafting:CreateShoppingScrollFrame()
	-- Scroll frame to contain all the queued crafts
	local shoppingScroll = CreateFrame("ScrollFrame", "TSMCraftingScrollShopping", Crafting.frame, "FauxScrollFrameTemplate")
	shoppingScroll:SetPoint("TOPLEFT", Crafting.frame.horizontalBarFrame2, "TOPLEFT", 4, -24)
	shoppingScroll:SetPoint("BOTTOMRIGHT", Crafting.frame.verticalBarFrame, "BOTTOMLEFT", -21, 2)
	shoppingScroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT_SHOPPING, Crafting.UpdateShopping) 
	end)
	return shoppingScroll
end

function Crafting:CreateShoppingTitleRow()
	local row = CreateFrame("Button", nil, Crafting.frame)
	row:SetHeight(14)
	row:SetPoint("TOPLEFT", Crafting.frame.shoppingScroll, "TOPLEFT", 	0, 18)
	row:SetPoint("TOPRIGHT", Crafting.frame.shoppingScroll, "TOPRIGHT", 0, 18)
	
	row.name = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.name:SetText(L["Name"])
	row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 40, 0)
	row.name:SetPoint("TOPRIGHT", row, "TOPLEFT", 100, 0)
	row.name:SetJustifyH("Left")
	row.name:SetJustifyV("TOP")
	
	row.need = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.need:SetText(L["Need"])
	row.need:SetPoint("TOPLEFT", row, "TOPLEFT", 180, 0)
	row.need:SetPoint("TOPRIGHT", row, "TOPLEFT", 250, 0)
	row.need:SetJustifyH("Left")
	row.need:SetJustifyV("TOP")
	
	row.bags = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.bags:SetText(L["In Bags"])
	row.bags:SetPoint("TOPLEFT", row, "TOPLEFT", 250, 0)
	row.bags:SetPoint("TOPRIGHT", row, "TOPLEFT", 320, 0)
	row.bags:SetJustifyH("Left")
	row.bags:SetJustifyV("TOP")
	
	row.total = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.total:SetText(L["Total"])
	row.total:SetPoint("TOPLEFT", row, "TOPLEFT", 320, 0)
	row.total:SetPoint("TOPRIGHT", row, "TOPLEFT", 390, 0)
	row.total:SetJustifyH("Left")
	row.total:SetJustifyV("TOP")
	
	row.value = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.value:SetText(L["Market Value"])
	row.value:SetPoint("TOPLEFT", row, "TOPLEFT", 390, 0)
	row.value:SetPoint("TOPRIGHT")
	row.value:SetJustifyH("Left")
	row.value:SetJustifyV("TOP")
	
	row.bar = row:CreateTexture()
	row.bar:SetPoint("BOTTOMLEFT", Crafting.frame.shoppingScroll, "TOPLEFT")
	row.bar:SetPoint("BOTTOMRIGHT", Crafting.frame.shoppingScroll, "BOTTOMRIGHT", 24, 0)
	row.bar:SetHeight(4)
	row.bar:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	row.bar:SetTexCoord(0.577, 0.683, 0.145, 0.309)
	row.bar:SetVertexColor(0, 0, 0.7, 0.5)
	
	return row
end

function Crafting:CreateShoppingRows()
	-- rows of the scrollframe containing the crafts in the queue
	-- each row is the clickable name of a craft (we set up the script to craft the craft later)
	local shoppingRows = {}
	for count=1, MAX_ROWS_SHOPPING do
		local row = CreateFrame("Button", nil, Crafting.frame, "SecureActionButtonTemplate")
		row:SetHeight(ROW_HEIGHT_SHOPPING)
		row.extraTooltip = L["Right click to remove all items with this mat from the craft queue."]
		row:SetScript("OnEnter", function(row) Crafting:ShowTooltip(row) end)
		row:SetScript("OnLeave", function(row) Crafting:HideTooltip(row) end)
		
		if( count > 1 ) then
			row:SetPoint("TOPLEFT", shoppingRows[count - 1], "BOTTOMLEFT", 0, -2)
			row:SetPoint("TOPRIGHT", Crafting.frame.shoppingScroll, "BOTTOMRIGHT", 0, -2)
		else
			row:SetPoint("TOPLEFT", Crafting.frame.shoppingScroll, "TOPLEFT", 0, 0)
			row:SetPoint("TOPRIGHT", Crafting.frame.shoppingScroll, "TOPRIGHT", -12, 0)
		end
		
		row.name = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		row.name:SetTextColor(1, 1, 1, 1)
		row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
		row.name:SetPoint("TOPRIGHT", row, "TOPLEFT", 200, 0)
		row.name:SetJustifyH("Left")
		row.name:SetJustifyV("TOP")
		
		row.need = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		row.need:SetTextColor(1, 1, 1, 1)
		row.need:SetPoint("TOPLEFT", row, "TOPLEFT", 180, 0)
		row.need:SetPoint("TOPRIGHT", row, "TOPLEFT", 250, 0)
		row.need:SetJustifyH("Left")
		row.need:SetJustifyV("TOP")
		
		row.bags = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		row.bags:SetTextColor(1, 1, 1, 1)
		row.bags:SetPoint("TOPLEFT", row, "TOPLEFT", 250, 0)
		row.bags:SetPoint("TOPRIGHT", row, "TOPLEFT", 320, 0)
		row.bags:SetJustifyH("Left")
		row.bags:SetJustifyV("TOP")
		
		row.total = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		row.total:SetTextColor(1, 1, 1, 1)
		row.total:SetPoint("TOPLEFT", row, "TOPLEFT", 320, 0)
		row.total:SetPoint("TOPRIGHT", row, "TOPLEFT", 390, 0)
		row.total:SetJustifyH("Left")
		row.total:SetJustifyV("TOP")
		
		row.value = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		row.value:SetTextColor(1, 1, 1, 1)
		row.value:SetPoint("TOPLEFT", row, "TOPLEFT", 400, 0)
		row.value:SetPoint("TOPRIGHT")
		row.value:SetJustifyH("Left")
		row.value:SetJustifyV("TOP")
		
		shoppingRows[count] = row
	end
	return shoppingRows
end

function Crafting:ToggleCategory(button)
	groupShown[button.group] = not groupShown[button.group]
	TSM.Data:CalculateCosts()
	Crafting:UpdateQueuing()
end

function Crafting:CraftRowClicked(row, mouseButton)
	if not row.itemID then
		Crafting:ToggleCategory(row.button)
	elseif mouseButton == "LeftButton" then
		TSM.Data[Crafting.mode].crafts[row.itemID].queued = TSM.Data[Crafting.mode].crafts[row.itemID].queued + 1
		TSM.GUI:UpdateQueue(true)
		Crafting:UpdateAllScrollFrames()
	elseif mouseButton == "RightButton" then
		if TSM.Data[Crafting.mode].crafts[row.itemID].queued > 0 then
			TSM.Data[Crafting.mode].crafts[row.itemID].queued = TSM.Data[Crafting.mode].crafts[row.itemID].queued - 1
		end
		TSM.GUI:UpdateQueue(true)
		Crafting:UpdateAllScrollFrames()
	end
end

function Crafting:CraftRowDoubleClicked(row, mouseButton)
	TSM.db.profile.doubleClick = TSM.db.profile.doubleClick or 5
	for i=1, TSM.db.profile.doubleClick-1 do
		Crafting:CraftRowClicked(row, mouseButton)
	end
end

function Crafting:CreateQueuingScrollFrame()
	-- Scroll frame to contain all the queued crafts
	local queuingScroll = CreateFrame("ScrollFrame", "TSMCraftingScrollQueuing", Crafting.frame, "FauxScrollFrameTemplate")
	queuingScroll:SetPoint("TOPLEFT", Crafting.frame, "TOPLEFT", 6, -24)
	queuingScroll:SetPoint("BOTTOMRIGHT", Crafting.frame.horizontalBarFrame2, "TOPRIGHT", -25, 1)
	queuingScroll:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT_QUEUING, Crafting.UpdateQueuing) 
	end)
	return queuingScroll
end

function Crafting:CreateQueuingTitleRow()
	local row = CreateFrame("Button", nil, Crafting.frame)
	row:SetHeight(14)
	row:SetPoint("TOPLEFT", Crafting.frame.queuingScroll, "TOPLEFT", 	0, 18)
	row:SetPoint("TOPRIGHT", Crafting.frame.queuingScroll, "TOPRIGHT", 0, 18)
	
	row.name = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.name:SetText(L["Name"])
	row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 50, 0)
	row.name:SetPoint("TOPRIGHT", row, "TOPLEFT", 150, 0)
	row.name:SetJustifyH("Left")
	row.name:SetJustifyV("TOP")
	
	row.quantity = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.quantity:SetText(L["AH/Bags/Bank/Alts"])
	row.quantity:SetPoint("TOPLEFT", row, "TOPLEFT", 180, 0)
	row.quantity:SetPoint("TOPRIGHT", row, "TOPLEFT", 350, 0)
	row.quantity:SetJustifyH("Left")
	row.quantity:SetJustifyV("TOP")
	
	row.buyout = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.buyout:SetText(L["Market Value"])
	row.buyout:SetPoint("TOPLEFT", row, "TOPLEFT", 350, 0)
	row.buyout:SetPoint("TOPRIGHT", row, "TOPLEFT", 430, 0)
	row.buyout:SetJustifyH("Left")
	row.buyout:SetJustifyV("TOP")
	
	row.profit = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	row.profit:SetText(L["Profit"])
	row.profit:SetPoint("TOPLEFT", row, "TOPLEFT", 455, 0)
	row.profit:SetPoint("TOPRIGHT")
	row.profit:SetJustifyH("Left")
	row.profit:SetJustifyV("TOP")
	
	row.bar = row:CreateTexture()
	row.bar:SetPoint("BOTTOMLEFT", Crafting.frame.queuingScroll, "TOPLEFT")
	row.bar:SetPoint("BOTTOMRIGHT", Crafting.frame.queuingScroll, "BOTTOMRIGHT", 24, 0)
	row.bar:SetHeight(4)
	row.bar:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	row.bar:SetTexCoord(0.577, 0.683, 0.145, 0.309)
	row.bar:SetVertexColor(0, 0, 0.7, 0.5)
	
	return row
end

function Crafting:CreateQueueingRows()
	-- rows of the scrollframe containing the crafts in the queue
	-- each row is the clickable name of a craft (we set up the script to craft the craft later)
	local queuingRows = {}
	local offset = 0
	for count=1, MAX_ROWS_QUEUING do
		local row = CreateFrame("Button", nil, Crafting.frame, "SecureActionButtonTemplate")
		row:SetHeight(ROW_HEIGHT_QUEUING)
		row:RegisterForClicks("AnyUp")
		row:SetScript("OnEnter", function(row) Crafting:ShowTooltip(row) end)
		row:SetScript("OnLeave", function(row) Crafting:HideTooltip(row) end)
		row:SetScript("OnClick", function(row, mouseButton) Crafting:CraftRowClicked(row, mouseButton) end)
		row:SetScript("OnDoubleClick", function(row, mouseButton) Crafting:CraftRowDoubleClicked(row, mouseButton) end)
		
		if( count > 1 ) then
			row:SetPoint("TOPLEFT", queuingRows[count - 1], "BOTTOMLEFT", 0, -2)
			row:SetPoint("TOPRIGHT", Crafting.frame.queuingScroll, "BOTTOMRIGHT", 0, -2)
		else
			row:SetPoint("TOPLEFT", Crafting.frame.queuingScroll, "TOPLEFT", 	18, 0)
			row:SetPoint("TOPRIGHT", Crafting.frame.queuingScroll, "TOPRIGHT", -12, 0)
		end
		
		row.buyout = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.profit = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.quantity = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.name:SetText("*")
		row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
		row.name:SetPoint("TOPRIGHT", row, "TOPLEFT", 200, 0)
		row.name:SetJustifyH("Left")
		row.name:SetJustifyV("TOP")
		
		row.button = CreateFrame("Button", nil, row)
		row.button:SetScript("OnClick", function(button) Crafting:ToggleCategory(button) end)
		row.button:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP")
		row.button:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN")
		row.button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
		row.button:SetPoint("TOPLEFT", row, "TOPLEFT", -16, 0)
		row.button:SetHeight(14)
		row.button:SetWidth(14)
		
		row.button:Hide()
		row:Hide()
		
		queuingRows[count] = row
	end
	return queuingRows
end