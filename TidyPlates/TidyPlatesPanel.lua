
local copytable = TidyPlatesUtility.copyTable
local mergetable = TidyPlatesUtility.mergeTable
local PanelHelpers = TidyPlatesUtility.PanelHelpers

local currentThemeName = ""
local activespec = "primary"
local useAutohide = false

local function SetAutoHide(option) 
	useAutoHide = option
	if useAutoHide and (not InCombat) then SetCVar("nameplateShowEnemies", 0) end 
end

local function SetSpellCastWatcher(enable)
	if enable then TidyPlates:StartSpellCastWatcher()
	else TidyPlates:StopSpellCastWatcher()	end
end


-------------------------------------------------------------------------------------
--  Default Options
-------------------------------------------------------------------------------------
TidyPlatesOptions = {
	primary = "Neon/Tank",
	secondary = "Neon/DPS",
	autohide = false, 
	EnableCastWatcher = false, 
}
	
local TidyPlatesOptionsDefaults = copytable(TidyPlatesOptions)
local TidyPlatesThemeNames, TidyPlatesThemeIndexes = {}, {}
local warned = {}

-------------------------------------------------------------------------------------
-- Pre-Processor
-------------------------------------------------------------------------------------
local function LoadTheme(incomingtheme) 
	local theme, style, stylename, newvalue, propertyname, oldvalue
	
	-- Sends a notification to all available themes, if possible.
	for themename, themetable in pairs(TidyPlatesThemeList) do
		if themetable.OnActivateTheme then themetable.OnActivateTheme(nil, nil) end
	end
	
	-- Get theme table
	if type(TidyPlatesThemeList) == "table" then 
		if type(incomingtheme) == 'string' then 
			theme = TidyPlatesThemeList[incomingtheme] 
		end
	end
	
	-- Check for valid theme
	if type(theme) == 'table' then 
		if theme.SetStyle and type(theme.SetStyle) == "function" then
			-- Multi-Style Theme
			for stylename, style in pairs(theme) do
				if type(style) == "table" then theme[stylename] = mergetable(TidyPlates.Template, style) end 
			end
		else 	
			-- Single-Style Theme
			for propertyname, oldvalue in pairs(TidyPlates.Template) do
				newvalue = theme[propertyname]
				if type(newvalue) == "table" then theme[propertyname] = mergetable(oldvalue, newvalue)
				else theme[propertyname] = copytable(oldvalue) end 	
			end
		end
		-- Choices: Overwrite incomingtheme as it's processed, or Overwrite after the processing is done
		TidyPlates:ActivateTheme(theme)	
		if theme.OnActivateTheme then theme.OnActivateTheme(theme, incomingtheme) end
		currentThemeName = incomingtheme
		return theme
	else
		TidyPlatesOptions[activespec] = "None"
		currentThemeName = "None"
		TidyPlates:ActivateTheme(TidyPlatesThemeList["None"])
		return nil
	end
		
end

TidyPlates.LoadTheme = LoadTheme
TidyPlates._LoadTheme = LoadTheme

function TidyPlates:ReloadTheme()
	LoadTheme(TidyPlatesOptions[activespec])
	TidyPlates:ForceUpdate()
end
	
-------------------------------------------------------------------------------------
-- Panel
-------------------------------------------------------------------------------------
local ThemeDropdownMenuItems = {}
local ApplyPanelSettings

local title = GetAddOnMetadata("TidyPlates", "title").." v"..GetAddOnMetadata("TidyPlates", "version")
local firstShow = true

local panel = PanelHelpers:CreatePanelFrame( "TidyPlatesInterfaceOptions", "Tidy Plates", title )
local helppanel = PanelHelpers:CreatePanelFrame( "TidyPlatesInterfaceOptionsHelp", "Troubleshooting" )
panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
panel:SetBackdropColor(0.06, 0.06, 0.06, .9)

-- Convert the Theme List into a Menu List
local function UpdateThemeNames()
	local themecount = 1
	if type(TidyPlatesThemeList) == "table" then
		for themename, themepointer in pairs(TidyPlatesThemeList) do
			TidyPlatesThemeNames[themecount] = themename
			TidyPlatesThemeIndexes[themename] = themecount
			themecount = themecount + 1
		end
		-- Theme Choices
		for index, name in pairs(TidyPlatesThemeNames) do ThemeDropdownMenuItems[index] = {text = name, notCheckable = 1 } end
	end

end


local function ConfigureTheme(spec)
	local themename = TidyPlatesOptions[spec]
	if themename then 
		local theme = TidyPlatesThemeList[themename]
		--print("Opening Interface Panel for", themename, theme)
		if theme and theme.ShowConfigPanel and type(theme.ShowConfigPanel) == 'function' then theme.ShowConfigPanel() end
	end
end

-- The usual function:
-- local function ShowConfigPanelDelegate() InterfaceOptionsFrame_OpenToCategory(panel) end
-- theme.ShowConfigPanel = ShowConfigPanelDelegate

local function ThemeHasPanelLink(themename)
	if themename then
		local theme = TidyPlatesThemeList[themename]
		if theme and theme.ShowConfigPanel and type(theme.ShowConfigPanel) == 'function' then return true end
	end
end
		

local function ActivateInterfacePanel()
	---- Note 
	local offset = -28
	panel.label = panel:CreateFontString(nil, 'ARTWORK') --, 'GameFontLarge'
	panel.label:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	panel.label:SetPoint("TOPLEFT", panel, "TOPLEFT", 35, -45)
	panel.label:SetWidth(340)
	panel.label:SetJustifyH("LEFT")
	panel.label:SetText(
		"Please choose a theme for your Primary and Secondary Specializations. "
		.."The appropriate theme will be automatically activated when you switch specs.")
	panel.label:SetTextColor(1,1,1,1)


	----------------------
	-- Primary Spec
	----------------------
	--  Dropdown
	panel.PrimarySpecTheme = PanelHelpers:CreateDropdownFrame("TidyPlatesChooserDropdown", panel, ThemeDropdownMenuItems, 1)
	panel.PrimarySpecTheme:SetPoint("TOPLEFT", 16, -80+offset)
	
	-- [[	Edit Button
	panel.PrimaryEditButton = CreateFrame("Button", "TidyPlatesEditButton", panel)
	panel.PrimaryEditButton:SetPoint("LEFT", panel.PrimarySpecTheme, "RIGHT", 29, 2)
	panel.PrimaryEditButton.Texture = panel.PrimaryEditButton:CreateTexture(nil, "OVERLAY")
	panel.PrimaryEditButton.Texture:SetAllPoints(panel.PrimaryEditButton)
	panel.PrimaryEditButton.Texture:SetTexture( "Interface\\Addons\\TidyPlates\\media\\Wrench")
	panel.PrimaryEditButton:SetHeight(16)
	panel.PrimaryEditButton:SetWidth(16)
	panel.PrimaryEditButton:Enable()
	panel.PrimaryEditButton:EnableMouse()
	panel.PrimaryEditButton:SetScript("OnClick", function() ConfigureTheme("primary") end)
	--]]
	
	-- Label 
	panel.PrimaryLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.PrimaryLabel:SetPoint("BOTTOMLEFT", panel.PrimarySpecTheme,"TOPLEFT", 20, 5)
	panel.PrimaryLabel:SetWidth(170)
	panel.PrimaryLabel:SetJustifyH("LEFT")

	----------------------
	-- Secondary Spec
	----------------------
	-- Dropdown
	panel.SecondarySpecTheme = PanelHelpers:CreateDropdownFrame("TidyPlatesChooserDropdown2", panel, ThemeDropdownMenuItems, 1)
	panel.SecondarySpecTheme:SetPoint("TOPLEFT",panel.PrimarySpecTheme, "TOPRIGHT", 45, 0)

	-- [[	Edit Button
	panel.SecondaryEditButton = CreateFrame("Button", "TidyPlatesEditButton", panel)
	panel.SecondaryEditButton:SetPoint("LEFT", panel.SecondarySpecTheme, "RIGHT", 29, 2)
	panel.SecondaryEditButton.Texture = panel.SecondaryEditButton:CreateTexture(nil, "OVERLAY")
	panel.SecondaryEditButton.Texture:SetAllPoints(panel.SecondaryEditButton)
	panel.SecondaryEditButton.Texture:SetTexture( "Interface\\Addons\\TidyPlates\\media\\Wrench")
	panel.SecondaryEditButton:SetHeight(16)
	panel.SecondaryEditButton:SetWidth(16)
	panel.SecondaryEditButton:Enable()
	panel.SecondaryEditButton:EnableMouse()
	panel.SecondaryEditButton:SetScript("OnClick", function() ConfigureTheme("secondary") end)
	--]]

	-- Label 
	panel.SecondaryLabel = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.SecondaryLabel:SetPoint("BOTTOMLEFT", panel.SecondarySpecTheme,"TOPLEFT", 20, 5)
	panel.SecondaryLabel:SetWidth(170)
	panel.SecondaryLabel:SetJustifyH("LEFT")
	--panel.SecondaryLabel:SetText("Secondary Spec:")

	----------------------
	-- Other Options
	----------------------
	-- Overlap:
	panel.AllowOverlap = PanelHelpers:CreateCheckButton("TidyPlatesOptions_Overlap", panel, "Allow Overlapping Nameplates")
	panel.AllowOverlap:SetPoint("TOPLEFT", panel.PrimarySpecTheme, "TOPLEFT", 16, -55)
	panel.AllowOverlap:SetScript("OnClick", function(self) 	if self:GetChecked() then SetCVar("spreadnameplates", 0) else SetCVar("spreadnameplates", 1) end end)
	--panel.AllowOverlap:SetScript("OnShow", function(self) self:SetChecked( tonumber(GetCVar("spreadnameplates")) == 0) end)	
	
	-- [[ Autohide:
	panel.AutoHide = PanelHelpers:CreateCheckButton("TidyPlatesOptions_Autohide", panel, "Show Enemy Plates When Entering Combat")
	panel.AutoHide:SetPoint("TOPLEFT", panel.AllowOverlap, "TOPLEFT", 0, -35)
	panel.AutoHide:SetScript("OnClick", function(self) SetAutoHide(self:GetChecked()) end)
	
	-- Cast Watcher
	panel.EnableCastWatcher = PanelHelpers:CreateCheckButton("TidyPlatesOptions_EnableCastWatcher", panel, "Show Non-Target Casting Bars (When Possible)")
	panel.EnableCastWatcher:SetPoint("TOPLEFT", panel.AutoHide, "TOPLEFT", 0, -35)
	panel.EnableCastWatcher:SetScript("OnClick", function(self) SetSpellCastWatcher(self:GetChecked()) end)
	
	-- Update Functions
	panel.okay = ApplyPanelSettings
	panel.PrimarySpecTheme.OnValueChanged = ApplyPanelSettings
	panel.SecondarySpecTheme.OnValueChanged = ApplyPanelSettings
	
	panel.refresh = function ()
		panel.PrimarySpecTheme:SetValue(TidyPlatesThemeIndexes[TidyPlatesOptions.primary])
		panel.SecondarySpecTheme:SetValue(TidyPlatesThemeIndexes[TidyPlatesOptions.secondary])
		panel.AutoHide:SetChecked(TidyPlatesOptions.autohide)
		panel.EnableCastWatcher:SetChecked(TidyPlatesOptions.EnableCastWatcher)
		if tonumber(GetCVar("spreadnameplates")) == 0 then panel.AllowOverlap:SetChecked(true) else panel.AllowOverlap:SetChecked(false) end	
		
		panel.PrimaryLabel:SetText("Primary Theme:")
		panel.SecondaryLabel:SetText("Secondary Theme:")
		
		if ThemeHasPanelLink(TidyPlatesOptions["primary"]) then panel.PrimaryEditButton:Show() else panel.PrimaryEditButton:Hide() end
		if ThemeHasPanelLink(TidyPlatesOptions["secondary"]) then panel.SecondaryEditButton:Show() else panel.SecondaryEditButton:Hide() end

		--[[
		spec = GetActiveTalentGroup() -- 1 for primary / 2 for secondary
		-- Would like to name the specs in the labels
		--]]
	end

	InterfaceOptions_AddCategory(panel);
end

TidyPlatesInterfacePanel = panel

helppanel.parent = "Tidy Plates"
helppanel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 2, right = 2, top = 2, bottom = 2 },})
helppanel:SetBackdropColor(0.05, 0.05, 0.05, .7)

local function ActivateHelpPanel()
	--[[ Description 
	helppanel.label = helppanel:CreateFontString(nil, 'ARTWORK') --, 'GameFontLarge'
	helppanel.label:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	helppanel.label:SetPoint("TOPLEFT", helppanel, "TOPLEFT", 35, -40)
	helppanel.label:SetWidth(325)
	helppanel.label:SetJustifyH("LEFT")
	helppanel.label:SetText("First, try these quick fixes:")
	helppanel.label:SetTextColor(1,1,1,1)
	
	--]]
	---- Button: Vkey alias 
	helppanel.vkeylabel = helppanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') --, 'GameFontLarge'
	--helppanel.vkeylabel:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	helppanel.vkeylabel:SetPoint("TOPLEFT", helppanel, "TOPLEFT", 35, -50)
	helppanel.vkeylabel:SetWidth(325)
	helppanel.vkeylabel:SetJustifyH("LEFT")
	helppanel.vkeylabel:SetText("Show Nameplates:|cFFFFFFFF You can also toggle nameplates on-and-off by using:"..
								" '|rV|cFFFFFFFF' for Enemies, '|rShift-V|cFFFFFFFF' for friends, and '|rControl-V|cFFFFFFFF' for both.")
	
	helppanel.vkey = CreateFrame("Button", "TidyPlatesHelpButton1", helppanel, "UIPanelButtonTemplate2")
	helppanel.vkey:SetPoint("TOPLEFT", helppanel.vkeylabel, "BOTTOMLEFT", 0, -8)
	helppanel.vkey:SetText("Show")
	helppanel.vkey:SetWidth(80)
	
	helppanel.vkey:SetScript("OnClick", function() 
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("nameplateShowFriends", 1)
		TidyPlates:ForceUpdate()
	end)
	
	---- Button: Reset and Reload
	helppanel.resetreloadlabel = helppanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') --, 'GameFontLarge'
	--helppanel.resetreloadlabel:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	helppanel.resetreloadlabel:SetPoint("TOPLEFT", helppanel.vkey, "BOTTOMLEFT", 0, -20)
	helppanel.resetreloadlabel:SetWidth(325)
	helppanel.resetreloadlabel:SetJustifyH("LEFT")
	helppanel.resetreloadlabel:SetText("Reset Variables:|cFFFFFFFF This button will reset Tidy Plates variables, and reload the UI.  "..
										"Note: Using this button during combat is NOT a good idea. ")
	--helppanel.resetreloadlabel:SetTextColor(1,1,1,1)
	
	helppanel.resetreload = CreateFrame("Button", "TidyPlatesHelpButton2", helppanel, "UIPanelButtonTemplate2")
	helppanel.resetreload:SetPoint("TOPLEFT", helppanel.resetreloadlabel, "BOTTOMLEFT", 0, -8)
	helppanel.resetreload:SetText("Reset")
	helppanel.resetreload:SetWidth(80)
	
	helppanel.resetreload:SetScript("OnClick", function() 
		TidyPlatesOptions = {}
		TidyPlatesOptions = copytable(TidyPlatesOptionsDefaults)
		LoadTheme(TidyPlatesOptions[activespec])
		ReloadUI()
	end)
	
	---- Note 
	helppanel.notes = helppanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal') --, 'GameFontLarge'
	--helppanel.notes:SetFont("Fonts\\FRIZQT__.TTF", 10, nil)
	helppanel.notes:SetPoint("TOPLEFT", helppanel.resetreload, "BOTTOMLEFT", 0, -45)
	helppanel.notes:SetWidth(325)
	helppanel.notes:SetJustifyH("LEFT")
	helppanel.notes:SetText("If issues persist, visit our page at Wowinterface.com "..
							"to file a bug report or to ask a question.  If you're "..
							"filing a bug, please use the 'Report Bug' button.")
	helppanel.notes:SetTextColor(1,1,1,1)

	InterfaceOptions_AddCategory(helppanel);
end

ApplyPanelSettings = function()
	
	TidyPlatesOptions.primary = TidyPlatesThemeNames[panel.PrimarySpecTheme.Value]
	TidyPlatesOptions.secondary = TidyPlatesThemeNames[panel.SecondarySpecTheme.Value]
	TidyPlatesOptions.EnableCastWatcher = panel.EnableCastWatcher:GetChecked()
	TidyPlatesOptions.autohide = panel.AutoHide:GetChecked()

	if currentThemeName ~= TidyPlatesOptions[activespec] then 
		LoadTheme(TidyPlatesOptions[activespec]) 
	end
	-- Clear Widgets
	TidyPlatesWidgets:ResetWidgets()
	
	-- Update Appearance
	TidyPlates:ForceUpdate()
	
	-- Overlap
	if panel.AllowOverlap:GetChecked() then SetCVar("spreadnameplates", 0)
	else SetCVar("spreadnameplates", 1) end
	
	SetAutoHide(TidyPlatesOptions.autohide) 
	SetSpellCastWatcher(TidyPlatesOptions.EnableCastWatcher)

	-- Spell Casting
	if	TidyPlatesOptions.EnableCastWatcher then TidyPlates:StartSpellCastWatcher()
	else TidyPlates:StopSpellCastWatcher()	end

	-- Editing Link
	if ThemeHasPanelLink(TidyPlatesOptions["primary"]) then panel.PrimaryEditButton:Show() else panel.PrimaryEditButton:Hide() end
	if ThemeHasPanelLink(TidyPlatesOptions["secondary"]) then panel.SecondaryEditButton:Show() else panel.SecondaryEditButton:Hide() end

end

-------------------------------------------------------------------------------------
-- Auto-Loader
-------------------------------------------------------------------------------------
local panelevents = {}

function panelevents:ACTIVE_TALENT_GROUP_CHANGED()
	if GetActiveTalentGroup(false, false) == 2 then activespec = "secondary" 
	else activespec = "primary" end
	LoadTheme(TidyPlatesOptions[activespec])

	TidyPlatesWidgets:ResetWidgets()
	TidyPlates:ForceUpdate()
	
	-- Warn user if no theme is selected
	if currentThemeName == "None" and not warned[activespec] then
		print("|cFFFF6600Tidy Plates: |cFFFF9900No Theme is Selected.")
		print("|cFF77FF00Use |cFFFFFF00/tidyplates|cFF77FF00 to bring up the Theme Selection Window")
		warned[activespec] = true
	end
	
end

function panelevents:PLAYER_ENTERING_WORLD() panelevents:ACTIVE_TALENT_GROUP_CHANGED() end

function panelevents:PLAYER_REGEN_ENABLED() if useAutoHide then SetCVar("nameplateShowEnemies", 0) end end

function panelevents:PLAYER_REGEN_DISABLED() if useAutoHide then SetCVar("nameplateShowEnemies", 1) end end	

function panelevents:PLAYER_LOGIN()
	-- AutoHide
	SetAutoHide(TidyPlatesOptions.autohide)
	SetSpellCastWatcher(TidyPlatesOptions.EnableCastWatcher)
	UpdateThemeNames()
	ActivateInterfacePanel()
	--ActivateHelpPanel()
	LoadTheme("None")
	--panelevents:ACTIVE_TALENT_GROUP_CHANGED()
	--SetCVar("bloattest", 1)			-- Possibly fixes problems
	SetCVar("threatWarning", 3)		-- Required for threat/aggro detection
end

panel:SetScript("OnEvent", function(self, event, ...) panelevents[event]() end)
for eventname in pairs(panelevents) do panel:RegisterEvent(eventname) end

-------------------------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------------------------
TidyPlatesSlashCommands = {}
TidyPlatesSlashCommands.reset = function() print("Tidy Plates: Variables have been reset"); TidyPlatesOptions = copytable(TidyPlatesOptionsDefaults); LoadTheme(TidyPlatesOptions[activespec]) end

function slash_TidyPlates(arg)
	if type(TidyPlatesSlashCommands[arg]) == 'function' then 
		TidyPlatesSlashCommands[arg]() 
		TidyPlates:ForceUpdate()
	else InterfaceOptionsFrame_OpenToCategory(panel) end
end

SLASH_TIDYPLATES1 = '/tidyplates'
SlashCmdList['TIDYPLATES'] = slash_TidyPlates;

