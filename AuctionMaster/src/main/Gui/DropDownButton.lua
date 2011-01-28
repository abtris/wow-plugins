--[[
	Wraps a dropdown button.
	
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

vendor.DropDownButton = {}
vendor.DropDownButton.prototype = {}
vendor.DropDownButton.metatable = {__index = vendor.DropDownButton.prototype}

local log = vendor.Debug:new("DropDownButton")

--[[
	Update function for being able to show incorrect values.
--]]
local function _OnUpdate(self)
	if (self.title) then
		if (self.valid or not self.validating) then
			self.title:SetTextColor(1, 1, 1, 1)
		else
			self.title:SetTextColor(1, 0, 0, 1)
		end
	end
end

--[[
	Returns the currently selected/typed value
--]]
local function _GetSelectedValue(self)
	if (self.editBox) then	
		if (self.numeric) then
			local txt = self.editBox:GetText()
			if (vendor.isnumber(txt)) then
				return tonumber(txt)
			end
			return txt 
		end
		return self.editBox:GetText()
	end
	return UIDropDownMenu_GetSelectedValue(self.button)
end

--[[
	Checks whether the current value is in range, and adapts it, if not.
--]]
local function _CheckRange(self)
	if (self.editBox and self.numeric) then
		local txt = self.editBox:GetText()
		if (vendor.isnumber(txt)) then
			local val = tonumber(txt)
			log:Debug("_CheckRange val: %d", val)
			self.valid = true
			if (self.minNumeric and self.minNumeric > val) then
				self.valid = false
			end
			if (self.maxNumeric and self.maxNumeric < val) then
				self.valid = false
			end
		end
	end
end

--[[
	A new value has been typed.
--]]
local function _OnEditBoxUpdate(self)
	log:Debug("_OnEditBoxUpdate id: %d", self.id or -1)
	local val = _GetSelectedValue(self)
	if (self.numeric) then
		if (vendor.isnumber(val)) then
			_CheckRange(self)
		else
			self.valid = self.exclusions and self.exclusions[val]
		end
	end
	if (self.valid and self.listener and self.listener.DropDownButtonSelected) then
		self.listener:DropDownButtonSelected(self, val)
	end
end

--[[
	Set new focus.
--]]
local function _OnEditBoxTabPressed(self)
	self.editBox:ClearFocus()
	if (IsShiftKeyDown()) then
		if (self.prevFocus and self.prevFocus.SetFocus) then
			self.prevFocus:SetFocus()
		end
	elseif (self.nextFocus and self.nextFocus.SetFocus) then
		self.nextFocus:SetFocus()
	end
end

--[[
	Select all, if the focus has been gained.
--]]
local function _OnEditFocusGained(self)
	self.editBox:HighlightText()
end

--[[
	Callback for selecting items.
--]]
local function _DropDownOnClick(but, arg1, arg2)
	local self = arg1
	log:Debug("_DropDownOnClick id: %d", self.id or -1)
	UIDropDownMenu_SetSelectedValue(self.button, but.value)
	if (self.editBox) then
		log:Debug("_DropDownOnClick set editBox to: %s", tostring(but.value))
		self.editBox:SetText(but.value)
		self.valid = true
	end
	if (self.listener and self.listener.DropDownButtonSelected) then
		self.listener:DropDownButtonSelected(self, but.value)
	end
end

--[[
	Callback for initializing a dropdown button.
--]]
local function _DropDownInitialize(button)
	local info = UIDropDownMenu_CreateInfo();
	info.owner = button:GetParent();
	info.func = _DropDownOnClick;
	info.arg1 = button.ctrl;
	for key, value in ipairs(button.ctrl.items) do
		if (type(value) == "table") then
			info.text = value.text;
			info.value = value.value;
		else
			info.text = value;
			info.value = value;			
		end
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

--[[ 
	Creates a new instance.
--]]
function vendor.DropDownButton:new(name, parent, width, title, tooltipText)
	local instance = setmetatable({}, self.metatable)
	name = vendor.GuiTools.EnsureName(name)
	instance.button = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
	instance.valid = true
	UIDropDownMenu_SetWidth(instance.button, width)
	if (title) then
		local f = instance.button:CreateFontString(name.."Name", "OVERLAY", "GameFontHighlightSmall")
		f:SetText(title)
		f:SetPoint("BOTTOMLEFT", name, "TOPLEFT", 20, 0)
		instance.title = f
	end
	if (tooltipText) then
		local bt = getglobal(name.."Button")
		vendor.GuiTools.AddTooltip(bt, tooltipText)
	end
	instance.button.ctrl = instance
	instance.button.obj = instance
	instance.button:SetScript("OnUpdate", function(but) _OnUpdate(but.ctrl) end)
	instance:Clear()
	return instance
end

--[[
	Sets a unique identifier for the button.
--]]
function vendor.DropDownButton.prototype:SetId(id)
	self.id = id;
end

--[[
	Returns the identifier of the button, if any.
--]]
function vendor.DropDownButton.prototype:GetId()
	return self.id;
end

--[[
	Sets a listener for selection changes. The listener has to implement the method
	"DropDownButtonSelected" with the following synopsis:
	@param button The corresponding DropDownButton
	@param value The selected value
--]]
function vendor.DropDownButton.prototype:SetListener(listener)
	self.listener = listener;
end

--[[
	Sets the position of the button.
--]]
function vendor.DropDownButton.prototype:SetPoint(...)
	self.button:SetPoint(...);
end

--[[
	Clears the list of selectable items
--]]
function vendor.DropDownButton.prototype:Clear()
	self.items = {};
	UIDropDownMenu_ClearAll(self.button);
end

--[[
	Sets the list of selectable items from the given table.
--]]
function vendor.DropDownButton.prototype:SetItems(itemTable, selectedValue)
	self.items = itemTable;
	self:SelectValue(selectedValue);
	self.valid = true
end

--[[
	Selects the given value, that should be in the value list.
--]]
function vendor.DropDownButton.prototype:SelectValue(item)
	log:Debug("SelectValue id: %d", self.id or -1)
	-- I don't know, why I have to initialize all the time for that :-(
	UIDropDownMenu_Initialize(self.button, _DropDownInitialize);
	if (item) then
		UIDropDownMenu_SetSelectedValue(self.button, item)
		if (self.editBox) then
			local val = UIDropDownMenu_GetSelectedValue(self.button)
			log:Debug("SelectValue set editBox to %s", val)
			self.editBox:SetText(val)
		end
	end
end

--[[
	Returns the currently selected value.
--]]
function vendor.DropDownButton.prototype:GetSelectedValue()
	return _GetSelectedValue(self)
end

--[[
	Selects whether the dropdown value should be editable.
--]]
function vendor.DropDownButton.prototype:SetEditable(editable)
	self.editable = editable
	local name = self.button:GetName()
	if (self.editable) then
		_G[name.."Text"]:Hide()
		_G[name.."Left"]:Hide()
		_G[name.."Middle"]:Hide()
		_G[name.."Right"]:Hide()
		local editBox = CreateFrame("EditBox", name.."EditBox", self.button, "InputBoxTemplate")
		editBox:SetAutoFocus(false)
		editBox:SetJustifyH("LEFT")
		editBox:SetHeight(12)
		editBox:SetPoint("LEFT", name, 25, 2)
		editBox:SetPoint("RIGHT", name, -35, 2)
		editBox.obj = self
		editBox:SetScript("OnTextChanged", function(but) _OnEditBoxUpdate(but.obj) end)
		editBox:SetScript("OnTabPressed", function(but) _OnEditBoxTabPressed(but.obj) end)
		editBox:SetScript("OnEditFocusGained", function(but) _OnEditFocusGained(but.obj) end)
		_G[name.."Button"]:ClearAllPoints()
		_G[name.."Button"]:SetPoint("LEFT", name.."EditBox", "RIGHT", -2, 0)
		self.editBox = editBox
	else
		self.editBox = nil
		_G[name.."Text"]:Show()
		_G[name.."Left"]:Show()
		_G[name.."Middle"]:Show()
		_G[name.."Right"]:Show()
		_G[name.."Button"]:ClearAllPoints()
		_G[name.."Button"]:SetPoint("TOPRIGHT", name.."Right", -16, -18)
	end
end

--[[
	Selects numerical mode for the optional edit box.
--]]
function vendor.DropDownButton.prototype:SetNumeric(numeric)
	self.numeric = true
	self.minNumeric = nil
	self.maxNumeric = nil
	self.exclusions = nil
	self.editBox:SetNumeric(true)
end

--[[
	Sets an optional range for numerical values.
--]]
function vendor.DropDownButton.prototype:SetRange(min, max, exclusions)
	self.minNumeric = min
	self.maxNumeric = max
	self.exclusions = exclusions
	if (self.exclusions) then
		self.editBox:SetNumeric(false)
	else
		self.editBox:SetNumeric(true)
	end
	_CheckRange(self)
end

--[[
	Returns whether the currentvalue seems to be valid.
--]]
function vendor.DropDownButton.prototype:IsValid()
	return self.valid
end

--[[
	Selects whether the dropdown should validate the values. Needed for the startup
	where the value is still empty.
--]]
function vendor.DropDownButton.prototype:SetValidating(validating)
	self.validating = validating
end

--[[
	Next EditBox to be focused.
--]]
function vendor.DropDownButton.prototype:SetNextFocus(nextFocus)
	self.nextFocus = nextFocus
end

--[[
	Previous EditBox to be focused.
--]]
function vendor.DropDownButton.prototype:SetPrevFocus(prevFocus)
	self.prevFocus = prevFocus
end

--[[
	Returns the optional EditBox for focus rules.
--]] 
function vendor.DropDownButton.prototype:GetEditBox()
	if (self.editBox) then
		return self.editBox
	end
	return nil
end

--[[
	Clears the focus of any edit box.
--]]
function vendor.DropDownButton.prototype:ClearFocus()
	if (self.editBox) then
		self.editBox:ClearFocus()
	end
end

--[[
	Enables or diables the dropdown.
--]]
function vendor.DropDownButton.prototype:SetEnabled(enabled)
	if (enabled) then
		UIDropDownMenu_EnableDropDown(self.button)
	else
		UIDropDownMenu_DisableDropDown(self.button)
	end
end

function vendor.DropDownButton.prototype:Enable()
	self:SetEnabled(true)
end

function vendor.DropDownButton.prototype:Disable()
	self:SetEnabled(false)
end