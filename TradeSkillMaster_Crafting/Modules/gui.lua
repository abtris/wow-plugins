-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --


-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local GUI = TSM:NewModule("GUI", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local debug = function(...) TSM:Debug(...) end -- for debugging

-- some static variables for easy changing of frame dimmensions
-- these values are what the frame starts out using but the user can resize it from there
local TREE_WIDTH = 150 -- the width of the tree part of the frame
local FRAME_WIDTH = 780 -- width of the entire frame
local FRAME_HEIGHT = 700 -- height of the entire frame

-- color codes
local CYAN = "|cff99ffff"
local BLUE = "|cff5555ff"
local GREEN = "|cff00ff00"
local RED = "|cffff0000"
local WHITE = "|cffffffff"
local GOLD = "|cffffbb00"
local YELLOW = "|cffffd000"

local function getIndex(t, value)
	for i, v in pairs(t) do
		if v == value then
			return i
		end
	end
end

function GUI:OnEnable()
	GUI.queueList = {}
	GUI.offsets = {}
	GUI.currentPage = {}
	TSM.mode = "Enchanting"
	
	-- Popup Confirmation Window used in this module
	StaticPopupDialogs["TSMCrafting.DeleteConfirm"] = {
		text = L["Are you sure you want to delete the selected profile?"],
		button1 = L["Accept"],
		button2 = L["Cancel"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}
	
	local names, textures = {}, {}
	for _, data in pairs(TSM.tradeSkills) do
		local name, _, texture = GetSpellInfo(data.spellID)
		tinsert(names, name)
		tinsert(textures, texture)
	end
	
	for i=1, #(names) do
		TSMAPI:RegisterIcon("Crafting - "..names[i], textures[i], function(...) GUI:LoadGUI(i, ...) end, "TradeSkillMaster_Crafting", "crafting")
	end
	
	TSMAPI:RegisterIcon(L["Crafting Options"], "Interface\\Icons\\Inv_Jewelcrafting_DragonsEye02", function(...) GUI:SelectTree(...) end, "TradeSkillMaster_Crafting", "options")
end

-- setup the main GUI frame / structure
function GUI:LoadGUI(num, parent)
	TSMAPI:SetFrameSize(FRAME_WIDTH, FRAME_HEIGHT)
	local treeGroupStatus = {treewidth = TREE_WIDTH, groups = TSM.db.global.treeStatus}
	TSM.onOptions = false
	
	-- Create the main tree-group that will control and contain the entire GUI
	GUI.TreeGroup = AceGUI:Create("TSMTreeGroup")
	GUI.TreeGroup:SetLayout("Fill")
	GUI.TreeGroup:SetCallback("OnGroupSelected", function(...) GUI:SelectTree(...) end)
	GUI.TreeGroup:SetStatusTable(treeGroupStatus)
	parent:AddChild(GUI.TreeGroup)
	
	local treeStructure = {
			{value = 1, text = L["Crafts"], children = {}},
			{value = 2, text = L["Materials"]},
			{value = 3, text = L["Options"]},
		}
	
	if num <= #(TSM.tradeSkills) then
		TSM.onOptions = false
		TSM.mode = TSM.tradeSkills[num].name
		local slotList = TSM[TSM.mode].slotList
		if TSM.mode == "Inscription" then
			slotList = TSM.Inscription:GetSlotList()
		end
		for i=1, #(slotList) do
			tinsert(treeStructure[1].children, {value = i, text = slotList[i]})
		end
		GUI.TreeGroup:SetTree(treeStructure)
		GUI.TreeGroup:SelectByPath(1)
		
		local lastScan = TSM.db.profile.lastScan[TSM.mode]
		if not lastScan or (time() - lastScan) > 60*60 then
			TSM.Data:ScanProfession(TSM.mode)
		end
	end
end

-- controls what is drawn on the right side of the GUI window
-- this is based on what is selected in the "tree" on the left (ex 'Options'->'Remove Crafts')
function GUI:SelectTree(treeFrame, optionsPage, selection)
	if not selection then
		TSM.onOptions = true
		GUI:DrawOptions(treeFrame)
		return
	end

	-- decodes and seperates the selection string from AceGUIWidget-TreeGroup
	local selectedParent, selectedChild = ("\001"):split(selection)
	selectedParent = tonumber(selectedParent) -- the main group that's selected (Crafts, Materials, Options, etc)
	selectedChild = tonumber(selectedChild) -- the child group that's if there is one (2H Weapon, Boots, Chest, etc)
	
	if treeFrame.children and treeFrame.children[1] and treeFrame.children[1].children and treeFrame.children[1].children[1] and treeFrame.children[1].children[1].localstatus then
		GUI.offsets[GUI.currentPage.parent][GUI.currentPage.child] = treeFrame.children[1].children[1].localstatus.offset
	end
	
	-- prepare the TreeFrame for a new container which will hold everything that is drawn on the right part of the GUI
	treeFrame:ReleaseChildren()
	if not TSM.onOptions then
		GUI:UpdateQueue(true)
		TSM.Data:CalculateCosts()
	end
	GUI.currentPage = {parent=selectedParent, child=(selectedChild or 0)}
	
	-- a simple group to provide a fresh layout to whatever is put inside of it
	-- just acts as an invisible layer between the TreeGroup and whatever is drawn inside of it
	local container = AceGUI:Create("TSMSimpleGroup")
	container:SetLayout("Fill")
	treeFrame:AddChild(container)
	
	-- figures out which tree element is selected
	-- then calls the correct function to build that part of the GUI
	if selectedParent == 1 then
		local slot = selectedChild or 0
		if selectedChild then
			GUI:DrawSubCrafts(container, selectedChild)
		else
			GUI:DrawStatus(container)
		end
	elseif selectedParent == 2 then -- Materials summary page
		GUI:DrawMaterials(container)
	elseif selectedParent == 3 then -- Options page
		GUI:DrawProfessionOptions(container)
	end
	
	GUI.offsets[GUI.currentPage.parent] = GUI.offsets[GUI.currentPage.parent] or {}
	GUI.offsets[GUI.currentPage.parent][GUI.currentPage.child] = GUI.offsets[GUI.currentPage.parent][GUI.currentPage.child] or 0
	container.children[1].localstatus.offset = GUI.offsets[GUI.currentPage.parent][GUI.currentPage.child]
end

 -- Front Crafts page
function GUI:DrawStatus(container)
	-- checks if a table has at least one element in it
	local function hasElements(sTable)
		local isTable = false
		for i, v in pairs(sTable) do
			return true
		end
	end
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "Label",
					text = "TradeSkillMaster_Crafting v" .. TSM.version .. " " .. L["Status"] .. ": " .. GOLD .. TSM.mode .. "|r\n",
					fontObject = GameFontNormalHuge,
					fullWidth = true,
					colorRed = 255,
					colorGreen = 0,
					colorBlue = 0,
				},
				{
					type = "Spacer"
				},
				{
					type = "Label",
					text = CYAN .. L["Use the links on the left to select which page to show."] .. "|r",
					fontObject = GameFontNormalLarge,
					fullWidth = true,
				},
				{
					type = "Spacer",
					quantity = 2,
				},
				{
					type = "Button",
					text = L["Show Craft Management Window"],
					relativeWidth = 1,
					height = 30,
					callback = function()
							if TSM.db.profile.closeTSMWindow then
								TSMAPI:CloseFrame()
							end
							TSM.Crafting:OpenFrame()
						end,
				},
				{
					type = "Spacer",
					quantity = 2,
				},
				{
					type = "Button",
					text = L["Force Rescan of Profession (Advanced)"],
					relativeWidth = 1,
					callback = function()
							TSM.Data:ScanProfession(TSM.mode)
						end,
				},
			},
		},
	}
	
	if TSM.Data[TSM.mode].crafts == nil or not hasElements(TSM.Data[TSM.mode].crafts) then
	end
	
	if TSM.db.profile.minRestockQuantity.default > TSM.db.profile.maxRestockQuantity.default then
		-- Popup Confirmation Window used in this module
		StaticPopupDialogs["TSMCrafting.Warning2"] = StaticPopupDialogs["TSMCrafting.Warning2"] or {
			text = L["Warning: Your default minimum restock quantity is higher than your maximum restock " ..
				"quantity! Visit the \"Craft Management Window\" section of the Crafting options to fix this!" ..
				"\n\nYou will get error messages printed out to chat if you try and perform a restock queue without fixing this."],
			button1 = L["OK"],
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
		StaticPopup_Show("TSMCrafting.Warning2")
	end
	
	TSMAPI:BuildPage(container, page)
end

-- Craft Pages
function GUI:DrawSubCrafts(container, slot)
	local function ShowAdditionalSettings(parent, itemID, data)
		if GUI.OpenWindow then GUI.OpenWindow:Hide() end
		
		local window = AceGUI:Create("TSMWindow")
		window.frame:SetParent(container.frame)
		window:SetWidth(500)
		window:SetHeight(440)
		window:SetTitle(L["Add Item to TSM_Auctioning"])
		window:SetLayout("Flow")
		window:EnableResize(false)
		window.frame:SetPoint("TOPRIGHT", parent.frame, "TOPLEFT")
		window:SetCallback("OnClose", function(self)
				self:ReleaseChildren()
				GUI.OpenWindow = nil
				window.frame:Hide()
			end)
		GUI.OpenWindow = window
		
		local groupSelection, newGroupName, inAuctioningGroup
		local auctioningGroupList = {}
		local auctioningGroups = TSMAPI:GetData("auctioningGroups")
		for groupName, items in pairs(TSMAPI:GetData("auctioningGroups")) do
			auctioningGroupList[groupName] = groupName
			if items[itemID] then
				inAuctioningGroup = groupName
			end
		end
		
		if tonumber(TSM.db.profile.maxRestockQuantity) then
			TSM.db.profile.maxRestockQuantity = {default = 3}
		end
		
		local page = {
			{
				type = "InteractiveLabel",
				text = select(2, GetItemInfo(itemID)) or data.name,
				fontObject = GameFontHighlight,
				relativeWidth = 1,
				callback = function() SetItemRef("item:".. itemID, itemID) end,
				tooltip = itemID,
			},
			{
				type = "HeadingLine"
			},
			{
				type = "Dropdown",
				label = L["TSM_Auctioning Group to Add Item to:"],
				list = auctioningGroupList,
				value = 1,
				relativeWidth = 0.49,
				callback = function(self, _, value)
						value = value:trim()
						groupSelection = value
						local i = getIndex(self.parent.children, self)
						self.parent.children[i+2]:SetDisabled(not value or value == "")
					end,
				tooltip = L["Which group in TSM_Auctioning to add this item to."],
			},
			{
				type = "Label",
				text = "",
				relativeWidth = 0.02,
			},
			{
				type = "Button",
				text = L["Add Item to Selected Group"],
				relativeWidth = 0.49,
				disabled = true,
				callback = function(self)
						if groupSelection then
							TSM:SendMessage("TSMAUC_NEW_GROUP_ITEM", groupSelection, itemID)
							window.frame:Hide()
						end
					end,
			},
			{
				type = "Spacer"
			},
			{
				type = "EditBox",
				label = L["Name of New Group to Add Item to:"],
				relativeWidth = 0.49,
				callback = function(self, _, value)
						value = value:trim()
						local i = getIndex(self.parent.children, self)
						self.parent.children[i+2]:SetDisabled(not value or value == "")
						newGroupName = value
					end,
			},
			{
				type = "Label",
				text = "",
				relativeWidth = 0.02,
			},
			{
				type = "Button",
				text = L["Add Item to New Group"],
				relativeWidth = 0.49,
				disabled = true,
				callback = function(self)
						if newGroupName then
							TSM:SendMessage("TSMAUC_NEW_GROUP_ITEM", newGroupName, itemID, true)
							window.frame:Hide()
						end
					end,
			},
			{
				type = "HeadingLine"
			},
			{
				type = "Dropdown",
				label = "NOT YET IMPLEMENTED", --"TSM_Mailing Group to Add Item to:",
				list = {"Sapu", "Cente", "Mischanix"},
				value = 1,
				relativeWidth = 0.49,
				callback = function() end,
				disabled = true,
				tooltip = L["Which group in TSM_Mailing to add this item to."],
			},
			{
				type = "Label",
				text = "",
				relativeWidth = 0.02,
			},
			{
				type = "Button",
				text = "NOT YET IMPLEMENTED", --"Add Item to Selected Group",
				disabled = true,
				relativeWidth = 0.49,
				callback = function() end,
			},
			{
				type = "HeadingLine"
			},
			{
				type = "CheckBox",
				label = L["Override Max Restock Quantity"],
				value = TSM.db.profile.maxRestockQuantity[itemID] and true,
				relativeWidth = 0.5,
				callback = function(self, _, value)
						if value then
							TSM.db.profile.maxRestockQuantity[itemID] = TSM.db.profile.maxRestockQuantity.default
						else
							TSM.db.profile.maxRestockQuantity[itemID] = nil
						end
						local siblings = self.parent.children --aw how cute...siblings ;)
						local i = getIndex(siblings, self)
						siblings[i+2]:SetDisabled(not value)
						siblings[i+2]:SetText(TSM.db.profile.maxRestockQuantity[itemID] or "")
						siblings[i+3]:SetDisabled(not value)
						siblings[i+4]:SetDisabled(not value)
					end,
				tooltip = "Allows you to set a custom maximum queue quantity for this item.",
			},
			{
				type = "Label",
				text = "",
				relativeWidth = 0.1,
			},
			{
				type = "EditBox",
				label = L["Max Restock Quantity"],
				value = TSM.db.profile.maxRestockQuantity[itemID],
				disabled = TSM.db.profile.maxRestockQuantity[itemID] == nil,
				relativeWidth = 0.2,
				callback = function(self, _, value)
						value = tonumber(value)
						if value and value >= 0 then
							TSM.db.profile.maxRestockQuantity[itemID] = value
						end
					end,
			},
			{	-- plus sign for incrementing the number
				type = "Icon",
				image = "Interface\\Buttons\\UI-PlusButton-Up",
				width = 24,
				imageWidth = 24,
				imageHeight = 24,
				disabled = TSM.db.profile.maxRestockQuantity[itemID] == nil,
				callback = function(self)
						local value = (TSM.db.profile.maxRestockQuantity[itemID] or 0) + 1
						TSM.db.profile.maxRestockQuantity[itemID] = value
						
						local i = getIndex(self.parent.children, self)
						self.parent.children[i-1]:SetText(value)
					end,
			},
			{	-- minus sign for decrementing the number
				type = "Icon",
				image = "Interface\\Buttons\\UI-MinusButton-Up",
				disabled = true,
				width = 24,
				imageWidth = 24,
				imageHeight = 24,
				disabled = TSM.db.profile.maxRestockQuantity[itemID] == nil,
				callback = function(self)
						local value = (TSM.db.profile.maxRestockQuantity[itemID] or 0) - 1
						if value < 1 then value = 0 end
						
						if value < (TSM.db.profile.minRestockQuantity[itemID] or TSM.db.profile.minRestockQuantity.default) then
							value = TSM.db.profile.minRestockQuantity[itemID] or TSM.db.profile.minRestockQuantity.default
							TSM:Print(string.format(L["Can not set a max restock quantity below the minimum restock quantity of %d."], value))
						end
						TSM.db.profile.maxRestockQuantity[itemID] = value
				
						local i = getIndex(self.parent.children, self)
						self.parent.children[i-2]:SetText(value)
					end,
			},
			{
				type = "CheckBox",
				label = L["Override Min Restock Quantity"],
				value = TSM.db.profile.minRestockQuantity[itemID] and true,
				relativeWidth = 0.6,
				callback = function(self, _, value)
						if value then
							TSM.db.profile.minRestockQuantity[itemID] = TSM.db.profile.minRestockQuantity.default
						else
							TSM.db.profile.minRestockQuantity[itemID] = nil
						end
						local siblings = self.parent.children
						local i = getIndex(siblings, self)
						siblings[i+1]:SetDisabled(not value)
						siblings[i+1]:SetText(TSM.db.profile.minRestockQuantity[itemID] or "")
						siblings[i+2]:SetDisabled(not value)
						siblings[i+3]:SetDisabled(not value)
					end,
				tooltip = L["Allows you to set a custom minimum queue quantity for this item."],
			},
			{
				type = "EditBox",
				label = L["Min Restock Quantity"],
				value = TSM.db.profile.minRestockQuantity[itemID],
				disabled = TSM.db.profile.minRestockQuantity[itemID] == nil,
				relativeWidth = 0.2,
				callback = function(_, _, value)
						value = tonumber(value)
						if value and value >= 0 then
							TSM.db.profile.minRestockQuantity[itemID] = value
						end
					end,
				tooltip = L["This item will only be added to the queue if the number being added " ..
					"is greater than or equal to this number. This is useful if you don't want to bother with " ..
					"crafting singles for example."],
			},
			{	-- plus sign for incrementing the number
				type = "Icon",
				image = "Interface\\Buttons\\UI-PlusButton-Up",
				width = 24,
				imageWidth = 24,
				imageHeight = 24,
				disabled = TSM.db.profile.minRestockQuantity[itemID] == nil,
				callback = function(self)
						local value = (TSM.db.profile.minRestockQuantity[itemID] or 0) + 1
						if value > (TSM.db.profile.maxRestockQuantity[itemID] or TSM.db.profile.maxRestockQuantity.default) then
							value = TSM.db.profile.maxRestockQuantity[itemID] or TSM.db.profile.maxRestockQuantity.default
							TSM:Print(string.format("Can not set a min restock quantity above the max restock quantity of %d.", value))
						end
						TSM.db.profile.minRestockQuantity[itemID] = value
				
						local i = getIndex(self.parent.children, self)
						self.parent.children[i-1]:SetText(value)
					end,
			},
			{	-- minus sign for decrementing the number
				type = "Icon",
				image = "Interface\\Buttons\\UI-MinusButton-Up",
				disabled = true,
				width = 24,
				imageWidth = 24,
				imageHeight = 24,
				disabled = TSM.db.profile.minRestockQuantity[itemID] == nil,
				callback = function(self)
						local value = TSM.db.profile.minRestockQuantity[itemID] - 1
						if value < 1 then value = 1 end
						TSM.db.profile.minRestockQuantity[itemID] = tonumber(value)
						
						local i = getIndex(self.parent.children, self)
						self.parent.children[i-2]:SetText(value)
					end,
			},
			{
				type = "CheckBox",
				label = L["Ignore Seen Count Filter"],
				value = TSM.db.profile.ignoreSeenCountFilter[itemID],
				relativeWidth = 0.5,
				callback = function(_, _, value)
						TSM.db.profile.ignoreSeenCountFilter[itemID] = value
					end,
				tooltip = L["Allows you to set a custom minimum queue quantity for this item."],
			},
			{
				type = "Label",
				text = "",
				relativeWidth = 0.4
			},
			{
				type = "CheckBox",
				label = L["Don't queue this item."],
				value = TSM.db.profile.dontQueue[itemID],
				relativeWidth = 0.5,
				callback = function(_, _, value)
						TSM.db.profile.dontQueue[itemID] = value
					end,
				tooltip = L["This item will not be queued by the \"Restock Queue\" ever."],
			},
			{
				type = "CheckBox",
				label = L["Always queue this item."],
				value = TSM.db.profile.alwaysQueue[itemID],
				relativeWidth = 0.5,
				callback = function(_, _, value)
						TSM.db.profile.alwaysQueue[itemID] = value
					end,
				tooltip = L["This item will always be queued (to the max restock quantity) regardless of price data."],
			},
		}
		
		if inAuctioningGroup then
			for i=1, 7 do
				tremove(page, 3)
			end
			tinsert(page, 3, {
					type = "Label",
					text = string.format(L["This item is already in the \"%s\" Auctioning group."], inAuctioningGroup),
					relativeWidth = 1,
					fontObject = GameFontNormal,
				})
		end
		
		TSMAPI:BuildPage(window, page)
	end
	
	local sortedData = TSM.Data:GetSortedData(TSM.Data[TSM.mode].crafts, function(a, b) return a.name < b.name end)
	
	local function DrawCreateAuctioningGroups(parent)
		if GUI.OpenWindow then GUI.OpenWindow:Hide() end
		
		local window = AceGUI:Create("TSMWindow")
		window.frame:SetParent(container.frame)
		window:SetWidth(560)
		window:SetHeight(250)
		window:SetTitle(L["Export Crafts to TradeSkillMaster_Auctioning"])
		window:SetLayout("flow")
		window:EnableResize(false)
		window.frame:SetPoint("TOPRIGHT", parent.frame, "TOPLEFT")
		window:SetCallback("OnClose", function(self)
				self:ReleaseChildren()
				GUI.OpenWindow = nil
				window.frame:Hide()
			end)
		GUI.OpenWindow = window
		
		local moveCrafts = false
		local onlyEnabled = true
		local targetCategory = "None"
		local groupStyle = "oneGroup"
		local groupSelection = "newGroup"
		
		local auctioningGroups = {["newGroup"] = "<New Group>"}
		for name in pairs(TSMAPI:GetData("auctioningGroups")) do
			auctioningGroups[name] = name
		end
		local auctioningCategories = {["None"]="<No Category>"}
		for name in pairs(TSMAPI:GetData("auctioningCategories")) do
			auctioningCategories[name] = name
		end
		
		local page = {
			{
				type = "Label",
				fontObject = GameFontNormal,
				text = L["Select the crafts you would like to add to Auctioning and use the settings / buttons below to do so."],
				relativeWidth = 1,
			},
			{
				type = "HeadingLine",
			},
			{
				type = "Dropdown",
				list = auctioningCategories,
				value = targetCategory,
				relativeWidth = 0.5,
				label = "Category to put groups into:",
				callback = function(_,_,value) targetCategory = value end,
				tooltip = L["You can select a category that group(s) will be added to or select \"<No Category>\" to not add the group(s) to a category."],
			},
			{
				type = "Dropdown",
				list = {["indivGroups"]=L["All in Individual Groups"], ["oneGroup"]=L["All in Same Group"]},
				value = groupStyle,
				relativeWidth = 0.5,
				label = L["How to add crafts to Auctioning:"],
				callback = function(self,_,value)
						groupStyle = value
						local i = getIndex(self.parent.children, self)
						self.parent.children[i+1]:SetDisabled(value ~= "oneGroup")
					end,
				tooltip = L["You can either add every craft to one group or make individual groups for each craft."],
			},
			{
				type = "Dropdown",
				list = auctioningGroups,
				relativeWidth = 0.5,
				value = groupSelection,
				label = L["Group to Add Crafts to:"],
				disabled = groupStyle ~= "oneGroup",
				callback = function(self,_,value)
						groupSelection = value
					end,
				tooltip = L["Select an Auctioning group to add these crafts to."],
			},
			{
				type = "CheckBox",
				label = L["Include Crafts Already in a Group"],
				value = moveCrafts,
				relativeWidth = 0.5,
				callback = function(_,_,value) moveCrafts = value end,
				tooltip = L["If checked, any crafts which are already in an Auctioning group will be removed from their current group and a new group will be created for them. If you want to maintain the groups you already have setup that include items in this group, leave this unchecked."],
			},
			{
				type = "CheckBox",
				label = L["Only Included Enabled Crafts"],
				value = onlyEnabled,
				relativeWidth = 1,
				callback = function(_,_,value) onlyEnabled = value end,
				tooltip = L["If checked, Only crafts that are enabled (have the checkbox to the right of the item link checked) below will be added to Auctioning groups."],
			},
			{
				type = "Button",
				text = L["Add Crafted Items from this Group to Auctioning Groups"],
				relativeWidth = 1,
				callback = function(self)
						local groups = TSMAPI:GetData("auctioningGroups")
						local function CreateGroupName(name)
							for i=1, 100 do -- it's the user's fault if they have more than 100 groups named this...
								local gName = strlower(name..(i==1 and "" or i))
								if not groups[gName] then
									return gName
								end
							end
						end
						
						local itemLookup = {}
						for groupName, items in pairs(groups) do
							for itemID in pairs(items) do
								itemLookup[itemID] = groupName
							end
						end
						
						local groupName
						local currentSlot = (TSM.mode == "Inscription" and TSM.Inscription:GetSlotList() or TSM[TSM.mode].slotList)[slot]
						if groupStyle == "oneGroup" then
							groupName = (groupSelection ~= "newGroup" and groupSelection or CreateGroupName(TSM.mode.." - "..currentSlot))
							TSM:SendMessage("TSMAUC_NEW_GROUP_ITEM", groupName, nil, groupSelection == "newGroup", targetCategory ~= "None" and targetCategory)
						end
						
						local count = 0
						for _, sData in pairs(sortedData) do
							local itemID = sData.originalIndex
							local data = TSM.Data[TSM.mode].crafts[itemID]
							if data.group == slot then
								-- make sure the item isn't already in a group (or the checkbox is checked to ignore this)
								if (not itemLookup[itemID] or moveCrafts) and (onlyEnabled and data.enabled or not onlyEnabled) then
									count = count + 1
									if not groupName then
										local tempName = CreateGroupName(GetItemInfo(itemID) or data.name)
										TSM:SendMessage("TSMAUC_NEW_GROUP_ITEM", tempName, itemID, true, targetCategory ~= "None" and targetCategory)
									else
										TSM:SendMessage("TSMAUC_NEW_GROUP_ITEM", groupName, itemID)
									end
								end
							end
						end
						
						if groupName then
							TSM:Print(format(L["Added %s crafted items to: %s."], count, "\""..groupName.."\""))
						else
							TSM:Print(format(L["Added %s crafted items to %s individual groups."], count, count))
						end
						self.parent:Hide()
					end,
				tooltip = L["Adds all items in this Crafting group to Auctioning group(s) as per the above settings."],
			},
		}
		
		TSMAPI:BuildPage(window, page)
	end
	
	local page = {
		{
			type = "ScrollFrame",
			layout = "Flow",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Help"],
					fullWidth = true,
					children = {
						{	-- label at the top of the page
							type = "Label",
							text = L["The checkboxes in next to each craft determine enable / disable the craft being shown in the Craft Management Window."],
							fontObject = GameFontNormal,
							relativeWidth = 1,
						},
						{	-- add all button
							type = "Button",
							text = L["Enable All Crafts"],
							relativeWidth = 0.3,
							callback = function(self) 
									for _, sData in pairs(sortedData) do
										local itemID = sData.originalIndex
										if TSM.Data[TSM.mode].crafts[itemID].group == slot then
											TSM.Data[TSM.mode].crafts[itemID].enabled = true
										end
									end
									GUI.TreeGroup:SelectByPath(1, slot)
								end,
						},
						{	-- add all button
							type = "Button",
							text = L["Disable All Crafts"],
							relativeWidth = 0.3,
							callback = function(self) 
									for _, sData in pairs(sortedData) do
										local itemID = sData.originalIndex
										if TSM.Data[TSM.mode].crafts[itemID].group == slot then
											TSM.Data[TSM.mode].crafts[itemID].enabled = false
										end
									end
									GUI.TreeGroup:SelectByPath(1, slot)
								end,
						},
						{	-- add all button
							type = "Button",
							text = L["Create Auctioning Groups"],
							disabled = not TSMAPI:GetData("auctioningCategories"), -- they don't have a recent enough version of auctioning
							relativeWidth = 0.4,
							callback = function(self) DrawCreateAuctioningGroups(self) end,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Crafts"],
					fullWidth = true,
					children = {},
				},
			},
		},
	}
	
	if not select(4, GetAddOnInfo("TradeSkillMaster_Auctioning")) then
		tremove(page[1].children[1].children, 4)
	end
	
	-- local variable to store the parent table to add children widgets to
	local inline = page[1].children[2].children
	
	-- Creates the widgets for the tab
	-- loops once for every craft contained in the tab
	for _, sData in pairs(sortedData) do
		local itemID = sData.originalIndex
		local data = TSM.Data[TSM.mode].crafts[itemID]
		if data.group == slot then
			
			-- The text below the links of each item
			local numCrafted = YELLOW .. (TSM.db.profile.craftHistory[data.spellID] or 0) .. "|r" .. WHITE
			
			-- calculations / widget for printing out the cost, lowest buyout, and profit of the scroll
			local cost, buyout, profit = TSM.Data:CalcPrices(data)
			if buyout and profit then
				buyout = CYAN .. buyout .. "|r" .. GOLD .. "g|r"
				if profit > 0 then
					profit = GREEN .. profit .. "|r" .. GOLD .. "g|r"
				else
					profit = RED .. profit .. "|r" .. GOLD .. "g|r"
				end
			else
				buyout = CYAN .. "?" .. "|r"
				profit = CYAN .. "?|r"
			end
			cost = CYAN .. cost .. "|r" .. GOLD .. "g|r"
			local ts = "       " -- tabspace
			
			-- the line that lists the cost, buyout, and profit
			local rString = format(L["Cost: %s Market Value: %s Profit: %s Times Crafted: %s"],  cost..ts, buyout..ts, profit..ts, numCrafted)
				
			local inlineChildren = {
				{
					type = "CheckBox",
					relativeWidth = 0.05,
					value = data.enabled,
					tooltip = L["Enable / Disable showing this craft in the craft management window."],
					callback = function(_,_,value)
							if not value then
								data.queued = 0
							end
							data.enabled = value
						end,
				},
				{
					type = "InteractiveLabel",
					text = select(2, GetItemInfo(itemID)) or data.name,
					fontObject = GameFontHighlight,
					relativeWidth = 0.61,
					callback = function() SetItemRef("item:".. itemID, itemID) end,
					tooltip = itemID,
				},
				{
					type = "Button",
					text = L["Additional Item Settings"],
					relativeWidth = 0.34,
					callback = function(self) ShowAdditionalSettings(self, itemID, data) end,
				},
				{
					type = "Label",
					text = rString,
					fontObject = GameFontWhite,
					fullWidth = true,
				},
				{
					type = "HeadingLine",
				},
			}
			
			foreach(inlineChildren, function(_, data) tinsert(inline, data) end)
		end
	end
	
	-- if no crafts have been added for this slot, show a message to alert the user
	if #(inline) == 0 then
		local text = L["No crafts have been added for this profession. Crafts are automatically added when you click on the profession icon while logged onto a character which has that profession."]
		tinsert(inline, {
				type = "Label",
				text = text,
				fontObject = GameFontNormal,
				fullWidth=true,
			})
	else
		-- remove the last headingline
		tremove(inline)
	end
	
	TSMAPI:BuildPage(container, page)
end

-- Materials Page
function GUI:DrawMaterials(container)
	TSM.Data:CalculateCosts()
	local matText = L["Here, you can view and change the material prices. If scanning for materials is enabled "	..
		"in the options, TradeSkillMaster_Crafting will update these values with the results of the scan. If you lock " .. 
		"the cost of a material it will not be changed by TradeSkillMaster_Crafting."]
	
	-- scroll frame to contain everything
	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Help"],
					fullWidth = true,
					children = {
						{
							type = "Label",
							text = matText,
							fontObject = GameFontWhite,
							fullWidth = true,
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Materials"],
					fullWidth = true,
					children = {},
				},
			},
		},
	}

	-- create all the text lables / editboxes for the materials page
	-- this series of for loops and if statements builds the widgets in 2 collums
	-- numbers 1-7 are in the first collum and 8-13 in the second collum
	local matList = TSM.Data:GetMats()
	local inline = page[1].children[2].children
	for num=1, #(matList) do
		tinsert(inline, {
				type = "CheckBox",
				label = L["Override Cost"],
				width = 200,
				value = TSM.db.profile.matLock[matList[num]],
				callback = function(self, _, value)
						TSM.db.profile.matLock[matList[num]] = value
						local i = getIndex(self.parent.children, self)
						self.parent.children[i+1]:SetDisabled(not value)
						GUI.TreeGroup:SelectByPath(2)
					end,
			})
	
		-- the editboxes for viewing / changing the cost of the mats.
		tinsert(inline, {
				type = "EditBox",
				value = tostring(TSM.db.profile[TSM.mode].mats[matList[num]].cost),
				relativeWidth = 0.15,
				disabled = not TSM.db.profile.matLock[matList[num]],
				callback = function(self,_,value)
						value = tonumber(value)
						if value and (value < 1000000) then
							TSM.db.profile[TSM.mode].mats[matList[num]].cost = value
						else
							self:SetText(0)
						end
					end,
			})
			
		tinsert(inline, {
				type = "InteractiveLabel",
				text = select(2, GetItemInfo(matList[num])) or TSM.db.profile[TSM.mode].mats[matList[num]].name,
				fontObject = GameFontNormal,
				relativeWidth = 0.35,
				callback = function() SetItemRef("item:".. matList[num], matList[num]) end,
			})
		
		tinsert(inline, {
				type = "Spacer",
			})
	end
	
	TSMAPI:BuildPage(container, page)
end

-- Profession Options Page
function GUI:DrawProfessionOptions(container)
	-- scroll frame to contain everything
	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Restock Queue Overrides"],
					fullWidth = true,
					children = {
						{
							type = "Label",
							text = L["Here, you can override default restock queue settings."],
							fontObject = GameFontNormal,
							fullWidth = true,
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["Override Max Restock Quantity"],
							value = TSM.db.profile.maxRestockQuantity[TSM.mode] and true,
							relativeWidth = 0.5,
							callback = function(self, _, value)
									if value then
										TSM.db.profile.maxRestockQuantity[TSM.mode] = TSM.db.profile.maxRestockQuantity.default
									else
										TSM.db.profile.maxRestockQuantity[TSM.mode] = nil
									end
									local siblings = self.parent.children --aw how cute...siblings ;)
									local i = getIndex(siblings, self)
									siblings[i+2]:SetDisabled(not value)
									siblings[i+2]:SetText(TSM.db.profile.maxRestockQuantity[TSM.mode] or "")
									siblings[i+3]:SetDisabled(not value)
									siblings[i+4]:SetDisabled(not value)
								end,
							tooltip = L["Allows you to set a custom maximum queue quantity for this profession."],
						},
						{
							type = "Label",
							text = "",
							relativeWidth = 0.1,
						},
						{
							type = "EditBox",
							label = L["Max Restock Quantity"],
							value = TSM.db.profile.maxRestockQuantity[TSM.mode],
							disabled = TSM.db.profile.maxRestockQuantity[TSM.mode] == nil,
							relativeWidth = 0.2,
							callback = function(self, _, value)
									value = tonumber(value)
									if value and value >= 0 then
										TSM.db.profile.maxRestockQuantity[TSM.mode] = value
									end
								end,
						},
						{	-- plus sign for incrementing the number
							type = "Icon",
							image = "Interface\\Buttons\\UI-PlusButton-Up",
							width = 24,
							imageWidth = 24,
							imageHeight = 24,
							disabled = TSM.db.profile.maxRestockQuantity[TSM.mode] == nil,
							callback = function(self)
									local value = (TSM.db.profile.maxRestockQuantity[TSM.mode] or 0) + 1
									TSM.db.profile.maxRestockQuantity[TSM.mode] = value
									
									local i = getIndex(self.parent.children, self)
									self.parent.children[i-1]:SetText(value)
								end,
						},
						{	-- minus sign for decrementing the number
							type = "Icon",
							image = "Interface\\Buttons\\UI-MinusButton-Up",
							disabled = true,
							width = 24,
							imageWidth = 24,
							imageHeight = 24,
							disabled = TSM.db.profile.maxRestockQuantity[TSM.mode] == nil,
							callback = function(self)
									local value = (TSM.db.profile.maxRestockQuantity[TSM.mode] or 0) - 1
									if value < 1 then value = 0 end
									
									if value < (TSM.db.profile.minRestockQuantity[TSM.mode] or TSM.db.profile.minRestockQuantity.default) then
										value = TSM.db.profile.minRestockQuantity[TSM.mode] or TSM.db.profile.minRestockQuantity.default
										TSM:Print(string.format(L["Can not set a max restock quantity below the minimum restock quantity of %d."], value))
									end
									TSM.db.profile.maxRestockQuantity[TSM.mode] = value
							
									local i = getIndex(self.parent.children, self)
									self.parent.children[i-2]:SetText(value)
								end,
						},
						{
							type = "CheckBox",
							label = L["Override Min Restock Quantity"],
							value = TSM.db.profile.minRestockQuantity[TSM.mode] and true,
							relativeWidth = 0.6,
							callback = function(self, _, value)
									if value then
										TSM.db.profile.minRestockQuantity[TSM.mode] = TSM.db.profile.minRestockQuantity.default
									else
										TSM.db.profile.minRestockQuantity[TSM.mode] = nil
									end
									
									local siblings = self.parent.children --aw how cute...siblings ;)
									local i = getIndex(siblings, self)
									siblings[i+1]:SetDisabled(not value)
									siblings[i+1]:SetText(TSM.db.profile.minRestockQuantity[TSM.mode] or "")
									siblings[i+2]:SetDisabled(not value)
									siblings[i+3]:SetDisabled(not value)
								end,
							tooltip = L["Allows you to set a custom minimum queue quantity for this profession."],
						},
						{
							type = "EditBox",
							label = L["Min Restock Quantity"],
							value = TSM.db.profile.minRestockQuantity[TSM.mode],
							disabled = TSM.db.profile.minRestockQuantity[TSM.mode] == nil,
							relativeWidth = 0.2,
							callback = function(_, _, value)
									value = tonumber(value)
									if value and value >= 0 then
										TSM.db.profile.minRestockQuantity[TSM.mode] = value
									end
								end,
							tooltip = L["This item will only be added to the queue if the number being added " ..
								"is greater than or equal to this number. This is useful if you don't want to bother with " ..
								"crafting singles for example."],
						},
						{	-- plus sign for incrementing the number
							type = "Icon",
							image = "Interface\\Buttons\\UI-PlusButton-Up",
							width = 24,
							imageWidth = 24,
							imageHeight = 24,
							disabled = TSM.db.profile.minRestockQuantity[TSM.mode] == nil,
							callback = function(self)
									local value = (TSM.db.profile.minRestockQuantity[TSM.mode] or 0) + 1
									if value > (TSM.db.profile.maxRestockQuantity[TSM.mode] or TSM.db.profile.maxRestockQuantity.default) then
										value = TSM.db.profile.maxRestockQuantity[TSM.mode] or TSM.db.profile.maxRestockQuantity.default
										TSM:Print(string.format("Can not set a min restock quantity above the max restock quantity of %d.", value))
									end
									TSM.db.profile.minRestockQuantity[TSM.mode] = value
							
									local i = getIndex(self.parent.children, self)
									self.parent.children[i-1]:SetText(value)
								end,
						},
						{	-- minus sign for decrementing the number
							type = "Icon",
							image = "Interface\\Buttons\\UI-MinusButton-Up",
							disabled = true,
							width = 24,
							imageWidth = 24,
							imageHeight = 24,
							disabled = TSM.db.profile.minRestockQuantity[TSM.mode] == nil,
							callback = function(self)
									local value = TSM.db.profile.minRestockQuantity[TSM.mode] - 1
									if value < 1 then value = 1 end
									TSM.db.profile.minRestockQuantity[TSM.mode] = tonumber(value)
									
									local i = getIndex(self.parent.children, self)
									self.parent.children[i-2]:SetText(value)
								end,
						},
						{
							type = "HeadingLine",
						},
						{
							type = "CheckBox",
							label = L["Override Minimum Profit"],
							value = TSM.db.profile.queueProfitMethod[TSM.mode] ~= nil,
							relativeWidth = 0.5,
							callback = function(self, _, value)
									if value then
										TSM.db.profile.queueProfitMethod[TSM.mode] = TSM.db.profile.queueProfitMethod.default
										TSM.db.profile.queueMinProfitGold[TSM.mode] = TSM.db.profile.queueMinProfitGold.default
										TSM.db.profile.queueMinProfitPercent[TSM.mode] = TSM.db.profile.queueMinProfitPercent.default
									else
										TSM.db.profile.queueProfitMethod[TSM.mode] = nil
										TSM.db.profile.queueMinProfitGold[TSM.mode] = nil
										TSM.db.profile.queueMinProfitPercent[TSM.mode] = nil
									end
									GUI.TreeGroup:SelectByPath(3)
								end,
							tooltip = L["Allows you to override the minimum profit settings for this profession."],
						},
						{	-- dropdown to select the method for setting the Minimum profit for the main crafts page
							type = "Dropdown",
							label = L["Minimum Profit Method"],
							list = {["gold"]=L["Gold Amount"], ["percent"]=L["Percent of Cost"],
								["none"]=L["No Minimum"], ["both"]=L["Percent and Gold Amount"]},
							value = TSM.db.profile.queueProfitMethod[TSM.mode],
							disabled = TSM.db.profile.queueProfitMethod[TSM.mode] == nil,
							relativeWidth = 0.49,
							callback = function(self,_,value)
									TSM.db.profile.queueProfitMethod[TSM.mode] = value
									GUI.TreeGroup:SelectByPath(3)
								end,
							tooltip = L["You can choose to specify a minimum profit amount (in gold or by " ..
								"percent of cost) for what crafts should be added to the craft queue."],
						},
						{
							type = "Slider",
							value = TSM.db.profile.queueMinProfitPercent[TSM.mode] or TSM.db.profile.queueMinProfitPercent.default or 0,
							label = L["Minimum Profit (in %)"],
							tooltip = L["If enabled, any craft with a profit over this percent of the cost will be added to " ..
								"the craft queue when you use the \"Restock Queue\" button."],
							min = 0,
							max = 2,
							step = 0.01,
							relativeWidth = 0.49,
							isPercent = true,
							disabled = TSM.db.profile.queueProfitMethod[TSM.mode] == nil or TSM.db.profile.queueProfitMethod[TSM.mode] == "none" or TSM.db.profile.queueProfitMethod[TSM.mode] == "gold",
							callback = function(_,_,value)
									TSM.db.profile.queueMinProfitPercent[TSM.mode] = math.floor(value*100)/100
								end,
						},
						{
							type = "Slider",
							value = TSM.db.profile.queueMinProfitGold[TSM.mode] or TSM.db.profile.queueMinProfitGold.default or 0,
							label = L["Minimum Profit (in gold)"],
							tooltip = L["If enabled, any craft with a profit over this value will be added to the craft queue " ..
								"when you use the \"Restock Queue\" button."],
							min = 0,
							max = 300,
							step = 1,
							relativeWidth = 0.49,
							disabled = TSM.db.profile.queueProfitMethod[TSM.mode] == nil or TSM.db.profile.queueProfitMethod[TSM.mode] == "none" or TSM.db.profile.queueProfitMethod[TSM.mode] == "percent",
							callback = function(_,_,value)
									TSM.db.profile.queueMinProfitGold[TSM.mode] = math.floor(value)
								end,
						},
					},
				},
			},
		},
	}
	
	if TSM.mode == "Inscription" then
		tinsert(page[1].children, 1, {
				type = "InlineGroup",
				layout = "flow",
				title = L["Profession-Specific Settings"],
				fullWidth = true,
				children = {
					{	-- dropdown to select how to calculate material costs
						type = "Dropdown",
						label = L["Group Inscription Crafts By:"],
						list = {L["Ink"], L["Class"]},
						value = TSM.db.profile.inscriptionGrouping,
						relativeWidth = 0.49,
						callback = function(_,_,value)
								TSM.db.profile.inscriptionGrouping = value
								TSM.Data:ReGroup()
								
								-- clicks on the icon in order to reload the treeGroup
								for i=1, #TSM.tradeSkills do
									if TSM.tradeSkills[i].name == TSM.mode then
										TSMAPI:SelectIcon("TradeSkillMaster_Crafting", "Crafting - "..GetSpellInfo(TSM.tradeSkills[i].spellID))
										break
									end
								end
								GUI.TreeGroup:SelectByPath(3)
							end,
						tooltip = L["Inscription crafts can be grouped in TradeSkillMaster_Crafting either by class or by the ink required to make them."],
					},
				},
			})
	end
	
	TSMAPI:BuildPage(container, page)
end

-- Options Page
function GUI:DrawOptions(container)
	local tg = AceGUI:Create("TSMTabGroup")
	tg:SetLayout("Fill")
	tg:SetFullHeight(true)
	tg:SetFullWidth(true)
	tg:SetTabs({{value = 1, text = L["Data"]}, {value = 2, text = L["Craft Management Window"]}, {value = 3, text = L["Profiles"]}})
	container:AddChild(tg)
	
	local ddList1 = {["Manual"] = L["Manual Entry"]}
	local ddList2 = {}
	if select(4, GetAddOnInfo("Auc-Advanced")) == 1 then
		ddList1["AucMarket"]=L["Auctioneer - Market Value"]
		ddList1["AucAppraiser"]=L["Auctioneer - Appraiser"]
		ddList1["AucMinBuyout"]=L["Auctioneer - Minimum Buyout"]
		ddList2["AucMarket"]=L["Auctioneer - Market Value"]
		ddList2["AucAppraiser"]=L["Auctioneer - Appraiser"]
		ddList2["AucMinBuyout"]=L["Auctioneer - Minimum Buyout"]
	end
		
	if select(4, GetAddOnInfo("TradeSkillMaster_AuctionDB")) == 1 then
		ddList1["DBMarket"]=L["AuctionDB - Market Value"]
		ddList1["DBMinBuyout"]=L["AuctionDB - Minimum Buyout"]
		ddList2["DBMarket"]=L["AuctionDB - Market Value"]
		ddList2["DBMinBuyout"]=L["AuctionDB - Minimum Buyout"]
	end
	
	local function GetTab(num)
		local altCharacters, altGuilds, altCharactersValue, altGuildsValue = {}, {}, {}, {}
		if TSM.db.profile.altAddon == "DataStore" and DataStore and DataStore.GetCharacters and DataStore.GetGuilds then
			if TSM.db.profile.altCharacters == nil then
				for account in pairs(DataStore:GetAccounts()) do
					for name, character in pairs(DataStore:GetCharacters(nil, account)) do
						if DataStore:GetCharacterFaction(character) == DataStore:GetCharacterFaction(DataStore:GetCharacter()) then
							TSM.db.profile.altCharacters[name] = true
						end
					end
				end
			end
			for account in pairs(DataStore:GetAccounts()) do
				for name, character in pairs(DataStore:GetCharacters(nil, account)) do
					if DataStore:GetCharacterFaction(character) == DataStore:GetCharacterFaction(DataStore:GetCharacter()) then
						tinsert(altCharacters, name)
						tinsert(altCharactersValue, TSM.db.profile.altCharacters[name])
					end
				end
			end
			
			if TSM.db.profile.altGuilds == nil then
				for account in pairs(DataStore:GetAccounts()) do
					for name in pairs(DataStore:GetGuilds(nil, account)) do
						TSM.db.profile.altGuilds[name] = true
					end
				end
			end
			for account in pairs(DataStore:GetAccounts()) do
				for name in pairs(DataStore:GetGuilds(nil, account)) do
					tinsert(altGuilds, name)
					tinsert(altGuildsValue, TSM.db.profile.altGuilds[name])
				end
			end
		elseif TSM.db.profile.altAddon == "Gathering" and select(4, GetAddOnInfo("TradeSkillMaster_Gathering")) == 1 then
			altCharacters = TSMAPI:GetData("playerlist")
			altGuilds = TSMAPI:GetData("guildlist")
			
			for _, name in pairs(altCharacters) do
				tinsert(altCharactersValue, TSM.db.profile.altCharacters[name])
			end
			for _, name in pairs(altGuilds) do
				tinsert(altGuildsValue, TSM.db.profile.altGuilds[name])
			end
		end
		
		local addonList, fullAddonList = {}, {["DataStore"] = L["DataStore"], ["Gathering"] = L["Gathering"]}
		if select(4, GetAddOnInfo("DataStore_Auctions")) == 1 and DataStore then
			addonList["DataStore"] = L["DataStore"]
		end
		if select(4, GetAddOnInfo("TradeSkillMaster_Gathering")) == 1 then
			addonList["Gathering"] = L["Gathering"]
		end
		
		local page = {}
		
		page[1] = {
			{	-- scroll frame to contain everything
				type = "ScrollFrame",
				layout = "List",
				children = {
					{ 	-- holds the second group of options (profit deduction label + slider)
						type = "InlineGroup",
						layout = "flow",
						title = L["Price Settings"],
						fullWidth = true,
						children = {
							{	-- dropdown to select how to calculate material costs
								type = "Dropdown",
								label = L["Get Mat Prices From:"],
								list = ddList1,
								value = TSM.db.profile.matCostSource,
								relativeWidth = 0.45,
								callback = function(_,_,value)
										TSM.db.profile.matCostSource = value
										TSM.Data:CalculateCosts()
									end,
								tooltip = L["This is where TradeSkillMaster_Crafting will get material prices. AuctionDB is the integrated TSM Addon, whereas Auctioneer requires Auc-Advanced to be enabled for functionality.  Alternatively, prices can be entered manually in the \"Materials\" pages."],
							},
							{	-- dropdown to select how to calculate material costs
								type = "Dropdown",
								label = L["Get Craft Prices From:"],
								list = ddList2,
								value = TSM.db.profile.craftCostSource,
								relativeWidth = 0.45,
								callback = function(_,_,value)
										TSM.db.profile.craftCostSource = value
										TSM.Data:CalculateCosts()
									end,
								tooltip = L["This is where TradeSkillMaster_Crafting will get prices for crafted items. AuctionDB is the integrated TSM Addon, whereas Auctioneer requires Auc-Advanced to be enabled for functionality."],
							},
							{	-- just a spacer to seperate the dropdown from the slider
								type = "Label",
								text = "",
								relativeWidth = 0.09,
							},
							{	-- slider to set the % to deduct from profits
								type = "Slider",
								value = TSM.db.profile.profitPercent,
								label = L["Profit Deduction"],
								isPercent = true,
								min = 0,
								max = 0.25,
								step = 0.01,
								relativeWidth = 0.45,
								callback = function(_,_,value) TSM.db.profile.profitPercent = value end,
								tooltip = L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."],
							},
						},
					},
					{
						type = "Spacer"
					},
					{ 	-- holds the second group of options (profit deduction label + slider)
						type = "InlineGroup",
						layout = "flow",
						title = L["Inventory Settings"],
						fullWidth = true,
						children = {
							{
								type = "Label",
								text = L["TradeSkillMaster_Crafting can use TradeSkillMaster_Gathering or DataStore_Containers " ..
									"to provide data for a number of different places inside TradeSkillMaster_Crafting. Use the " ..
									"settings below to set this up."],
								fontObject = GameFontNormal,
								fullWidth = true,
							},
							{
								type = "HeadingLine",
							},
							{
								type = "Dropdown",
								label = L["Addon to use for alt data:"],
								value = fullAddonList[TSM.db.profile.altAddon],
								list = addonList,
								relativeWidth = 0.49,
								callback = function(self,_,value)
										TSM.db.profile.altAddon = value
										tg:SelectTab(1)
									end,
							},
							{
								type = "HeadingLine"
							},
							{
								type = "Dropdown",
								label = L["Characters to include:"],
								value = altCharactersValue,
								list = altCharacters,
								relativeWidth = 0.49,
								multiselect = true,
								disabled = not TSM.db.profile.altAddon,
								callback = function(self,_,key,value)
										TSM.db.profile.altCharacters[altCharacters[key]] = value
										self:SetValue(altCharactersValue)
									end,
							},
							{
								type = "Dropdown",
								label = L["Guilds to include:"],
								value = altGuildsValue,
								list = altGuilds,
								relativeWidth = 0.49,
								multiselect = true,
								disabled = not TSM.db.profile.altAddon,
								callback = function(_,_,key, value)
										TSM.db.profile.altGuilds[altGuilds[key]] = value
									end,
							},
						},
					},
				},
			},
		}
	
		page[2] = {
			{	-- scroll frame to contain everything
				type = "ScrollFrame",
				layout = "List",
				children = {
					{
						type = "InlineGroup",
						layout = "flow",
						title = L["General"],
						fullWidth = true,
						children = {
							{	-- option to close / not close the main TSM window when opening the Craft Management Window
								type = "CheckBox",
								value = TSM.db.profile.closeTSMWindow,
								label = L["Close TSM Frame When Opening Craft Management Window"],
								relativeWidth = 1,
								callback = function(_,_,value) TSM.db.profile.closeTSMWindow = value end,
								tooltip = L["If checked, the main TSM frame will close when you open the craft management window."],
							},
							{	-- slider to set the stock number
								type = "Slider",
								value = TSM.db.profile.craftManagementWindowScale,
								label = L["Frame Scale"],
								isPercent = true,
								min = 0.5,
								max = 2,
								step = 0.01,
								relativeWidth = 0.49,
								callback = function(_,_,value)
										TSM.db.profile.craftManagementWindowScale = value
										if TSM.Crafting.frame and TSM.Crafting.openCloseButton then
											TSM.Crafting.openCloseButton:SetScale(value)
											TSM.Crafting.frame:SetScale(value)
										end
									end,
								tooltip = L["This will set the scale of the craft management window. Everything inside the window will be scaled by this percentage."],
							},
							{	-- slider to set the stock number
								type = "Slider",
								value = TSM.db.profile.craftManagementWindowScale,
								label = L["Double Click Queue"],
								min = 2,
								max = 10,
								step = 1,
								relativeWidth = 0.49,
								callback = function(self,_,value)
										self:ClearFocus()
										value = floor(value + 0.5)
										if value < 2 then value = 2 end
										if value > 10 then value = 10 end
										self:SetValue(value)
										TSM.db.profile.doubleClick = value
									end,
								tooltip = L["When you double click on a craft in the top-left portion (queuing portion) of the craft management window, it will increment/decrement this many times."],
							},
						},
					},
					{
						type = "InlineGroup",
						layout = "flow",
						title = L["Restock Queue Settings"],
						fullWidth = true,
						children = {
							{
								type = "Label",
								text = L["These options control the \"Restock Queue\" button in the craft management window."],
								fontObject = GameFontNormal,
								fullWidth = true,
							},
							{
								type = "HeadingLine",
							},
							{
								type = "CheckBox",
								value = TSM.db.profile.restockAH,
								label = L["Include Items on AH When Restocking"],
								relativeWidth = 1,
								callback = function(_,_,value) TSM.db.profile.restockAH = value end,
								tooltip = L["When you use the \"Restock Queue\" button, it will queue enough of " ..
									"each craft so that you will have the desired maximum quantity on hand. If " ..
									"you check this checkbox, anything that you have on the AH as of the last scan " ..
									"will be included in the number you currently have on hand."],
							},
							{	-- dropdown to select the method for setting the Minimum profit for the main crafts page
								type = "Dropdown",
								label = L["Minimum Profit Method"],
								list = {["gold"]=L["Gold Amount"], ["percent"]=L["Percent of Cost"],
									["none"]=L["No Minimum"], ["both"]=L["Percent and Gold Amount"]},
								value = TSM.db.profile.queueProfitMethod.default,
								relativeWidth = 0.49,
								callback = function(self,_,value)
										TSM.db.profile.queueProfitMethod.default = value
										tg:SelectTab(2)
									end,
								tooltip = L["You can choose to specify a minimum profit amount (in gold or by " ..
									"percent of cost) for what crafts should be added to the craft queue."],
							},
							{
								type = "Label",
								text = "",
								relativeWidth = 0.5,
							},
							{	-- slider to set the stock number
								type = "Slider",
								value = TSM.db.profile.minRestockQuantity.default,
								label = L["Min Restock Quantity"],
								isPercent = false,
								min = 1,
								max = 20,
								step = 1,
								relativeWidth = 0.49,
								callback = function(self,_,value)
										if value > TSM.db.profile.maxRestockQuantity.default then
											TSMAPI:SetStatusText("|cffffff00"..L["Warning: The min restock quantity must be lower than the max restock quantity."].."|r")
										else
											TSMAPI:SetStatusText("")
										end
										TSM.db.profile.minRestockQuantity.default = value
									end,
								tooltip = L["Items will only be added to the queue if the number being added " ..
										"is greater than this number. This is useful if you don't want to bother with " ..
										"crafting singles for example."],
							},
							{	-- slider to set the stock number
								type = "Slider",
								value = TSM.db.profile.maxRestockQuantity.default,
								label = L["Max Restock Quantity"],
								isPercent = false,
								min = 1,
								max = 20,
								step = 1,
								relativeWidth = 0.49,
								callback = function(self,_,value)
										if value < TSM.db.profile.minRestockQuantity.default then
											TSMAPI:SetStatusText(CYAN ..L["Warning: The min restock quantity must be lower than the max restock quantity"])
										else
											TSMAPI:SetStatusText("")
										end
										TSM.db.profile.maxRestockQuantity.default = value
									end,
								tooltip = L["When you click on the \"Restock Queue\" button enough of each " ..
									"craft will be queued so that you have this maximum number on hand. For " ..
									"example, if you have 2 of item X on hand and you set this to 4, 2 more " ..
									"will be added to the craft queue."],
							},
							{
								type = "Slider",
								value = TSM.db.profile.queueMinProfitPercent.default,
								label = L["Minimum Profit (in %)"],
								tooltip = L["If enabled, any craft with a profit over this percent of the cost will be added to " ..
									"the craft queue when you use the \"Restock Queue\" button."],
								min = 0,
								max = 2,
								step = 0.01,
								relativeWidth = 0.49,
								isPercent = true,
								disabled = TSM.db.profile.queueProfitMethod.default == "none" or TSM.db.profile.queueProfitMethod.default == "gold",
								callback = function(_,_,value)
										TSM.db.profile.queueMinProfitPercent.default = math.floor(value*100)/100
									end,
							},
							{
								type = "Slider",
								value = TSM.db.profile.queueMinProfitGold.default,
								label = L["Minimum Profit (in gold)"],
								tooltip = L["If enabled, any craft with a profit over this value will be added to the craft queue " ..
									"when you use the \"Restock Queue\" button."],
								min = 0,
								max = 300,
								step = 1,
								relativeWidth = 0.49,
								disabled = TSM.db.profile.queueProfitMethod.default == "none" or TSM.db.profile.queueProfitMethod.default == "percent",
								callback = function(_,_,value)
										TSM.db.profile.queueMinProfitGold.default = math.floor(value)
									end,
							},
							{
								type = "HeadingLine",
							},
							{
								type = "CheckBox",
								value = TSM.db.profile.seenCountFilterSource ~= "",
								label = L["Filter out items with low seen count."],
								relativeWidth = 1,
								callback = function(self, _, value)
										TSM.db.profile.seenCountFilterSource = (value and "AuctionDB") or ""
										local siblings = self.parent.children --aw how cute...siblings ;)
										local i = getIndex(siblings, self)
										siblings[i+1]:SetDisabled(not value)
										siblings[i+3]:SetDisabled(not value)
										siblings[i+4]:SetDisabled(not value)
										siblings[i+5]:SetDisabled(not value)
										siblings[i+1]:SetValue(TSM.db.profile.seenCountFilterSource)
									end,
								tooltip = L["When you use the \"Restock Queue\" button, it will ignore any items "
									.. "with a seen count below the seen count filter below. The seen count data "
									.. "can be retreived from either Auctioneer or TradeSkillMaster's AuctionDB module."],
							},
							{	-- dropdown to select the method for setting the Minimum profit for the main crafts page
								type = "Dropdown",
								label = L["Seen Count Source"],
								disabled = TSM.db.profile.seenCountFilterSource == "",
								list = {["AuctionDB"]=L["TradeSkillMaster_AuctionDB"], ["Auctioneer"]=L["Auctioneer"]},
								value = TSM.db.profile.seenCountFilterSource,
								relativeWidth = 0.49,
								callback = function(_, _, value)
										TSM.db.profile.seenCountFilterSource = value
										tg:SelectTab(2)
									end,
								tooltip = L["This setting determines where seen count data is retreived from. The seen count data "
									.. "can be retreived from either Auctioneer or TradeSkillMaster's AuctionDB module."],
							},
							{
								type = "Label",
								text = "",
								relativeWidth = 0.1,
							},
							{
								type = "EditBox",
								label = L["Seen Count Filter"],
								value = TSM.db.profile.seenCountFilter,
								disabled = TSM.db.profile.seenCountFilterSource == "",
								relativeWidth = 0.2,
								callback = function(self, _, value)
										value = tonumber(value)
										if value and value >= 0 then
											TSM.db.profile.seenCountFilter = value
										end
									end,
								tooltip = L["If enabled, any item with a seen count below this seen count filter value will not "
									.. "be added to the craft queue when using the \"Restock Queue\" button. You can overrride "
									.. "this filter for individual items in the \"Additional Item Settings\"."],
							},
							{	-- plus sign for incrementing the number
								type = "Icon",
								image = "Interface\\Buttons\\UI-PlusButton-Up",
								width = 24,
								imageWidth = 24,
								imageHeight = 24,
								disabled = TSM.db.profile.seenCountFilterSource == "",
								callback = function(self)
										local value = TSM.db.profile.seenCountFilter + 1
										TSM.db.profile.seenCountFilter = value
								
										local i = getIndex(self.parent.children, self)
										self.parent.children[i-1]:SetText(value)
									end,
							},
							{	-- minus sign for decrementing the number
								type = "Icon",
								image = "Interface\\Buttons\\UI-MinusButton-Up",
								disabled = true,
								width = 24,
								imageWidth = 24,
								imageHeight = 24,
								disabled = TSM.db.profile.seenCountFilterSource == "",
								callback = function(self)
										local value = TSM.db.profile.seenCountFilter - 1
										if value < 0 then value = 0 end
										TSM.db.profile.seenCountFilter = value
								
										local i = getIndex(self.parent.children, self)
										self.parent.children[i-2]:SetText(value)
									end,
							},
						},
					},
					{
						type = "Spacer",
					},
				},
			},
		}
		
		-- profiles page
		local text = {
			default = L["Default"],
			intro = L["You can change the active database profile, so you can have different settings for every character."],
			reset_desc = L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."],
			reset = L["Reset Profile"],
			choose_desc = L["You can either create a new profile by entering a name in the editbox, or choose one of the already exisiting profiles."],
			new = L["New"],
			new_sub = L["Create a new empty profile."],
			choose = L["Existing Profiles"],
			copy_desc = L["Copy the settings from one existing profile into the currently active profile."],
			copy = L["Copy From"],
			delete_desc = L["Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file."],
			delete = L["Delete a Profile"],
			profiles = L["Profiles"],
			current = L["Current Profile:"] .. " " .. CYAN .. TSM.db:GetCurrentProfile() .. "|r",
		}
	
		-- Returns a list of all the current profiles with common and nocurrent modifiers.
		-- This code taken from AceDBOptions-3.0.lua
		local function GetProfileList(db, common, nocurrent)
			local profiles = {}
			local tmpprofiles = {}
			local defaultProfiles = {["Default"] = "Default"}
			
			-- copy existing profiles into the table
			local currentProfile = db:GetCurrentProfile()
			for i,v in pairs(db:GetProfiles(tmpprofiles)) do 
				if not (nocurrent and v == currentProfile) then 
					profiles[v] = v 
				end 
			end
			
			-- add our default profiles to choose from ( or rename existing profiles)
			for k,v in pairs(defaultProfiles) do
				if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
					profiles[k] = v
				end
			end
			
			return profiles
		end
	
		page[3] = {
			{	-- scroll frame to contain everything
				type = "ScrollFrame",
				layout = "List",
				children = {
					{
						type = "Label",
						text = "TradeSkillMaster_Crafting" .. "\n",
						fontObject = GameFontNormalLarge,
						fullWidth = true,
						colorRed = 255,
						colorGreen = 0,
						colorBlue = 0,
					},
					{
						type = "Label",
						text = text["intro"] .. "\n" .. "\n",
						fontObject = GameFontNormal,
						fullWidth = true,
					},
					{
						type = "Label",
						text = text["reset_desc"],
						fontObject = GameFontNormal,
						fullWidth = true,
					},
					{	--simplegroup1 for the reset button / current profile text
						type = "SimpleGroup",
						layout = "flow",
						fullWidth = true,
						children = {
							{
								type = "Button",
								text = text["reset"],
								callback = function() TSM.db:ResetProfile() end,
							},
							{
								type = "Label",
								text = text["current"],
								fontObject = GameFontNormal,
							},
						},
					},
					{
						type = "Spacer",
						quantity = 2,
					},
					{
						type = "Label",
						text = text["choose_desc"],
						fontObject = GameFontNormal,
						fullWidth = true,
					},
					{	--simplegroup2 for the new editbox / existing profiles dropdown
						type = "SimpleGroup",
						layout = "flow",
						fullWidth = true,
						children = {
							{
								type = "EditBox",
								label = text["new"],
								value = "",
								callback = function(_,_,value)
										TSM.db:SetProfile(value)
										tg:SelectTab(3)
									end,
							},
							{
								type = "Dropdown",
								label = text["choose"],
								list = GetProfileList(TSM.db, true, nil),
								value = TSM.db:GetCurrentProfile(),
								callback = function(_,_,value)
										if value ~= TSM.db:GetCurrentProfile() then
											TSM.db:SetProfile(value)
											tg:SelectTab(3)
										end
									end,
							},
						},
					},
					{
						type = "Spacer",
						quantity = 1,
					},
					{
						type = "Label",
						text = text["copy_desc"],
						fontObject = GameFontNormal,
						fullWidth = true,
					},
					{
						type = "Dropdown",
						label = text["copy"],
						list = GetProfileList(TSM.db, true, nil),
						value = "",
						disabled = not GetProfileList(TSM.db, true, nil) and true,
						callback = function(_,_,value)
								if value ~= TSM.db:GetCurrentProfile() then
									TSM.db:CopyProfile(value)
									tg:SelectTab(3)
								end
							end,
					},
					{
						type = "Spacer",
						quantity = 2,
					},
					{
						type = "Label",
						text = text["delete_desc"],
						fontObject = GameFontNormal,
						fullWidth = true,
					},
					{
						type = "Dropdown",
						label = text["delete"],
						list = GetProfileList(TSM.db, true, nil),
						value = "",
						disabled = not GetProfileList(TSM.db, true, nil) and true,
						callback = function(_,_,value)
								if TSM.db:GetCurrentProfile() == value then
									TSMAPI:SetStatusText("Cannot delete currently active profile!")
									return
								end
								TSMAPI:SetStatusText("")
								StaticPopupDialogs["TSMCrafting.DeleteConfirm"].OnAccept = function()
										TSM.db:DeleteProfile(value)
										tg:SelectTab(3)
									end
								StaticPopup_Show("TSMCrafting.DeleteConfirm")
								for i=1, 10 do
									if _G["StaticPopup" .. i] and _G["StaticPopup" .. i].which == "TSMCrafting.DeleteConfirm" then
										_G["StaticPopup" .. i]:SetFrameStrata("TOOLTIP")
										break
									end
								end
							end,
					},
				},
			},
		}
		return page[num]
	end
	
	local offsets = {}
	local previousTab = 1
	
	tg:SetCallback("OnGroupSelected", function(self,_,value)
			if tg.children and tg.children[1] and tg.children[1].localstatus then
				offsets[previousTab] = tg.children[1].localstatus.offset
			end
			tg:ReleaseChildren()
			if value <= 2 then
				TSMAPI:BuildPage(tg, GetTab(value))
			elseif value == 3 then
				TSMAPI:BuildPage(tg, GetTab(value))
			end
			if tg.children and tg.children[1] and tg.children[1].localstatus then
				tg.children[1].localstatus.offset = (offsets[value] or 0)
			end
			previousTab = value
		end)
	tg:SelectTab(1)
end

local updateThrottle = CreateFrame("Frame")
updateThrottle.timeLeft = 1
updateThrottle:SetScript("OnShow", function(self) GUI:UpdateQueue(true, self.mode) end)
updateThrottle:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			self:Hide()
			GUI:UpdateQueue(true, self.mode)
		end
	end)

-- updates the craft queue
function GUI:UpdateQueue(forced, mode)
	if not forced and mode == updateThrottle.lastProfession then
		updateThrottle.timeLeft = 1
		updateThrottle.mode = mode
		updateThrottle:Show()
	else
		GUI.queueInTotal = 0 -- integer representing the number of different items in the craft queue
		updateThrottle.lastProfession = mode
		mode = mode or TSM:GetMode()
		
		wipe(GUI.queueList) -- clear the craft queue so we start fresh
		for itemID, data in pairs(TSM.Data[mode].crafts) do
			if data.intermediateQueued then
				data.queued = data.queued - data.intermediateQueued
				data.intermediateQueued = nil
			end
		end
		
		local function FillQueue(craftID, quantity, level)
			if not TSM.Data[mode].crafts[craftID] or level > 3 then return end
			TSM.Data[mode].crafts[craftID].queued = TSM.Data[mode].crafts[craftID].queued + quantity
			TSM.Data[mode].crafts[craftID].intermediateQueued = (TSM.Data[mode].crafts[craftID].intermediateQueued or 0) + quantity
			for matItemID, q2 in pairs(TSM.Data[mode].crafts[craftID].mats) do
				FillQueue(matItemID, quantity*q2, level+1)
			end
		end
		
		local toDo = {}
		for itemID, data in pairs(TSM.Data[mode].crafts) do
			if data.queued > 0 and data.enabled then
				if not data.intermediateQueued then
					tinsert(toDo, data)
				elseif data.queued > data.intermediateQueued then
					data.queued = data.queued - data.intermediateQueued
					data.intermediateQueued = nil
					tinsert(toDo, data)
				elseif data.intermediateQueued == data.queued then
					data.queued = 0
					data.intermediateQueued = nil
				end
			end
		end
		
		for _,data in ipairs(toDo) do
			for matItemID, quantity in pairs(data.mats) do
				FillQueue(matItemID, quantity*data.queued, 1)
			end
		end
		
		local orderCache = {}
		for itemID, data in pairs(TSM.Data[mode].crafts) do
			if data.intermediateQueued and data.enabled then 
				local bags, bank, auctions = TSM.Data:GetPlayerNum(itemID)
				local numHave = TSM.Data:GetAltNum(itemID) + bags + bank + auctions
				TSM.Data[mode].crafts[itemID].queued = TSM.Data[mode].crafts[itemID].queued - numHave
				TSM.Data[mode].crafts[itemID].intermediateQueued = TSM.Data[mode].crafts[itemID].intermediateQueued - numHave
				if TSM.Data[mode].crafts[itemID].queued < 0 then TSM.Data[mode].crafts[itemID].queued = 0 end
				if TSM.Data[mode].crafts[itemID].intermediateQueued < 0 then TSM.Data[mode].crafts[itemID].intermediateQueued = 0 end
			end
			if data.queued > 0 then -- find crafts that are queued
				-- get some information and add the craft to the craft queue (GUI.queueList)
				local iName = data.name or GetSpellInfo(data.spellID)
				local iQuantity = data.queued
				local iSpellID = data.spellID
				local tempData = {name=iName, quantity=iQuantity, spellID=iSpellID, itemID=itemID}
				tinsert(GUI.queueList, tempData)
				orderCache[iSpellID] = TSM.Crafting:GetOrderIndex(tempData)
				
				-- update our totals
				GUI.queueInTotal = GUI.queueInTotal + 1
			end
		end
		
		
		sort(GUI.queueList, function(a, b)
				local orderA = orderCache[a.spellID] or 0
				local orderB = orderCache[b.spellID] or 0
				if orderA == orderB then
					if a.quantity == b.quantity then
						return a.spellID > b.spellID
					else
						return a.quantity > b.quantity
					end
				else
					return orderA > orderB
				end
			end)
	end
end

function GUI:ClearQueue()
	local mode = TSM:GetMode()
	for _, data in pairs(TSM.Data[mode].crafts) do
		data.queued = 0
		data.intermediateQueued = nil
	end
	
	wipe(GUI.queueList) -- clear the craft queue so we start fresh
	GUI.queueInTotal = 0 -- integer representing the number of different items in the craft queueend
end