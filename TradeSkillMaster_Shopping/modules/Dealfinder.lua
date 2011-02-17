local TSM = select(2, ...)
local Dealfinder = TSM:NewModule("Dealfinder", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local ROW_HEIGHT = 16
local MAX_ROWS = 13

local function debug(...)
	TSM:Debug(...)
end

function Dealfinder:OnEnable()
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Shopping", "shoppingDealfinder", "Interface\\Icons\\Spell_Shaman_SpectralTransformation", 
		L["Shopping - Dealfinding"], function(...) Dealfinder:LoadSidebar(...) end, Dealfinder.HideSidebar)
	Dealfinder.shoppingList = {}
	Dealfinder.totalSpent = 0
end

local function BuildConfigPage(parent)
	local maxWidth = parent:GetWidth() - 16
	
	local configFrame = CreateFrame("Frame", nil, parent)
	configFrame:SetPoint("TOPLEFT", 0, -70)
	configFrame:SetPoint("BOTTOMRIGHT", 0, 0)
	
	local eb = TSM.GUI:CreateEditBox(configFrame, L["Add Item to Dealfinder List:"], maxWidth, {"TOPLEFT", 8, 0}, L["You can either drag an item into this box, paste (shift click) an item link into this box, or enter an itemID."])
	eb:SetCallback("OnEnterPressed", function(self,_,value)
			value = value:trim()
			local name, link = GetItemInfo(value)
			if value == "" then
				self:SetText("")
				configFrame.itemPrice:SetDisabled(true)
				configFrame.fullStackCB:SetDisabled(true)
			elseif not link then
				self:SetText(L["<Invalid! See Tooltip>"])
				configFrame.itemPrice:SetDisabled(true)
				configFrame.fullStackCB:SetDisabled(true)
			else
				Dealfinder.newItem = {itemID=TSMAPI:GetItemID(link), name=name, link=link}
				configFrame.itemPrice:SetDisabled(false)
				local stackSize = select(8, GetItemInfo(Dealfinder.newItem.itemID))
				if stackSize > 1 then
					configFrame.fullStackCB:SetDisabled(false);
				else
					configFrame.fullStackCB:SetDisabled(true)
				end
			end
			self:ClearFocus()
		end)
	configFrame.itemName = eb
	
	local eb = TSM.GUI:CreateEditBox(configFrame, L["Max Price (Per 1 Item):"], maxWidth/2+80, {"TOPLEFT", 8, -40}, L["The max price (per 1 item) you want to have a Dealfinder scan buy something for. \n\nMust be entered in the form of \"#g#s#c\". For example \"5g24s98c\" would be 5 gold 24 silver 98 copper."])
	eb:SetCallback("OnEnterPressed", function(self,_,value)
			value = value:trim()
			configFrame.addButton:Disable()
			if value ~= "" then
				local money = TSM:UnformatTextMoney(value)
				if money then
					Dealfinder.newItem.price = money
					self:SetText(TSM:FormatTextMoney(money))
					configFrame.addButton:Enable()
				else
					Dealfinder.newItem.price = nil
					self:SetText(L["<Invalid! See Tooltip>"])
				end
			else
				Dealfinder.newItem.price = nil
				self:SetText("")
			end
			self:ClearFocus()
		end)
	eb:SetDisabled(true)
	configFrame.itemPrice = eb
	
	local chkBox = TSM.GUI:CreateCheckBox(configFrame, L["Even Stacks Only"], 150, {"TOPLEFT", maxWidth/2+40, -40}, L["If checked, when buying ore / herbs only stacks that are evenly divisible by 5 will be purchased."])
		chkBox:SetCallback("OnValueChanged", function(_,_,value) Dealfinder.newItem.evenStack = value end)
		chkBox:SetDisabled(true);
		configFrame.fullStackCB = chkBox
		
	local btn = TSM.GUI:CreateButton(L["Add Item"], configFrame, nil, "UIPanelButtonTemplate", -1, nil, 25, {"TOPLEFT", maxWidth/2+90, -58}, {"TOPRIGHT", -8, -68}, L["Scans for all items in your Dealfinder list."])
	btn:SetScript("OnClick", function(self)
			for index, data in pairs(TSM.db.global.DealfinderList) do
				if data.itemID == Dealfinder.newItem.itemID then
					TSM:Print(format(L["Item was already in the Dealfinder list. Price has been overriden (old price was %s)."], TSM:FormatTextMoney(tremove(TSM.db.global.DealfinderList, index).price)))
					break
				end
			end
			tinsert(TSM.db.global.DealfinderList, CopyTable(Dealfinder.newItem))
			wipe(Dealfinder.newItem)
			configFrame.itemName:SetText("")
			configFrame.itemPrice:SetText("")
			configFrame.itemPrice:SetDisabled(true)
			self:Disable()
			Dealfinder:UpdateScrollFrame()
		end)
	configFrame.addButton = btn
	
	TSM.GUI:AddHorizontalBar(configFrame, -85)

	-- Scroll frame to contain the shopping list
	local scrollFrame = CreateFrame("ScrollFrame", "TSMShoppingDealfinderScrollFrame", configFrame, "FauxScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 6, -92)
	scrollFrame:SetPoint("BOTTOMRIGHT", -28, 33)
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, Dealfinder.UpdateScrollFrame) 
	end)
	configFrame.rows = {}
	for i=1, MAX_ROWS do
		local row = CreateFrame("Button", nil, configFrame)
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
		row:SetScript("OnClick", function(self)
				Dealfinder.selectedItem = self.link
				self:LockHighlight()
				--configFrame.editButton:Enable()
				configFrame.deleteButton:Enable()
				Dealfinder:UpdateScrollFrame()
			end)
		
		if i > 1 then
			row:SetPoint("TOPLEFT", configFrame.rows[i-1], "BOTTOMLEFT", 0, -2)
			row:SetPoint("TOPRIGHT", configFrame.rows[i-1], "BOTTOMRIGHT", 0, -2)
		else
			row:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
			row:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -12, 0)
		end
		
		row.label = TSM.GUI:CreateLabel(row, "*", GameFontHighlight, -1, nil, {"BOTTOMLEFT", 10, 0}, {"TOPRIGHT", -100, 0}, "LEFT", "CENTER")
		row.price = TSM.GUI:CreateLabel(row, "*", GameFontHighlight, -1, nil, {"BOTTOMLEFT", 240, 0}, {"TOPRIGHT", 10, 0}, "LEFT", "CENTER")
		
		configFrame.rows[i] = row
	end
	configFrame.scrollFrame = scrollFrame
	
	TSM.GUI:AddHorizontalBar(configFrame, -325)
	
	-- local btn = TSM.GUI:CreateButton(L["Edit Selected Item"], configFrame, nil, "UIPanelButtonTemplate", -1, nil, 25, {"BOTTOMLEFT", 4, 5}, {"BOTTOMRIGHT", -maxWidth/2-8, 5}, L["Scans for all items in your Dealfinder list."])
	-- btn:SetScript("OnClick", function(self) end)
	-- btn:Disable()
	-- configFrame.editButton = btn
	
	local btn = TSM.GUI:CreateButton(L["Delete Selected Item"], configFrame, nil, "UIPanelButtonTemplate", -1, nil, 25, {"BOTTOMLEFT", maxWidth/2+8, 5}, {"BOTTOMRIGHT", -4, 5}, L["Scans for all items in your Dealfinder list."])
	btn:SetScript("OnClick", function(self)
			for i, data in pairs(TSM.db.global.DealfinderList) do
				if data.link == Dealfinder.selectedItem then
					tremove(TSM.db.global.DealfinderList, i)
					Dealfinder.selectedItem = nil
					Dealfinder:UpdateScrollFrame()
					return
				end
			end
		end)
	btn:Disable()
	configFrame.deleteButton = btn
	
	configFrame:Hide()
	parent.configFrame = configFrame
end

local function BuildScanPage(parent)
	local maxWidth = parent:GetWidth() - 16
	
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOPLEFT", 0, -130)
	frame:SetPoint("BOTTOMRIGHT")
	frame:Raise()
	frame:Hide()
	frame.EnableButtons = function(self)
		self.buyButton:Enable()
		self.skipButton:Enable()
	end
	frame.DisableButtons = function(self)
		self.buyButton:Disable()
		self.skipButton:Disable()
	end
	
	local label = TSM.GUI:CreateLabel(frame, "*", GameFontHighlight, 0, nil, maxWidth+4, {"TOP", 0, 20}, "CENTER")
	frame.buyLabel = label
	
	local btn = TSM.GUI:CreateButton(L["BUY"], frame, "TSMShoppingGeneralBuyButton", "UIPanelButtonTemplate", 8, nil, 40, {"TOPLEFT", 250, -20}, {"TOPRIGHT", -10, -20}, L["Buy the next cheapest auction."])
	btn:SetScript("OnClick", Dealfinder.BuyItem)
	frame.buyButton = btn
	
	local btn = TSM.GUI:CreateButton("SKIP", frame, "TSMShoppingGeneralSkipButton", "UIPanelButtonTemplate", -1, nil, 25, {"TOPLEFT", 250, -65}, {"TOPRIGHT", -10, -65}, L["Skip this auction."])
	btn:SetScript("OnClick", Dealfinder.SkipItem)
	frame.skipButton = btn
	
	local label = TSM.GUI:CreateLabel(frame, "*", GameFontHighlight, 2, nil, maxWidth+4, {"TOPLEFT", 10, -20}, "LEFT")
	frame.currentLabel = label
	
	TSM.GUI:AddHorizontalBar(frame, -100)
	
	local label = TSM.GUI:CreateLabel(frame, "", GameFontHighlight, 0, nil, maxWidth+4, {"TOP", 0, -120}, "LEFT")
	frame.infoLabel = label
	
	parent.buyFrame = frame
	
	local label = TSM.GUI:CreateLabel(parent, "*", GameFontHighlight, 0, nil, maxWidth+4, {"CENTER"}, "CENTER")
	label:Hide()
	parent.noAuctionsLabel = label
end

function Dealfinder:LoadSidebar(parentFrame)
	if not Dealfinder.frame then
		local maxWidth = parentFrame:GetWidth() - 16
	
		local container = CreateFrame("Frame", nil, parentFrame)
		container:SetAllPoints(parentFrame)
		container:Raise()
		
		container.EnableAll = function(self)
			self.scanButton:Enable()
			self.configButton:Enable()
		end
		
		container.DisableAll = function(self)
			self.scanButton:Disable()
			self.configButton:Disable()
		end
		
		container.title = TSM.GUI:CreateLabel(container, L["Shopping - Dealfinding"], GameFontHighlight, 0, "OUTLINE", maxWidth, {"TOP", 0, -10})
		TSM.GUI:AddHorizontalBar(container, -25)
		
		local btn = TSM.GUI:CreateButton(L["Run Dealfinder Scan"], container, "TSMShoppingDealfinderScanButton", "UIPanelButtonTemplate", -1, nil, 28, {"TOPLEFT", 6, -35}, {"TOPRIGHT", -((maxWidth/2)+8), -35}, L["Scans for all items in your Dealfinder list."])
		btn:SetScript("OnClick", function(self)
				self:LockHighlight()
				
				local container = self:GetParent()
				container.configButton:UnlockHighlight()
				container.configFrame:Hide()
				Dealfinder:RunDealfinderScan()
			end)
		container.scanButton = btn
		
		local btn = TSM.GUI:CreateButton(L["Configure Dealfinder List"], container, "TSMShoppingDealfinderConfigureButton", "UIPanelButtonTemplate", -1, nil, 28, {"TOPLEFT", (maxWidth/2)+8, -35}, {"TOPRIGHT", -6, -35}, L["Configures your Dealfinder list."])
		btn:SetScript("OnClick", function(self)
				self:LockHighlight()
				
				local container = self:GetParent()
				container.scanButton:UnlockHighlight()
				container.configFrame:Show()
				container.buyFrame:Hide()
				container.noAuctionsLabel:Hide()
				Dealfinder:UpdateScrollFrame()
			end)
		container.configButton = btn
		TSM.GUI:AddHorizontalBar(container, -65)
		
		BuildConfigPage(container)
		BuildScanPage(container)
		
		Dealfinder.frame = container
	end
	
	Dealfinder.frame.configButton:UnlockHighlight()
	Dealfinder.frame.scanButton:UnlockHighlight()
	Dealfinder.frame.configFrame.addButton:Disable()
	--Dealfinder.frame.configFrame.editButton:Disable()
	Dealfinder.frame.configFrame.deleteButton:Disable()
	Dealfinder.frame.configFrame:Hide()
	Dealfinder.frame.buyFrame:Hide()
	Dealfinder.frame:EnableAll()
	Dealfinder.frame:Show()
end

function Dealfinder:HideSidebar()
	Dealfinder.selectedItem = nil
	Dealfinder.frame:Hide()
end

function Dealfinder:UpdateScrollFrame()
	local scrollFrame = Dealfinder.frame.configFrame.scrollFrame
	local rows = Dealfinder.frame.configFrame.rows
	for _, row in ipairs(rows) do row:Hide() end

	-- Update the scroll bar
	FauxScrollFrame_Update(scrollFrame, #TSM.db.global.DealfinderList, MAX_ROWS-1, ROW_HEIGHT)
	
	-- Now display the correct rows
	local offset = FauxScrollFrame_GetOffset(scrollFrame)
	local displayIndex = 0
	
	for index, data in ipairs(TSM.db.global.DealfinderList) do
		if index >= offset and displayIndex < MAX_ROWS then
			displayIndex = displayIndex + 1
			local row = rows[displayIndex]
			
			if Dealfinder.selectedItem == data.link then
				row:LockHighlight()
			else
				row:UnlockHighlight()
			end
			
			row.link = data.link
			row.label:SetText(data.link)
			row.price:SetText(TSM:FormatTextMoney(data.price))
			row:Show()
		end
	end
end

function Dealfinder:RunDealfinderScan()
	local queue = {}
	for _, data in ipairs(TSM.db.global.DealfinderList) do
		tinsert(queue, {itemID=data.itemID, name=data.name})
	end
	
	TSM.Scan:StartScan(queue, "Dealfinder")
end

function Dealfinder:Process(scanData)
	local prices = {}
	local evenStacks = {};
	for _, data in ipairs(TSM.db.global.DealfinderList) do
		prices[data.itemID] = data.price
		evenStacks[data.itemID] = data.evenStack;
	end
	
	local auctions, totals = {}, {}
	for itemID, data in pairs(scanData) do
		for _, record in pairs(data.records) do
			if prices[itemID] and record.buyout <= prices[itemID] then
				if evenStacks[itemID] == nil then
					totals[itemID] = (totals[itemID] or 0) + record.quantity
					tinsert(auctions, {itemID=itemID, buyout=record.buyout, maxPrice=prices[itemID], quantity=record.quantity, page=record.page, stackSizeFlag=false, numItems=record.quantity})
				else
					if (record.quantity % 5) < 1 then
						totals[itemID] = (totals[itemID] or 0) + record.quantity
						tinsert(auctions, {itemID=itemID, buyout=record.buyout, maxPrice=prices[itemID], quantity=record.quantity, page=record.page, stackSizeFlag=false, numItems=record.quantity})
					end
				end
			end
		end
	end
	
	TSM:SortAuctions(auctions, {"itemID", "page", "buyout", "quanity"})
	auctions.totals = totals
	
	Dealfinder.frame.buyFrame:DisableButtons()
	Dealfinder.auctions = auctions
	if Dealfinder.auctions[1] then
		local nextAuction = CopyTable(Dealfinder.auctions[1])
		local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
		TSM.Scan:FindAuction(Dealfinder.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page)
	else
		Dealfinder.frame.buyFrame:Hide()
		Dealfinder.frame.noAuctionsLabel:Show()
		Dealfinder.frame:EnableAll()
		Dealfinder.frame.noAuctionsLabel:SetText(L["No auctions are under your Dealfinder prices."])
	end
end

function Dealfinder:ProcessCheapest(index)
	local cheapest = tremove(Dealfinder.auctions, 1)
	
	if not index or not cheapest then
		if Dealfinder.auctions[1] then
			local nextAuction = CopyTable(Dealfinder.auctions[1])
			local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
			TSM.Scan:FindAuction(Dealfinder.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page)
		else
			Dealfinder.frame.buyFrame:Hide()
			Dealfinder.frame:EnableAll()
			Dealfinder.frame.noAuctionsLabel:Show()
			Dealfinder.frame.noAuctionsLabel:SetText(L["No more auctions"])
		end
		return
	end
	
	Dealfinder.frame:EnableAll()
	local cQuantity = Dealfinder.auctions.totals[cheapest.itemID]
	local link = GetAuctionItemLink("list", index) or GetItemInfo(cheapest.itemID) or ""
	local _, _, quantity, _, _, _, _, _, buyout = GetAuctionItemInfo("list", index)
	local cCost = math.floor(buyout/quantity+0.5)
	if not buyout then
		return Dealfinder:ProcessCheapest()
	end
	local extraText = ""
	local percent = floor(((cheapest.maxPrice - cCost)/cheapest.maxPrice)*10000 + 0.5)/100
	if percent < 0 then
		extraText = format("|cffff0000"..L["%s%% above maximum price."].."|r", abs(percent))
	else
		extraText = format("|cff00ff00"..L["%s%% below maximum price."].."|r", percent)
	end
	
	Dealfinder.frame.buyFrame:Show()
	Dealfinder.frame.buyFrame:EnableButtons()
	Dealfinder.frame.buyFrame.buyLabel:SetText(format(L["%s below your Dealfinding price."], cQuantity.."x"..link))
	Dealfinder.frame.buyFrame.currentLabel:SetText(link.."x"..quantity.." @ "..TSM:FormatTextMoney(buyout).."\n\n(~"..TSM:FormatTextMoney(cCost).." "..L["per item"]..")\n\n"..extraText)
	Dealfinder.currentItem = {itemID=cheapest.itemID, index=index, buyout=buyout, quantity=quantity, numItems=cheapest.numItems}
end

function Dealfinder:BuyItem()
	debug("BUY11")
	debug(Dealfinder.currentItem.index)
	Dealfinder.totalSpent = Dealfinder.totalSpent + Dealfinder.currentItem.buyout
	Dealfinder.frame.buyFrame.infoLabel:SetText(L["Total Spent this Session:"].." "..TSM:FormatTextMoney(Dealfinder.totalSpent))
	Dealfinder.auctions.totals[Dealfinder.currentItem.itemID] = Dealfinder.auctions.totals[Dealfinder.currentItem.itemID] - Dealfinder.currentItem.quantity
	PlaceAuctionBid("list", Dealfinder.currentItem.index, Dealfinder.currentItem.buyout)
	
	if Dealfinder.auctions[1] then
		Dealfinder:WaitForEvent()
	else
		Dealfinder.frame.buyFrame:Hide()
		Dealfinder.frame:EnableAll()
		Dealfinder.frame.noAuctionsLabel:Show()
		Dealfinder.frame.noAuctionsLabel:SetText(L["No more auctions."])
	end
end

function Dealfinder:WaitForEvent()
	debug("START WAIT")
	Dealfinder.frame.buyFrame:DisableButtons()
	Dealfinder.waitingFor = {chatMsg = true, listUpdate = true}
	Dealfinder:RegisterEvent("CHAT_MSG_SYSTEM", function(_, msg)
			local targetMsg = gsub(ERR_AUCTION_BID_PLACED, "%%s", "")
			if msg:match(targetMsg) then
				Dealfinder:UnregisterEvent("CHAT_MSG_SYSTEM")
				Dealfinder.waitingFor.chatMsg = false
				if not Dealfinder.waitingFor.listUpdate then
					debug("chat msg enable")
					local nextAuction = CopyTable(Dealfinder.auctions[1])
					local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
					TSMAPI:CreateTimeDelay("shoppingFindNext", 0.1, function() TSM.Scan:FindAuction(Dealfinder.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page) end)
				else
					debug("waiting on list update")
				end
			end
		end)
		
	local nextAuction = Dealfinder.auctions[1]
	local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
	Dealfinder:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", function()
			Dealfinder:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			Dealfinder.waitingFor.listUpdate = false
			if not Dealfinder.waitingFor.chatMsg then
				debug("list update enable")
				local nextAuction = Dealfinder.auctions[1]
				local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
				TSMAPI:CreateTimeDelay("shoppingFindNext", 0.3, function() TSM.Scan:FindAuction(Dealfinder.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page) end)
			else
				debug("waiting on chat msg")
			end
		end)
end

function Dealfinder:SkipItem()
	debug("SKIP")
	Dealfinder.auctions.totals[Dealfinder.currentItem.itemID] = Dealfinder.auctions.totals[Dealfinder.currentItem.itemID] - Dealfinder.currentItem.quantity
	Dealfinder.frame.buyFrame:DisableButtons()
	if Dealfinder.auctions[1] then
		local nextAuction = CopyTable(Dealfinder.auctions[1])
		local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
		TSM.Scan:FindAuction(Dealfinder.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page)
	else
		Dealfinder.frame.buyFrame:Hide()
		Dealfinder.frame.noAuctionsLabel:Show()
		Dealfinder.frame:EnableAll()
		Dealfinder.frame.noAuctionsLabel:SetText(L["No more auctions."])
	end
end