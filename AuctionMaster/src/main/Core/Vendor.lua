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
	The entry point of the addon.
--]]
vendor.Vendor = LibStub("AceAddon-3.0"):NewAddon("AuctionMaster", "AceConsole-3.0")
local L = vendor.Locale.GetInstance()
vendor.Vendor.AceConfigDialog = LibStub("AceConfigDialog-3.0")
vendor.Vendor.AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local self = vendor.Vendor;
local log = vendor.Debug:new("Vendor")

local function _CleanupDb(self)
	VendorDb.namespaces.SellPrizes = nil
	VendorDb.namespaces.Scanner = nil
end

--[[
	"Reset" popup
--]]
StaticPopupDialogs["VENDOR_RESET_DIALOG"] = {
	text = L["Do you really want to reset the AuctionMaster database? All data gathered will be lost!"],
	button1 = L["Yes"],
  	button2 = L["No"],
  	OnAccept = function()
		vendor.Vendor.db:ResetDB("Default")
		ReloadUI()
  	end,
  	timeout = 0,
  	whileDead = 1,
  	hideOnEscape = 1
};

--[[
	Applies the current settings.
--]]
local function _ApplySettings(self)
	if (self.db.profile.dev) then
		self.options.args.debug.guiHidden = nil
		self.options.args.debug.cmdHidden = nil
	else
		self.options.args.debug.guiHidden = true
		self.options.args.debug.cmdHidden = true
	end
end

--[[
	Sets the given new value for the specified field.
--]]
local function _SetValue(info, value)
	self.db.profile[info.arg] = value
	_ApplySettings(self)
end

--[[
	Returns the given value from the profile.
--]]
local function _GetValue(info)
	return self.db.profile[info.arg]
end

--[[
	Taken from http://lua-users.org/wiki/CopyTable
--]]
local function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--[[
	All options of the addon.
--]]
local function _CreateOptions(self)
	self.options = {
		name = L["AuctionMaster"], 
        type = "group",
        args = {
        	desc = {
        		type = "description",
        		order = 1,
        		name = L["auctionmaster_conf_help"].."\n\n",
        	},
        	helpDesc = {
        		type = "description",
        		order = 10,
        		name = L["Opens the documentation for AuctionsMaster."],
        	},
        	help = {
        		type = "execute",
        		name = L["Help"],
        		order = 20,
        		func = function()
        			vendor.Help:Show(vendor.Help.DOCUMENTATION)
        		end
        	},
        	releaseNotesDesc = {
        		type = "description",
        		order = 25,
        		name = L["Shows the release notes for AuctionsMaster."],
        	},
        	releaseNotes = {
        		type = "execute",
        		name = L["Release notes"],
        		order = 30,
        		func = function()
        			vendor.Help:Show(vendor.Help.RELEASES_4X)
        		end
        	},
        	resetDesc = {
        		type = "description",
        		order = 40,
        		name = L["Resets the complete database of AuctionMaster. This will set everything to it's default values. The GUI will be restarted for refreshing all modules of AuctionMaster."],
        	},
        	reset = {
        		type = "execute",
        		name = L["Reset database"],
        		order = 50,
        		func = function() StaticPopup_Show("VENDOR_RESET_DIALOG") end
        	},
--        	moneyIcons = {
--        		type = "toggle",
--        		name = L["Money icons"],
--        		desc = L["Selects whether money icons should be shown in tooltips and tables or a textual money representation."],
--        		get = _GetValue,
--        		set = _SetValue,
--        		arg = "moneyIcons",
--        		order = 55,
--        	},
    		conf = {
    			type = "execute",
    			name = L["Configuration"],
    			desc = L["Opens a configuration window."],
    			guiHidden = true,
    			func = function()
    				vendor.Vendor:OpenConfig()
    			end
    		},
    		dev = {
    			type = "toggle",
    			name = "Devmode",
    			desc = "Activates the developer mode",
    			guiHidden = true,
    			get = _GetValue,
    			set = _SetValue,
    			arg = "dev",
    		},
			debug = vendor.Debug.GetOptions(),
        }
	}
	-- copy the options to be able to have a clean gui in blizzards options
	self.options2 = deepcopy(self.options)
	
	-- register options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AuctionMaster", self.options2, {"am", "auctionmaster"})
	self.AceConfigRegistry:RegisterOptionsTable("AuctionMaster Blizz", self.options)
	self.AceConfigDialog:AddToBlizOptions("AuctionMaster Blizz", "AuctionMaster")
end

--[[
	Initializes the addon.
--]]
function vendor.Vendor:OnInitialize()
	log:Debug("OnInitialize")
	self.debug = vendor.Debug:new("AuctionMaster")
	-- initialize old ace2 database for migration
	self.oldDb = vendor.AceDb20:new()
	self.oldDb:RegisterDB("VendorDb")
	-- now the ace3 database
 	self.db = LibStub("AceDB-3.0"):New("VendorDb", {
 		profile = {
			useTooltips = true,
--			moneyIcons = true,
		},
		global = {
    		locale = "unknown",
    		checksum = "",
    		hasChargesPattern = false,
		}
	}, "Default")
	self.version = GetAddOnMetadata("AuctionMaster", "Version")
	_CreateOptions(self);
	log:Debug("OnInitialize exit")
end

--[[
	Enables the addon.
--]]
function vendor.Vendor:OnEnable()
	-- init Blizzard_AuctionUi
	vendor.Vendor:Debug("load auction house")
	vendor.AuctionHouse.EnsureAuctionHouseUI()
	_ApplySettings(self)
	-- remember the locale used
	self.db.global.locale = GetLocale()
	self.playerName = UnitName("player")
end

--[[
	Displays the given error message
--]]
function vendor.Vendor:Error(msg)
	self:Print(msg)
end

--[[
	Logs the given debug message.
--]]
function vendor.Vendor:Debug(...)
	self.debug:Debug(...)
end

function vendor.Vendor:Test()
	vendor.Vendor:Debug("Test enter")
	vendor.Vendor:Debug("Test exit")
end

--[[
	Returns an ordered table.
--]]
function vendor.Vendor:OrderTable(tbl)
	local cmds = {}
	for k,v in pairs(tbl) do
		table.insert(cmds, v)
	end
	table.sort(cmds, function(a, b) return a.order < b.order end)
	return cmds
end

--[[
	Opens the display of the configuration frame.
--]]
function vendor.Vendor:OpenConfig()
--    InterfaceOptionsList_DisplayFrame(self.configFrame)
	if (InterfaceOptionsFrame_OpenToFrame) then
		InterfaceOptionsFrame_OpenToFrame("AuctionMaster")
 	elseif (InterfaceOptionsFrame_OpenToCategory) then
	    InterfaceOptionsFrame_OpenToCategory("AuctionMaster")
--   		local buttons = InterfaceOptionsFrameCategories.buttons
--		for i, button in next, buttons do
--			if (button.element and button.element.name) then
--				log:Debug("button name: %s", button.element.name)
--			end
--			if ( button.element == frame ) then
--				button:Click();
--			elseif ( frame.parent and button.element and (button.element.name == frame.parent and button.element.collapsed) ) then
--				button.toggle:Click();
--			end
--		end
    end
--    self.AceConfigDialog:SelectGroup("AuctionMaster", "AuctionMaster AuctionHouse")
--	if (self.AceConfigDialog.OpenFrames["AuctionMaster"]) then
--		self.AceConfigDialog:Close("AuctionMaster")
--	else
--		self.AceConfigDialog:Open("AuctionMaster")
--	end
end