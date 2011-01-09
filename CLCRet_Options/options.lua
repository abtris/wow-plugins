local _, trueclass = UnitClass("player")
if trueclass ~= "PALADIN" then return end

local function bprint(...)
	local t = {}
	for i = 1, select("#", ...) do
		t[i] = tostring(select(i, ...))
	end
	DEFAULT_CHAT_FRAME:AddMessage("CLCRet.options: " .. table.concat(t, " "))
end

clcret.optionsLoaded = true

local MAX_AURAS = 20
local MAX_SOVBARS = 5
local MAX_PRESETS = 10

local function GetSpellChoice()
	local spellChoice = { none = "None" }
	for alias, data in pairs(clcret.fillers) do
		spellChoice[alias] = data.name
	end
	
	return spellChoice
end


local db = clcret.db.profile
local root

local strataLevels = {
	"BACKGROUND",
	"LOW",
	"MEDIUM",
	"HIGH",
	"DIALOG",
	"FULLSCREEN",
	"FULLSCREEN_DIALOG",
	"TOOLTIP",
}

local anchorPoints = {
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	TOPLEFT = "TOPLEFT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT"
}
local execList = {
	AuraButtonExecNone = "None",
	AuraButtonExecSkillVisibleAlways = "Skill always visible",
	AuraButtonExecSkillVisibleNoCooldown = "Skill visible when available",
	AuraButtonExecSkillVisibleOnCooldown = "Skill visible when not available",
	AuraButtonExecItemVisibleAlways = "OnUse item always visible",
	AuraButtonExecItemVisibleNoCooldown = "OnUse item visible when available",
	AuraButtonExecGenericBuff = "Generic buff",
	AuraButtonExecGenericDebuff = "Generic debuff",
	AuraButtonExecPlayerMissingBuff = "Missing player buff",
	AuraButtonExecICDItem = "ICD Proc",
}
local skillButtonNames = { "Main skill", "Secondary skill" }


-- index lookup for aura buttons
local ilt = {}
for i = 1, MAX_AURAS do
	ilt["aura" .. i] = i
end

-- aura buttons get/set functions
local abgs = {}

function abgs:UpdateAll()
	clcret:UpdateEnabledAuraButtons()
	clcret:UpdateAuraButtonsCooldown()
	clcret:AuraButtonUpdateICD()
	clcret:AuraButtonResetTextures()
end

-- enabled toggle
function abgs:EnabledGet()
	local i = ilt[self[2]]
	
	return db.auras[i].enabled
end
function abgs:EnabledSet(val)
	local i = ilt[self[2]]
	
	clcret.temp = info
	if db.auras[i].data.spell == "" then
		val = false
		bprint("Not a valid spell name/id or buff name!")
	end
	db.auras[i].enabled = val
	if not val then clcret:AuraButtonHide(i) end
	abgs:UpdateAll()
end

-- id/name field
function abgs:SpellGet()
	local i = ilt[self[2]]
	
	-- special case for items since link is used instead of name
	if (db.auras[i].data.exec == "AuraButtonExecItemVisibleAlways") or (db.auras[i].data.exec == "AuraButtonExecItemVisibleNoCooldown") then
		return db.auras[i].data.spell
	elseif db.auras[i].data.exec == "AuraButtonExecICDItem" then
		return GetSpellInfo(db.auras[i].data.spell)
	end
	return db.auras[i].data.spell
end

function abgs:SpellSet(val)
	local i = ilt[self[2]]
	
	-- skill
	if (db.auras[i].data.exec == "AuraButtonExecSkillVisibleAlways") or (db.auras[i].data.exec == "AuraButtonExecSkillVisibleNoCooldown") or (db.auras[i].data.exec == "AuraButtonExecSkillVisibleOnCooldown") then
		local name = GetSpellInfo(val)
		if name then
			db.auras[i].data.spell = name
		else
			db.auras[i].data.spell = ""
			db.auras[i].enabled = false
			clcret:AuraButtonHide(i)
			bprint("Not a valid spell name or id !")
		end
	-- item
	elseif (db.auras[i].data.exec == "AuraButtonExecItemVisibleAlways") or (db.auras[i].data.exec == "AuraButtonExecItemVisibleNoCooldown") then
		local name, link = GetItemInfo(val)
		if name then
			db.auras[i].data.spell = val
		else
			db.auras[i].data.spell = ""
			db.auras[i].enabled = false
			clcret:AuraButtonHide(i)
			bprint("Not a valid item name or id !")
		end
	-- icd stuff
	elseif (db.auras[i].data.exec == "AuraButtonExecICDItem") then
		local tid = tonumber(val)
		local name = GetSpellInfo(tid)
		if name then
			db.auras[i].data.spell = tid
		else
			db.auras[i].data.spell = ""
			db.auras[i].enabled = false
			clcret:AuraButtonHide(i)
			bprint("Not a valid spell id!")
		end
	else
		db.auras[i].data.spell = val
	end
	
	abgs:UpdateAll()
end

-- type select
function abgs:ExecGet()
	local i = ilt[self[2]]
	
	return db.auras[i].data.exec
end

function abgs:ExecSet(val)
	local i = ilt[self[2]]
	local aura = db.auras[i]
	
	-- reset every other setting when this is changed
	aura.enabled = false
	aura.data.spell = ""
	aura.data.unit = ""
	aura.data.byPlayer = false
	clcret:AuraButtonHide(i)
	
	aura.data.exec = val
	
	abgs:UpdateAll()
end

-- target field
function abgs:UnitGet()
	local i = ilt[self[2]]
	
	return db.auras[i].data.unit
end

function abgs:UnitSet(val)
	local i = ilt[self[2]]
	
	db.auras[i].data.unit = val
	abgs:UpdateAll()
end

-- cast by player toggle
function abgs:ByPlayerGet()
	local i = ilt[self[2]]
	
	return db.auras[i].data.byPlayer
end

function abgs:ByPlayerSet(val)
	local i = ilt[self[2]]
	
	db.auras[i].data.byPlayer = val
	abgs:UpdateAll()
end

local options = {
	type = "group",
	name = "CLCRet",
	args = {
		info = {
			type = "group",
			name = "Info",
			args = {
				__i1 = {
					type = "description",
					name = "Commands:\n\n    /clcret\n        * opens the options frame \n    /clcreteq\n        * allows editing the FCFS through command line\n        * usage: /clcreteq shortcut1 shortcut2 shortcut3 ....\n        * shortcuts:\n            how - hammer of wrath\n            cs - crusader strike\n            jol - judgement\n            ds - divine storm\n            cons - consecration\n            exo - exorcism\n            ss - sacred shield\n            dp - divine plea\n            hw - holy wrath\n            sor - shield of righteousness\n    /clcretlp\n        * loads a specified preset for retribution\n        * usage: /clcretlp preset_name"
--[[					
Commands:
\n
\n    /clcret
\n        * opens the options frame" 
\n    /clcreteq
\n        * allows editing the FCFS through command line
\n        * usage: /clcreteq shortcut1 shortcut2 shortcut3 ....
\n        * shortcuts:
\n            how - hammer of wrath
\n            cs - crusader strike
\n            jol - judgement
\n            ds - divine storm
\n            cons - consecration
\n            exo - exorcism
\n            ss - sacred shield
\n            dp - divine plea
\n            hw - holy wrath
\n            sor - shield of righteousness
\n    /clcretlp
\n        * loads a specified preset for retribution
\n        * usage: /clcretlp preset_name
--]]

				},
			},
		},
		global = {
			type = "group",
			name = "Global",
			order = 1,
			args = {
				-- lock frame
				lock = {
					order = 1,
					width = "full",
					type = "toggle",
					name = "Lock Frame",
					get = function(info) return clcret.locked end,
					set = function(info, val)
						clcret:ToggleLock()
					end,
				},
				
				show = {
					order = 10,
					type = "select",
					name = "Show",
					get = function(info) return db.show end,
					set = function(info, val)
						db.show = val
						clcret:UpdateShowMethod()
					end,
					values = { always = "Always", combat = "In Combat", valid = "Valid Target", boss = "Boss" }
				},
				
				__strata = {
					order = 15,
					type = "header",
					name = "",
				},
				____strata = {
					order = 16,
					type = "description",
					name = "|cffff0000WARNING|cffffffff Changing Strata value will automatically reload your UI."
				},
				strata = {
					order = 17,
					type = "select",
					name = "Frame Strata",
					get = function(info) return db.strata end,
					set = function(info, val)
						db.strata = val
						ReloadUI()
					end,
					values = strataLevels,
				},
				
				-- full disable toggle
				__fulldisable = {
					order = 20,
					type = "header",
					name = "",
				},
				fullDisable = {
					order = 21,
					width = "full",
					type = "toggle",
					name = "Addon disabled",
					get = function(info) return db.fullDisable end,
					set = function(info, val) clcret:FullDisableToggle() end,
				},
			},
		},
	
		-- appearance
		appearance = {
			order = 10,
			name = "Appearance",
			type = "group",
			args = {
				myppb = {
					order = 1, type = "group", inline = true, name = "Adjust Holy Power Bar",
					args = {
						adjustHPBar = {
							order = 1, type = "toggle",
							name = "Use own bar",
							get = function(info) return db.adjustHPBar end,
							set = function(info, val) db.adjustHPBar = val clcret:UpdatePPB() end,
						},
						hideBlizPPB = {
							order = 2, type = "toggle", width="double",
							name = "Hide Blizzard",
							get = function(info) return db.hideBlizPPB end,
							set = function(info, val) db.hideBlizPPB = val clcret:UpdatePPB() end,
						},
						ppbX = {
							order = 12, type = "range", min = -2000, max = 2000, step = 1, name = "X",
							get = function(info) return db.ppbX end,
							set = function(info, val) db.ppbX = val clcret:UpdatePPB() end,
						},
						ppbY = {
							order = 13, type = "range", min = -2000, max = 2000, step = 1, name = "Y",
							get = function(info) return db.ppbY end,
							set = function(info, val) db.ppbY = val clcret:UpdatePPB() end,
						},
						ppbScale = {
							order = 14, type = "range", min = 0.1, max = 10, step = 0.1, name = "Scale",
							get = function(info) return db.ppbScale end,
							set = function(info, val) db.ppbScale = val clcret:UpdatePPB() end,
						},
						ppbAlpha = {
							order = 15, type = "range", min = 0, max = 1, step = 0.01, name = "Alpha",
							get = function(info) return db.ppbAlpha end,
							set = function(info, val) db.ppbAlpha = val clcret:UpdatePPB() end,
						},
					},
				},
				__buttonAspect = {
					type = "header",
					name = "Button Aspect",
					order = 2,
				},
				zoomIcons = {
					order = 3,
					type = "toggle",
					name = "Zoomed icons",
					get = function(info) return db.zoomIcons end,
					set = function(info, val)
						db.zoomIcons = val
						clcret:UpdateSkillButtonsLayout()
						clcret:UpdateAuraButtonsLayout()
						clcret:UpdateSovBarsLayout()
					end,
				},
				noBorder = {
					order = 4,
					type = "toggle",
					name = "Hide border",
					get = function(info) return db.noBorder end,
					set = function(info, val)
						db.noBorder = val
						clcret:UpdateSkillButtonsLayout()
						clcret:UpdateAuraButtonsLayout()
						clcret:UpdateSovBarsLayout()
					end,
				},
				borderColor = {
					order = 5,
					type = "color",
					name = "Border color",
					hasAlpha = true,
					get = function(info) return unpack(db.borderColor) end,
					set = function(info, r, g, b, a)
						db.borderColor = {r, g, b, a}
						clcret:UpdateSkillButtonsLayout()
						clcret:UpdateAuraButtonsLayout()
						clcret:UpdateSovBarsLayout()
					end,
				},
				borderType = {
					order = 6,
					type = "select",
					name = "Border type",
					get = function(info) return db.borderType end,
					set = function(info, val)
						db.borderType = val
						clcret:UpdateSkillButtonsLayout()
						clcret:UpdateAuraButtonsLayout()
						clcret:UpdateSovBarsLayout()
					end,
					values = { "Light", "Medium", "Heavy" }
				},
				grayOOM = {
					order = 7,
					type = "toggle",
					name = "Gray when OOM",
					get = function(info) return db.grayOOM end,
					set = function(info, val)
						db.grayOOM = val
						clcret:ResetButtonVertexColor()
					end,
				},
				
				__hudAspect = {
					type = "header",
					name = "HUD Aspect",
					order = 10,
				},
				scale = {
					order = 11,
					type = "range",
					name = "Scale",
					min = 0.01,
					max = 3,
					step = 0.01,
					get = function(info) return db.scale end,
					set = function(info, val)
						db.scale = val
						clcret:UpdateFrameSettings()
					end,
				},
				alpha = {
					order = 12,
					type = "range",
					name = "Alpha",
					min = 0,
					max = 1,
					step = 0.001,
					get = function(info) return db.alpha end,
					set = function(info, val)
						db.alpha = val
						clcret:UpdateFrameSettings()
					end,
				},
				_hudPosition = {
					type = "header",
					name = "HUD Position",
					order = 13,
				},
				x = {
					order = 20,
					type = "range",
					name = "X",
					min = 0,
					max = 5000,
					step = 21,
					get = function(info) return db.x end,
					set = function(info, val)
						db.x = val
						clcret:UpdateFrameSettings()
					end,
				},
				y = {
					order = 22,
					type = "range",
					name = "Y",
					min = 0,
					max = 3000,
					step = 1,
					get = function(info) return db.y end,
					set = function(info, val)
						db.y = val
						clcret:UpdateFrameSettings()
					end,
				},
				align = {
					order = 23,
					type = "execute",
					name = "Center Horizontally",
					func = function()
						clcret:CenterHorizontally()
					end,
				},
				
				__icd = {
					order = 50,
					type = "header",
					name = "ICD Visibility",
				},
				____icd = {
					order = 51,
					type = "description",
					name = "Controls the way ICD Aura Buttons are displayed while the proc is ready or on cooldown.",
				},
				icdReady = {
					order = 52,
					type = "select",
					name = "Ready",
					values = { [1] = "Visible", [2] = "Faded", [3] = "Invisible" },
					get = function(info) return db.icd.visibility.ready end,
					set = function(info, val)
						db.icd.visibility.ready = val
					end,
				},
				icdCooldown = {
					order = 53,
					type = "select",
					name = "On cooldown",
					values = { [1] = "Visible", [2] = "Faded", [3] = "Invisible" },
					get = function(info) return db.icd.visibility.cd end,
					set = function(info, val)
						db.icd.visibility.cd = val
					end,
				}
			},
		},
	
		-- behavior
		behavior = {
			order = 15,
			name = "Behavior",
			type = "group",
			args = {
				__updateRates = {
					order = 1,
					type = "header",
					name = "Updates per Second",
				},
				ups = {
					order = 5,
					type = "range",
					name = "FCFS Detection",
					min = 1,
					max = 100,
					step = 1,
					get = function(info) return db.updatesPerSecond end,
					set = function(info, val)
						db.updatesPerSecond = val
						clcret.scanFrequency = 1 / val
					end,
				},
				upsAuras = {
					order = 6,
					type = "range",
					name = "Aura Detection",
					min = 1,
					max = 100,
					step = 1,
					get = function(info) return db.updatesPerSecondAuras end,
					set = function(info, val)
						db.updatesPerSecondAuras = val
						clcret.scanFrequencyAuras = 1 / val
					end,
				},
			
				__rangePerSkill = {
					order = 15,
					type = "header",
					name = "Range Display",
				},
				____rangePerSkill = {
					order = 16,
					type = "description",
					name = "By default the addon checks if you are in melee range and colors both main and secondary skills if not. This option allows you to display the range of the actual skills displayed.",
				},
				rangePerSkill = {
					order = 17,
					type = "toggle",
					width = "full",
					name = "Check range for each skill",
					get = function(info) return db.rangePerSkill end,
					set = function(info, val) db.rangePerSkill = val end,
				},
				__delayedStart = {
					order = 20,
					type = "header",
					name = "Delayed Start",
				},
				____delayedStart = {
					order = 21,
					type = "description",
					name = "Sometimes the talent checks fail at load. If that happens adjust this slider to a higher value.",
				},
				delayedStart = {
					order = 22,
					type = "range",
					name = "Delay start by (seconds)",
					min = 0,
					max = 30,
					step = 1,
					get = function(info) return db.delayedStart end,
					set = function(info, val) db.delayedStart = val end,
				},
				__csBoost = {
					order = 50,
					type = "header",
					name = "Boost CS",
				},
				____csBoost = {
					order = 51,
					type = "description",
					name = "When you want to make sure fillers do not clip into the next CS.",
				},
				csBoost = {
					order = 52,
					type = "range",
					min = 0,
					max = 1.5,
					step = 0.1,
					name = "Extra delay (in seconds)",
					get = function(info) return db.csBoost end,
					set = function(info, val) db.csBoost = val end,
				},
				__inq = {
					order = 60,
					type = "header",
					name = "Inquisition",
				},
				useInq = {
					order = 61, 
					type = "toggle",
					name = "Enabled",
					get = function(info) return db.useInq end,
					set = function(info, val) db.useInq = val end,
				},
				preInq = {
					order = 62,
					type = "range",
					min = 0,
					max = 15,
					step = 0.1,
					name = "Time before expiration",
					get = function(info) return db.preInq end,
					set = function(info, val) db.preInq = val end,
				},
			},
		},
		
		
		-- fcfs edit
		fcfs = {
			order = 10,
			name = "FCFS",
			type = "group",
			args = {
				ret = {
					order = 1,
					name = "Retribution",
					type = "group",
					args = {},
				},
			},
		},
		
		-- presets
		presets = {
			order = 20,
			name = "Presets",
			type = "group",
			args = {
				____info = {
					order = 1,
					type = "description",
					name = "This is a rudimentary presets module. Works only for retribution. It allows you to save current FCFS to a preset and to load it from there. You can also load the preset with |cffffff00/clcretlp preset name|cffffffff.\n"					
				},
				____presetFrameToggle = {
					order = 10,
					type = "description",
					name = "The Preset Frame shows the name of the active preset. Second option allows you to select the preset from the frame with a popup menu.",
				},
				toggle = {
					order = 11,
					type = "execute",
					name = "Toggle Preset Frame",
					func = function() clcret:PresetFrame_Toggle() end,
				},
				enableMouse = {
					order = 12,
					type = "toggle",
					name = "Select from frame",
					get = function(info) return db.presetFrame.enableMouse end,
					set = function(info, val)
						db.presetFrame.enableMouse = val
						clcret:PresetFrame_UpdateMouse()
					end,
				},
				
				-- preset frame Settings
				presetFrameLayout = {
					order = 50,
					type = "group",
					name = "Frame Layout",
					args = {
						expandDown = {
							order = 20,
							type = "toggle",
							name = "Expand Down",
							get = function(info) return db.presetFrame.expandDown end,
							set = function(info, val)
								db.presetFrame.expandDown = val
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						backdropColor = {
							order = 30,
							type = "color",
							name = "Backdrop Color",
							hasAlpha = true,
							get = function(info) return unpack(db.presetFrame.backdropColor) end,
							set = function(info, r, g, b, a)
								db.presetFrame.backdropColor = {r, g, b, a}
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						backdropBorderColor = {
							order = 31,
							type = "color",
							name = "Backdrop Border Color",
							hasAlpha = true,
							get = function(info) return unpack(db.presetFrame.backdropBorderColor) end,
							set = function(info, r, g, b, a)
								db.presetFrame.backdropBorderColor = {r, g, b, a}
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						fontSize = {
							order = 40,
							type = "range",
							name = "Font Size",
							min = 1,
							max = 50,
							step = 1,
							get = function(info) return db.presetFrame.fontSize end,
							set = function(info, val)
								db.presetFrame.fontSize = val
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						fontColor = {
							order = 41,
							type = "color",
							name = "Font Color",
							hasAlpha = true,
							get = function(info) return unpack(db.presetFrame.fontColor) end,
							set = function(info, r, g, b, a)
								db.presetFrame.fontColor = {r, g, b, a}
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						anchor = {
							order = 50,
							type = "select",
							name = "Anchor",
							get = function(info) return db.presetFrame.point end,
							set = function(info, val)
								db.presetFrame.point = val
								clcret:PresetFrame_UpdateLayout()
							end,
							values = anchorPoints,
						},
						anchorTo = {
							order = 51,
							type = "select",
							name = "Anchor To",
							get = function(info) return db.presetFrame.pointParent end,
							set = function(info, val)
								db.presetFrame.pointParent = val
								clcret:PresetFrame_UpdateLayout()
							end,
							values = anchorPoints,
						},
						x = {
							order = 60,
							type = "range",
							name = "X",
							min = -1000,
							max = 1000,
							step = 1,
							get = function(info) return db.presetFrame.x end,
							set = function(info, val)
								db.presetFrame.x = val
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						y = {
							order = 61,
							type = "range",
							name = "Y",
							min = -1000,
							max = 1000,
							step = 1,
							get = function(info) return db.presetFrame.y end,
							set = function(info, val)
								db.presetFrame.y = val
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						width = {
							order = 70,
							type = "range",
							name = "Width",
							min = 1,
							max = 1000,
							step = 1,
							get = function(info) return db.presetFrame.width end,
							set = function(info, val)
								db.presetFrame.width = val
								clcret:PresetFrame_UpdateLayout()
							end,
						},
						height = {
							order = 71,
							type = "range",
							name = "Height",
							min = 1,
							max = 500,
							step = 1,
							get = function(info) return db.presetFrame.height end,
							set = function(info, val)
								db.presetFrame.height = val
								clcret:PresetFrame_UpdateLayout()
							end,
						},
					},
				},
				
			},
		},
		
					-- aura buttons
		auras = {
			order = 30,
			name = "Aura Buttons",
			type = "group",
			args = {
				____info = {
					order = 1,
					type = "description",
					name = "These are cooldown watchers. You can select a player skill, an item or a buff/debuff (on a valid target) to watch.\nItems and skills only need a valid item/spell id (or name) and the type. Target (the target to scan) and Cast by player (filters or not buffs cast by others) are specific to buffs/debuffs.\nValid targets are the ones that work with /cast [target=name] macros. For example: player, target, focus, raid1, raid1target.\n\nICD Proc:\nYou need to specify a valid proc ID (example: 60229 for Greatness STR proc) Name doesn't work, if the ID is valid it will be replaced by the name after the edit.\nIn the \"Target unit\" field you have to enter the ICD and duration of the proc separated by \":\" (example: for Greatness the value should be 45:15).",
				},
			},
		},
	
		-- layout
		layout = {
			order = 31,
			name = "Layout",
			type = "group",
			args = {},
		},
		
		
		-- sov tracking
		sov = {
			order = 40,
			name = "SoV/SoCorr Tracking",
			type = "group",
			args = {
				____info = {
					order = 1,
					type = "description",
					name = "This module provides bars or icons to watch the cooldown of your Seal of Vengeance/Corruption debuff on different targets.\nIt tracks combat log events so disable it unless you really need it.\nTargets are tracked by their GUID from combat log events.",
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = "Enable",
					get = function(info) return db.sov.enabled end,
					set = function(info, val) clcret:ToggleSovTracking() end,
				},
				updatesPerSecond = {
					order = 3,
					type = "range",
					name = "Updates per second",
					min = 1,
					max = 100,
					step = 1,
					get = function(info) return db.sov.updatesPerSecond end,
					set = function(info, val)
						db.sov.updatesPerSecond = val
						clcret.scanFrequencySov = 1 / val
					end,
				},
				__display = {
					order = 10,
					type = "header",
					name = "Appearance"
				},
				useButtons = {
					order = 11,
					width = "full",
					type = "toggle",
					name = "Icons instead of bars",
					get = function(info) return db.sov.useButtons end,
					set = function(invo, val)
						db.sov.useButtons = val
						clcret:UpdateSovBarsLayout()
					end,
				},
				____alpha = {
					order = 20,
					type = "description",
					name = "You can control if the bar/icon of your current target looks different than the other ones.\nFor bars it uses both alpha and color values while the icons only change their alpha.",
				},
				targetDifference = {
					order = 21,
					width = "full",
					type = "toggle",
					name = "Different color for target",
					get = function(info) return db.sov.targetDifference end,
					set = function(info, val)
						db.sov.targetDifference = val
						clcret:UpdateSovBarsLayout()
					end,
				},
				color = {
					order = 22,
					type = "color",
					name = "Target color/alpha",
					hasAlpha = true,
					get = function(info) return unpack(db.sov.color) end,
					set = function(info, r, g, b, a)
						db.sov.color = {r, g, b, a}
						clcret:UpdateSovBarsLayout()
					end,
				},
				colorNonTarget = {
					order = 23,
					type = "color",
					name = "Non target color/alpha",
					hasAlpha = true,
					get = function(info) return unpack(db.sov.colorNonTarget) end,
					set = function(info, r, g, b, a)
						db.sov.colorNonTarget = {r, g, b, a}
					end,
				},
				__layout = {
					order = 40,
					type = "header",
					name = "Layout",
				},
				showAnchor = {
					order = 50,
					width = "full",
					type = "toggle",
					name = "Show anchor (not movable)",
					get = function(info) return clcret.showSovAnchor end,
					set = function(invo, val) clcret:ToggleSovAnchor() end,
				},
				growth = {
					order = 60,
					type = "select",
					name = "Growth direction",
					get = function(info) return db.sov.growth end,
					set = function(info, val)
						db.sov.growth = val
						clcret:UpdateSovBarsLayout()
					end,
					values = { up = "Up", down = "Down", left = "Left", right = "Right" }
				},
				spacing = {
					order = 70,
					type = "range",
					name = "Spacing",
					min = 0,
					max = 100,
					step = 1,
					get = function(info) return db.sov.spacing end,
					set = function(info, val)
						db.sov.spacing = val
						clcret:UpdateSovBarsLayout()
					end,
				},
				
				anchor = {
					order = 80,
					type = "select",
					name = "Anchor",
					get = function(info) return db.sov.point end,
					set = function(info, val)
						db.sov.point = val
						clcret:UpdateSovBarsLayout()
					end,
					values = anchorPoints,
				},
				anchorTo = {
					order = 81,
					type = "select",
					name = "Anchor To",
					get = function(info) return db.sov.pointParent end,
					set = function(info, val)
						db.sov.pointParent = val
						clcret:UpdateSovBarsLayout()
					end,
					values = anchorPoints,
				},
				x = {
					order = 82,
					type = "range",
					name = "X",
					min = -1000,
					max = 1000,
					step = 1,
					get = function(info) return db.sov.x end,
					set = function(info, val)
						db.sov.x = val
						clcret:UpdateSovBarsLayout()
					end,
				},
				y = {
					order = 83,
					type = "range",
					name = "Y",
					min = -1000,
					max = 1000,
					step = 1,
					get = function(info) return db.sov.y end,
					set = function(info, val)
						db.sov.y = val
						clcret:UpdateSovBarsLayout()
					end,
				},
				width = {
					order = 90,
					type = "range",
					name = "Width",
					min = 1,
					max = 1000,
					step = 1,
					get = function(info) return db.sov.width end,
					set = function(info, val)
						db.sov.width = val
						clcret:UpdateSovBarsLayout()
					end,
				},
				height = {
					order = 91,
					type = "range",
					name = "Height (Size for Icons)",
					min = 1,
					max = 500,
					step = 1,
					get = function(info) return db.sov.height end,
					set = function(info, val)
						db.sov.height = val
						clcret:UpdateSovBarsLayout()
					end,
				},
			},
		},
		
		-- swing timer
		swing = {
			order = 50,
			name = "Swing Timer",
			type = "group",
			args = {
				____info = {
					order = 1,
					type = "description",
					name = "Minimalist swing timer.",
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = "Enable",
					get = function(info) return db.swing.enabled end,
					set = function(info, val) clcret:ToggleSwingTimer() end,
				},
				color = {
					order = 22,
					type = "color",
					name = "Color of the bar",
					hasAlpha = true,
					get = function(info) return unpack(db.swing.color) end,
					set = function(info, r, g, b, a)
						db.swing.color = {r, g, b, a}
						clcret:UpdateSwingBarLayout()
					end,
				},
				
				anchor = {
					order = 80,
					type = "select",
					name = "Anchor",
					get = function(info) return db.swing.point end,
					set = function(info, val)
						db.swing.point = val
						clcret:UpdateSwingBarLayout()
					end,
					values = anchorPoints,
				},
				anchorTo = {
					order = 81,
					type = "select",
					name = "Anchor To",
					get = function(info) return db.swing.pointParent end,
					set = function(info, val)
						db.swing.pointParent = val
						clcret:UpdateSwingBarLayout()
					end,
					values = anchorPoints,
				},
				x = {
					order = 82,
					type = "range",
					name = "X",
					min = -1000,
					max = 1000,
					step = 1,
					get = function(info) return db.swing.x end,
					set = function(info, val)
						db.swing.x = val
						clcret:UpdateSwingBarLayout()
					end,
				},
				y = {
					order = 83,
					type = "range",
					name = "Y",
					min = -1000,
					max = 1000,
					step = 1,
					get = function(info) return db.swing.y end,
					set = function(info, val)
						db.swing.y = val
						clcret:UpdateSwingBarLayout()
					end,
				},
				width = {
					order = 90,
					type = "range",
					name = "Width",
					min = 1,
					max = 1000,
					step = 1,
					get = function(info) return db.swing.width end,
					set = function(info, val)
						db.swing.width = val
						clcret:UpdateSwingBarLayout()
					end,
				},
				height = {
					order = 91,
					type = "range",
					name = "Height (Size for Icons)",
					min = 1,
					max = 500,
					step = 1,
					get = function(info) return db.swing.height end,
					set = function(info, val)
						db.swing.height = val
						clcret:UpdateSwingBarLayout()
					end,
				},
			},
		},
	},
}

-- add the presets
root = options.args.presets.args
for i = 1, MAX_PRESETS do
	root["p" .. i] = {
		order = 50 + i,
		name = "Preset" .. i,
		type = "group",
		args = {
			name = {
				order = 10,
				type = "input",
				name = "Name",
				get = function(info) return db.presets[i].name end,
				set = function(info, val)
					db.presets[i].name = strtrim(val)
				end,
			},
			data = {
				order = 20,
				type = "input",
				name = "Rotation",
				get = function(info) return db.presets[i].data end,
				set = function(info, val)
					db.presets[i].data = strtrim(val)
				end
			},
			load = {
				order = 30,
				width = "half",
				type = "execute",
				name = "Load",
				func = function() clcret:Preset_Load(i) end,
			},
			save = {
				order = 40,
				width = "half",
				type = "execute",
				name = "Save",
				func = function() clcret:Preset_SaveCurrent(i) end,
			},
		},
	}
end


	-- add main buttons to layout
for i = 1, 2 do
	options.args.layout.args["button" .. i] = {
		order = i,
		name = skillButtonNames[i],
		type = "group",
		args = {
			size = {
				order = 1,
				type = "range",
				name = "Size",
				min = 1,
				max = 300,
				step = 1,
				get = function(info) return db.layout["button" .. i].size end,
				set = function(info, val)
					db.layout["button" .. i].size = val
					clcret:UpdateSkillButtonsLayout()
				end,
			},
			alpha = {
				order = 2,
				type = "range",
				name = "Alpha",
				min = 0,
				max = 1,
				step = 0.01,
				get = function(info) return db.layout["button" .. i].alpha end,
				set = function(info, val)
					db.layout["button" .. i].alpha = val
					clcret:UpdateSkillButtonsLayout()
				end,
			},
			anchor = {
				order = 6,
				type = "select",
				name = "Anchor",
				get = function(info) return db.layout["button" .. i].point end,
				set = function(info, val)
					db.layout["button" .. i].point = val
					clcret:UpdateSkillButtonsLayout()
				end,
				values = anchorPoints,
			},
			anchorTo = {
				order = 6,
				type = "select",
				name = "Anchor To",
				get = function(info) return db.layout["button" .. i].pointParent end,
				set = function(info, val)
					db.layout["button" .. i].pointParent = val
					clcret:UpdateSkillButtonsLayout()
				end,
				values = anchorPoints,
			},
			x = {
				order = 10,
				type = "range",
				name = "X",
				min = -1000,
				max = 1000,
				step = 1,
				get = function(info) return db.layout["button" .. i].x end,
				set = function(info, val)
					db.layout["button" .. i].x = val
					clcret:UpdateSkillButtonsLayout()
				end,
			},
			y = {
				order = 11,
				type = "range",
				name = "Y",
				min = -1000,
				max = 1000,
				step = 1,
				get = function(info) return db.layout["button" .. i].y end,
				set = function(info, val)
					db.layout["button" .. i].y = val
					clcret:UpdateSkillButtonsLayout()
				end,
			},
		},
	}
end

-- add the buttons to options
for i = 1, MAX_AURAS do
	-- aura options
	options.args.auras.args["aura" .. i] = {
		order = i + 10,
		type = "group",
		name = "Aura Button " .. i,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = "Enabled",
				get = abgs.EnabledGet,
				set = abgs.EnabledSet,
			},
			spell = {
				order = 5,
				type = "input",
				name = "Spell/item name/id or buff to track",
				get = abgs.SpellGet,
				set = abgs.SpellSet,
			},
			exec = {
				order = 10,
				type = "select",
				name = "Type",
				get = abgs.ExecGet,
				set = abgs.ExecSet,
				values = execList,
			},
			unit = {
				order = 15,
				type = "input",
				name = "Target unit",
				get = abgs.UnitGet,
				set = abgs.UnitSet,
			},
			byPlayer = {
				order = 16,
				type = "toggle",
				name = "Cast by player",
				get = abgs.ByPlayerGet,
				set = abgs.ByPlayerSet,
			}
		},
	}
	
	-- layout
	options.args.layout.args["aura" .. i] = {
		order = 10 + i,
		type = "group",
		name = "Aura Button " .. i,
		args = {
			size = {
				order = 1,
				type = "range",
				name = "Size",
				min = 1,
				max = 300,
				step = 1,
				get = function(info) return db.auras[i].layout.size end,
				set = function(info, val)
					db.auras[i].layout.size = val
					clcret:UpdateAuraButtonLayout(i)
				end,
			},
			anchor = {
				order = 6,
				type = "select",
				name = "Anchor",
				get = function(info) return db.auras[i].layout.point end,
				set = function(info, val)
					db.auras[i].layout.point = val
					clcret:UpdateAuraButtonLayout(i)
				end,
				values = anchorPoints,
			},
			anchorTo = {
				order = 6,
				type = "select",
				name = "Anchor To",
				get = function(info) return db.auras[i].layout.pointParent end,
				set = function(info, val)
					db.auras[i].layout.pointParent = val
					clcret:UpdateAuraButtonLayout(i)
				end,
				values = anchorPoints,
			},
			x = {
				order = 10,
				type = "range",
				name = "X",
				min = -1000,
				max = 1000,
				step = 1,
				get = function(info) return db.auras[i].layout.x end,
				set = function(info, val)
					db.auras[i].layout.x = val
					clcret:UpdateAuraButtonLayout(i)
				end,
			},
			y = {
				order = 11,
				type = "range",
				name = "Y",
				min = -1000,
				max = 1000,
				step = 1,
				get = function(info) return db.auras[i].layout.y end,
				set = function(info, val)
					db.auras[i].layout.y = val
					clcret:UpdateAuraButtonLayout(i)
				end,
			},
		},
	}
end

root = options.args.fcfs.args.ret.args
for i = 1, 10 do
	root["p"..i] = {
		order = i,
		name = "",
		type = "select",
		get = function(info) return db.fcfs[i] end,
		set = function(info, val)
			db.fcfs[i] = val
			clcret:UpdateFCFS()
			clcret:PresetFrame_Update()
		end,
		values = GetSpellChoice,
	}
end

-- the init stuff

-- remove the first one we added
for i = 1, #INTERFACEOPTIONS_ADDONCATEGORIES do
	if 	INTERFACEOPTIONS_ADDONCATEGORIES[i]
	and INTERFACEOPTIONS_ADDONCATEGORIES[i].name
	and INTERFACEOPTIONS_ADDONCATEGORIES[i].name == "CLCRet"
	then
		table.remove(INTERFACEOPTIONS_ADDONCATEGORIES, i)
	end
end

local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable("CLCRet", options)

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfigDialog:AddToBlizOptions("CLCRet", "CLCRet", nil, "info")
AceConfigDialog:AddToBlizOptions("CLCRet", "Global", "CLCRet", "global")
AceConfigDialog:AddToBlizOptions("CLCRet", "Appearance", "CLCRet", "appearance")
AceConfigDialog:AddToBlizOptions("CLCRet", "Behavior", "CLCRet", "behavior")
AceConfigDialog:AddToBlizOptions("CLCRet", "FCFS", "CLCRet", "fcfs")
AceConfigDialog:AddToBlizOptions("CLCRet", "Presets", "CLCRet", "presets")
AceConfigDialog:AddToBlizOptions("CLCRet", "Aura Buttons", "CLCRet", "auras")
AceConfigDialog:AddToBlizOptions("CLCRet", "Layout", "CLCRet", "layout")
AceConfigDialog:AddToBlizOptions("CLCRet", "SoV Tracking", "CLCRet", "sov")
AceConfigDialog:AddToBlizOptions("CLCRet", "Swing Timer", "CLCRet", "swing")

-- profiles
options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(clcret.db)
options.args.profiles.order = 900
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CLCRet", "Profiles", "CLCRet", "profiles")

InterfaceOptionsFrame_OpenToCategory("CLCRet")

