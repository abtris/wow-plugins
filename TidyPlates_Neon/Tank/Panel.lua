local Theme = TidyPlatesThemeList["Neon/Tank"]

--TidyPlatesNeonTankSavedVariables
-- /run for i,v in pairs(TidyPlatesNeonTankSavedVariables) do print(i,v) end

---------------
-- Helpers
---------------
local CopyTable = TidyPlatesUtility.copyTable
local PanelHelpers = TidyPlatesUtility.PanelHelpers

local function SplitToTable( ... )
	local t = {}
	local index, line
	for index = 1, select("#", ...) do
		line = select(index, ...)
		if line ~= "" then t[line] = true end
	end
	return t
end

local function TableToString(t)
	local str = ""
	for i in pairs(t) do
		if str then str = "\n" ..str else str = "" end
		str = (tostring(i))..str
	end
	return str
end

local function GetPanelValues(panel, targetTable, cloneTable)
	local index
	for index in pairs(targetTable) do
		if panel[index] then
			targetTable[index] = panel[index]:GetValue()
			cloneTable[index] = targetTable[index]
		end
	end
end

local function SetPanelValues(panel, sourceTable)
	for index, value in pairs(sourceTable) do
		if panel[index] then
			panel[index]:SetValue(value)
		end
	end
end

local function GetSavedVariables(targetTable, cloneTable)
	local i, v
	for i, v in pairs(targetTable) do 
		if cloneTable[i] ~= nil then
			targetTable[i] = cloneTable[i]
		end
	end
end
--[[
local SharedMediaStub
local function UpdateFont(panel)

	local fontlist = SharedMediaStub:List('font')
	--local font =  SharedMediaStub:Fetch('font', TidyPlatesNeonTankVariables.CustomFont) 
	--theme.name.typeface = font
	
	local font =  SharedMediaStub:Fetch('font', TidyPlatesNeonTankVariables.CustomFont, true) 
	
	if font then theme.name.typeface = font
	else 
		theme.name.typeface = "Interface\\Addons\\TidyPlates\\Media\\LiberationSans-Regular.ttf"
		TidyPlatesNeonTankVariables.CustomFont = "Liberation Sans"
		panel.CustomFont = "Liberation Sans"
	end
	--print(TidyPlatesNeonTankVariables.CustomFont, font)

end

local function UpdateFontSize()

	theme.name.size = TidyPlatesNeonTankVariables.CustomFontSize

end

local SharedMediaFontList = { {text = "Liberation Sans", notCheckable = 1 } }
local FontObjects = {}	
--]]




------------------------------------------------------------------
-- Interface Options Panel
------------------------------------------------------------------

local TextModes = { { text = "None", notCheckable = 1 },
					{ text = "Percent", notCheckable = 1 } ,
					{ text = "Actual", notCheckable = 1 } ,
					{ text = "Defecit", notCheckable = 1 } ,
					{ text = "Total & Percent", notCheckable = 1 } ,
					{ text = "Plus-and-Minus", notCheckable = 1 } ,
					}
		
local RangeModes = { { text = "9 yards"} , 
					{ text = "15 yards" } ,
					{ text = "28 yards" } ,
					{ text = "40 yards" } ,
					}


					
local DebuffModes = { 
					{ text = "Show All", notCheckable = 1 } ,
					{ text = "Filter", notCheckable = 1 } , 
					--{ text = "Show All, Except...", notCheckable = 1 } ,
					}
-------------------
-- Main Panel
-------------------
local function CreateInterfacePanel( panelName, panelTitle, parentTitle) -- TidyPlatesNeonTankVariables, TidyPlatesNeonTankSavedVariables )  
	
	-- Copies the default options
	--for property, value in pairs(DefaultOptions) do TidyPlatesNeonTankVariables[property] = value end
	
	local panel = PanelHelpers:CreatePanelFrame( panelName.."_InterfaceOptionsPanel", panelTitle )
	panel.name = panelTitle
	if parentTitle then panel.parent = parentTitle end
	
	panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
	panel:SetBackdropColor(0.05, 0.05, 0.05, .7)

	-------------------
	-- Apply Button
	-------------------
	panel.ApplyButton = CreateFrame("Button", panelName.."_ApplyButton", panel, "UIPanelButtonTemplate2")
	panel.ApplyButton:SetPoint("BOTTOMRIGHT", panel, -9, 12)
	panel.ApplyButton:SetText("Apply")
	panel.ApplyButton:SetWidth(120)

	-------------------
	-- Scroll Box
	-------------------
	panel.ScrollFrame = CreateFrame("ScrollFrame",panelName.."_Scrollframe", panel, "UIPanelScrollFrameTemplate")
	panel.ScrollFrame:SetPoint("TOPLEFT", 16, -40 )
	panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 48 )
		
	
	local ScrollFrameBorder = CreateFrame("Frame", panelName.."ScrollFrameBorder", panel.ScrollFrame )
	ScrollFrameBorder:SetPoint("TOPLEFT", -4, 5)
	ScrollFrameBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	ScrollFrameBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
												tile = true, tileSize = 16, edgeSize = 16, 
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	ScrollFrameBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	ScrollFrameBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
	
	panel.MainFrame = CreateFrame("Frame")
	panel.MainFrame:SetWidth(412)
	panel.MainFrame:SetHeight(550)
	
	panel.ScrollFrame:SetScrollChild(panel.MainFrame)

	panel.Column1 = CreateFrame("Frame", panelName.."_Column1", panel.MainFrame)
	panel.Column1:SetPoint("TOPLEFT", 12,0)
	panel.Column1:SetPoint("BOTTOMRIGHT", panel.MainFrame, "BOTTOM")

	panel.Column2 = CreateFrame("Frame", panelName.."_Column2", panel.MainFrame)
	panel.Column2:SetPoint("TOPRIGHT", -16, 0)
	panel.Column2:SetPoint("BOTTOMLEFT", panel.MainFrame, "BOTTOM", -16, 0)

	local Column1, Column2 = panel.Column1, panel.Column2


	--[[
	-------------------
	-- Font
	-------------------
	-- Health Bar
	--panel.ShowName = PanelHelpers:CreateCheckButton(panelName.."_ShowName", Column1, "Show Name:")
	--panel.ShowName:SetPoint("LEFT")
	--panel.ShowName:SetPoint("TOP", panel.HealthText, "BOTTOM",0, -4)
	
	panel.CustomFont = PanelHelpers:CreateDropdownFrame(panelName.."_FontDropdown", Column1, SharedMediaFontList, 1, "Nameplate Text:", true)
	panel.CustomFont:ClearAllPoints()
	panel.CustomFont:SetPoint("LEFT", Column1, -20, 0)
	panel.CustomFont:SetPoint("TOP", 32, -32)
	--panel.CustomFont:SetPoint("TOP", panel.HealthText, "BOTTOM", 0, -26)

	panel.CustomFontSize = PanelHelpers:CreateSliderFrame(panelName.."_FontSizeDropdown", Column1, "", 11, 6, 26, 1, "ACTUAL")
	panel.CustomFontSize:SetPoint("LEFT", Column1, 8, 0)
	panel.CustomFontSize:SetPoint("TOP", panel.CustomFont, "BOTTOM", 0, 0)
	--]]
	
	-------------------
	-- Opacity
	-------------------
	-- Non-Targets Opacity Slider
	panel.OpacityNonTarget = PanelHelpers:CreateSliderFrame(panelName.."_OpacityNonTargets", Column1, "Non-Target Opacity:", .5, 0, 1, .1)
	panel.OpacityNonTarget:SetPoint("LEFT")
	panel.OpacityNonTarget:SetPoint("TOP", 32, -32)	-- Standalone
	--panel.OpacityNonTarget:SetPoint("TOP", panel.CustomFontSize, "BOTTOM", 0, -38)	-- Custom Font
	-- Hide Neutral Units Checkbox
	panel.OpacityHideNeutral = PanelHelpers:CreateCheckButton(panelName.."_OpacityHideNeutral", Column1, "Hide Neutral Units")
	panel.OpacityHideNeutral:SetPoint("LEFT")
	panel.OpacityHideNeutral:SetPoint("TOP", panel.OpacityNonTarget, "BOTTOM", 0,-10)
	-- Hide Non-Elites Checkbox
	panel.OpacityHideNonElites = PanelHelpers:CreateCheckButton(panelName.."_OpacityHideNonElites", Column1, "Hide Non-Elites")
	panel.OpacityHideNonElites:SetPoint("LEFT")
	panel.OpacityHideNonElites:SetPoint("TOP", panel.OpacityHideNeutral, "BOTTOM", 0,0)
	
	-------------------
	-- Scale
	-------------------
	-- General Scale
	panel.ScaleGeneral = PanelHelpers:CreateSliderFrame(panelName.."_ScaleGeneral", Column1, "General Scale:", 1, .5, 2, .1)
	panel.ScaleGeneral:SetPoint("LEFT")
	panel.ScaleGeneral:SetPoint("TOP", panel.OpacityHideNonElites, "BOTTOM", 0,-32)
	-- Loose Units Scale
	panel.ScaleLoose = PanelHelpers:CreateSliderFrame(panelName.."_ScaleLoose", Column1, "Loose Mob Scale:", 1.5, 1, 2, .1)
	panel.ScaleLoose:SetPoint("LEFT")
	--panel.ScaleLoose:SetPoint("TOP", panel.ScaleGeneral, "BOTTOM", 0,-40)
	panel.ScaleLoose:SetPoint("TOP", panel.ScaleGeneral, "BOTTOM", 0,-48)
	-- Hide Non-Elites Checkbox
	panel.ScaleIgnoreNonElite = PanelHelpers:CreateCheckButton(panelName.."_ScaleIgnoreNonElite", Column1, "Ignore Non-Elites")
	panel.ScaleIgnoreNonElite:SetPoint("LEFT")
	panel.ScaleIgnoreNonElite:SetPoint("TOP", panel.ScaleLoose, "BOTTOM",0, -12)

-- [[
	-------------------
	-- Aggro
	-------------------
	panel.AggroIndDesc = Column1:CreateFontString(panelName.."AggroIndDesc", 'ARTWORK', 'GameFontNormal')
	panel.AggroIndDesc:SetHeight(15)
	panel.AggroIndDesc:SetWidth(200)
	panel.AggroIndDesc:SetText("Aggro Indicators:")
	panel.AggroIndDesc:SetJustifyH("LEFT")
	panel.AggroIndDesc:SetPoint("LEFT", -5, 0)
	panel.AggroIndDesc:SetPoint("TOP", panel.ScaleIgnoreNonElite, "BOTTOM", 0,-16)
	-- Health Bar
	panel.AggroHealth = PanelHelpers:CreateCheckButton(panelName.."_AggroHealth", Column1, "Health Bar Color")
	panel.AggroHealth:SetPoint("LEFT")
	panel.AggroHealth:SetPoint("TOP", panel.AggroIndDesc, "BOTTOM",0, -4)
	-- Border
	panel.AggroBorder = PanelHelpers:CreateCheckButton(panelName.."_AggroBorder", Column1, "Border Glow")
	panel.AggroBorder:SetPoint("LEFT")
	panel.AggroBorder:SetPoint("TOP", panel.AggroHealth, "BOTTOM",0, 0)
	-- AggroOnOtherTank
	panel.AggroOnOtherTank = PanelHelpers:CreateCheckButton(panelName.."_AggroOtherTank", Column1, "Color Raid Tanks")
	panel.AggroOnOtherTank:SetPoint("LEFT")
	panel.AggroOnOtherTank:SetPoint("TOP", panel.AggroBorder, "BOTTOM",0, 0)
--]]
	-------------------
	-- Aggro Color
	-------------------
	panel.AggroColorDesc = Column1:CreateFontString(panelName.."_WidgetDesc", 'ARTWORK', 'GameFontNormal')
	panel.AggroColorDesc:SetHeight(15)
	panel.AggroColorDesc:SetWidth(200)
	panel.AggroColorDesc:SetText("Aggro Colors:")
	panel.AggroColorDesc:SetJustifyH("LEFT")
	panel.AggroColorDesc:SetPoint("LEFT", -5, 0)
	panel.AggroColorDesc:SetPoint("TOP", panel.AggroOnOtherTank, "BOTTOM", 0,-16)

	-- 
	panel.AggroTankedColor = PanelHelpers:CreateColorBox(panelName.."_AggroTankedColor", Column1, "Tanked By Me", 0, .5, 1, 1)
	panel.AggroTankedColor:SetPoint("LEFT", 24)
	panel.AggroTankedColor:SetPoint("TOP", panel.AggroColorDesc, "BOTTOM", 0,-8)

	-- 
	panel.AggroOtherColor = PanelHelpers:CreateColorBox(panelName.."_AggroOtherColor", Column1, "Tanked By Other", 0, .5, 1, 1)
	panel.AggroOtherColor:SetPoint("LEFT", 24)
	panel.AggroOtherColor:SetPoint("TOP", panel.AggroTankedColor, "BOTTOM", 0,-6)
	
	-- 
	panel.AggroLooseColor = PanelHelpers:CreateColorBox(panelName.."_AggroLooseColor", Column1, "Loose", 0, .5, 1, 1)
	panel.AggroLooseColor:SetPoint("LEFT", 24)
	panel.AggroLooseColor:SetPoint("TOP", panel.AggroOtherColor, "BOTTOM", 0,-6)

	-------------------
	-- Health Text
	-------------------
	panel.HealthText = PanelHelpers:CreateDropdownFrame(panelName.."_HealthText", Column1, TextModes, 1, "Health Text Mode:")
	panel.HealthText:ClearAllPoints()
	panel.HealthText:SetPoint("LEFT", Column1, -20, 0)
	panel.HealthText:SetPoint("TOP", panel.AggroLooseColor, "BOTTOM", 0, -32)
	
	--[[
	-------------------
	-- Font
	-------------------
	-- Health Bar
	--panel.ShowName = PanelHelpers:CreateCheckButton(panelName.."_ShowName", Column1, "Show Name:")
	--panel.ShowName:SetPoint("LEFT")
	--panel.ShowName:SetPoint("TOP", panel.HealthText, "BOTTOM",0, -4)
	
	panel.CustomFont = PanelHelpers:CreateDropdownFrame(panelName.."_FontDropdown", Column1, SharedMediaFontList, 1, "Nameplate Text:", true)
	panel.CustomFont:ClearAllPoints()
	panel.CustomFont:SetPoint("LEFT", Column1, -20, 0)
	panel.CustomFont:SetPoint("TOP", panel.HealthText, "BOTTOM", 0, -26)

	panel.CustomFontSize = PanelHelpers:CreateSliderFrame(panelName.."_FontSizeDropdown", Column1, "", 11, 6, 26, 1, "ACTUAL")
	panel.CustomFontSize:SetPoint("LEFT", Column1, 8, 0)
	panel.CustomFontSize:SetPoint("TOP", panel.CustomFont, "BOTTOM", 0, 0)
	--]]
	
	-------------------
	-- Widgets
	-------------------

	-- Description
	panel.WidgetDesc = Column2:CreateFontString(panelName.."_WidgetDesc", 'ARTWORK', 'GameFontNormal')
	panel.WidgetDesc:SetText("Indicators & Widgets:")
	panel.WidgetDesc:SetJustifyH("LEFT")
	panel.WidgetDesc:SetPoint("LEFT", -5)
	panel.WidgetDesc:SetPoint("TOP", 0, -15)

	-- Level
	panel.LevelText = PanelHelpers:CreateCheckButton(panelName.."_WidgetLevelText", Column2, "Level Text")
	panel.LevelText:SetPoint("LEFT")
	panel.LevelText:SetPoint("TOP", panel.WidgetDesc, "BOTTOM", 0, -10)
	
	-- Class Icon
	panel.WidgetClassIcon = PanelHelpers:CreateCheckButton(panelName.."_WidgetClassIcon", Column2, "Enemy Class Icon")
	panel.WidgetClassIcon:SetPoint("LEFT")
	panel.WidgetClassIcon:SetPoint("TOP", panel.LevelText, "BOTTOM", 0, -4)
	
	-- Selection Box
	panel.WidgetSelect = PanelHelpers:CreateCheckButton(panelName.."_WidgetSelect", Column2, "Selection Box")
	panel.WidgetSelect:SetPoint("LEFT")
	panel.WidgetSelect:SetPoint("TOP", panel.WidgetClassIcon, "BOTTOM", 0, -4)

	-- Tug-o'-Threat
	panel.WidgetTug = PanelHelpers:CreateCheckButton(panelName.."_WidgetTug", Column2, "Tug-o'-Threat")
	panel.WidgetTug:SetPoint("LEFT")
	panel.WidgetTug:SetPoint("TOP", panel.WidgetSelect, "BOTTOM", 0, -4)

	-- Loose Color
	panel.TugWidgetLooseColor = PanelHelpers:CreateColorBox(panelName.."_TugWidgetLooseColor", Column2, "Loose Color", 0, .5, 1, 1)
	panel.TugWidgetLooseColor:ClearAllPoints()
	panel.TugWidgetLooseColor:SetPoint("LEFT", Column2, 24,0)
	panel.TugWidgetLooseColor:SetPoint("TOP", panel.WidgetTug, "BOTTOM", 0, -2)

	-- Aggro'd Color
	panel.TugWidgetAggroColor = PanelHelpers:CreateColorBox(panelName.."_TugWidgetAggroColor", Column2, "Aggro Color", 0, .5, 1, 1)
	panel.TugWidgetAggroColor:ClearAllPoints()
	panel.TugWidgetAggroColor:SetPoint("LEFT", Column2, 24,0)
	panel.TugWidgetAggroColor:SetPoint("TOP", panel.TugWidgetLooseColor, "BOTTOM", 0, -4)

	-- Safe 
	panel.TugWidgetSafeColor = PanelHelpers:CreateColorBox(panelName.."_TugWidgetSafeColor", Column2, "Other Tank Color", 0, .5, 1, 1)
	panel.TugWidgetSafeColor:ClearAllPoints()
	panel.TugWidgetSafeColor:SetPoint("LEFT", Column2, 24,0)
	panel.TugWidgetSafeColor:SetPoint("TOP", panel.TugWidgetAggroColor, "BOTTOM", 0, -4)
	
	-- Threat Wheel
	panel.WidgetWheel = PanelHelpers:CreateCheckButton(panelName.."_WidgetWheel", Column2, "Threat Wheel")
	panel.WidgetWheel:SetPoint("LEFT")
	panel.WidgetWheel:SetPoint("TOP", panel.TugWidgetSafeColor, "BOTTOM", 0, -4)


	-- Combo Points
	panel.WidgetCombo = PanelHelpers:CreateCheckButton(panelName.."_WidgetCombo", Column2, "Combo Points")
	panel.WidgetCombo:SetPoint("LEFT")
	panel.WidgetCombo:SetPoint("TOP", panel.WidgetWheel, "BOTTOM", 0, -8)

	-- Group Range
	panel.WidgetRange = PanelHelpers:CreateCheckButton(panelName.."_WidgetRange", Column2, "Range Watcher")
	panel.WidgetRange:SetPoint("LEFT")
	panel.WidgetRange:SetPoint("TOP", panel.WidgetCombo, "BOTTOM", 0, -4)
								
	-- Range
	panel.RangeMode = PanelHelpers:CreateDropdownFrame(panelName.."_RangeModeDropdown", Column2, RangeModes, 1, "")
	panel.RangeMode:SetPoint("LEFT")
	panel.RangeMode:SetPoint("TOP", panel.WidgetRange, "BOTTOM", 0, 0)

	-- Short Debuffs
	panel.WidgetDebuff = PanelHelpers:CreateCheckButton(panelName.."_WidgetDebuff", Column2, "Debuff Tracker")
	panel.WidgetDebuff:SetPoint("LEFT")
	panel.WidgetDebuff:SetPoint("TOP", panel.RangeMode, "BOTTOM", 0, -4)


	-- [[ -----------------
	-- Debuff Tracker List
								
	panel.WidgetDebuffMode = PanelHelpers:CreateDropdownFrame(panelName.."DebuffModeDropdown", Column2, DebuffModes, 1, "")
	panel.WidgetDebuffMode:SetPoint("LEFT")
	panel.WidgetDebuffMode:SetPoint("TOP", panel.WidgetDebuff, "BOTTOM", 0, 0)

	local DebuffScrollFrame = CreateFrame("ScrollFrame",panelName.."DebuffScrollFrame", Column2, "UIPanelScrollFrameTemplate")
	DebuffScrollFrame:SetPoint("LEFT", 18, 0)
	DebuffScrollFrame:SetPoint("TOP", panel.WidgetDebuffMode, "BOTTOM", 0, -2)
	DebuffScrollFrame:SetHeight(75)
	DebuffScrollFrame:SetWidth(108)

	local DebuffEditBoxBorder = CreateFrame("Frame", panelName.."DebuffEditBoxBorder", DebuffScrollFrame )
	DebuffEditBoxBorder:SetPoint("TOPLEFT", 0, 5)
	DebuffEditBoxBorder:SetPoint("BOTTOMRIGHT", 3, -5)
	DebuffEditBoxBorder:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
												tile = true, tileSize = 16, edgeSize = 16, 
												insets = { left = 4, right = 4, top = 4, bottom = 4 }
												});
	DebuffEditBoxBorder:SetBackdropColor(0.05, 0.05, 0.05, 0)
	DebuffEditBoxBorder:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

	panel.WidgetDebuffList = CreateFrame("EditBox", panelName.."DebuffEditBoxList", DebuffScrollFrame)
	panel.WidgetDebuffList:SetWidth(108)
	panel.WidgetDebuffList:SetFont("Fonts\\FRIZQT__.TTF", 11, "NONE")
	panel.WidgetDebuffList:SetText("Unset")
	panel.WidgetDebuffList:SetAutoFocus(false)
	panel.WidgetDebuffList:SetTextInsets(6, 6, 0, 0)
	panel.WidgetDebuffList:SetMultiLine(true)
	
	function panel.WidgetDebuffList:GetValue() return SplitToTable(strsplit("\n", panel.WidgetDebuffList:GetText() )) end
	function panel.WidgetDebuffList:SetValue(value)  panel.WidgetDebuffList:SetText(TableToString(value)) end
	DebuffScrollFrame:SetScrollChild(panel.WidgetDebuffList)
	
	-- End Panel Layout --

	-----------------
	-- Button Handlers
	-----------------
	panel.okay = function() 
		GetPanelValues(panel, TidyPlatesNeonTankVariables, TidyPlatesNeonTankSavedVariables)
		if Theme.UpdateStyleElements then Theme.UpdateStyleElements() end
		TidyPlates:ForceUpdate()
	end
	panel.refresh = function() SetPanelValues(panel, TidyPlatesNeonTankVariables) end
	panel.ApplyButton:SetScript("OnClick", panel.okay)
	
	-----------------
	-- Panel Event Handler
	-----------------
	panel:SetScript("OnEvent", function(self, event, ...) 
		if event == "PLAYER_LOGIN" then 
		elseif event == "PLAYER_ENTERING_WORLD" then 
			
			GetSavedVariables(TidyPlatesNeonTankVariables, TidyPlatesNeonTankSavedVariables)
			if Theme.UpdateStyleElements then Theme.UpdateStyleElements() end
			--[[
			if LibStub then SharedMediaStub = LibStub("LibSharedMedia-3.0", true) end
			
			if SharedMediaStub then
				SharedMediaStub:Register("font", "Liberation Sans","Interface\\Addons\\TidyPlates\\Media\\LiberationSans-Regular.ttf")
				local fontpath
				for index, name in pairs(SharedMediaStub:List('font')) do
					fontpath = SharedMediaStub:Fetch('font', name)
					FontObjects[name] = CreateFont(name)
					FontObjects[name]:SetFont(fontpath, 15, "NONE")
					SharedMediaFontList[index] = { text = name, fontObject = FontObjects[name], notCheckable = 1 }
					--print(index, name, fontpath, FontObjects[name])
				end
				UpdateFont(TankPanel)
			else
				TidyPlatesNeonTankVariables.CustomFont ="Liberation Sans"
			end
			UpdateFontSize()
			--]]
		
		end
	end)
	panel:RegisterEvent("PLAYER_LOGIN")
	panel:RegisterEvent("PLAYER_ENTERING_WORLD")
	panel:RegisterEvent("VARIABLES_LOADED")
	InterfaceOptions_AddCategory(panel)
	----------------
	-- Return a pointer to the whole thingy
	----------------
	return panel
end

-- Initialize the thing
local TankPanel = CreateInterfacePanel( "TidyPlatesNeonTankOptionsPanel", "Tidy Plates: Neon/Tank", nil) -- TidyPlatesNeonTankVariables, TidyPlatesNeonTankSavedVariables ) 

-- Register the Panel in the Theme
TidyPlatesThemeList["Neon/Tank"].InterfacePanel = TankPanel

-- Slash Command
function slash_NEONTANK(arg) InterfaceOptionsFrame_OpenToCategory(TankPanel); end
SLASH_NEONTANK1 = '/neontank'
SlashCmdList['NEONTANK'] = slash_NEONTANK;