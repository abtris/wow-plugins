VUHDO_LibSharedMedia = LibStub("LibSharedMedia-3.0");
VUHDO_LibDataBroker = LibStub("LibDataBroker-1.1", true);
VUHDO_LibButtonFacade = nil;

VUHDO_LibSharedMedia:Register("font", "Arial Black", "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf");
VUHDO_LibSharedMedia:Register("font", "Emblem",	"Interface\\AddOns\\VuhDo\\Fonts\\Emblem.ttf");

VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Rhombs", "Interface\\AddOns\\VuhDo\\Images\\bar1.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Twirls", "Interface\\AddOns\\VuhDo\\Images\\bar2.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Pipe, dark", "Interface\\AddOns\\VuhDo\\Images\\bar3.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Concave, dark", "Interface\\AddOns\\VuhDo\\Images\\bar4.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Pipe, light", "Interface\\AddOns\\VuhDo\\Images\\bar5.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Flat", "Interface\\AddOns\\VuhDo\\Images\\bar6.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Concave, light", "Interface\\AddOns\\VuhDo\\Images\\bar7.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Convex", "Interface\\AddOns\\VuhDo\\Images\\bar8.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Textile", "Interface\\AddOns\\VuhDo\\Images\\bar9.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Mirrorfinish", "Interface\\AddOns\\VuhDo\\Images\\bar10.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Diagonals", "Interface\\AddOns\\VuhDo\\Images\\bar11.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Zebra", "Interface\\AddOns\\VuhDo\\Images\\bar12.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Marble", "Interface\\AddOns\\VuhDo\\Images\\bar13.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Modern Art", "Interface\\AddOns\\VuhDo\\Images\\bar14.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Polished Wood", "Interface\\AddOns\\VuhDo\\Images\\bar15.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Plain", "Interface\\AddOns\\VuhDo\\Images\\bar16.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Minimalist", "Interface\\AddOns\\VuhDo\\Images\\bar17.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Aluminium", "Interface\\AddOns\\VuhDo\\Images\\bar18.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Bar Highlighter", "Interface\\AddOns\\VuhDo\\Images\\highlight.tga");
VUHDO_LibSharedMedia:Register("statusbar", "LiteStepLite", "Interface\\AddOns\\VuhDo\\Images\\LiteStepLite.tga");

VUHDO_LibSharedMedia:Register("sound", "Tribal Bass Drum", "Sound\\Doodad\\BellTollTribal.wav");
VUHDO_LibSharedMedia:Register("sound", "Thorns", "Sound\\Spells\\Thorns.wav	");
VUHDO_LibSharedMedia:Register("sound", "Elf Bell Toll", "Sound\\Doodad\\BellTollNightElf.wav");

LoadAddOn("FuBarPlugin-3.0");



--
function VUHDO_parseAddonMessage(anArg1, anArg2, anArg3, anArg4)
	if ("CTRA" == anArg1) then
		local tNick = anArg4;
		local tMessage = anArg2;
		if (strfind(tMessage, "#")) then
			local tFragments = VUHDO_splitString(tMessage, "#");
			local tCommand;
			for _, tCommand in pairs(tFragments) do
				VUHDO_parseCtraMessage(tNick, tCommand);
			end
		else
			VUHDO_parseCtraMessage(tNick, tMessage);
		end
	end
end



--
function VUHDO_initFuBar()
	-- libDataBroker
	if (VUHDO_LibDataBroker ~= nil) then
		VUHDO_LibDataBroker:NewDataObject("VuhDo", {
			type = "launcher",
			icon = "Interface\\AddOns\\VuhDo\\Images\\VuhDo",
			OnClick = function(aClickedFrame, aButton)
				if (aButton == "RightButton") then
					ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, aClickedFrame:GetName(), 0, -5);
				else
					VUHDO_slashCmd("opt");
				end
			end,
			OnTooltipShow = function(aTooltip)
				aTooltip:AddLine("VuhDo")
				aTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_1)
				aTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_2)
			end,
		})
	end

	-- Native FuBar
	if (LibStub:GetLibrary("LibFuBarPlugin-3.0", true)
		and IsAddOnLoaded("FuBar")
		and not IsAddOnLoaded("FuBar2Broker")
		and not IsAddOnLoaded("Broker2FuBar")) then

		local tLibFuBarPlugin = LibStub:GetLibrary("LibFuBarPlugin-3.0");
		LibStub("AceAddon-3.0"):EmbedLibrary(VuhDo, "LibFuBarPlugin-3.0");
		VuhDo:SetFuBarOption("tooltipType", "GameTooltip");
		VuhDo:SetFuBarOption("hasNoColor", true);
		VuhDo:SetFuBarOption("cannotDetachTooltip", true);
		VuhDo:SetFuBarOption("hideWithoutStandby", true);
		VuhDo:SetFuBarOption("iconPath", [[Interface\AddOns\VuhDo\Images\VuhDo]]);
		VuhDo:SetFuBarOption("hasIcon", true);
		VuhDo:SetFuBarOption("defaultPosition", "RIGHT");
		VuhDo:SetFuBarOption("tooltipHiddenWhenEmpty", true);
		VuhDo:SetFuBarOption("configType", "None");
		VuhDo.title = "VuhDo";
		VuhDo.name = "VuhDo";
		tLibFuBarPlugin:OnEmbedInitialize(VuhDo, VuhDo);
		function VuhDo:OnUpdateFuBarTooltip()
			GameTooltip:AddLine("VuhDo");
			GameTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_1);
			GameTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_2);
		end
		VuhDo:Show();
		function VuhDo:OnFuBarClick(aButton)
			if ("LeftButton" == aButton) then
				VUHDO_slashCmd("opt");
			elseif ("RightButton" == aButton) then
				ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, VuhDo:GetFrame():GetName(), 0, -5);
			end
		end
	end
end



--
function VUHDO_initSharedMedia()
	local tIndex, tValue;

	-- fonts
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List('font')) do
		VUHDO_FONTS[tIndex] = { VUHDO_LibSharedMedia:Fetch('font', tValue), tValue };
	end

	-- status bars
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List('statusbar')) do
		VUHDO_STATUS_BARS[tIndex] = { tValue, tValue };
	end

	-- sounds
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List('sound')) do
		VUHDO_SOUNDS[tIndex] = { VUHDO_LibSharedMedia:Fetch('sound', tValue), tValue };
	end
	tinsert(VUHDO_SOUNDS, 1, { nil, "-- " .. VUHDO_I18N_OFF .. " --" } );

	-- borders
	for tIndex, tValue in ipairs(VUHDO_LibSharedMedia:List('border')) do
		VUHDO_BORDERS[tIndex] = { VUHDO_LibSharedMedia:Fetch('border', tValue), tValue };
	end
end



--
function VUHDO_initCliqueSupport()
	if (not VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"]) then
		return;
	end

	if (not IsAddOnLoaded("Clique")) then
		VUHDO_Msg("WARNING: Clique compatibility mode is enabled but clique doesn't seem to be loaded!", 1, 0.4, 0.4);
	end

	ClickCastFrames = ClickCastFrames or {};

	local tPanelNum, tButtonNum, tIconNum;
	local tBtnName;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for tButtonNum = 1, 51 do -- VUHDO_MAX_BUTTONS_PANEL
			tBtnName = format("VdAc%dHlU%d", tPanelNum, tButtonNum);
			if (VUHDO_GLOBAL[tBtnName] ~= nil) then
				ClickCastFrames[VUHDO_GLOBAL[tBtnName]] = true;
				ClickCastFrames[VUHDO_GLOBAL[tBtnName .. "Tg"]] = true;
				ClickCastFrames[VUHDO_GLOBAL[tBtnName .. "Tot"]] = true;
				for tIconNum = 40, 44 do
					ClickCastFrames[VUHDO_GLOBAL[format("%sBgBarIcBarHlBarIc%d", tBtnName, tIconNum)]] = true;
				end
			end
		end
	end
end



--
function VuhDo:VUHDO_buttonFacadeCallback(aSkinId, aGloss, aBackdrop, aGroup, aButton, aColors)
	if (VUHDO_I18N_BUFF_WATCH == aGroup) then
		VUHDO_BUFF_SETTINGS["CONFIG"]["BUTTON_FACADE"] = aSkinId;
	end

	if (VUHDO_I18N_HOTS == aGroup) then
		VUHDO_PANEL_SETUP["HOTS"]["BUTTON_FACADE"] = aSkinId;
	end

	--[[if (VUHDO_I18N_DEBUFFS == aGroup) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["BUTTON_FACADE"] = aSkinId;
	end]] -- geht nicht, weil icon kein button sein darf (onenter/onleave)
end



--
function VUHDO_initButtonFacade(anInstance)
	if (VUHDO_CONFIG["IS_USE_BUTTON_FACADE"]) then
		VUHDO_LibButtonFacade = LibStub("LibButtonFacade", true);
	else
		VUHDO_LibButtonFacade = nil;
	end

	if (VUHDO_LibButtonFacade ~= nil) then
		VUHDO_LibButtonFacade:RegisterSkinCallback("VuhDo", VuhDo["VUHDO_buttonFacadeCallback"], anInstance);
		VUHDO_LibButtonFacade:Group("VuhDo", VUHDO_I18N_BUFF_WATCH);
		VUHDO_LibButtonFacade:Group("VuhDo", VUHDO_I18N_HOTS);
		--VUHDO_LibButtonFacade:Group("VuhDo", VUHDO_I18N_DEBUFFS);
	end
end
