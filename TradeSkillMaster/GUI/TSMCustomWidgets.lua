-- This file contains custom TSM widgets that are based on AceGUI
-- widgets (minus MacroButton) but modified to fit the TSM theme.
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)


-- MacroButton
do
	local Type, Version = "TSMMacroButton", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
	
	local methods = {
		["OnAcquire"] = function(self)
			-- restore default values
			self:SetHeight(24)
			self:SetWidth(200)
			self:SetDisabled(false)
			self:SetText()
		end,

		-- ["OnRelease"] = nil,

		["SetText"] = function(self, text)
			self.text:SetText(text)
		end,

		["SetDisabled"] = function(self, disabled)
			self.disabled = disabled
			if disabled then
				self.button:Disable()
			else
				self.button:Enable()
			end
		end
	}
	
	local function Constructor()
		local name = "AceGUITSMMacroButton" .. AceGUI:GetNextWidgetNum(Type)
		local button = CreateFrame("Button", name, UIParent, "UIPanelButtonTemplate2, SecureActionButtonTemplate")
		button:Hide()

		button:EnableMouse(true)
		button:SetScript("OnEnter", function(self) button.obj:Fire("OnEnter") end)
		button:SetScript("OnLeave", function(self) button.obj:Fire("OnLeave") end)

		local text = button:GetFontString()
		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", 15, -1)
		text:SetPoint("BOTTOMRIGHT", -15, 1)
		text:SetJustifyV("MIDDLE")

		local widget = {
			text  = text,
			button = button,
			type  = Type
		}
		for method, func in pairs(methods) do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- Dropdown
do
	local Type, Version = "TSMDropdown", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

	local function Constructor()
		local dropdown = AceGUI:Create("Dropdown")
		dropdown.type = Type
		return AceGUI:RegisterAsWidget(dropdown)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- EditBox
do
	local Type, Version = "TSMEditBox", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
	
	local function Constructor()
		local editBox = AceGUI:Create("EditBox")
		editBox.type = Type
		return AceGUI:RegisterAsWidget(editBox)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- CheckBox
do
	local Type, Version = "TSMCheckBox", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
	
	local function Constructor()
		local checkBox = AceGUI:Create("CheckBox")
		checkBox.type = Type
		return AceGUI:RegisterAsWidget(checkBox)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- Slider
do
	local Type, Version = "TSMSlider", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
	
	local function Constructor()
		local slider = AceGUI:Create("Slider")
		slider.type = Type
		return AceGUI:RegisterAsWidget(slider)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- Button
do
	local Type, Version = "TSMButton", 1
	if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
	
	local function Constructor()
		local button = AceGUI:Create("Button")
		button.type = Type
		
		local btn = button.frame
		
		btn:SetBackdrop({
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 18,
			insets = {left = 0, right = 0, top = 0, bottom = 0},
		})

		local normalTex = btn:CreateTexture()
		normalTex:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton")
		normalTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -6)
		normalTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 6, 6)
		normalTex:SetTexCoord(0.049, 0.958, 0.066, 0.244)
		btn:SetNormalTexture(normalTex)

		local disabledTex = btn:CreateTexture()
		disabledTex:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton")
		disabledTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -6)
		disabledTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 6, 6)
		disabledTex:SetVertexColor(0.1, 0.1, 0.1, 1)
		disabledTex:SetTexCoord(0.049, 0.958, 0.066, 0.244)
		btn:SetDisabledTexture(disabledTex)

		local highlightTex = btn:CreateTexture()
		highlightTex:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton")
		highlightTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -6)
		highlightTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 6, 6)
		highlightTex:SetTexCoord(0.005, 0.994, 0.613, 0.785)
		highlightTex:SetVertexColor(0.3, 0.3, 0.3, 0.7)
		btn:SetHighlightTexture(highlightTex)

		local pressedTex = btn:CreateTexture()
		pressedTex:SetTexture("Interface\\TokenFrame\\UI-TokenFrame-CategoryButton")
		pressedTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -6, -6)
		pressedTex:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 6, 6)
		pressedTex:SetVertexColor(1, 1, 1, 0.5)
		pressedTex:SetTexCoord(0.0256, 0.743, 0.017, 0.158)
		btn:SetPushedTexture(pressedTex)
		btn:SetPushedTextOffset(0, -2)

		return AceGUI:RegisterAsWidget(button)
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end