local VUHDO_PI, VUHDO_2_PI = math.pi, math.pi * 2;
local WorldMapFrame = WorldMapFrame;
local GetMouseFocus = GetMouseFocus;
local GetPlayerFacing = GetPlayerFacing;
local GetPlayerMapPosition = GetPlayerMapPosition;
local floor = floor;
local VUHDO_atan2 = math.atan2;
local tOldButton;
local sIsDeadOnly;
local sIsAlways;
local sIsDistanceText;
local sScale;
local VuhDoDirectionFrame;
local VuhDoDirectionFrameArrow;
local VuhDoDirectionFrameText;
local VUHDO_setMapToCurrentZone;

local VUHDO_RAID = { };
function VUHDO_directionsInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	sIsDeadOnly = VUHDO_CONFIG["DIRECTION"]["isDeadOnly"];
	sIsAlways = VUHDO_CONFIG["DIRECTION"]["isAlways"];
	sIsDistanceText = VUHDO_CONFIG["DIRECTION"]["isDistanceText"];
	sScale = VUHDO_CONFIG["DIRECTION"]["scale"] * 0.01;
	VuhDoDirectionFrame = VUHDO_GLOBAL["VuhDoDirectionFrame"];
	VuhDoDirectionFrameArrow = VUHDO_GLOBAL["VuhDoDirectionFrameArrow"];
	VuhDoDirectionFrameText = VUHDO_GLOBAL["VuhDoDirectionFrameText"];
	VUHDO_setMapToCurrentZone = VUHDO_GLOBAL["VUHDO_setMapToCurrentZone"];
	tOldButton = nil;
end



--
local tFacing;
local function VUHDO_getPlayerFacing()
	tFacing = GetPlayerFacing();
	if (tFacing < 0) then
		return tFacing + VUHDO_2_PI;
	else
		return tFacing;
	end
end



--
local tPlayerX, tPlayerY;
local tUnitX, tUnitY;
local function VUHDO_getUnitDirection(aUnit)
	if ((WorldMapFrame ~= nil and WorldMapFrame:IsShown())
		or (GetMouseFocus() ~= nil and GetMouseFocus():GetName() == nil)) then
		return nil;
	end

	tPlayerX, tPlayerY = GetPlayerMapPosition("player");
	if ((tPlayerX or 0) + (tPlayerY or 0) <= 0) then
		VUHDO_setMapToCurrentZone();
		tPlayerX, tPlayerY = GetPlayerMapPosition("player");
		if ((tPlayerX or 0) + (tPlayerY or 0) <= 0) then
			return nil;
		end
	end

	tUnitX, tUnitY = GetPlayerMapPosition(aUnit);
	if ((tUnitX or 0) + (tUnitY or 0) <= 0) then
		return nil;
	end

	return VUHDO_PI - VUHDO_atan2(tPlayerX - tUnitX, tUnitY - tPlayerY) - VUHDO_getPlayerFacing();
end



--
local tUnit;
local tCell;
local sLastCell = nil;
local tStartX, tStartY;
local tButton = nil;
local tHeight;
local tInfo;
local tDistance;
local tHeight;
local tQuota;
local tR1, tG1, tInvModi;
function VUHDO_updateDirectionFrame(aButton)
	if (aButton ~= nil) then
		tButton = aButton;
	elseif (tButton == nil) then
		return;
	end

	tUnit = tButton:GetAttribute("unit");
	tInfo = VUHDO_RAID[tUnit];

	if (UnitIsUnit("player", tUnit)
		or tInfo == nil
		or (tInfo["range"] and not sIsAlways)
		or (sIsDeadOnly and not tInfo["dead"])
		or not tInfo["connected"]
		or tInfo["isPet"]) then

		VuhDoDirectionFrame["shown"] = false;
		VuhDoDirectionFrame:Hide();
		return;
	end

	tDirection = VUHDO_getUnitDirection(tUnit);
	if (tDirection == nil) then
		VuhDoDirectionFrame["shown"] = false;
		VuhDoDirectionFrame:Hide();
		return;
	end

	tCell = floor(tDirection / VUHDO_2_PI * 108 + 0.5) % 108;
	if (tCell ~= sLastCell) then
		sLastCell = tCell;
		tStartX = (tCell % 9) * 0.109375;
		tStartY = floor(tCell / 9) * 0.08203125;
		VuhDoDirectionFrameArrow:SetTexCoord(tStartX, tStartX + 0.109375, tStartY, tStartY + 0.08203125);
	end

	if (sIsDistanceText) then
		tDistance = VUHDO_getDistanceBetween("player", tUnit);
		if ((tDistance or 0) > 0) then
			VuhDoDirectionFrameText:SetText(floor(tDistance + 0.5));
			tQuota = (tDistance - 40) * 0.05;
			if (tQuota > 2) then
				tQuota = 2;
			elseif(tQuota < 0) then
				tQuota = 0;
			end
			tQuota = 2 - tQuota;

			if (tQuota > 1) then
				tR1, tG1, tR2, tG2 = 0, 1, 1, 1;
				tQuota = tQuota - 1;
			else
				tR1, tG1, tR2, tG2 = 1, 1, 1, 0;
			end

			tInvModi = 1 - tQuota;
			tDestR = tR2 * tInvModi + tR1 * tQuota;
			tDestG = tG2 * tInvModi + tG1 * tQuota;

			VuhDoDirectionFrameText:SetTextColor(tDestR, tDestG, 0.2, 0.8);
			VuhDoDirectionFrameArrow:SetVertexColor(tDestR, tDestG, 0);
		else
			VuhDoDirectionFrameText:SetText("");
		end
	else
		VuhDoDirectionFrameText:SetText("");
	end

	if (tOldButton ~= tButton) then
		tHeight = tButton:GetHeight() * sScale;
		VuhDoDirectionFrame:SetPoint("CENTER", tButton:GetName(), "CENTER", 0, 0);
		VuhDoDirectionFrame:SetWidth(tHeight);
		VuhDoDirectionFrame:SetHeight(tHeight);
	end
	VuhDoDirectionFrame:Show();
	VuhDoDirectionFrame["shown"] = true;

	tOldButton = tButton;
end
