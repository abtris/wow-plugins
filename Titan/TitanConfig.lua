-- Titan AceConfigDialog-3.0 init tables
-- in-line creation of the tables needed by Ace for the Blizzard options

local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
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

local function TitanAdjustPanelScale(scale)
	Titan_AdjustScale()		

	-- Adjust frame positions								
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, true)
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
		iconspacing = { -- right side plugins
			name = L["TITAN_UISCALE_CONTROL_TITLE_ICON"],
			desc = L["TITAN_UISCALE_ICON_SLIDER_DESC"],
			order = 5, type = "range", width = "full",
			min = 0, max = 20, step = 1,
			get = function() return TitanPanelGetVar("IconSpacing") end,
			set = function(_, a)
				TitanPanelSetVar("IconSpacing", a);
				TitanPanel_InitPanelButtons();
			end,
		},
		tooltipfont = {
			name = L["TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPFONT"],
			desc = L["TITAN_UISCALE_TOOLTIP_SLIDER_DESC"],
			order = 10, type = "range", width = "full",
			min = 0.5, max = 1.3, step = 0.01,
			get = function() return TitanPanelGetVar("TooltipFont") end,
			set = function(_, a)
				TitanPanelSetVar("TooltipFont", a);
			end,
		},
		tooltipfontdisable = {
			name = L["TITAN_UISCALE_TOOLTIP_DISABLE_TEXT"],
			desc = L["TITAN_UISCALE_DISABLE_TOOLTIP_DESC"],
			order = 11, type = "toggle", width = "full",
			get = function() return TitanPanelGetVar("DisableTooltipFont") end,
			set = function()
				TitanPanelToggleVar("DisableTooltipFont");
			end,
		},
		fontselection = {
			name = L["TITAN_PANEL_MENU_LSM_FONTS"],
			desc = L["TITAN_PANEL_MENU_LSM_FONTS_DESC"],
			order = 12, type = "select",
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
			order = 13, type = "range",
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
			order = 14, type = "select",
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
								local bar = (TitanGetVar(name, "ForceBar") or TitanUtils_PickBar())
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

-- This routine will handle the requests to update the various config
-- items in Titan
function TitanUpdateConfig()
	TitanUpdateConfigAddons()
	TitanUpdateAddonAttempts()
	TitanUpdateExtras()
	TitanUpdateChars()
end

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

