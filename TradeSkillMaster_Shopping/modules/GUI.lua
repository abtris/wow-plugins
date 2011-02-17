local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI", "AceEvent-3.0")

local function debug(...)
	TSM:Debug(...)
end

function GUI:CreateLabel(frame, text, fontObject, fontSizeAdjustment, fontStyle, p1, p2, justifyH, justifyV)
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

function GUI:AddHorizontalBar(parent, ofsy)
	local barFrame = CreateFrame("Frame", nil, parent)
	barFrame:SetPoint("TOPLEFT", 4, ofsy)
	barFrame:SetPoint("TOPRIGHT", -4, ofsy)
	barFrame:SetHeight(8)
	local horizontalBarTex = barFrame:CreateTexture()
	horizontalBarTex:SetAllPoints(barFrame)
	horizontalBarTex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	horizontalBarTex:SetTexCoord(0.577, 0.683, 0.145, 0.309)
	horizontalBarTex:SetVertexColor(0, 0, 0.7, 1)
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

function GUI:CreateButton(text, parentFrame, frameName, inheritsFrame, fontHeight, width, height, point, arg1, arg2)
	local btn = CreateFrame("Button", frameName, parentFrame, inheritsFrame)
	btn:SetHeight(height or 0)
	btn:SetWidth(width or 0)
	btn:SetPoint(unpack(point))
	btn:SetText(text)
	btn:Raise()
	btn:GetFontString():SetPoint("CENTER")
	local tFile, tSize = GameFontHighlight:GetFont()
	btn:GetFontString():SetFont(tFile, tSize+fontHeight, "OUTLINE")
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

function GUI:CreateCheckBox(parent, label, width, point, tooltip)
	local cb = LibStub("AceGUI-3.0"):Create("TSMCheckBox")
	cb:SetType("checkbox")
	cb:SetWidth(width)
	cb:SetLabel(label)
	cb.frame:SetParent(parent)
	cb.frame:SetPoint(unpack(point))
	cb.frame:Show()
	cb.frame.tooltip = tooltip
	cb:SetCallback("OnEnter", ShowTooltip)
	cb:SetCallback("OnLeave", HideTooltip)
	return cb
end

function GUI:CreateDropdown(parent, label, width, list, point, tooltip)
	local dd = LibStub("AceGUI-3.0"):Create("TSMDropdown")
	dd:SetMultiselect(false)
	dd:SetWidth(width)
	dd:SetLabel(label)
	dd:SetList(list)
	dd.frame:SetParent(parent)
	dd.frame:SetPoint(unpack(point))
	dd.frame:Show()
	dd.frame.tooltip = tooltip
	dd:SetCallback("OnEnter", ShowTooltip)
	dd:SetCallback("OnLeave", HideTooltip)
	return dd
end

function GUI:CreateEditBox(parent, label, width, point, tooltip)
	local eb = LibStub("AceGUI-3.0"):Create("TSMEditBox")
	eb:SetWidth(width)
	eb:SetLabel(label)
	eb.frame:SetParent(parent)
	eb.frame:SetPoint(unpack(point))
	eb.frame:Show()
	eb.frame.tooltip = tooltip
	eb:SetCallback("OnEnter", ShowTooltip)
	eb:SetCallback("OnLeave", HideTooltip)
	return eb
end

function GUI:CreateIcon(parent, texture, size, point, tooltip)
	local iconButton = CreateFrame("Button", nil, parent, "ItemButtonTemplate")
	
	iconButton:SetNormalTexture(texture)
	iconButton:GetNormalTexture():SetWidth(size)
	iconButton:GetNormalTexture():SetHeight(size)
	iconButton:SetPushedTexture(texture)
	iconButton:SetPushedTextOffset(0, -4)
	
	iconButton:SetScript("OnEnter", ShowTooltip)
	iconButton:SetScript("OnLeave", HideTooltip)
	iconButton:SetPoint(unpack(point))
	iconButton:SetHeight(size)
	iconButton:SetWidth(size)
	iconButton.tooltip = tooltip
	return iconButton
end

function GUI:CreateBlueFrame(parent, height)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(height)
	frame:SetFrameLevel(parent:GetFrameLevel()-1)
	frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 5)
	frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 5)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		tile = false,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 24,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	frame:SetBackdropColor(0, 0, 0.05, 1)
	frame:SetBackdropBorderColor(0,0,1,1)
	return frame
end