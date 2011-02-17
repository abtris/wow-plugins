-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_AuctionDB") -- loads the localization table

local CATEGORIES = {L["Enchanting"], L["Inscription"], L["Jewelcrafting"], L["Alchemy"],
	L["Blacksmithing"], L["Leatherworking"], L["Tailoring"], L["Engineering"], L["Cooking"], L["Complete AH Scan"]}

function GUI:OnEnable()
	TSMAPI:RegisterSidebarFunction("TradeSkillMaster_AuctionDB", "auctionDBScan", "Interface\\Icons\\Inv_Inscription_WeaponScroll01", 
		L["AuctionDB - Run Scan"], function(...) GUI:LoadSidebar(...) end, GUI.HideSidebar)
end

-- options page
function GUI:LoadGUI(parent)
	--Truncate will leave off silver or copper if gold is greater than 100.
	local function CopperToGold(c)
		local GOLD_TEXT = "\124cFFFFD700g\124r"
		local SILVER_TEXT = "\124cFFC7C7CFs\124r"
		local COPPER_TEXT = "\124cFFEDA55Fc\124r"
		local g = floor(c/10000)
		local s = floor(mod(c/100,100))
		c = floor(mod(c, 100))
		local moneyString = ""
		if g > 0 then
			moneyString = format("%d%s", g, GOLD_TEXT)
		end
		if s > 0 and (g < 100) then
			moneyString = format("%s%d%s", moneyString, s, SILVER_TEXT)
		end
		if c > 0 and (g < 100) then
			moneyString = format("%s%d%s", moneyString, c, COPPER_TEXT)
		end
		if moneyString == "" then moneyString = "0"..COPPER_TEXT end
		return moneyString
	end

	local container = AceGUI:Create("SimpleGroup")
	container:SetLayout("list")
	parent:AddChild(container)
	
	local spacer = AceGUI:Create("Label")
	spacer:SetFullWidth(true)
	spacer:SetText(" ")
	container:AddChild(spacer)
	
	local checkBox = AceGUI:Create("CheckBox")
	checkBox:SetFullWidth(true)
	checkBox:SetLabel(L["Enable display of AuctionDB data in tooltip."])
	checkBox:SetValue(TSM.db.profile.tooltip)
	checkBox:SetCallback("OnValueChanged", function(_,_,value)
			TSM.db.profile.tooltip = value
			if value then
				TSMAPI:RegisterTooltip("TradeSkillMaster_AuctionDB", function(...) return TSM:LoadTooltip(...) end)
			else
				TSMAPI:UnregisterTooltip("TradeSkillMaster_AuctionDB")
			end
		end)
	container:AddChild(checkBox)
	
	local spacer = AceGUI:Create("Label")
	spacer:SetFullWidth(true)
	spacer:SetText(" ")
	container:AddChild(spacer)
	
	local spacer = AceGUI:Create("Label")
	spacer:SetFullWidth(true)
	spacer:SetText(" ")
	container:AddChild(spacer)
	
	local text = AceGUI:Create("Label")
	text:SetFullWidth(true)
	text:SetFontObject(GameFontNormalLarge)
	container:AddChild(text)
	
	local editBox = AceGUI:Create("EditBox")
	editBox:SetWidth(200)
	editBox:SetLabel(L["Item Lookup:"])
	editBox:SetCallback("OnEnterPressed", function(_,_,value)
			if not value then return TSM:Print(L["No data for that item"]) end
			local itemID
			local name, link = GetItemInfo(value)
			if not link then
				for ID in pairs(TSM.data) do
					local name = GetItemInfo(ID)
					if name == value then
						itemID = ID
					end
				end
			else
				itemID = TSMAPI:GetItemID(link)
			end
			if not TSM.data[itemID] then return TSM:Print(L["No data for that item"]) end
			local stdDev = sqrt(TSM.data[itemID].M2/(TSM.data[itemID].n - 1))
			local cost = CopperToGold(TSM.data[itemID].correctedMean)
			text:SetText(L["%s has a market value of %s and was seen %s times last scan and %s times total. The stdDev is %s."],
				(name or value), cost, (TSM.data[itemID].quantity or "???"), TSM.data[itemID].n, stdDev)
		end)
	container:AddChild(editBox, text)
end

-- sidebar stuff
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

local function AddHorizontalBar(parent, ofsy)
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

local function CreateCheckBox(parent, label, width, point, tooltip)
	local cb = AceGUI:Create("TSMCheckBox")
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

function GUI:LoadSidebar(frame)
	local function GetAllReady()
		if not select(2, CanSendAuctionQuery()) then
			local previous = TSM.db.profile.lastGetAll or 1/0
			if previous > (time() - 15*60) then
				local diff = previous + 15*60 - time()
				local diffMin = math.floor(diff/60)
				local diffSec = diff - diffMin*60
				return "|cffff0000"..format(L["Ready in %s min and %s sec"], diffMin, diffSec), false
			else
				return "|cffff0000"..L["Not Ready"], false
			end
		else
			return "|cff00ff00"..L["Ready"], true
		end
	end

	if not GUI.frame then
		local container = CreateFrame("Frame", nil, frame)
		container:SetAllPoints(frame)
		container:Raise()
		
		-- title text and first horizontal bar
		container.title = CreateLabel(container, L["AuctionDB - Auction House Scanning"], GameFontHighlight, 0, "OUTLINE", 300, {"TOP", 0, -20})
		AddHorizontalBar(container, -50)
		
		-- "Run <Regular/GetAll>s Scan" button + another horizontal bar
		local button = CreateButton(L["Run Scan"], container, "TSMAuctionDBRunScanButton", "UIPanelButtonTemplate", 150, 30, {"TOP", 0, -70},
			L["Starts scanning the auction house based on the below settings.\n\nIf you are running a GetAll scan, your game client may temporarily lock up."])
		button:SetScript("OnClick", TSM.Scan.RunScan)
		container.startScanButton = button
		AddHorizontalBar(container, -110)
		
		-- GetAll scan checkbox + label
		local cb = CreateCheckBox(container, L["Run GetAll Scan if Possible"], 200, {"TOPLEFT", 12, -130}, L["If checked, a GetAll scan will be used whenever possible.\n\nWARNING: With any GetAll scan there is a risk you may get disconnected from the game."])
		cb:SetCallback("OnValueChanged", function(_,_,value) TSM.db.profile.getAll = value end)
		container.getAllCheckBox = cb
		container.getAllLabel = CreateLabel(container, "", GameFontHighlight, 0, nil, 300, {"TOPLEFT", 12, -160}, "LEFT")
		
		-- timer frame for updating the getall label as well as the "Run <Regular/GetAll> Scan" button + another horizontal bar
		local timer = CreateFrame("Frame", nil, container)
		timer.timeLeft = 0
		timer:SetScript("OnUpdate", function(self, elapsed)
				self.timeLeft = self.timeLeft - elapsed
				if self.timeLeft <= 0 then
					self.timeLeft = 1
					if TSM.Scan:IsScanning() then return end
					local readyText, isReady = GetAllReady()
					GUI.frame.getAllLabel:SetText("|cffffbb00"..L["GetAll Scan:"].." "..readyText)
					if isReady and TSM.db.profile.getAll then
						GUI.frame.startScanButton:SetText(L["Run GetAll Scan"])
					else
						GUI.frame.startScanButton:SetText(L["Run Regular Scan"])
					end
				end
			end)
		AddHorizontalBar(container, -180)
		
		container.professionLabel = CreateLabel(container, L["Professions to scan for:"], GameFontHighlight, 0, nil, 300, {"TOP", 0, -190})
		-- profession checkboxes
		local i = 0
		local columnStart = frame:GetWidth() / 2
		for _, name in pairs(CATEGORIES) do
			i = i + 1
			if TSM.db.profile.scanSelections[name] == nil then
				TSM.db.profile.scanSelections[name] = false
			end
			local ofsx = 10+columnStart*((i+1)%2)-- alternating columns
			local ofsy = -190-ceil(i/2)*25 -- two per row
			local cb = CreateCheckBox(container, name, 150, {"TOPLEFT", ofsx, ofsy}, L["If checked, a regular scan will scan for this profession."])
			cb:SetCallback("OnValueChanged", function(_,_,value) TSM.db.profile.scanSelections[name] = value end)
			container[strlower(name).."CheckBox"] = cb
		end
		
		GUI.frame = container
	end
	
	GUI.frame.getAllCheckBox:SetValue(TSM.db.profile.getAll)
	for _, name in pairs(CATEGORIES) do
		GUI.frame[strlower(name).."CheckBox"]:SetValue(TSM.db.profile.scanSelections[name])
	end
	
	GUI.frame:Show()
end

function GUI:HideSidebar()
	GUI.frame:Hide()
end