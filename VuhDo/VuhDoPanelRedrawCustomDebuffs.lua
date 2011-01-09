
local VUHDO_FONT_HOTS;
local sDebuffConfig;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer;
local VUHDO_getBarIconCounter;
local VUHDO_getBarIconName;
local sSign;
local sMaxNum;
local sPoint;

function VUHDO_panelRedrawCustomDebuffsInitBurst()
	VUHDO_FONT_HOTS = VUHDO_PANEL_SETUP["HOTS"]["font"];
	VUHDO_getBarIcon = VUHDO_GLOBAL["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = VUHDO_GLOBAL["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = VUHDO_GLOBAL["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconName = VUHDO_GLOBAL["VUHDO_getBarIconName"];

	sDebuffConfig = VUHDO_CONFIG["CUSTOM_DEBUFF"];

	if ("TOPLEFT" == sDebuffConfig["point"] or "BOTTOMLEFT" == sDebuffConfig["point"]) then
		sSign = 1;
	else
		sSign = -1;
	end

	sMaxNum = sDebuffConfig["max_num"];
	sPoint = sDebuffConfig["point"];
end



--
local sBarScaling;
local sXOffset, sYOffset;
local sHeight;
local sStep;
function VUHDO_panelRedrwawCustomDebuffsInitLocalVars(aPanelNum)
	sBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
	sXOffset = sDebuffConfig["xAdjust"] * sBarScaling["barWidth"] * 0.01;
	sYOffset = -sDebuffConfig["yAdjust"] * sBarScaling["barHeight"] * 0.01;
	sHeight = sBarScaling["barHeight"];

	if (VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TEXT"]["outline"]) then
		sShadowAlpha = 0;
		sOutlineText = "OUTLINE";
	else
		sShadowAlpha = 1;
		sOutlineText = "";
	end

	sStep = sSign * sHeight;
end


local sButton;
local sHealthBar;
function VUHDO_initButtonStaticsCustomDebuffs(aButton, aPanelNum)
	sButton = aButton;
	sHealthBar = VUHDO_getHealthBar(aButton, 1);
end




--
local tIcon,  tCounter, tName;
local tCnt;
local tIconIdx;
local tIconName;
function VUHDO_initCustomDebuffs()
	for tCnt = 0, sMaxNum - 1 do
		tIconIdx = 40 + tCnt;

		tIcon = VUHDO_getBarIcon(sButton, tIconIdx);

		tIcon:ClearAllPoints();
		tIcon:SetPoint(sPoint, sHealthBar:GetName(), sPoint,
			 sXOffset + (tCnt * sStep), sYOffset); -- center
		tIcon:SetWidth(sHeight);
		tIcon:SetHeight(sHeight);

		tIconName = tIcon:GetName();

		tTimer = VUHDO_getBarIconTimer(sButton, tIconIdx);
		tTimer:SetPoint("BOTTOMRIGHT", tIconName, "BOTTOMRIGHT", 3, -3);
		tTimer:SetFont(VUHDO_FONT_HOTS, 18, sOutlineText);
		tTimer:SetShadowColor(0, 0, 0, sShadowAlpha);
		tTimer:SetShadowOffset(1, -0.5);
		tTimer:SetText("");
		tTimer:Show();

		tCounter = VUHDO_getBarIconCounter(sButton, tIconIdx);
		tCounter:SetPoint("TOPLEFT", tIconName, "TOPLEFT", 0, 5);
		tCounter:SetFont(VUHDO_FONT_HOTS, 15, sOutlineText);
		tCounter:SetShadowColor(0, 0, 0, sShadowAlpha);
		tCounter:SetShadowOffset(1, -0.5);
		tCounter:SetTextColor(0, 1, 0, 1);
		tCounter:SetText("");
		tCounter:Show();

		tName = VUHDO_getBarIconName(sButton, tIconIdx);
		tName:SetPoint("BOTTOM", tIconName, "TOP", 0, 0);
		tName:SetFont(GameFontNormalSmall:GetFont(), 12, sOutlineText, "");
		tName:SetShadowColor(0, 0, 0, sShadowAlpha);
		tName:SetShadowOffset(1, -0.5);
		tName:SetTextColor(1, 1, 1, 1);
		tName:SetText("");
		tName:Show();
	end

	for tCnt = sMaxNum + 40, 44 do
		tIcon = VUHDO_getBarIcon(sButton, tCnt);
		tIcon:ClearAllPoints();
		tIcon:Hide();
	end
end
