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

--[[
	Cell object for rendering textures. Input for the cell is:
	texture, itemLink, count
--]]
vendor.TextureCell = {}
vendor.TextureCell.prototype = {}
vendor.TextureCell.metatable = {__index = vendor.TextureCell.prototype}
setmetatable(vendor.TextureCell.prototype, {__index = vendor.ItemTableCell.prototype})

--[[
	Shows information if mouse is over the selected item
--]]
local function _OnEnterItem(but)
	local self = but.obj
	if (self.item) then
		GameTooltip:SetOwner(but, "ANCHOR_RIGHT")
		GameTooltip.itemCount = self.item.count
		GameTooltip:SetHyperlink(self.item.itemLink)
	end
end

--[[
	Initializes the cell.
--]]
local function _Init(self)
	local but = CreateFrame("Button", nil, self.parent)
	but.obj = self 
	but:SetScript("OnEnter", _OnEnterItem)
	but:SetScript("OnLeave", function() GameTooltip:Hide() end)
	but:SetWidth(self.width)
	but:SetHeight(self.height)
	local fontHeight = 10
	if (self.height >= 19) then
		fontHeight = 11
	end
	local f = but:CreateFontString(nil, "OVERLAY")
	f:SetFont("Fonts\\ARIALN.TTF", fontHeight, "OUTLINE")
	f:SetJustifyH("RIGHT")
	f:SetPoint("BOTTOMRIGHT", 0, 2)
	self.frame = but
	self.count = f
end

--[[ 
	Creates a new instance.
--]]
function vendor.TextureCell:new(parent, width, height)
	local instance = setmetatable({}, self.metatable)
	instance.parent = parent
	instance.width = width
	instance.height = height
	_Init(instance)
	return instance
end

--[[
	Updates the cell with the required input parameters of the cell.
--]]
function vendor.TextureCell.prototype:Update(texture, itemLink, count)
	assert(itemLink)
	assert(count)
	if (self.height >= 16) then
    	if (count > 1) then
    		self.count:SetText(count)
    	else
    		self.count:SetText(nil)
    	end
    else
    	self.count:SetText(nil)
    end
	self.frame:SetNormalTexture(texture)
	self.item = {count = count, itemLink = itemLink}
end
