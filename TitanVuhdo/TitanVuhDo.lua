VuhDoID = "VuhDo";
VuhDoVersion = "1.0"
VuhDoC1 = "|cffffcc00"
VuhDoC2 = "|cff00ff00"

function TitanPanelVuhDoButton_OnLoad(self)

	self.registry = {
		id = VuhDoID,
		version = VuhDoVersion,
		menuText = TITAN_VUHDO_MENU_TEXT, 
		category = "Interface",
		tooltipTitle = VuhDoC1..TITAN_VUHDO_TOOLTIP,
        tooltipTextFunction = "TitanPanelVuhDoButton_GetTooltipText",
        icon = "Interface\\Addons\\TitanVuhDo\\TitanVuhDo",
		iconWidth = 16,
	    savedVariables = {
	        ShowIcon = 1
	}}
    
	tinsert(TITAN_PANEL_NONMOVABLE_PLUGINS, VuhDoID)
end

function TitanPanelVuhDoButton_GetTooltipText()
    return 
    VuhDoC2..TITAN_VUHDO_TOOLTIP_HINT1.."\n"..VuhDoC2..TITAN_VUHDO_TOOLTIP_HINT2
end    


function TITANVUHDO_minimapRightClick()
	ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, "TitanPanelVuhDoButton", 0, -5);
end

function TitanPanelVuhDoButton_OnClick(button)
	if button == "RightButton" then TITANVUHDO_minimapRightClick()
      elseif button == "LeftButton" then VUHDO_minimapLeftClick()
  end

  
end
