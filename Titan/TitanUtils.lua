Titan__InitializedPEW = nil
Titan__Initialized_Settings = nil

TITAN_PANEL_NONMOVABLE_PLUGINS = {};
TITAN_PANEL_MENU_FUNC_HIDE = "TitanPanelRightClickMenu_Hide";
TitanPlugins = {};  -- Used by plugins
TitanPluginsIndex = {};
TITAN_NOT_REGISTERED = _G["RED_FONT_COLOR_CODE"].."Not_Registered_Yet".._G["FONT_COLOR_CODE_CLOSE"]
TITAN_REGISTERED = _G["GREEN_FONT_COLOR_CODE"].."Registered".._G["FONT_COLOR_CODE_CLOSE"]
TITAN_REGISTER_FAILED = _G["RED_FONT_COLOR_CODE"].."Failed_to_Register".._G["FONT_COLOR_CODE_CLOSE"]

local _G = getfenv(0);
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local media = LibStub("LibSharedMedia-3.0")

-- The routines are useable by plugin developers
-- until the sections listed as Titan ONLY.
--
--
-- Plugin button search & manipulation routines
--
function TitanUtils_GetButton(id) -- Used by plugins
	-- Return the actual button name and the plugin name
	if (id) then
		return _G["TitanPanel"..id.."Button"], id;
	else
		return nil, nil;
	end
end

function TitanUtils_GetRealPosition(id) -- Used by plugins
	-- Get which bar the plugin is on.
	
	-- This will return top / bottom but it is a compromise.
	-- With the introduction of independent bars there is
	-- more than just top / bottom.
	-- This should work in the sense that the plugins using this 
	-- would overlap the double bar.
	local bar = TitanUtils_GetWhichBar(id)
	local bar_pos = nil
	for idx,v in pairs (TitanBarData) do
		if bar == TitanBarData[idx].name then
			bar_pos = TitanBarData[idx].vert
		end
	end
	-- This will return bottom(2) or top(1)-default
	return (bar_pos == TITAN_BOTTOM and TITAN_PANEL_PLACE_BOTTOM or TITAN_PANEL_PLACE_TOP)
end

function TitanUtils_GetButtonID(name)
	if name then
		local s, e, id = string.find(name, "TitanPanel(.*)Button");
		return id;
	else
		return nil;
	end
end

function TitanUtils_GetParentButtonID(name)
	local frame = TitanUtils_Ternary(name, _G[name], nil);

	if ( frame and frame:GetParent() ) then
		return TitanUtils_GetButtonID(frame:GetParent():GetName());
	end
end

function TitanUtils_GetButtonIDFromMenu(self)
	if self and self:GetParent() then
		local name = self:GetParent():GetName()
		local s, e, id = string.find(name, TITAN_PANEL_DISPLAY_PREFIX);
		if not s == nil then
			return "Bar";
		elseif self:GetParent():GetParent():GetName() then  
			-- TitanPanelChildButton     			
			return TitanUtils_GetButtonID(self:GetParent():GetParent():GetName());		
		else		
			-- TitanPanelButton
			return TitanUtils_GetButtonID(self:GetParent():GetName());		
		end	
	end
end

function TitanUtils_GetPlugin(id)
	-- Return the plugin data
	if (id) then
		return TitanPlugins[id];
	else
		return nil;
	end
end

function TitanUtils_GetWhichBar(id)
	-- Get which bar the plugin is on.
	local i = TitanPanel_GetButtonNumber(id);
	if TitanPanelSettings.Location[i] == nil then
		return
	else
		return TitanPanelSettings.Location[i];
	end
end

function TitanUtils_ToRight(id)
--[[ doc
-- See if the plugin is to be on the right.
-- There are 3 methods to place a plugin on the right:
-- 1) DisplayOnRightSide saved variable logic (preferred)
-- 2) Create a plugin button using the TitanPanelIconTemplate
-- 3) Place a plugin in TITAN_PANEL_NONMOVABLE_PLUGINS (NOT preferred)
--]]
	local found = nil
	for index, _ in ipairs(TITAN_PANEL_NONMOVABLE_PLUGINS) do
		if id == TITAN_PANEL_NONMOVABLE_PLUGINS[index] then
			found = true;
		end
	end

	if TitanGetVar(id, "DisplayOnRightSide")
	or TitanPanelButton_IsIcon(id) 
	then
		found = true
	end
	
	return found
end

--
-- General util routines
--
function TitanUtils_Ternary(a, b, c) -- Used by plugins
	if (a) then
		return b;
	else
		return c;
	end
end

function TitanUtils_Toggle(value) -- Used by plugins
	if (value == 1 or value == true) then
		return nil;
	else
		return 1;
	end
end

function TitanUtils_Min(a, b)
	if (a and b) then
--		return ( a < b ) and a or b
		return TitanUtils_Ternary((a < b), a, b);
	end
end

function TitanUtils_Max(a, b)
	if (a and b) then
		return TitanUtils_Ternary((a > b), a, b);
---		return ( a > b ) and a or b
	end
end

local function GetTimeParts(s)
	local days = 0
	local hours = 0
	local minutes = 0
	local seconds = 0
	if not s or (s < 0) then
		seconds = L["TITAN_NA"]
	else
		days = floor(s/24/60/60); s = mod(s, 24*60*60);
		hours = floor(s/60/60); s = mod(s, 60*60);
		minutes = floor(s/60); s = mod(s, 60);
		seconds = s;
	end
	
	return days, hours, minutes, seconds
end

function TitanUtils_GetEstTimeText(s)
	local timeText = "";
	days, hours, minutes, seconds = GetTimeParts(s)
	if seconds == L["TITAN_NA"] then
		timeText = L["TITAN_NA"];
	else
		if (days ~= 0) then
			timeText = timeText..format("%d"..L["TITAN_DAYS_ABBR"].." ", days);
		elseif (days ~= 0 or hours ~= 0) then
			timeText = timeText..format("%d"..L["TITAN_HOURS_ABBR"].." ", hours);
		elseif (days ~= 0 or hours ~= 0 or minutes ~= 0) then
			timeText = timeText..format("%d"..L["TITAN_MINUTES_ABBR"].." ", minutes);
		else
			timeText = timeText..format("%d"..L["TITAN_SECONDS_ABBR"], seconds);
		end	
	end
	return timeText;
end

function TitanUtils_GetFullTimeText(s)
	days, hours, minutes, seconds = GetTimeParts(s)
	if seconds == L["TITAN_NA"] then
		return L["TITAN_NA"];
	else
		return format("%d"..L["TITAN_DAYS_ABBR"]
			..", %2d"..L["TITAN_HOURS_ABBR"]
			..", %2d"..L["TITAN_MINUTES_ABBR"]
			..", %2d"..L["TITAN_SECONDS_ABBR"],
				days, hours, minutes, seconds);
	end
end

function TitanUtils_GetAbbrTimeText(s) -- Used by plugins
	local timeText = "";
	days, hours, minutes, seconds = GetTimeParts(s)
	if seconds == L["TITAN_NA"] then
		timeText = L["TITAN_NA"];
	else
		if (days ~= 0) then
			timeText = timeText..format("%d"..L["TITAN_DAYS_ABBR"].." ", days);
		end
		if (days ~= 0 or hours ~= 0) then
			timeText = timeText..format("%d"..L["TITAN_HOURS_ABBR"].." ", hours);
		end
		if (days ~= 0 or hours ~= 0 or minutes ~= 0) then
			timeText = timeText..format("%d"..L["TITAN_MINUTES_ABBR"].." ", minutes);
		end	
		timeText = timeText..format("%d"..L["TITAN_SECONDS_ABBR"], seconds);
	end
	return timeText;
end

function TitanUtils_GetControlFrame(id)
	if (id) then
		return _G["TitanPanel"..id.."ControlFrame"];
	else
		return nil;
	end
end

function TitanUtils_TableContainsValue(table, value)
	if (table and value) then
		for i, v in pairs(table) do
			if (v == value) then
				return i;
			end
		end
	end
end

function TitanUtils_TableContainsIndex(table, index)
	if (table and index) then
		for i, v in pairs(table) do
			if (i == index) then
				return i;
			end
		end
	end
end

function TitanUtils_GetCurrentIndex(table, value)
	return TitanUtils_TableContainsValue(table, value);
end

function TitanUtils_PrintArray(array) 
	if (not array) then
		TitanDebug("array is nil");
	else
		TitanDebug("{");
		for i, v in array do
			TitanDebug("array[" .. tostring(i) .. "] = " .. tostring(v));
		end
		TitanDebug("}");
	end
	
end

function TitanUtils_GetRedText(text) -- Used by plugins
	if (text) then
		return _G["RED_FONT_COLOR_CODE"]..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetGoldText(text)
	if (text) then
		return "|cffffd700"..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetGreenText(text) -- Used by plugins
	if (text) then
		return _G["GREEN_FONT_COLOR_CODE"]..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetBlueText(text)
	if (text) then
		return "|cff0000ff"..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetNormalText(text) -- Used by plugins
	if (text) then
		return _G["NORMAL_FONT_COLOR_CODE"]..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetHighlightText(text) -- Used by plugins
	if (text) then
		return _G["HIGHLIGHT_FONT_COLOR_CODE"]..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetColoredText(text, color) -- Used by plugins
	if (text and color) then
		local redColorCode = format("%02x", color.r * 255);		
		local greenColorCode = format("%02x", color.g * 255);
		local blueColorCode = format("%02x", color.b * 255);		
		local colorCode = "|cff"..redColorCode..greenColorCode..blueColorCode;
		return colorCode..text.._G["FONT_COLOR_CODE_CLOSE"];
	end
end

function TitanUtils_GetThresholdColor(ThresholdTable, value)
	if ( not tonumber(value) or type(ThresholdTable) ~= "table" 
	or ThresholdTable.Values == nil or ThresholdTable.Colors == nil
	or table.getn(ThresholdTable.Values) >= table.getn(ThresholdTable.Colors)
	) then
		return _G["GRAY_FONT_COLOR"];
	end

	local n = table.getn(ThresholdTable.Values) + 1;
	for i = 1, n do 
		local low = TitanUtils_Ternary(i == 1, nil, ThresholdTable.Values[i-1]);
		local high = TitanUtils_Ternary(i == n, nil, ThresholdTable.Values[i]);
		
		if ( not low and not high ) then
			-- No threshold values
			return ThresholdTable.Colors[i];
			
		elseif ( not low and high ) then
			-- Value is smaller than the first threshold			
			if ( value < high ) then return ThresholdTable.Colors[i] end
			
		elseif ( low and not high ) then
			-- Value is larger than the last threshold
			if ( low <= value ) then return ThresholdTable.Colors[i] end
			
		else
			-- Value is in between 2 adjacent thresholds
			if ( low <= value and value < high ) then 
				return ThresholdTable.Colors[i]
			end
		end
	end
	
	-- Should never reach here
	return _G["GRAY_FONT_COLOR"];
end

function TitanUtils_ToString(text) 
	return TitanUtils_Ternary(text, text, "");
end

--
-- Right click menu routines for plugins
-- The expected global function name in the plugin is:
-- "TitanPanelRightClickMenu_Prepare"..<registry.id>.."Menu"
--
function TitanPanelRightClickMenu_AddTitle(title, level)
	if (title) then
		local info = {};
		info.text = title;
		info.notCheckable = true;
		info.notClickable = true;
		info.isTitle = 1;
		UIDropDownMenu_AddButton(info, level);
	end
end

function TitanPanelRightClickMenu_AddCommand(text, value, functionName, level)
	local info = {};
	info.notCheckable = true;
	info.text = text;
	info.value = value;
	info.func = function()
	local callback = _G[functionName];
-- callback must be a function else do nothing (spank developer)
		if callback and type(callback)== "function" then 
			callback(value)
		end
	end
	UIDropDownMenu_AddButton(info, level);
end

function TitanPanelRightClickMenu_AddSpacer(level)
	local info = {};
	info.notCheckable = true;
	info.notClickable = true;
	info.disabled = 1;
	UIDropDownMenu_AddButton(info, level);
end

function TitanPanelRightClickMenu_Hide(value) 
	TitanPanel_RemoveButton(value);
end

function TitanPanelRightClickMenu_AddToggleVar(text, id, var, toggleTable)
	local info = {};
	info.text = text;
	info.value = {id, var, toggleTable};
	info.func = function()
		TitanPanelRightClickMenu_ToggleVar({id, var, toggleTable})
	end
	info.checked = TitanGetVar(id, var);
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);
end

function TitanPanelRightClickMenu_AddToggleIcon(id)
	TitanPanelRightClickMenu_AddToggleVar(L["TITAN_PANEL_MENU_SHOW_ICON"]
		, id, "ShowIcon");
end

function TitanPanelRightClickMenu_AddToggleLabelText(id)
	TitanPanelRightClickMenu_AddToggleVar(L["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"]
		, id, "ShowLabelText");
end

function TitanPanelRightClickMenu_AddToggleColoredText(id)
	TitanPanelRightClickMenu_AddToggleVar(L["TITAN_PANEL_MENU_SHOW_COLORED_TEXT"]
		, id, "ShowColoredText");
end

function TitanPanelRightClickMenu_ToggleVar(value)
	local id, var, toggleTable = nil, nil, nil;
	
	-- table expected else do nothing  
	if type(value)~="table" then return end
	
	if value and value[1] then id = value[1] end
	if value and value[2] then var = value[2] end
	if value and value[3] then toggleTable = value[3] end

	-- Toggle var
	TitanToggleVar(id, var);
	
	if ( TitanPanelRightClickMenu_AllVarNil(id, toggleTable) ) then
		-- Undo if all vars in toggle table nil
		TitanToggleVar(id, var);
	else
		-- Otherwise continue and update the button
		TitanPanelButton_UpdateButton(id, 1);
	end
end

function TitanPanelRightClickMenu_AllVarNil(id, toggleTable)
	if ( toggleTable ) and type(toggleTable)== "table" then
		for i, v in toggleTable do
			if ( TitanGetVar(id, v) ) then
				return nil;
			end
		end	
		return 1;
	end	
end

function TitanPanelRightClickMenu_ToggleColoredText(value)
	TitanToggleVar(value, "ShowColoredText");
	TitanPanelButton_UpdateButton(value, 1);
end

--
-- The routines below are for Titan Panel ONLY
--

--
-- Plugin manipulation routines
--
local function TitanUtils_SwapButtonOnBar(from_id, to_id)
	-- Used as part of the shift L / R to swap the buttons
	local button = TitanPanelSettings.Buttons[from_id]
	local locale = TitanPanelSettings.Location[from_id]
	
	TitanPanelSettings.Buttons[from_id] = TitanPanelSettings.Buttons[to_id]
	TitanPanelSettings.Location[from_id] = TitanPanelSettings.Location[to_id]
	TitanPanelSettings.Buttons[to_id] = button
	TitanPanelSettings.Location[to_id] = locale
	TitanPanel_InitPanelButtons();
end

local function TitanUtils_GetNextButtonOnBar(bar, id, side)
	-- find the next button that is on the same bar and is on the same side
	-- return nil if not found
	local index = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons, id);
	
	for i, id in pairs(TitanPanelSettings.Buttons) do
		if TitanUtils_GetWhichBar(id) == bar 
		and i > index 
		and TitanPanel_GetPluginSide(id) == side then
			return i;
		end
	end
end

local function TitanUtils_GetPrevButtonOnBar(bar, id, side)
	-- find the prev button that is on the same bar and is on the same side
	-- return nil if not found
	local index = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons, id);
	local prev_idx = nil
	
	for i, id in pairs(TitanPanelSettings.Buttons) do
		if TitanUtils_GetWhichBar(id) == bar 
		and i < index 
		and TitanPanel_GetPluginSide(id) == side then
			prev_idx = i; -- this might be the previous button
		end
		if i == index then
			return prev_idx;
		end
	end
end

function TitanUtils_AddButtonOnBar(bar, id)
	-- Add the button to the requested bar - bar / aux if shown
	if (not bar)
	or (not id) 
	or (not TitanPanelSettings) 
	or (not TitanPanelGetVar(bar.."_Show"))
	then
		return;
	end 

	local i = TitanPanel_GetButtonNumber(id)
	if TitanPanelSettings.Location[i] == nil then
		-- add the plugin
		table.insert(TitanPanelSettings.Buttons, id);
	else
	end
	-- The _GetButtonNumber returns +1 if not found so it is 'safe' to 
	-- update / add to the Location
	TitanPanelSettings.Location[i] = (bar or "Bar")
	TitanPanel_InitPanelButtons();
end

function TitanUtils_GetFirstButtonOnBar(bar, side)
	-- find the first button that is on the same bar and is on the same side
	-- return nil if not found
	local index = 0
	
	for i, id in pairs(TitanPanelSettings.Buttons) do
		if TitanUtils_GetWhichBar(id) == bar 
		and i > index 
		and TitanPanel_GetPluginSide(id) == side then
			return i;
		end
	end
end

function TitanUtils_ShiftButtonOnBarLeft(name)
	-- Find the button to the left. If there is one, swap it in the array
	local from_idx = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons,name)
	local side = TitanPanel_GetPluginSide(name)
	local bar = TitanUtils_GetWhichBar(name)
	
	-- buttons on Left are placed L to R; 
	-- buttons on Right are placed R to L
	if side and side == TITAN_LEFT then
		to_idx = TitanUtils_GetPrevButtonOnBar (TitanUtils_GetWhichBar(name), name, side)
	elseif side and side == TITAN_RIGHT then
		to_idx = TitanUtils_GetNextButtonOnBar (TitanUtils_GetWhichBar(name), name, side)
	end
	
	if to_idx then
		TitanUtils_SwapButtonOnBar(from_idx, to_idx);
	else
		return
	end
end

function TitanUtils_ShiftButtonOnBarRight(name)
	-- Find the button to the right. If there is one, swap it in the array
	local from_idx = TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons,name)
	local to_idx = nil
	local side = TitanPanel_GetPluginSide(name)
	local bar = TitanUtils_GetWhichBar(name)
	
	-- buttons on Left are placed L to R; 
	-- buttons on Right are placed R to L
	if side and side == TITAN_LEFT then
		to_idx = TitanUtils_GetNextButtonOnBar (bar, name, side)
	elseif side and side == TITAN_RIGHT then
		to_idx = TitanUtils_GetPrevButtonOnBar (bar, name, side)
	end
	
	if to_idx then
		TitanUtils_SwapButtonOnBar(from_idx, to_idx);
	else
		return
	end
end

--
-- Frame check & manipulation routines
--
function TitanUtils_CheckFrameCounting(frame, elapsed)
	if (frame:IsVisible()) then
		if (not frame.frameTimer or not frame.isCounting) then
			return;
		elseif ( frame.frameTimer < 0 ) then
			frame:Hide();
			frame.frameTimer = nil;
			frame.isCounting = nil;
		else
			frame.frameTimer = frame.frameTimer - elapsed;
		end
	end
end

function TitanUtils_StartFrameCounting(frame, frameShowTime)
	frame.frameTimer = frameShowTime;
	frame.isCounting = 1;
end

function TitanUtils_StopFrameCounting(frame)
	frame.isCounting = nil;
end

function TitanUtils_CloseAllControlFrames()
	for index, value in pairs(TitanPlugins) do
		local frame = _G["TitanPanel"..index.."ControlFrame"];
		if (frame and frame:IsVisible()) then
			frame:Hide();
		end
	end
end

function TitanUtils_IsAnyControlFrameVisible() -- need?
	for index, value in TitanPlugins do
		local frame = _G["TitanPanel"..index.."ControlFrame"];
		if (frame:IsVisible()) then
			return true;
		end
	end
	return false;
end

function TitanUtils_GetOffscreen(frame)
	local offscreenX, offscreenY;
	local ui_scale = UIParent:GetEffectiveScale()
	if not frame then
		return
	end
	local fr_scale = frame:GetEffectiveScale()

	if ( frame and frame:GetLeft() 
	and frame:GetLeft() * fr_scale < UIParent:GetLeft() * ui_scale ) then
		offscreenX = -1;
	elseif ( frame and frame:GetRight() 
	and frame:GetRight() * fr_scale > UIParent:GetRight() * ui_scale ) then
		offscreenX = 1;
	else
		offscreenX = 0;
	end

	if ( frame and frame:GetTop() 
	and frame:GetTop() * fr_scale > UIParent:GetTop() * ui_scale ) then
		offscreenY = -1;
	elseif ( frame and frame:GetBottom() 
	and frame:GetBottom() * fr_scale < UIParent:GetBottom() * ui_scale ) then
		offscreenY = 1;
	else
		offscreenY = 0;
	end
	
	return offscreenX, offscreenY;
end

--
-- Plugin registration routines
--
function TitanUtils_PluginToRegister(self, isChildButton) 
--[[ doc
	-- NOTE: registry is part of 'self' (the Titan button frame) which works 
	-- great for Titan specific plugins.
	-- Titan plugins create the registry as part of the frame _OnLoad.
	-- But this does not work for LDB buttons. The frame is created THEN the 
	-- registry is added to the frame.
	-- 
	-- Any read of the registry must assume 
	-- it may not exist. Also assume the registry could be updated after 
	-- this routine.
	--
	-- This is called when a Titan button frame is created.
	-- Normally these are held until the player 'enters world' then the
	-- plugin is registered.
	-- Sometimes plugin frames are created after this process. Right
	-- now only LDB plugins are handled. If someone where to start creating 
	-- Titan frames after the registration process were complete then
	-- it would fail to be registered...
	-- NOTE: For LDB plugins the 'registry' is attached to the frame 
	-- AFTER the frame is created...
--]]
	TitanPluginToBeRegisteredNum = TitanPluginToBeRegisteredNum + 1
	local cat = ""
	local notes = ""
	if self and self.registry then
		cat = (self.registry.category or "")
		notes = (self.registry.notes or "")
	end
	-- Some of the fields in this record are displayed in the "Attempts"
	-- so they are defaulted here.
	TitanPluginToBeRegistered[TitanPluginToBeRegisteredNum] = {
		self = self,
		button = ((self and self:GetName() 
			or "Nyl".."_"..TitanPluginToBeRegisteredNum)),
		isChild = (isChildButton and true or false),
		-- fields below are updated when registered
		name = "?",
		issue = "", 
		status = TITAN_NOT_REGISTERED,
		category = cat,
		plugin_type = "",
		notes = notes,
	}
end

function TitanUtils_PluginFail(plugin) 
--[[ doc
	-- This is called when a plugin is unsupported.
	-- It is intended mainly for developers. It is a place to put relevant info
	-- for debug and so users can supply troubleshooting info.
	-- The key is set the status to 'fail' so there is no further attempt to 
	-- register the plugin.
	--
	-- plugin is expected to hold as much relevant info as possible...
--]]
	TitanPluginToBeRegisteredNum = TitanPluginToBeRegisteredNum + 1
	TitanPluginToBeRegistered[TitanPluginToBeRegisteredNum] = 
		{
		self = plugin.self,
		button = (plugin.button and plugin.button:GetName() or ""),
		isChild = (plugin.isChild and true or false),
		name = (plugin.name or "?"),
		issue = (plugin.issue or "?"), 
		status = TITAN_REGISTER_FAILED,
		category = (plugin.category or ""),
		plugin_type = (plugin.plugin_type or ""),
		}
end

local function TitanUtils_RegisterPluginProtected(plugin)
--[[ doc
	-- This is called using pcall (protected call).
	-- We try to anticipate the various ways a plugin could
	-- fail to register.
	-- The intent is to keep Titan whole so a plugin does not 
	-- prevent Tian from loading.
	-- And attempt to tell the user / developer what went wrong.
	-- See the return below for the usage of returned fields.
--]]
	local result = nil
	local issue = nil
	local id = nil
	local cat = nil
	local notes = ""
	
	local self = plugin.self
	local isChildButton = (plugin.isChild and true or false)
	
	if self and self:GetName() then
		if (isChildButton) then
			-- This is a button within a button
			self:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
			self:RegisterForDrag("LeftButton")
			TitanPanelDetectPluginMethod(self:GetName(), true);
			result = TITAN_REGISTERED
			-- give some indication that this is valid...
			id = (self:GetName() or "").."<child>" 
		else 
			-- Check for the .registry where all the Titan plugin info is expected
			if (self.registry and self.registry.id) then
				id = self.registry.id
				if TitanUtils_IsPluginRegistered(id) then
					-- We have already registered this plugin!
					issue =  "Plugin already loaded."
				else
					-- A sanity check just in case it was already in the list
					if (not TitanUtils_TableContainsValue(TitanPluginsIndex, id)) then
						-- Assign and Sort the list of plugins
						TitanPlugins[id] = self.registry;
						table.insert(TitanPluginsIndex, self.registry.id);
						table.sort(TitanPluginsIndex, 
							function(a, b)
								-- if the .menuText is missing then use .id
								if TitanPlugins[a].menuText == nil then
									TitanPlugins[a].menuText = TitanPlugins[a].id;
								end
								if TitanPlugins[b].menuText == nil then
									TitanPlugins[b].menuText = TitanPlugins[b].id;
								end
								return string.lower(TitanPlugins[a].menuText) 
									< string.lower(TitanPlugins[b].menuText);
							end
						);
					end
				end
				if issue then
					result = TITAN_REGISTER_FAILED
				else
					-- We are almost done-
					-- Allow mouse clicks on the plugin
					local pluginID = TitanUtils_GetButtonID(self:GetName());
					local plugin_id = TitanUtils_GetPlugin(pluginID);
					if (plugin_id) then
						self:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
						self:RegisterForDrag("LeftButton")
						if (plugin_id.id) then
							TitanPanelDetectPluginMethod(plugin_id.id);
						end
					end
					result = TITAN_REGISTERED
					-- determine the plugin category
					cat = (self.registry.category or nil)
					ptype = "Titan" -- Assume it is created for Titan
					if self.registry.ldb then
						-- Override the type with the LDB type
						ptype = "LDB: '"..self.registry.ldb.."'" 
					end
				end
				notes = (self.registry.notes or "")
			else
				-- There could be a couple reasons the .registry was not found
				result = TITAN_REGISTER_FAILED
				if (not self.registry) then
					issue = "Can not find registry for plugin (self.registry)"
				end
				if (self.registry and not self.registry.id) then
					issue = "Can not determine plugin name (self.registry.id)"
				end
			end
		end
	else
		-- The button could not be determined - the plugin is hopeless
		result = TITAN_REGISTER_FAILED
		issue = "Can not determine plugin button name"
	end
	
	-- create and return the results
	local ret_val = {}
	ret_val.issue = (issue or "")
	ret_val.result = (result or TITAN_REGISTER_FAILED)
	ret_val.id = (id or "")
	ret_val.cat = (cat or "General")
	ret_val.ptype = ptype
	ret_val.notes = notes
	return ret_val
--[[ doc
	.issue	: Show the user what prevented the plugin from registering
	.result	: Used so we know which plugins were processed
	.id		: The name used to lookup the plugin
	.cat		: The 'bucket' to use off the main Titan menu
	.ptype	: For now just Titan or LDB type
--]]
end

function TitanUtils_RegisterPlugin(plugin)
--[[ doc
-- lets be extremely paranoid here...
-- Registering plugins that do not play nice can cause real headaches.
--]]
	local call_success, ret_val
	-- Ensure we have a glimmer of a plugin and that the plugin has not 
	-- already been registered.
	if plugin and plugin.status == TITAN_NOT_REGISTERED then
		-- See if the request to register has a shot at success
		if plugin.self then
			-- Just in case, catch any errors
			call_success, -- needed for pcall
			ret_val =  -- actual return values
				pcall (TitanUtils_RegisterPluginProtected, plugin)
			-- pcall does not allow errors to propagate out. Any error
			-- is returned as text with the success / fail. 
			-- Think of it as sort of a try - catch block
			if call_success then
				-- all is good so write the return values to the plugin
				plugin.status = ret_val.result
				plugin.issue = ret_val.issue
				plugin.name = ret_val.id
				plugin.category = ret_val.cat
				plugin.notes = ret_val.notes
				plugin.plugin_type = ret_val.ptype
			else
				-- write enough to the plugin so the user or developer 
				-- can see Titan at least tried...
				plugin.status = TITAN_REGISTER_FAILED
				plugin.issue = (ret_val.issue or "Unknown error")
				plugin.name = "?"
				plugin.notes = ret_val.notes or ""
			end
		else
			-- write enough to the plugin so the user or developer can see something
			plugin.status = TITAN_REGISTER_FAILED
			plugin.issue = "Can not determine plugin button name"
			plugin.name = "?"
		end
		
		-- If there was an error tell the user.
		if not plugin.issue == "" 
		or plugin.status ~= TITAN_REGISTERED then
			TitanDebug(TitanUtils_GetRedText("Error Registering Plugin")
				..TitanUtils_GetGreenText(
					": "
					.."name: '"..(plugin.name or "?_").."' "
					.."issue: '"..(plugin.issue or "?_").."' "
					.."button: '"..plugin.button.."' "
					)
				)
		end
	end
end

function TitanUtils_RegisterPluginList()
--[[ doc
-- Loop through the plugins have requested to be loaded into Titan.
-- Tell the user when this starts and ends only on the first time.
-- This could be called if a plugin requests to be registered after
-- the first loop through.
--]]
	local result = ""
	local issue = ""
	local id
	if TitanPluginToBeRegisteredNum > 0 then
		if not Titan__InitializedPEW then
			TitanDebug(L["TITAN_PANEL_REGISTER_START"])
		end
		for index, value in ipairs(TitanPluginToBeRegistered) do
			if TitanPluginToBeRegistered[index] then
				TitanUtils_RegisterPlugin(TitanPluginToBeRegistered[index])
			end
		end
		if not Titan__InitializedPEW then
			TitanDebug(L["TITAN_PANEL_REGISTER_END"])
		end
	end
end

function TitanUtils_IsPluginRegistered(id)
	if (id and TitanPlugins[id]) then
		return true;
	else
		return false;
	end
end

--
-- The routines below are for Titan Panel ONLY
--

-- Right click menu routines for Titan Panel bars
function TitanUtils_CloseRightClickMenu()
	if (DropDownList1:IsVisible()) then
		DropDownList1:Hide();
	end
end

-- local routines for right click menu
local function TitanRightClick_UIScale()
	-- take UI Scale into consideration
	local listFrame = _G["DropDownList1"];
	local listframeScale = listFrame:GetScale();

	local uiScale;
	local uiParentScale = UIParent:GetScale();
	
	local x, y = GetCursorPosition(UIParent)

	if ( GetCVar("useUIScale") == "1" ) then
		uiScale = tonumber(GetCVar("uiscale"));
		if ( uiParentScale < uiScale ) then
			uiScale = uiParentScale;
		end
	else
		uiScale = uiParentScale;
	end

	x = x/uiScale;
	y = y/uiScale;

	listFrame:SetScale(uiScale);
	
	return x, y, uiScale
end
-- for plugins
local function TitanRightClickMenu_OnLoad(self)
	-- Prepare the right click menu using the function given
	-- by the plugin. The function name is assumed to be
	-- "TitanPanelRightClickMenu_Prepare"..plugin_id.."Menu"
	local id = TitanUtils_GetButtonIDFromMenu(self);
	if id then
		local prepareFunction = _G["TitanPanelRightClickMenu_Prepare"..id.."Menu"]
		if prepareFunction and type(prepareFunction) == "function" then
		 	UIDropDownMenu_Initialize(self, prepareFunction, "MENU");
		end
	end
end
-- for the display bars
local function TitanDisplayRightClickMenu_OnLoad(self, func)
	local prepareFunction = _G[func];
	if prepareFunction and type(prepareFunction) == "function" then
		-- Nasty "hack", load Blizzard_Calendar if not loaded, 
		-- for it to secure init 24 dropdown menu buttons, 
		-- to avoid action blocked by tainting
		if not IsAddOnLoaded("Blizzard_Calendar") then 
			LoadAddOn("Blizzard_Calendar") 
		end
		-- not good practice but there seems to be no other way to get
		-- the actual bar (frame parent) to the dropdown implementation
		TitanPanel_DropMenu = self
		UIDropDownMenu_Initialize(self, prepareFunction, "MENU");
	end
end
-- for plugins
function TitanPanelRightClickMenu_Toggle(self, isChildButton)
--[[ doc
-- This is close to TitanPanelDisplayRightClickMenu_Toggle but geared to 
-- handle Titan plugins.
--]]
	local x, y, scale
	-- Get top / bottom 
	local name = self:GetName() -- assuming this is a plugin
	local parent = self:GetParent():GetName()
	local menu = _G[self:GetName().."RightClickMenu"]
	local vert
	local position
	local id
	local frame = ""

	TitanRightClickMenu_OnLoad(menu)

	-- if this is a child button then use the parent to get the plugin info
	-- otherwise use self as passed in
	if isChildButton then
		id = TitanUtils_GetButtonID(parent)
	else
		id = TitanUtils_GetButtonID(name)
	end
	local i = TitanPanel_GetButtonNumber(id)
	frame = TITAN_PANEL_DISPLAY_PREFIX..TitanPanelSettings.Location[i]
	-- .Location would tell us teh bar but we still need vert (top / bottom)
	vert = TitanBarData[frame].vert
	position = (vert == TITAN_TOP and TITAN_PANEL_PLACE_TOP or TITAN_PANEL_PLACE_BOTTOM)

	if position == TITAN_PANEL_PLACE_TOP then
		menu.point = "TOPLEFT";
		menu.relativePoint = "BOTTOMLEFT";
	else 
		menu.point = "BOTTOMLEFT";
		menu.relativePoint = "TOPLEFT";
	end

	x, y, scale = TitanRightClick_UIScale()
	
	ToggleDropDownMenu(1, nil, menu, frame, TitanUtils_Max(x - 40, 0), 0, nil, self);
	
	local listFrame = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL];
	local offscreenX, offscreenY = TitanUtils_GetOffscreen(listFrame);

	if offscreenX == 1 then
		if position == TITAN_PANEL_PLACE_TOP then 
			listFrame:ClearAllPoints();
			listFrame:SetPoint("TOPRIGHT", frame, "BOTTOMLEFT", x, 0);
		else
			listFrame:ClearAllPoints();
			listFrame:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", x, 0);
		end	
	end
end
-- for display bars
function TitanPanelDisplayRightClickMenu_Toggle(self, isChildButton)
--[[ doc
-- This is close to TitanPanelRightClickMenu_Toggle but geared to the Titan
-- display bars. This routine allows the Titan display bars to be independent 
-- rather than rely on bars being a 'sort of' plugin.
--
-- This relies on name="$parentRightClickMenu" being part of the display 
-- bar template.
--]]
	if not self:GetName() then
		return
	end
	
	local frame = (isChildButton and self:GetParent():GetName() or self:GetName())
	if not frame then
		-- Only Titan display bars should be processed here!!!
		return
	end
	
	local vert = TitanBarData[frame].vert
	local position = (vert == TITAN_TOP and TITAN_PANEL_PLACE_TOP or TITAN_PANEL_PLACE_BOTTOM)
	local x, y, scale
	local menu
	
	menu = _G[frame.."RightClickMenu"];
	-- Initialize the DropDown Menu if not already initialized
	TitanDisplayRightClickMenu_OnLoad(menu, "TitanPanelRightClickMenu_PrepareBarMenu")

	if position == TITAN_PANEL_PLACE_TOP then
		menu.point = "TOPLEFT";
		menu.relativePoint = "BOTTOMLEFT";
	else 
		menu.point = "BOTTOMLEFT";
		menu.relativePoint = "TOPLEFT";
	end
	
	x, y, scale = TitanRightClick_UIScale()
	
	ToggleDropDownMenu(1, nil, menu, frame, TitanUtils_Max(x - 40, 0), 0, nil, self);
	
	local offscreenX, offscreenY = TitanUtils_GetOffscreen(listFrame);
	if offscreenX == 1 then
		local listFrame = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL];
		if position == TITAN_PANEL_PLACE_TOP then 
			listFrame:ClearAllPoints();
			listFrame:SetPoint("TOPRIGHT", frame, "BOTTOMLEFT", x, 0);
		else
			listFrame:ClearAllPoints();
			listFrame:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", x, 0);
		end
	end
end

function TitanPanelRightClickMenu_IsVisible()
	return _G["DropDownList1"]:IsVisible();
end

function TitanPanelRightClickMenu_Close()
	if _G["DropDownList1"]:IsVisible() then
		_G["DropDownList1"]:Hide()
	end
end

-- Various debug routines
function TitanDebug(debug_message)
	_G["DEFAULT_CHAT_FRAME"]:AddMessage(
		TitanUtils_GetGoldText(L["TITAN_DEBUG"]) .. " " 
		.. TitanUtils_GetGreenText(debug_message)
	);
end

function TitanDumpPluginList()
	-- Just dump the current list of plugins
	for idx, value in pairs(TitanPluginsIndex) do
		plug_in = TitanUtils_GetPlugin(TitanPluginsIndex[idx])
		if plug_in then
			TitanDebug("TitanDumpPluginList "
				.."'"..idx.."'"
				..": '"..(plug_in.id or "?").."'"
				..": '"..(plug_in.version or "?").."'"
			)
		end
	end
end

function TitanDumpPlayerList()
	-- Just dump the current list of toons in Titan config
	for idx, value in pairs(TitanSettings.Players) do
			TitanDebug("TitanDumpPlayerList "
				.."'"..(idx or "?").."'"
			)
	end
end

function TitanDumpFrameName(self)
	local frame
	local parent
	if self then
		frame = self:GetName()
	else
		frame = "?"
	end
	if frame == "?" then
		parent = "?"
	else
		parent = self:GetParent():GetName()
	end
--[
TitanDebug("_GetFrameName "
..(self and "T" or "F").." "
..(frame or "?").." "
..(parent or "?").." "
)
--]]
end

--
-- Deprecated routines
-- These routines will be commented out for a couple releases then deleted.
--
--[[
function TitanUtils_GetDoubleBar(bothbars, framePosition)
	return 1
end


--]]
