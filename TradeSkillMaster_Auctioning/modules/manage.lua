-- This module is to contain things that are common between other modules.
-- Mostly stuff in common between scanning and posting such as the "<Post/Cancel> Auction" Frame

local TSMAuc = select(2, ...)
local Manage = TSMAuc:NewModule("Manage", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0")

function Manage:OnInitialize()
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Auctioning", "postScan", "Interface\\Icons\\Spell_Holy_AvengineWrath",
		L["Auctioning - Post"], function(...) Manage:LoadSidebarFrame("Post", ...) end, function() Manage:HideSidebarFrame("Post") end)
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Auctioning", "cancelScan", "Interface\\Icons\\Spell_Nature_TimeStop",
		L["Auctioning - Cancel"], function(...)Manage:LoadSidebarFrame("Cancel", ...) end, function() Manage:HideSidebarFrame("Cancel") end)
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Auctioning", "cancelAllScan", "Interface\\Icons\\Inv_Misc_PocketWatch_01", 
		L["Auctioning - Cancel All"], function(...) Manage:LoadCancelAll(...) end, Manage.HideCancelAll)
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_Auctioning", "auctioningOther", "Interface\\Icons\\Achievement_BG_win_AB_X_times", 
		L["Auctioning - Status/Config"], function(...) Manage:LoadOther(...) end, Manage.HideOther)
		
	Manage:RegisterEvent("AUCTION_HOUSE_SHOW")
end

local function ApplyTexturesToButton(btn, isOpenCloseButton)
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
		highlightTex:SetVertexColor(0.5, 0.5, 0.5, 0.7)
		pressedTex:SetTexCoord(0.0256, 0.743, 0.017, 0.158)
		btn:SetPushedTextOffset(0, -2)
	end
	
	btn:SetNormalTexture(normalTex)
	btn:SetDisabledTexture(disabledTex)
	btn:SetHighlightTexture(highlightTex)
	btn:SetPushedTexture(pressedTex)
end

-- Tooltips!
local function ShowTooltip(self)
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	elseif self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	else
		GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetText(self.frame.tooltip, 1, 1, 1, 1, true)
		GameTooltip:Show()
	end
end

local function HideTooltip()
	GameTooltip:Hide()
end

local function CreateButton(text, parentFrame, frameName, inheritsFrame, width, height, point, arg1, arg2)
	local btn = CreateFrame("Button", frameName, parentFrame, inheritsFrame)
	btn:SetHeight(height or 0)
	btn:SetWidth(width or 0)
	btn:SetPoint(unpack(point))
	btn:SetText(text)
	btn:Raise()
	btn:GetFontString():SetPoint("CENTER")
	local tFile, tSize = GameFontHighlight:GetFont()
	btn:GetFontString():SetFont(tFile, tSize, "OUTLINE")
	btn:GetFontString():SetTextColor(1, 1, 1, 1)
	if type(arg1) == "string" then
		btn.tooltip = arg1
		btn:SetScript("OnEnter", ShowTooltip)
		btn:SetScript("OnLeave", HideTooltip)
	elseif type(arg2) == "string" then
		btn:SetPoint(unpack(arg1))
		btn.tooltip = arg2
		btn:SetScript("OnEnter", ShowTooltip)
		btn:SetScript("OnLeave", HideTooltip)
	end
	btn:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 18,
			insets = {left = 0, right = 0, top = 0, bottom = 0},
		})
	btn:SetScript("OnDisable", function(self) self:GetFontString():SetTextColor(0.5, 0.5, 0.5, 1) end)
	btn:SetScript("OnEnable", function(self) self:GetFontString():SetTextColor(1, 1, 1, 1) end)
	ApplyTexturesToButton(btn)
	return btn
end

local function AddHorizontalBar(parent, point1, point2)
	local barFrame = CreateFrame("Frame", nil, parent)
	barFrame:SetPoint(unpack(point1))
	barFrame:SetPoint(unpack(point2))
	barFrame:SetHeight(8)
	local horizontalBarTex = barFrame:CreateTexture()
	horizontalBarTex:SetAllPoints(barFrame)
	horizontalBarTex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	horizontalBarTex:SetTexCoord(0.577, 0.683, 0.145, 0.309)
	horizontalBarTex:SetVertexColor(0, 0, 0.7, 1)
end

local function CreateLabel(frame, text, fontObject, fontSizeAdjustment, fontStyle, p1, p2, justifyH, justifyV)
	local label = frame:CreateFontString(nil, "OVERLAY", fontObject)
	local tFile, tSize = fontObject:GetFont()
	label:SetFont(tFile, tSize+fontSizeAdjustment, fontStyle)
	if type(p1) == "table" then
		label:SetPoint(unpack(p1))
	elseif type(p1) == "number" then
		label:SetWidth(p1)
	end
	if type(p2) == "table" then
		label:SetPoint(unpack(p2))
	elseif type(p2) == "number" then
		label:SetHeight(p2)
	end
	if justifyH then
		label:SetJustifyH(justifyH)
	end
	if justifyV then
		label:SetJustifyV(justifyV)
	end
	label:SetText(text)
	label:SetTextColor(1, 1, 1, 1)
	return label
end

function Manage:LoadSidebarFrame(sType, frame)
	local isCancelAll = false
	if sType == "CancelAll" then
		isCancelAll = true
		sType = "Cancel"
	end
	if not Manage[strlower(sType).."Frame"] then
		local container = CreateFrame("Frame", nil, frame)
		container:SetAllPoints(frame)
		container:Raise()
		
		container.label = CreateLabel(container, L["Auctioning - "..sType.." Scan"], GameFontHighlight, 0, "OUTLINE", 300, {"TOP", 0, -20})
		Manage["done"..sType.."ing"] = CreateLabel(container, L["Done "..sType.."ing"], GameFontHighlightLarge, 0, nil, 200, {"CENTER"}, "CENTER", "TOP")
		
		Manage[strlower(sType).."Scanning"] = CreateLabel(container, L["Scanning..."], GameFontHighlightLarge, 0, nil, 200, {"CENTER"}, "CENTER", "TOP")
		
		local btn = CreateButton(L["Stop Scanning"], container, nil, "UIPanelButtonTemplate",
			(frame:GetWidth()-200), 30, {"BOTTOM", 0, 50}, L["Stop the current scan."])
		btn:SetScript("OnClick", function() TSMAuc[sType]["Stop" .. sType .. "ing"]() TSMAuc.Scan:StopScanning(true) end)
		Manage["stop"..sType.."ingButton"] = btn
		Manage[strlower(sType).."Frame"] = container
	end
	
	Manage["done"..sType.."ing"]:Hide()
	Manage[strlower(sType).."Scanning"]:Hide()
	Manage[strlower(sType).."Frame"]:Show()
	if not isCancelAll then
		TSMAuc[sType]:StartScan()
	end
end

function Manage:HideSidebarFrame(sType)
	Manage[strlower(sType).."Frame"]:Hide()
end

function Manage:LoadCancelAll(frame)
	if not Manage.cancelAllFrame then
		local container = CreateFrame("Frame", nil, frame)
		container:SetAllPoints(frame)
		container:Raise()
		
		container.title = CreateLabel(container, L["Auctioning - Cancel All Scan"], GameFontHighlight, 0, "OUTLINE", 300, {"TOP", 0, -20})
		AddHorizontalBar(container, {"TOPLEFT", 4, -50}, {"TOPRIGHT", -4, -50})
		
		local width = (container:GetWidth()-12)/2
		
		local text1 = L["Cancel Match - Cancel all items that match the specified filter."]
		container.label1 = CreateLabel(container, text1, GameFontNormal, 0, nil, {"BOTTOMRIGHT", container, "TOPRIGHT", -10, -110}, {"TOPLEFT", 10, -80}, "LEFT", "CENTER")
		local editBox = AceGUI:Create("TSMEditBox")
		editBox:SetWidth(width)
		editBox:SetLabel(L["Cancel Items Matching:"])
		editBox.frame:SetParent(container)
		editBox.frame:SetPoint("TOPLEFT", 6, -120)
		editBox.frame:Show()
		editBox.frame.tooltip = L["Any of your auctions which match this text will be canceled. For example, if you enter \"glyph\", any item with \"glyph\" in its name will be canceled (even ones not in a group)."]
		editBox:SetCallback("OnEnterPressed", function(self, _, value)
				value = value:trim()
				if not value or value == "" then
					container.matchButton:Disable()
					container.matchButton.match = nil
				else
					container.matchButton:Enable()
					container.matchButton.match = value
				end
			end)
		editBox:SetCallback("OnEnter", ShowTooltip)
		editBox:SetCallback("OnLeave", HideTooltip)
		container.matchEditBox = editBox
		AddHorizontalBar(container, {"TOPLEFT", 4, -50}, {"TOPRIGHT", -4, -50})
		
		local btn = CreateButton(L["Cancel Matching Items"], container, nil, "UIPanelButtonTemplate",
			width, 27, {"TOPRIGHT", -6, -137}, L["Cancel all auctions according to the filter."])
		btn:SetScript("OnClick", function(self)
				if self.match then
					Manage.cancelAllFrame:Hide()
					Manage:LoadSidebarFrame("CancelAll", frame)
					TSMAuc.Cancel:CancelMatch(self.match)
				end
			end)
		btn:Disable()
		container.matchButton = btn
		
		
		local text2 = L["Cancel All - Cancel all active items, those in a specified group, or those with a specified time left."]
		container.label2 = CreateLabel(container, text2, GameFontNormal, 0, nil, {"BOTTOMRIGHT", container, "TOPRIGHT", -10, -250}, {"TOPLEFT", 10, -220}, "LEFT", "CENTER")
		local editBox = AceGUI:Create("TSMEditBox")
		editBox:SetWidth(width)
		editBox:SetLabel(L["Cancel All Filter:"])
		editBox.frame:SetParent(container)
		editBox.frame:SetPoint("TOPLEFT", 6, -260)
		editBox.frame:Show()
		editBox:SetCallback("OnEnterPressed", function(self, _, value) 
				value = value:trim()
				if not value or value == "" then
					container.allButton.filter = nil
				else
					container.allButton.filter = value
				end
			end)
		editBox:SetCallback("OnEnter", ShowTooltip)
		editBox:SetCallback("OnLeave", HideTooltip)
		editBox.frame.tooltip = L["You can enter a group name to cancel every item in that group, 12 or 2 to cancel every item with " ..
				"less than 12/2 hours left, enter a formatted price (ex. 1g50s) to cancel everything below that price, " ..
				"or leave the field blank to cancel every item you have on the auction house (even ones not in a group)."]
		container.allEditBox = editBox
		AddHorizontalBar(container, {"TOPLEFT", 4, -200}, {"TOPRIGHT", -4, -200})
		
		local btn = CreateButton(L["Cancel All Items"], container, nil, "UIPanelButtonTemplate", width, 27, {"TOPRIGHT", -6, -277},
			L["Cancel all auctions according to the filter. If the editbox is blank, everything will be canceled."])
		btn:SetScript("OnClick", function(self)
				Manage.cancelAllFrame:Hide()
				Manage:LoadSidebarFrame("CancelAll", frame)
				TSMAuc.Cancel:CancelAll(self.filter)
			end)
		btn:Enable()
		container.allButton = btn
		
		Manage.cancelAllFrame = container
	end
	
	Manage.cancelAllFrame:Show()
end

function Manage:HideCancelAll()
	Manage.cancelAllFrame:Hide()
	if Manage.cancelFrame then Manage.cancelFrame:Hide() end
end

function Manage:LoadOther(frame)
	if not Manage.otherFrame then
		local container = CreateFrame("Frame", nil, frame)
		container:SetAllPoints(frame)
		container:Raise()
		
		container.title = CreateLabel(container, L["Auctioning - Status Scan / Config"], GameFontHighlight, 0, "OUTLINE", 300, {"TOP", 0, -20})
		
		AddHorizontalBar(container, {"TOPLEFT", 4, -50}, {"TOPRIGHT", -4, -50})
		
		-- status scan button
		local btn = CreateButton(L["Run Status Scan"], container, nil, "UIPanelButtonTemplate", nil, 25,
		{"TOPLEFT", 50, -120}, {"TOPRIGHT", -50, -120}, L["Does a status scan that helps to identify auctions you can buyout to raise the price of a group you're managing.\n\nThis will NOT automatically buy items for you, all it tells you is the lowest price and how many are posted."])
		btn:SetScript("OnClick", TSMAuc.Status.Scan)
		container.statusButton = btn
		
		-- open/close config button
		local btn = CreateButton(L["Config"], container, nil, "UIPanelButtonTemplate", nil, 25, {"TOPLEFT", 50, -320},
			{"TOPRIGHT", -50, -320}, L["Opens the config window for TradeSkillMaster_Auctioning."])
		btn:SetScript("OnClick", function(self)
				TSMAPI:OpenFrame()
				TSMAPI:SelectIcon("TradeSkillMaster_Auctioning", "AuctioningGroups")
			end)
		container.configButton = btn
		
		Manage.otherFrame = container
	end
	
	Manage.otherFrame:Show()
end

function Manage:HideOther()
	Manage.otherFrame:Hide()
end

function Manage:BuildAHFrame(scanType)
	local frame = CreateFrame("Frame", nil, Manage[string.lower(scanType).."Frame"])
	frame:SetClampedToScreen(true)
	frame:Raise()
	frame:SetPoint("TOPLEFT", 0, -60)
	frame:SetPoint("TOPRIGHT", 0, -60)
	frame:SetPoint("BOTTOM")
	frame:SetPoint("CENTER", 0, 100)
	frame:Hide()

	local iconButton = CreateFrame("Button", nil, frame, "ItemButtonTemplate")
	iconButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -100)
	iconButton:SetScript("OnEnter", ShowTooltip)
	iconButton:SetScript("OnLeave", HideTooltip)
	iconButton:GetNormalTexture():SetWidth(50)
	iconButton:GetNormalTexture():SetHeight(50)
	iconButton:SetHeight(50)
	iconButton:SetWidth(50)
	frame.iconButton = iconButton

	-- stack size label
	frame.link = CreateLabel(frame, "", GameFontNormalLarge, 0, nil, 250, {"LEFT", iconButton, "RIGHT"}, "LEFT", "TOP")
	
	-- stack size label
	frame.stackSize = CreateLabel(frame, "", GameFontNormalLarge, -2, nil, {"BOTTOMRIGHT", frame, "BOTTOM", -2, 140},
		{"BOTTOMLEFT", 10, 140}, "LEFT", "TOP")
	
	-- bid label
	frame.bid = CreateLabel(frame, "", GameFontNormalLarge, -2, nil, {"BOTTOMLEFT", frame, "BOTTOM", 2, 140},
		{"BOTTOMRIGHT", -10, 140}, "LEFT", "TOP")
	
	-- number of stacks label (for posting only)
	frame.numStacks = CreateLabel(frame, "", GameFontNormalLarge, -2, nil, {"BOTTOMLEFT", 10, 120},
		{"BOTTOMRIGHT", frame, "BOTTOM", -2, 120}, "LEFT", "TOP")
	
	-- buyout label
	frame.buyout = CreateLabel(frame, "", GameFontNormalLarge, -2, nil, {"BOTTOMLEFT", frame, "BOTTOM", 2, 120},
		{"BOTTOMRIGHT", -10, 120}, "LEFT", "TOP")

	-- "Skip Item" button
	local button = CreateButton(L["Skip Item"], frame, nil, "UIPanelButtonTemplate", nil, 25,
		{"BOTTOMLEFT", 6, 40}, {"BOTTOMRIGHT", frame, "BOTTOM", 0, 40}, L["Skip the current auction."])
	button:SetScript("OnClick", TSMAuc[scanType].SkipItem)
	frame.skipButton = button

	-- "Stop <Posting/Canceling>" button
	local button = CreateButton(L["Stop " .. scanType .. "ing"], frame, nil, "UIPanelButtonTemplate", nil, 25,
		{"BOTTOMLEFT", frame, "BOTTOM", 0, 40}, {"BOTTOMRIGHT", -6, 40}, L["Stop the current scan."])
	button:SetScript("OnClick", function() TSMAuc[scanType]["Stop" .. scanType .. "ing"]() TSMAuc.Scan:StopScanning(true) end)
	frame.cancelButton = button

	-- "<Post/Cancel> Auction X/Y" button
	local button = CreateButton("Post Auction", frame, "TSMAuc" .. scanType .. "Button", "UIPanelButtonTemplate",
		nil, 50, {"TOPLEFT", 3, -5}, {"TOPRIGHT", -3, -5}, L["Clicking this will " .. strlower(scanType) .. " auctions based on the data scanned."])
	button:GetFontString():SetPoint("CENTER")
	local tFile, tSize = ZoneTextFont:GetFont()
	button:GetFontString():SetFont(tFile, tSize-8, "OUTLINE")
	button:GetFontString():SetTextColor(1, 1, 1, 1)
	button:SetPushedTextOffset(0, 0)
	button:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 24,
		insets = {left = 2, right = 2, top = 4, bottom = 4},
	})
	button:SetScript("OnDisable", function() frame.skipButton:Disable() end)
	button:SetScript("OnEnable", function() frame.skipButton:Enable() end)
	button:SetScript("OnClick", TSMAuc[scanType][scanType .. "Item"])
	frame.button = button
	
	-- store the frame (all the buttons / labels are children of the frame)
	TSMAuc[scanType].frame = frame
end

function Manage:AUCTION_HOUSE_SHOW()
	local btn = CreateButton(L["Log"], AuctionFrameAuctions, nil, "UIPanelButtonTemplate", 50, 25,
		{"TOPRIGHT", -20, -11}, L["Displays the Auctioning log describing what it's currently scanning, posting or cancelling."])
	btn:SetScript("OnShow", function(self)
			if TSMAuc.db.global.showStatus then
				TSMAuc.Log:Show()
			else
				TSMAuc.Log:Hide()
			end
		end)
	btn:SetScript("OnClick", function(self)
			TSMAuc.db.global.showStatus = not TSMAuc.db.global.showStatus
			if TSMAuc.db.global.showStatus then
				TSMAuc.Log:Show()
			else
				TSMAuc.Log:Hide()
			end
		end)
	Manage.logButton = btn
end