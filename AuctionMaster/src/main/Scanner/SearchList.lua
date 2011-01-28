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

vendor.SearchList = {}
vendor.SearchList.prototype = {}
vendor.SearchList.metatable = {__index = vendor.SearchList.prototype}

local log = vendor.Debug:new("SearchList")
local L = vendor.Locale.GetInstance()

local SCROLLFRAME_WIDTH = 158
local ROW_WIDTH = 184
local ROW_HEIGHT = 16
local SCROLLBAR_WIDTH = 16
local VISIBLE_ITEMS = 12

local SCROLLBAR_BACKGROUND_COLOR = {r = 0.12, g = 0.12, b = 0.12, a = 0.8}

local SELECT_HIGHLIGHT = "Interface\\Addons\\AuctionMaster\\src\\resources\\Highlight1"

local MAX_ID = 2147483647

local function _MigrateSnipes(self)
	if (not vendor.Scanner.db.factionrealm.oldSnipesMigrated) then
		for k, v in pairs(vendor.Sniper:GetSnipes()) do
			if (k and strlen(k) > 0) then
				local maxBidStr, maxBuyoutStr = strsplit(":", v)
				local bid
				local buyout
				local maxPrice
				if (maxBidStr and strlen(maxBidStr) > 0) then
					maxPrice = tonumber(maxBidStr)
					bid = true
				end
				if (maxBuyoutStr and strlen(maxBuyoutStr) > 0) then
					maxPrice = tonumber(maxBuyoutStr)
					buyout = true
				end
				local info = {saveName = k, name = k, maxPrice = maxPrice, bid = bid, buyout = buyout, snipe = true, classIndex = 0, subclassIndex = 0, rarity = 0, minLevel = 0, maxLevel = 0} 
				self:SaveSearchInfo(info)
				log:Debug("migrate [%s] [%s] [%s]", k, maxBidStr, maxBuyoutStr)
			end
		end
		vendor.Scanner.db.factionrealm.oldSnipesMigrated = true
	end
end

local function _GetSearchInfo(infos, index, snipesOnly)
	if (snipesOnly) then
		local snipes = 0
		local n = #infos
		for i = 1, n do
			if (infos[i].snipe) then
				snipes = snipes + 1
				if (snipes == index) then
					return infos[i]
				end
			end
		end
	end
	return infos[index]
end

local function _OnScrollFrameUpdate(scrollFrame)
	log:Debug("_OnScrollFrameUpdate")
	local self = scrollFrame.obj
	
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	local n = #infos
	if (self.snipesOnly) then
		local off = 0
		for i = 1, n do
			if (infos[i].snipe) then
				off = off + 1
			end
		end
		n = off 
	end
	
	local offset = FauxScrollFrame_GetOffset(scrollFrame)
	local isScrolling = n > VISIBLE_ITEMS
	for i = 1, VISIBLE_ITEMS do
		local index = offset + i
		local row = self.rows[i]
		if (index > n) then
			row:Hide()
		else
			row:Show()
			if (isScrolling) then
				row:SetWidth(ROW_WIDTH - SCROLLBAR_WIDTH)
				row.highlight:SetWidth(ROW_WIDTH - SCROLLBAR_WIDTH)
				row.selectHighlight:SetWidth(ROW_WIDTH - SCROLLBAR_WIDTH)
			else
				row:SetWidth(ROW_WIDTH)
				row.highlight:SetWidth(ROW_WIDTH)
				row.selectHighlight:SetWidth(ROW_WIDTH)
			end
			local info = _GetSearchInfo(infos, index, self.snipesOnly)
			local selected = self.searchScanFrame.searchInfo and info.id == self.searchScanFrame.searchInfo.id  
			if (selected) then
				row.selectHighlight:Show()
			else
				row.selectHighlight:Hide()
			end
			row.label:SetText(info.saveName)
		end
	end
	FauxScrollFrame_Update(self.scrollFrame, n, VISIBLE_ITEMS, ROW_HEIGHT)
end

local function _OnRowClick(row)
	local self = row.obj
	
	local offset = FauxScrollFrame_GetOffset(self.scrollFrame) or 0
	local index = row.id + offset
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	if (index >= 1 and index <= #infos) then
		self.searchScanFrame:SelectSearchInfo(infos[index])
	end
	self:Update()
end

local function _InitFrame(self, frame)
	log:Debug("_InitFrame")
	-- scroll frame
	local name = vendor.GuiTools.EnsureName()
	local scrollFrame = CreateFrame("ScrollFrame", name, frame, "FauxScrollFrameTemplate")
	scrollFrame.obj = self
	--scrollFrame:ClearAllPoints()
	scrollFrame:SetWidth(SCROLLFRAME_WIDTH)
	scrollFrame:SetHeight(200)
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 26, -188)
	scrollFrame:SetScript("OnVerticalScroll", function(this, value) FauxScrollFrame_OnVerticalScroll(this, value, ROW_HEIGHT, _OnScrollFrameUpdate) end)
	scrollFrame:SetScript("OnShow", _OnScrollFrameUpdate)
	
	local scrollbar = _G[name.."ScrollBar"]
	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(scrollbar)
	vendor.GuiTools.SetColor(scrollbg, SCROLLBAR_BACKGROUND_COLOR)
		
	-- rows
	local rows = {}
	local prev
	for i = 1, VISIBLE_ITEMS do
    	local row = CreateFrame("Button", vendor.GuiTools.EnsureName(), frame)
    	row.id = i
    	row.obj = self
    	row:SetWidth(ROW_WIDTH)
    	row:SetHeight(ROW_HEIGHT)
    	row:SetScript("OnClick", _OnRowClick)
    	if (prev) then
    		row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
    	else
    		row:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    	end
    	prev = row
    	
    	local texture = row:CreateTexture()
    	texture:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
    	texture:SetWidth(ROW_WIDTH)
    	texture:SetHeight(ROW_HEIGHT)
    	texture:SetPoint("TOPLEFT", -4, 0)
    	texture:SetTexCoord(0, 1.0, 0, 0.578125)
    	row:SetHighlightTexture(texture, "ADD")
    	row.highlight = texture

    	local texture = row:CreateTexture()
    	texture:SetTexture(SELECT_HIGHLIGHT)
    	texture:SetWidth(ROW_WIDTH)
    	texture:SetHeight(ROW_HEIGHT)
    	texture:SetPoint("TOPLEFT", -4, 0)
    	texture:SetTexCoord(0, 1.0, 0, 0.578125)
    	texture:Hide()
    	row.selectHighlight = texture

    	local f = row:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
		f:SetAllPoints(row)
		f:SetJustifyH("LEFT")
		row.label = f
		
    	table.insert(rows, row)
	end
	
	-- remember objects
	self.scrollFrame = scrollFrame
	self.rows = rows
	
	-- first update
	_OnScrollFrameUpdate(scrollFrame)
end

local function _InitClass(info)
	if (info.classIndex > 0) then
		info.class = select(info.classIndex, GetAuctionItemClasses())
	else
		info.class = nil
	end
	if (info.classIndex > 0 and info.subclassIndex > 0) then
		info.subclass = select(info.subclassIndex, GetAuctionItemSubClasses(info.classIndex))
	else
		info.subclass = nil
	end
end

-- Calculate the fresh localizations of the class indices
local function _InitClasses(self)
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	for i = 1, #infos do
		_InitClass(infos[i])
	end
end

--[[ 
	Creates a new instance.
--]]
function vendor.SearchList:new(searchScanFrame)
	local instance = setmetatable({}, self.metatable)
	instance.searchScanFrame = searchScanFrame
	_InitClasses(instance)
	_InitFrame(instance, searchScanFrame.frame)
	_MigrateSnipes(instance)
	return instance
end

function vendor.SearchList.prototype:SaveSearchInfo(info)
	log:Debug("SaveSearchInfo id [%s]", info.id)
	_InitClass(info)
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	local handled
	if (not info.id) then
		info.id = math.random(MAX_ID)
		table.insert(infos, info)
		handled = true
	end
	if (not handled) then
    	for i = 1, #infos do
    		if (infos[i].id == info.id) then
    			infos[i] = info
    			handled = true
    			break
    		end
    	end
	end
	if (not handled) then
		table.insert(infos, info)
	end
	table.sort(vendor.Scanner.db.factionrealm.searchInfos, function(a,b)
			return a.saveName < b.saveName
		end
	)
	self:Update()
end

function vendor.SearchList.prototype:DeleteSearchInfo(info)
	local infos = vendor.Scanner.db.factionrealm.searchInfos
	if (#infos > 0 and info.id) then
    	for i = 1, #infos do
    		if (infos[i].id == info.id) then
    			table.remove(infos, i)
    			break
    		end
    	end
	end
	self:Update()
end

function vendor.SearchList.prototype:Update()
	_OnScrollFrameUpdate(self.scrollFrame)
end

function vendor.SearchList.prototype:SetSnipesOnly(snipesOnly)
	self.snipesOnly = snipesOnly
	self:Update()
end