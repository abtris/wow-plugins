local Fontain = _G.Fontain
local pairs = _G.pairs
local optFrame
local fonts = {}
local fonts_and_default = {Default = "Default"}
local disableReload = true
local media = LibStub("LibSharedMedia-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Fontain")

local outlines = {
	[""] = L["None"], 
	["OUTLINE"] = L["Outline"], 
	["THICKOUTLINE"] = L["Thick Outline"], 
	["DEFAULT"] = L["Default"]
}

function Fontain:LibSharedMedia_Registered()
	self:ApplyFonts()
end

local frame_defaults = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	inset = 4,
	edgeSize = 22,
	tile = true,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local exampleFontContainer = CreateFrame("Frame", nil, InterfaceOptionsFrame)
exampleFontContainer:SetBackdrop(frame_defaults)
exampleFontContainer:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
exampleFontContainer:SetPoint("TOPLEFT", InterfaceOptionsFrame, "BOTTOMLEFT")
exampleFontContainer:SetPoint("TOPRIGHT", InterfaceOptionsFrame, "BOTTOMRIGHT")
exampleFontContainer:SetHeight(40)
exampleFontContainer:Hide()

local exampleFont = exampleFontContainer:CreateFontString("FontainExample")
exampleFont:SetPoint("CENTER")

local function enableReload()
	disableReload = false
	Fontain:Print(L["Please reload your UI by typing /console reloadui"])
end

local getFontData, setFontData, execFontData, isDisabled
do
	local db
	function getFontData(info)
		db = db or Fontain.db.profile
		local font = _G[info.arg]
		if font and font:GetObjectType() == "font" then
			exampleFont:SetFontObject(font)
			exampleFont:SetText("Example: " .. info.arg)
			exampleFontContainer:Show()
		end
		if info[#info] == "font" then
			return db.fonts[info.arg] or db.font
		elseif info[#info] == "size" then
			local default = Fontain.fontDefaults[info.arg]
			return db.sizes[info.arg] or (default and default[2]) or 12
		elseif info[#info] == "flags" then
			local default = Fontain.fontDefaults[info.arg]
			return db.flags[info.arg] or (default and default[3]) or ""
		elseif info[#info] == "color" then
		end
	end

	function setFontData(info, v)
		db = db or Fontain.db.profile
		if info[#info] == "font" then
			db.fonts[info.arg] = v
			Fontain:ApplyFonts(info.arg)
			if info.arg == "Nameplates" or info.arg == "StandardText" then
				enableReload()
			end
		elseif info[#info] == "size" then
			db.sizes[info.arg] = v
			Fontain:ApplyFonts(info.arg)
		elseif info[#info] == "flags" then
			db.flags[info.arg] = v
			Fontain:ApplyFonts(info.arg)
		elseif info[#info] == "color" then
		end
	end
	
	function execFontData(info, v)
		if info[#info] == "default" then
			db.fonts[info.arg] = nil
			db.sizes[info.arg] = nil
			db.flags[info.arg] = nil
		end
	end
	
	function isDisabled(info)
		return db.fonts[info.arg] == nil
	end
end

local options = {
	type = "group",
	childGroups = "tab",
	args = {
		enable = {
			type = "toggle",
			name = L["Enable Fontain"],
			get = function()
				return Fontain.db.profile.enabled
			end,
			set = function(info, v)
				Fontain.db.profile.enabled = v
				if v then
					Fontain:Enable()
				else
					Fontain:Disable()
				end				
			end
		},
		override = {
			type = "toggle",
			name = L["Override SharedMedia"],
			desc = L["Override font selection for ALL addons that use SharedMedia. This will force addons to ignore their custom settings and use the chosen font."],
			get = function()
				return Fontain.db.profile.override
			end,
			set = function(info, v)
				Fontain.db.profile.override = v
				if v then
					media:SetGlobal("font", Fontain.db.profile.font)
				else
					media:SetGlobal("font", nil)
				end
				enableReload()
			end
		},
		reset = {
			type = "execute",
			name = L["Reset all"],
			func = function()
				Fontain.db.profile.font = nil
				for k, v in pairs(Fontain.db.profile.fonts) do
					Fontain.db.profile.fonts[k] = nil
				end
				for k, v in pairs(Fontain.db.profile.sizes) do
					Fontain.db.profile.sizes[k] = nil
				end
				for k, v in pairs(Fontain.db.profile.flags) do
					Fontain.db.profile.flags[k] = nil
				end
				Fontain:RevertFonts()
				enableReload()
			end
		},
		reload = {
			type = "execute",
			name = L["Reload UI"],
			func = function()
				ReloadUI()
			end,
			disabled = function() return disableReload end
		},
		masterfont = {
			type = "select",
			name = L["Master Font"],
			dialogControl = 'LSM30_Font',
			values = AceGUIWidgetLSMlists.font,
			get = function()
				return Fontain.db.profile.font
			end,
			set = function(info, v)
				Fontain.db.profile.font = v
				Fontain:ApplyFonts()
			end
		},
		fonts = {
			type = "group",
			-- guiHidden = function() return Fontain.db.profile.showAdvanced end,
			name = L["Single Font Overrides"],
			args = {},
			get = getFontData,
			set = setFontData,
			func = execFontData,
			disabled = function() return Fontain.db.profile.override end
		},
		specialfonts = {
			type = "group",
			name = L["Special fonts"],
			get = getFontData,
			set = setFontData,
			disabled = function() return Fontain.db.profile.override end,
			args = {
				desc = {
					type = "header",
					name = L["Requires a logout/log-in (NOT a UI reload) to take effect"],
					order = 1
				},
				UnitNames = {
					type = "group",
					name = "Unit Names",
					args = {
						font = {
							type = "select",
							name = "Font",
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							arg = "UnitNames"
						}
					}
				},
				Nameplates = {
					type = "group",
					name = L["Nameplates"],
					args = {
						font = {
							type = "select",
							name = "Font",
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							arg = "Nameplates"
						}
					}
				},
				DamageText = {
					type = "group",
					name = "Damage Text",
					args = {
						font = {
							type = "select",
							name = "Font",
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							arg = "DamageText"
						}
					}
				},
				StandardText = {
					type = "group",
					name = L["Chat Bubbles"],
					args = {
						font = {
							type = "select",
							name = "Font",
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							arg = "StandardText"
						}
					}
				}
			}
		}
	}
}

local function createGroupsFor(t, name, pre)
	local piece, rest = (" "):split(name, 2)
	local key = pre..piece
	
	if not rest then return t end
	
	t.args[piece] = t.args[piece] or {
		parent = t,
		type = "group",
		name = piece,
		args = {
			header = {
				type = "header",
				name = (L["All fonts matching \"%s\""]):format(key)
			},
			default = {
				type = "execute",
				disabled = isDisabled,
				name = L["Restore defaults"],
				arg = key
			},
			font = {
				type = "select",
				name = L["Font"],
				dialogControl = 'LSM30_Font',
				values = AceGUIWidgetLSMlists.font,
				arg = key
			}	
		}
	}
	if rest and #rest:trim() > 0 then
		return createGroupsFor(t.args[piece], rest, pre .. piece)
	else
		return t.args[piece]
	end
end

local function hasLeaves(tree)
	for k, v in pairs(tree.args) do
		if v.type == "group" and v.leaf then
			return true
		elseif v.type == "group" then
			if hasLeaves(v) then
				return true
			end
		end
	end
	return false
end

local function cleanupTree(tree)
	local name, entry
	local count, moves = 0, 0
	for k, v in pairs(tree.args) do
		if v.type == "group" then
			if v.leaf then
				name, entry = k, v
				count = count + 1
			else
				moves = moves + cleanupTree(v)
				if hasLeaves(v) then
					count = count + 1
				end
			end
		end
	end
	
	if count == 1 and entry and tree.parent then
		moves = moves + 1
		tree.parent.args[name] = entry
		tree.args[name] = nil
	end
	return moves
end

local function cleanEmptyLeaves(tree)
	local count = 0
	for k, v in pairs(tree.args) do
		if v.leaf then count = count + 1 end
		if v.type == "group" and v.args and not v.leaf then
			local leafCount = cleanEmptyLeaves(v)
			count = count + leafCount
			if leafCount == 0 then
				tree.args[k] = nil
			end
		end
	end
	return count
end

local function cleanCustomParams(tree)
	for k, v in pairs(tree.args) do
		if v.type == "group" then
			cleanCustomParams(v)
		end
		v.parent = nil
		v.leaf = nil
	end
end

function Fontain:BuildFontMenus()
	for k, v in pairs(Fontain.fontList) do
		local rawname = v:GetName()
		local name = rawname:gsub("(%u)", "_%1"):gsub("_", " "):gsub(" +", " "):gsub("(%u) (%u)", "%1%2"):gsub("(%u) (%u)", "%1%2"):trim()
		local leaf = createGroupsFor(options.args.fonts, name, "").args
		leaf[rawname] = leaf[rawname] or {
			type = "group",
			leaf = true,
			name = name,
			args = {
				default = {
					type = "execute",
					name = L["Restore defaults"],
					arg = rawname
				},
				font = {
					type = "select",
					name = L["Font"],
					dialogControl = 'LSM30_Font',
					values = AceGUIWidgetLSMlists.font,
					arg = rawname
				},
				flags = {
					type = "select",
					name = L["Outline"],
					values = outlines,
					arg = rawname
				},
				size = {
					type = "range",
					name = L["Size"],
					min  = 1,
					max  = 30,
					step = 1,
					bigStep = 1,
					arg = rawname
				}
			}
		}
	end
	while cleanupTree(options.args.fonts) > 0 do end
	cleanEmptyLeaves(options.args.fonts)
	cleanCustomParams(options.args.fonts)
	collectgarbage()
end

function Fontain:OpenConfig(input)
	if input == "config" or not InterfaceOptionsFrame:IsResizable() then
		InterfaceOptionsFrame:Hide()
		LibStub("AceConfigDialog-3.0"):SetDefaultSize("Fontain", 500, 550)
		LibStub("AceConfigDialog-3.0"):Open("Fontain")
	else
		InterfaceOptionsFrame_OpenToCategory(optFrame)
	end
end

Fontain.options = options
LibStub("AceConfig-3.0"):RegisterOptionsTable("Fontain", options)
optFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Fontain", "Fontain")
Fontain:RegisterChatCommand("font", "OpenConfig")
Fontain:RegisterChatCommand("fonts", "OpenConfig")
Fontain:RegisterChatCommand("fontain", "OpenConfig")

	