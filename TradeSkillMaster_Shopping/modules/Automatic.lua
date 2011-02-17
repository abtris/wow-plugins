local TSM = select(2, ...)
local Automatic = TSM:NewModule("Automatic", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local ROW_HEIGHT = 20
local MAX_ROWS = 6

local function debug(...)
	TSM:Debug(...)
end

function Automatic:OnEnable()
	if not select(4, GetAddOnInfo("TradeSkillMaster_Crafting")) then return end
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Shopping", "shoppingAutomatic", "Interface\\Icons\\Spell_Holy_ImprovedResistanceAuras", 
		L["Shopping - Crafting Mats"], function(...) Automatic:LoadSidebar(...) end, Automatic.HideSidebar)
	Automatic.shoppingList = {}
end

function Automatic:LoadSidebar(parentFrame)
	if not Automatic.frame then
		local maxWidth = parentFrame:GetWidth() - 16
	
		local container = CreateFrame("Frame", nil, parentFrame)
		container:SetAllPoints(parentFrame)
		container:Raise()
		
		container.title = TSM.GUI:CreateLabel(container, L["Shopping - Crafting Mats"], GameFontHighlight, 0, "OUTLINE", maxWidth, {"TOP", 0, -20})
		TSM.GUI:AddHorizontalBar(container, -45)
		
		container.text = TSM.GUI:CreateLabel(container, L["Shopping will automatically buy materials you need for your craft queue in TradeSkillMaster_Crafting.\n\nNote that all queues will be shopped for so make sure you clear any queues you don't want to buy mats for."], GameFontHighlight, 0, "OUTLINE", maxWidth, {"TOP", 0, -100})
		
		local btn = TSM.GUI:CreateButton(L["Start Shopping for Crafting Mats!"], container, "TSMShoppingAutomaticStartButton", "UIPanelButtonTemplate", -1, nil, 28, {"TOPLEFT", 20, -220}, {"TOPRIGHT", -20, -220}, L["Start Shopping for Crafting Mats!"])
		btn:SetScript("OnClick", function(self) Automatic:StartAutomaticMode(parentFrame) end)
		container.goButton = btn
		
		Automatic.frame = container
	end
	
	Automatic.frame:Show()
end

function Automatic:HideSidebar()
	Automatic.frame:Hide()
end

function Automatic:StartAutomaticMode()
	Automatic:ShowAutomaticFrame()
	local list = CopyTable(TSMAPI:GetData("shopping"))
	local toRemove = {}
	
	for i, data in ipairs(list) do
		data.itemID, data.quantity, data.mode = unpack(data)
		data.cost = TSMAPI:GetData("craftingcost", data.itemID)
		data[1], data[2], data[3] = nil, nil, nil
		if data.mode or TSM.db.global.neverShopFor[data.itemID] then
			tinsert(toRemove, i)
		elseif TSM.Destroying:GetDestroyableInfo(data.itemID) then
			data.mode = "Destroying"
		else
			data.mode = "General"
		end
	end
	
	for i=#(toRemove), 1, -1 do
		tremove(list, toRemove[i])
	end
	
	Automatic.shoppingList = list
	TSMAPI:LockSidebar()
	TSM.automaticMode = true
	Automatic:UpdateScrollFrame()
	Automatic:QueryNextItem()
end

function Automatic:ShowAutomaticFrame()
	if not Automatic.autoFrame then
		local container = TSM.GUI:CreateBlueFrame(Automatic.frame:GetParent(), 200)
		local maxWidth = container:GetWidth()
		
		container.title = TSM.GUI:CreateLabel(container, "|cffff0000"..L["Shopping - Automatic Mode"].."|r", GameFontHighlight, 0, "OUTLINE", 192, {"TOP", 8, -10}, "CENTER")
		
		TSM.GUI:AddHorizontalBar(container, -25)
		
		-- Scroll frame to contain the shopping list
		local scrollFrame = CreateFrame("ScrollFrame", "TSMShoppingAutomaticModeScrollFrame", container, "FauxScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", 6, -33)
		scrollFrame:SetPoint("BOTTOMRIGHT", -28, 38)
		scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
			FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, Automatic.UpdateScrollFrame) 
		end)
		container.rows = {}
		for i=1, MAX_ROWS do
			local row = CreateFrame("Button", "TSMShoppingListRow"..i, container)
			local highlightTex = row:CreateTexture()
			highlightTex:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
			highlightTex:SetPoint("TOPRIGHT", row, "TOPRIGHT", 16, 0)
			highlightTex:SetPoint("BOTTOMLEFT")
			highlightTex:SetAlpha(0.7)
			row:SetHeight(ROW_HEIGHT)
			row:SetHighlightTexture(highlightTex)
			row:SetScript("OnEnter", function(self)
					if self.link then
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetHyperlink(self.link)
						GameTooltip:Show()
					end
				end)
			row:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
			if i > 1 then
				row:SetPoint("TOPLEFT", container.rows[i-1], "BOTTOMLEFT", 0, -2)
				row:SetPoint("TOPRIGHT", container.rows[i-1], "BOTTOMRIGHT", 0, -2)
			else
				row:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
				row:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -12, 0)
			end
			
			row.label = TSM.GUI:CreateLabel(row, "*", GameFontHighlight, -1, nil, {"BOTTOMLEFT", 10, 0}, {"TOPRIGHT", -100, 0}, "LEFT", "CENTER")
			row.price = TSM.GUI:CreateLabel(row, "*", GameFontHighlight, -1, nil, {"BOTTOMLEFT", 200, 0}, {"TOPRIGHT", 10, 0}, "LEFT", "CENTER")
			
			container.rows[i] = row
		end
		container.scrollFrame = scrollFrame
		
		TSM.GUI:AddHorizontalBar(container, -162)
		
		local btn = TSM.GUI:CreateButton(L["Skip Current Item"], container, "TSMShoppingAutomaticSkipButton", "UIPanelButtonTemplate", -1, nil, 25, {"BOTTOMLEFT", 6, 6}, {"BOTTOMRIGHT", -maxWidth/2, 6}, L["Skips the item currently being shopped for."])
		btn:SetScript("OnClick", function(self) Automatic:BoughtItem(Automatic.shoppingList[1].quantity) end)
		container.skipButton = btn
		
		local btn = TSM.GUI:CreateButton(L["Exit Automatic Mode"], container, "TSMShoppingAutomaticCancelButton", "UIPanelButtonTemplate", -1, nil, 25, {"BOTTOMLEFT", maxWidth/2, 6}, {"BOTTOMRIGHT", -6, 6}, L["Cancels automatic mode and allows manual searches to resume."])
		btn:SetScript("OnClick", function(self) Automatic:StopAutomaticMode() end)
		container.cancelButton = btn
		
		Automatic.autoFrame = container
	end
	
	Automatic.autoFrame:Show()
	Automatic:UpdateScrollFrame()
	Automatic:RegisterEvent("AUCTION_HOUSE_CLOSED")
end

function Automatic:UpdateScrollFrame()
	local scrollFrame = Automatic.autoFrame.scrollFrame
	local rows = Automatic.autoFrame.rows
	for _, row in ipairs(rows) do row:Hide() end

	-- Update the scroll bar
	FauxScrollFrame_Update(scrollFrame, #Automatic.shoppingList, MAX_ROWS-1, ROW_HEIGHT)
	
	-- Now display the correct rows
	local offset = FauxScrollFrame_GetOffset(scrollFrame)
	local displayIndex = 0
	
	for index, data in ipairs(Automatic.shoppingList) do
		if index >= offset and displayIndex < MAX_ROWS then
			displayIndex = displayIndex + 1
			local row = rows[displayIndex]
			if index == 1 then
				row:LockHighlight()
			else
				row:UnlockHighlight()
			end
			
			local name = TSM:GetItemName(data.itemID)
			local link = select(2, GetItemInfo(data.itemID)) or name or ""
			row.itemID = data.itemID
			row.link = select(2, GetItemInfo(data.itemID))
			row.label:SetText(link.."x"..data.quantity)
			
			if data.cost then
				row.price:SetText(TSM:FormatTextMoney(data.cost))
			else
				row.price:SetText("---")
			end
			row:Show()
		end
	end
end

function Automatic:QueryNextItem()
	local currentItem = Automatic.shoppingList[1]
	if not currentItem then debug("Empty Shopping List") return Automatic:StopAutomaticMode() end
	debug("item started", currentItem.mode, currentItem.itemID)
	
	TSM[currentItem.mode]:AutomaticQuery(currentItem)
end

function Automatic:BoughtItem(quantity)
	Automatic.shoppingList[1].quantity = Automatic.shoppingList[1].quantity - quantity
	if Automatic.shoppingList[1].quantity <= 0 then
		TSM[Automatic.shoppingList[1].mode]:StopAutomaticMode()
		tremove(Automatic.shoppingList, 1)
		Automatic:QueryNextItem()
		Automatic:UpdateScrollFrame()
		return true
	end
	Automatic:UpdateScrollFrame()
end

function Automatic:AUCTION_HOUSE_CLOSED()
	Automatic:UnregisterEvent("AUCTION_HOUSE_CLOSED")
	Automatic:StopAutomaticMode(true)
end

function Automatic:StopAutomaticMode(closed)
	if not TSM.automaticMode then return end
	if not Automatic.shoppingList[1] then
		TSM:Print(L["Done shopping."])
	else
		TSM[Automatic.shoppingList[1].mode]:StopAutomaticMode()
	end
	if not closed then TSM.Scan:StopScanning("Automatic") end
	TSM.automaticMode = false
	TSMAPI:UnlockSidebar()
	Automatic.autoFrame:Hide()
	wipe(Automatic.shoppingList)
end