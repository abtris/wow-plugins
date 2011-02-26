local TSMAuc = select(2, ...)
local Config = TSMAuc:NewModule("Config", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table
local AceGUI = LibStub("AceGUI-3.0")

local debug = function(...)
	if TSMAUCDEBUG then
		print(...)
	end
end

-- Make sure the item isn't soulbound
local scanTooltip
local resultsCache = {}
function Config:IsSoulbound(bag, slot, itemID)
	if resultsCache[bag .. slot .. itemID] ~= nil then return resultsCache[bag .. slot .. itemID] end
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", "TSMAucScanTooltip", UIParent, "GameTooltipTemplate")
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end
	
	scanTooltip:ClearLines()
	scanTooltip:SetBagItem(bag, slot)
	
	for id=1, scanTooltip:NumLines() do
		local text = _G["TSMAucScanTooltipTextLeft" .. id]
		if text and text:GetText() and text:GetText() == ITEM_SOULBOUND then
			resultsCache[bag .. slot .. itemID] = true
			return true
		end
	end
	
	resultsCache[bag .. slot .. itemID] = nil
	return false
end

function Config:ValidateName(value)
	for name in pairs(TSMAuc.db.profile.groups) do
		if strlower(name) == strlower(value) then
			return false
		end
	end
	for name in pairs(TSMAuc.db.profile.categories) do
		if strlower(name) == strlower(value) then
			return false
		end
	end
	return true
end

function Config:ShouldScan(itemID, isCancel)
	if TSMAuc.db.global.smartScanning then
		if TSMAuc.Config:GetBoolConfigValue(itemID, "disabled") then
			return false
		end
		if isCancel and TSMAuc.Config:GetBoolConfigValue(itemID, "noCancel") then
			return false
		end
	end
		
	return true
end

function Config:GetConfigValue(itemID, key)
	local groupValue
	if key ~= "threshold" and key ~= "fallback" then
		if TSMAuc.itemReverseLookup[itemID] and TSMAuc.db.profile[key][TSMAuc.itemReverseLookup[itemID]] then
			groupValue = TSMAuc.itemReverseLookup[itemID]
		elseif TSMAuc.groupReverseLookup[TSMAuc.itemReverseLookup[itemID] or ""] and TSMAuc.db.profile[key][TSMAuc.groupReverseLookup[TSMAuc.itemReverseLookup[itemID] or ""]] then
			groupValue = TSMAuc.groupReverseLookup[TSMAuc.itemReverseLookup[itemID]]
		elseif TSMAuc.db.profile.groups[itemID] or TSMAuc.db.profile.categories[itemID] then
			-- we got passed a group not an itemID (used by GetGroupMoney method in the options)
			groupValue = itemID
		else
			groupValue = "default"
		end
	else
		local mGroup = TSMAuc.itemReverseLookup[itemID] or itemID
		if TSMAuc.itemReverseLookup[itemID] and TSMAuc.db.profile[key][TSMAuc.itemReverseLookup[itemID]] and TSMAuc.db.profile[key][TSMAuc.itemReverseLookup[itemID]] then
			groupValue = TSMAuc.itemReverseLookup[itemID]
		elseif TSMAuc.groupReverseLookup[TSMAuc.itemReverseLookup[itemID] or ""] and TSMAuc.db.profile[key][TSMAuc.groupReverseLookup[TSMAuc.itemReverseLookup[itemID] or ""]] then
			groupValue = TSMAuc.groupReverseLookup[TSMAuc.itemReverseLookup[itemID]]
		elseif TSMAuc.db.profile.groups[itemID] or TSMAuc.db.profile.categories[itemID] then
			-- we got passed a group not an itemID (used by GetGroupMoney method in the options)
			if TSMAuc.db.profile[key][itemID] then
				groupValue = itemID
			elseif TSMAuc.groupReverseLookup[itemID] and TSMAuc.db.profile[key][TSMAuc.groupReverseLookup[itemID]] then
				groupValue = TSMAuc.groupReverseLookup[itemID]
			else
				groupValue = "default"
			end
		else
			groupValue = "default"
		end
		if TSMAuc.db.profile[key][groupValue] ~= nil then
			TSMAuc.db.profile[key.."PriceMethod"][groupValue] = TSMAuc.db.profile[key.."PriceMethod"][groupValue] or "gold"
		end
		local method = TSMAuc.db.profile[key.."PriceMethod"][groupValue]
		debug(groupValue, method, key)
		if method ~= "gold" then
			local group = TSMAuc.itemReverseLookup[itemID] or (TSMAuc.db.profile.groups[itemID] and itemID)
			debug(group, method, key)
			if not group then return 0 end
			local percent = TSMAuc.db.profile[key.."Percent"][groupValue]
			local value = TSMAuc:GetMarketValue(group, percent, method)
			debug(value, percent)
			return value
		end
	end
	return TSMAuc.db.profile[key][groupValue]
end

function Config:GetBoolConfigValue(itemID, key)
	local val
	local groupName = TSMAuc.itemReverseLookup[itemID]
	local categoryName = TSMAuc.groupReverseLookup[groupName or ""]
	
	val = TSMAuc.db.profile[key][groupName or ""]
	if val == nil and categoryName then
		val = TSMAuc.db.profile[key][categoryName]
	end
	
	if val ~= nil then
		return val
	end
	return TSMAuc.db.profile[key].default
end

function Config:LoadOptions(parent)
	if TSMAuc.db.global.hideAdvanced == nil then
		StaticPopupDialogs["TSMAucHideAdvancedPopup"] = {
			text = L["Would you like to load these options in beginner or advanced mode? If you have not used APM, QA3, or ZA before, beginner is recommended. Your selection can always be changed using the \"Hide advanced options\" checkbox in the \"Options\" page."],
			button1 = L["Beginner"],
			button2 = L["Advanced"],
			timeout = 0,
			whileDead = true,
			hideOnEscape = false,
			OnAccept = function() TSMAuc.db.global.hideAdvanced = true end,
			OnCancel = function() TSMAuc.db.global.hideAdvanced = false end,
		}
		StaticPopup_Show("TSMAucHideAdvancedPopup")
		for i=1, 10 do
			if _G["StaticPopup" .. i] and _G["StaticPopup" .. i].which == "TSMAucHideAdvancedPopup" then
				_G["StaticPopup" .. i]:SetFrameStrata("TOOLTIP")
				break
			end
		end
	end

	local treeGroupStatus = {treewidth = 200, groups={[2]=true}}

	local treeGroup = AceGUI:Create("TSMTreeGroup")
	treeGroup:SetLayout("Fill")
	treeGroup:SetCallback("OnGroupSelected", function(...) Config:SelectTree(...) end)
	treeGroup:SetStatusTable(TSMAuc.db.global.treeGroupStatus)
	parent:AddChild(treeGroup)
	
	Config.treeGroup = treeGroup
	Config:UpdateTree()
	Config.treeGroup:SelectByPath(1)
end

function Config:UpdateTree()
	if not Config.treeGroup then return end
	TSMAuc:UpdateGroupReverseLookup()

	local categoryTreeIndex = {}
	local treeGroups = {{value=1, text="Options"}, {value=2, text=L["Categories / Groups"], children={{value="~", text="|cffaaff11"..L["<Uncategorized Groups>"].."|r", disabled=true, children={}}}}}
	local pageNum
	for categoryName in pairs(TSMAuc.db.profile.categories) do
		tinsert(treeGroups[2].children, {value=categoryName, text="|cff99ff99"..categoryName.."|r"})
		categoryTreeIndex[categoryName] = #(treeGroups[2].children)
	end
	for name in pairs(TSMAuc.db.profile.groups) do
		if TSMAuc.groupReverseLookup[name] then
			local index = categoryTreeIndex[TSMAuc.groupReverseLookup[name]]
			treeGroups[2].children[index].children = treeGroups[2].children[index].children or {}
			tinsert(treeGroups[2].children[index].children, {value=name, text=name})
		else
			tinsert(treeGroups[2].children[1].children, {value=name, text=name})
		end
	end
	sort(treeGroups[2].children, function(a, b) return strlower(a.value) < strlower(b.value) end)
	for _, data in pairs(treeGroups[2].children) do
		if data.children then
			sort(data.children, function(a, b) return strlower(a.value) < strlower(b.value) end)
		end
	end
	Config.treeGroup:SetTree(treeGroups)
end

function Config:SelectTree(treeFrame, _, selection)
	TSMAuc:UpdateGroupReverseLookup()
	treeFrame:ReleaseChildren()
	local content = AceGUI:Create("TSMSimpleGroup")
	content:SetLayout("Fill")
	treeFrame:AddChild(content)

	local selectedParent, selectedChild, selectedSubChild = ("\001"):split(selection)
	if not selectedChild or tonumber(selectedChild) == 0 then
		if tonumber(selectedParent) == 1 then
			local offsets, previousTab = {}, 1
			local tg = AceGUI:Create("TSMTabGroup")
			tg:SetLayout("Fill")
			tg:SetFullHeight(true)
			tg:SetFullWidth(true)
			tg:SetTabs({{value=1, text=L["General"]}, {value=2, text=L["Whitelist"]}, {value=3, text="Profiles"}})
			tg:SetCallback("OnGroupSelected", function(self,_,value)
				if tg.children and tg.children[1] and tg.children[1].localstatus then
					offsets[previousTab] = tg.children[1].localstatus.offset
				end
				tg:ReleaseChildren()
				content:DoLayout()
				
				if value == 1 then
					Config:DrawGeneralOptions(tg)
				elseif value == 2 then
					Config:DrawWhitelist(tg)
				elseif value == 3 then
					Config:DrawProfiles(tg)
				end
				
				if tg.children and tg.children[1] and tg.children[1].localstatus then
					tg.children[1].localstatus.offset = (offsets[value] or 0)
				end
				previousTab = value
			end)
			content:AddChild(tg)
			tg:SelectTab(1)
		else
			local offsets, previousTab = {}, 1
			local tg = AceGUI:Create("TSMTabGroup")
			tg:SetLayout("Fill")
			tg:SetFullHeight(true)
			tg:SetFullWidth(true)
			tg:SetTabs({{value=1, text=L["Auction Defaults"]}, {value=2, text=L["Create Category / Group"]}})
			tg:SetCallback("OnGroupSelected", function(self,_,value)
				if tg.children and tg.children[1] and tg.children[1].localstatus then
					offsets[previousTab] = tg.children[1].localstatus.offset
				end
				tg:ReleaseChildren()
				content:DoLayout()
				
				if value == 1 then
					Config:DrawGroupGeneral(tg, "default")
				elseif value == 2 then
					Config:DrawItemGroups(tg)
				end
				
				if tg.children and tg.children[1] and tg.children[1].localstatus then
					tg.children[1].localstatus.offset = (offsets[value] or 0)
				end
				previousTab = value
			end)
			content:AddChild(tg)
			tg:SelectTab(1)
		end
	else
		selectedChild = strlower(selectedSubChild or selectedChild)
		local offsets, previousTab = {}, 1
		local isCategory = TSMAuc.db.profile.categories[selectedChild]
		
		local groupTabs = {
			{value=3, text=L["Add/Remove Items"]},
			{value=1, text=L["Group Overrides"]},
			{value=2, text=L["Management"]},
		}
		local categoryTabs = {
			{value=3, text=L["Add/Remove Groups"]},
			{value=1, text=L["Category Overrides"]},
			{value=2, text=L["Management"]},
		}
		
		local tg = AceGUI:Create("TSMTabGroup")
		tg:SetLayout("Fill")
		tg:SetFullHeight(true)
		tg:SetFullWidth(true)
		tg:SetTabs(isCategory and categoryTabs or groupTabs)
		tg:SetCallback("OnGroupSelected", function(self,_,value)
			if tg.children and tg.children[1] and tg.children[1].localstatus then
				offsets[previousTab] = tg.children[1].localstatus.offset
			end
			tg:ReleaseChildren()
			content:DoLayout()
			Config:UnregisterAllEvents()
			
			if value == 1 then
				Config:DrawGroupGeneral(tg, selectedChild)
			elseif value == 2 then
				if isCategory then
					Config:DrawCategoryManagement(tg, selectedChild)
				else
					Config:DrawGroupManagement(tg, selectedChild)
				end
			elseif value == 3 then
				if isCategory then
					Config:DrawAddRemoveGroup(tg, selectedChild)
				else
					Config:RegisterEvent("BAG_UPDATE", function() tg:SelectTab(3) end)
					Config:DrawAddRemoveItem(tg, selectedChild)
				end
			end
			
			if tg.children and tg.children[1] and tg.children[1].localstatus then
				tg.children[1].localstatus.offset = (offsets[value] or 0)
			end
			previousTab = value
		end)
		content:AddChild(tg)
		tg:SelectTab(3)
	end
end

function Config:DrawGeneralOptions(container)
	local macroOptions = {down=true, up=true, ctrl=true, shift=false, alt=false}

	local page = {
		{
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General"],
					children = {
						{
							type = "CheckBox",
							value = TSMAuc.db.global.hideHelp,
							label = L["Hide help text"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.hideHelp = value end,
							tooltip = L["Hides auction setting help text throughout the options."],
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.global.hideAdvanced,
							label = L["Hide advanced options"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.hideAdvanced = value end,
							tooltip = L["Hides advanced auction settings. Provides for an easier learning curve for new users."],
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.global.hideGray,
							label = L["Hide poor quality items"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.hideGray = value end,
							tooltip = L["Hides all poor (gray) quality items from the 'Add items' pages."],
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.global.smartScanning,
							label = L["Smart scanning"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.smartScanning = value end,
							tooltip = L["Prevents the scanning of items in groups that are disabled (for post and cancel scans) or set to not auto cancel (for cancel scans only)."],
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.global.enableSounds,
							label = L["Enable sounds"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.enableSounds = value end,
							tooltip = L["Plays the ready check sound when a post / cancel scan is complete and items are ready to be posting / canceled (the gray bar is all the way across)."],
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.global.blockAuc,
							label = L["Block Auctioneer while scanning"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.blockAuc = value end,
							tooltip = L["Prevents Auctioneer from scanning while Auctioning is doing a scan."],
						},
					}
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Canceling"],
					children = {
						{
							type = "CheckBox",
							value = TSMAuc.db.global.cancelWithBid,
							label = L["Cancel auctions with bids"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.cancelWithBid = value end,
							tooltip = L["Will cancel auctions even if they have a bid on them, you will take an additional gold cost if you cancel an auction with bid."],
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.global.smartCancel,
							label = L["Smart cancelling"],
							relativeWidth = 0.5,
							callback = function(_,_,value) TSMAuc.db.global.smartCancel = value end,
							tooltip = L["Disables cancelling of auctions with a market price below the threshold, also will cancel auctions if you are the only one with that item up and you can relist it for more."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Macro Help"],
					children = {
						{
							type = "Label",
							text = format(L["There are two ways of making clicking the Post / Cancel Auction button easier. You can put %s and %s in a macro (on separate lines), or use the utility below to have a macro automatically made and bound to scrollwheel for you."], "\"|cffffbb00/click TSMAucPostButton|r\"", "\"|cffffbb00/click TSMAucCancelButton|r\""),
							fontObject = GameFontNormal,
							relativeWidth = 1,
						},
						{
							type = "HeadingLine"
						},
						{
							type = "Label",
							text = L["ScrollWheel Direction (both recommended):"],
							relativeWidth = 0.59,
							fontObject = GameFontNormal,
						},
						{
							type = "CheckBox",
							label = L["Up"],
							relativeWidth = 0.20,
							value = macroOptions.up,
							callback = function(_,_,value) macroOptions.up = value end,
							tooltip = L["Will bind ScrollWheelUp (plus modifiers below) to the macro created."],
						},
						{
							type = "CheckBox",
							label = L["Down"],
							relativeWidth = 0.20,
							value = macroOptions.down,
							callback = function(_,_,value) macroOptions.down = value end,
							tooltip = L["Will bind ScrollWheelDown (plus modifiers below) to the macro created."],
						},
						{
							type = "Label",
							text = L["Modifiers:"],
							relativeWidth = 0.24,
							fontObject = GameFontNormal,
						},
						{
							type = "CheckBox",
							label = L["ALT"],
							relativeWidth = 0.25,
							value = macroOptions.alt,
							callback = function(_,_,value) macroOptions.alt = value end,
						},
						{
							type = "CheckBox",
							label = L["CTRL"],
							relativeWidth = 0.25,
							value = macroOptions.ctrl,
							callback = function(_,_,value) macroOptions.ctrl = value end,
						},
						{
							type = "CheckBox",
							label = L["SHIFT"],
							relativeWidth = 0.25,
							value = macroOptions.shift,
							callback = function(_,_,value) macroOptions.shift = value end,
						},
						{
							type = "Button",
							relativeWidth = 1,
							text = L["Create Macro and Bind ScrollWheel (with selected options)"],
							callback = function()
									DeleteMacro("TSMAucBClick")
									CreateMacro("TSMAucBClick", 1, "/click TSMAucCancelButton\n/click TSMAucPostButton")
									
									local modString = ""
									if macroOptions.ctrl then
										modString = modString .. "CTRL-"
									end
									if macroOptions.alt then
										modString = modString .. "ALT-"
									end
									if macroOptions.shift then
										modString = modString .. "SHIFT-"
									end
									
									local bindingNum = GetCurrentBindingSet()
									bindingNum = (bindingNum == 1) and 2 or 1
									
									if macroOptions.up then
										SetBinding(modString.."MOUSEWHEELUP", nil, bindingNum)
										SetBinding(modString.."MOUSEWHEELUP", "MACRO TSMAucBClick", bindingNum)
									end
									if macroOptions.down then
										SetBinding(modString.."MOUSEWHEELDOWN", nil, bindingNum)
										SetBinding(modString.."MOUSEWHEELDOWN", "MACRO TSMAucBClick", bindingNum)
									end
									SaveBindings(2)
									
									TSMAuc:Print(L["Macro created and keybinding set!"])
								end,
						},
					},
				},
			},
		}
	}
	
	if not AucAdvanced then
		for i, v in ipairs(page[1].children[1].children) do
			if v.label == L["Block Auctioneer while scanning"] then
				tremove(page[1].children[1].children, i)
				break
			end
		end
	end
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawGroupGeneral(container, group)
	local isDefaultPage = (group == "default")
	local overrideTooltip = "|cffff8888"..L["Right click to override this setting."].."|r"
	local unoverrideTooltip = "\n\n|cffff8888"..L["Right click to remove the override of this setting."].."|r"
	if isDefaultPage then
		overrideTooltip = ""
		unoverrideTooltip = ""
	end
	TSMAuc:UpdateGroupReverseLookup()
	
	local function GetInfo(num)
		local function GetValue(key)
			local categoryName = TSMAuc.groupReverseLookup[group]
			return TSMAuc.db.profile[key][group] or (categoryName and TSMAuc.db.profile[key][categoryName]) or TSMAuc.db.profile[key].default
		end
		
		local color = "|cfffed000"
	
		if num == 1 then
			local stacksOver = color..GetValue("ignoreStacksOver").."|r"
			local stacksUnder = color..GetValue("ignoreStacksUnder").."|r"
			local maxPriceGap = color..(GetValue("priceThreshold")*100).."%%|r"
			local noCancel = GetValue("noCancel")
			local disabled = GetValue("disabled")
			
			if disabled then
				return format(L["Items in this group will not be posted or canceled automatically."])
			elseif noCancel then
				return format(L["When posting, ignore auctions with more than %s items or less than %s items in them. Ingoring the lowest auction if the price difference between the lowest two auctions is more than %s. Items in this group will not be canceled automatically."], stacksOver, stacksUnder, maxPriceGap)
			else
				return format(L["When posting and canceling, ignore auctions with more than %s items or less than %s items in them. Ingoring the lowest auction if the price difference between the lowest two auctions is more than %s."], stacksOver, stacksUnder, maxPriceGap)
			end
		elseif num == 2 then
			local duration = color..GetValue("postTime").."|r"
			local perAuction = color..GetValue("perAuction").."|r"
			local postCap = color..GetValue("postCap").."|r"
			local perAuctionIsCap = GetValue("perAuctionIsCap")
		
			if perAuctionIsCap and not TSMAuc.db.global.hideAdvanced then
				return format(L["Auctions will be posted for %s hours in stacks of up to %s. A maximum of %s auctions will be posted."], duration, perAuction, postCap)
			else
				return format(L["Auctions will be posted for %s hours in stacks of %s. A maximum of %s auctions will be posted."], duration, perAuction, postCap)
			end
		elseif num == 3 then
			local undercut = TSMAuc:FormatTextMoney(GetValue("undercut"))
			local bidPercent = color..(GetValue("bidPercent")*100).."|r"
		
			return format(L["Auctioning will undercut your competition by %s. When posting, the bid of your auctions will be set to %s percent of the buyout."], undercut, bidPercent)
		elseif num == 4 then
			local threshold = TSMAuc:FormatTextMoney(GetValue("threshold"))
			
			if TSMAuc.db.global.hideAdvanced then
				return format(L["Auctioning will never post your auctions for below %s."], threshold)
			else
				return format(L["Auctioning will follow the 'Advanced Price Settings' when the market goes below %s."], threshold)
			end
		elseif num == 5 then
			local fallback = TSMAuc:FormatTextMoney(GetValue("fallback"))
			local fallbackCap = TSMAuc:FormatTextMoney(GetValue("fallbackCap")*GetValue("fallback"))
		
			if TSMAuc.db.global.hideAdvanced then
				return format(L["Auctioning will post at %s when there are no other auctions up."], fallback)
			else
				return format(L["Auctioning will post at %s when you are the only one posting below %s."], fallback, fallbackCap)
			end
		elseif num == 6 then
			local reset = GetValue("reset")
			local fallback = TSMAuc:FormatTextMoney(GetValue("fallback"))
			local threshold = TSMAuc:FormatTextMoney(GetValue("threshold"))
			local resetPrice = TSMAuc:FormatTextMoney(GetValue("resetPrice"))
			
			if reset == "none" then
				return format(L["Auctions will not be posted when the market goes below your threshold."])
			elseif reset == "threshold" then
				return format(L["Auctions will be posted at your threshold price of %s when the market goes below your threshold."], threshold)
			elseif reset == "fallback" then
				return format(L["Auctions will be posted at your fallback price of %s when the market goes below your threshold."], fallback)
			elseif reset == "custom" then
				return format(L["Auctions will be posted at %s when the market goes below your threshold."], resetPrice)
			end
		end
	end
	
	local GetGroupMoney
	
	local function SetGroupOverride(key, value, widget)
		debug(key, value)
		if not value then
			TSMAuc.db.profile[key][group] = nil
		else
			TSMAuc.db.profile[key][group] = TSMAuc.db.profile[key].default
		end
		
		widget:SetDisabled(not value)
		if widget.type == "TSMEditBox" then
			widget:SetText(GetGroupMoney(key))
		elseif widget.type == "TSMSlider" then
			widget:SetValue(TSMAuc.db.profile[key][group] or TSMAuc.db.profile[key].default)
			widget.editbox:ClearFocus()
		end
	end

	local function GetGroupOverride(key)
		if isDefaultPage then return false end
		
		return TSMAuc.db.profile[key][group] ~= nil
	end
	
	local function SetGroupMoney(key, value, editBox)
		local gold = tonumber(string.match(value, "([0-9]+)|c([0-9a-fA-F]+)g|r") or string.match(value, "([0-9]+)g"))
		local silver = tonumber(string.match(value, "([0-9]+)|c([0-9a-fA-F]+)s|r") or string.match(value, "([0-9]+)s"))
		local copper = tonumber(string.match(value, "([0-9]+)|c([0-9a-fA-F]+)c|r") or string.match(value, "([0-9]+)c"))
		local percent = tonumber(string.match(value, "([0-9]+)|c([0-9a-fA-F]+)%%|r") or string.match(value, "([0-9]+)%%"))
		local goldMethod = TSMAuc.db.profile[key.."PriceMethod"] and TSMAuc.db.profile[key.."PriceMethod"][group] == "gold" or not TSMAuc.db.profile[key.."PriceMethod"]
		debug(percent, goldMethod)
		
		if not gold and not silver and not copper and goldMethod then
			TSMAPI:SetStatusText(L["Invalid monney format entered, should be \"#g#s#c\", \"25g4s50c\" is 25 gold, 4 silver, 50 copper."])
			editBox:SetFocus()
			return
		elseif not percent and TSMAuc.db.profile[key.."PriceMethod"] and TSMAuc.db.profile[key.."PriceMethod"][group] ~= "gold" then
			TSMAPI:SetStatusText(L["Invalid percent format entered, should be \"#%\", \"105%\" is 105 percent."])
			editBox:SetFocus()
			return
		elseif gold or silver or copper then
			-- Convert it all into copper
			copper = (copper or 0) + ((gold or 0) * COPPER_PER_GOLD) + ((silver or 0) * COPPER_PER_SILVER)
			TSMAuc.db.profile[key][group] = copper
		elseif percent then
			TSMAuc.db.profile[key.."Percent"][group] = percent/100
			--TSMAuc.db.profile[key][group] = TSMAuc:GetMarketValue(key, group)*TSMAuc.db.profile[key.."Percent"][group]
		end
		
		editBox:SetText(GetGroupMoney(key))
		TSMAPI:SetStatusText()
		container:SelectTab(1)
	end

	GetGroupMoney = function(key)
		if not TSMAuc.db.profile[key] then print(key) end
		local groupValue = Config:GetConfigValue(group, key)
		local defaultValue = TSMAuc.db.profile[key].default
		local extraText = ""
		
		if key ~= "undercut" and Config:GetConfigValue(group, key.."PriceMethod") ~= "gold" then
			local percent = Config:GetConfigValue(group, key.."Percent")
			if percent then
				extraText = " ("..(Config:GetConfigValue(group, key.."Percent")*100).."%)"
			else
				percent = floor(((Config:GetConfigValue(group, key) or 0)/TSMAuc:GetMarketValue(group, nil, Config:GetConfigValue(group, key.."PriceMethod")))*1000 + 0.5)/10
				TSMAuc.db.profile[key.."Percent"][group] = percent/100
				extraText = " ("..percent.."%)"
			end
			
			-- if it's not a group then it's either a category or default in which case just return the percent
			if not TSMAuc.db.profile.groups[group] then
				return percent*100 .. "%"
			end
		end
		
		-- if we aren't overriding, the option will be disabled so strip color codes so it all grays out
		if group ~= "general" and TSMAuc:FormatTextMoney(groupValue) == nil then
			return TSMAuc:FormatTextMoney(defaultValue, nil, true) .. extraText
		end
		return TSMAuc:FormatTextMoney(groupValue) .. extraText
	end
	
	local priceMethodList = {["gold"]=L["Fixed Gold Amount"]}
	if select(4, GetAddOnInfo("Auc-Advanced")) == 1 then
		priceMethodList["aucmarket"]=L["% of Auctioneer Market Value"]
		priceMethodList["aucappraiser"]=L["% of Auctioneer Appraiser"]
		priceMethodList["aucminbuyout"]=L["% of Auctioneer Minimum Buyout"]
	end
	if select(4, GetAddOnInfo("TradeSkillMaster_AuctionDB")) == 1 then
		priceMethodList["dbmarket"]=L["% of AuctionDB Market Value"]
		priceMethodList["dbminbuyout"]=L["% of AuctionDB Minimum Buyout"]
	end
	if select(4, GetAddOnInfo("TradeSkillMaster_Crafting")) == 1 then
		priceMethodList["crafting"]=L["% of Crafting cost"]
	end
	if select(4, GetAddOnInfo("ItemAuditor")) == 1 then
		priceMethodList["iacost"]=L["% of ItemAuditor cost"]
	end

	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Help"],
					hidden = not isDefaultPage,
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = L["The below are fallback settings for groups, if you do not override a setting in a group then it will use the settings below.\n\nWarning! All auction prices are per item, not overall. If you set it to post at a fallback of 1g and you post in stacks of 20 that means the fallback will be 20g."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["General Settings"],
					hidden = TSMAuc.db.global.hideAdvanced,
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = GetInfo(1),
							hidden = TSMAuc.db.global.hideHelp,
						},
						{
							type = "HeadingLine",
							hidden = TSMAuc.db.global.hideHelp,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.ignoreStacksUnder[group] or TSMAuc.db.profile.ignoreStacksUnder.default,
							label = L["Ignore stacks under"],
							isPercent = false,
							min = 1,
							max = 1000,
							step = 1,
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.ignoreStacksUnder[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									TSMAuc.db.profile.ignoreStacksUnder[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(1)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("ignoreStacksUnder", value, self) end,
							tooltip = L["Items that are stacked beyond the set amount are ignored when calculating the lowest market price."]..unoverrideTooltip,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.ignoreStacksOver[group] or TSMAuc.db.profile.ignoreStacksOver.default,
							label = L["Ignore stacks over"],
							isPercent = false,
							min = 1,
							max = 1000,
							step = 1,
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.ignoreStacksOver[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									TSMAuc.db.profile.ignoreStacksOver[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(1)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("ignoreStacksOver", value, self) end,
							tooltip = L["Items that are stacked beyond the set amount are ignored when calculating the lowest market price."]..unoverrideTooltip,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.priceThreshold[group] or TSMAuc.db.profile.priceThreshold.default,
							label = L["Maximum price gap"],
							isPercent = true,
							min = 0.1,
							max = 10,
							step = 0.05,
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.priceThreshold[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									value = floor(value*100 + 0.5)/100
									TSMAuc.db.profile.priceThreshold[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(1)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("priceThreshold", value, self) end,
							tooltip = L["How much of a difference between auction prices should be allowed before posting at the second highest value.\n\nFor example. If Apple is posting Runed Scarlet Ruby at 50g, Orange posts one at 30g and you post one at 29g, then Oranges expires. If you set price threshold to 30% then it will cancel yours at 29g and post it at 49g next time because the difference in price is 42% and above the allowed threshold."]..unoverrideTooltip,
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.profile.noCancel[group] or TSMAuc.db.profile.noCancel.default,
							label = L["Disable auto cancelling"],
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.noCancel[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(_,_,value) TSMAuc.db.profile.noCancel[group] = value container:SelectTab(1) end,
							onRightClick = function(self, value) SetGroupOverride("noCancel", value, self) end,
							tooltip = L["Disable automatically cancelling of items in this group if undercut."]..unoverrideTooltip,
							hidden = isDefaultPage,
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.profile.disabled[group] or TSMAuc.db.profile.disabled.default,
							label = L["Disable posting and canceling"],
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.disabled[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(_,_,value) TSMAuc.db.profile.disabled[group] = value container:SelectTab(1) end,
							onRightClick = function(self, value) SetGroupOverride("disabled", value, self) end,
							tooltip = L["Completely disables this group. This group will not be scanned for and will be effectively invisible to Auctioning."]..unoverrideTooltip,
							hidden = isDefaultPage,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "Flow",
					title = L["Post Settings (Quantity / Duration)"],
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = GetInfo(2),
							hidden = TSMAuc.db.global.hideHelp,
						},
						{
							type = "HeadingLine",
							hidden = TSMAuc.db.global.hideHelp,
						},
						{
							type = "Dropdown",
							label = L["Post time"],
							relativeWidth = 0.48,
							list = {[12] = L["12 hours"], [24] = L["24 hours"], [48] = L["48 hours"]},
							value = TSMAuc.db.profile.postTime[group] or TSMAuc.db.profile.postTime.default,
							disabled = TSMAuc.db.profile.postTime[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(_,_,value) TSMAuc.db.profile.postTime[group] = value container:SelectTab(1) end,
							onRightClick = function(self, value) SetGroupOverride("postTime", value, self) end,
							tooltip = L["How long auctions should be up for."]..unoverrideTooltip,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.postCap[group] or TSMAuc.db.profile.postCap.default,
							label = L["Post cap"],
							isPercent = false,
							min = 1,
							max = 500,
							step = 1,
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.postCap[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									TSMAuc.db.profile.postCap[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(2)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("postCap", value, self) end,
							tooltip = L["How many auctions at the lowest price tier can be up at any one time."]..unoverrideTooltip,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.perAuction[group] or TSMAuc.db.profile.perAuction.default,
							label = L["Per auction"],
							isPercent = false,
							relativeWidth = 0.48,
							min = 1,
							max = 1000,
							step = 1,
							disabled = TSMAuc.db.profile.perAuction[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									TSMAuc.db.profile.perAuction[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(2)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("perAuction", value, self) end,
							tooltip = L["How many items should be in a single auction, 20 will mean they are posted in stacks of 20."]..unoverrideTooltip,
						},
						{
							type = "CheckBox",
							value = TSMAuc.db.profile.perAuctionIsCap[group] or TSMAuc.db.profile.perAuctionIsCap.default,
							label = L["Use per auction as cap"],
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.perAuctionIsCap[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(_,_,value) TSMAuc.db.profile.perAuctionIsCap[group] = value container:SelectTab(1) end,
							onRightClick = function(self, value) SetGroupOverride("perAuctionIsCap", value, self) end,
							tooltip = L["If you don't have enough items for a full post, it will post with what you have."]..unoverrideTooltip,
							hidden = TSMAuc.db.global.hideAdvanced,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["General Price Settings (Undercut / Bid)"],
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = GetInfo(3),
							hidden = TSMAuc.db.global.hideHelp,
						},
						{
							type = "HeadingLine",
							hidden = TSMAuc.db.global.hideHelp,
						},
						{
							type = "EditBox",
							value = GetGroupMoney("undercut"),
							label = L["Undercut by"],
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.undercut[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self, _, value) SetGroupMoney("undercut", value, self) end,
							onRightClick = function(self, value) SetGroupOverride("undercut", value, self) end,
							tooltip = L["How much to undercut other auctions by, format is in \"#g#s#c\" but can be in any order, \"50g30s\" means 50 gold, 30 silver and so on."]..unoverrideTooltip,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.bidPercent[group] or TSMAuc.db.profile.bidPercent.default,
							label = L["Bid percent"],
							relativeWidth = 0.48,
							isPercent = true,
							min = 0,
							max = 1,
							step = 0.05,
							disabled = TSMAuc.db.profile.bidPercent[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									value = floor(value*100 + 0.5)/100
									TSMAuc.db.profile.bidPercent[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(3)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("bidPercent", value, self) end,
							tooltip = L["Percentage of the buyout as bid, if you set this to 90% then a 100g buyout will have a 90g bid."]..unoverrideTooltip,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Minimum Price Settings (Threshold)"],
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = GetInfo(4),
							hidden = TSMAuc.db.global.hideHelp
						},
						{
							type = "HeadingLine",
							hidden = TSMAuc.db.global.hideHelp
						},
						{
							type = "EditBox",
							value = GetGroupMoney("threshold"),
							label = L["Price threshold"],
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.threshold[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self, _, value) SetGroupMoney("threshold", value, self) end,
							onRightClick = function(self, value)
									SetGroupOverride("threshold", value, self)
									if TSMAuc.db.profile.thresholdPriceMethod.default == "gold" then
										TSMAuc.db.profile.thresholdPercent[group] = nil
									else
										TSMAuc.db.profile.thresholdPercent[group] = TSMAuc.db.profile.thresholdPercent.default
									end
									TSMAuc.db.profile.thresholdPriceMethod[group] = TSMAuc.db.profile.thresholdPriceMethod.default
									container:SelectTab(1)
								end,
							tooltip = L["How low the market can go before an item should no longer be posted. The minimum price you want to post an item for."]..unoverrideTooltip,
						},
						{
							type = "Dropdown",
							label = L["Set threshold as a"],
							relativeWidth = 0.48,
							list = priceMethodList,
							value = TSMAuc.db.profile.thresholdPriceMethod[group] or TSMAuc.db.profile.thresholdPriceMethod.default,
							disabled = TSMAuc.db.profile.threshold[group] == nil,
							callback = function(self,_,value)
									if value == "gold" then
										TSMAuc.db.profile.thresholdPercent[group] = nil
									elseif TSMAuc.db.profile.thresholdPriceMethod[group] ~= "gold" then
										TSMAuc.db.profile.thresholdPriceMethod[group] = value
										TSMAuc.db.profile.threshold[group] = Config:GetConfigValue(group, "threshold")
									end
									TSMAuc.db.profile.thresholdPriceMethod[group] = value
									local siblings = self.parent.children
									for i, v in pairs(siblings) do
										if v == self then
											siblings[i-1]:SetText(GetGroupMoney("threshold"))
											break
										end
									end
									container:SelectTab(1)
								end,
							tooltip = L["You can set a fixed threshold price for this group, or have the threshold price be automatically calculated to a percentage of a value. If you have multiple different items in this group and use a percentage, the highest value will be used for the entire group."],
							hidden = TSMAuc.db.global.hideAdvanced,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Maximum Price Settings (Fallback)"],
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = GetInfo(5),
							hidden = TSMAuc.db.global.hideHelp
						},
						{
							type = "HeadingLine",
							hidden = TSMAuc.db.global.hideHelp
						},
						{
							type = "EditBox",
							value = GetGroupMoney("fallback"),
							label = L["Fallback price"],
							relativeWidth = 0.48,
							disabled = TSMAuc.db.profile.fallback[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self, _, value) SetGroupMoney("fallback", value, self) end,
							onRightClick = function(self, value)
									SetGroupOverride("fallback", value, self)
									if not value then
										TSMAuc.db.profile.fallbackPriceMethod[group] = nil
									else
										TSMAuc.db.profile.fallbackPriceMethod[group] = TSMAuc.db.profile.fallbackPriceMethod.default
									end
									if TSMAuc.db.profile.fallbackPriceMethod.default == "gold" then
										TSMAuc.db.profile.fallbackPercent[group] = nil
									else
										TSMAuc.db.profile.fallbackPercent[group] = TSMAuc.db.profile.fallbackPercent.default
									end
									TSMAuc.db.profile.fallbackPriceMethod[group] = TSMAuc.db.profile.fallbackPriceMethod.default
									container:SelectTab(1)
								end,
							tooltip = L["Price to fallback too if there are no other auctions up, the lowest market price is too high."]..unoverrideTooltip,
						},
						{
							type = "Dropdown",
							label = L["Set fallback as a"],
							relativeWidth = 0.48,
							list = priceMethodList,
							value = TSMAuc.db.profile.fallbackPriceMethod[group] or TSMAuc.db.profile.fallbackPriceMethod.default,
							disabled = TSMAuc.db.profile.fallback[group] == nil,
							callback = function(self,_,value)
									if value == "gold" then
										TSMAuc.db.profile.fallbackPercent[group] = nil
									elseif TSMAuc.db.profile.fallbackPriceMethod[group] ~= "gold" then
										TSMAuc.db.profile.fallbackPriceMethod[group] = value
										TSMAuc.db.profile.fallback[group] = Config:GetConfigValue(group, "fallback")
									end
									TSMAuc.db.profile.fallbackPriceMethod[group] = value
									local siblings = self.parent.children
									for i, v in pairs(siblings) do
										if v == self then
											siblings[i-1]:SetText(GetGroupMoney("fallback"))
											break
										end
									end
									container:SelectTab(1)
								end,
							tooltip = L["You can set a fixed fallback price for this group, or have the fallback price be automatically calculated to a percentage of a value. If you have multiple different items in this group and use a percentage, the highest value will be used for the entire group."],
							hidden = TSMAuc.db.global.hideAdvanced,
						},
						{
							type = "Slider",
							value = TSMAuc.db.profile.fallbackCap[group] or TSMAuc.db.profile.fallbackCap.default,
							label = L["Maximum price"],
							relativeWidth = 0.48,
							isPercent = true,
							min = 1,
							max = 10,
							step = 0.1,
							disabled = TSMAuc.db.profile.fallbackCap[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									value = floor(value*100 + 0.5)/100
									TSMAuc.db.profile.fallbackCap[group] = value
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(5)) end
								end,
							onRightClick = function(self, value) SetGroupOverride("fallbackCap", value, self) end,
							tooltip = L["If the market price is above fallback price * maximum price, items will be posted at the fallback * maximum price instead.\n\nEffective for posting prices in a sane price range when someone is posting an item at 5000g when it only goes for 100g."]..unoverrideTooltip,
							hidden = TSMAuc.db.global.hideAdvanced,
						},
					},
				},
				{
					type = "Spacer",
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Advanced Price Settings (Market Reset)"],
					hidden = TSMAuc.db.global.hideAdvanced,
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = GetInfo(6),
							hidden = TSMAuc.db.global.hideHelp
						},
						{
							type = "HeadingLine",
							hidden = TSMAuc.db.global.hideHelp
						},
						{
							type = "Dropdown",
							label = "Reset Method",
							relativeWidth = 0.48,
							list = {["none"]=L["Don't Post Items"], ["threshold"]=L["Post at Threshold"], ["fallback"]=L["Post at Fallback"], ["custom"]=L["Custom Value"]},
							value = TSMAuc.db.profile.reset[group] or TSMAuc.db.profile.reset.default,
							disabled = TSMAuc.db.profile.reset[group] == nil,
							disabledTooltip = overrideTooltip,
							callback = function(self,_,value)
									local oldValue = TSMAuc.db.profile.reset[group]
									TSMAuc.db.profile.reset[group] = value
									if value == "custom" or oldValue == "custom" then
										TSMAuc.db.profile.resetPrice[group] = (TSMAuc.db.profile.threshold[group] or TSMAuc.db.profile.threshold.default)
										container:SelectTab(1)
									end
									if value ~= "custom" then
										TSMAuc.db.profile.resetPrice[group] = nil
									end
									container:SelectTab(1)
								end,
							onRightClick = function(self, value) SetGroupOverride("reset", value, self) container:SelectTab(1) end,
							tooltip = L["This dropdown determines what Auctioning will do when the market for an item goes below your threshold value. You can either not post the items or post at your fallback/threshold/a custom value."]
						},
						{
							type = "Slider",
							value = (TSMAuc.db.profile.resetPrice[group] or TSMAuc.db.profile.resetPrice.default or 50000)/COPPER_PER_GOLD,
							label = L["Custom Reset Price (gold)"],
							relativeWidth = 0.48,
							min = (TSMAuc.db.profile.threshold[group] or TSMAuc.db.profile.threshold.default)*0.5/COPPER_PER_GOLD,
							max = (TSMAuc.db.profile.fallback[group] or TSMAuc.db.profile.fallback.default)*5/COPPER_PER_GOLD,
							step = 1,
							callback = function(self,_,value)
									TSMAuc.db.profile.resetPrice[group] = value*COPPER_PER_GOLD
									if not TSMAuc.db.global.hideHelp then self.parent.children[1]:SetText(GetInfo(6)) end
								end,
							tooltip = L["Custom market reset price. If the market goes below your threshold, items will be posted at this price."],
							hidden = TSMAuc.db.profile.reset[group] ~= "custom",
						},
					},
				},
			},
		},
	}
	
	for i=#(page[1].children), 1, -1 do
		if page[1].children[i].hidden then
			tremove(page[1].children, i)
		elseif page[1].children[i].onRightClick and isDefaultPage then
			page[1].children[i].onRightClick = nil
			page[1].children[i].disabledTooltip = nil
		elseif page[1].children[i].children then
			for k=#(page[1].children[i].children), 1, -1 do
				if page[1].children[i].children[k].hidden then
					tremove(page[1].children[i].children, k)
				elseif page[1].children[i].children[k].onRightClick and isDefaultPage then
					page[1].children[i].children[k].onRightClick = nil
					page[1].children[i].children[k].disabledTooltip = nil
				end
			end
		end
	end
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawProfiles(container)
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
		current = L["Current Profile:"] .. " |cff99ffff" .. TSMAuc.db:GetCurrentProfile() .. "|r",
	}
	
	-- Popup Confirmation Window used in this module
	StaticPopupDialogs["TSMAucProfiles.DeleteConfirm"] = StaticPopupDialogs["TSMAucProfiles.DeleteConfirm"] or {
		text = L["Are you sure you want to delete the selected profile?"],
		button1 = L["Accept"],
		button2 = L["Cancel"],
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		OnCancel = false,
		-- OnAccept defined later
	}
	
	-- Returns a list of all the current profiles with common and nocurrent modifiers.
	-- This code taken from AceDBOptions-3.0.lua
	local function GetProfileList(db, common, nocurrent)
		local profiles = {}
		local tmpprofiles = {}
		local defaultProfiles = {["Default"] = L["Default"]}
		
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
	
	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "Label",
					text = "TradeSkillMaster_Auctioning" .. "\n",
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
							callback = function() TSMAuc.db:ResetProfile() end,
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
									TSMAuc.db:SetProfile(value)
									container:SelectTab(2)
								end,
						},
						{
							type = "Dropdown",
							label = text["choose"],
							list = GetProfileList(TSMAuc.db, true, nil),
							value = TSMAuc.db:GetCurrentProfile(),
							callback = function(_,_,value)
									if value ~= TSMAuc.db:GetCurrentProfile() then
										TSMAuc.db:SetProfile(value)
										container:SelectTab(2)
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
					list = GetProfileList(TSMAuc.db, true, nil),
					value = "",
					disabled = not GetProfileList(TSMAuc.db, true, nil) and true,
					callback = function(_,_,value)
							if value ~= TSMAuc.db:GetCurrentProfile() then
								TSMAuc.db:CopyProfile(value)
								container:SelectTab(2)
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
					list = GetProfileList(TSMAuc.db, true, nil),
					value = "",
					disabled = not GetProfileList(TSMAuc.db, true, nil) and true,
					callback = function(_,_,value)
							StaticPopupDialogs["TSMAucProfiles.DeleteConfirm"].OnAccept = function()
									TSMAuc.db:DeleteProfile(value)
									container:SelectTab(2)
								end
							StaticPopup_Show("TSMAucProfiles.DeleteConfirm")
						end,
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawItemGroups(container)
	local function AddGroup(editBox, _, value)
		local ok, name = pcall(function() return GetItemInfo(value) end)
		value = ok and name or value
		value = string.trim(strlower(value) or "")
		if not Config:ValidateName(value) then
			TSMAPI:SetStatusText(format(L["Group/Category named \"%s\" already exists!"], value))
			editBox:SetFocus()
			return
		end
		
		TSMAuc.db.profile.groups[value] = {}
		Config:UpdateTree()
		Config.treeGroup:SelectByPath(2, value)
	end
	
	local function AddCategory(editBox, _, value)
		local ok, name = pcall(function() return GetItemInfo(value) end)
		value = ok and name or value
		value = string.trim(strlower(value) or "")
		if not Config:ValidateName(value) then
			TSMAPI:SetStatusText(format(L["Group/Category named \"%s\" already exists!"], value))
			editBox:SetFocus()
			return
		end
		
		TSMAuc.db.profile.categories[value] = {}
		Config:UpdateTree()
		Config.treeGroup:SelectByPath(2, value)
	end

	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Add group"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							fontObject = GameFontNormal,
							text = L["A group contains items that you wish to sell with similar conditions (stack size, fallback price, etc).  Default settings may be overridden by a group's individual settings."],
						},
						{
							type = "EditBox",
							label = L["Group name"],
							relativeWidth = 0.8,
							callback = AddGroup,
							tooltip = L["Name of the new group, this can be whatever you want and has no relation to how the group itself functions."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Add category"],
					children = {
						{
							type = "Label",
							relativeWidth = 1,
							fontObject = GameFontNormal,
							text = L["A category contains groups with similar settings and acts like an organizational folder. You may override default settings by category (and then override category settings by group)."],
						},
						{
							type = "EditBox",
							label = "Category name",
							relativeWidth = 0.8,
							callback = AddCategory,
							tooltip = L["Name of the new category, this can be whatever you want and has no relation to how the category itself functions."],
						},
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawWhitelist(container)
	local function AddPlayer(self, _, value)
		value = string.trim(strlower(value or ""))
		if value == "" then return TSMAPI:SetStatusText(L["No name entered."]) end
		
		for playerID, player in pairs(TSMAuc.db.factionrealm.whitelist) do
			if playerID == value then
				TSMAPI:SetStatusText(format(L["The player \"%s\" is already on your whitelist."], player))
				return
			end
		end
		
		for player in pairs(TSMAuc.db.factionrealm.player) do
			if strlower(player) == value then
				TSMAPI:SetStatusText(format(L["You do not need to add \"%s\", alts are whitelisted automatically."], player))
				return
			end
		end
		
		TSMAPI:SetStatusText()
		TSMAuc.db.factionrealm.whitelist[strlower(value)] = value
		self.parent.parent.parent:SelectTab(2)
	end

	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Help"],
					children = {
						{
							type = "Label",
							fullWidth = true,
							fontObject = GameFontNormal,
							text = L["Whitelists allow you to set other players besides you and your alts that you do not want to undercut; however, if somebody on your whitelist matches your buyout but lists a lower bid it will still consider them undercutting."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Add player"],
					children = {
						{
							type = "EditBox",
							label = L["Player name"],
							relativeWidth = 0.5,
							callback = AddPlayer,
							tooltip = L["Add a new player to your whitelist."],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Whitelist"],
					children = {},
				},
			},
		},
	}
	
	for name in pairs(TSMAuc.db.factionrealm.whitelist) do
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = TSMAuc.db.factionrealm.whitelist[name],
				fontObject = GameFontNormal,
			})
		tinsert(page[1].children[3].children,
			{
				type = "Button",
				text = L["Delete"],
				relativeWidth = 0.3,
				callback = function(self)
						TSMAuc.db.factionrealm.whitelist[name] = nil
						container:SelectTab(2)
					end,
			})
	end
	
	if #(page[1].children[3].children) == 0 then
		tinsert(page[1].children[3].children,
			{
				type = "Label",
				text = L["You do not have any players on your whitelist yet."],
				fontObject = GameFontNormal,
				fullWidth = true,
			})
	end
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawGroupManagement(container, group)
	TSMAuc:UpdateGroupReverseLookup()
	local function RenameGroup(self, _, value)
		local ok, name = pcall(function() return GetItemInfo(value) end)
		value = ok and name or value
		TSMAuc:UpdateGroupReverseLookup()
		value = string.trim(strlower(value or ""))
		if not Config:ValidateName(value) then
			TSMAPI:SetStatusText(format(L["Group/Category named \"%s\" already exists!"], value))
			editBox:SetFocus()
			return
		elseif value == "" then
			TSMAPI:SetStatusText(L["Invalid group name."])
			return
		end
		
		TSMAPI:SetStatusText()
		TSMAuc.db.profile.groups[value] = CopyTable(TSMAuc.db.profile.groups[group])
		TSMAuc.db.profile.groups[group] = nil
		for key, data in pairs(TSMAuc.db.profile) do
			if type(data) == "table" and data[group] ~= nil then
				data[value] = data[group]
				data[group] = nil
			end
		end
		if TSMAuc.groupReverseLookup[group] then
			TSMAuc.db.profile.categories[TSMAuc.groupReverseLookup[group]][value] = true
			TSMAuc.db.profile.categories[TSMAuc.groupReverseLookup[group]][group] = nil
		end
		Config:UpdateTree()
		Config.treeGroup:SelectByPath(2, value)
		group = value
	end
	
	local function DeleteGroup(confirmed)
		if confirmed then
			-- Popup Confirmation Window used in this module
			StaticPopupDialogs["TSMAucGroups.DeleteConfirm"] = StaticPopupDialogs["TSMAucGroups.DeleteConfirm"] or {
				text = L["Are you SURE you want to delete this group?"],
				button1 = L["Accept"],
				button2 = L["Cancel"],
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				OnCancel = false,
			}
			StaticPopupDialogs["TSMAucGroups.DeleteConfirm"].OnAccept = function() DeleteGroup() end,
			StaticPopup_Show("TSMAucGroups.DeleteConfirm")
			-- need to make sure the popup doesn't open behind the TSM frame
			-- if the player has more than 10 popups open it's their fault!
			for i=1, 10 do
				if _G["StaticPopup" .. i].which == "TSMAucGroups.DeleteConfirm" then
					_G["StaticPopup" .. i]:SetFrameStrata("TOOLTIP")
					break
				end
			end
			
			return
		end
		TSMAuc:UpdateGroupReverseLookup()
		TSMAuc.db.profile.groups[group] = nil
		for key, data in pairs(TSMAuc.db.profile) do
			if type(data) == "table" and data[group] ~= nil then
				data[group] = nil
			end
		end
		if TSMAuc.groupReverseLookup[group] then
			TSMAuc.db.profile.categories[TSMAuc.groupReverseLookup[group]][group] = nil
		end
		
		Config:UpdateTree()
		Config.treeGroup:SelectByPath(2)
	end

	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Rename"],
					children = {
						{
							type = "EditBox",
							label = L["New group name"],
							callback = RenameGroup,
							tooltip = L["Rename this group to something else!"],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Delete"],
					children = {
						{
							type = "Button",
							text = L["Delete group"],
							relativeWidth = 0.3,
							callback = DeleteGroup,
							tooltip = L["Delete this group, this cannot be undone!"],
						},
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawAddRemoveItem(container, group)
	TSMAuc:UpdateItemReverseLookup()
	
	local function SelectItemsMatching(selectionList, _, value)
		value = strlower(value:trim())
		selectionList:UnselectAllItems()
		if not value or value == "" then return end
		
		local itemList = {}
		for bag=4, 0, -1 do
			for slot=1, GetContainerNumSlots(bag) do
				local itemID = TSMAuc:GetItemString(GetContainerItemLink(bag, slot))
				if itemID then
					local name = GetItemInfo(itemID)
					if name and strmatch(strlower(name), value) and not TSMAuc.itemReverseLookup[itemID] and not Config:IsSoulbound(bag, slot, itemID) then
						tinsert(itemList, itemID)
					end
				end
			end
		end
		
		for itemID in pairs(TSMAuc.db.profile.groups[group]) do
			local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
			if name and strmatch(strlower(name), value) then
				tinsert(itemList, itemID)
			end
		end
		
		selectionList:SelectItems(itemList)
	end
	
	local itemsInGroup = {}
	for itemID in pairs(TSMAuc.db.profile.groups[group]) do
		local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
		if name then
			tinsert(itemsInGroup, {value=itemID, text=link, icon=texture, name=name})
		end
	end
	sort(itemsInGroup, function(a,b) return a.name<b.name end)
	
	local ungroupedItems, usedLinks = {}, {}
	for bag=4, 0, -1 do
		for slot=1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			local itemID = TSMAuc:GetItemString(link)
			if itemID and not usedLinks[itemID] and not TSMAuc.itemReverseLookup[itemID] and not Config:IsSoulbound(bag, slot, itemID) then
				local name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID)
				if not (TSMAuc.db.global.hideGray and quality == 0) then
					tinsert(ungroupedItems, {value=itemID, text=link, icon=texture, name=name})
					usedLinks[itemID] = true
				end
			end
		end
	end
	sort(ungroupedItems, function(a,b) return a.name<b.name end)
	
	local page = {
		{	-- scroll frame to contain everything
			type = "SimpleGroup",
			layout = "Fill",
			children = {
				{
					type = "SelectionList",
					leftTitle = L["Items not in any group:"],
					rightTitle = L["Items in this group:"],
					filterTitle = L["Select Matches:"],
					filterTooltip = L["Selects all items in either list matching the entered filter. Entering \"Glyph of\" will select any item with \"Glyph of\" in the name."],
					leftList = ungroupedItems,
					rightList = itemsInGroup,
					onAdd = function(_,_,selected)
							for i=#selected, 1, -1 do
								TSMAuc.db.profile.groups[group][selected[i]] = true
							end
							container:SelectTab(3)
						end,
					onRemove = function(_,_,selected)
							for i=#selected, 1, -1 do
								TSMAuc.db.profile.groups[group][selected[i]] = nil
							end
							container:SelectTab(3)
						end,
					onFilter = SelectItemsMatching,
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawCategoryManagement(container, category)
	local function RenameCategory(self, _, value)
		local ok, name = pcall(function() return GetItemInfo(value) end)
		value = ok and name or value
		value = string.trim(strlower(value or ""))
		if not Config:ValidateName(value) then
			TSMAPI:SetStatusText(format(L["Group/Category named \"%s\" already exists!"], value))
			return
		elseif value == "" then
			TSMAPI:SetStatusText(L["Invalid category name."])
			return
		end
		
		TSMAPI:SetStatusText()
		TSMAuc.db.profile.categories[value] = CopyTable(TSMAuc.db.profile.categories[category])
		TSMAuc.db.profile.categories[category] = nil
		for key, data in pairs(TSMAuc.db.profile) do
			if type(data) == "table" and data[category] ~= nil then
				data[value] = data[category]
				data[category] = nil
			end
		end
		Config:UpdateTree()
		Config.treeGroup:SelectByPath(2, value)
		category = value
	end
	
	local function DeleteCategory(confirmed)
		if confirmed then
			-- Popup Confirmation Window used in this module
			StaticPopupDialogs["TSMAuc.Category.DeleteConfirm"] = StaticPopupDialogs["TSMAuc.Category.DeleteConfirm"] or {
				text = L["Are you SURE you want to delete this category?"],
				button1 = L["Accept"],
				button2 = L["Cancel"],
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				OnCancel = false,
			}
			StaticPopupDialogs["TSMAuc.Category.DeleteConfirm"].OnAccept = function() DeleteCategory() end,
			StaticPopup_Show("TSMAuc.Category.DeleteConfirm")
			-- need to make sure the popup doesn't open behind the TSM frame
			-- if the player has more than 10 popups open it's their fault!
			for i=1, 10 do
				if _G["StaticPopup" .. i].which == "TSMAuc.Category.DeleteConfirm" then
					_G["StaticPopup" .. i]:SetFrameStrata("TOOLTIP")
					break
				end
			end
			
			return
		end
		
		TSMAuc.db.profile.categories[category] = nil
		for key, data in pairs(TSMAuc.db.profile) do
			if type(data) == "table" and data[category] ~= nil then
				data[category] = nil
			end
		end
		
		Config:UpdateTree()
		Config.treeGroup:SelectByPath(2)
	end

	local page = {
		{	-- scroll frame to contain everything
			type = "ScrollFrame",
			layout = "List",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Rename"],
					children = {
						{
							type = "EditBox",
							label = L["New category name"],
							callback = RenameCategory,
							tooltip = L["Rename this category to something else!"],
						},
					},
				},
				{
					type = "InlineGroup",
					layout = "flow",
					title = L["Delete"],
					children = {
						{
							type = "Button",
							text = "Delete category",
							relativeWidth = 0.3,
							callback = DeleteCategory,
							tooltip = L["Delete this category, this cannot be undone!"],
						},
					},
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end

function Config:DrawAddRemoveGroup(container, category)
	TSMAuc:UpdateGroupReverseLookup()
	
	local groupsInCategory = {}
	for groupName in pairs(TSMAuc.db.profile.categories[category]) do
		tinsert(groupsInCategory, {value=groupName, name=groupName, text=groupName})
	end
	sort(groupsInCategory, function(a,b) return a.name<b.name end)
	
	local uncategorizedGroups = {}
	for groupName in pairs(TSMAuc.db.profile.groups) do
		if not TSMAuc.groupReverseLookup[groupName] then
			tinsert(uncategorizedGroups, {value=groupName, name=groupName, text=groupName})
		end
	end
	sort(uncategorizedGroups, function(a,b) return a.name<b.name end)
	
	local page = {
		{	-- scroll frame to contain everything
			type = "SimpleGroup",
			layout = "Fill",
			children = {
				{
					type = "SelectionList",
					leftTitle = L["Uncategorized Groups:"],
					rightTitle = L["Groups in this Category:"],
					leftList = uncategorizedGroups,
					rightList = groupsInCategory,
					onAdd = function(_,_,selected)
							for i=#selected, 1, -1 do
								TSMAuc.db.profile.categories[category][selected[i]] = true
							end
							Config:UpdateTree()
							container:SelectTab(3)
						end,
					onRemove = function(_,_,selected)
							for i=#selected, 1, -1 do
								TSMAuc.db.profile.categories[category][selected[i]] = nil
							end
							Config:UpdateTree()
							container:SelectTab(3)
						end,
				},
			},
		},
	}
	
	TSMAPI:BuildPage(container, page)
end