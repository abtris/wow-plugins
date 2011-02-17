-- This file contains custom TSM containers that are based on AceGUI containers
-- but modified to fit the TSM theme and given a Add method for TSMAPI:BuildPage()
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)


-- Window
do
	local Type, Version = "TSMWindow", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local container = AceGUI:Create("Window")
		container.type = Type
		container.Add = TSMAPI.AddGUIElement
		
		for _, frame in pairs({container.frame:GetRegions()}) do
			if frame.GetVertexColor and frame:GetVertexColor() == 0 then
				frame:SetTexture(0, 0, 0, 1)
				frame:SetVertexColor(0, 0, 0, 0.9)
			end
		end
		
		AceGUI:RegisterAsContainer(container)
		return container
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- TreeGroup
do
	local Type, Version = "TSMTreeGroup", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local container = AceGUI:Create("TreeGroup")
		container.type = Type
		container.Add = TSMAPI.AddGUIElement
		
		container.border:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 20,
			insets = {left = 4, right = 1, top = 4, bottom = 4},
		})
		container.border:SetBackdropBorderColor(0,0,1,1)
		
		container.treeframe:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 20,
			insets = {left = 4, right = 1, top = 4, bottom = 4},
		})
		container.treeframe:SetBackdropBorderColor(0,0,1,1)
		
		container.content:SetPoint("TOPLEFT", 6, -6)
		container.content:SetPoint("BOTTOMRIGHT", -6, 6)
		
		AceGUI:RegisterAsContainer(container)
		return container
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- ScrollFrame
do
	local Type, Version = "TSMScrollFrame", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local container = AceGUI:Create("ScrollFrame")
		container.type = Type
		container.Add = TSMAPI.AddGUIElement
		
		AceGUI:RegisterAsContainer(container)
		return container
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- TabGroup
do
	local Type, Version = "TSMTabGroup", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local container = AceGUI:Create("TabGroup")
		container.type = Type
		container.Add = TSMAPI.AddGUIElement
		
		container.border:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 20,
			insets = {left = 4, right = 1, top = 4, bottom = 4},
		})
		container.border:SetBackdropBorderColor(0,0,1,1)
		
		container.content:SetPoint("TOPLEFT", 8, -8)
		container.content:SetPoint("BOTTOMRIGHT", -8, 8)
		
		AceGUI:RegisterAsContainer(container)
		return container
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- InlineGroup
do
	local Type, Version = "TSMInlineGroup", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local container = AceGUI:Create("InlineGroup")
		container.type = Type
		container.Add = TSMAPI.AddGUIElement
		
		local frame = container.content:GetParent()
		frame:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 20,
			insets = {left = 4, right = 1, top = 4, bottom = 4},
		})
		frame:SetBackdropBorderColor(0,0,1,1)
		
		AceGUI:RegisterAsContainer(container)
		return container
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- SimpleGroup
do
	local Type, Version = "TSMSimpleGroup", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local container = AceGUI:Create("SimpleGroup")
		container.type = Type
		container.Add = TSMAPI.AddGUIElement
		AceGUI:RegisterAsContainer(container)
		return container
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end