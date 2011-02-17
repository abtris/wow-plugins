-- This module creates and provides API functions for the TSM remote frame.
-- These functions support the table format for building AceGUI pages created by Sapu94.

local TSM = select(2, ...)
local lib = TSMAPI
local private = {functions={}}
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
local version = GetAddOnMetadata("TradeSkillMaster","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster", "Version")

local FRAME_WIDTH = 350
local FRAME_HEIGHT = 430
local MAX_FUNCTIONS = 11


-- ====================================================================== --
-- helper functions for creating the frame

local function CreateRemoteFrame()
	local frame = CreateFrame("Frame", nil, AuctionFrame)
	frame:SetWidth(FRAME_WIDTH)
	frame:SetHeight(FRAME_HEIGHT)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetScript("OnShow", function() private:ShowFunctionPage(0) end)
	frame:SetScript("OnHide", function() private:HideFunctionPage(private.currentPage) end)
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
		highlightTex:SetVertexColor(0.3, 0.3, 0.3, 0.7)
		pressedTex:SetTexCoord(0.0256, 0.743, 0.017, 0.158)
		btn:SetPushedTextOffset(0, -2)
	end
	
	btn:SetNormalTexture(normalTex)
	btn:SetDisabledTexture(disabledTex)
	btn:SetHighlightTexture(highlightTex)
	btn:SetPushedTexture(pressedTex)
end

local function CreateButton(text, parentFrame, frameName, inheritsFrame, height, baseFont, textSize)
	local btn = CreateFrame("Button", frameName, parentFrame, inheritsFrame)
	btn:SetHeight(height)
	btn:SetText(text)
	btn:GetFontString():SetPoint("CENTER")
	local tFile, tSize = baseFont:GetFont()
	btn:GetFontString():SetFont(tFile, tSize + textSize, "OUTLINE")
	btn:GetFontString():SetTextColor(1, 1, 1, 1)
	return btn
end

local function CreateOpenCloseButton()
	-- button to open / close the remote frame
	local btn = CreateButton("TSM>>", AuctionFrame, nil, "UIPanelButtonTemplate", 25, GameFontHighlight, 0)
	btn:SetWidth(70)
	btn:SetPoint("TOPRIGHT", -25, -11)
	btn:Raise()
	btn:SetScript("OnClick", function(self)
		if private.frame:IsVisible() then
			self:SetText("TSM>>")
			self:UnlockHighlight()
			private.frame:Hide()
			if btn.scaleChanged then
				AuctionFrame:SetScale(1)
				private.frame:SetScale(1)
			end
		else
			local screenWidth = UIParent:GetWidth()
			if UIParent:GetWidth() < 1300 then
				local requiredWidth = AuctionFrame:GetWidth()+FRAME_WIDTH+100
				local scale = screenWidth / requiredWidth
				AuctionFrame:SetPoint("TOPLEFT", 20, -50)
				AuctionFrame:SetScale(scale)
				private.frame:SetScale(scale)
				btn.scaleChanged = true
			else
				btn.scaleChanged = false
			end
			self:SetText("<<TSM")
			self:LockHighlight()
			private.frame:Show()
		end
	end)
	btn:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 18,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	ApplyTexturesToButton(btn, true)
	return btn
end

local function CreateIconContainerFrame()
	-- frame to contain all the function icons
	local frame = CreateFrame("Frame", nil, private.frame)
	frame:SetWidth(50)
	frame:SetHeight(FRAME_HEIGHT-12)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		tile = false,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	frame:SetBackdropColor(0, 0, 0.05, 1)
	frame:SetBackdropBorderColor(0,0,1,1)
	frame:SetPoint("TOPLEFT", private.frame, "TOPRIGHT", -5, -6)
	return frame
end

local function CreateIconFrame(parent)
	-- frame to contain one icon
	local frame = CreateFrame("frame", nil, parent)
	frame:SetWidth(32)
	frame:SetHeight(32)
	frame:Raise()
	frame:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	})
	frame:SetBackdropBorderColor(0,0,1,1)
	
	return frame
end

local function AddTexture(frame, texture)
	if not texture then return end
	if frame.icon then
		frame.icon:SetTexture(texture)
	else
		local tex = frame:CreateTexture()
		tex:SetTexture(texture)
		tex:SetAllPoints(frame)
		frame.icon = tex
	end
end

local function AddTooltip(frame, tooltip)
	frame:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
			GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)
	frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end

local function CreateIconFrames()
	local function OnClick(buttonNum, self, button)
		if button == "LeftButton" then
			private:ShowFunctionPage(buttonNum)
		end
	end
	
	local icons = {icon={}}
	
	local container = CreateIconContainerFrame()
	icons.container = container

	for i=1, MAX_FUNCTIONS do
		icons.icon[i] = CreateIconFrame(container)
		icons.icon[i]:SetPoint("TOPLEFT", 10, -8-((i-1)*36))
		icons.icon[i]:SetScript("OnMouseUp", function(...) OnClick(i, ...) end)
	end
	return icons
end

local function UpdateIconFrame()
	for i=1, MAX_FUNCTIONS do
		if private.functions[i] then
			AddTexture(private.frame.icons.icon[i], private.functions[i].icon)
			AddTooltip(private.frame.icons.icon[i], private.functions[i].tooltip)
		end
	end
end

local function ShowDefaultPage(frame)
	if not private.defaultPage then
		local container = CreateFrame("Frame", nil, frame)
		container:SetAllPoints(frame)
		container:Raise()
		
		local label = container:CreateFontString(nil, "Overlay", "GameFontHighlight")
		local tFile, tSize = GameFontNormalLarge:GetFont()
		label:SetFont(tFile, tSize-1, "OUTLINE")
		label:SetTextColor(1, 1, 1, 1)
		label:SetPoint("TOP", container, "TOP", 0, -20)
		label:SetWidth(300)
		label:SetText(L["TradeSkillMaster Sidebar"])
		container.title = label
		
		local label = container:CreateFontString(nil, "Overlay", "GameFontHighlight")
		local tFile, tSize = GameFontNormalLarge:GetFont()
		label:SetFont(tFile, tSize-4, "OUTLINE")
		label:SetTextColor(1, 1, 1, 1)
		label:SetPoint("TOP", 0, -50)
		label:SetWidth(300)
		label:SetHeight(100)
		label:SetText(L["You can use the icons on the right side of this frame to quickly access auction house related functions for TradeSkillMaster modules."])
		if lib:GetNumModules() == 1 then
			label:SetHeight(200)
			label:SetText("\n|cffff0000"..L["No modules are currently loaded.  Enable or download some for full functionality!"].."\n\n"..L["Visit http://wow.curse.com/downloads/wow-addons/details/tradeskill-master.aspx for information about the different TradeSkillMaster modules as well as download links."].."|r")
		end
		container.text = label
		
		local cb = AceGUI:Create("TSMCheckBox")
		cb:SetType("checkbox")
		cb:SetValue(TSM.db.profile.autoOpenSidebar)
		cb:SetWidth(250)
		cb:SetLabel(L["Automatically Open Sidebar"])
		cb.frame:SetParent(container)
		cb.frame:SetPoint("TOP", 0, -200)
		cb.frame:Show()
		cb.frame.tooltip = L["If checked, the sidebar will open automatically whenever you open up the auction house window."]
		cb:SetCallback("OnEnter", function(self)
				if self.tooltip then
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
					GameTooltip:SetText(self.tooltip, 1, 1, 1, 1, true)
					GameTooltip:Show()
				end
			end)
		cb:SetCallback("OnLeave", function() GameTooltip:Hide() end)
		cb:SetCallback("OnValueChanged", function(_,_,value) TSM.db.profile.autoOpenSidebar = value end)
		if lib:GetNumModules() == 1 then
			cb.frame:Hide()
		end
		
		private.defaultPage = container
	end
	
	private.defaultPage:Show()
end

local function HideDefaultPage()
	private.defaultPage:Hide()
end

local function CreateStatusBar()
	local level = private.frame:GetFrameLevel()
	-- Frame that containes the StatusBar
	local frame = CreateFrame("Frame", nil, private.frame)
	frame:SetHeight(25)
	frame:SetPoint("BOTTOMRIGHT", -6, 6)
	frame:SetPoint("BOTTOMLEFT", 6, 6)
	frame:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 3, right = 3, top = 5, bottom = 3 }
		})
	frame:SetBackdropBorderColor(0.75, 0.75, 0.75, 0.90)
	frame:SetFrameLevel(level+1)
	
	-- minor status bar (gray one)
	local statusBar = CreateFrame("STATUSBAR", "TSMMinorStatusBar", frame, "TextStatusBar")
	statusBar:SetOrientation("HORIZONTAL")
	statusBar:SetHeight(25)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetPoint("TOPLEFT", 4, -4)
	statusBar:SetPoint("BOTTOMRIGHT", -4, 4)
	statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
	statusBar:SetStatusBarColor(200,10,20, 0.5)
	statusBar:SetValue(25)
	statusBar:SetFrameLevel(level+2)
	frame.minorStatusBar = statusBar
	
	-- major status bar (main blue one)
	local statusBar = CreateFrame("STATUSBAR", "TSMMajorStatusBar", frame,"TextStatusBar")
	statusBar:SetOrientation("HORIZONTAL")
	statusBar:SetHeight(25)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetPoint("TOPLEFT", 4, -4)
	statusBar:SetPoint("BOTTOMRIGHT", -4, 4)
	statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
	statusBar:SetStatusBarColor(0,100,20, 0.9)
	statusBar:SetFrameLevel(level+3)
	frame.majorStatusBar = statusBar
	
	local textFrame = CreateFrame("Frame", nil, frame)
	textFrame:SetFrameLevel(level+4)
	textFrame:SetAllPoints(frame)
	-- Text for the StatusBar
	local tFile, tSize = GameFontNormal:GetFont()
	local text = textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetFont(tFile, tSize, "OUTLINE")
	text:SetPoint("CENTER")
	frame.text = text
	
	private.statusBarFrame = frame
end


-- ====================================================================== --
-- functions for initializing the addon and creating the frame

function private.AUCTION_HOUSE_SHOW()
	if not private.frame then
		private:Create()
	end
	
	private.frame:SetPoint("TOPLEFT", AuctionFrame, "TOPRIGHT", -4, -10)
	private.frame:SetWidth(FRAME_WIDTH)
	private.frame:SetHeight(FRAME_HEIGHT)
	lib:UnlockSidebar()
	if TSM.db.profile.autoOpenSidebar then
		if not private.frame:IsVisible() then
			private.frame.toggleButton:Click()
		end
	else
		if private.frame:IsVisible() then
			private.frame.toggleButton:Click()
		end
	end
end

do
	LibStub("AceEvent-3.0").RegisterEvent(private, "AUCTION_HOUSE_SHOW")
end

function private:Create()
	private.frame = CreateRemoteFrame()
	private.frame.toggleButton = CreateOpenCloseButton()
	private.frame.icons = CreateIconFrames()
	UpdateIconFrame()
	private.frame:Hide()
	
	private.functions[0] = {module="TradeSkillMaster", icon="", tooltip="", show=ShowDefaultPage, hide=HideDefaultPage}
end

function private:ShowFunctionPage(num)
	if not private.functions[num] or private.isLocked then return end
	
	private:HideFunctionPage(private.currentPage)
	private.functions[num].show(private.frame)
	private.currentPage = num
end

function private:HideFunctionPage(num)
	if not (num and private.functions[num]) or private.isLocked then return end
	
	private.functions[num].hide(private.frame)
end


-- TSMAPI functions for the Sidebar

function lib:RegisterSidebarFunction(moduleName, label, iconTexture, tooltip, loadFunc, closeFunc)
	if not (moduleName and label and iconTexture and tooltip and loadFunc and closeFunc) then
		return nil, "invalid args", moduleName, label, iconTexture, tooltip, loadFunc, closeFunc
	end
	
	if not TSM:CheckModuleName(moduleName) then
		return nil, "No module registered under name: " .. moduleName
	end
	
	tinsert(private.functions, {module=moduleName, label=label, icon=iconTexture, tooltip=tooltip, show=loadFunc, hide=closeFunc})
	if private.frame then
		UpdateIconFrame()
	end
end

function lib:SelectRemoteFunction(label, forced)
	if not label then return nil, "invalid args", label end
	if private.isLocked and not forced then return nil, "frame is locked" end
	
	for i, data in pairs(private.functions) do
		if data.label == label then
			if forced then lib:UnlockSidebar() end
			private:ShowFunctionPage(i)
			if forced then lib:LockSidebar() end
			break
		end
	end
end

function lib:LockSidebar()
	private.isLocked = true
	private.frame.toggleButton:Disable()
end

function lib:UnlockSidebar()
	private.isLocked = false
	private.frame.toggleButton:Enable()
end

function lib:ShowSidebarStatusBar()
	if not private.statusBarFrame then
		CreateStatusBar()
	end
	
	private.statusBarFrame:Show()
end

function lib:HideSidebarStatusBar()
	if private.statusBarFrame then
		private.statusBarFrame:Hide()
	end
end

function lib:SetSidebarStatusBarText(text)
	private.statusBarFrame.text:SetText(text)
end

function lib:UpdateSidebarStatusBar(value, isMinorBar)
	if isMinorBar then
		private.statusBarFrame.minorStatusBar:SetValue(value)
	else
		private.statusBarFrame.majorStatusBar:SetValue(value)
	end
end