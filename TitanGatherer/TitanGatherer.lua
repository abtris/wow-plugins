--[[
    Name:           Titan Gatherer
	Description:	Titan Panel plugin for Gatherer
	  Gatherer created by Esamynn and the Gatherer Team
    Author:         Suddendeath2000
    Version:        4.0.0
    ]]--

local TPGathID = "Gatherer"
local TPGathVersion = "4.0.0"
local TPGathC1 = "|cffffffff"
local TPGathC2 = "|cff00ff00"
local TPGathC3 = "|cff999999"
local TPGathC4 = "|cffffcc00"

function TitanPanelGathererButton_OnLoad(self)
    DEFAULT_CHAT_FRAME:AddMessage(TPGathC1.."Titan Panel "..TPGathC2.."[Gatherer] "..TPGathC1.." v"..TPGathC2..TPGathVersion.." "..TPGathC1.."by |cff999999Suddendeath2000")

    TitanPanelGathererButton:RegisterEvent("ADDON_LOADED")

    self.registry = {
		id = TPGathID,
	    version = TPGathVersion,
        menuText = TPGathID,      
        category = "Interface",
        tooltipTitle = TPGathC4..TPGathID,		
        tooltipTextFunction = "TitanPanelGathererButton_GetTooltipText",
        iconButtonWidth = 16,
        iconWidth = 16,        
        savedVariables = {
			ShowIcon = 1,
            DisplayOnRightSide = 1,
    }}
end

function TitanPanelGathererButton_GetTooltipText()
    return TPGathC2.."Right-click to Open Gatherer Report\n"..TPGathC2.."Left-click to Toggle Minimap icons\n"..TPGathC2.."Shift/Right-click to Toggle Node Search\n"..TPGathC2.."Shift/Left-click to Toggle Mainmap icons"
end

function TitanPanelGathererButton_OnClick(self, button)
	if button == "LeftButton" then
	  if IsShiftKeyDown() then if (Gatherer.Config.GetSetting("mainmap.enable")) then Gatherer.Command.Process("mainmap off")
        else Gatherer.Command.Process("mainmap on")
  end    
      elseif (Gatherer.Config.GetSetting("minimap.enable")) then Gatherer.Command.Process("minimap off")       
        else Gatherer.Command.Process("minimap on")   
  end 
end
    if button == "RightButton" then 
      if IsShiftKeyDown() then if Gatherer.NodeSearch.private.frame:IsVisible() then Gatherer.NodeSearch.private.frame:Hide()
        else Gatherer.NodeSearch.private.frame:Show()
  end
       else Gatherer.Report.Toggle()
    end    
  end
end

function TitanPanelGathererButton_OnUpdate(self)
    local Button = TitanUtils_GetButton(TPGathID, true)
    
    if Gatherer.MiniIcon.icon:IsDesaturated() then 
      Button.registry.icon = "Interface\\Addons\\TitanGatherer\\TitanGatherer2"
    else Button.registry.icon = "Interface\\Addons\\TitanGatherer\\TitanGatherer"
  end
    TitanPanelButton_UpdateButton(TPGathID)
end