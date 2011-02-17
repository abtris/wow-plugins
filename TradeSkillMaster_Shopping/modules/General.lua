local TSM = select(2, ...)
local General = TSM:NewModule("General", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

local function debug(...)
	TSM:Debug(...)
end

function General:OnEnable()
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Shopping", "shoppingGeneral", "Interface\\Icons\\Inv_Misc_Token_ArgentDawn", 
		L["Shopping - General Buying"], function(...) General:LoadSidebar(...) end, General.HideSidebar)
	General.selection = {}
	General.auctions = {}
end

function General:LoadSidebar(parentFrame)
	General.currentItem = {}
	
	if not General.frame then
		local maxWidth = parentFrame:GetWidth() - 16
		
		local container = CreateFrame("Frame", nil, parentFrame)
		container:SetAllPoints(parentFrame)
		container:Raise()
		container.disableAll = function()
			container.searchBox:SetDisabled(true)
			container.goButton:Disable()
			container.maxPrice:SetDisabled(true)
			container.maxQuantity:SetDisabled(true)
		end
		container.EnableAll = function()
			container.searchBox:SetDisabled(false)
			container.goButton:Enable()
			container.maxPrice:SetDisabled(false)
			container.maxQuantity:SetDisabled(false)
		end
		
		container.title = TSM.GUI:CreateLabel(container, L["Shopping - General Buying"], GameFontHighlight, 0, "OUTLINE", maxWidth, {"TOP", 0, -12})
		TSM.GUI:AddHorizontalBar(container, -30)
		
		local eb = TSM.GUI:CreateEditBox(container, L["Name of item to serach for:"], 260, {"TOPLEFT", 8, -40}, L["What would you like to buy?"])
		eb:SetCallback("OnEnterPressed", function(self,_,value)
				value = value:trim()
				if value ~= "" then
					General.selection.filter = value
					General.frame.goButton:Enable()
				else
					General.selection.filter = nil
					General.frame.goButton:Disable()
				end
				if self.ClearFocus then self:ClearFocus() end
			end)
		container.searchBox = eb
		
		local btn = TSM.GUI:CreateButton(L["GO"], container, "TSMShoppingGeneralStartButton", "UIPanelButtonTemplate", -1, nil, 25, {"TOPLEFT", 271, -58}, {"TOPRIGHT", -8, -58}, L["Start buying!"])
		btn:SetScript("OnClick", function()
				General.frame.buyFrame:Hide()
				General.totalSpent = 0
				General.numItems = 0
				General.filter = General.selection.filter
				General.maxPrice = General.selection.maxPrice
				General.maxQuantity = General.selection.maxQuantity
				wipe(General.auctions)
				General.frame.noAuctionsLabel:Hide()
				General:RunScan()
			end)
		container.goButton = btn
		
		local eb = TSM.GUI:CreateEditBox(container, L["Max Price (optional):"], maxWidth/2, {"TOPLEFT", 8, -80}, L["The most you want to pay for something. \n\nMust be entered in the form of \"#g#s#c\". For example \"5g24s98c\" would be 5 gold 24 silver 98 copper."])
		eb:SetCallback("OnEnterPressed", function(self,_,value)
				value = value:trim()
				if value ~= "" then
					local money = TSM:UnformatTextMoney(value)
					if money then
						General.selection.maxPrice = money
						self:SetText(TSM:FormatTextMoney(money))
					else
						General.selection.maxPrice = nil
						self:SetText(L["<Invalid! See Tooltip>"])
					end
				else
					General.selection.maxPrice = nil
					self:SetText("")
				end
				self:ClearFocus()
			end)
		container.maxPrice = eb
		
		local eb = TSM.GUI:CreateEditBox(container, L["Quantity (optional)"], maxWidth/2, {"TOPLEFT", 8+(maxWidth/2), -80}, L["How many you want to buy."])
		eb:SetCallback("OnEnterPressed", function(self,_,value)
				value = value:trim()
				if tonumber(value) then
					General.selection.maxQuantity = tonumber(value)
					self:SetText(value)
				elseif value == "" then
					General.selection.maxQuantity = nil
					self:SetText("")
				else
					General.selection.maxQuantity = nil
					self:SetText("<Invalid Number>")
				end
				self:ClearFocus()
			end)
		container.maxQuantity = eb
		
		container.automaticLabel = TSM.GUI:CreateLabel(container, L["Manual controls disabled when Shopping in automatic mode.\n\nClick on the \"Exit Automatic Mode\" button to enable manual controls."], GameFontNormal, 0, nil, maxWidth, {"TOP", 0, -50})
		container.automaticLabel:Hide()
		
		TSM.GUI:AddHorizontalBar(container, -130)
		
		local frame = CreateFrame("Frame", nil, container)
		frame:SetPoint("TOPLEFT", 0, -150)
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
		
		local label = TSM.GUI:CreateLabel(frame, "*", GameFontHighlight, 0, nil, maxWidth+4, {"TOP", 0, 3}, "CENTER")
		frame.buyLabel = label
		
		local btn = TSM.GUI:CreateButton(L["BUY"], frame, "TSMShoppingGeneralBuyButton", "UIPanelButtonTemplate", 8, nil, 40, {"TOPLEFT", 250, -20}, {"TOPRIGHT", -10, -20}, L["Buy the next cheapest auction."])
		btn:SetScript("OnClick", General.BuyItem)
		frame.buyButton = btn
		
		local btn = TSM.GUI:CreateButton(L["SKIP"], frame, "TSMShoppingGeneralSkipButton", "UIPanelButtonTemplate", -1, nil, 25, {"TOPLEFT", 250, -65}, {"TOPRIGHT", -10, -65}, L["Skip this auction."])
		btn:SetScript("OnClick", General.SkipItem)
		frame.skipButton = btn
		
		local label = TSM.GUI:CreateLabel(frame, "*", GameFontHighlight, 2, nil, maxWidth+4, {"TOPLEFT", 10, -20}, "LEFT")
		frame.currentLabel = label
		
		TSM.GUI:AddHorizontalBar(frame, -100)
		
		local label = TSM.GUI:CreateLabel(frame, "", GameFontHighlight, 0, nil, maxWidth+4, {"TOP", 0, -120}, "LEFT")
		frame.infoLabel = label
		
		container.buyFrame = frame
		
		local label = TSM.GUI:CreateLabel(container, "*", GameFontHighlight, 0, nil, maxWidth+4, {"CENTER"}, "CENTER")
		label:Hide()
		container.noAuctionsLabel = label
		
		General.frame = container
	end
	
	General.frame:Show()
end

function General:HideSidebar()
	General.frame:Hide()
	wipe(General.auctions)
	wipe(General.currentItem)
	General.frame.buyFrame:Hide()
	General.frame.searchBox:SetText("")
	General.frame.searchBox:Fire("OnEnterPressed", "")
	General.frame.maxQuantity:SetText("")
	General.frame.maxQuantity:Fire("OnEnterPressed", "")
	General.frame.maxPrice:SetText("")
	General.frame.maxPrice:Fire("OnEnterPressed", "")
	General.frame:Hide()
end

function General:RunScan()
	local queue = {General.filter}
	General.frame.disableAll()
	TSM.Scan:StartScan(queue, "General")
end

function General:Process(scanData)
	local itemID, data, foundMatch
	local count = 0
	for sID, sData in pairs(scanData) do
		count = count + 1
		if strlower(GetItemInfo(sID) or "") == strlower(General.filter) then
			itemID = sID
			data = sData
			foundMatch = true
		elseif count == 1 then
			itemID = sID
			data = sData
		end
	end
		
	if count > 1 and not foundMatch then
		General.frame:EnableAll()
		General.frame.noAuctionsLabel:Show()
		General.frame.noAuctionsLabel:SetText(format(L["No auctions matched \"%s\""], General.filter))
		if General.automaticMode then
			TSM.Automatic.autoFrame.skipButton:Enable()
		end
		return
	elseif count == 0 then
		General.frame:EnableAll()
		General.frame.noAuctionsLabel:Show()
		General.frame.noAuctionsLabel:SetText(L["No auctions found."])
		if General.automaticMode then
			TSM.Automatic.autoFrame.skipButton:Enable()
		end
		return
	end
	
	local auctions = {}
	for _, record in pairs(data.records) do
		tinsert(auctions, {itemID=itemID, buyout=record.buyout, quantity=record.quantity, page=record.page, stackSizeFlag=false, numItems=record.quantity})
	end
	debug("NUM AUCTIONS:", #auctions)
	TSM:SortAuctions(auctions, {"buyout", "numItems", "page", "quantity"})
	
	local currentCost = 0
	auctions.totalQuantity = {}
	for _, data in ipairs(auctions) do
		if data.buyout > currentCost then
			currentCost = data.buyout
			auctions.totalQuantity[currentCost] = data.quantity
		else
			auctions.totalQuantity[currentCost] = auctions.totalQuantity[currentCost] + data.quantity
		end
	end
	General.auctions = auctions
	
	General.frame.buyFrame:DisableButtons()
	General.auctions = auctions
	if General.auctions[1] then
		local nextAuction = CopyTable(General.auctions[1])
		local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
		TSM.Scan:FindAuction(General.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page)
	else
		debug("NO FIRST AUCTION")
		General.frame.buyFrame:Hide()
		General.frame.noAuctionsLabel:Show()
		General.frame.noAuctionsLabel:SetText(L["No auctions for this item."])
		if not General.automaticMode then
			General.frame:EnableAll()
		else
			TSM.Automatic.autoFrame.skipButton:Enable()
		end
	end
end

function General:ProcessCheapest(index)
	debug("Process", index)
	local cheapest = tremove(General.auctions, 1)
	
	if not index or not cheapest then
		local nextAuction = General.auctions[1]
		if not nextAuction then
			local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
			TSM.Scan:FindAuction(General.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page)
		else
			General.frame.buyFrame:Hide()
			General.frame.noAuctionsLabel:Show()
			General.frame.noAuctionsLabel:SetText(L["No more auctions for this item."])
			if not General.automaticMode then
				General.frame:EnableAll()
			else
				TSM.Automatic.autoFrame.skipButton:Enable()
			end
		end
		return
	end
	
	if not General.automaticMode then
		General.frame:EnableAll()
	else
		TSM.Automatic.autoFrame.skipButton:Enable()
	end
	
	local link = GetAuctionItemLink("list", index)
	local _, _, quantity, _, _, _, _, _, buyout = GetAuctionItemInfo("list", index)
	local cBuyout = buyout/quantity
	local extraText = ""
	
	if General.maxPrice then
		local percent = floor(((General.maxPrice - cBuyout)/General.maxPrice)*10000 + 0.5)/100
		if percent < 0 then
			extraText = format("|cffff0000"..L["%s%% above maximum price."].."|r", abs(percent))
		else
			extraText = format("|cff00ff00"..L["%s%% below maximum price."].."|r", percent)
		end
	end
	
	General.frame.buyFrame:Show()
	General.frame.buyFrame:EnableButtons()
	General.frame.buyFrame.buyLabel:SetText(format(L["Buying: %s(%s at this price)"], link, General.auctions.totalQuantity[cBuyout]))
	General.frame.buyFrame.currentLabel:SetText(format(L["%s @ %s(%s per)"]..extraText, link.."x"..quantity.."\n\n", TSM:FormatTextMoney(buyout), TSM:FormatTextMoney(cBuyout)))
	General.currentItem = {itemID=cheapest.itemID, index=index, buyout=buyout, cost=cBuyout, quantity=quantity, numItems=cheapest.numItems, original=CopyTable(cheapest)}
end

function General:BuyItem()
	debug("BUY")
	local _, _, quantity, _, _, _, _, _, buyout = GetAuctionItemInfo("list", General.currentItem.index)
	debug(General.currentItem.index, General.currentItem.itemID, buyout, General.currentItem.buyout, quantity, General.currentItem.quantity)
	if abs(buyout - General.currentItem.buyout) > 1 or abs(quantity - General.currentItem.quantity) > 0.5 then
		General.frame.buyFrame:DisableButtons()
		TSM:Print("The auction house has changed in the time between the last scan and you clicking this button. The item failed to be purchased. Try again.")
		TSM.Scan:FindAuction(function(_,index) General.currentItem.index = index General.frame.buyFrame:EnableButtons() end, General.currentItem.itemID, General.currentItem.quantity, General.currentItem.buyout)
		return
	end
	General.totalSpent = General.totalSpent + General.currentItem.buyout
	General.numItems = General.numItems + General.currentItem.numItems
	General.frame.buyFrame.infoLabel:SetText(format(L["Total Spent this Session: %sItems Bought This Session: %sAverage Cost Per Item this Session: %s"], TSM:FormatTextMoney(General.totalSpent).."\n\n", General.numItems.."\n\n", TSM:FormatTextMoney(General.totalSpent/General.numItems)))
	PlaceAuctionBid("list", General.currentItem.index, General.currentItem.buyout)
	General.auctions.totalQuantity[General.currentItem.cost] = General.auctions.totalQuantity[General.currentItem.cost] - General.currentItem.quantity
	if General.automaticMode and TSM.Automatic:BoughtItem(General.currentItem.numItems) then
		return
	elseif General.maxQuantity and General.numItems >= General.maxQuantity then
		General.frame.buyFrame:Hide()
		General.frame:EnableAll()
		General.frame.noAuctionsLabel:Show()
		General.frame.noAuctionsLabel:SetText(L["Bought at least the max quantity set for this item."])
	elseif General.auctions[1] then
		General:WaitForEvent()
	else
		General.frame.buyFrame:Hide()
		General.frame.noAuctionsLabel:Show()
		General.frame.noAuctionsLabel:SetText(L["No more auctions for this item."])
		if not General.automaticMode then
			General.frame:EnableAll()
		else
			TSM.Automatic.autoFrame.skipButton:Enable()
		end
	end
end

function General:WaitForEvent()
	debug("START WAIT")
	General.frame.buyFrame:DisableButtons()
	General.waitingFor = {chatMsg = true, listUpdate = true}
	General:RegisterEvent("CHAT_MSG_SYSTEM", function(_, msg)
			local targetMsg = gsub(ERR_AUCTION_BID_PLACED, "%%s", "")
			if msg:match(targetMsg) then
				General:UnregisterEvent("CHAT_MSG_SYSTEM")
				General.waitingFor.chatMsg = false
				if not General.waitingFor.listUpdate then
					debug("chat msg enable")
					local nextAuction = General.auctions[1]
					local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
					TSMAPI:CreateTimeDelay("shoppingFindNextGeneral", 0.1, function() TSM.Scan:FindAuction(General.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page) end)
				else
					debug("waiting on list update")
				end
			end
		end)
		
	local nextAuction = General.auctions[1]
	local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
	General:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", function()
			General:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			General.waitingFor.listUpdate = false
			if not General.waitingFor.chatMsg then
				debug("list update enable")
				local nextAuction = General.auctions[1]
				local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
				TSMAPI:CreateTimeDelay("shoppingFindNextGeneral", 0.3, function() TSM.Scan:FindAuction(General.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page) end)
			else
				debug("waiting on chat msg")
			end
		end)
end

function General:SkipItem()
	debug("SKIP")
	foreach(General.currentItem, function(i, v) if type(v) == "table" then v = "table:XXXXX" end debug(i, v) end)
	General.frame.buyFrame:DisableButtons()
	General.auctions.totalQuantity[General.currentItem.cost] = General.auctions.totalQuantity[General.currentItem.cost] - General.currentItem.quantity
	if General.auctions[1] then
		local nextAuction = CopyTable(General.auctions[1])
		local buyout = floor(nextAuction.buyout*nextAuction.quantity+0.5)
		TSM.Scan:FindAuction(General.ProcessCheapest, nextAuction.itemID, nextAuction.quantity, buyout, nextAuction.page)
	else
		General.frame.buyFrame:Hide()
		General.frame.noAuctionsLabel:Show()
		General.frame.noAuctionsLabel:SetText(L["No more auctions for this item."])
		if not General.automaticMode then
			General.frame:EnableAll()
		else
			TSM.Automatic.autoFrame.skipButton:Enable()
		end
	end
end

function General:AutomaticQuery(item)
	TSMAPI:SelectRemoteFunction("shoppingGeneral", true)
	local itemName = TSM:GetItemName(item.itemID)
	
	General.frame.searchBox.frame:Show()
	General.frame.searchBox:SetDisabled(false)
	General.frame.searchBox:SetText(itemName)
	General.frame.searchBox:Fire("OnEnterPressed", itemName)
	General.frame.maxQuantity:SetDisabled(false)
	General.frame.maxQuantity:SetText(item.quantity)
	General.frame.maxQuantity:Fire("OnEnterPressed", ""..item.quantity) -- must be cast to a string
	General.frame.goButton:Click()
	General:StartAutomaticMode()
end

function General:StartAutomaticMode()
	if General.automaticMode then return end
	General.automaticMode = true

	General.frame.automaticLabel:Show()
	General.frame.goButton:Disable()
	General.frame.goButton:Hide()
	General.frame.searchBox:SetDisabled(true)
	General.frame.searchBox.frame:Hide()
	General.frame.maxPrice:SetDisabled(true)
	General.frame.maxPrice.frame:Hide()
	General.frame.maxQuantity:SetDisabled(true)
	General.frame.maxQuantity.frame:Hide()
end

function General:StopAutomaticMode()
	if not General.automaticMode then return end
	General.automaticMode = nil
	TSMAPI:SelectRemoteFunction("shoppingGeneral", true)

	General.frame.buyFrame:Hide()
	General.frame.automaticLabel:Hide()
	General.frame.goButton:Enable()
	General.frame.goButton:Show()
	General.frame.searchBox:SetDisabled(false)
	General.frame.searchBox.frame:Show()
	General.frame.searchBox:SetText("")
	General.frame.maxPrice:SetDisabled(false)
	General.frame.maxPrice.frame:Show()
	General.frame.maxQuantity:SetDisabled(false)
	General.frame.maxQuantity.frame:Show()
	General.frame.maxQuantity:SetText("")
end