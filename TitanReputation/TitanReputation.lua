-- globals
TITANREP_ID =  "Reputation";
TITANREP_VERSION = GetAddOnMetadata("TitanReputation", "Version") or "UnKnown Version"
TITANREP_TITLE = GetAddOnMetadata("TitanReputation", "Title") or "UnKnown Title"
TITANREP_BUTTON_ICON = "Interface\\AddOns\\TitanReputation\\TitanReputation";
TITANREP_EventTime = GetTime();
--check Glamour version
--
local min_version = 1.2;
local major, minor, _ = strsplit(".", Glamour_VERSION);
local glam_ver = tonumber(major.."."..minor);

if (glam_ver < min_version) then
	StaticPopupDialogs["! ! ! Glamour Outdated ! ! !"] = {
		  text = "An outdated version of Glamour has been detected. Running an older version of Glamour can have undesired effects on Glamour enabled addons.\n\n"..
		  	"Reporting Addon:\n"..TITANREP_TITLE.." v"..TITANREP_VERSION.."\n\n"..
			"Glamour Version Detected: "..Glamour_VERSION.."\nGlamour Version Required: "..min_version.."\n\n",
		  button1 = "Ok",
		  timeout = 0,
		  whileDead = true,
		  hideOnEscape = true,
	}
	StaticPopup_Show ("! ! ! Glamour Outdated ! ! !");
end	

--new color coding
local TITANREP_COLORS_DEFAULT = {	
		[1] = {r = 0.8, g = 0, b = 0},
		[2] = {r = 0.8, g = 0.3, b = 0.22},
		[3] = {r = 0.75, g = 0.27, b = 0},
		[4] = {r = 0.9, g = 0.7, b = 0},
		[5] = {r = 0, g = 1.0, b = 0.5},
		[6] = {r = 0, g = 0.5, b = 0.5},
		[7] = {r = 0, g = 0.5, b = 1.0},
		[8] = {r = 0.2, g = 0.7, b = 0.7} 
};
	
local TITANREP_COLORS_ARMORY = { 
		[1] = {r = 0.54, g = 0.11, b = 0.07},
 		[2] = {r = 0.65, g = 0.30, b = 0.10},
		[3] = {r = 0.70, g = 0.48, b = 0.11},
		[4] = {r = 0.67, g = 0.55, b = 0.11},
		[5] = {r = 0.49, g = 0.49, b = 0.00},
		[6] = {r = 0.34, g = 0.47, b = 0.00},
		[7] = {r = 0.14, g = 0.48, b = 0.00},
		[8] = {r = 0.01, g = 0.49, b = 0.42} 
};

local MYBARCOLORS = TITANREP_COLORS_DEFAULT;

local TITANREP_ICONS = { "03", "03", "07", "08", "06", "06", "06", "05" }

	

-- labels
local TITANREP_ALL_HIDDEN_LABEL = "Reputation: Off";
local TITANREP_NO_FACTION_LABEL = "Reputation: No Faction Selected";
local TITANREP_SHOW_FACTION_NAME_LABEL = "Show Faction Name";
local TITANREP_SHOW_STANDING = "Show Standing";
local TITANREP_SHOW_VALUE = "Show Reputation Value";
local TITANREP_SHOW_PERCENT = "Show Percent";
local TITANREP_AUTO_CHANGE = "Auto Show Changed";
local TITANREP_SHOW_EXALTED = "Show Exalted";
local TITANREP_SHOW_REVERED = "Show Revered";
local TITANREP_SHOW_HONORED = "Show Honored";
local TITANREP_SHOW_FRIENDLY = "Show Friendly";
local TITANREP_SHOW_NEUTRAL = "Show Neutral";
local TITANREP_SHOW_UNFRIENDLY = "Show Unfriendly";
local TITANREP_SHOW_HOSTILE = "Show Hostile";
local TITANREP_SHOW_HATED = "Show Hated";
local TITANREP_SHORT_STANDING = "Abbreviate Standing";
local TITANREP_ARMORY_COLORS = "Armory Colors";
local TITANREP_DEFAULT_COLORS = "Default Colors";
local TITANREP_NO_COLORS = "Basic Colors";
local TITANREP_SHOW_STATS = "Show Exalted Total";
local TITANREP_SHOW_SUMMARY = "Show Session Summary";
local TITANREP_SHOW_ANNOUNCE = "Announce Standing Changes";
local TITANREP_SHOW_ANNOUNCE_FRAME = "Glamourize Standing Changes";

-- local
local TITANREP_BUTTON_TEXT = TITANREP_NO_FACTION_LABEL;
local TITANREP_TOOLTIP_TEXT = "";
local TITANREP_HIGHCHANGED = 0;
local TITANREP_RTS = {};
local TITANREP_TIME = GetTime();
local TITANREP_CHANGEDFACTION = "none";
local TITANREP_TABLE = {};

-- initializing
function TitanPanelReputationButton_OnLoad(self)
	self.registry = {
		id = TITANREP_ID,
		menuText = TITANREP_ID, 
		version = TITANREP_VERSION,
		buttonTextFunction = "TitanPanelReputation_GetButtonText", 
		tooltipCustomFunction = TitanPanelReputation_localGetToolTipText, 
		category = "Information",
		icon = TITANREP_BUTTON_ICON,
		iconWidth = 16,
		savedVariables = {
			ShowIcon = 1,
			ShowFactionName = 1,
			ShowStanding = 1,
			ShortStanding = false,
			ShowValue = 1,
			ShowPercent = 1, 
			AutoChange = 1,
			TITANREP_WATCHED_FACTION = "none",
			ShowExalted = 1,
			ShowRevered= 1,
			ShowHonored= 1,
			ShowFriendly= 1,
			ShowNeutral= 1,
			ShowUnfriendly= 1,
			ShowHostile= 1,
			ShowHated= 1,
			MyColor = 1,
			ShowSummary = 1,
			ShowStats = 1,
			FactionHeaders = { "" },		
			ShowTipValue = 1,
			ShowTipPercent = 1,
			ShowTipStanding = 1,
			ShowAnnounce = 1,
			ShowAnnounceFrame = 1,
			ShortTipStanding = false
		}
	};	
    self:RegisterEvent("UPDATE_FACTION");
--    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
end

-- event handling
function TitanPanelReputationButton_OnClick(self, button)
     if (button == "LeftButton") then
	     ToggleCharacter("ReputationFrame");
     end
     if (button == "RightButton") then
	     TitanPanelRightClickMenu_PrepareReputationMenu(self);
     end
end

function TitanPanelReputationButton_OnEvent(event, ...)	
	if(GetTime() - TITANREP_EventTime > 1) then
		TITANREP_EventTime = GetTime();
		--print(event);
		--print("EventTime: "..TITANREP_EventTime);
		--print(...);
		TitanPanelReputation_GatherFactions(TitanPanelReputation_GetChangedName);
		if(TitanGetVar(TITANREP_ID, "AutoChange")) then
			TITANREP_HIGHCHANGED = 0;
			if(not (TITANREP_CHANGEDFACTION == "none")) then
				TitanSetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION", TITANREP_CHANGEDFACTION);
			end		
		end
	end		
	TitanPanelReputation_GatherFactions(TitanPanelReputation_GatherValues);
	TitanPanelReputation_Refresh();
	TitanPanelButton_UpdateTooltip();
	TitanPanelButton_UpdateButton(TITANREP_ID);
end

-- for titan to get the displayed text
function TitanPanelReputation_GetButtonText(id)
	TitanPanelReputation_Refresh();
	return TITANREP_BUTTON_TEXT;
end

-- for titan tool tip text building
function TitanPanelReputation_localGetToolTipText(self)
	local tleft = "|T"..TITANREP_BUTTON_ICON..":32|t "..TITANREP_TITLE;
	local tright = "v"..TITANREP_VERSION.."|T"..TITANREP_BUTTON_ICON..":32|t";
	GameTooltip:AddDoubleLine(tleft, tright, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);	
	TitanTooltip_AddTooltipText(TitanPanelReputation_GetToolTipText());
	GameTooltip:Show();
end

function TitanPanelReputation_GetToolTipText()
	TITANREP_TOOLTIP_TEXT = "";
	TOTAL_EXALTED = 0;
	LAST_HEADER = {"HEADER", 1};
	TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildToolTipText);
	if(TitanGetVar(TITANREP_ID, "ShowStats") == 1) then
		TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n"..TitanUtils_GetHighlightText("Total Exalted Factions:");
		TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\t"..TitanUtils_GetNormalText(TOTAL_EXALTED);
	end
	if(TitanGetVar(TITANREP_ID, "ShowSummary") == 1) then
		local timeonline =  GetTime() -	TITANREP_TIME;
		local humantime = "";

		if (timeonline < 60) then
			humantime = "< 1 Mn";
		else 
			humantime = floor(timeonline / 60);
			if(humantime < 60) then
				humantime = humantime.." Mn";
			else
				local hours = floor(humantime / 60);
				local mins = floor((timeonline - (hours * 60 * 60)) / 60);
				humantime = hours.." Hr "..mins.." Mn";
			end
		end
		TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n"..TitanUtils_GetHighlightText("Session Summary:");
		TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\t"..TitanUtils_GetNormalText("Duration: "..humantime);

		for f, v in pairs(TITANREP_RTS) do
			local RPH = floor(v / (timeonline / 60 / 60));
			if(RPH > 0) then
				TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n "..f.." : "..TitanUtils_GetGreenText(RPH).." perHour\t Total: "..TitanUtils_GetGreenText(v);
			else
				TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n "..f.." : "..TitanUtils_GetRedText(RPH).." perHour\t Total: "..TitanUtils_GetRedText(v);
			end
		end
	end
	return TITANREP_TOOLTIP_TEXT;
end

function TitanReputationSetColor()
	if(TitanGetVar(TITANREP_ID, "MyColor") == 1) then
		MYBARCOLORS = TITANREP_COLORS_DEFAULT;
	end 
	if(TitanGetVar(TITANREP_ID, "MyColor") == 2) then
		MYBARCOLORS = TITANREP_COLORS_ARMORY;
	end 
	if(TitanGetVar(TITANREP_ID, "MyColor") == 3) then
		MYBARCOLORS = nil;
	end 
end

-- this method adds a line to the tooltip text
function TitanPanelReputation_BuildToolTipText(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, isInactive)
	local showrep = 0;
	if(standingId == 8) then
		TOTAL_EXALTED = TOTAL_EXALTED + 1;
	end
	if (tContains(TitanGetVar(TITANREP_ID, "FactionHeaders"), parentName)) then 
		return;
	end
	TitanReputationSetColor();

	if(isInactive) then
		showrep = 0;
	else
		showrep = 1;
	end

	if(isHeader) then
		LAST_HEADER = {name, 0};

		if(name == "Horde Expedition" or name == "Alliance Vanguard") then
			showrep = 1;
		else
			showrep = 0;
		end
	end
	
	if(showrep == 1) then
		showrep = 0;

		if(standingId == 8 and TitanGetVar(TITANREP_ID, "ShowExalted")) then showrep = 1; end
		if(standingId == 7 and TitanGetVar(TITANREP_ID, "ShowRevered")) then showrep = 1; end
		if(standingId == 6 and TitanGetVar(TITANREP_ID, "ShowHonored")) then showrep = 1; end
		if(standingId == 5 and TitanGetVar(TITANREP_ID, "ShowFriendly")) then showrep = 1; end
		if(standingId == 4 and TitanGetVar(TITANREP_ID, "ShowNeutral")) then showrep = 1; end
		if(standingId == 3 and TitanGetVar(TITANREP_ID, "ShowUnfriendly")) then showrep = 1; end
		if(standingId == 2 and TitanGetVar(TITANREP_ID, "ShowHostile")) then showrep = 1; end
		if(standingId == 1 and TitanGetVar(TITANREP_ID, "ShowHated")) then showrep = 1; end

		if(showrep == 1) then
			if(LAST_HEADER[2] == 0) then 
				if(LAST_HEADER[1] == "Guild") then
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n"..TitanUtils_GetHighlightText(LAST_HEADER[1]); 
				else
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n"..TitanUtils_GetHighlightText(LAST_HEADER[1]).."\n"; 
				end
				LAST_HEADER[2] = 1;
			end
			if(MYBARCOLORS) then 
				if(standingId == 8) then
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetHighlightText(" - "); 
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText(name, MYBARCOLORS[8]).."\t";			
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText(getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[8]);			
				else
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetHighlightText(" - "); 
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText(name, MYBARCOLORS[standingId]).."\t";			
					if(TitanGetVar(TITANREP_ID, "ShowTipValue")) then
						TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText("["..earnedValue.."/"..topValue.."]", MYBARCOLORS[standingId]).." ";
					end
					if(TitanGetVar(TITANREP_ID, "ShowTipPercent")) then
						TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText(percent.."%",MYBARCOLORS[standingId]).." ";
					end
					if(TitanGetVar(TITANREP_ID, "ShowTipStanding")) then
						if(not TitanGetVar(TITANREP_ID, "ShortTipStanding")) then
							TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText(getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[standingId]);
						else
							TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetColoredText(strsub(getglobal("FACTION_STANDING_LABEL"..standingId),1,1),MYBARCOLORS[standingId]);
						end
					end
				end
			else
				if(standingId == 8) then
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetHighlightText(" - "); 
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..name.."\t";			
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..getglobal("FACTION_STANDING_LABEL"..standingId);			
				else
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..TitanUtils_GetHighlightText(" - "); 
					TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..name.."\t";			
					if(TitanGetVar(TITANREP_ID, "ShowTipValue")) then
						TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."["..earnedValue.."/"..topValue.."] ";
					end
					if(TitanGetVar(TITANREP_ID, "ShowTipPercent")) then
						TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..percent.."% ";
					end
					if(TitanGetVar(TITANREP_ID, "ShowTipStanding")) then
						if(not TitanGetVar(TITANREP_ID, "ShortTipStanding")) then
							TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..strsub(getglobal("FACTION_STANDING_LABEL"..standingId),1,1);
						else
							TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT..getglobal("FACTION_STANDING_LABEL"..standingId);
						end
					end
				end
			end
			TITANREP_TOOLTIP_TEXT = TITANREP_TOOLTIP_TEXT.."\n";
		end
	end
end

function TitanPanelRightClickMenu_AddTitle2(title, level)
	if (title) then
		local info = {};
		info.text = title;
		info.notClickable = 1;
		info.isTitle = 1;
       		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, level);
	end
end


function TitanPanelRightClickMenu_AddToggleVar2(text, id, var, toggleTable)
	local info = {};
	info.text = text;
	info.value = {id, var, toggleTable};
	info.func = function()
		TitanPanelRightClickMenu_ToggleVar({id, var, toggleTable})
	end
	info.checked = TitanGetVar(id, var);
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info, 2);
end

function TitanPanelRightClickMenu_AddToggleIcon2(id)
	TitanPanelRightClickMenu_AddToggleVar2("Show Icon", id, "ShowIcon");
end

function TitanPanelRightClickMenu_AddSpacer2(level)
	local info = {};
	info.disabled = 1;
       	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);
end


-- this method builds the right-click menus
function TitanPanelRightClickMenu_PrepareReputationMenu()
	-- level 2 menus
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		TitanPanelRightClickMenu_AddTitle2(UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
		TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildFactionSubMenu);
		if UIDROPDOWNMENU_MENU_VALUE == "Button Options" then
			TitanPanelRightClickMenu_AddToggleIcon2(TITANREP_ID, UIDROPDOWNMENU_MENU_LEVEL);
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_FACTION_NAME_LABEL, TITANREP_ID, "ShowFactionName");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STANDING, TITANREP_ID, "ShowStanding");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHORT_STANDING, TITANREP_ID, "ShortStanding");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_VALUE, TITANREP_ID, "ShowValue");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_PERCENT, TITANREP_ID, "ShowPercent");	
		end
		if UIDROPDOWNMENU_MENU_VALUE == "Tooltip Options" then
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_EXALTED, TITANREP_ID, "ShowExalted");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_REVERED, TITANREP_ID, "ShowRevered");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_HONORED, TITANREP_ID, "ShowHonored");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_FRIENDLY, TITANREP_ID, "ShowFriendly");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_NEUTRAL, TITANREP_ID, "ShowNeutral");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_UNFRIENDLY, TITANREP_ID, "ShowUnfriendly");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_HOSTILE, TITANREP_ID, "ShowHostile");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_HATED, TITANREP_ID, "ShowHated");	
			TitanPanelRightClickMenu_AddSpacer2(2);
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_VALUE, TITANREP_ID, "ShowTipValue");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_PERCENT, TITANREP_ID, "ShowTipPercent");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STANDING, TITANREP_ID, "ShowTipStanding");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHORT_STANDING, TITANREP_ID, "ShortTipStanding");	
			TitanPanelRightClickMenu_AddSpacer2(2);
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_STATS, TITANREP_ID, "ShowStats");	
			TitanPanelRightClickMenu_AddToggleVar2(TITANREP_SHOW_SUMMARY, TITANREP_ID, "ShowSummary");	
		end
		if UIDROPDOWNMENU_MENU_VALUE == "Color Options" then
			local info = {};
				info.text = TITANREP_DEFAULT_COLORS;
				info.checked = function() if TitanGetVar(TITANREP_ID, "MyColor") == 1 then return true else return nil end end
				info.func = function() 
					TitanSetVar(TITANREP_ID, "MyColor", 1);
					TitanPanelButton_UpdateButton(TITANREP_ID);
				end
     			UIDropDownMenu_AddButton(info, 2);
			local info = {};
				info.text = TITANREP_ARMORY_COLORS;
				info.checked = function() if TitanGetVar(TITANREP_ID, "MyColor") == 2 then return true else return nil end end
				info.func = function() 
					TitanSetVar(TITANREP_ID, "MyColor", 2);
					TitanPanelButton_UpdateButton(TITANREP_ID);
				end
     			UIDropDownMenu_AddButton(info, 2);
			local info = {};
				info.text = TITANREP_NO_COLORS;
				info.checked = function() if TitanGetVar(TITANREP_ID, "MyColor") == 3 then return true else return nil end end
				info.func = function() 
					TitanSetVar(TITANREP_ID, "MyColor", 3);
					TitanPanelButton_UpdateButton(TITANREP_ID);
				end
     			UIDropDownMenu_AddButton(info, 2);
		end
		return;
	end
	-- level 1 menu
	TitanPanelRightClickMenu_AddTitle2(TitanPlugins[TITANREP_ID].menuText.." v"..TITANREP_VERSION);
	TitanPanelRightClickMenu_AddToggleVar(TITANREP_AUTO_CHANGE, TITANREP_ID, "AutoChange");	
	TitanPanelRightClickMenu_AddToggleVar(TITANREP_SHOW_ANNOUNCE, TITANREP_ID, "ShowAnnounce");	
	TitanPanelRightClickMenu_AddToggleVar(TITANREP_SHOW_ANNOUNCE_FRAME, TITANREP_ID, "ShowAnnounceFrame");	
	TitanPanelRightClickMenu_AddSpacer2();
	TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildRightClickMenu);
	TitanPanelRightClickMenu_AddSpacer2();
	local info = {};
       	info.hasArrow = true; 
       	info.notCheckable = true;
       	info.text = "Button Options";
       	info.value = "Button Options";
	UIDropDownMenu_AddButton(info, 1);			
       	info.text = "Tooltip Options";
       	info.value = "Tooltip Options";
	UIDropDownMenu_AddButton(info, 1);			
       	info.text = "Color Options";
       	info.value = "Color Options";
	UIDropDownMenu_AddButton(info, 1);
	TitanPanelRightClickMenu_AddSpacer2();
	info.text = "Close Menu";
	info.value = "Close Menu";
	info.hasArrow = false;
	UIDropDownMenu_AddButton(info, 1);

end

function TitanReputationHeaderFactionToggle(name)
	local value = "";
	local found = false;
	local array = TitanGetVar(TITANREP_ID, "FactionHeaders");
	for index, value in ipairs(array) do
		if (value == name) then
			found = index;
		end
	end
	if(found) then 
		tremove(array,found);		
	else
		tinsert(array,name);		
	end
	TitanSetVar(TITANREP_ID, "FactionHeaders", array)
	return;
end

-- this method adds a line to the right-click menu (to build up faction headers)
function TitanPanelReputation_BuildRightClickMenu(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, isInactive)
	if(not isInactive) then
		if(isHeader and not isCollapsed) then
			command = {}
			command.text = name;
			command.value = name;
			command.hasArrow = 1;
			command.keepShownOnClick = 1;
			command.checked = function() if (tContains(TitanGetVar(TITANREP_ID, "FactionHeaders"), name)) then return nil else return true end end
			command.func = function() 
				TitanReputationHeaderFactionToggle(name); 
				TitanPanelButton_UpdateButton(TITANREP_ID);
			end
			UIDropDownMenu_AddButton(command);
		end
	end
end

-- this method adds a line to the level2 right-click menu (to build up factions for parent header)
function TitanPanelReputation_BuildFactionSubMenu(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, isInactive)
	if(parentName == UIDROPDOWNMENU_MENU_VALUE and (not isHeader or (name == "Horde Expedition" or name == "Alliance Vanguard"))) then
		command = {}
		if(MYBARCOLORS) then
			command.text = name.."  -  "..TitanUtils_GetColoredText(getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[standingId]);
		else
			command.text = name.."  -  "..getglobal("FACTION_STANDING_LABEL"..standingId);
		end
		command.value = name;
		command.func = TitanPanelReputation_SetFaction;
       		command.notCheckable = true;
		UIDropDownMenu_AddButton(command, UIDROPDOWNMENU_MENU_LEVEL);
	end
end

-- this method sets the selected faction shown at titan panel
function TitanPanelReputation_SetFaction(this)
		TitanSetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION", this.value);
--		TitanSetVar(TITANREP_ID, "AutoChange", nil);
		TitanPanelReputation_Refresh();
		TitanPanelButton_UpdateButton(TITANREP_ID);
end

-- This method refreshes the reputation data
function TitanPanelReputation_Refresh()
	if not (TitanGetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION") == "none") then
		TitanPanelReputation_GatherFactions(TitanPanelReputation_BuildButtonText);
	else
		TITANREP_BUTTON_TEXT = TITANREP_NO_FACTION_LABEL;		
	end
end

-- This method sets the text of the button according to selected faction's data
function TitanPanelReputation_BuildButtonText(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, isInactive)
	TitanReputationSetColor();
	if((not isHeader or (name == "Horde Expedition" or name == "Alliance Vanguard")) and (TitanGetVar(TITANREP_ID, "TITANREP_WATCHED_FACTION")==name)) then
		TITANREP_BUTTON_TEXT = "";
		local COLOR = nil;
		if(MYBARCOLORS) then
			COLOR = MYBARCOLORS[standingId];
		end

		if(TitanGetVar(TITANREP_ID, "ShowFactionName")) then 
			if(COLOR) then
				TITANREP_BUTTON_TEXT = TitanUtils_GetColoredText(name, COLOR); 
			else
				TITANREP_BUTTON_TEXT = name; 
			end
			if(TitanGetVar(TITANREP_ID, "ShowStanding") or
				TitanGetVar(TITANREP_ID, "ShowStanding") or
				TitanGetVar(TITANREP_ID, "ShowValue") or
				TitanGetVar(TITANREP_ID, "ShowPercent")) then 
				TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT.." - ";
			end
		end

		if(TitanGetVar(TITANREP_ID, "ShowStanding")) then 
			if(TitanGetVar(TITANREP_ID, "ShortStanding")) then 
				if(COLOR) then
					TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..TitanUtils_GetColoredText(strsub(getglobal("FACTION_STANDING_LABEL"..standingId),1,1),COLOR).." "; 
				else
					TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..strsub(getglobal("FACTION_STANDING_LABEL"..standingId),1,1).." "; 
				end
			else
				if(COLOR) then
					TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..TitanUtils_GetColoredText(getglobal("FACTION_STANDING_LABEL"..standingId),COLOR).." "; 
				else
					TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..getglobal("FACTION_STANDING_LABEL"..standingId).." "; 
				end
			end
		end
		if(TitanGetVar(TITANREP_ID, "ShowValue")) then 
			if(COLOR) then
				TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT.."["..TitanUtils_GetColoredText(earnedValue.."/"..topValue, COLOR).."] "; 
			else
				TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT.."["..earnedValue.."/"..topValue.."] "; 
			end
		end

		if(TitanGetVar(TITANREP_ID, "ShowPercent")) then 
			if(COLOR) then
				TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..TitanUtils_GetColoredText(percent.."%",COLOR); 
			else
				TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..percent.."%"; 
			end
		end

		if(not (TitanGetVar(TITANREP_ID, "ShowFactionName") or 
			TitanGetVar(TITANREP_ID, "ShowStanding") or 
			TitanGetVar(TITANREP_ID, "ShowValue") or 
			TitanGetVar(TITANREP_ID, "ShowPercent"))) then
			TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT..TITANREP_ALL_HIDDEN_LABEL;
		end

		--TITANREP_BUTTON_TEXT = TITANREP_BUTTON_TEXT.."\n";
	end
end

-- saves all reputation value, so we can monitor what is changed
function TitanPanelReputation_GatherValues(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, isInactive)
	if((not isHeader and name) or (name == "Horde Expedition" or name == "Alliance Vanguard")) then
		TITANREP_TABLE[name] = {};
		TITANREP_TABLE[name].standingId = standingId;
		TITANREP_TABLE[name].earnedValue = earnedValue;
		TITANREP_TABLE[name].topValue= topValue;
	end
end

-- gets the faction name where reputation changed
function TitanPanelReputation_GetChangedName(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, isInactive)
	local earnedAmount = 0;
	if(TITANREP_TABLE[name]) then
		if((TITANREP_TABLE[name].standingId < standingId) or (TITANREP_TABLE[name].earnedValue ~= earnedValue)) then
			local msg = "";
			local dsc = "You have obtained ";
			local tag = " ";
			if(TITANREP_TABLE[name].standingId < standingId) then
				if(MYBARCOLORS) then
					TitanReputationFrameGlowFrameGlow:SetVertexColor(MYBARCOLORS[standingId].r,MYBARCOLORS[standingId].g,MYBARCOLORS[standingId].b);
					msg = TitanUtils_GetColoredText(name.." - "..getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[standingId]);	
					dsc = dsc..TitanUtils_GetColoredText(getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[standingId]);	
				else
					TitanReputationFrameGlowFrameGlow:SetVertexColor(0.5,0.5,0);
					msg = TitanUtils_GetGoldText(name.." - "..getglobal("FACTION_STANDING_LABEL"..standingId));	
					dsc = dsc..TitanUtils_GetGoldText(getglobal("FACTION_STANDING_LABEL"..standingId));	
				end
				dsc = dsc.." standing with "..name..".";
				msg = tag..msg..tag;
				if(TitanGetVar(TITANREP_ID, "ShowAnnounce")) then 
					if(IsAddOnLoaded("MikScrollingBattleText")) then
						MikSBT.DisplayMessage("|T"..TITANREP_BUTTON_ICON..":32|t"..msg.."|T"..TITANREP_BUTTON_ICON..":32|t","Static",1);
					else
						UIErrorsFrame:AddMessage("|T"..TITANREP_BUTTON_ICON..":32|t"..msg.."|T"..TITANREP_BUTTON_ICON..":32|t", 2.0, 2.0, 0.0, 53, 30);
					end
				end
				if(TitanGetVar(TITANREP_ID, "ShowAnnounceFrame")) then 					
					if(IsAddOnLoaded("Glamour")) then
							local MyData = { };
							MyData.Text = msg;
	 						MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_"..TITANREP_ICONS[standingId];
	 						MyData.tText = "";
							MyData.bText = "";
							MyData.Points = 0;
							local color = { };
							color.r = TITANREP_COLORS_ARMORY[standingId].r;
							color.g = TITANREP_COLORS_ARMORY[standingId].g;
							color.b = TITANREP_COLORS_ARMORY[standingId].b;
							MyData.tText = "";
							MyData.bText = "";
							MyData.Title = "Faction Standing Upgrade";
							local LastAlertFrame = GlamourShowAlert(400, MyData, color, color);
							--_G[LastAlertFrame.."IconTexture"]:SetVertexColor(color.r,color.g,color.b);
					else
						TitanReputation_Title:SetText(msg);
						TitanReputation_Desc:SetText(dsc);
						TitanReputationFrame_Show(); 
					end
				end
				earnedAmount = TITANREP_TABLE[name].topValue - TITANREP_TABLE[name].earnedValue;
				earnedAmount = earnedValue + earnedAmount;
			elseif(TITANREP_TABLE[name].standingId > standingId) then
				if(MYBARCOLORS) then
					TitanReputationFrameGlowFrameGlow:SetVertexColor(MYBARCOLORS[standingId].r,MYBARCOLORS[standingId].g,MYBARCOLORS[standingId].b);
					msg = TitanUtils_GetColoredText(name.." - "..getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[standingId]);	
					dsc = dsc..TitanUtils_GetColoredText(getglobal("FACTION_STANDING_LABEL"..standingId),MYBARCOLORS[standingId]);	
				else
					TitanReputationFrameGlowFrameGlow:SetVertexColor(0.5,0.5,0);
					msg = TitanUtils_GetGoldText(name.." - "..getglobal("FACTION_STANDING_LABEL"..standingId));	
					dsc = dsc..TitanUtils_GetGoldText(getglobal("FACTION_STANDING_LABEL"..standingId));	
				end
				dsc = dsc.." standing with "..name..".";
				msg = tag..msg..tag;
				if(TitanGetVar(TITANREP_ID, "ShowAnnounce")) then 
					if(IsAddOnLoaded("MikScrollingBattleText")) then
						MikSBT.DisplayMessage("|T"..TITANREP_BUTTON_ICON..":32|t"..msg.."|T"..TITANREP_BUTTON_ICON..":32|t","Static",1);
					else
						UIErrorsFrame:AddMessage("|T"..TITANREP_BUTTON_ICON..":32|t"..msg.."|T"..TITANREP_BUTTON_ICON..":32|t", 2.0, 2.0, 0.0, 53, 30);
					end
				end
				if(TitanGetVar(TITANREP_ID, "ShowAnnounceFrame")) then 
					if(IsAddOnLoaded("Glamour")) then
							local MyData = { };
							MyData.Text = msg;
	 						MyData.Icon = "Interface\\ICONS\\Achievement_Reputation_"..TITANREP_ICONS[standingId];
	 						MyData.tText = "";
							MyData.bText = "";
							MyData.Points = 0;
							local color = { };
							color.r = TITANREP_COLORS_ARMORY[standingId].r;
							color.g = TITANREP_COLORS_ARMORY[standingId].g;
							color.b = TITANREP_COLORS_ARMORY[standingId].b;
							MyData.tText = "";
							MyData.bText = "";
							MyData.Title = "Faction Standing Downgrade";
							local LastAlertFrame = GlamourShowAlert(400, MyData, color, color);
							--_G[LastAlertFrame.."IconTexture"]:SetVertexColor(color.r,color.g,color.b);
					else
						TitanReputation_Title:SetText(msg);
						TitanReputation_Desc:SetText(dsc);
						TitanReputationFrame_Show(); 
					end
				end
				earnedAmount = earnedValue - topValue;
				earnedAmount = earnedAmount - TITANREP_TABLE[name].earnedValue;
			elseif(TITANREP_TABLE[name].standingId == standingId) then
				if(TITANREP_TABLE[name].earnedValue < earnedValue) then
					earnedAmount = earnedValue - TITANREP_TABLE[name].earnedValue;
				else
					earnedAmount = earnedValue - TITANREP_TABLE[name].earnedValue;
				end

			end
			if(TITANREP_RTS[name]) then
				TITANREP_RTS[name] = TITANREP_RTS[name] + earnedAmount;
			else
				TITANREP_RTS[name] = earnedAmount;
			end
			if(earnedAmount > 0) then
				if(TITANREP_HIGHCHANGED < earnedAmount) then
					TITANREP_HIGHCHANGED = earnedAmount;
					TITANREP_CHANGEDFACTION = name;
				end
			elseif(earnedAmount < 0) then
				if(TITANREP_HIGHCHANGED > earnedAmount and TITANREP_HIGHCHANGED < 0) then
					TITANREP_HIGHCHANGED = earnedAmount;
					TITANREP_CHANGEDFACTION = name;
				end
			else
				TITANREP_CHANGEDFACTION = name;
			end
		end
	end
end

-- This method looks up all factions, and calls 'method' with faction parameters
function TitanPanelReputation_GatherFactions(method)
		local count = GetNumFactions();
		local done = false;
		local index = 1;
		local parentName = "";
		while(not done)do
			local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
			canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(index);
			local value;
			-- Normalize values
			topValue = topValue - bottomValue;
			earnedValue = earnedValue - bottomValue;
			bottomValue = 0;
			percent = format("%.2f",(earnedValue/topValue)*100);
			if(percent:len()<5) then percent = "0"..percent; end;
			if(isHeader) then parentName = name; end;
			method(name, parentName, standingId, topValue, earnedValue, percent, isHeader, isCollapsed, IsFactionInactive(index));
			index = index+1;
			if(index>count) then done = true; end;
		end		
end

function TitanReputationFrame_Hide() 
	TitanReputationFrame:Hide(); 
end

function TitanReputationFrame_Show()
	local frame = TitanReputationFrame
	frame:Show();
	frame.animIn:Play();
	TitanReputationFrameGlowFrame.glow.animIn:Play();
	frame.waitAndAnimOut:Stop();
	frame.waitAndAnimOut.animOut:SetStartDelay(4.5);
	frame.waitAndAnimOut:Play();
end
