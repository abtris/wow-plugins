-- This is the main TSM file that holds the majority of the APIs that modules will use.

-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster") -- loads the localization table
TSM.version = GetAddOnMetadata("TradeSkillMaster","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster", "Version") -- current version of the addon

-- stuff for debugging TSM
local TSMDebug = false
function TSM:Debug(...)
	if TSMdebug then
		print(...)
	end
end
local debug = function(...) TSM:Debug(...) end

local FRAME_WIDTH = 780 -- width of the entire frame
local FRAME_HEIGHT = 700 -- height of the entire frame
local TREE_WIDTH = 150 -- the width of the tree part of the options frame

TSMAPI = {}
local lib = TSMAPI
local private = {modules={}, iconInfo={}, icons={}, slashCommands={}, modData={}, delays = {}, tooltips = {}}
local tooltip = LibStub("nTipHelper:1")

local savedDBDefaults = {
	profile = {
		minimapIcon = { -- minimap icon position and visibility
			hide = false,
			minimapPos = 220,
			radius = 80,
		},
		autoOpenSidebar = false,
		infoMessage = 0,
	},
}

-- Called once the player has loaded WOW.
function TSM:OnInitialize()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMasterDB", savedDBDefaults, true)

	-- register the chat commands (slash commands)
	-- whenver '/tsm' or '/tradeskillmaster' is typed by the user, TSM:ChatCommand() will be called
   TSM:RegisterChatCommand("tsm", "ChatCommand")
	TSM:RegisterChatCommand("tradeskillmaster", "ChatCommand")
	
	-- create / register the minimap button
	TSM.LDBIcon = LibStub("LibDataBroker-1.1", true) and LibStub("LibDBIcon-1.0", true)
	local TradeSkillMasterLauncher = LibStub("LibDataBroker-1.1", true):NewDataObject("TradeSkillMaster", {
		type = "launcher",
		icon = "Interface\\Icons\\inv_scroll_05",
		OnClick = function(_, button) -- fires when a user clicks on the minimap icon
				if button == "RightButton" then
					-- does the same thing as typing '/tsm config'
					TSM:ChatCommand("config")
				elseif button == "LeftButton" then
					-- does the same thing as typing '/tsm'
					TSM:ChatCommand("")
				end
			end,
		OnTooltipShow = function(tt) -- tooltip that shows when you hover over the minimap icon
				local cs = "|cffffffcc"
				local ce = "|r"
				tt:AddLine("TradeSkill Master " .. TSM.version)
				tt:AddLine(string.format(L["%sLeft-Click%s to open the main window"], cs, ce))
				tt:AddLine(string.format(L["%sDrag%s to move this button"], cs, ce))
				tt:AddLine(string.format(L["%s/tsm help%s for a list of slash commands"], cs, ce))
			end,
		})
	TSM.LDBIcon:Register("TradeSkillMaster", TradeSkillMasterLauncher, TSM.db.profile.minimapIcon)
	
	-- Create Frame which is the main frame of Scroll Master
	TSM.Frame = AceGUI:Create("TSMMainFrame")
	TSM.Frame:SetLayout("Fill")
	TSM.Frame:SetWidth(FRAME_WIDTH)
	TSM.Frame:SetHeight(FRAME_HEIGHT)
	TSM:DefaultContent()
	
	local oldWidthSet = TSM.Frame.OnWidthSet
	TSM.Frame.OnWidthSet = function(self, width)
			TSM.Frame.localstatus.width = width
			oldWidthSet(self, width)
			TSM:BuildIcons()
		end
	local oldHeightSet = TSM.Frame.OnHeightSet
	TSM.Frame.OnHeightSet = function(self, height)
			TSM.Frame.localstatus.height = height
			oldHeightSet(self, height)
			TSM:BuildIcons()
		end
	
	tooltip:Activate()
	tooltip:AddCallback(function(...) TSM:LoadTooltip(...) end)
end

function TSM:OnEnable()
	lib:CreateTimeDelay("noModules", 3, function()
			if #private.modules == 1 then
				StaticPopupDialogs["TSMModuleWarningPopup"] = {
					text = "|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r\n\nPlease visit http://wow.curse.com/downloads/wow-addons/details/tradeskill-master.aspx and check the project description for links to download modules.",
					button1 = "I'll Go There Now!",
					timeout = 0,
					whileDead = true,
					OnAccept = function() TSM:Print("Just incase you didn't read this the first time:") TSM:Print("|cffffff00Important Note:|r You do not currently have any modules installed / enabled for TradeSkillMaster! |cff77ccffYou must download modules for TradeSkillMaster to have some useful functionality!|r\n\nPlease visit http://wow.curse.com/downloads/wow-addons/details/tradeskill-master.aspx and check the project description for links to download modules.") end,
				}
				StaticPopup_Show("TSMModuleWarningPopup")
			else
				if TSM.db.profile.infoMessage == 0 then
					TSM.db.profile.infoMessage = 1
					StaticPopupDialogs["TSMInfoPopup"] = {
						text = "TradeSkillMaster was designed to be as user friendly as possible. However, should you get lost please read the 'TSM Guidebook' pdf located in your TradeSkillMaster folder in your addons folder.\n\nAlso feel free to pop into the IRC (http://tradeskillmaster.wikispaces.com/IRC) for help.\n\nEnjoy!",
						button1 = "Thanks!",
						timeout = 0,
						whileDead = true,
					}
					StaticPopup_Show("TSMInfoPopup")
				end
			end
		end)
end

function lib:GetNumModules()
	return #private.modules
end

function TSM:LoadTooltip(tipFrame, link)
	local itemID = TSMAPI:GetItemID(link)
	if not itemID then return end
	
	local lines = {}
	for _, v in ipairs(private.tooltips) do
		local moduleLines = v.loadFunc(itemID)
		if type(moduleLines) ~= "table" then moduleLines = {} end
		for _, line in ipairs(moduleLines) do
			tinsert(lines, line)
		end
	end
	
	if #lines > 0 then
		tooltip:SetFrame(tipFrame)
		tooltip:AddLine(" ", nil, true)
		tooltip:SetColor(1,1,0)
		tooltip:AddLine(L["TradeSkillMaster Info:"], nil, true)
		tooltip:SetColor(0.4,0.4,0.9)
		
		for i=1, #lines do
			tooltip:AddLine(lines[i], nil, true)
		end
		
		tooltip:AddLine(" ", nil, true)
	end
end

-- deals with slash commands
function TSM:ChatCommand(oInput)
	local input, extraValue
	local sStart, sEnd = string.find(oInput, "  ")
	if sStart and sEnd then
		input = string.sub(oInput, 1, sStart-1)
		extraValue = string.sub(oInput, sEnd+1)
	else
		local inputs = {strsplit(" ", oInput)}
		input = inputs[1]
		extraValue = inputs[2]
		for i=3, #(inputs) do
			extraValue = extraValue .. " " .. inputs[i]
		end
	end
	if input == "" then	-- '/tsm' opens up the main window to the main 'enchants' page
		TSM.Frame:Show()
		if #(TSM.Frame.children) == 0 then
			for i=1, #(private.icons) do
				if private.icons[i].name==L["Status"] then
					private.icons[i].loadGUI(TSM.Frame)
					local name
					for _, module in pairs(private.modules) do
						if module.name == private.icons[i].moduleName then
							name = module.name
							version = module.version
						end
					end
					TSM.Frame:SetTitle((name or private.icons[i].moduleName) .. " v" .. version)
					break
				end
			end
		end
		TSM:BuildIcons()
		lib:SetStatusText("")
	elseif input == "test" and TSMdebug then -- for development purposes
	
	elseif input == "debug" then -- enter debugging mode - for development purposes
		if TSMdebug then
			TSM:Print("Debugging turned off.")
			TSMdebug = false
		else
			TSM:Print("Debugging mode turned on. Type '/tsm debug' again to cancel.")
			TSMdebug = true
		end
		
	else -- go through our Module-specific commands
		local found=false
		for _,v in ipairs(private.slashCommands) do
			if input == v.cmd then
				found = true
				if v.isLoadFunc then
					if #(TSM.Frame.children) > 0 then
						TSM.Frame:ReleaseChildren()
						TSMAPI:SetStatusText("")
					end
					v.loadFunc(self, TSM.Frame, extraValue)
					TSM.Frame:Show()
				else
					v.loadFunc(self, extraValue)
				end
			end
		end
		if not found then
			TSM:Print(L["Slash Commands:"])
			print("|cffffaa00"..L["/tsm|r - opens the main TSM window."])
			print("|cffffaa00"..L["/tsm help|r - Shows this help listing"])
			print("|cffffaa00"..L["/tsm <command name> help|r - Help for commands specific to this module"])
			
			for _,v in ipairs(private.slashCommands) do
				if input=="help" and v.tier==0 then
					print("|cffffaa00/tsm " .. v.cmd .. "|r - " .. v.desc)
				end
				if input==strsub(v.cmd,0,strfind(v.cmd," ")).." help" and v.tier>0 then -- possibly sort the slashCommands list for this output
					print("|cffffaa00/tsm " .. v.cmd .. "|r - " .. v.desc)
				end
			end
				
		end
    end
end

-- registers a module with TSM
function lib:RegisterModule(moduleName, version, authors, desc)
	if not (moduleName and version and authors and desc) then
		return nil, "invalid args", moduleName, version, authors, desc
	end
	
	tinsert(private.modules, {name=moduleName, version=version, authors=authors, desc=desc})
end

-- registers a new icon to be displayed around the border of the TSM frame
function lib:RegisterIcon(displayName, icon, loadGUI, moduleName, side)
	if not (displayName and icon and loadGUI and moduleName) then
		return nil, "invalid args", displayName, icon, loadGUI, moduleName
	end
	
	if not TSM:CheckModuleName(moduleName) then
		return nil, "No module registered under name: " .. moduleName
	end
	
	if side and not (side == "module" or side == "crafting" or side == "options") then
		return nil, "invalid side", side
	end
	
	tinsert(private.icons, {name=displayName, moduleName=moduleName, icon=icon, loadGUI=loadGUI, side=(string.lower(side or "module"))})
end

-- registers a slash command with TSM
--  cmd : the slash command (after /tsm)
--  loadFunc : the function called when the slash command is executed
--  desc : a brief description of the command for help
--  notLoadFunc : set to true if loadFunc does not use the TSM GUI
function lib:RegisterSlashCommand(cmd, loadFunc, desc, notLoadFunc)
	if not desc then
		desc = "No help provided."
	end
	if not loadFunc then
		return nil, "no function provided"
	end
	if not cmd then
		return nil, "no command provided"
	end
	if cmd=="test" or cmd=="debug" or cmd=="help" or cmd=="" then
		return nil, "reserved command provided"
	end
	local tier = 0
	for w in string.gmatch(cmd, " ") do
		tier=tier+1 -- support for help
	end
	tinsert(private.slashCommands, {cmd=cmd, loadFunc=loadFunc, desc=desc, isLoadFunc=not notLoadFunc, tier=tier})
end

-- API to register an addon to show info in a tooltip
function lib:RegisterTooltip(moduleName, loadFunc)
	if not (moduleName and loadFunc) then
		return nil, "Invalid arguments", moduleName, loadFunc
	elseif not TSM:CheckModuleName(moduleName) then
		return nil, "No module registered under name: " .. moduleName
	end
	tinsert(private.tooltips, {module=moduleName, loadFunc=loadFunc})
end

function lib:UnregisterTooltip(moduleName)
	if not TSM:CheckModuleName(moduleName) then
		return nil, "No module registered under name: " .. moduleName
	end
	
	for i, v in pairs(private.tooltips) do
		if v.module == moduleName then
			tremove(private.tooltips, i)
			return
		end
	end
end

-- API to interface with :SetPoint()
function lib:SetFramePoint(point, relativeFrame, relativePoint, ofsx, ofsy)
	TSM.Frame:ClearAllPoints()
	TSM.Frame:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)
end

-- set the frame size to the specified width and height then re-layout the icons
-- as well as reset the frame to the default point in the center of the screen
function lib:SetFrameSize(width, height)
	TSM.Frame:SetWidth(width)
	TSM.Frame:SetHeight(height)
	TSM.Frame.localstatus.width = width
	TSM.Frame.localstatus.height = height
	TSM:BuildIcons()
	TSM.Frame:ClearAllPoints()
	TSM.Frame:SetPoint("CENTER", UIParent, "CENTER")
end

function lib:SetStatusText(statusText)
	TSM.Frame:SetStatusText(statusText)
end

function lib:CloseFrame()
	TSM.Frame:Hide()
end

function lib:OpenFrame()
	TSM.Frame:Show()
	TSM:BuildIcons()
end

function lib:RegisterData(label, dataFunc)
	label = string.lower(label)
	private.modData[label] = dataFunc
end

function lib:GetData(label, ...)
	label = string.lower(label)
	if private.modData[label] then
		return private.modData[label](self, ...)
	end
	
	return nil, "no data for that label"
end

function lib:GetItemID(itemLink, ignoreGemID)
	if not itemLink or type(itemLink) ~= "string" then return nil, "invalid args" end
	
	local test = select(2, strsplit(":", itemLink))
	if not test then return nil, "invalid link" end
	
	local s, e = string.find(test, "[0-9]+")
	if not (s and e) then return nil, "not an itemLink" end
	
	local itemID = tonumber(string.sub(test, s, e))
	if not itemID then return nil, "invalid number" end
	
	return (not ignoreGemID and TSMAPI:GetNewGem(itemID)) or itemID
end

function lib:SelectIcon(moduleName, iconName)
	if not moduleName then return nil, "no moduleName passed" end
	
	if not TSM:CheckModuleName(moduleName) then
		return nil, "No module registered under name: " .. moduleName
	end
	
	for _, data in pairs(private.icons) do
		if not data.frame then return nil, "not ready yet" end
		if data.moduleName == moduleName and data.name == iconName then
			data.frame:Click()
		end
	end
end

function lib:CreateTimeDelay(label, duration, callback, repeatDelay)
	local durationIsValid = type(duration) == "number"
	local callbackIsValid = type(callback) == "function"
	if not (label and durationIsValid and callbackIsValid) then return nil, "invalid args", label, duration, callback, repeatDelay end

	local frameNum
	for i, frame in pairs(private.delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		local delay = CreateFrame("Frame")
		delay:Hide()
		tinsert(private.delays, delay)
		frameNum = #private.delays
	end
	
	local frame = private.delays[frameNum]
	frame.inUse = true
	frame.repeatDelay = repeatDelay
	frame.label = label
	frame.timeLeft = duration
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			if self.repeatDelay then
				self.timeLeft = self.repeatDelay
			else
				lib:CancelFrame(self)
			end
			callback()
		end
	end)
	frame:Show()
end

function lib:CreateFunctionRepeat(label, callback)
	local callbackIsValid = type(callback) == "function"
	if not (label and callbackIsValid) then return nil, "invalid args", label, callback end

	local frameNum
	for i, frame in pairs(private.delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		local delay = CreateFrame("Frame")
		delay:Hide()
		tinsert(private.delays, delay)
		frameNum = #private.delays
	end
	
	local frame = private.delays[frameNum]
	frame.inUse = true
	frame.repeatDelay = repeatDelay
	frame.label = label
	frame.validate = duration
	frame:SetScript("OnUpdate", function(self)
		callback()
	end)
	frame:Show()
end

function lib:CancelFrame(label)
	local delayFrame
	if type(label) == "table" then
		delayFrame = label
	else
		for i, frame in pairs(private.delays) do
			if frame.label == label then
				delayFrame = frame
			end
		end
	end
	
	if delayFrame then
		delayFrame:Hide()
		delayFrame.label = nil
		delayFrame.inUse = false
		delayFrame.validate = nil
		delayFrame.timeLeft = nil
		delayFrame:SetScript("OnUpdate", nil)
	end
end

function TSM:CheckModuleName(moduleName)
	for _, module in pairs(private.modules) do
		if module.name == moduleName then
			return true
		end
	end
end

function TSM:BuildIcons()
	local numItems = {left=0, right=0, bottom=0}
	local count = {left=0, right=0, bottom=0}
	local width = TSM.Frame.localstatus.width or TSM.Frame.frame.width
	local height = TSM.Frame.localstatus.height or TSM.Frame.frame.height
	local spacing = {}
	
	for _, data in pairs(private.icons) do
		if data.frame then 
			data.frame:Hide()
		end
		if data.side == "crafting" then
			numItems.left = numItems.left + 1
		elseif data.side == "options" then
			numItems.right = numItems.right + 1
		else
			numItems.bottom = numItems.bottom + 1
		end
	end
	
	spacing.left = min((TSM.Frame.craftingIconContainer:GetHeight() - 10) / numItems.left, 200)
	spacing.right = min((TSM.Frame.optionsIconContainer:GetHeight() - 10) / numItems.right, 200)
	spacing.bottom = min((TSM.Frame.moduleIconContainer:GetWidth() - 10) / numItems.bottom, 200)

	for i=1, #(private.icons) do
		local frame = nil
		if private.icons[i].frame then
			frame = private.icons[i].frame
			frame:Show()
		else
			frame = CreateFrame("Button", nil, TSM.Frame.frame)
			frame:SetScript("OnClick", function()
					if #(TSM.Frame.children) > 0 then
						TSM.Frame:ReleaseChildren()
						TSMAPI:SetStatusText("")
					end
					local name
					for _, module in pairs(private.modules) do
						if module.name == private.icons[i].moduleName then
							name = module.name
							version = module.version
						end
					end
					TSM.Frame:SetTitle((name or private.icons[i].moduleName) .. " v" .. version)
					private.icons[i].loadGUI(TSM.Frame)
				end)
			frame:SetScript("OnEnter", function(self)
					if private.icons[i].side == "options" then
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 5, -20)
					elseif private.icons[i].side == "crafting" then
						GameTooltip:SetOwner(self, "ANCHOR_LEFT", -5, -20)
					else
						GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
					end
					GameTooltip:SetText(private.icons[i].name)
					GameTooltip:Show()
				end)
			frame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

			local image = frame:CreateTexture(nil, "BACKGROUND")
			image:SetWidth(40)
			image:SetHeight(40)
			image:SetPoint("TOP")
			frame.image = image

			local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
			highlight:SetAllPoints(image)
			highlight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
			highlight:SetTexCoord(0, 1, 0.23, 0.77)
			highlight:SetBlendMode("ADD")
			frame.highlight = highlight
			
			frame:SetHeight(40)
			frame:SetWidth(40)
			frame.image:SetTexture(private.icons[i].icon)
			frame.image:SetVertexColor(1, 1, 1)
			
			private.icons[i].frame = frame
		end
		
		if private.icons[i].side == "crafting" then
			count.left = count.left + 1
			frame:SetPoint("BOTTOMLEFT", TSM.Frame.craftingIconContainer, "TOPLEFT", 10, -((count.left-1)*spacing.left)-50)
		elseif private.icons[i].side == "options" then
			count.right = count.right + 1
			frame:SetPoint("BOTTOMLEFT", TSM.Frame.optionsIconContainer, "TOPLEFT", 11, -((count.right-1)*spacing.right)-50)
		else
			count.bottom = count.bottom + 1
			frame:SetPoint("BOTTOMLEFT", TSM.Frame.moduleIconContainer, "BOTTOMLEFT", ((count.bottom-1)*spacing.bottom)+10, 7)
		end
	end
	local minHeight = max(max(numItems.left, numItems.right)*50, 200)
	local minWidth = max(numItems.bottom*50, 400)
	TSM.Frame.frame:SetMinResize(minWidth, minHeight)
end

function TSM:DefaultContent()
	local function LoadGUI(parent)
		TSMAPI:SetFrameSize(FRAME_WIDTH, FRAME_HEIGHT)
		local content = AceGUI:Create("TSMScrollFrame")
		content:SetLayout("flow")
		parent:AddChild(content)
		
		local ig = AceGUI:Create("TSMInlineGroup")
		ig:SetFullWidth(true)
		ig:SetTitle(L["Installed Modules"])
		ig:SetLayout("flow")
		content:AddChild(ig)
		
		for i, module in pairs(private.modules) do
			local thisFrame = AceGUI:Create("TSMSimpleGroup")
			thisFrame:SetRelativeWidth(0.49)
			thisFrame:SetLayout("list")
			
			local name = AceGUI:Create("Label")
			name:SetText("|cffffbb00"..L["Module:"].."|r"..module.name)
			name:SetFullWidth(true)
			name:SetFontObject(GameFontNormalLarge)
			
			local version = AceGUI:Create("Label")
			version:SetText("|cffffbb00"..L["Version:"].."|r"..module.version)
			version:SetFullWidth(true)
			version:SetFontObject(GameFontNormal)
			
			local authors = AceGUI:Create("Label")
			authors:SetText("|cffffbb00"..L["Author(s):"].."|r"..module.authors)
			authors:SetFullWidth(true)
			authors:SetFontObject(GameFontNormal)
			
			local desc = AceGUI:Create("Label")
			desc:SetText("|cffffbb00"..L["Description:"].."|r"..module.desc)
			desc:SetFullWidth(true)
			desc:SetFontObject(GameFontNormal)
			
			local spacer = AceGUI:Create("Heading")
			spacer:SetText("")
			spacer:SetFullWidth(true)
			
			thisFrame:AddChild(spacer)
			thisFrame:AddChild(name)
			thisFrame:AddChild(version)
			thisFrame:AddChild(authors)
			thisFrame:AddChild(desc)
			ig:AddChild(thisFrame)
		end
		
		if #private.modules == 1 then
			local warningText = AceGUI:Create("Label")
			warningText:SetText("\n|cffff0000"..L["No modules are currently loaded.  Enable or download some for full functionality!"].."\n\n|r")
			warningText:SetFullWidth(true)
			warningText:SetFontObject(GameFontNormalLarge)
			ig:AddChild(warningText)
			
			local warningText2 = AceGUI:Create("Label")
			warningText2:SetText("\n|cffff0000"..L["Visit http://wow.curse.com/downloads/wow-addons/details/tradeskill-master.aspx for information about the different TradeSkillMaster modules as well as download links."].."|r")
			warningText2:SetFullWidth(true)
			warningText2:SetFontObject(GameFontNormalLarge)
			ig:AddChild(warningText2)
		end
		
		local ig = AceGUI:Create("TSMInlineGroup")
		ig:SetFullWidth(true)
		ig:SetTitle(L["Credits"])
		ig:SetLayout("flow")
		content:AddChild(ig)
		
		local credits = AceGUI:Create("Label")
		credits:SetText(L["TradeSkillMaster Team:"])
		credits:SetRelativeWidth(1)
		credits:SetFontObject(GameFontHighlightLarge)
		ig:AddChild(credits)
		
		local credits = AceGUI:Create("Label")
		credits:SetText("|cffffbb00"..L["Lead Developer and Project Manager:"].."|r Sapu94")
		credits:SetRelativeWidth(1)
		credits:SetFontObject(GameFontNormal)
		ig:AddChild(credits)
		
		local credits = AceGUI:Create("Label")
		credits:SetText("|cffffbb00"..L["Project Organizer / Resident Master Goblin:"].."|r Cente")
		credits:SetRelativeWidth(1)
		credits:SetFontObject(GameFontNormal)
		ig:AddChild(credits)
		
		local credits = AceGUI:Create("Label")
		credits:SetText("|cffffbb00"..L["Contributing Developers:"].."|r Mischanix, Xubera, cduhn")
		credits:SetRelativeWidth(1)
		credits:SetFontObject(GameFontNormal)
		ig:AddChild(credits)
		
		local spacer = AceGUI:Create("Heading")
		spacer:SetText("")
		spacer:SetRelativeWidth(1)
		ig:AddChild(spacer)
		
		local credits = AceGUI:Create("Label")
		credits:SetText(L["Special thanks to our alpha testers:"])
		credits:SetRelativeWidth(1)
		credits:SetFontObject(GameFontHighlightLarge)
		ig:AddChild(credits)
		
		local credits = AceGUI:Create("Label")
		credits:SetText("|cffffbb00"..L["Alpha Testers:"].."|r cduhn, chaley, kip, shamus, tamen, chaley, bonnell, cryan, unnamedzero, "..L["and many others"])
		credits:SetRelativeWidth(1)
		credits:SetFontObject(GameFontNormal)
		ig:AddChild(credits)
		
		local spacer = AceGUI:Create("Heading")
		spacer:SetText("")
		spacer:SetRelativeWidth(1)
		content:AddChild(spacer)
		
		local iconCB = AceGUI:Create("CheckBox")
		iconCB:SetLabel(L["Hide the TradeSkillMaster minimap icon."])
		iconCB:SetValue(TSM.db.profile.minimapIcon.hide)
		iconCB:SetRelativeWidth(1)
		iconCB:SetCallback("OnValueChanged", function(_,_,value)
				TSM.db.profile.minimapIcon.hide = value
				if value then
					TSM.LDBIcon:Hide("TradeSkillMaster")
				else
					TSM.LDBIcon:Show("TradeSkillMaster")
				end
			end)
		content:AddChild(iconCB)
	end
	
	lib:RegisterModule("TradeSkillMaster", TSM.version, GetAddOnMetadata("TradeSkillMaster", "Author"), L["Provides the main central frame as well as APIs for all TSM modules."])
	lib:RegisterIcon(L["Status"], "Interface\\Icons\\Achievement_Quests_Completed_04", LoadGUI, "TradeSkillMaster", "options")
end