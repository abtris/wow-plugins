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

vendor.ScanFrame = {}
vendor.ScanFrame.prototype = {}
vendor.ScanFrame.metatable = {__index = vendor.ScanFrame.prototype}

local FRAME_HEIGHT = 500
local FRAME_WIDTH = 890
local TREE_WIDTH = 150
local SNIPERS_HEIGHT = 230
local TYPES_HEIGHT = 300
local TABLE_TOP = -51
local TABLE_WIDTH = 609
local TABLE_HEIGHT = 358
local STOP_WIDTH = 90

local SCAN_FRAME = 1
local SEARCH_FRAME = 2

vendor.ScanFrame.SCAN_SPEED_OFF = 0
vendor.ScanFrame.SCAN_SPEED_SLOW = 1
vendor.ScanFrame.SCAN_SPEED_MEDIUM = 2
vendor.ScanFrame.SCAN_SPEED_FAST = 3
vendor.ScanFrame.SCAN_SPEED_HURRY = 4

vendor.ScanFrame.SPEEDS = {
	[vendor.ScanFrame.SCAN_SPEED_OFF] = 0,
	[vendor.ScanFrame.SCAN_SPEED_SLOW] = 200,
	[vendor.ScanFrame.SCAN_SPEED_MEDIUM] = 400,
	[vendor.ScanFrame.SCAN_SPEED_FAST] = 700,
	[vendor.ScanFrame.SCAN_SPEED_HURRY] = 1200
}

local log = vendor.Debug:new("ScanFrame")
local L = vendor.Locale.GetInstance()

local function _HideAuctionFrame(self)
	self.auctionFrameScale = AuctionFrame:GetScale()
	AuctionFrame:SetScale(0.0001)
end

local function _RestoreAuctionFrame(self)
	AuctionFrame:SetScale(self.auctionFrameScale or 1)
end

local function _DisableOtherTabs(self)
	log:Debug("_DisableOtherTabs")
	for i=1,10 do
		if (i ~= self.id) then
			local tabBut = _G["AuctionFrameTab"..i]
			if (tabBut) then
				tabBut:Disable()
			end
		end
	end
end

local function _EnableOtherTabs(self)
	log:Debug("_EnableOtherTabs")
	for i=1,10 do
		if (i ~= self.id) then
			local tabBut = _G["AuctionFrameTab"..i]
			if (tabBut) then
				tabBut:Enable()
			end
		end
	end
end

local function _Stop(self)
	log:Debug("_Stop")
	self.scanning = nil
	_EnableOtherTabs(self)
	vendor.Scanner:StopScan()
end

local function _Hide(self)
	_Stop(self)
	self.frame:Hide()
	_RestoreAuctionFrame(self)
end

local function _CheckUpdate(but)
	if (but:GetChecked()) then
		vendor.Scanner.db.profile.getAll = true
	else
		vendor.Scanner.db.profile.getAll = false
	end
end

local function _OnUpdateFrame(self)
	if (vendor.Scanner:IsScanning()) then
		self.backBut:Hide()
		self.stopBut:Show()
--		if (self.getAll) then
--			self:SetProgress(L["Performing getAll scan. This may last up to several minutes..."], 0)
--		end
	else
		self.backBut:Show()
		self.stopBut:Hide()
	end
	
	-- status bar
	if (self.statusBar:GetValue() > 0.001 or string.len(self.statusBarText:GetText() or "") > 0) then
		self.title:Hide()
		if (vendor.AuctionHouse.db.profile.amButtonPos == 0) then
			-- AuctionMaster button is at the right pos
			self.statusBar:SetPoint("TOPLEFT", 70, -17)
			self.statusBar:SetWidth(623)
		else
			-- AuctionMaster button is at the left pos
			self.statusBar:SetPoint("TOPLEFT", 185, -17)
			self.statusBar:SetWidth(618)
		end
		self.statusBar:Show()
	else
		self.title:Show()
		self.statusBar:Hide()
	end
end

local function _OnHideFrame(self)
	log:Debug("_OnHideFrame")
	_EnableOtherTabs(self)
end

local function _FinishFullScan(self, result)
	if (result and result.scanId and not result.cancelled) then
		vendor.Scanner.db.factionrealm.lastScan = date()
	end
	_EnableOtherTabs(self)
end

local function _FullScan(self)
	log:Debug("_Scan enter")
	vendor.Scanner:FullScan(nil, _FinishFullScan, self)
	log:Debug("_Scan leave")
end

local function _UpdateSnipeProgress(self, name)
	local scanned = self.numItemsToScan - #self.snipeScans
	local msg = L["Scanning snipe %d/%d (%s)"]:format(scanned + 1, self.numItemsToScan, name)
	self:SetProgress(msg, scanned / self.numItemsToScan)
end

local function _SnipeScanProgress(self, result)
	local scanId = result.scanId
	log:Debug("_SnipeScanProgress result: %s scanId: %s", result, scanId)
	if (self.scanning) then
    	if (scanId) then
    		for i = 1, #self.snipeScans do
    			local info = self.snipeScans[i]
    			if (info.scanId and info.scanId == scanId) then
    				table.remove(self.snipeScans, i)
    				break
    			end
    		end
        	if (#self.snipeScans > 0) then
        		local info = self.snipeScans[1]
    			_UpdateSnipeProgress(self, info.saveName)
        		info.scanId = vendor.Scanner:SearchScan(info, true, nil, _SnipeScanProgress, self)
        	else
        		_EnableOtherTabs(self)
        	end
    	else
    		vendor.Vendor:Error("missing scanId for scan")
    	end
    end
end

local function _SnipeScan(self)
	log:Debug("_SnipeScan enter")
	self.scanning = true
	self.snipeScans = wipe(self.snipeScans or {})
	local snipeScans = self.snipeScans
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	for i = 1, #infos do
		table.insert(snipeScans, infos[i])
	end
	self.numItemsToScan = #snipeScans
	if (self.numItemsToScan > 0) then
		local info = snipeScans[1]
		_UpdateSnipeProgress(self, info.saveName)
		info.scanId = vendor.Scanner:SearchScan(info, true, nil, _SnipeScanProgress, self) 
	else
		_EnableOtherTabs(self)
	end
	log:Debug("_SnipeScan leave")
end

local function _Back(self)
	log:Debug("_Back")
	self.frameType = SEARCH_FRAME
	self:Clear()
	self:ShowTabFrame()
end

local function _OnSniperClick(checkbox)
	local self = checkbox.obj
	local selected = checkbox:GetChecked()
	self.itemModel:SetSniperVisibility(checkbox.sniperId, selected)
	if (selected) then
		vendor.Scanner.db.profile.snipers[checkbox.sniperId] = true
	else
		vendor.Scanner.db.profile.snipers[checkbox.sniperId] = nil
	end
end

local function _CreateSnipers(self)
	local snipers = vendor.Sniper:GetSnipers()
	local yOff = -80
	local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	title:SetText(L["Snipers"])
	local xOff = 27 
	title:SetPoint("TOPLEFT", xOff, yOff)
	yOff = yOff - 12
	local checkbox
	for i=1,#snipers do
		local sniper = snipers[i]
		local selected = vendor.Scanner.db.profile.snipers[sniper:GetId()]
		if (selected) then
			self.itemModel:SetSniperVisibility(sniper:GetId(), selected)
		end
		checkbox = vendor.GuiTools.CreateCheckButton(nil, self.frame, "UICheckButtonTemplate", 24, 24, selected)
		checkbox.obj = self
		checkbox.sniperId = sniper:GetId()
		checkbox:SetPoint("TOPLEFT", xOff, yOff)
		checkbox:SetScript("OnClick", _OnSniperClick)
		local f = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		f:SetPoint("LEFT", checkbox, "RIGHT", 0, 0)
		f:SetText(sniper:GetDisplayName())
		yOff = yOff - 24
	end
	return checkbox 
end


local function _NotScanning(self)
	local isScanning, getAll = vendor.Scanner:IsScanning()
	if (isScanning) then
		self.getAll = getAll
	end
	return not isScanning
end

local function _Bid(self)
	log:Debug("_Bid")
	local rows = wipe(self.tmpList1)
	local auctions = wipe(self.buyTable)
   	for _, row in pairs(self.itemModel:GetSelectedItems()) do
   		local _, itemLink, _, name, _, count, minBid, minIncrement, buyout, bidAmount, _, _, index = self.itemModel:Get(row)
   		local bid = minBid
   		if (bidAmount and bidAmount > 0) then
   			bid = bidAmount + (minIncrement or 0) 
   		end
   		local info = {itemLink = itemLink, name = name, count = count, bidAmount = bidAmount, minBid = minBid, buyout = buyout, bid = bid, index = index, minIncrement = minIncrement, doBid = true, reason = L["Bid"]}
   		log:Debug("name [%s] minBid [%s] minIncrement [%s]", name, minBid, minIncrement)
   		table.insert(rows, row)
   		table.insert(auctions, info)
   	end
   	self.itemModel:RemoveRows(rows)
   	local n = #auctions
 	if (self.getAll) then
    	--vendor.Scanner:PlaceAuctionBid("list", auctions, self.possibleGap)
    	local task = vendor.GetAllPlaceAuctionTask:new(auctions, false)
		vendor.TaskQueue:AddTask(task)
    else
    	vendor.Scanner:BuyScan(auctions)
    end
    self.possibleGap = self.possibleGap + n
end

local function _Buyout(self)
	log:Debug("_Buyout")
	local rows = wipe(self.tmpList1)
	local auctions = wipe(self.buyTable)
   	for _, row in pairs(self.itemModel:GetSelectedItems()) do
   		local _, itemLink, _, name, _, count, minBid, minIncrement, buyout, _, _, _, index = self.itemModel:Get(row)
   		log:Debug("name [%s] minBid [%s] minIncrement [%s]", name, minBid, minIncrement)
   		local info = {name = name, itemLink = itemLink, count = count, bidAmount = bidAmount, minBid = minBid, buyout = buyout, bid = buyout, index = index, doBuyout = true, reason = L["Buy"]}
   		table.insert(rows, row)
   		table.insert(auctions, info)
   	end
   	local n = #auctions
   	self.itemModel:RemoveRows(rows)
	if (self.getAll) then
--    	vendor.Scanner:PlaceAuctionBid("list", auctions, self.possibleGap)
		local task = vendor.GetAllPlaceAuctionTask:new(auctions, false)
		vendor.TaskQueue:AddTask(task)
    else
    	vendor.Scanner:BuyScan(auctions)
    end
    self.possibleGap = self.possibleGap + n
end

local function _InitFrame(self)
	local frame = vendor.AuctionHouse:CreateTabFrame("AMScannerTab", L["Scanner"], L["Scanner"], self)
	self.frame = frame
	frame.obj = self
	
	-- status bar 
	local statusBar = CreateFrame("StatusBar", nil, frame, "TextStatusBar")
	self.statusBar = statusBar
	statusBar.obj = self
	statusBar:SetHeight(14)
	statusBar:SetWidth(622)
	statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	statusBar:SetPoint("TOPLEFT", 70, -17)
	statusBar:SetMinMaxValues(0, 1)
	statusBar:SetValue(1)
	statusBar:SetStatusBarColor(0, 1, 0)
	
	-- status bar text
	local text = statusBar:CreateFontString(nil, "ARTWORK")
	self.statusBarText = text
	text:SetPoint("CENTER", statusBar)
	text:SetFontObject("GameFontHighlight")
		
	-- stop button 
	local but = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	but.obj = self
	but:SetText(L["Stop"])
	but:SetWidth(STOP_WIDTH)
	but:SetHeight(20)
	but:SetPoint("TOPLEFT", 90, -45)
	but:SetScript("OnClick", function(but) _Stop(but.obj) end)
	vendor.GuiTools.AddTooltip(but, L["Aborts the current scan."])
	self.stopBut = but
	
	-- back button 
	local but = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	but.obj = self
	but:SetText(L["Back"])
	but:SetWidth(STOP_WIDTH)
	but:SetHeight(20)
	but:SetPoint("TOPLEFT", self.stopBut, "TOPLEFT", 0, 0)
	but:SetScript("OnClick", function(but) _Back(but.obj) end)
	vendor.GuiTools.AddTooltip(but, L["Goes back to the search view."])
	self.backBut = but

	-- scan/stop switch
	frame:SetScript("OnUpdate", function(frame) _OnUpdateFrame(frame.obj) end)
	frame:SetScript("OnHide", function(frame) _OnHideFrame(frame.obj) end)
	
	-- close button
	vendor.AuctionHouse:CreateCloseButton(frame, "AMScanFrameClose")
	
	-- selected snipers
	_CreateSnipers(self)
--   -- create the frame
--	local frame = CreateFrame("Frame", nil, UIParent, "VendorDialogTemplate")
--	frame.obj = self
--	self.frame = frame
--	frame:SetWidth(FRAME_WIDTH)
--	frame:SetHeight(FRAME_HEIGHT)
--	frame:SetPoint("TOPLEFT", 0, -104)
--	--frame:SetFrameStrata("DIALOG")
--	frame:SetMovable(true)
--	frame:EnableMouse(true)
--	frame:SetToplevel(true)
----	frame:SetClampedToScreen(true)
--	frame:SetScript("OnMouseDown", function() this:StartMoving() end)
--	frame:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
--				
--	-- title string
--	local text = frame:CreateFontString(nil, "OVERLAY")
--	text:SetPoint("TOP", frame, "TOP", 0, -10)
--	text:SetFontObject("GameFontHighlightLarge")
--	text:SetText(L["Scanner"])
--	
--	-- close button
--	local but = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
--	but.obj = self
--	but:SetPoint("TOPRIGHT", 3, 0)
--	but:SetScript("OnClick", function(but) _Hide(but.obj) end)
--	
--	-- status bar 
--	local statusBar = CreateFrame("StatusBar", name, frame, "TextStatusBar")
--	self.statusBar = statusBar
--	statusBar:SetHeight(14)
--	statusBar:SetWidth(FRAME_WIDTH - STOP_WIDTH - 15)
--	statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
--	statusBar:SetPoint("TOPLEFT", 5, -30)
--	statusBar:SetMinMaxValues(0, 1)
--	statusBar:SetValue(0)
--	statusBar:SetStatusBarColor(0, 1, 0)
--	
--	-- status bar text
--	local text = statusBar:CreateFontString(nil, "ARTWORK")
--	self.statusBarText = text
--	text:SetPoint("CENTER", statusBar)
--	text:SetFontObject("GameFontHighlight")
--	text:SetText("1000/166363 auctions")
--	
--	-- stop button 
--	local but = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
--	but.obj = self
--	but:SetText(L["Stop"])
--	but:SetWidth(STOP_WIDTH)
--	but:SetHeight(20)
--	but:SetPoint("TOPRIGHT", -5, -27)
--	but:SetScript("OnClick", function(but) _Stop(but.obj) end)
--	self.stopBut = but
--	
--	-- scan button 
--	local but = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
--	but.obj = self
--	but:SetText(L["Scan"])
--	but:SetWidth(STOP_WIDTH)
--	but:SetHeight(20)
--	but:SetPoint("TOPRIGHT", -5, -27)
--	but:SetScript("OnClick", function(but) _Scan(but.obj) end)
--	self.backBut = but
--	
--	-- scan/stop switch
--	frame:SetScript("OnUpdate", function(frame) _OnUpdateFrame(frame.obj) end)
--	
--	-- selected snipers
--	_CreateSnipers(self)
--	
--	-- selected types
----	local types = AceGUI:Create("TreeMenu")
----	types:SetTree(tree)
----	types:SetWidth(TREE_WIDTH)
----	types:SetHeight(TYPES_HEIGHT)
----	types.frame:SetParent(frame)
----	types:SetPoint("TOPLEFT", snipes.frame, "BOTTOMLEFT", 0, -15)
----	types:SetTitle("Types")
--	
--	frame:Hide()
end

local function _PrepareScan(self)
	self.frameType = SCAN_FRAME
	self.searchFrame:Hide()
	self.frame:Show()
	self:UpdateTabFrame()
	self:Clear()
	_DisableOtherTabs(self)
end

local function _Init(self)
	local itemModel = vendor.ScannerItemModel:new()
	self.itemModel = itemModel
	_InitFrame(self)
	local cmds = {
		[1] = {
			title = L["Bid"],
			tooltip = L["Bids on all selected items."].." "..L["Auctions may be selected with left clicks. Press the ctrl button, if you want to select multiple auctions. Press the shift button, if you want to select a range of auctions."],
    		arg1 = self,
    		func = _Bid,
    		enabledFunc = _NotScanning
    	},
    	[2] = {
    		title = L["Buyout"],
    		tooltip = L["Buys all selected items."].." "..L["Auctions may be selected with left clicks. Press the ctrl button, if you want to select multiple auctions. Press the shift button, if you want to select a range of auctions."],
    		arg1 = self,
    		func = _Buyout,
    		enabledFunc = _NotScanning
    	},
	}
	local cfg = {
		name = "AMScannerAuctions",
		parent = self.frame,
		itemModel = itemModel,
		cmds = cmds,
		config = vendor.Scanner.db.profile.scannerItemTableCfg,
		width = TABLE_WIDTH,
		height = TABLE_HEIGHT,
		xOff = TREE_WIDTH + 10,
		yOff = TABLE_TOP,
		xOff = 214,
		yOff = -51,
		--sortButtonBackground = true,
	}
	local itemTable = vendor.ItemTable:new(cfg)
	self.itemTable = itemTable
	self.buyTable = {}
	self.tmpList1 = {}
	self.possibleGap = 0
	--self.frame:Hide()
	--self:Clear()
	
	self.searchFrame = vendor.SearchScanFrame:new(self)
end

--[[ 
	Creates a new instance.
--]]
function vendor.ScanFrame:new()
	local instance = setmetatable({}, self.metatable)
	instance.frameType = SEARCH_FRAME
	_Init(instance)
	return instance
end

--[[
	Sets the progress together with the given message.
--]]
function vendor.ScanFrame.prototype:SetProgress(msg, percent)
	log:Debug("SetProgress msg [%s] percent [%s]", msg, percent)
	self.statusBar:SetValue(percent)
	self.statusBarText:SetText(msg)
	if (msg and strlen(msg) > 0) then
		self.title:Hide()
		self.statusBar:Show()
		self.statusBarText:Show()
	else
		self.title:Show()
		self.statusBar:Hide()
		self.statusBarText:Hide()
	end
end

--[[
	Notifies the termination of a scan. May play a sound, if the scan frame is currently
	visible.
--]]
function vendor.ScanFrame.prototype:ScanFinished()
	if (self.frame:IsVisible()) then
		PlaySound("AuctionWindowClose")
		self:SetProgress("", 0)
	end
end

--[[
	Clears the progres bar.
--]]
function vendor.ScanFrame.prototype:Clear()
	log:Debug("Clear enter")
	self.statusBar:SetValue(0)
	self.statusBarText:SetText("")
	self.itemModel:Clear()
	self.itemTable:Update()
	self.possibleGap = 0
	log:Debug("Clear exit")
end

--[[
	Closes the scanner frame.
--]]
function vendor.ScanFrame.prototype:Hide()
	_Hide(self)
end

--[[
	Updates the gui for displaying the frame (Interface method).
--]]
function vendor.ScanFrame.prototype:UpdateTabFrame()
	log:Debug("UpdateTabFrame")
	AuctionFrameTopLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\Seller-TopLeft")
	AuctionFrameTop:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-Top")
	AuctionFrameTopRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-TopRight")
	AuctionFrameBotLeft:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\Seller-BotLeft")
	AuctionFrameBot:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-Bot")
	AuctionFrameBotRight:SetTexture("Interface\\Addons\\AuctionMaster\\src\\resources\\SearchScanFrame-BotRight")
end

--[[
	Returns the type of this auction house tab.
--]]
function vendor.ScanFrame.prototype:GetTabType()
	return "scanner"
end
	
--[[
	Shows the tabbed frame (Interface method).
--]]
function vendor.ScanFrame.prototype:ShowTabFrame(ommitClear)
	log:Debug("ShowTabFrame")
	if (not ommitClear) then
		self:Clear()
	end
	if (self.frameType == SCAN_FRAME) then
    	self.frame:Show()
    	self.searchFrame:Hide()
    	self:UpdateTabFrame()
	else
    	self.frame:Hide()
    	self.searchFrame:Show()
	end
end

--[[
	Hides the tabbed frame (Interface method).
--]]
function vendor.ScanFrame.prototype:HideTabFrame()
	self.frameType = SEARCH_FRAME
	self.searchFrame:Hide()
	self.frame:Hide()
end

--[[
	Returns the id of the Scanner tab.
--]]
function vendor.ScanFrame.prototype:GetTabId()
	return self.id
end

--[[
	Returns the name of the single selected item, if any. Returns nil, if no item is selected. 
--]]
function vendor.ScanFrame.prototype:GetSingleSelected()
	local map = self.itemModel:GetSelectedItems()
	if (#map > 0) then
		local _, _, _, name = self.itemModel:Get(map[1])
		return name
	end
	return nil
end

function vendor.ScanFrame.prototype:DropDownButtonSelected(button, value)
	vendor.Scanner.db.profile.scanSpeed = value
end

function vendor.ScanFrame.prototype:FullScan()
	_PrepareScan(self)
	_FullScan(self)
end

function vendor.ScanFrame.prototype:SnipeScan()
	_PrepareScan(self)
	_SnipeScan(self)
end

function vendor.ScanFrame.prototype:SearchScan(info)
	_PrepareScan(self)
	local searchScanModules = {vendor.SearchScanModule:new(info)}
	vendor.Scanner:SearchScan(info, false, searchScanModules, _Stop, self)
end

function vendor.ScanFrame.prototype:SnipeItem(name)
	if (not name) then
		local tabType = vendor.AuctionHouse:GetCurrentAuctionHouseTab()
		if (tabType == "list" or tabType == "bidder" or tabType == "owner") then
			if (tabType == "owner") then
				name = vendor.OwnAuctions:GetSingleSelected()
			end
			if (not name) then
    			local index = GetSelectedAuctionItem(tabType)
    			if (index and index > 0) then
    				name = GetAuctionItemInfo(tabType, index)
    			end
    		end
		elseif (tabType == "seller") then
			name = vendor.Seller:GetSelectedItemInfo()
		elseif (tabType == "scanner") then
			name = vendor.Scanner.scanFrame:GetSingleSelected() 
		end
	end
	if (vendor.AuctionHouse:IsAuctionHouseTabShown(self.id)) then
		self.frameType = SEARCH_FRAME
		self:ShowTabFrame(true)
	else
		vendor.AuctionHouse:SelectTab(self.id)
	end
	self.searchFrame:SnipeItem(name)
end

function vendor.ScanFrame.prototype:PickItem(itemLink)
	log:Debug("PickItem frameType [%s]", self.frameType)
	if (self.frameType == SEARCH_FRAME) then
		self.searchFrame:PickItem(itemLink)
	end
end
