--[[
	Copyright (C) Udorn (Blackhand)
	
	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.	
--]]

vendor.SearchScanFrame = {}
vendor.SearchScanFrame.prototype = {}
vendor.SearchScanFrame.metatable = {__index = vendor.SearchScanFrame.prototype}

local log = vendor.Debug:new("SearchScanFrame")
local L = vendor.Locale.GetInstance()

local BUT_HEIGHT = 20
local EDIT_HEIGHT = 16
local SCAN_WIDTH = 90

local CLASS_INDEX = 1

local function _OnUpdateSearchFrame(self)
	local hasContent
	
	-- fetch name functionality
	if (self.name:GetNumLetters() > 0) then
		hasContent = true
		self.fetchName:Enable()
	else
		self.fetchName:Disable()
	end
	
	-- save button
	if (self.saveName:GetNumLetters() > 0) then
		self.save:Enable()
	else
		self.save:Disable()
	end
	
	-- delete/new button
	if (self.searchInfo and self.searchInfo.id) then
		self.delete:Enable()
		self.new:Enable()
	else
		self.delete:Disable()
		self.new:Disable()
	end
	
	-- price
	local copper = MoneyInputFrame_GetCopper(self.maxPrice) or 0 
	if (copper > 0) then
		hasContent = true
		self.bid:Enable()
		self.buyout:Enable()
		self.bidLabel:SetText(L["Bid"])
		self.buyoutLabel:SetText(L["Buyout"])
	else
		self.bid:Disable()
		self.buyout:Disable()
		self.bidLabel:SetText(vendor.OUTDATED_FONT_COLOR_CODE..L["Bid"]..FONT_COLOR_CODE_CLOSE)
		self.buyoutLabel:SetText(vendor.OUTDATED_FONT_COLOR_CODE..L["Buyout"]..FONT_COLOR_CODE_CLOSE)
	end
	
	-- usable
	if (self.snipe:GetChecked() and self.usable:IsEnabled()) then
		self.usable:SetChecked(false)
		self.usable:Disable()
		self.usableLabel:SetText(vendor.OUTDATED_FONT_COLOR_CODE..L["Usable"]..FONT_COLOR_CODE_CLOSE)
	elseif (not self.snipe:GetChecked() and not self.usable:IsEnabled()) then
		self.usable:Enable()
		self.usableLabel:SetText(L["Usable"])
	end
	
	-- any other content?
	if (not hasContent) then
		hasContent = self.minLevel:GetNumber() > 0 or self.maxLevel:GetNumber() > 0 or self.rarity:GetSelectedValue() ~= 0 or
			self.classIndex:GetSelectedValue() ~= 0 or self.subclassIndex:GetSelectedValue() ~= 0 or
			self.usable:GetChecked()
	end
	
	-- reset button
	if (hasContent) then
		self.reset:Enable()
	else
		self.reset:Disable()
	end
end

local function _OnUpdateFrame(frame)
	local self = frame.obj
	local _, allAllowed = vendor.Scanner:MaySendAuctionQuery()
	allAllowed = allAllowed and vendor.Scanner.db.profile.getAll
	if (allAllowed and vendor.ScanFrame.SCAN_SPEED_OFF ~= vendor.Scanner.db.profile.scanSpeed) then
		self.fullScan:SetNormalTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\UI-Panel-Button-Up-green")
		self.fullScanDesc:SetText(L["(Fast scan possible)"])
	else
		self.fullScan:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
		if (vendor.ScanFrame.SCAN_SPEED_OFF == vendor.Scanner.db.profile.scanSpeed) then
			self.fullScanDesc:SetText(L["(Fast full-scan deactivated)"])
		elseif (vendor.Scanner.db.profile.lastGetAll) then
			local diff = GetTime() - vendor.Scanner.db.profile.lastGetAll
			local remaining = 15 * 60 - diff
			if (remaining < 0 and remaining > -10) then
				remaining = 0
			end
			if (remaining >= 0) then
				if (remaining > 60) then
					self.fullScanDesc:SetText(L["(Fast full-scan available in %s)"]:format(SecondsToTime(remaining, true)))
				else
					self.fullScanDesc:SetText(L["(Fast full-scan available in %s)"]:format(SecondsToTime(remaining)))
				end
			else
				self.fullScanDesc:SetText(L["(Fast full-scan currently not possible)"])
			end
		else
			self.fullScanDesc:SetText(L["(Fast full-scan currently not possible)"])
		end
	end
	
	-- last full scan
	if (vendor.Scanner.db.factionrealm.lastScan) then
		self.lastScanLabel:SetText(L["Last full scan: %s"]:format(vendor.Scanner.db.factionrealm.lastScan))
	end
	
	_OnUpdateSearchFrame(self)
end

local function _GetSearchInfo(self)
	local saveName = self.saveName:GetText()
	local name = self.name:GetText()
	local minLevel = self.minLevel:GetNumber()
	local maxLevel = self.maxLevel:GetNumber()
	local rarity = self.rarity:GetSelectedValue()
	local classIndex = self.classIndex:GetSelectedValue()
	local subclassIndex = self.subclassIndex:GetSelectedValue()
	local usable = self.usable:GetChecked()
	local maxPrice = MoneyInputFrame_GetCopper(self.maxPrice)
	local bid = self.bid:GetChecked()
	local buyout = self.buyout:GetChecked()
	local snipe = self.snipe:GetChecked()
	return {saveName = saveName, name = name, minLevel = minLevel, maxLevel = maxLevel, rarity = rarity, 
		classIndex = classIndex, subclassIndex = subclassIndex, usable = usable, maxPrice = maxPrice,
		bid = bid, buyout = buyout, snipe = snipe} 
end

local function _OnSearchScanClick(searchScan)
	local self = searchScan.obj
	self.searchInfo = _GetSearchInfo(self)
	self.scanFrame:SearchScan(self.searchInfo)
end

local function _OnFetchNameClick(fetchName)
	log:Debug("_OnFetchNameClick")
	local self = fetchName.obj
	
	local name = self.name:GetText()
	if (name and strlen(name) > 0) then
		-- TODO check for duplicates?
		self.saveName:SetText(name)
	end
end

local function _OnSaveClick(save)
	local self = save.obj
	
	local name = self.saveName:GetText()
	if (name and strlen(name) > 0) then
		local id
		if (self.searchInfo) then
			id = self.searchInfo.id
		end
		self.searchInfo = _GetSearchInfo(self)
		self.searchInfo.id = id
		self.searchList:SaveSearchInfo(self.searchInfo)
	end
end

local function _Reset(reset)
	local self = reset.obj
	
	self.name:SetText("")
	self.minLevel:SetText("")
	self.maxLevel:SetText("")
	self.rarity:SelectValue(0)
	self.subclassIndex:SelectValue(0)
	self.classIndex:SelectValue(0)
	self.usable:SetChecked(false)
	MoneyInputFrame_ResetMoney(self.maxPrice)
	MoneyInputFrame_ClearFocus(self.maxPrice)
	self.bid:SetChecked(true)
	self.buyout:SetChecked(true)
	self.snipe:SetChecked(true)
end

local function _New(new)
	log:Debug("_New") 
	local self = new.obj
	
	_Reset(self.reset)
	self.saveName:SetText("")
	self.searchInfo = nil
	self.searchList:Update()
end

local function _OnDeleteClick(delete)
	local self = delete.obj
	
	if (self.searchInfo and self.searchInfo.id) then 
		self.searchList:DeleteSearchInfo(self.searchInfo)
	end
	_New(self.new)
end

local function _OnSnipesOnlyClick(snipesOnly)
	local self = snipesOnly.obj
	
	self.searchList:SetSnipesOnly(snipesOnly:GetChecked())
end

local function _PickName(name)
	local self = name.obj
	
	local infoType, itemId, itemLink = GetCursorInfo()
	if (infoType == "item") then
		local itemName = GetItemInfo(itemLink)
		if (itemName) then
			name:SetText(itemName)
			ClearCursor()
		end
	end
end

local function _InitSearchFrame(self)
	local frame = self.frame
	
	-- name edit
	local name = CreateFrame("EditBox", vendor.GuiTools.EnsureName(), frame, "InputBoxTemplate")
	name.obj = self
	name:SetMaxLetters(32)
	name:SetFontObject(ChatFontNormal)
	name:SetWidth(150)
	name:SetHeight(EDIT_HEIGHT)
	name:SetPoint("TOP", frame, "TOP", -80, -210)
	name:SetAutoFocus(false)
	name:SetScript("OnEscapePressed", function(this) this:ClearFocus() end)
	name:SetScript("OnDragStart", function(this) _PickName(this) end)
	name:SetScript("OnReceiveDrag", function(this) _PickName(this) end)
	vendor.GuiTools.AddTooltip(name, L["Drop item here for copying it's name."])

	local f = name:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Name"])
    f:SetPoint("BOTTOMLEFT", name, "TOPLEFT", -2, 3)
    
    -- levels
    local minLevel = CreateFrame("EditBox", vendor.GuiTools.EnsureName(), frame, "InputBoxTemplate")
	minLevel.obj = self
	minLevel:SetMaxLetters(2)
	minLevel:SetNumeric(true)
	minLevel:SetWidth(25)
	minLevel:SetHeight(EDIT_HEIGHT)
	minLevel:SetPoint("LEFT", name, "RIGHT", 25, 0)
	minLevel:SetAutoFocus(false)
	minLevel:SetScript("OnEscapePressed", function(this) this:ClearFocus() end)

    local maxLevel = CreateFrame("EditBox", vendor.GuiTools.EnsureName(), frame, "InputBoxTemplate")
	maxLevel.obj = self
	maxLevel:SetMaxLetters(2)
	maxLevel:SetNumeric(true)
	maxLevel:SetWidth(25)
	maxLevel:SetHeight(EDIT_HEIGHT)
	maxLevel:SetPoint("LEFT", minLevel, "RIGHT", 30, 0)
	maxLevel:SetAutoFocus(false)
	maxLevel:SetScript("OnEscapePressed", function(this) this:ClearFocus() end)
	
	local f = name:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText("-")
    f:SetPoint("LEFT", minLevel, "RIGHT", 10, 0)
    
    local f = name:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Level range"])
    f:SetPoint("BOTTOMLEFT", minLevel, "TOPLEFT", -2, 3)
    
    -- rarity
	rarity = vendor.DropDownButton:new(nil, frame, 80, nil)
	rarity:SetPoint("LEFT", maxLevel, "RIGHT", 7, -2)
    local qualities = {}
    table.insert(qualities, {value = 0, text = L["All"]})
	table.insert(qualities, {value = 1, text = L["Common"]})
	table.insert(qualities, {value = 2, text = L["Uncommon"]})
	table.insert(qualities, {value = 3, text = L["Rare"]})
	table.insert(qualities, {value = 4, text = L["Epic"]})
	rarity:SetItems(qualities, 0)

    local f = name:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Rarity"])
    f:SetPoint("BOTTOMLEFT", rarity.button, "TOPLEFT", 20, 0)
	
	-- class
	local classIndex = vendor.DropDownButton:new(nil, frame, 120, nil)
	classIndex:SetPoint("TOPLEFT", name, "BOTTOMLEFT", -24, -30)
    local classes = {}
    table.insert(classes, {value = 0, text = L["All"]})
    local itemClasses = {GetAuctionItemClasses()}
	if (#itemClasses > 0) then
  		local itemClass
  		for off, itemClass in pairs(itemClasses) do
    		table.insert(classes, {value = off, text = itemClass})
  		end
	end
	classIndex:SetItems(classes, 0)
	classIndex:SetListener(self)
	classIndex:SetId(CLASS_INDEX)
	
    local f = classIndex.button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Class"])
    f:SetPoint("BOTTOMLEFT", classIndex.button, "TOPLEFT", 20, 0)

	-- subclass
	local subclassIndex = vendor.DropDownButton:new(nil, frame, 120, nil)
	subclassIndex:SetPoint("LEFT", classIndex.button, "RIGHT", 0, 0)
    local subclasses = {}
    table.insert(subclasses, {value = 0, text = L["All"]})
	subclassIndex:SetItems(subclasses, 0)
	
    local f = subclassIndex.button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Subclass"])
    f:SetPoint("BOTTOMLEFT", subclassIndex.button, "TOPLEFT", 20, 0)
	
	-- usable
	local usable = vendor.GuiTools.CreateCheckButton(nil, frame, "UICheckButtonTemplate", 24, 24)
	usable:SetPoint("LEFT", subclassIndex.button, "RIGHT", 0, 0)

    local usableLabel = usable:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	usableLabel:SetText(L["Usable"])
    usableLabel:SetPoint("BOTTOMLEFT", usable, "TOPLEFT", 2, 3)

    -- maxPrice
    local maxPriceName = vendor.GuiTools.EnsureName()
    local maxPrice = CreateFrame("Frame", maxPriceName, frame, "MoneyInputFrameTemplate")
	maxPrice:SetPoint("TOPLEFT", classIndex.button, "BOTTOMLEFT", 25, -20)
	local gold = _G[maxPriceName.."Gold"]
	gold:SetMaxLetters(6)

    local f = maxPrice:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Max price"])
    f:SetPoint("BOTTOMLEFT", maxPrice, "TOPLEFT", -4, 3)

	-- bid
	local bid = vendor.GuiTools.CreateCheckButton(nil, frame, "UICheckButtonTemplate", 24, 24)
	bid:SetPoint("LEFT", maxPrice, "RIGHT", 0, 10)

    local bidLabel = usable:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	bidLabel:SetText(L["Bid"])
    bidLabel:SetPoint("LEFT", bid, "RIGHT", 0, 0)

	-- buyout
	local buyout = vendor.GuiTools.CreateCheckButton(nil, frame, "UICheckButtonTemplate", 24, 24)
	buyout:SetPoint("TOP", bid, "BOTTOM", 0, 0)

    local buyoutLabel = buyout:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	buyoutLabel:SetText(L["Buyout"])
    buyoutLabel:SetPoint("LEFT", buyout, "RIGHT", 0, 0)

	-- activate snipe
	local snipe = vendor.GuiTools.CreateCheckButton(nil, frame, "UICheckButtonTemplate", 24, 24)
	snipe:SetPoint("TOPLEFT", usable, "TOPLEFT", 0, -50)
	
    local f = usable:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	--f:SetText(L["Check in scans"])
	f:SetText(L["snipe_scan_label"])
    f:SetPoint("BOTTOMLEFT", snipe, "TOPLEFT", 2, 3)

    local f = usable:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["(Check in scans)"])
    f:SetPoint("LEFT", snipe, "RIGHT", 5, 0)


	-- save name
	local saveName = CreateFrame("EditBox", vendor.GuiTools.EnsureName(), frame, "InputBoxTemplate")
	saveName.obj = self
	saveName:SetMaxLetters(32)
	saveName:SetFontObject(ChatFontNormal)
	saveName:SetWidth(150)
	saveName:SetHeight(EDIT_HEIGHT)
	saveName:SetPoint("TOPLEFT", maxPrice, "BOTTOMLEFT", 0, -50)
	saveName:SetAutoFocus(false)
	saveName:SetScript("OnEscapePressed", function(this) this:ClearFocus() end)
	
	local f = saveName:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Save name"])
    f:SetPoint("BOTTOMLEFT", saveName, "TOPLEFT", -2, 3)

    -- fetch name
	local fetchName = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	fetchName.obj = self
	fetchName:SetText(L["Fetch name"])
	fetchName:SetWidth(SCAN_WIDTH)
	fetchName:SetHeight(BUT_HEIGHT)
	fetchName:SetPoint("LEFT", saveName, "RIGHT", 5, 0)
    fetchName:SetScript("OnClick", _OnFetchNameClick)
    
    -- delete
	local delete = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	delete.obj = self
	delete:SetText(L["Delete"])
	delete:SetWidth(SCAN_WIDTH)
	delete:SetHeight(BUT_HEIGHT)
	delete:SetPoint("LEFT", fetchName, "RIGHT", 20, 0)
	delete:SetScript("OnClick", _OnDeleteClick)
	
    -- save
	local save = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	save.obj = self
	save:SetText(L["Save"])
	save:SetWidth(SCAN_WIDTH)
	save:SetHeight(BUT_HEIGHT)
	save:SetPoint("LEFT", delete, "RIGHT", 10, 0)
	save:SetScript("OnClick", _OnSaveClick)
	
    -- search scan
	local search = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	search.obj = self
	search:SetText(L["Scan"])
	search:SetWidth(SCAN_WIDTH)
	search:SetHeight(BUT_HEIGHT)
	search:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 30, -220)
	search:SetScript("OnClick", _OnSearchScanClick)

 	-- new search
	local new = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	new.obj = self
	new:SetText(L["New"])
	new:SetWidth(SCAN_WIDTH)
	new:SetHeight(BUT_HEIGHT)
	new:SetPoint("TOPLEFT", search, "BOTTOMLEFT", 0, -25)
	new:SetScript("OnClick", _New)
	
 	-- reset
	local reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	reset.obj = self
	reset:SetText(L["Reset"])
	reset:SetWidth(SCAN_WIDTH)
	reset:SetHeight(BUT_HEIGHT)
	reset:SetPoint("TOPLEFT", new, "BOTTOMLEFT", 0, -15)
	reset:SetScript("OnClick", _Reset)
	
	-- remember objects
    self.name = name
    self.minLevel = minLevel
    self.maxLevel = maxLevel
    self.rarity = rarity
    self.classIndex = classIndex
    self.subclassIndex = subclassIndex
    self.usable = usable
    self.usableLabel = usableLabel
    self.maxPrice = maxPrice
    self.bid = bid
    self.bidLabel = bidLabel
    self.buyout = buyout
    self.buyoutLabel = buyoutLabel
    self.reset = reset
    self.saveName = saveName
    self.fetchName = fetchName
    self.save = save
    self.delete = delete
    self.new = new
    self.snipe = snipe
end

local function _InitFrame(self)
	-- create the toplevel frame
	local frame = CreateFrame("Frame", nil, AuctionFrame)
	frame.obj = self
	frame:SetWidth(758)
	frame:SetHeight(447)
	frame:SetPoint("TOPLEFT")
	frame:Hide()
	frame:SetScript("OnUpdate", _OnUpdateFrame)
	local f = frame:CreateFontString("BrowseTitle", "BACKGROUND", "GameFontNormal")
	f:SetText(title)
	f:SetPoint("TOP", 0, -18)
	
	-- full scan button
	local fullScan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	fullScan.obj = self
	fullScan:SetText(L["Scan"])
	fullScan:SetWidth(SCAN_WIDTH)
	fullScan:SetHeight(BUT_HEIGHT)
	fullScan:SetPoint("TOPLEFT", frame, "TOPLEFT", 120, -90)
	fullScan:SetScript("OnClick", function(but) but.obj.scanFrame:FullScan() end)
	vendor.GuiTools.AddTooltip(fullScan, L["Scans the auction house for updating statistics and sniping items. Uses a fast \"GetAll\" scan, if the scan button is displayed with a green background. This is only possible each 15 minutes."])
	
	local f = fullScan:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	f:SetPoint("RIGHT", fullScan, "LEFT", 0, 0)
	f:SetText(L["Full scan"])

	local fullScanDesc = fullScan:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	fullScanDesc:SetPoint("LEFT", fullScan, "RIGHT", 10, 0)
	fullScanDesc:SetText(L["(Fast scan possible)"])

	-- snipe scan button
	local snipeScan = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	snipeScan.obj = self
	snipeScan:SetText(L["Scan"])
	snipeScan:SetWidth(SCAN_WIDTH)
	snipeScan:SetHeight(BUT_HEIGHT)
	snipeScan:SetPoint("TOP", fullScan, "BOTTOM", 0, -20)
	snipeScan:SetScript("OnClick", function(but) but.obj.scanFrame:SnipeScan() end)
	vendor.GuiTools.AddTooltip(snipeScan, L["Scans the auction house for for all snipes that has been set. Free custom searches may be declared as snipes."])
	
	local f = fullScan:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	f:SetPoint("RIGHT", snipeScan, "LEFT", 0, 0)
	f:SetText(L["Snipe scan"])

	local f = snipeScan:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	f:SetPoint("LEFT", snipeScan, "RIGHT", 10, 0)
	f:SetText(L["(Scan for snipes only)"])
	
	-- scan speed
	scanSpeed = vendor.DropDownButton:new(nil, frame, 80, nil, L["Too high scan speed may lead to disconnects. You should lower it, if you encounter problems."])
	scanSpeed:SetPoint("TOPLEFT", 680, -90)
    local speeds = {}
	table.insert(speeds, {value = vendor.ScanFrame.SCAN_SPEED_OFF, text = L["off"]})
	table.insert(speeds, {value = vendor.ScanFrame.SCAN_SPEED_SLOW, text = L["slow"]})
	table.insert(speeds, {value = vendor.ScanFrame.SCAN_SPEED_MEDIUM, text = L["easy"]})
	table.insert(speeds, {value = vendor.ScanFrame.SCAN_SPEED_FAST, text = L["fast"]})
	table.insert(speeds, {value = vendor.ScanFrame.SCAN_SPEED_HURRY, text = L["hurry"]})
	scanSpeed:SetItems(speeds, vendor.Scanner.db.profile.scanSpeed or vendor.ScanFrame.SCAN_SPEED_FAST)
	scanSpeed:SetListener(self.scanFrame)

	local f = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	f:SetPoint("RIGHT", scanSpeed.button, "LEFT", 10, 2)
	f:SetText(L["Scan speed"])

	-- snipes only
	local snipesOnly = vendor.GuiTools.CreateCheckButton(nil, frame, "UICheckButtonTemplate", 24, 24)
	snipesOnly.obj = self
	snipesOnly:SetPoint("TOPLEFT", frame, "TOPLEFT", 180, -386)
	snipesOnly:SetScript("OnClick", _OnSnipesOnlyClick)
	
    local f = snipesOnly:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	f:SetText(L["Snipes only"])
    f:SetPoint("RIGHT", snipesOnly, "LEFT", 0, 0)

	-- close button
	vendor.AuctionHouse:CreateCloseButton(frame, "AMScanFrameClose")
	
	-- last scan label
	local lastScanLabel = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	lastScanLabel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 30, -140)
	lastScanLabel:SetText("")
	lastScanLabel:SetJustifyH("RIGHT")
	
	-- remember objects
	self.frame = frame
	self.fullScan = fullScan
	self.fullScanDesc = fullScanDesc
	self.lastScanLabel = lastScanLabel
	
	_InitSearchFrame(self)
end

--[[ 
	Creates a new instance.
--]]
function vendor.SearchScanFrame:new(scanFrame)
	local instance = setmetatable({}, self.metatable)
	instance.scanFrame = scanFrame
	_InitFrame(instance)
	_Reset(instance.reset)
	instance.searchList = vendor.SearchList:new(instance)
	return instance
end

function vendor.SearchScanFrame.prototype:Show()
	log:Debug("Show")
	if (not self.frame:IsVisible()) then
		AuctionFrameTopLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-TopLeft")
    	AuctionFrameTop:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-Top")
    	AuctionFrameTopRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-TopRight")
    	AuctionFrameBotLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-BotLeft")
    	AuctionFrameBot:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-Bot")
    	AuctionFrameBotRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-BotRight")
		self.frame:Show()
	end
end

function vendor.SearchScanFrame.prototype:Hide()
	log:Debug("Hide enter")
	self.frame:Hide()
	log:Debug("Hide leave")
end

function vendor.SearchScanFrame.prototype:DropDownButtonSelected(button, value)
	log:Debug("DropDownButtonSelected value [%s]", value)
	if (button:GetId() == CLASS_INDEX) then
		local subclasses = {}
		table.insert(subclasses, {value = 0, text = L["All"]})
		if (value >= 1) then
    		local itemSubclasses = {GetAuctionItemSubClasses(value)}
			if (#itemSubclasses > 0) then
  				local itemSubclass
  				for off, itemSubclass in pairs(itemSubclasses) do
    				table.insert(subclasses, {value = off, text = itemSubclass})
  				end
			end
		end
		self.subclassIndex:SetItems(subclasses, 0)
	end
end

function vendor.SearchScanFrame.prototype:SelectSearchInfo(searchInfo)
	log:Debug("SelectSearchInfo saveName")
	self.searchInfo = searchInfo
	self.name:SetText(searchInfo.name or "")
	self.saveName:SetText(searchInfo.saveName or "")
	if (not searchInfo.minLevel or searchInfo.minLevel == 0) then
		self.minLevel:SetText("")
	else
		self.minLevel:SetText(searchInfo.minLevel)
	end
	if (not searchInfo.maxLevel or searchInfo.maxLevel == 0) then
		self.maxLevel:SetText("")
	else
		self.maxLevel:SetText(searchInfo.maxLevel)
	end	
	self.rarity:SelectValue(searchInfo.rarity or 0)
	self.classIndex:SelectValue(searchInfo.classIndex or 0)
	self.subclassIndex:SelectValue(searchInfo.subclassIndex or 0)
	self.usable:SetChecked(searchInfo.usable)
	if (not searchInfo.maxPrice or searchInfo.maxPrice == 0) then
		MoneyInputFrame_ResetMoney(self.maxPrice)
	else
		MoneyInputFrame_SetCopper(self.maxPrice, searchInfo.maxPrice)
	end
	self.bid:SetChecked(searchInfo.bid)
	self.buyout:SetChecked(searchInfo.buyout)
	self.snipe:SetChecked(searchInfo.snipe)
end

function vendor.SearchScanFrame.prototype:SnipeItem(name)
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	local info
	if (name and strlen(name) > 0) then
    	for i = 1, #infos do
    		if (infos[i].name == name) then
    			info = infos[i]
    		end
    	end
    end
    
    if (info) then
		self:SelectSearchInfo(info)
	else
		_New(self.new)
		self.name:SetText(name or "")
		self.saveName:SetText(name or "")
	end
end

function vendor.SearchScanFrame.prototype:PickItem(itemLink)
	log:Debug("PickItem")
	local name = GetItemInfo(itemLink)
	log:Debug("name [%s]", name)
	if (name) then
		_New(self.new)
		self.name:SetText(name)
		self.saveName:SetText(name)
	end
end
