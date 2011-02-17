local GetSpellBookItemTexture = GetSpellBookItemTexture;

local VUHDO_getHealthBar;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer
local VUHDO_getBarIconCounter
local VUHDO_getBarIconCharge

local VUHDO_FONT_HOTS;
local sHotConfig;
local sHotPos;
local sBarsPos;
local sBarColors;
local sStacksRadio;
local sOutlineText;
local sShadowAlpha;
local sIconRadio;



--
function VUHDO_panelRedrawHotsInitBurst()
	VUHDO_getHealthBar = VUHDO_GLOBAL["VUHDO_getHealthBar"];
	VUHDO_getBarIcon = VUHDO_GLOBAL["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = VUHDO_GLOBAL["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = VUHDO_GLOBAL["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconCharge = VUHDO_GLOBAL["VUHDO_getBarIconCharge"];

	VUHDO_FONT_HOTS = VUHDO_PANEL_SETUP["HOTS"]["font"];
	sHotConfig = VUHDO_PANEL_SETUP["HOTS"];
	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	sHotPos = sHotConfig["radioValue"];
	sBarsPos = sHotConfig["BARS"]["radioValue"];
	sStacksRadio = sHotConfig["stacksRadioValue"];
	sIconRadio = sHotConfig["iconRadioValue"];

	if (sBarColors["HOTS"]["TEXT"]["outline"]) then
		sOutlineText = "OUTLINE";
	else
		sOutlineText = "";
	end

	if (sBarColors["HOTS"]["TEXT"]["shadow"]) then
		sShadowAlpha = 1;
	else
		sShadowAlpha = 0;
	end
end



--
local sBarScaling;
local sBarWidth;
local sHotIconSize;
local sHotFontRatio;
local sHotBarHeight;
function VUHDO_panelRedrwawHotsInitLocalVars(aPanelNum)
	sBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
	sBarWidth = VUHDO_getHealthBarWidth(aPanelNum);
	sHotIconSize = sBarScaling["barHeight"] * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["size"] * 0.01;
	if (sHotIconSize == 0) then
		sHotIconSize = 0.001;
	end
	sHotFontRatio = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["textSize"] * 0.01;
	sHotBarHeight = sBarScaling["barHeight"] * sHotConfig["BARS"]["width"] * 0.01;
end



--
local sButton;
local sHealthBarName;
function VUHDO_initButtonStaticsHots(aButton, aPanelNum)
	sButton = aButton;
	sHealthBarName = VUHDO_getHealthBar(aButton, 1):GetName();
end



--
local tHotBar;
local tHotBarColor;
local tCnt;
local tHotName;
function VUHDO_initHotBars()
	for tCnt = 6, 8 do
		tHotBar = VUHDO_getHealthBar(sButton, tCnt + 3);
		tHotBar:ClearAllPoints();

		tHotName = sHotConfig["SLOTS"][tCnt];
		if (strtrim(tHotName or "") == "") then
			tHotBar:Hide();
		else
			tHotBar:SetWidth(sBarWidth);
			tHotBar:SetHeight(sHotBarHeight);
			tHotBar:SetValue(0);
			tHotBarColor = sBarColors[format("HOT%d", tCnt)];
			tHotBar:SetStatusBarColor(tHotBarColor["R"], tHotBarColor["G"], tHotBarColor["B"], tHotBarColor["O"]);

			if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["turnAxis"]) then
				tHotBar:SetOrientation("HORIZONTAL_INV");
			else
				tHotBar:SetOrientation("HORIZONTAL");
			end

			tHotBar:Show();
		end
	end

	if (sBarsPos == 1) then -- edges
		VUHDO_getHealthBar(sButton, 9):SetPoint("TOP", sHealthBarName, "TOP", 0, 0);
		VUHDO_getHealthBar(sButton, 10):SetPoint("CENTER", sHealthBarName, "CENTER",  0, 0);
		VUHDO_getHealthBar(sButton, 11):SetPoint("BOTTOM", sHealthBarName, "BOTTOM",  0, 0);
	elseif (sBarsPos == 2) then -- center
		VUHDO_getHealthBar(sButton, 9):SetPoint("CENTER", sHealthBarName, "CENTER", 0, sHotBarHeight);
		VUHDO_getHealthBar(sButton, 10):SetPoint("CENTER", sHealthBarName, "CENTER",  0, 0);
		VUHDO_getHealthBar(sButton, 11):SetPoint("CENTER", sHealthBarName, "CENTER",  0, -sHotBarHeight);
	elseif (sBarsPos == 3) then -- top
		VUHDO_getHealthBar(sButton, 9):SetPoint("TOP", sHealthBarName, "TOP", 0, 0);
		VUHDO_getHealthBar(sButton, 10):SetPoint("TOP", sHealthBarName, "TOP",  0, -sHotBarHeight);
		VUHDO_getHealthBar(sButton, 11):SetPoint("TOP", sHealthBarName, "TOP",  0, -2 * sHotBarHeight);
	else -- bottom
		VUHDO_getHealthBar(sButton, 9):SetPoint("BOTTOM", sHealthBarName, "BOTTOM", 0, 0);
		VUHDO_getHealthBar(sButton, 10):SetPoint("BOTTOM", sHealthBarName, "BOTTOM",  0, sHotBarHeight);
		VUHDO_getHealthBar(sButton, 11):SetPoint("BOTTOM", sHealthBarName, "BOTTOM",  0, 2 * sHotBarHeight);
	end

end



--
local tHotIcon;
local tOffset;
local tHotColor;
local tIsBothBottom, tIsBothTop;
local tTimer;
local tCounter;
local tHotName;
local tChargeIcon;
local tTexture;
local tIconFrame;
local function VUHDO_initHotIcon(anIndex)
	tHotIcon = VUHDO_getBarIcon(sButton, anIndex);
	tHotIcon:ClearAllPoints();

	tHotColor = sBarColors[format("HOT%d", anIndex)];

	if (sIconRadio ~= 1) then
		tHotIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"]);
	else
		tHotIcon:SetVertexColor(1, 1, 1);
	end

	if (sHotPos >= 20) then
		tHotIcon:SetWidth(sHotIconSize  * 0.5);
		tHotIcon:SetHeight(sHotIconSize * 0.5);
	else
		tHotIcon:SetWidth(sHotIconSize);
		tHotIcon:SetHeight(sHotIconSize);
	end

	if (anIndex < 9) then
		tOffset = (anIndex - 1) * sHotIconSize;
	else
		tOffset = (anIndex - 4) * sHotIconSize;
	end

	if (sHotPos == 2) then
		tHotIcon:SetPoint("LEFT", sHealthBarName, "LEFT", tOffset,  0); -- li
	elseif (sHotPos == 3) then
		tHotIcon:SetPoint("RIGHT",  sHealthBarName, "RIGHT",  -tOffset, 0); --  ri
	elseif (sHotPos == 1) then
		tHotIcon:SetPoint("RIGHT",  sButton:GetName(), "LEFT", -tOffset, 0); -- lo
	elseif (sHotPos == 4) then
		tHotIcon:SetPoint("LEFT", sButton:GetName(), "RIGHT", tOffset, 0); --  ro
	elseif (sHotPos == 5) then
		tHotIcon:SetPoint("TOPLEFT",  sHealthBarName, "BOTTOMLEFT", tOffset, sHotIconSize * 0.5); -- lb
	elseif (sHotPos == 6) then
		tHotIcon:SetPoint("TOPRIGHT", sHealthBarName, "BOTTOMRIGHT", -tOffset,  sHotIconSize * 0.5); -- rb
	elseif (sHotPos == 7) then
		tHotIcon:SetPoint("TOPLEFT",  sButton:GetName(), "BOTTOMLEFT", tOffset, 0); -- lu
	elseif (sHotPos == 8) then
		tHotIcon:SetPoint("TOPRIGHT", sButton:GetName(), "BOTTOMRIGHT", -tOffset,  0); -- ru
	elseif (sHotPos == 9) then
		tHotIcon:SetPoint("TOPLEFT",  sHealthBarName, "TOPLEFT",  tOffset,  sBarScaling["barHeight"] / 3); -- la
	elseif (sHotPos == 10) then
		tHotIcon:SetPoint("TOPLEFT",  sHealthBarName, "TOPLEFT", tOffset,  0); -- lu corner
	elseif (sHotPos == 12) then
		tHotIcon:SetPoint("BOTTOMLEFT", sHealthBarName, "BOTTOMLEFT",  tOffset, 0);  -- lb corner
	elseif (sHotPos == 11) then
		tHotIcon:SetPoint("BOTTOMRIGHT", sHealthBarName, "BOTTOMRIGHT", -tOffset, 0);  -- rb corner
	elseif (sHotPos == 13) then
		tHotIcon:SetPoint("BOTTOMLEFT",  sButton:GetName(), "BOTTOMLEFT", tOffset, 0); -- lb
	elseif (sHotPos == 14) then
		tHotIcon:SetPoint("BOTTOMRIGHT", sButton:GetName(), "BOTTOMRIGHT", -tOffset,  0); -- rb

	elseif (sHotPos == 20) then
		tIsBothBottom = sHotConfig["SLOTS"][4] ~= nil	and sHotConfig["SLOTS"][5] ~= nil;
		tIsBothTop = sHotConfig["SLOTS"][2] ~= nil	and sHotConfig["SLOTS"][9] ~= nil;

		if (anIndex == 1) then
			tHotIcon:SetPoint("LEFT", sHealthBarName, "LEFT", 0, 0);
		elseif (anIndex  == 2) then
			if (tIsBothTop)  then
				tHotIcon:SetPoint("TOP",  sHealthBarName, "TOP",  -sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("TOP",  sHealthBarName, "TOP",  0, 0);
			end
		elseif (anIndex == 9) then
			if (tIsBothTop)  then
				tHotIcon:SetPoint("TOP",  sHealthBarName, "TOP",  sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("TOP",  sHealthBarName, "TOP",  0, 0);
			end
		elseif (anIndex == 3) then
			tHotIcon:SetPoint("RIGHT",  sHealthBarName, "RIGHT",  0, 0);
		elseif (anIndex  == 4) then
			if (tIsBothBottom)  then
				tHotIcon:SetPoint("BOTTOM", sHealthBarName, "BOTTOM", sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("BOTTOM", sHealthBarName, "BOTTOM", 0, 0);
			end
		elseif (anIndex == 5) then
			if (tIsBothBottom)  then
				tHotIcon:SetPoint("BOTTOM", sHealthBarName, "BOTTOM", -sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("BOTTOM", sHealthBarName, "BOTTOM", 0, 0);
			end
		elseif (anIndex == 10) then
			tHotIcon:SetPoint("CENTER", sHealthBarName, "CENTER", 0, 0);
		end
	elseif (sHotPos == 21) then
		if (anIndex == 1) then
			tHotIcon:SetPoint("TOPLEFT",  sHealthBarName, "TOPLEFT",  0, 0);
		elseif (anIndex == 2) then
			tHotIcon:SetPoint("TOPRIGHT", sHealthBarName, "TOPRIGHT", 0, 0);
		elseif (anIndex == 3) then
			tHotIcon:SetPoint("BOTTOMLEFT", sHealthBarName, "BOTTOMLEFT", 0, 0);
		elseif (anIndex == 4) then
			tHotIcon:SetPoint("BOTTOMRIGHT",  sHealthBarName, "BOTTOMRIGHT",  0, 0);
		elseif (anIndex == 5) then
			tHotIcon:SetPoint("BOTTOM", sHealthBarName, "BOTTOM", 0, 0);
		elseif (anIndex == 9) then
			tHotIcon:SetPoint("TOP", sHealthBarName, "TOP", 0, 0);
		elseif (anIndex == 10) then
			tHotIcon:SetPoint("CENTER", sHealthBarName, "CENTER", 0, 0);
		end
	end

	tTimer  = VUHDO_getBarIconTimer(sButton, anIndex);
	tCounter = VUHDO_getBarIconCounter(sButton, anIndex);

	tHotIcon:SetAlpha(0);
	tTimer:SetText("");
	tCounter:SetText("");

	tHotIcon:Show();
	tTimer:Show();
	tCounter:Show();

	tTimer:ClearAllPoints();

	tHotName = sHotConfig["SLOTS"][anIndex];

	if (tHotName  ~= nil) then
		tTimer:SetShadowOffset(1, -0.5);
		tTimer:SetShadowColor(0, 0, 0, sShadowAlpha);

		if (sStacksRadio == 2 or "CLUSTER" == tHotName) then -- Counter text
			tHotIcon:SetVertexColor(1, 1, 1);
			tTimer:SetPoint("BOTTOMRIGHT", tHotIcon:GetName(), "BOTTOMRIGHT", 2, 0);
			if (sHotIconSize > 1) then
				tTimer:SetFont(VUHDO_FONT_HOTS, tHotIcon:GetHeight() / 1.7 * sHotFontRatio, sOutlineText);
			else
				tTimer:Hide();
			end
			tCounter:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"]);
		else
			tTimer:SetPoint("CENTER", tHotIcon:GetName(), "CENTER", 1, 0);
			tTimer:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]);
			if (sHotIconSize > 1) then
				tTimer:SetFont(VUHDO_FONT_HOTS, tHotIcon:GetHeight() / 1.2 * sHotFontRatio, sOutlineText);
			else
				tTimer:Hide();
			end
			tCounter:Hide();
		end

		if ("CLUSTER" == tHotName) then
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\cluster2");
		elseif (sIconRadio == 3) then -- Flat
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16");
		elseif (sIconRadio == 2) then -- Glossy
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\icon_white_square");
		else
			if (VUHDO_CAST_ICON_DIFF[tHotName] ~= nil and VUHDO_CAST_ICON_DIFF[tHotName] ~= "*") then
				tHotIcon:SetTexture(VUHDO_CAST_ICON_DIFF[tHotName]);
			else
				tTexture = GetSpellBookItemTexture(tHotName);
				if (tTexture ~= nil) then
					tHotIcon:SetTexture(tTexture);
				end
			end
		end

		tChargeIcon = VUHDO_getBarIconCharge(sButton, anIndex);
		tChargeIcon:SetWidth(tHotIcon:GetWidth() + 4);
		tChargeIcon:SetHeight(tHotIcon:GetHeight() + 4);
		tChargeIcon:SetVertexColor(tHotColor["R"] * 2, tHotColor["G"] * 2, tHotColor["B"] * 2);
		tChargeIcon:Hide();
		tChargeIcon:SetPoint("TOPLEFT", tHotIcon:GetName(), "TOPLEFT", -2, 2);

		if (tHotColor["countdownMode"] == 0 or sHotIconSize < 1) then
			tTimer:Hide();
		else
			tTimer:Show();
		end
	end

	tCounter:SetPoint("TOPLEFT", tHotIcon:GetName(), "TOPLEFT",  -2, 0);

	if (sHotIconSize > 1) then
		tCounter:SetFont(VUHDO_FONT_HOTS, tHotIcon:GetHeight() / 1.5 * sHotFontRatio, sOutlineText);
	else
		tCounter:Hide();
	end
	tCounter:SetShadowColor(0, 0, 0, sShadowAlpha);
	tCounter:SetShadowOffset(1, -0.5);
end



--
local tCnt;
function VUHDO_initAllHotIcons()
	for tCnt  = 1, 5 do
		VUHDO_initHotIcon(tCnt);
	end
	for tCnt  = 9, 10 do
		VUHDO_initHotIcon(tCnt);
	end
end
