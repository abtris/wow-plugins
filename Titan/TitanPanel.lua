--[[ doc
--]]
-- Globals
TITAN_PANEL_MOVE_ADDON = nil;
TITAN_PANEL_DROPOFF_ADDON = nil;
TITAN_PANEL_MOVING = 0;

-- Locals
local TITAN_PANEL_BUTTONS_INIT_FLAG = nil;

local TITAN_PANEL_ICON_SPACING = 4;
local TITAN_PANEL_FROM_TOP = -25;
local TITAN_PANEL_FROM_BOTTOM = 25;
local TITAN_PANEL_FROM_BOTTOM_MAIN = 1;
local TITAN_PANEL_FROM_TOP_MAIN = 1;

local _G = getfenv(0);
local InCombatLockdown	= _G.InCombatLockdown;
local TitanSkinToRemove = "None";
local TitanSkinName, TitanSkinPath = "", "";
local newButtons = {};
local newLocations = {};
local IsTitanPanelReset = nil;
local numOfTextures = 0;
local numOfTexturesHider = 0;

-- Library references
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local AceTimer = LibStub("AceTimer-3.0")
local media = LibStub("LibSharedMedia-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfig = LibStub("AceConfig-3.0")

-- Titan local helper funcs
local function TitanPanel_GetTitle()
	return GetAddOnMetadata("Titan", "Title") or L["TITAN_NA"];
end

local function TitanPanel_GetAuthor()
	return GetAddOnMetadata("Titan", "Author") or L["TITAN_NA"];
end

local function TitanPanel_GetCredits()
	return GetAddOnMetadata("Titan", "X-Credits") or L["TITAN_NA"];
end

local function TitanPanel_GetCategory()
	return GetAddOnMetadata("Titan", "X-Category") or L["TITAN_NA"];
end

local function TitanPanel_GetEmail()
	return GetAddOnMetadata("Titan", "X-Email") or L["TITAN_NA"];
end

local function TitanPanel_GetWebsite()
	return GetAddOnMetadata("Titan", "X-Website") or L["TITAN_NA"];
end

local function TitanPanel_GetVersion()
	return tostring(GetAddOnMetadata("Titan", "Version")) or L["TITAN_NA"];
end

local function TitanPanel_GetLicense()
	return GetAddOnMetadata("Titan", "X-License") or L["TITAN_NA"];
end

local function TitanAdjustBottomFrames()
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTTOM, true)
end

local function TitanAdjustPanelScale(scale)
	Titan_AdjustScale()		

	-- Adjust frame positions								
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, true)
end

local function TitanSetPanelFont(fontname, fontsize)
	-- a couple of arg checks to avoid unpleasant things...
	if not fontname then fontname = "Friz Quadrata TT" end
	if not fontsize then fontsize = 10 end
	local index,id;
	local newfont = media:Fetch("font", fontname)
	for index, id in pairs(TitanPluginsIndex) do
		local button = TitanUtils_GetButton(id);
		local buttonText = _G[button:GetName().."Text"];
		if buttonText then
			buttonText:SetFont(newfont, fontsize);
		end
		-- account for plugins with child buttons
		local childbuttons = {button:GetChildren()};
		for _, child in ipairs(childbuttons) do
			if child then
				local childbuttonText = _G[child:GetName().."Text"];
				if childbuttonText then
					childbuttonText:SetFont(newfont, fontsize);
				end
			end
		end
	end
	TitanPanel_RefreshPanelButtons();
end

local function TitanPanel_ResetBar()
	local playerName = UnitName("player");
	local serverName = GetCVar("realmName");

	toon = playerName..TITAN_AT..serverName
	TitanCopyPlayerSettings = TitanSettings.Players[toon];
	TitanCopyPluginSettings = TitanCopyPlayerSettings["Plugins"];

	for index, id in pairs (TitanPanelSettings["Buttons"]) do
		local currentButton = 
			TitanUtils_GetButton(TitanPanelSettings["Buttons"][index])
		-- safeguard
		if currentButton then
			currentButton:Hide();
		end					
	end

	TitanSettings.Players[toon] = {}
	TitanSettings.Players[toon].Plugins = {}
	TitanSettings.Players[toon].Panel = {}
	TitanSettings.Players[toon].Panel.Buttons = 
		TITAN_PANEL_SAVED_VARIABLES.Buttons
	TitanSettings.Players[toon].Panel.Locations = 
		TITAN_PANEL_SAVED_VARIABLES.Location
	
	-- Set global variables
	TitanPlayerSettings = TitanSettings.Players[toon];
	TitanPluginSettings = TitanPlayerSettings["Plugins"];
	TitanPanelSettings = TitanPlayerSettings["Panel"];	
	IsTitanPanelReset = true;
	ReloadUI()
end

local function TitanPanel_ResetToDefault()
	StaticPopupDialogs["TITAN_RESET_BAR"] = {
		text = TitanUtils_GetNormalText(L["TITAN_PANEL_MENU_TITLE"])
			.."\n\n"..L["TITAN_PANEL_RESET_WARNING"],
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function(self)
			TitanPanel_ResetBar();
		end,	
		showAlert = 1,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	};
	StaticPopup_Show("TITAN_RESET_BAR");
end

local function TitanPanel_TicketReload()
	StaticPopupDialogs["TITAN_RELOAD"] = {
		text = TitanUtils_GetNormalText(L["TITAN_PANEL_MENU_TITLE"]).."\n\n"
			..L["TITAN_PANEL_RELOAD"],
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function(self)
			TitanPanelToggleVar("TicketAdjust");
			ReloadUI();
			end,	
		showAlert = 1,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	};
	StaticPopup_Show("TITAN_RELOAD");
end

local function TitanPanel_SaveCustomProfile()

	StaticPopupDialogs["TITAN_RELOADUI"] = {
		text = TitanUtils_GetNormalText(L["TITAN_PANEL_MENU_TITLE"]).."\n\n"
			..L["TITAN_PANEL_MENU_PROFILE_RELOADUI"],
		button1 = TEXT(OKAY),
		OnAccept = function(self)
		ReloadUI();
		end,
		showAlert = 1,
		whileDead = 1,
		timeout = 0,
	};
	
	StaticPopupDialogs["TITAN_OVERWRITE_CUSTOM_PROFILE"] = {
		text = TitanUtils_GetNormalText(L["TITAN_PANEL_MENU_TITLE"]).."\n\n"
			..L["TITAN_PANEL_MENU_PROFILE_ALREADY_EXISTS"],
		button1 = ACCEPT,
		button2 = CANCEL,
		OnAccept = function(self, data)
			local playerName = UnitName("player");
			local serverName = GetCVar("realmName");
			local currentprofilevalue = playerName..TITAN_AT..serverName;
			local profileName = data..TITAN_AT.."TitanCustomProfile";
			TitanPanelSettings.Buttons = newButtons;
			TitanPanelSettings.Location = newLocations;
			TitanSettings.Players[profileName] = 
				TitanSettings.Players[currentprofilevalue]
			DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
				..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]..": "
				..L["TITAN_PANEL_MENU_PROFILE_SAVE_PENDING"]
				.."|cffff8c00"..data.."|r");
			self:Hide();
			StaticPopup_Show("TITAN_RELOADUI");
		end,
		showAlert = 1,
		whileDead = 1,
		timeout = 0,
		hideOnEscape = 1
	};
	
	StaticPopupDialogs["TITAN_SAVE_CUSTOM_PROFILE"] = {
		text = TitanUtils_GetNormalText(L["TITAN_PANEL_MENU_TITLE"]).."\n\n"
			..L["TITAN_PANEL_MENU_PROFILE_SAVE_CUSTOM_TITLE"],
		button1 = ACCEPT,
		button2 = CANCEL,
		hasEditBox = 1,
		maxLetters = 20,
		OnAccept = function(self)
			local rawprofileName = self.editBox:GetText();
			local conc2profileName = string.gsub( rawprofileName, " ", "" );
			if conc2profileName == "" then return; end
			local concprofileName = string.gsub( conc2profileName, TITAN_AT, "-" );
			local profileName = concprofileName..TITAN_AT.."TitanCustomProfile";
			if TitanSettings.Players[profileName] then			
				local dialogFrame = 
					StaticPopup_Show("TITAN_OVERWRITE_CUSTOM_PROFILE", concprofileName);
				if dialogFrame then
					dialogFrame.data = concprofileName;
				end
				return;
			else
				local playerName = UnitName("player");
				local serverName = GetCVar("realmName");
				local currentprofilevalue = playerName..TITAN_AT..serverName;
				TitanPanelSettings.Buttons = newButtons;
				TitanPanelSettings.Location = newLocations;
				TitanSettings.Players[profileName] = 
					TitanSettings.Players[currentprofilevalue];
				DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
					..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]..": "
					..L["TITAN_PANEL_MENU_PROFILE_SAVE_PENDING"]
					.."|cffff8c00"..concprofileName.."|r");
				self:Hide();
				StaticPopup_Show("TITAN_RELOADUI");
			end
		end,
		OnShow = function(self)
			self.editBox:SetFocus();
		end,
		OnHide = function(self)
			self.editBox:SetText("");
		end,
		EditBoxOnEnterPressed = function(self)
			local parent = self:GetParent();
			local rawprofileName = parent.editBox:GetText();		
			local conc2profileName = string.gsub( rawprofileName, " ", "" );
			if conc2profileName == "" then return; end
			local concprofileName = string.gsub( conc2profileName, TITAN_AT, "-" );
			local profileName = concprofileName..TITAN_AT.."TitanCustomProfile";
			if TitanSettings.Players[profileName] then			
				local dialogFrame = 
					taticPopup_Show("TITAN_OVERWRITE_CUSTOM_PROFILE", concprofileName);
				if dialogFrame then
					dialogFrame.data = concprofileName;
				end
				parent:Hide();
				return;
			else
				local playerName = UnitName("player");
				local serverName = GetCVar("realmName");
				local currentprofilevalue = playerName..TITAN_AT..serverName;
				TitanPanelSettings.Buttons = newButtons;
				TitanPanelSettings.Location = newLocations;
				TitanSettings.Players[profileName] =
					TitanSettings.Players[currentprofilevalue];
				DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
					..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]..": "
					..L["TITAN_PANEL_MENU_PROFILE_SAVE_PENDING"]
					.."|cffff8c00"..concprofileName.."|r");			
				end
				parent:Hide();
				StaticPopup_Show("TITAN_RELOADUI");
			end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide();
		end,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		hideOnEscape = 1
	};

	StaticPopup_Show("TITAN_SAVE_CUSTOM_PROFILE");
end

local function TitanPanel_SetCustomTexture(path)
	if path ~= TitanPanelGetVar("TexturePath") then
		TitanPanelSetVar("TexturePath", path);
		for idx,v in pairs (TitanBarData) do
			TitanPanel_SetTexture(
				TITAN_PANEL_DISPLAY_PREFIX..TitanBarData[idx].name, 
				TITAN_PANEL_PLACE_TOP);
		end
	end
end

-- Titan AceConfigDialog-3.0 init tables
-- in-line creation of the tables needed by Ace for the Blizzard options

-- About
local optionsControl = {
	name = L["TITAN_PANEL"],
	type = "group",
	args = {
		confgendesc = {
			order = 1,
			type = "description",
			name = L["TITAN_PANEL_CONFIG_MAIN_LABEL"].."\n\n",
			cmdHidden = true
		},
		confinfodesc = {
			name = "About",
			type = "group", inline = true,
			args = {
				confversiondesc = {
				order = 1,
				type = "description",			
				name = "|cffffd700".."Version"..": "
					.._G["GREEN_FONT_COLOR_CODE"]..TitanPanel_GetVersion(),
				cmdHidden = true
				},
				confauthordesc = {
					order = 2,
					type = "description",
					name = "|cffffd700".."Author"..": "
						.."|cffff8c00"..TitanPanel_GetAuthor(),
					cmdHidden = true
				},
				confcreditsdesc = {
					order = 3,
					type = "description",
					name = "|cffffd700".."Credits"..": "
						.._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanel_GetCredits(),
					cmdHidden = true
				},
				confcatdesc = {
					order = 4,
					type = "description",
					name = "|cffffd700".."Category"..": "
						.._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanel_GetCategory(),
					cmdHidden = true
				},
				confemaildesc = {
					order = 5,
					type = "description",
					name = "|cffffd700".."Email"..": "
						.._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanel_GetEmail(),
					cmdHidden = true
				},
				confwebsitedesc = {
					order = 6,
					type = "description",
					name = "|cffffd700".."Website"..": "
						.._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanel_GetWebsite(),
					cmdHidden = true
				},
				conflicensedesc = {
					order = 7,
					type = "description",
					name = "|cffffd700".."License"..": "
						.._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanel_GetLicense(),
					cmdHidden = true
				},
			}
		}
	}
}
-- Transparency config
local function TitanPanel_TransOptions(args)
	local bar = ""
	local bar_name = ""
	local var = ""
	local position
	for idx,v in pairs (TitanBarData) do
		bar = TitanBarData[idx].name
		vert = TitanBarData[idx].vert
		position = TitanBarData[idx].order + 10
		var = bar.."_Transparency"
		bar_name = TITAN_PANEL_DISPLAY_PREFIX..bar
		args[bar_name] = {
			name = bar, --L["TITAN_TRANS_MAIN_CONTROL_TITLE"],
			desc = "Sets transparency on " --L["TITAN_TRANS_MAIN_BAR_DESC"],
				..bar.." ("..vert..")",
			order = position, type = "range", width = "full",
			min = 0, max = 1, step = 0.01,
			get = function(info)
				local bar = TitanBarData[info[1]].name
				return TitanPanelGetVar(bar.."_Transparency") 
				end,
			set = function(info, a)
				local bar = TitanBarData[info[1]].name
				_G[info[1]]:SetAlpha(a)
				TitanPanelSetVar(bar.."_Transparency", a);
			end,
		}
	position = position + 1
	end
end
local optionsTrans = {
	name = L["TITAN_TRANS_MENU_TEXT"],
	type = "group",
	args = {
		confdesc = {
				order = 1,
				type = "description",
				name = L["TITAN_TRANS_MENU_DESC"].."\n",
				cmdHidden = true
			},
		tooltiptrans = {
			name = L["TITAN_TRANS_CONTROL_TITLE_TOOLTIP"],
			desc = L["TITAN_TRANS_TOOLTIP_DESC"],
			order = 50, type = "range", width = "full",
			min = 0, max = 1, step = 0.01,
			get = function() return TitanPanelGetVar("TooltipTrans") end,
			set = function(_, a)
				TitanPanelSetVar("TooltipTrans", a);
			end,
		},
   },
 }
 -- Add the sliders for each bar
TitanPanel_TransOptions(optionsTrans.args)

 -- skins config
local function TitanPanel_AddNewSkin(skinname, skinpath)
	-- name and path must be provided
	if not skinname or not skinpath then return end 
	
	-- name cannot be empty or "None", path cannot be empty	
	if skinname == "" or skinname == L["TITAN_NONE"] or skinpath == "" then 
		return 
	end 
	local found
	for _,i in pairs(TitanSkins) do
		if i.name == skinname or i.path == skinpath then
			found = true			
			break
		end
	end
--[[
TitanDebug("_AddNewSkin "
..(skinname or "?").." "
..(skinpath or "?").." "
..(found and "T" or "F").." "
)
--]]
	if not found then 
		table.insert(TitanSkins, {name = skinname, path = skinpath }) 
	end
end
local optionsSkins = {
	name = L["TITAN_SKINS_TITLE"],
	type = "group",
	args = {
		setskinhdear = {
			order = 2,
			type = "header",
			name = L["TITAN_SKINS_SET_HEADER"],
		},
		setskinlist = {
			order = 3, type = "select",
			name = L["TITAN_SKINS_LIST_TITLE"],
			desc = L["TITAN_SKINS_SET_DESC"],
			get = function() return TitanPanelGetVar("TexturePath") end,
			set = function(_,v)
				TitanPanel_SetCustomTexture(v)
				if TitanSkinToRemove == TitanPanelGetVar("TexturePath") then
					TitanSkinToRemove = "None"
				end
			end,
			values = function()
				local Skinlist = {}
				local v;
				for _,v in pairs (TitanSkins) do
					if v.path ~= TitanPanelGetVar("TexturePath") then
						Skinlist[v.path] = "|cff19ff19"..v.name.."|r"
					else
						Skinlist[v.path] = "|cffffff9a"..v.name.."|r"
					end
				end
				table.sort(Skinlist, function(a, b)
					return string.lower(TitanSkins[a].name) 
						< string.lower(TitanSkins[b].name)
				end)
				return Skinlist
			end,
		},
		nulloption1 = {
			order = 5,
			type = "description",
			name = "   ",
			cmdHidden = true
		},
		resetskinhdear = {
		order = 20,
		type = "header",
		name = L["TITAN_SKINS_RESET_HEADER"],
		},
		defaultskins = {
			order = 21,
			name = L["TITAN_SKINS_RESET_DEFAULTS_TITLE"], type = "execute",
			desc = L["TITAN_SKINS_RESET_DEFAULTS_DESC"],
			func = function()
				TitanSkins = TitanSkinsDefault;
			end,
		},
	}
}
local optionsSkinsCustom = {
	name = L["TITAN_SKINS_TITLE_CUSTOM"],
	type = "group",
	args = {
		confdesc = {
			order = 1,
			type = "description",
			name = L["TITAN_SKINS_MAIN_DESC"].."\n",
			cmdHidden = true
		},
		nulloption1 = {
			order = 5,
			type = "description",
			name = "   ",
			cmdHidden = true
		},
		addskinheader = {
			order = 10,
			type = "header",
			name = L["TITAN_SKINS_NEW_HEADER"],
		},
		newskinname = {
			order = 11,
			name = L["TITAN_SKINS_NAME_TITLE"],
			desc = L["TITAN_SKINS_NAME_DESC"],
			type = "input", width = "full",
			get = function() return TitanSkinName end,
			set = function(_,v) TitanSkinName = v end,
		},
		newskinpath = {
			order = 12,
			name = L["TITAN_SKINS_PATH_TITLE"],
			desc = L["TITAN_SKINS_PATH_DESC"],
			type = "input", width = "full",
			get = function() return TitanSkinPath end,
			set = function(_,v) TitanSkinPath = TitanSkinsCustomPath..v..TitanSkinsPathEnd end,

		},
		addnewskin = {
			order = 13,
			name = L["TITAN_SKINS_ADD_HEADER"], type = "execute",
			desc = L["TITAN_SKINS_ADD_DESC"],
			func = function()
				if TitanSkinName ~= "" and TitanSkinPath ~= "" then				
					TitanPanel_AddNewSkin(TitanSkinName, TitanSkinPath)
					TitanSkinName = ""
					TitanSkinPath = ""
					-- Config Tables changed!
					AceConfigRegistry:NotifyChange("Titan Panel Skin Custom")
				end
			end,
		},
		nulloption2 = {
			order = 14,
			type = "description",
			name = "   ",
			cmdHidden = true
		},
		removeskinheader = {
			order = 20,
			type = "header",
			name = L["TITAN_SKINS_REMOVE_HEADER"],
		},
		removeskinlist = {
			order = 21, type = "select", width = "full",
			name = L["TITAN_SKINS_REMOVE_HEADER"],
			desc = L["TITAN_SKINS_REMOVE_DESC"],
			get = function() return TitanSkinToRemove end,
			set = function(_,v)
				TitanSkinToRemove = v
			end,
			values = function()
			local Skinlist = {}
			local v;
				for _,v in pairs (TitanSkins) do
					-- You may not remove the currently used skin 
					-- or the default one
					-- or a Titan default skin (it would only come back...)
					if v.path ~= TitanPanelGetVar("TexturePath") 
					and v.path ~= "Interface\\AddOns\\Titan\\Artwork\\" 
					and v.titan ~= true
					then
						Skinlist[v.path] = "|cff19ff19"..v.name.."|r"
					end
					if v.path == TitanSkinToRemove then
						Skinlist[v.path] = "|cffffff9a"..v.name.."|r"
					end
				end
				if TitanSkinToRemove ~= "None" then
					Skinlist["None"] = "|cff19ff19"..L["TITAN_NONE"].."|r"
				else
					Skinlist["None"] = "|cffffff9a"..L["TITAN_NONE"].."|r"
				end
				table.sort(Skinlist, function(a, b)
					return string.lower(TitanSkins[a].name) 
						< string.lower(TitanSkins[b].name)
				end)
					return Skinlist
			end,
		},
		removeskin = {
			order = 22, type = "execute",
			name = L["TITAN_SKINS_REMOVE_BUTTON"],
			desc = L["TITAN_SKINS_REMOVE_BUTTON_DESC"],
			func = function()
			if TitanSkinToRemove == "None" then return end
			local k, v;
				for k, v in pairs (TitanSkins) do
					if v.path == TitanSkinToRemove then
						table.remove(TitanSkins, k)
						TitanSkinToRemove = "None"
						-- Config Tables changed!
						AceConfigRegistry:NotifyChange("Titan Panel Skin Custom")
						break
					end
				end
			end,
		},
		notes_delete = {
			order = 23,
			type = "description",
			name = L["TITAN_SKINS_REMOVE_NOTES"].."\n",
			cmdHidden = true
		},
		nulloption4 = {
			order = 24,
			type = "description",
			name = "   ",
			cmdHidden = true
		},		
	}
}

-- UI scale config
local optionsUIScale = {
	name = L["TITAN_UISCALE_MENU_TEXT"],
	type = "group",
	args = {
		confdesc = {
			order = 1,
			type = "description",
			name = L["TITAN_UISCALE_MENU_DESC"].."\n",
			cmdHidden = true
		},
		uiscale = {
			name = L["TITAN_UISCALE_CONTROL_TITLE_UI"],
			desc = L["TITAN_UISCALE_SLIDER_DESC"],
			order = 2, type = "range", width = "full",
			min = 0.64, max = 1, step = 0.01,		
			get = function() return UIParent:GetScale() end,
			set = function(_, a)
				SetCVar("useUiScale", 1);
				SetCVar("uiScale", a, "uiScale");								
			end,
		},
		panelscale = {
			name = L["TITAN_UISCALE_CONTROL_TITLE_PANEL"],
			desc = L["TITAN_UISCALE_PANEL_SLIDER_DESC"],
			order = 3, type = "range", width = "full",
			min = 0.75, max = 1.25, step = 0.01,
			get = function() return TitanPanelGetVar("Scale") end,
			set = function(_, a)
				if not InCombatLockdown() then 
					TitanPanelSetVar("Scale", a);									
					TitanAdjustPanelScale(a)
				end
			end,
			disabled = function()
				if InCombatLockdown() then
					return true
				end
				return false
			end,
		},
		buttonspacing = {
			name = L["TITAN_UISCALE_CONTROL_TITLE_BUTTON"],
			desc = L["TITAN_UISCALE_BUTTON_SLIDER_DESC"],
			order = 4, type = "range", width = "full",
			min = 5, max = 80, step = 1,
			get = function() return TitanPanelGetVar("ButtonSpacing") end,
			set = function(_, a)
				TitanPanelSetVar("ButtonSpacing", a);
				TitanPanel_InitPanelButtons();
			end,
		},
		tooltipfont = {
			name = L["TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPFONT"],
			desc = L["TITAN_UISCALE_TOOLTIP_SLIDER_DESC"],
			order = 5, type = "range", width = "full",
			min = 0.5, max = 1.3, step = 0.01,
			get = function() return TitanPanelGetVar("TooltipFont") end,
			set = function(_, a)
				TitanPanelSetVar("TooltipFont", a);
			end,
		},
		tooltipfontdisable = {
			name = L["TITAN_UISCALE_TOOLTIP_DISABLE_TEXT"],
			desc = L["TITAN_UISCALE_DISABLE_TOOLTIP_DESC"],
			order = 6, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("DisableTooltipFont") end,
			set = function()
				TitanPanelToggleVar("DisableTooltipFont");
			end,
		},
		fontselection = {
			name = L["TITAN_PANEL_MENU_LSM_FONTS"],
			desc = L["TITAN_PANEL_MENU_LSM_FONTS_DESC"],
			order = 7, type = "select",
			dialogControl = "LSM30_Font",
			get = function()
				return TitanPanelGetVar("FontName")
			end,
			set = function(_, v)
				TitanPanelSetVar("FontName", v)
				TitanSetPanelFont(v, TitanPanelGetVar("FontSize"))
			end,
			values = AceGUIWidgetLSMlists.font,
		},
		fontsize = {
			name = L["TITAN_PANEL_MENU_FONT_SIZE"],
			desc = L["TITAN_PANEL_MENU_FONT_SIZE_DESC"],
			order = 8, type = "range",
			min = 7, max = 15, step = 1,
			get = function() return TitanPanelGetVar("FontSize") end,
			set = function(_, v)
				TitanPanelSetVar("FontSize", v);
				TitanSetPanelFont(TitanPanelGetVar("FontName"), v)
			end,
		},
		panelstrata = {
			name = L["TITAN_PANEL_MENU_FRAME_STRATA"],
			desc = L["TITAN_PANEL_MENU_FRAME_STRATA_DESC"],
			order = 9, type = "select",
			get = function()								
				return TitanPanelGetVar("FrameStrata")
			end,
			set = function(_, v)
				TitanPanelSetVar("FrameStrata", v)
				TitanVariables_SetPanelStrata(v)
			end,
			values = {
			["BACKGROUND"] = "BACKGROUND",
			["LOW"] = "LOW",
			["MEDIUM"] = "MEDIUM",
			["HIGH"] = "HIGH",
			["DIALOG"] = "DIALOG",
			["FULLSCREEN"] = "FULLSCREEN",
			},
		},
   }
 }
-- Bar control - show / hide, auto hide, etc
local optionsBars = {
	name = L["TITAN_PANEL_MENU_OPTIONS_MAIN_BARS"],
	type = "group",
	args = {
		confdesc1 = {
			order = 100,
			type = "header",
			name = L["TITAN_TRANS_MAIN_CONTROL_TITLE"],
		},
		optiontop = {
			name = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			desc = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			order = 101, type = "toggle", width = "full",
			get = function() return (TitanPanelGetVar("Bar_Show")) end,
			set = function()
					TitanPanelToggleVar("Bar_Show")
					TitanPanelBarButton_DisplayBarsWanted() 
					end,
		},
		optiontophide = {
			name = L["TITAN_PANEL_MENU_AUTOHIDE"],
			desc = L["TITAN_PANEL_MENU_AUTOHIDE"],
			order = 103, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("Bar_Hide") end,
			set = function() 
				TitanPanelBarButton_ToggleAutoHide(TITAN_PANEL_DISPLAY_PREFIX.."Bar")
			end,
		},
		optiontopcenter = {
			name = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			desc = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			order = 104, type = "toggle", width = "full",
			get = function() 
				return (TitanPanelGetVar("Bar_Align") == TITAN_PANEL_BUTTONS_ALIGN_CENTER)
			end,
			set = function() TitanPanelBarButton_ToggleAlign("Bar_Align"); end,
		},
		confdesc2 = {
			order = 200,
			type = "header",
			name = L["TITAN_TRANS_MAIN_CONTROL_TITLE"].." 2",
		},
		optionbottom = {
			name = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			desc = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			order = 201, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("Bar2_Show") end,
			set = function()
					TitanPanelToggleVar("Bar2_Show")
					TitanPanelBarButton_DisplayBarsWanted() 
					end,
		},
		optionbottomhide = {
			name = L["TITAN_PANEL_MENU_AUTOHIDE"],
			desc = L["TITAN_PANEL_MENU_AUTOHIDE"],
			order = 203, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("Bar2_Hide") end,
			set = function() 
				TitanPanelBarButton_ToggleAutoHide(TITAN_PANEL_DISPLAY_PREFIX.."Bar2"); 
			end,
		},
		optionbottomcenter = {
			name = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			desc = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			order = 204, type = "toggle", width = "full",
			get = function() 
				return (TitanPanelGetVar("Bar2_Align") == TITAN_PANEL_BUTTONS_ALIGN_CENTER) 
			end,
			set = function() TitanPanelBarButton_ToggleAlign("Bar2_Align"); end,
		},
		confdesc3 = {
			order = 300,
			type = "header",
			name = L["TITAN_PANEL_OPTIONS"],
		},
		optiontopscreen = {
			name = L["TITAN_PANEL_MENU_DISABLE_PUSH"],
			desc = L["TITAN_PANEL_MENU_DISABLE_PUSH"],
			order = 301, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("ScreenAdjust") end,
			set = function() TitanPanelBarButton_ToggleScreenAdjust(); end,
		},
		optionminimap = {
			name = L["TITAN_PANEL_MENU_DISABLE_MINIMAP_PUSH"],
			desc = L["TITAN_PANEL_MENU_DISABLE_MINIMAP_PUSH"],
			order = 302, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("MinimapAdjust") end,
			set = function() TitanPanelToggleVar("MinimapAdjust"); end,
		},
		optiontickets = {
			name = L["TITAN_PANEL_MENU_DISABLE_TICKET"].." "
				.._G["GREEN_FONT_COLOR_CODE"]..L["TITAN_PANEL_MENU_RELOADUI"],
			desc = L["TITAN_PANEL_MENU_DISABLE_TICKET"].." "
				.._G["GREEN_FONT_COLOR_CODE"]..L["TITAN_PANEL_MENU_RELOADUI"],
			order = 305, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("TicketAdjust"); end,
			set = function() TitanPanel_TicketReload() end,
		},
	}
 }
-- Aux Bar control - show / hide, auto hide, etc
local optionsAuxBars = {
	name = L["TITAN_PANEL_MENU_OPTIONS_AUX_BARS"],
	type = "group",
	args = {
		confdesc1 = {
			order = 100,
			type = "header",
			name = L["TITAN_TRANS_AUX_CONTROL_TITLE"],
		},
		optiontop = {
			name = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			desc = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			order = 101, type = "toggle", width = "full",
			get = function() return (TitanPanelGetVar("AuxBar_Show")) end,
			set = function()
					TitanPanelToggleVar("AuxBar_Show")
					TitanPanelBarButton_DisplayBarsWanted() 
					end,
		},
		optiontophide = {
			name = L["TITAN_PANEL_MENU_AUTOHIDE"],
			desc = L["TITAN_PANEL_MENU_AUTOHIDE"],
			order = 103, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("AuxBar_Hide") end,
			set = function() 
				TitanPanelBarButton_ToggleAutoHide(TITAN_PANEL_DISPLAY_PREFIX.."AuxBar");
			end,
		},
		optiontopcenter = {
			name = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			desc = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			order = 104, type = "toggle", width = "full",
			get = function() 
				return (TitanPanelGetVar("AuxBar_Align") == TITAN_PANEL_BUTTONS_ALIGN_CENTER) 
			end,
			set = function() TitanPanelBarButton_ToggleAlign("AuxBar_Align"); end,
		},
		confdesc2 = {
				order = 200,
				type = "header",
				name = L["TITAN_TRANS_AUX_CONTROL_TITLE"].." 2",
		},
		optionbottom = {
			name = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			desc = L["TITAN_PANEL_MENU_DISPLAY_BAR"],
			order = 201, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("AuxBar2_Show") end,
			set = function()
					TitanPanelToggleVar("AuxBar2_Show")
					TitanPanelBarButton_DisplayBarsWanted() 
					end,
		},
		optionbottomhide = {
			name = L["TITAN_PANEL_MENU_AUTOHIDE"],
			desc = L["TITAN_PANEL_MENU_AUTOHIDE"],
			order = 203, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("AuxBar2_Hide") end,
			set = function() 
				TitanPanelBarButton_ToggleAutoHide(TITAN_PANEL_DISPLAY_PREFIX.."AuxBar2"); 
			end,
		},
		optionbottomcenter = {
			name = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			desc = L["TITAN_PANEL_MENU_CENTER_TEXT"],
			order = 204, type = "toggle", width = "full",
			get = function() 
				return (TitanPanelGetVar("AuxBar2_Align") == TITAN_PANEL_BUTTONS_ALIGN_CENTER) 
			end,
			set = function() TitanPanelBarButton_ToggleAlign("AuxBar2_Align"); end,
		},
		confdesc3 = {
			order = 300,
			type = "header",
			name = L["TITAN_PANEL_OPTIONS"],
		},
		optionbottomscreen = {
			name = L["TITAN_PANEL_MENU_DISABLE_PUSH"],
			desc = L["TITAN_PANEL_MENU_DISABLE_PUSH"],
			order = 301, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("AuxScreenAdjust") end,
			set = function() TitanPanelBarButton_ToggleAuxScreenAdjust(); end,
		},
		optionlog = {
			name = L["TITAN_PANEL_MENU_DISABLE_LOGS"],
			desc = L["TITAN_PANEL_MENU_DISABLE_LOGS"],
			order = 303, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("LogAdjust") end,
			set = function() TitanPanelToggleVar("LogAdjust"); end,
		},
		optionbags = {
			name = L["TITAN_PANEL_MENU_DISABLE_BAGS"],
			desc = L["TITAN_PANEL_MENU_DISABLE_BAGS"],
			order = 304, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("BagAdjust") end,
			set = function() TitanPanelToggleVar("BagAdjust"); end,
		},
	}
 }
 -- Overall bar options tooltips, reset, etc
local optionsFrames = {
	name = L["TITAN_PANEL_MENU_OPTIONS"],
	type = "group",
	args = {
		confdesc2 = {
			order = 200,
			type = "header",
			name = L["TITAN_PANEL_MENU_OPTIONS_TOOLTIPS"],
		},
		optiontooltip = {
			name = L["TITAN_PANEL_MENU_TOOLTIPS_SHOWN"],
--			desc = L["TITAN_PANEL_MENU_TOOLTIPS_SHOWN"],
			order = 201, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("ToolTipsShown") end,
			set = function() TitanPanelToggleVar("ToolTipsShown"); end,
		},
		optiontooltipcombat = {
			name = L["TITAN_PANEL_MENU_TOOLTIPS_SHOWN_IN_COMBAT"],
--			desc = L["TITAN_PANEL_MENU_TOOLTIPS_SHOWN_IN_COMBAT"],
			order = 201, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("HideTipsInCombat") end,
			set = function() TitanPanelToggleVar("HideTipsInCombat"); end,
		},
		confdesc = {
			order = 300,
			type = "header",
			name = L["TITAN_PANEL_MENU_OPTIONS_FRAMES"],
		},
		optionlock = {
			name = L["TITAN_PANEL_MENU_LOCK_BUTTONS"],
			desc = L["TITAN_PANEL_MENU_LOCK_BUTTONS"],
			order = 301, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("LockButtons") end,
			set = function() TitanPanelToggleVar("LockButtons") end,
		},
		optionversions = {
			name = L["TITAN_PANEL_MENU_VERSION_SHOWN"],
--			desc = L["TITAN_PANEL_MENU_VERSION_SHOWN"],
			order = 302, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("VersionShown") end,
			set = function() TitanPanelToggleVar("VersionShown") end,
		},
		space_400_1 = {
			order = 400,
			type = "description",
			name = "  ",
			cmdHidden = true,
		},
		optionlaunchers = {
			name = L["TITAN_PANEL_MENU_LDB_FORCE_LAUNCHER"],
			order = 401, type = "execute", width = "full",
			func = function() TitanPanelBarButton_ForceLDBLaunchersRight() end,
		},
		space_500_1 = {
			order = 500,
			type = "description",
			name = "  ",
			cmdHidden = true,
		},
		pluginreset = {
			name = L["TITAN_PANEL_MENU_PLUGIN_RESET"],
			desc = L["TITAN_PANEL_MENU_PLUGIN_RESET_DESC"],
			order = 501, type = "execute", width = "full",
			func = function() TitanPanel_InitPanelButtons() end,
		},
		space_600_1 = {
			order = 600,
			type = "description",
			name = "  ",
			cmdHidden = true,
		},
		optionreset = {
			name = L["TITAN_PANEL_MENU_RESET"].." "
				.._G["GREEN_FONT_COLOR_CODE"]
				..L["TITAN_PANEL_MENU_RELOADUI"],
			order = 601, type = "execute", width = "full",
			func = function() TitanPanel_ResetToDefault() end,
		}
	}
 }

-- Show all plugins that attempted to register (no child frames though)
local optionsAddonAttempts = {
	name = L["TITAN_PANEL_ATTEMPTS"],
	type = "group",
	args = {}
 }
local function TitanUpdateAddonAttempts()
	local args = optionsAddonAttempts.args
	local plug_in = nil
    
	wipe(args)

	args["desc"] = {
		order = 0,
		type = "description",
		name = L["TITAN_PANEL_ATTEMPTS_DESC"],
		cmdHidden = true
	}
	for idx, value in pairs(TitanPluginToBeRegistered) do
		if TitanPluginToBeRegistered[idx] 
		then
			local num = tostring(idx)
			local button = TitanPluginToBeRegistered[idx].button
			local name = (TitanPluginToBeRegistered[idx].name or "?")
			local reason = TitanPluginToBeRegistered[idx].status
			local issue = TitanPluginToBeRegistered[idx].issue
			local notes = TitanPluginToBeRegistered[idx].notes or ""
			local category = TitanPluginToBeRegistered[idx].category
			local ptype = TitanPluginToBeRegistered[idx].plugin_type
			local title = TitanPluginToBeRegistered[idx].name
			local isChild = TitanPluginToBeRegistered[idx].isChild and true or false
			if reason ~= TITAN_REGISTERED then
				title = TitanUtils_GetRedText(title)
				issue = TitanUtils_GetRedText(issue)
			end
			
			if isChild then
				-- Do not show. A child is part of (within) another plugin
				-- showing it here would be confusing to the 'normal' user.
				-- A plugin in author would know to look at the 
				-- TitanPluginToBeRegistered array directly.
			else
				args[num] = {
					type = "group",
					name = title,
					order = idx,
					args = {
						name ={
							type = "description",
							name = TitanUtils_GetGoldText("")..name,
							cmdHidden = true,
							order = 1,
						},
						reason = {
							type = "description",
							name = TitanUtils_GetGoldText("Status: ")..reason,
							cmdHidden = true,
							order = 2,
						},
						issue = {
							type = "description",
							name = TitanUtils_GetGoldText("Issue: \n")..issue,
							cmdHidden = true,
							order = 3,
						},
						notes = {
							type = "description",
							name = TitanUtils_GetGoldText("Notes: \n")..notes,
							cmdHidden = true,
							order = 4,
						},
						sp_1 = {
							type = "description",
							name = "",
							cmdHidden = true,
							order = 5,
						},
						category = {
							type = "description",
							name = TitanUtils_GetGoldText(L["TITAN_PANEL_ATTEMPTS_CATEGORY"]..": ")..category,
							cmdHidden = true,
							order = 10,
						},
						ptype = {
							type = "description",
							name = TitanUtils_GetGoldText(L["TITAN_PANEL_ATTEMPTS_TYPE"]..": ")..ptype,
							cmdHidden = true,
							order = 11,
						},
						button = {
							type = "description",
							name = TitanUtils_GetGoldText(L["TITAN_PANEL_ATTEMPTS_BUTTON"]..": \n")..button,
							cmdHidden = true,
							order = 12,
						},
						num_val = {
							type = "description",
							name = TitanUtils_GetGoldText("Table index"..": \n")..num,
							cmdHidden = true,
							order = 13,
						},
					}
				}
			end
		end
   end
    
	-- Config Tables changed!
	AceConfigRegistry:NotifyChange(L["TITAN_PANEL"])
end
-- Show plugins no longer used. They have data but are not loaded
local optionsExtras = {
	name = L["TITAN_PANEL_EXTRAS"],
	type = "group",
	args = {}
 }
local function TitanUpdateExtras()
	local args = optionsExtras.args
	local plug_in = nil

	wipe(args)

	args["desc"] = {
		order = 1,
		type = "description",
		name = L["TITAN_PANEL_EXTRAS_DESC"].."\n",
		cmdHidden = true
	}
	for idx, value in pairs(TitanPluginExtras) do
		if TitanPluginExtras[idx] then
			local num = TitanPluginExtras[idx].num
			local name = TitanPluginExtras[idx].id
			args[name] = {
				type = "group",
				name = TitanUtils_GetGoldText(tostring(num)..": "..(name or "?")),
				order = idx,
				args = {
					name = {
						type = "description",
						name = TitanUtils_GetGoldText(name or "?"),
						cmdHidden = true,
						order = 10,
					},
					optionreset = {
						name = L["TITAN_PANEL_EXTRAS_DELETE_BUTTON"],
						order = 15, type = "execute", width = "full",
						func = function(info, v) 
							TitanPluginSettings[info[1]] = nil -- delete the config entry
							DEFAULT_CHAT_FRAME:AddMessage(
								TitanUtils_GetGoldText(L["TITAN_PANEL"])
								.." '"..info[1].."' "..L["TITAN_PANEL_EXTRAS_DELETE_MSG"]
								);
							TitanVariables_ExtraPluginSettings() -- rebuild the list
							TitanUpdateExtras() -- rebuild the options config
							AceConfigRegistry:NotifyChange("Titan Panel Addon Extras") -- tell Ace to redraw
						end,
					},
				}
			}
		end
   end
	
	AceConfigRegistry:NotifyChange("Titan Panel Addon Extras")
end
-- Delete toon data (not the one we are logged into)
local optionsChars = {
	name = "Titan "..L["TITAN_PANEL_MENU_PROFILES"],
	type = "group",
	args = {}
 }
local function TitanUpdateChars()
	local players = {};
	-- Rip through the players (with server name) to sort them
	for index, id in pairs(TitanSettings.Players) do
			table.insert(players, index);
	end

	-- set up the options for the user
	local args = optionsChars.args
	local plug_in = nil

	wipe(args)

	args["desc"] = {
		order = 1,
		type = "description",
		name = L["TITAN_PANEL_CHARS_DESC"].."\n",
		cmdHidden = true
	}
	args["custom_header"] = {
		order = 10,
		type = "header",
		name = L["TITAN_PANEL_MENU_PROFILE_CUSTOM"].."\n",
		cmdHidden = true
	}
	args["custom"] = {
		order = 20, type = "execute", width = "full",
		name = L["TITAN_PANEL_MENU_SAVE_SETTINGS"],
		func = function(info, v) 
			TitanPanel_SaveCustomProfile()
			TitanUpdateChars() -- rebuild the toons
		end,
	}
	args["sp_1"] = {
		type = "description",
		name = "",
		cmdHidden = true,
		order = 900,
	}
	args["profile_header"] = {
		order = 901,
		type = "header",
		name = L["TITAN_PANEL_MENU_PROFILES"].."\n",
		cmdHidden = true
	}
	for idx, value in pairs(players) do
		local name = (players[idx] or "?")
		if name and not (name == TitanSettings.Player) then -- do not display current character
			args[name] = {
				type = "group",
				name = TitanUtils_GetGoldText((name or "?")),
				desc = "",
				order = 1,
				args = {
					name = {
						type = "description",
						name = TitanUtils_GetGoldText(name or "?"),
						cmdHidden = true,
						order = 10,
					},
					sp_1 = {
						type = "description",
						name = "",
						cmdHidden = true,
						order = 11,
					},
					optionload = {
						name = L["TITAN_PANEL_MENU_LOAD_SETTINGS"],
						order = 20, type = "execute", width = "full",
						func = function(info, v) 
							TitanVariables_UseSettings(info[1])
							TitanPanelSettings.Buttons = newButtons;
							TitanPanelSettings.Location = newLocations;
						end,
					},
					sp_20 = {
						type = "description",
						name = "",
						cmdHidden = true,
						order = 21,
					},
					optionreset = {
						name = L["TITAN_PANEL_MENU_DELETE_SETTINGS"],
						order = 30, type = "execute", width = "full",
						func = function(info, v) 
							TitanSettings.Players[info[1]] = nil -- delete the config entry
							DEFAULT_CHAT_FRAME:AddMessage(
								_G["GREEN_FONT_COLOR_CODE"]..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]
								..": "..L["TITAN_PANEL_MENU_PROFILE"]
								.."|cffff8c00"..info[1].."|r"
								..L["TITAN_PANEL_MENU_PROFILE_DELETED"]
								);
							TitanUpdateChars() -- rebuild the toons
						end,
					},
				},
			}
		end
   end
    
	-- tell the options screen there is a new list
	AceConfigRegistry:NotifyChange("Titan Panel Addon Chars")
end
-- Plugin controls - show / hide parts; shift R/L; etc
local optionsAddons = {
	name = "Titan "..L["TITAN_PANEL_MENU_PLUGINS"],
	type = "group",
	args = {}
 }
local function TitanUpdateConfigAddons()
	local args = optionsAddons.args
	local plug_in = nil

	wipe(args)

	for idx, value in pairs(TitanPluginsIndex) do
		plug_in = TitanUtils_GetPlugin(TitanPluginsIndex[idx])
		if plug_in then
			args[plug_in.id] = {
				type = "group",
				name = (plug_in.menuText or ""),
				order = idx,
				args = {
					name = {
						type = "header",
						name = (tostring (plug_in.version) or ""),
						order = 1,
					},
					show = {
						type = "toggle",
						name = L["TITAN_PANEL_MENU_SHOW"],
						order = 3,
						get = function(info) return (TitanPanel_IsPluginShown(info[1])) end,
						set = function(info, v) 
							local name = info[1]
							if v then -- Show / add
								local bar = (TitanGetVar(name, "ForceBar") or "Bar")
								TitanUtils_AddButtonOnBar(bar, name)
							else -- Hide / remove
								TitanPanel_RemoveButton(name)
							end
							end,
					},
				}
			}
			
			--ShowIcon
			if plug_in.controlVariables and plug_in.controlVariables.ShowIcon then
				args[plug_in.id].args.icon =
				{
					type = "toggle",
					name = L["TITAN_PANEL_MENU_SHOW_ICON"],
					order = 4,
					get = function(info) return (TitanGetVar(info[1], "ShowIcon")) end,
					set = function(info, v) 
						TitanToggleVar(info[1], "ShowIcon");
						TitanPanelButton_UpdateButton(info[1])
						end,
				}
			end

			--ShowLabel
			if plug_in.controlVariables and plug_in.controlVariables.ShowLabelText then
				args[plug_in.id].args.label = {
					type = "toggle",
					name = L["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"],
					order = 5,
					get = function(info) return (TitanGetVar(info[1], "ShowLabelText")) end,
					set = function(info, v) 
						TitanToggleVar(info[1], "ShowLabelText");
						TitanPanelButton_UpdateButton(info[1])
					end,
				}
			end
			
			--ShowRegularText (LDB data sources only atm)
			if plug_in.controlVariables and plug_in.controlVariables.ShowRegularText then
				args[plug_in.id].args.regular_text =
				{
					type = "toggle",
					name = L["TITAN_PANEL_MENU_SHOW_PLUGIN_TEXT"],
					order = 6,
					get = function(info) return (TitanGetVar(info[1], "ShowRegularText")) end,
					set = function(info, v) 
						TitanToggleVar(info[1], "ShowRegularText");
						TitanPanelButton_UpdateButton(info[1])
						end,
				}
			end
			
			--ShowColoredText
			if plug_in.controlVariables and plug_in.controlVariables.ShowColoredText then
				args[plug_in.id].args.color_text = {
					type = "toggle",
					name = L["TITAN_PANEL_MENU_SHOW_COLORED_TEXT"],
					order = 7,
					get = function(info) return (TitanGetVar(info[1], "ShowColoredText")) end,
					set = function(info, v) 
						TitanToggleVar(info[1], "ShowColoredText");
						TitanPanelButton_UpdateButton(info[1])
					end,
				}
			end

			-- Right-side plugin
			if plug_in.controlVariables and plug_in.controlVariables.DisplayOnRightSide then
				args[plug_in.id].args.right_side = {
					type = "toggle",
					name = L["TITAN_PANEL_MENU_LDB_SIDE"],
					order = 8,
					get = function(info) return (TitanGetVar(info[1], "DisplayOnRightSide")) end,
					set = function(info, v)
						local bar = TitanUtils_GetWhichBar(info[1])
						TitanToggleVar(info[1], "DisplayOnRightSide");
						TitanPanel_RemoveButton(info[1]);
						TitanUtils_AddButtonOnBar(bar, info[1]);     
						TitanPanelButton_UpdateButton(info[1])
					end,
				}
			end
			-- Shift R / L
			args[plug_in.id].args.plugin_position = {
				order = 50,
				type = "header",
				name = L["TITAN_PANEL_MENU_POSITION"],
			}
			args[plug_in.id].args.shift_left = {
				type = "execute",
				name = "< "..L["TITAN_PANEL_SHIFT_LEFT"].."  ",
				order = 51,
				func = function(info, arg1)
					name = info[1]
					if TitanPanel_IsPluginShown(name) then
						TitanUtils_ShiftButtonOnBarLeft(name)
					end
				end,
			}
			args[plug_in.id].args.shift_right = {
				type = "execute",
				name = "> "..L["TITAN_PANEL_SHIFT_RIGHT"],
				order = 52,
				func = function(info, arg1)
					name = info[1]
					if TitanPanel_IsPluginShown(info[1]) then
						TitanUtils_ShiftButtonOnBarRight(name)
					end
				end,
			}
			args[plug_in.id].args.space_50_1 = {
				order = 53,
				type = "description",
				name = "  ",
				cmdHidden = true,
			}
			if not TitanVarExists(plug_in.id, "ForceBar") then
				args[plug_in.id].args.top_bottom = {
					order = 54, type = "select",
					name = L["TITAN_PANEL_MENU_BAR"],
					desc = L["TITAN_PANEL_MENU_DISPLAY_ON_BAR"],
					get = function(info) 
						return TitanUtils_GetWhichBar(info[1]) end,
					set = function(info,v)
						local name = info[1]
						if TitanPanel_IsPluginShown(name) then
							TitanUtils_AddButtonOnBar(v, name)
						end
					end,
					values = function()
						local Locationlist = {}
						local v
						for idx,v in pairs (TitanBarData) do
							if TitanPanelGetVar(TitanBarData[idx].name.."_Show") then
								Locationlist[TitanBarData[idx].name] = TitanBarData[idx].name
							end
						end
						return Locationlist
					end,
				}
			else
				args[plug_in.id].args.top_bottom = {
					order = 54,
					type = "description",
					name = TitanUtils_GetGoldText(L["TITAN_PANEL_MENU_BAR_ALWAYS"].." "..TitanGetVar(plug_in.id, "ForceBar")),
					cmdHidden = true,
				}
			end
		end
	end

	-- Config Tables changed!
	AceConfigRegistry:NotifyChange("Titan Panel Addon Control")
end

-- Event registration
_G[TITAN_PANEL_CONTROL]:RegisterEvent("ADDON_LOADED");
_G[TITAN_PANEL_CONTROL]:RegisterEvent("PLAYER_ENTERING_WORLD");
_G[TITAN_PANEL_CONTROL]:RegisterEvent("PLAYER_REGEN_DISABLED");
_G[TITAN_PANEL_CONTROL]:RegisterEvent("PLAYER_REGEN_ENABLED");
_G[TITAN_PANEL_CONTROL]:RegisterEvent("CVAR_UPDATE");
_G[TITAN_PANEL_CONTROL]:RegisterEvent("PLAYER_LOGOUT");
_G[TITAN_PANEL_CONTROL]:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
_G[TITAN_PANEL_CONTROL]:SetScript("OnEvent", function(_, event, ...)
	_G[TITAN_PANEL_CONTROL][event](_G[TITAN_PANEL_CONTROL], ...)
end)
	
-- Add Blizzard Configuration Panel
AceConfig:RegisterOptionsTable("Titan Panel Main", optionsControl)
AceConfig:RegisterOptionsTable("Titan Panel Bars", optionsBars)
AceConfig:RegisterOptionsTable("Titan Panel Aux Bars", optionsAuxBars)
AceConfig:RegisterOptionsTable("Titan Panel Frames", optionsFrames)
AceConfig:RegisterOptionsTable("Titan Panel Transparency Control", optionsTrans)
AceConfig:RegisterOptionsTable("Titan Panel Panel Control", optionsUIScale)
AceConfig:RegisterOptionsTable("Titan Panel Skin Control", optionsSkins)
AceConfig:RegisterOptionsTable("Titan Panel Skin Custom", optionsSkinsCustom)
AceConfig:RegisterOptionsTable("Titan Panel Addon Control", optionsAddons)
AceConfig:RegisterOptionsTable("Titan Panel Addon Attempts", optionsAddonAttempts)
AceConfig:RegisterOptionsTable("Titan Panel Addon Extras", optionsExtras)
AceConfig:RegisterOptionsTable("Titan Panel Addon Chars", optionsChars)

AceConfigDialog:AddToBlizOptions("Titan Panel Main", L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Bars", L["TITAN_PANEL_MENU_OPTIONS_BARS"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Aux Bars", "Aux "..L["TITAN_PANEL_MENU_OPTIONS_BARS"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Addon Control", L["TITAN_PANEL_MENU_PLUGINS"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Addon Chars", L["TITAN_PANEL_MENU_PROFILES"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Frames", L["TITAN_PANEL_MENU_OPTIONS_SHORT"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Panel Control", L["TITAN_UISCALE_MENU_TEXT_SHORT"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Transparency Control", L["TITAN_TRANS_MENU_TEXT_SHORT"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Skin Control", L["TITAN_PANEL_MENU_TEXTURE_SETTINGS"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Skin Custom", "Skins - Custom", L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Addon Extras", L["TITAN_PANEL_EXTRAS_SHORT"], L["TITAN_PANEL"])
AceConfigDialog:AddToBlizOptions("Titan Panel Addon Attempts", L["TITAN_PANEL_ATTEMPTS_SHORT"], L["TITAN_PANEL"])

-- Local routines
local function TitanPanelFrame_ScreenAdjust()
	if not InCombatLockdown() then
		TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, true)
	end
end

local function TitanPanel_SetTransparent(frame, position)
	local frName = _G[frame];
	
	if (position == TITAN_PANEL_PLACE_TOP) then
		frName:ClearAllPoints();
		frName:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, 0);
		frName:SetPoint("BOTTOMRIGHT", "UIParent", "TOPRIGHT", 0, -TITAN_PANEL_BAR_HEIGHT);
	else
		frName:ClearAllPoints();
		frName:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0); 
		frName:SetPoint("TOPRIGHT", "UIParent", "BOTTOMRIGHT", 0, TITAN_PANEL_BAR_HEIGHT); 
	end
end

local function TitanPanel_CreateABar(frame)
	local hide_name = TitanBarData[frame].hider
	local bar_name = TitanBarData[frame].name

	-- Set script handlers for display
	_G[frame]:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	_G[frame]:SetScript("OnEnter", function(self) TitanPanelBarButton_OnEnter(self) end)
	_G[frame]:SetScript("OnLeave", function(self) TitanPanelBarButton_OnLeave(self) end)
	_G[frame]:SetScript("OnClick", function(self, button) TitanPanelBarButton_OnClick(self, button) end)

	-- Set script handlers for display
	_G[hide_name]:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	_G[hide_name]:SetScript("OnEnter", function(self) TitanPanelBarButtonHider_OnEnter(self) end)
	_G[hide_name]:SetScript("OnLeave", function(self) TitanPanelBarButtonHider_OnLeave(self) end)
	_G[hide_name]:SetScript("OnClick", function(self, button) TitanPanelBarButton_OnClick(self, button) end)
	
	_G[hide_name]:SetFrameStrata("BACKGROUND")
	_G[hide_name]:SetHeight(TITAN_PANEL_BAR_HEIGHT);
	_G[hide_name]:SetWidth(2560);
	
	-- Set the display bar
	local container = _G[frame]
	container:SetHeight(TITAN_PANEL_BAR_HEIGHT);
	-- Set local identifier
	local container_text = _G[frame.."_Text"]
	if container_text then -- was used for debug/creating of the independent bars
		container_text:SetText(tostring(bar_name))
		-- for now show it
		container:Show()
	end
end
-- End Local routines

function TitanPanel_PlayerEnteringWorld()
	if Titan__InitializedPEW then
		-- Also sync the LDB object with the Tian plugin
		TitanLDBRefreshButton()
	else
		-- only do this sort of initialization on the first PEW event
		
		-- Ensure the bars are created before the 
		-- plugins are registered. 
		for idx, v in pairs (TitanBarData) do
			TitanPanel_CreateABar(idx)
		end

		local realmName = GetCVar("realmName")

		if ServerTimeOffsets[realmName] then
			TitanSetVar(TITAN_CLOCK_ID, "OffsetHour", ServerTimeOffsets[realmName])
		elseif TitanGetVar(TITAN_CLOCK_ID, "OffsetHour") then
			ServerTimeOffsets[realmName] = TitanGetVar(TITAN_CLOCK_ID, "OffsetHour")
		end
	
		if ServerHourFormat[realmName] then
			TitanSetVar(TITAN_CLOCK_ID, "Format", ServerHourFormat[realmName])
		elseif TitanGetVar(TITAN_CLOCK_ID, "Format") then
			ServerHourFormat[realmName] = TitanGetVar(TITAN_CLOCK_ID, "Format")
		end
	end

	-- Some addons wait to create their LDB component or a Titan addon could
	-- create additional buttons as needed.
	-- So we need to sync their variables and set them up
	TitanUtils_RegisterPluginList()

	-- Init detailed settings only after plugins are registered!
	TitanVariables_InitDetailedSettings()
	
	-- all addons are loaded so update the config (options)
	-- some could have registered late...
	TitanUpdateConfigAddons()
	TitanUpdateAddonAttempts()
	TitanUpdateExtras()
	TitanUpdateChars()

	-- Init panel font
	local isfontvalid = media:IsValid("font", TitanPanelGetVar("FontName"))
	if isfontvalid then
		TitanSetPanelFont(TitanPanelGetVar("FontName"), TitanPanelGetVar("FontSize"))
	else
	-- if the selected font is not valid, revert to default (Friz Quadrata TT)
		TitanPanelSetVar("FontName", "Friz Quadrata TT");
		TitanSetPanelFont("Friz Quadrata TT", TitanPanelGetVar("FontSize"))
	end

	-- Init panel frame strata
	TitanVariables_SetPanelStrata(TitanPanelGetVar("FrameStrata"))

	-- Move frames
	TitanPanelFrame_ScreenAdjust();
	
	-- Init panel buttons
	TitanPanel_InitPanelBarButton();
	TitanPanel_InitPanelButtons();
	TitanMovable_SecureFrames()

	-- Secondary failsafe check for bottom frame adjustment
--	AceTimer.ScheduleTimer("TitanPanelAdjustBottomFrames", TitanAdjustBottomFrames, 5);
-- needed???


	Titan__InitializedPEW = true
end

-- Event handlers
function TitanPanelBarButton:ADDON_LOADED(addon)
	if addon == "Titan" then
		-- Init Profile/Saved Vars
		TitanVariables_InitTitanSettings();			
		local VERSION = TitanPanel_GetVersion();
		local POS = strfind(VERSION," - ");
		VERSION = strsub(VERSION,1,POS-1);
		DEFAULT_CHAT_FRAME:AddMessage(
			TitanUtils_GetGoldText(L["TITAN_PANEL"].." (")
			..TitanUtils_GetGreenText(VERSION)
			..TitanUtils_GetGoldText(")"..L["TITAN_PANEL_VERSION_INFO"])
			);

		if not ServerTimeOffsets then
			ServerTimeOffsets = {};
		end
		if not ServerHourFormat then
			ServerHourFormat = {};
		end
		-- Unregister event - saves a few event calls.
		self:UnregisterEvent("ADDON_LOADED");
		self.ADDON_LOADED = nil
	end
end

function TitanPanelBarButton:PLAYER_ENTERING_WORLD()
	TitanPanel_PlayerEnteringWorld()
end

function TitanPanelBarButton:CVAR_UPDATE(cvarname, cvarvalue)
	if cvarname == "USE_UISCALE" 
	or cvarname == "WINDOWED_MODE" 
	or cvarname == "uiScale" then
		if TitanPlayerSettings and TitanPanelGetVar("Scale") then
			Titan_AdjustScale()
			-- Adjust frame positions
			TitanPanelFrame_ScreenAdjust();
		end
	end
end

function TitanPanelBarButton:PLAYER_LOGOUT()
	if not IsTitanPanelReset then
		-- save bars settings on logout to avoid "garbage" in savedvars buttons table
		if TitanPanelSettings then -- Issue 490...
			TitanPanelSettings.Buttons = newButtons;
			TitanPanelSettings.Location = newLocations;
		end
		
		-- for debug
		TitanPanelRegister.ToBe = TitanPluginToBeRegistered
		TitanPanelRegister.ToBeNum = TitanPluginToBeRegisteredNum
		TitanPanelRegister.TitanPlugins = TitanPlugins
		TitanPanelRegister.Extras = TitanPluginExtras
	end
end

function TitanPanelBarButton:PLAYER_REGEN_DISABLED()
-- If in combat close all control frames and menus
	TitanUtils_CloseAllControlFrames();
	TitanUtils_CloseRightClickMenu();
end

function TitanPanelBarButton:PLAYER_REGEN_ENABLED()
	-- Outside combat check to see if frames need correction
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, true)
end

function TitanPanelBarButton:ACTIVE_TALENT_GROUP_CHANGED()
	AceTimer.ScheduleTimer("TitanPanelAdjustBottomDualSpec", Titan_ManageFramesNew, 3)
end

function TitanPanelBarButton_OnClick(self, button)
	-- ensure that the right-click menu will not appear on "hidden" bottom bar(s)
	local bar = self:GetName();
	if (button == "LeftButton") then
		TitanUtils_CloseAllControlFrames();
		TitanUtils_CloseRightClickMenu();	
	elseif (button == "RightButton") then
		TitanUtils_CloseAllControlFrames();			
		TitanPanelRightClickMenu_Close();
		-- Show RightClickMenu anyway
		TitanPanelDisplayRightClickMenu_Toggle(self)  -- self not used...
	end
end

-- Slash command handler
local function TitanPanel_RegisterSlashCmd(cmd)
	--
	--	reset routines
	--
	if (string.lower(cmd) == "reset") then
		TitanPanel_ResetToDefault();
		return;
	end
	if (string.lower(cmd) == "reset tipfont") then
		TitanPanelSetVar("TooltipFont", 1);
		GameTooltip:SetScale(TitanPanelGetVar("TooltipFont"));
		DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_RESP1"]);
		return;
	end
	if (string.lower(cmd) == "reset tipalpha") then
		TitanPanelSetVar("TooltipTrans", 1);
		local red, green, blue, _ = GameTooltip:GetBackdropColor();
		local red2, green2, blue2, _ = GameTooltip:GetBackdropBorderColor();
		GameTooltip:SetBackdropColor(red,green,blue,TitanPanelGetVar("TooltipTrans"));
		GameTooltip:SetBackdropBorderColor(red2,green2,blue2,TitanPanelGetVar("TooltipTrans"));
		DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_RESP2"]);
		return;
	end
	if (string.lower(cmd) == "reset panelscale") then
		if not InCombatLockdown() then
			TitanPanelSetVar("Scale", 1);
			-- Adjust panel scale
			Titan_AdjustScale()
			-- Adjust frame positions
			TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, true)
			DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_RESP3"]);
		else
			DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
				..L["TITAN_PANEL"].._G["FONT_COLOR_CODE_CLOSE"]..": "
				..L["TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN"]);
		end
		return;
	end
	if (string.lower(cmd) == "reset spacing") then
		TitanPanelSetVar("ButtonSpacing", 20);
		TitanPanel_InitPanelButtons();
		DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_RESP4"]);
		return;
	end
	
	--
	--	GUI routines
	--
	if (string.lower(cmd) == "gui control") then
		InterfaceOptionsFrame_OpenToCategory(L["TITAN_UISCALE_MENU_TEXT_SHORT"])
		return;
	end
	if (string.lower(cmd) == "gui trans") then
		InterfaceOptionsFrame_OpenToCategory(L["TITAN_TRANS_MENU_TEXT_SHORT"])
		return;
	end
	if (string.lower(cmd) == "gui skin") then
		InterfaceOptionsFrame_OpenToCategory(L["TITAN_PANEL_MENU_TEXTURE_SETTINGS"])
		return;
	end

	--
	--	Give the user the general help if we can not figure out what they want
	--
   DEFAULT_CHAT_FRAME:AddMessage(_G["LIGHTYELLOW_FONT_COLOR_CODE"]
		..L["TITAN_PANEL"].." ".._G["GREEN_FONT_COLOR_CODE"]
		..TitanPanel_GetVersion().._G["LIGHTYELLOW_FONT_COLOR_CODE"]
		..L["TITAN_PANEL_VERSION_INFO"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING2"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING3"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING4"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING5"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING6"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING7"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING8"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING9"]);
   DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING10"]);
 --  DEFAULT_CHAT_FRAME:AddMessage(L["TITAN_PANEL_SLASH_STRING11"]);
end

-- Register slash commands for Titan Panel
SlashCmdList["TitanPanel"] = TitanPanel_RegisterSlashCmd;
SLASH_TitanPanel1 = "/titanpanel";
SLASH_TitanPanel2 = "/titan";

-- Texture routines
function TitanPanel_ClearAllBarTextures()
-- Clear textures if they already exist
	for idx,v in pairs (TitanBarData) do
		for i = 0, numOfTexturesHider do
			tex = TITAN_PANEL_BACKGROUND_PREFIX..TitanBarData[idx].name.."_"..i
			if _G[tex] then
				_G[tex]:SetTexture()
			end
		end
	end
end

function TitanPanel_CreateBarTextures()
	-- Create the basic Titan bars (textures)
	local i, titanTexture
	local texture_path = TitanPanelGetVar("TexturePath")
	local bar_name
	local screenWidth
	local lastTextureWidth
	local tex, tex_pre
	
	-- loop through the bars to set the texture
	for idx,v in pairs (TitanBarData) do
		bar_name = TITAN_PANEL_DISPLAY_PREFIX..TitanBarData[idx].name
		screenWidth = (_G[bar_name]:GetWidth() or GetScreenWidth()) + 1
		numOfTextures = floor(screenWidth / 256)
		numOfTexturesHider = (numOfTextures * 2) + 1
		lastTextureWidth = screenWidth - (numOfTextures * 256)
		
		for i = 0, numOfTextures do
			-- Create textures if they don't exist
			tex = TITAN_PANEL_BACKGROUND_PREFIX..TitanBarData[idx].name.."_"..i
			tex_pre = TITAN_PANEL_BACKGROUND_PREFIX..TitanBarData[idx].name.."_"..i-1
			if not _G[tex] then
				titanTexture = _G[bar_name]:CreateTexture(tex, "BACKGROUND")
			else
				titanTexture = _G[tex]
			end
			titanTexture:SetHeight(30)  --(32)
			if i == numOfTextures then
				titanTexture:SetWidth(lastTextureWidth)
			else
			  titanTexture:SetWidth(256)
			end
			titanTexture:ClearAllPoints()
			if i == 0 then
				titanTexture:SetPoint("TOPLEFT", bar_name, "TOPLEFT", 0, 0) --  -1, 0)
			else
				titanTexture:SetPoint("TOPLEFT", tex_pre, "TOPRIGHT")
			end
		end
		titanTexture:SetWidth(256)

		-- Handle Hider Textures
		for i = numOfTextures + 1, numOfTexturesHider do
			tex = TITAN_PANEL_BACKGROUND_PREFIX..TitanBarData[idx].name.."_"..i
			tex_pre = TITAN_PANEL_BACKGROUND_PREFIX..TitanBarData[idx].name.."_"..i-1
			if not _G[tex] then
				titanTexture = _G[bar_name]:CreateTexture(tex, "BACKGROUND")
			else
				titanTexture = _G[tex]
			end
			titanTexture:SetHeight(TITAN_PANEL_BAR_HEIGHT) --(30)
			if i == numOfTexturesHider then
				titanTexture:SetWidth(lastTextureWidth)
			else
				titanTexture:SetWidth(256)
			end
			titanTexture:ClearAllPoints()
			titanTexture:SetPoint("TOPLEFT", tex_pre, "TOPRIGHT")
		end
	end
end

function TitanPanel_SetTexture(frame, position)
	-- Determine the bar that needs the texture applied.
	local bar = TitanBarData[frame].name
	local vert = TitanBarData[frame].vert
	local tex = "TitanPanelBackground"
	local tex_pre = tex.."_"..bar.."_"

	-- Create the path & file name to the texture
	local texture_file = TitanPanelGetVar("TexturePath")..tex..vert.."0"
	-- include the normal bar (numOfTextures) and hider textures (numOfTexturesHider)
	for i = 0, numOfTexturesHider do
		_G[tex_pre..i]:SetTexture(texture_file);			
	end
end

-- auto hide event handlers
function TitanPanelBarButton_OnLeave(self)
	-- On leaving the display check if we have to hide the bar
	local frame = (self and self:GetName() or nil)
	local bar = (TitanBarData[frame] and TitanBarData[frame].name or nil)
	
	-- if auto hide is active then let the timer hide the bar
	local hide = (bar and TitanPanelGetVar(bar.."_Hide") or nil)
	if hide then
		Titan_AutoHide_Timers(frame, "Leave")
	end
end

function TitanPanelBarButton_OnEnter(self)
	-- no work to do
end

function TitanPanelBarButtonHider_OnLeave(self)
	-- no work to do
end

function TitanPanelBarButtonHider_OnEnter(self)
	-- On entering the hider check if we need to show the
	-- display bar.
	
	-- make sure self is valid
	local index = self and self:GetName() or nil
	if not index then return end -- sanity check
	
	-- find the relevant bar data
	local frame = nil
	for idx,v in pairs (TitanBarData) do
		if index == TitanBarData[idx].hider then
			frame = idx
		end
	end
	-- Now process that bar
	if frame then
		Titan_AutoHide_Timers(frame, "Enter")
		TitanPanelBarButton_Show(frame)
	end
end
-- Titan features
function TitanPanelBarButton_ToggleAlign(align)
	-- toggle between left or center
	if ( TitanPanelGetVar(align) == TITAN_PANEL_BUTTONS_ALIGN_CENTER ) then
		TitanPanelSetVar(align, TITAN_PANEL_BUTTONS_ALIGN_LEFT);
	else
		TitanPanelSetVar(align, TITAN_PANEL_BUTTONS_ALIGN_CENTER);
	end
	
	-- Justify button position
	TitanPanelButton_Justify();
end

function TitanPanelBarButton_ToggleAutoHide(frame)
	local frName = _G[frame]
	local plugin = (TitanBarData[frame] and TitanBarData[frame].auto_hide_plugin or nil)
	local var = TitanBarData[frame].name.."_Hide"
	local hide = TitanPanelGetVar(var)

	if frName then
		Titan_AutoHide_ToggleAutoHide(_G[plugin])
	end
end

function TitanPanelBarButton_ToggleScreenAdjust()
	-- Turn on / off adjusting of other frames around Titan
	TitanPanelToggleVar("ScreenAdjust");
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_TOP, true)
end

function TitanPanelBarButton_ToggleAuxScreenAdjust()
	-- turn on / off adjusting of frames at the bottom of the screen
	TitanPanelToggleVar("AuxScreenAdjust");
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTTOM, true)
end

function TitanPanelBarButton_ForceLDBLaunchersRight()
	local plugin, index, id;
	for index, id in pairs(TitanPluginsIndex) do
		plugin = TitanUtils_GetPlugin(id);
		if plugin.ldb == "launcher" 
		and not TitanGetVar(id, "DisplayOnRightSide") then
			TitanToggleVar(id, "DisplayOnRightSide");
			local button = TitanUtils_GetButton(id);
			local buttonText = _G[button:GetName().."Text"];
			if not TitanGetVar(id, "ShowIcon") then
				TitanToggleVar(id, "ShowIcon");	
			end
			TitanPanelButton_UpdateButton(id);
			if buttonText then
				buttonText:SetText("")
				button:SetWidth(16);
				TitanPlugins[id].buttonTextFunction = nil;
				_G["TitanPanel"..id.."ButtonText"] = nil;
				if button:IsVisible() then
					local bar = TitanUtils_GetWhichBar(id)
					TitanPanel_RemoveButton(id);
					TitanUtils_AddButtonOnBar(bar, id)     
				end
			end
		end
	end
end

function TitanPanelBarButton_DisplayBarsWanted()
	-- Check all bars to see if the user has requested they be shown
	for idx,v in pairs (TitanBarData) do
		-- Show / hide plus kick auto hide, if needed
		Titan_AutoHide_Init((_G[TitanBarData[idx].auto_hide_plugin] or nil))
	end

	-- Adjust other frames because the bars shown / hidden may have changed
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, true)
end

function TitanPanelBarButton_Show(frame)
	local display = _G[frame];
	local bar = (TitanBarData[frame].name or nil)
	local hide = TitanBarData[frame] and TitanBarData[frame].hide or nil
	local show = TitanBarData[frame] and TitanBarData[frame].show or nil
	local hider = _G[TitanBarData[frame].hider] or nil

	if bar and display and hider and show and hide 
	then
		-- Show the display bar if the user requested it
		if (TitanPanelGetVar(bar.."_Show")) then
			if hide and show then
				display:ClearAllPoints();
				display:SetPoint(show.top.pt, show.top.rel_fr, show.top.rel_pt, show.top.x, show.top.y); 
				display:SetPoint(show.bot.pt, show.bot.rel_fr, show.bot.rel_pt, show.bot.x, show.bot.y);
				
				hider:Hide()
			end
		else
			-- The user has not elected to show this bar
			display:ClearAllPoints();
			display:SetPoint(hide.top.pt, hide.top.rel_fr, hide.top.rel_pt, hide.top.x, hide.top.y); 
			display:SetPoint(hide.bot.pt, hide.bot.rel_fr, hide.bot.rel_pt, hide.bot.x, hide.bot.y);
			hider:ClearAllPoints();
			hider:SetPoint(hide.top.pt, hide.top.rel_fr, hide.top.rel_pt, hide.top.x, hide.top.y); 
			hider:SetPoint(hide.bot.pt, hide.bot.rel_fr, hide.bot.rel_pt, hide.bot.x, hide.bot.y);
		end
	end
end

function TitanPanelBarButton_Hide(frame)
	if TITAN_PANEL_MOVING == 1 then return end

	local display = _G[frame]
	local data = TitanBarData[frame]
	local hider = _G[data.hider]
	local bar = (data.name or nil)
	local hide = data.hide or nil
	local show = data.show or nil

	if display and hider and bar and show and hide then
		-- This moves rather than hides. If we just hide then
		-- the plugins will still show.
		display:ClearAllPoints();
		display:SetPoint(hide.top.pt, hide.top.rel_fr, hide.top.rel_pt, hide.top.x, hide.top.y); 
		display:SetPoint(hide.bot.pt, hide.bot.rel_fr, hide.bot.rel_pt, hide.bot.x, hide.bot.y);
		if (TitanPanelGetVar(bar.."_Show")) and (TitanPanelGetVar(bar.."_Hide")) then
			-- Auto hide is requested so show the hider bar in the right place
			hider:ClearAllPoints();
			hider:SetPoint(show.top.pt, show.top.rel_fr, show.top.rel_pt, show.top.x, show.top.y); 
			hider:SetPoint(show.bot.pt, show.bot.rel_fr, show.bot.rel_pt, show.bot.x, show.bot.y);
			hider:Show()
		else
			-- The bar was not requested so also move the hider bar to the right place
			hider:ClearAllPoints();
			hider:SetPoint(hide.top.pt, hide.top.rel_fr, hide.top.rel_pt, hide.top.x, hide.top.y); 
			hider:SetPoint(hide.bot.pt, hide.bot.rel_fr, hide.bot.rel_pt, hide.bot.x, hide.bot.y);
		end
	end
end

function TitanPanel_InitPanelBarButton()
	-- Set initial Panel Scale
	TitanPanel_SetScale();
	-- Create textures for the first time
	if numOfTextures == 0 then TitanPanel_CreateBarTextures() end

	-- Reposition textures if needed
	TitanPanel_CreateBarTextures()
	for idx,v in pairs (TitanBarData) do
		TitanPanel_SetTexture(TITAN_PANEL_DISPLAY_PREFIX..TitanBarData[idx].name, TITAN_PANEL_PLACE_TOP);
	end
	
	-- Set transparency of the bars
	local bar = ""
	local plugin = nil
	for idx,v in pairs (TitanBarData) do
		-- Set the transparency of each bar
		bar = TitanBarData[idx].name
		_G[idx]:SetAlpha(TitanPanelGetVar(bar.."_Transparency"))
	end
end

function TitanPanel_InitPanelButtons()
	local button
	local r_prior = {}
	local l_prior = {}
	local scale = TitanPanelGetVar("Scale");
	local button_spacing = TitanPanelGetVar("ButtonSpacing") * scale
--	
	local prior = {}
	-- set prior to the starting offsets
	-- The right side plugins are set here.
	-- Justify adjusts the left side start according to the user setting
	-- The effect is left side plugins has spacing on the right side and
	-- right side plugins have spacing on the left.
	for idx,v in pairs (TitanBarData) do
		local bar = TitanBarData[idx].name
		local y_off = TitanBarData[idx].plugin_y_offset
		prior[bar] = {
			right = { 
				button = TITAN_PANEL_DISPLAY_PREFIX..bar, 
				anchor = "RIGHT",
				x = 5, -- Offset of first plugin to right side of screen
				y = y_off,
				},
			left = {
				button = TITAN_PANEL_DISPLAY_PREFIX..bar, 
				anchor = "LEFT",
				x = 0, -- Justify adjusts - center or not
				y = y_off,
				},
			}
	end
--	
	newButtons = {};
	newLocations = {};
	TitanPanelBarButton_DisplayBarsWanted();

	-- Position all the buttons 
	for i = 1, table.maxn(TitanPanelSettings.Buttons) do 
	
		local id = TitanPanelSettings.Buttons[i];
		if ( TitanUtils_IsPluginRegistered(id) ) then
			local i = TitanPanel_GetButtonNumber(id);
			button = TitanUtils_GetButton(id);

			-- If the plugin has asked to be on the right
			if TitanUtils_ToRight(id) then	
				-- =========================
				-- position the plugin relative to the prior plugin 
				-- or the bar if it is the 1st
				r_prior = prior[TitanPanelSettings.Location[i]].right
				-- =========================
				button:ClearAllPoints();
				button:SetPoint("RIGHT", _G[r_prior.button]:GetName(), r_prior.anchor, (-(r_prior.x) * scale), r_prior.y); 

				-- =========================
				-- capture the button for the next plugin
				r_prior.button = "TitanPanel"..id.."Button"
				-- set prior[x] the anchor points and offsets for the next plugin
				r_prior.anchor = "LEFT"
				r_prior.x = TITAN_PANEL_ICON_SPACING
				r_prior.y = 0
				-- =========================
			else
				--  handle plugins on the left side of the bar
				--
				-- =========================
				-- position the plugin relative to the prior plugin 
				-- or the bar if it is the 1st
				l_prior = prior[TitanPanelSettings.Location[i]].left
				-- =========================
				--
				button:ClearAllPoints();
				button:SetPoint("LEFT", _G[l_prior.button]:GetName(), l_prior.anchor, l_prior.x * scale, l_prior.y);
					
				-- =========================
				-- capture the plugin for the next plugin
				l_prior.button = "TitanPanel"..id.."Button"
				-- set prior[x] (anchor points and offsets) for the next plugin
				l_prior.anchor = "RIGHT"
				l_prior.x = (button_spacing)
				l_prior.y = 0
				-- =========================
			end
			table.insert(newButtons, id);
			table.insert(newLocations, TitanPanelSettings.Location[i]);
			button:Show();
		end
	end
	-- Set panel button init flag
	TITAN_PANEL_BUTTONS_INIT_FLAG = 1;
	TitanPanelButton_Justify();
end

function TitanPanel_ReOrder(index)
	for i = index, table.getn(TitanPanelSettings.Buttons) do		
		TitanPanelSettings.Location[i] = TitanPanelSettings.Location[i+1]
	end
end

function TitanPanel_RemoveButton(id)
	if ( not TitanPanelSettings ) then
		return;
	end 

	local i = TitanPanel_GetButtonNumber(id)
	local currentButton = TitanUtils_GetButton(id);
	
	-- safeguard to destroy any active plugin timers based on a fixed naming
	-- convention : TitanPanel..id, eg. "TitanPanelClock"
	-- this prevents "rogue" timers being left behind by lack of an OnHide check
	if id then AceTimer.CancelAllTimers("TitanPanel"..id) end

	TitanPanel_ReOrder(i);
	table.remove(TitanPanelSettings.Buttons, TitanUtils_GetCurrentIndex(TitanPanelSettings.Buttons, id));
	if currentButton then
		currentButton:Hide();
	end
	-- Show the existing buttons
	TitanPanel_InitPanelButtons();
end

function TitanPanel_GetButtonNumber(id)
	if (TitanPanelSettings) then
		for i = 1, table.getn(TitanPanelSettings.Buttons) do		
			if(TitanPanelSettings.Buttons[i] == id) then
				return i;
			end	
		end
		return table.getn(TitanPanelSettings.Buttons)+1;
	else
		return 0;
	end
end

function TitanPanel_RefreshPanelButtons()
	if (TitanPanelSettings) then
		for i = 1, table.getn(TitanPanelSettings.Buttons) do		
			TitanPanelButton_UpdateButton(TitanPanelSettings.Buttons[i], 1);		
		end
	end
end

function TitanPanelButton_Justify()
	-- Only the left side buttons are justified.
	if ( not TITAN_PANEL_BUTTONS_INIT_FLAG or not TitanPanelSettings ) then
		return;
	end

	local bar
	local vert
	local y_offset
	local firstLeftButton
	local scale = TitanPanelGetVar("Scale");
	local button_spacing = TitanPanelGetVar("ButtonSpacing") * scale
	local leftWidth = 0;
	local rightWidth = 0;
	local counter = 0;
	local align = 0;
	local center_offset = 0;

	-- Look at each bar for plugins.
	for idx,v in pairs (TitanBarData) do
		bar = TitanBarData[idx].name
		vert = TitanBarData[idx].vert
		y_offset = TitanBarData[idx].plugin_y_offset
		firstLeftButton = TitanUtils_GetButton(TitanPanelSettings.Buttons[TitanUtils_GetFirstButtonOnBar (bar, TITAN_LEFT)])
		align = TitanPanelGetVar(bar.."_Align")
		leftWidth = 0;
		rightWidth = 0;
		counter = 0;
		-- If there is a plugin on this bar then justify the first button.
		-- The other buttons are relative to the first.
		if ( firstLeftButton ) then
			if ( align == TITAN_PANEL_BUTTONS_ALIGN_LEFT ) then
				-- Now offset the plugins
				firstLeftButton:ClearAllPoints();
				firstLeftButton:SetPoint("LEFT", idx, "LEFT", 5, y_offset); 
			end
			-- Center if requested
			if ( align == TITAN_PANEL_BUTTONS_ALIGN_CENTER ) then
				leftWidth = 0;
				rightWidth = 0;
				counter = 0;
				-- Calc the total width of the icons so we know where to start
				for index, id in pairs(TitanPanelSettings.Buttons) do
					local button = TitanUtils_GetButton(id);
					if button and button:GetWidth() then
						if TitanUtils_GetWhichBar(id) == bar then
							if ( TitanPanelButton_IsIcon(id) 
							or (TitanGetVar(id, "DisplayOnRightSide")) ) then
								rightWidth = rightWidth 
									+ TITAN_PANEL_ICON_SPACING 
									+ button:GetWidth();
							else
								counter = counter + 1;
								leftWidth = leftWidth 
									+ button_spacing
									+ button:GetWidth()
							end
						end
					end
				end
				-- Now offset the plugins on the bar
				firstLeftButton:ClearAllPoints();
				-- remove the last spacing otherwise the buttons appear justified too far left
				center_offset = (0 - (leftWidth-button_spacing) / 2)
				firstLeftButton:SetPoint("LEFT", idx, "CENTER", center_offset, y_offset); 
			end
		end
	end
end

function TitanPanel_SetScale()
	local scale = TitanPanelGetVar("Scale");

	-- Set all the Titan bars
	for idx,v in pairs (TitanBarData) do
		local bar_name = TITAN_PANEL_DISPLAY_PREFIX..TitanBarData[idx].name
		_G[bar_name]:SetScale(scale)
	end
	-- Set all the registered plugins
	for index, value in pairs(TitanPlugins) do
		if index then
			TitanUtils_GetButton(index):SetScale(scale);
		end
	end
end

function TitanPanel_LoadError(ErrorMsg) 
	StaticPopupDialogs["LOADING_ERROR"] = {
		text = ErrorMsg,
		button1 = TEXT(OKAY),
		showAlert = 1,
		timeout = 0,
	};
	StaticPopup_Show("LOADING_ERROR");
end

-- Local routines for Titan menu creation
local function TitanPanelRightClickMenu_BarOnClick(checked, value)
	-- value is the plugin id
	
	-- we need to know which bar the user clicked to get the menu...
	local frame = TitanPanel_DropMenu:GetParent():GetName()
	local bar = TitanBarData[frame].name

	if checked then
		TitanPanel_RemoveButton(value);		
	else
		TitanUtils_AddButtonOnBar(bar, value)
	end
end

local function TitanPanel_MainMenu()	
	local info = {};

	TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_TITLE"]);
	TitanPanelRightClickMenu_AddSpacer(UIDROPDOWNMENU_MENU_LEVEL);
	
	TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_PLUGINS"]);

	-- Plugin Categories
	for index, id in pairs(L["TITAN_PANEL_MENU_CATEGORIES"]) do
		info = {};
		info.notCheckable = true
		info.text = L["TITAN_PANEL_MENU_CATEGORIES"][index];
		info.value = "Addons_" .. TITAN_PANEL_BUTTONS_PLUGIN_CATEGORY[index];
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);
	end

	TitanPanelRightClickMenu_AddSpacer();

--[[
	TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_CONFIGURATION"]);

	-- Plugins
 	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_PLUGINS"]
	info.value = "Plugins";	
	info.func = function() 
		InterfaceOptionsFrame_OpenToCategory(L["TITAN_PANEL_MENU_PLUGINS"])
	end
	UIDropDownMenu_AddButton(info);

	-- Options
 	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_OPTIONS_BARS"];
	info.value = "Bars";	
	info.func = function() 
		InterfaceOptionsFrame_OpenToCategory(L["TITAN_PANEL_MENU_OPTIONS_BARS"]) 
	end
	UIDropDownMenu_AddButton(info);
--]]
	-- Options - just one button to open the first Titan option screen
 	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_CONFIGURATION"];
	info.value = "Bars";	
	info.func = function() 
		InterfaceOptionsFrame_OpenToCategory(L["TITAN_PANEL_MENU_OPTIONS_BARS"]) 
	end
	UIDropDownMenu_AddButton(info);

	TitanPanelRightClickMenu_AddSpacer();
	
	-- Profiles
	TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_PROFILES"]);
	
	-- Load/Delete
	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_MANAGE_SETTINGS"];
	info.value = "Settings";
	info.hasArrow = 1;
	-- lock this menu in combat
	if InCombatLockdown() then
		info.disabled = 1;
		info.hasArrow = nil;
		info.text = info.text.." "
			.._G["GREEN_FONT_COLOR_CODE"]
			..L["TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN"];
		end
	UIDropDownMenu_AddButton(info);
	
	-- Save
	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_SAVE_SETTINGS"];
	info.value = "SettingsCustom";
	info.func = TitanPanel_SaveCustomProfile;
	-- lock this menu in combat
	if InCombatLockdown() then
		info.disabled = 1;
		info.text = info.text.." "
			.._G["GREEN_FONT_COLOR_CODE"]
			..L["TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN"];
		end
	UIDropDownMenu_AddButton(info);
end

local function TitanPanel_ServerSettingsMenu()
	local info = {};
	local servers = {};
	local player = nil;
	local server = nil;
	local s, e, ident;
	local setonce = 0;

	if ( UIDROPDOWNMENU_MENU_VALUE == "Settings" ) then
		TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_PROFILE_SERVERS"],
			UIDROPDOWNMENU_MENU_LEVEL);
		-- Normal profile per toon
		for index, id in pairs(TitanSettings.Players) do
			s, e, ident = string.find(index, TITAN_AT);
			if s ~= nil then
				server = string.sub(index, s+1);
				player = string.sub(index, 1, s-1);
			else
				server = "Unknown";
				player = "Unknown";
			end
			
			if TitanUtils_GetCurrentIndex(servers, server) == nil then
				if server ~= "TitanCustomProfile" then
					table.insert(servers, server);	
					info = {};
					info.notCheckable = true
					info.text = server;
					info.value = server;
					info.hasArrow = 1;
					UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		end
		-- Custom profiles
		for index, id in pairs(TitanSettings.Players) do
			s, e, ident = string.find(index, TITAN_AT);
			if s ~= nil then
				server = string.sub(index, s+1);
				player = string.sub(index, 1, s-1);
			else
				server = "Unknown";
				player = "Unknown";
			end
			
			if TitanUtils_GetCurrentIndex(servers, server) == nil then
				if server == "TitanCustomProfile" then
					if setonce and setonce == 0 then
						TitanPanelRightClickMenu_AddTitle("", UIDROPDOWNMENU_MENU_LEVEL);
						TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_PROFILE_CUSTOM"], UIDROPDOWNMENU_MENU_LEVEL);
					setonce = 1;
					end
					info = {};
					info.notCheckable = true
					info.text = player;
					info.value = player;
					info.hasArrow = 1;
					UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		end
	end
end

local function TitanPanel_PlayerSettingsMenu()
	-- there are 2 level 3 menus possible
	-- 1) Under profiles, then value could be the server of a saved toon
	-- 2) Under plugins value could be the options of a plugin
	--
	local info = {};
	local player = nil;
	local server = nil;
	local s, e, ident;
	local plugin;
	local setonce = 0;

	-- 
	-- Handle the profiles
	--
	for index, id in pairs(TitanSettings.Players) do
		s, e, ident = string.find(index, TITAN_AT);
		if s ~= nil then
			server = string.sub(index, s+1);
			player = string.sub(index, 1, s-1);
		else
			server = "Unknown";
			player = "Unknown";
		end
		
		-- handle custom profiles here
		if server == "TitanCustomProfile" 
		and player == UIDROPDOWNMENU_MENU_VALUE then
			info = {};
			info.notCheckable = true
			info.text = L["TITAN_PANEL_MENU_LOAD_SETTINGS"];
			info.value = index;
			info.func = function() TitanVariables_UseSettings(index)
			TitanPanelSettings.Buttons = newButtons;
			TitanPanelSettings.Location = newLocations;
			end
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			
			info = {};
			info.notCheckable = true
			info.text = L["TITAN_PANEL_MENU_DELETE_SETTINGS"];
			info.value = index;
			info.func = function()			  
				if TitanSettings.Players[info.value] then
					TitanSettings.Players[info.value] = nil;
					local tempstring = string.find (index, TITAN_AT);
					local profname =  string.sub(index, 1, tempstring-1);
					DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
						..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]
						..": "..L["TITAN_PANEL_MENU_PROFILE"]
						.."|cffff8c00"..profname.."|r"
						..L["TITAN_PANEL_MENU_PROFILE_DELETED"]);
					TitanPanelRightClickMenu_Close();
				end
			end
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		
		-- handle regular profiles here
		if server == UIDROPDOWNMENU_MENU_VALUE then
			-- Set the label once
			if setonce and setonce == 0 then
				TitanPanelRightClickMenu_AddTitle(L["TITAN_PANEL_MENU_PROFILE_CHARS"], UIDROPDOWNMENU_MENU_LEVEL);
				setonce = 1;
			end
			info = {};
			info.notCheckable = true
			info.text = player;
			info.value = index;
			info.hasArrow = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end		
	end
	
	-- 
	-- Handle the plugins
	--
	for index, id in pairs(TitanPluginsIndex) do
		plugin = TitanUtils_GetPlugin(id);
		if plugin.id and plugin.id == UIDROPDOWNMENU_MENU_VALUE then
			--title
			info = {};
			info.text = TitanPlugins[plugin.id].menuText;
			info.notCheckable = true
			info.notClickable = 1;
			info.isTitle = 1;
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			--ShowIcon
			if plugin.controlVariables.ShowIcon then
				info = {};
				info.text = L["TITAN_PANEL_MENU_SHOW_ICON"];
				info.value = {id, "ShowIcon", nil};
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar({id, "ShowIcon", nil})
				end
				info.keepShownOnClick = 1;
				info.checked = TitanGetVar(id, "ShowIcon");
				info.disabled = nil;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
			
			--ShowLabel
			if plugin.controlVariables.ShowLabelText then
				info = {};
				info.text = L["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"];
				info.value = {id, "ShowLabelText", nil};
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar({id, "ShowLabelText", nil})
				end
				info.keepShownOnClick = 1;
				info.checked = TitanGetVar(id, "ShowLabelText");
				info.disabled = nil;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
			
			--ShowRegularText (LDB data sources only atm)
			if plugin.controlVariables.ShowRegularText then
				info = {};
				info.text = L["TITAN_PANEL_MENU_SHOW_PLUGIN_TEXT"]
				info.value = {id, "ShowRegularText", nil};
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar({id, "ShowRegularText", nil})
				end
				info.keepShownOnClick = 1;
				info.checked = TitanGetVar(id, "ShowRegularText");
				info.disabled = nil;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
			
			--ShowColoredText
			if plugin.controlVariables.ShowColoredText then
				info = {};
				info.text = L["TITAN_PANEL_MENU_SHOW_COLORED_TEXT"];
				info.value = {id, "ShowColoredText", nil};
				info.func = function()
					TitanPanelRightClickMenu_ToggleVar({id, "ShowColoredText", nil})
				end
				info.keepShownOnClick = 1;
				info.checked = TitanGetVar(id, "ShowColoredText");
				info.disabled = nil;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end

			-- Right-side plugin
			if plugin.controlVariables.DisplayOnRightSide then
				info = {};
				info.text = L["TITAN_PANEL_MENU_LDB_SIDE"];
				info.func = function () 
					TitanToggleVar(id, "DisplayOnRightSide")
					local bar = TitanUtils_GetWhichBar(id)
					TitanPanel_RemoveButton(id);
					TitanUtils_AddButtonOnBar(bar, id);     
				end
				info.checked = TitanGetVar(id, "DisplayOnRightSide");
				info.disabled = nil;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end				
	end	
end

local function TitanPanel_SettingsSelectionMenu()
	local info = {};
	
	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_LOAD_SETTINGS"];
	info.value = UIDROPDOWNMENU_MENU_VALUE;
	info.func = function() 
		TitanVariables_UseSettings(UIDROPDOWNMENU_MENU_VALUE)
		TitanPanelSettings.Buttons = newButtons;
		TitanPanelSettings.Location = newLocations;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	info = {};
	info.notCheckable = true
	info.text = L["TITAN_PANEL_MENU_DELETE_SETTINGS"];
	info.value = UIDROPDOWNMENU_MENU_VALUE;
	info.func = function()
		-- do not delete if current profile
		local playerName = UnitName("player");
		local serverName = GetCVar("realmName");
		local profilevalue = playerName..TITAN_AT..serverName
		if info.value == profilevalue then
			DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
				..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]
				..": "..L["TITAN_PANEL_ERROR_PROF_DELCURRENT"]);
			TitanPanelRightClickMenu_Close();
			return;
		end

		if TitanSettings.Players[info.value] then
			TitanSettings.Players[info.value] = nil;
			DEFAULT_CHAT_FRAME:AddMessage(_G["GREEN_FONT_COLOR_CODE"]
				..L["TITAN_PANEL_MENU_TITLE"].._G["FONT_COLOR_CODE_CLOSE"]
				..": "..L["TITAN_PANEL_MENU_PROFILE"]
				.."|cffff8c00"..info.value.."|r"
				..L["TITAN_PANEL_MENU_PROFILE_DELETED"]);
			TitanPanelRightClickMenu_Close();
		end
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

local function TitanPanel_BuildOtherPluginsMenu(frame)
	local info = {};
	local checked;
	local plugin;

	for index, id in pairs(TitanPluginsIndex) do
		plugin = TitanUtils_GetPlugin(id);
		if not plugin.category then
			plugin.category = "General";
		end
		if ( UIDROPDOWNMENU_MENU_VALUE == "Addons_" .. plugin.category ) then
			if not TitanGetVar(id, "ForceBar") 
				or (TitanGetVar(id, "ForceBar") == TitanBarData[frame].name) then
				info = {};
				if plugin.version ~= nil and TitanPanelGetVar("VersionShown") then
					info.text = plugin.menuText
						..TitanUtils_GetGreenText(" (v"..plugin.version..")")
				else
					info.text = plugin.menuText;
				end
				if plugin.controlVariables then
					info.hasArrow = 1;
				end
				info.value = id;				
				info.func = function() 
						local checked = TitanPanel_IsPluginShown(id) or nil;
						TitanPanelRightClickMenu_BarOnClick(checked, id) 
					end;
				info.checked = TitanPanel_IsPluginShown(id) or nil
				info.keepShownOnClick = 1;
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
			end
		end
	end
end

function TitanPanelRightClickMenu_PrepareBarMenu(self)
	-- Determine which bar was clicked on
	-- This MUST match the convention used in TitanPanel.xml to declare
	-- the dropdown menu. ($parentRightClickMenu)
	local s, e, frame = string.find(self:GetName(), "(.*)RightClickMenu");

	-- Level 2
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		TitanPanel_BuildOtherPluginsMenu(frame);
		TitanPanel_ServerSettingsMenu();
		return;
	end
	
	-- Level 3
	if ( UIDROPDOWNMENU_MENU_LEVEL == 3 ) then
		TitanPanel_PlayerSettingsMenu();
		return;
	end
	
	-- Level 4
	if ( UIDROPDOWNMENU_MENU_LEVEL == 4 ) then
		TitanPanel_SettingsSelectionMenu();
		return;
	end

	-- Level 1
	TitanPanel_MainMenu()
end

function TitanPanel_IsPluginShown(id)
	if ( id and TitanPanelSettings ) then
		return TitanUtils_TableContainsValue(TitanPanelSettings.Buttons, id);
	end
end

function TitanPanel_GetPluginSide(id)
	if ( TitanGetVar(id, "DisplayOnRightSide") ) then
		return TITAN_RIGHT;
	elseif ( TitanPanelButton_IsIcon(id) ) then
		return TITAN_RIGHT;
	else
		return TITAN_LEFT;
	end
end

-- Below are deprecated routines.
-- They will be here for a couple releases then deleted.

--[[

local function TitanPanel_Nextbar(var)
	if TitanPanelGetVar(var) == TITAN_PANEL_BARS_DOUBLE then
		return "Double";
	else
		return "Main";
	end
end

function TitanPanel_AddButton(id)
	TitanUtils_AddButtonOnBar(TITAN_PANEL_SELECTED, id)
end

--]]
