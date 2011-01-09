local VUHDO_GLOBAL = getfenv();

local tNameGroup = { };
local VUHDO_BUFF_RAID = { };
local VUHDO_BUFF_RAID_FILTERED = { };

local VUHDO_PLAYER_GROUP = { "player" };

local VUHDO_BS_COLOR_EMPTY = 1;
local VUHDO_BS_COLOR_CD = 2;
local VUHDO_BS_COLOR_LOW = 3;
local VUHDO_BS_COLOR_MISSING = 4;
local VUHDO_BS_COLOR_OKAY = 5;


local VUHDO_NUM_LOWS = { };

local VUHDO_LAST_COLORS = { };

--
VUHDO_BUFFS = { };
local VUHDO_BUFFS = VUHDO_BUFFS;
VUHDO_BUFF_SETTINGS = { };
--local VUHDO_BUFF_SETTINGS = VUHDO_BUFF_SETTINGS;

local VUHDO_CLICKED_BUFF = nil;
local VUHDO_CLICKED_TARGET = nil;
local VUHDO_IS_USED_SMART_BUFF;

VUHDO_BUFF_ORDER = { };




-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID;
local VUHDO_RAID_NAMES;

local VUHDO_getBuffVariantMaxTarget;
local VUHDO_tableUniqueAdd;
local VUHDO_isInSameZone;
local VUHDO_isInBattleground;
local VUHDO_brightenTextColor;

local UnitBuff = UnitBuff;
local GetTotemInfo = GetTotemInfo;
local table = table;
local strsub = strsub;
local GetTime = GetTime;
local GetSpellCooldown = GetSpellCooldown;
local GetSpellBookItemName = GetSpellBookItemName;
local GetSpellInfo = GetSpellInfo;
local InCombatLockdown = InCombatLockdown;

local GetWeaponEnchantInfo = GetWeaponEnchantInfo;
local tonumber = tonumber;
local tinsert = tinsert;
local pairs = pairs;
local ipairs = ipairs;
local twipe = table.wipe;
local _ = _;
local format = format;

local sConfig = { };
local sRebuffSecs;
local sRebuffPerc;

-----------------------------------------------------------------------------
function VUHDO_buffWatchInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];

	VUHDO_getBuffVariantMaxTarget = VUHDO_GLOBAL["VUHDO_getBuffVariantMaxTarget"];
	VUHDO_tableUniqueAdd = VUHDO_GLOBAL["VUHDO_tableUniqueAdd"];
	VUHDO_isInSameZone = VUHDO_GLOBAL["VUHDO_isInSameZone"];
	VUHDO_isInBattleground = VUHDO_GLOBAL["VUHDO_isInBattleground"];
	VUHDO_brightenTextColor = VUHDO_GLOBAL["VUHDO_brightenTextColor"];

	sConfig = VUHDO_BUFF_SETTINGS["CONFIG"];
	sRebuffSecs = sConfig["REBUFF_MIN_MINUTES"] * 60;
	sRebuffPerc = sConfig["REBUFF_AT_PERCENT"] * 0.01;
end

----------------------------------------------------



--
function VUHDO_buffWatchOnMouseDown(aPanel)
	if (VUHDO_mayMoveHealPanels()) then
		aPanel:StartMoving();
	end
end



--
function VUHDO_buffWatchOnMouseUp(aPanel)
	if (VUHDO_mayMoveHealPanels()) then
		aPanel:StopMovingOrSizing();

		local tCoords = VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"];
		tCoords["point"], _, tCoords["relativePoint"], tCoords["x"], tCoords["y"] = aPanel:GetPoint();
	end
end



--
local tCopy = { };
local function VUHDO_copyColor(aColor)
	tCopy["R"], tCopy["G"], tCopy["B"], tCopy["O"] = aColor["R"], aColor["G"], aColor["B"], aColor["O"];
	tCopy["TR"], tCopy["TG"], tCopy["TB"], tCopy["TO"] = aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"];
	tCopy["useBackground"], tCopy["useText"], tCopy["useOpacity"] = aColor["useBackground"], aColor["useText"], aColor["useOpacity"];
	return tCopy;
end



--
local tVariants;
local tMaxVariant;
function VUHDO_isUseSingleBuff(aSwatch)
	tVariants = aSwatch:GetAttribute("buff");
	tMaxVariant = VUHDO_getBuffVariantMaxTarget(tVariants);

	if (VUHDO_BUFF_TARGET_SINGLE ~= tMaxVariant[2]) then
		return false;
	end

	if (aSwatch:GetAttribute("lowtarget") == nil or InCombatLockdown()) then
		return 2;
	end

	return true;
end



--
local function VUHDO_setupBuffButtonAttributes(aModifierKey, aButtonId, anActionName, aButton)
	if ((anActionName or "") ~= "") then
		aButton:SetAttribute(aModifierKey .. "type" .. aButtonId, "spell");
		aButton:SetAttribute(aModifierKey .. "spell" .. aButtonId, anActionName);
	else
		aButton:SetAttribute(aModifierKey .. "type" .. aButtonId, "");
	end
end



--
function VUHDO_setupAllBuffButtonUnits(aButton, aUnit)
	if (not InCombatLockdown()) then
		aButton:SetAttribute("unit", aUnit or "_foo");
	end
end



--
local tSpellDescr;
local tModiKey, tButtonId;
function VUHDO_setupAllBuffButtonsTo(aButton, aBuffName, aUnit, aMaxTargetBuff)
	if (InCombatLockdown()) then
		return;
	end

	VUHDO_setupAllBuffButtonUnits(aButton, aUnit);

	for _, tSpellDescr in pairs(VUHDO_SPELL_ASSIGNMENTS) do
		tModiKey = tSpellDescr[1];
		tButtonId = tonumber(tSpellDescr[2]);

		if (tButtonId == 2) then
			VUHDO_setupBuffButtonAttributes(tModiKey, tButtonId, nil, aButton);
		elseif (tButtonId == 1) then
			VUHDO_setupBuffButtonAttributes(tModiKey, tButtonId, aBuffName, aButton);
		else
			VUHDO_setupBuffButtonAttributes(tModiKey, tButtonId, aMaxTargetBuff, aButton);
		end
	end
end



--
function VUHDO_buffSelectDropdownOnLoad()
	UIDropDownMenu_Initialize(VuhDoBuffSelectDropdown, VUHDO_buffSelectDropdown_Initialize, "MENU", 1);
end



--
function VUHDO_buffSelectDropdown_Initialize(_, _)
	if (VUHDO_CLICKED_BUFF == nil or VUHDO_CLICKED_TARGET == nil or InCombatLockdown()) then
		return;
	end

	local tCategSepc = VUHDO_getBuffCategory(VUHDO_CLICKED_BUFF);
	local tCategName = strsub(tCategSepc, 3);
	local tCateg = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS][tCategSepc];
	local tSettings = VUHDO_BUFF_SETTINGS[tCategName];
	local tMaxVariant = VUHDO_getBuffVariantMaxTarget(tCateg[1]);
	local tMaxTarget = tMaxVariant[2];

	if (#tCateg > 1) then
		local tCategBuff;
		local tInfo;

		for _, tCategBuff in ipairs(tCateg) do
			local tSingleBuff = VUHDO_getBuffVariantMaxTarget(tCategBuff)[1];

			if (VUHDO_BUFFS[tSingleBuff] ~= nil and VUHDO_BUFFS[tSingleBuff]["present"]) then
				tInfo = UIDropDownMenu_CreateInfo();
				tInfo["text"] = tSingleBuff;
				tInfo["keepShownOnClick"] = false;
				tInfo["icon"] = VUHDO_BUFFS[tSingleBuff]["icon"];
				tInfo["arg1"] = tCategName;
				tInfo["func"] = VUHDO_buffSelectDropdownBuffSelected;
				tInfo["arg2"] = tSingleBuff;

				tInfo["checked"] = tSettings["buff"] == tSingleBuff;
				UIDropDownMenu_AddButton(tInfo);
			end

		end

	elseif (VUHDO_BUFF_TARGET_RAID == tMaxTarget or VUHDO_BUFF_TARGET_SINGLE == tMaxTarget) then
		local tInfo;
		local tText;
		tInfo = UIDropDownMenu_CreateInfo();
		tInfo["text"] = VUHDO_I18N_TRACK_BUFFS_FOR;
		tInfo["isTitle"] = true;
		tInfo["notCheckable"] = true;
		UIDropDownMenu_AddButton(tInfo);

		for _, tFilter in pairs(VUHDO_BUFF_FILTER_COMBO_TABLE) do
			tInfo = UIDropDownMenu_CreateInfo();
			tText = tFilter[2];
			tInfo["text"] = tText;
			tInfo["checked"] = VUHDO_BUFF_SETTINGS[tCategName]["filter"][tFilter[1]];
			tInfo["arg1"] = tCategName;
			tInfo["arg2"] = tFilter[1];
			tInfo["func"] = VUHDO_buffSelectDropdownFilterSelected;
			tInfo["isTitle"] = false;
			tInfo["disabled"] = false;

			UIDropDownMenu_AddButton(tInfo);
		end

	else
		VuhDoBuffSelectDropdown:Hide();

		local tTargetType = strsub(VUHDO_CLICKED_TARGET, 1, 1);
		if (tTargetType == "N") then
			local tName;
			local tSelName = nil;
			local tNextSel = false;
			if (VUHDO_RAID_NAMES[tSettings["name"]] ~= nil) then
				for tName, _ in pairs(VUHDO_RAID_NAMES) do
					if (tName ~= "player") then
						if (tSelName == nil or tNextSel) then
							tSelName = tName;

							if (tNextSel) then
								break;
							end
						end
						if (tName == tSettings["name"]) then
							tNextSel = true;
						end
					end
				end

				tSettings["name"] = tSelName;
				VUHDO_reloadBuffPanel();
			else
				tSettings["name"] = VUHDO_PLAYER_NAME;
			end
		end
	end

end



--
function VUHDO_buffSelectDropdownBuffSelected(_, aCategoryName, aBuffName)
	if (aCategoryName ~= nil) then
		VUHDO_BUFF_SETTINGS[aCategoryName]["buff"] = aBuffName;
		VUHDO_reloadBuffPanel();
	end
end



--
function VUHDO_buffSelectDropdownFilterSelected(_, aCategName, aFilterValue)
	if (aCategName ~= nil) then
		local tAllFilters = VUHDO_BUFF_SETTINGS[aCategName]["filter"];
		if (VUHDO_ID_ALL == aFilterValue) then
			twipe(tAllFilters);
			tAllFilters[VUHDO_ID_ALL] = true;
		else
			if (tAllFilters[aFilterValue]) then
				tAllFilters[aFilterValue] = nil;
			else
				tAllFilters[aFilterValue] = true;
			end
			tAllFilters[VUHDO_ID_ALL] = nil;
		end

		VUHDO_updateBuffFilters();
	end
end



--
function VuhDoBuffPreClick(aButton, aMouseButton)
	local tSwatch = aButton:GetParent();
	local tVariants = tSwatch:GetAttribute("buff");
	local tVariant = VUHDO_getBuffVariantMaxTarget(tVariants);
	--local tSuffix = SecureButton_GetButtonSuffix(aMouseButton);

	if ("RightButton" == aMouseButton) then
		VUHDO_CLICKED_BUFF = tVariants[1][1];
		VUHDO_CLICKED_TARGET = tSwatch:GetAttribute("target");
		ToggleDropDownMenu(1, nil, VuhDoBuffSelectDropdown, aButton:GetName(), 0, -5);
	end

	VUHDO_IS_USED_SMART_BUFF = VUHDO_isUseSingleBuff(tSwatch);
	local tBuff = tVariant[1];

	if (2 == VUHDO_IS_USED_SMART_BUFF and aMouseButton == "LeftButton") then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_2 .. tBuff, 1, 0.1, 0.1, 1);
		VUHDO_setupAllBuffButtonsTo(aButton, "", "", "");
		return;
	end

	local tTarget;
	if (VUHDO_IS_USED_SMART_BUFF) then
		tTarget = tSwatch:GetAttribute("lowtarget");
	else
		tTarget = tSwatch:GetAttribute("goodtarget");
	end

	if (VUHDO_BUFF_TARGET_TOTEM == tVariant[2] and VUHDO_BUFF_SETTINGS["CONFIG"]["USE_COMBINED"]) then
		VUHDO_setupAllBuffButtonsTo(aButton, VUHDO_SPELL_ID_CALL_OF_THE_ELEMENTS, tTarget, VUHDO_SPELL_ID_CALL_OF_THE_ELEMENTS);
	else
		VUHDO_setupAllBuffButtonsTo(aButton, tBuff, tTarget, tBuff);
	end


	if (tTarget == nil and aMouseButton ~= "RightButton") then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_2 .. tBuff, 1, 0.1, 0.1, 1);
	end
end



--
local tSwatch;
local tVariants;
function VuhDoBuffPostClick(aButton, aMouseButton)
	if (VUHDO_IS_USED_SMART_BUFF) then
		tSwatch = aButton:GetParent();
		tVariants = tSwatch:GetAttribute("buff");
		tTarget = tSwatch:GetAttribute("goodtarget");
		tBuff = VUHDO_getBuffVariantMaxTarget(tVariants)[1];
		VUHDO_setupAllBuffButtonsTo(aButton, tBuff, tTarget, tBuff);
	end
end



--
local tUniqueBuffs = { };
local tUniqueCategs = { };
local tEmptyArray = { };
local tCategName;
local tAllBuffs;
local tCategBuffs;
local tVariant;
local tSpellName;
function VUHDO_getAllUniqueSpells()
	twipe(tUniqueBuffs);
	twipe(tUniqueCategs);

	tAllBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];

	if (tAllBuffs == nil) then
		return tEmptyArray, tEmptyArray;
	end

	for tCategName, tCategBuffs in pairs(tAllBuffs) do
		tVariant = tCategBuffs[1];
		tSpellName = tVariant[1][1];
		if (VUHDO_BUFFS[tSpellName] ~= nil and VUHDO_BUFFS[tSpellName]["present"] and VUHDO_BUFF_TARGET_UNIQUE == tVariant[1][2]) then
			tinsert(tUniqueBuffs, tSpellName);
			tUniqueCategs[tSpellName] = strsub(tCategName, 3);
		end
	end

	return tUniqueBuffs, tUniqueCategs;
end



--
local tAllBuffs;
local tCateg, tCategSpells;
local tBuffInfo;
local function VUHDO_initDynamicBuffArray()
	tAllBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];

	if (tAllBuffs == nil) then
		return;
	end

	for xName, tCateg in pairs(tAllBuffs) do
		for _, tCategSpells in pairs(tCateg) do
			for _, tBuffInfo in pairs(tCategSpells) do
				VUHDO_BUFFS[tBuffInfo[1]] = { ["present"] = false };
			end
		end
	end
end



local VUHDO_BLACKLIST_BUFFS = {
	[VUHDO_SPELL_ID_BUFF_VIGILANCE] = "Interface\\Icons\\Spell_Nature_Sleep", -- "Wachsamkeit" gibt's einmal als racial und als warri-talent
}



--
local tCnt;
local tSpellName;
local tIcon;
function VUHDO_initBuffsFromSpellBook()

	VUHDO_initDynamicBuffArray();

	for tCnt = 1, 99999 do
		tSpellName = GetSpellBookItemName(tCnt, BOOKTYPE_SPELL);
		if (tSpellName == nil) then
			break;
		end

		if (VUHDO_BUFFS[tSpellName] ~= nil and not VUHDO_BUFFS[tSpellName]["present"]) then
			_, _, tIcon = GetSpellInfo(tCnt, BOOKTYPE_SPELL);
			if (VUHDO_BLACKLIST_BUFFS[tSpellName] ~= tIcon) then
				VUHDO_BUFFS[tSpellName] = {
					["present"] = true,
					["icon"] = tIcon,
					["id"] = tCnt,
					["booktype"] = BOOKTYPE_SPELL,
				};
			end
		end
	end

	if (VUHDO_PLAYER_CLASS == "WARRIOR") then
		_, _, tIcon = GetSpellInfo(50720)
		VUHDO_BUFFS[VUHDO_SPELL_ID_BUFF_VIGILANCE] = {
			["present"] = true,
			["icon"] = tIcon,
			["id"] = 50720,
			["booktype"] = nil,
		};
	end
end



--
local tClassBuffs;
local tCategBuffs, tBuffVariants, tVariant, tCategName;
function VUHDO_getBuffCategory(aBuffName)
	tClassBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];

	for tCategName, tCategBuffs in pairs(tClassBuffs) do
		for _, tBuffVariants in pairs(tCategBuffs) do
			for _, tVariant in pairs(tBuffVariants) do
				if (aBuffName == tVariant[1]) then
					return tCategName;
				end
			end
		end
	end

	return nil;
end



--
local tBuffOrder;
local tInfo;
local tEmpty = { };
local function VUHDO_setUnitMissBuff(aUnit, aCategSpec, someVariants, aCategName)
	if (not (VUHDO_BUFF_SETTINGS[aCategName]["missingColor"] or tEmpty)["show"]) then
		return;
	end

	tInfo = VUHDO_RAID[aUnit];
	tBuffOrder = VUHDO_BUFF_ORDER[aCategSpec];
	if (tBuffOrder ~= nil and tInfo ~= nil) then
		-- Don't show missing buffs on vehicles
		if (tInfo["isPet"] and VUHDO_RAID[tInfo["ownerUnit"]] ~= nil
			and VUHDO_RAID[tInfo["ownerUnit"]]["isVehicle"]) then
			return;
		end

		if (tInfo["missbuff"] == nil or tInfo["missbuff"] > tBuffOrder) then
			tInfo["missbuff"] = tBuffOrder;
			tInfo["mibucateg"] = aCategName;
			tInfo["mibuvariants"] = someVariants;
		end
	end
end



--
local tUnit;
local tTexture, tStart, tRest, tDuration;
local tMaxVariant;
local tMissGroup = { };
local tLowGroup = { };
local tOkayGroup = { };
local tOorGroup = { };
local tGoodTarget;
local tLowestRest;
local tLowestUnit;
local tTotemNum, tTotemFound, tStart;
local tNow;
local tInRange;
local tCount;
local tMaxCount;
local tName;
local tIsWatchUnit;
local tInfo;
local tCategName;
local tIsAvailable;
local function VUHDO_getMissingBuffs(someBuffVariants, someUnits, aCategSpec)
	tMaxVariant = VUHDO_getBuffVariantMaxTarget(someBuffVariants);
	tCategName = strsub(aCategSpec, 3);
	twipe(tMissGroup);
	twipe(tLowGroup);
	twipe(tOkayGroup);
	twipe(tOorGroup);
	tGoodTarget = nil;
	tLowestRest = nil;
	tLowestUnit = nil;
	tNow = GetTime();
	tMaxCount = 0;

	for _, tUnit in pairs(someUnits) do
		tInfo = VUHDO_RAID[tUnit];

		if ("focus" == tUnit or "target" == tUnit or tInfo == nil or tInfo["isPet"]) then
			tIsWatchUnit = false;
		elseif ("player" == tUnit) then
			tIsWatchUnit = true;
		elseif (VUHDO_isInSameZone(tUnit) and (tInfo["visible"] or not VUHDO_isInBattleground())) then
			tIsWatchUnit = true;
		else
			tIsWatchUnit = false;
		end

		if (tIsWatchUnit) then
			tInRange = tInfo["baseRange"];
			tIsAvailable = tInfo["connected"] and not tInfo["dead"];
			if (not tInRange and tIsAvailable) then
				tinsert(tOorGroup, tUnit);
			end

			if (7 == tMaxVariant[2]) then -- VUHDO_BUFF_TARGET_TOTEM
				tRest = 0;
				for tTotemNum = 1, 4 do
					_, _, tStart, tDuration, tTexture = GetTotemInfo(tTotemNum);
					if (tTexture == VUHDO_BUFFS[tMaxVariant[1]]["icon"]) then
						tRest = tDuration - (tNow - tStart);
						if (tRest < 0) then
							tRest = 0;
						end
						break;
					else
						tTexture = nil;
					end
				end

			else
				tName, _, tTexture, tCount, _, tStart, tRest, _, _ = UnitBuff(tUnit, tMaxVariant[1]);
				if (tName == nil and tMaxVariant[3] ~= nil) then
					_, _, tTexture, tCount, _, tStart, tRest, _, _ = UnitBuff(tUnit, tMaxVariant[3]);
				end
			end

			if (tTexture ~= nil) then
				tStart = tStart or 0;

				if (tRest == nil) then
					tRest = 0;
				else
					tRest = tRest - tNow;
				end
				tCount = tCount or 0

				if (tCount > tMaxCount) then
					tMaxCount = tCount;
				end

				if ((tRest < sRebuffSecs or tRest / tStart < sRebuffPerc) and tRest > 0) then
					tinsert(tLowGroup, tUnit);
				else
					tinsert(tOkayGroup, tUnit);
				end

				if (tLowestRest == nil or tRest < tLowestRest) then
					tLowestRest = tRest;
					if (tInRange) then
						tLowestUnit = tUnit;
					end
				end
			end

			if (tIsAvailable) then
				if (tTexture == nil) then
					tinsert(tMissGroup, tUnit);
					VUHDO_setUnitMissBuff(tUnit, aCategSpec, someBuffVariants, tCategName);
					if (tInRange) then
						tLowestUnit = tUnit;
						tLowestRest = 0;
					end
				end

				if (9 == tMaxVariant[2]) then -- VUHDO_BUFF_TARGET_HOSTILE
					tGoodTarget = "playertarget";
				elseif (3 == tMaxVariant[2] or tInRange) then -- VUHDO_BUFF_TARGET_UNIQUE
					tGoodTarget = tUnit;
				end
			end

		end
	end

	return tMissGroup, tLowGroup, tGoodTarget, tLowestRest, tLowestUnit, tOkayGroup, tOorGroup, tMaxCount;
end



--
local tFilters;
local tUnit;
local tModelId;
local function VUHDO_updateFilter(aCategName)
	tFilters = VUHDO_BUFF_SETTINGS[aCategName]["filter"];

	if (tFilters[VUHDO_ID_ALL]) then
		VUHDO_BUFF_RAID_FILTERED[aCategName] = VUHDO_BUFF_RAID;
	else
		VUHDO_BUFF_RAID_FILTERED[aCategName] = { };

		for tModelId, _ in pairs(tFilters) do
			for _, tUnit in pairs(VUHDO_GROUPS[tModelId]) do
				if (not (VUHDO_RAID[tUnit] or { ["isPet"] = true })["isPet"]) then
					VUHDO_tableUniqueAdd(VUHDO_BUFF_RAID_FILTERED[aCategName], tUnit);
				end
			end
		end
	end
end



--
local tAllClassBuffs;
local tCategSpec;
function VUHDO_updateBuffFilters()
	tAllClassBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];
	if (tAllClassBuffs ~= nil) then
		for tCategSpec, _ in pairs(tAllClassBuffs) do
			VUHDO_updateFilter(strsub(tCategSpec, 3));
		end
	end
end



--
local tUnit, tInfo;
function VUHDO_updateBuffRaidGroup()
	twipe(VUHDO_BUFF_RAID);
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if ("focus" ~= tUnit and "target" ~= tUnit and not tInfo["isPet"]) then
			tinsert(VUHDO_BUFF_RAID, tUnit);
		end
	end

	VUHDO_updateBuffFilters();
end



--
local tDestGroup;
local tPlayerGroup;
local tMaxTarget;
local tCode;
local tUnit;
local tEnchTexture1, tWeaponTexture;
local tEnchDuration1, tEnchDuration2;
local tHasEnch1, tHasEnch2;
local tCategName;
local tEmpty = { };
local function VUHDO_getMissingBuffsForCode(aTargetCode, someBuffVariants, aCategSpec)
	tCode = strsub(aTargetCode, 1, 1);

	if ("N" == tCode) then
		tNameGroup[1] = VUHDO_RAID_NAMES[strsub(aTargetCode, 2)];
		tDestGroup = tNameGroup;
	else
		tMaxTarget = VUHDO_getBuffVariantMaxTarget(someBuffVariants)[2];

		if (VUHDO_BUFF_TARGET_RAID == tMaxTarget or VUHDO_BUFF_TARGET_SINGLE == tMaxTarget) then
			tCategName = strsub(aCategSpec, 3);
			if (VUHDO_BUFF_RAID_FILTERED[tCategName] ~= nil) then
				tDestGroup = VUHDO_BUFF_RAID_FILTERED[tCategName];
			else
				tDestGroup = VUHDO_BUFF_RAID;
			end

		elseif (VUHDO_BUFF_TARGET_OWN_GROUP == tMaxTarget) then
			tDestGroup = VUHDO_GROUPS[(VUHDO_RAID["player"] or {})["group"] or 1];

		elseif (VUHDO_BUFF_TARGET_ENCHANT == tMaxTarget) then
			tHasEnch1, tEnchDuration1, _, _, _, _ = GetWeaponEnchantInfo();

			if (tHasEnch1) then
				return {}, {}, "player", tEnchDuration1 * 0.001, "player", { "player" }, { }, 0;
			end

			VUHDO_setUnitMissBuff("player", aCategSpec, someBuffVariants, strsub(aCategSpec, 3));
			return { "player" }, {}, "player", 0, "player", { }, { }, 0;
		else
			-- If self, totem or aura we only care if buff isn't on player
			tDestGroup = VUHDO_PLAYER_GROUP;
		end
	end

	return VUHDO_getMissingBuffs(someBuffVariants, tDestGroup or tEmpty, aCategSpec);
end



--
local tColor;
local function VUHDO_setBuffSwatchColor(aSwatch, aColorInfo, aColorType)
	if (VUHDO_LAST_COLORS[aSwatch:GetName()] == aColorType) then
		return;
	end

	tColor = VUHDO_getDiffColor(VUHDO_copyColor(sConfig["SWATCH_BG_COLOR"]), aColorInfo);

	aSwatch:SetBackdropColor(tColor["R"], tColor["G"], tColor["B"], tColor["O"]);

	if (tColor["useText"]) then
		VUHDO_GLOBAL[aSwatch:GetName() .. "MessageLabelLabel"]:SetTextColor(tColor["TR"], tColor["TG"], tColor["TB"], tColor["TO"]);
		VUHDO_GLOBAL[aSwatch:GetName() .. "TimerLabelLabel"]:SetTextColor(tColor["TR"], tColor["TG"], tColor["TB"], tColor["TO"]);
		VUHDO_GLOBAL[aSwatch:GetName() .. "CounterLabelLabel"]:SetTextColor(tColor["TR"], tColor["TG"], tColor["TB"], tColor["TO"]);
		tColor = VUHDO_brightenTextColor(VUHDO_copyColor(aColorInfo), 0.2);
		VUHDO_GLOBAL[aSwatch:GetName() .. "GroupLabelLabel"]:SetTextColor(tColor["TR"], tColor["TG"], tColor["TB"], tColor["TO"]);
	end

	VUHDO_LAST_COLORS[aSwatch:GetName()] = aColorType;
end



--
local function VUHDO_setBuffSwatchInfo(aSwatchName, anInfoText)
	VUHDO_GLOBAL[aSwatchName .. "MessageLabelLabel"]:SetText(anInfoText);
end



--
local function VUHDO_setBuffSwatchCount(aSwatchName, aText)
	VUHDO_GLOBAL[aSwatchName .. "CounterLabelLabel"]:SetText(aText);
end



--
local tCountStr;
local function VUHDO_setBuffSwatchTimer(aSwatchName, aSecsNum, aCount)

	if ((aSecsNum or -1) >= 0) then
		if ((aCount or 0) > 0 and not VUHDO_BUFF_SETTINGS["CONFIG"]["HIDE_CHARGES"]) then
			tCountStr = format("|cffffffff%dx |r", aCount);
		else
			tCountStr = "";
		end

		VUHDO_GLOBAL[aSwatchName .. "TimerLabelLabel"]:SetText(format("%s%d:%02d", tCountStr, aSecsNum / 60, aSecsNum % 60));
	else
		VUHDO_GLOBAL[aSwatchName .. "TimerLabelLabel"]:SetText("");
	end
end



--
local tStart, tDuration;
local function VUHDO_getSpellCooldown(aSpellName)
	tStart, tDuration, _ = GetSpellCooldown(VUHDO_BUFFS[aSpellName]["id"], VUHDO_BUFFS[aSpellName]["booktype"]);
	if (tDuration == 0) then
		return 0, 0;
	else
		tStart = tStart or 0;
		tDuration = tDuration or 0;
		return tStart + tDuration - GetTime(), tDuration;
	end
end



--
local tMissGroup;
local tLowGroup;
local tGoodTarget;
local tLowestRest;
local tLowestUnit;
local tOkayGroup;
local tOorGroup;
local tCooldown, tTotalCd;
local tRefSpell;
local tSwatchName;
local tMaxCount;
local tCategSpec;
local tMaxVariant;
local tVariants;
local tTargetCode;
function VUHDO_updateBuffSwatch(aSwatch)
	tSwatchName = aSwatch:GetName();
	tVariants = aSwatch:GetAttribute("buff");
	tTargetCode = aSwatch:GetAttribute("target");
	tCategSpec = aSwatch:GetAttribute("buffName");

	if (tTargetCode == nil or tVariants == nil) then
		return;
	end
	tLowestUnit = nil;
	tGoodTarget = nil;


	tMaxVariant = VUHDO_getBuffVariantMaxTarget(tVariants);
	tRefSpell = tMaxVariant[1];

	if (VUHDO_BUFFS[tRefSpell] == nil or VUHDO_BUFFS[tRefSpell]["id"] == nil) then
		return;
	end

	tCooldown, tTotalCd = VUHDO_getSpellCooldown(tRefSpell);

	if (tCooldown > 1.5) then
		VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_COOLDOWN"], VUHDO_BS_COLOR_CD);
		VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_CD);
		VUHDO_setBuffSwatchCount(tSwatchName, "");
		VUHDO_setBuffSwatchTimer(tSwatchName, tCooldown, nil);
		if (tTotalCd > 59) then
			VUHDO_BUFFS[tRefSpell]["wasOnCd"] = true;
		end
	else
		if (VUHDO_BUFFS[tRefSpell]["wasOnCd"]	and VUHDO_BUFF_SETTINGS["CONFIG"]["HIGHLIGHT_COOLDOWN"]) then
			UIFrameFlash(aSwatch, 0.3, 0.3, 5, true, 0, 0.3);
			VUHDO_BUFFS[tRefSpell]["wasOnCd"] = false;
		end

		tMissGroup, tLowGroup, tGoodTarget, tLowestRest, tLowestUnit, tOkayGroup, tOorGroup, tMaxCount
			= VUHDO_getMissingBuffsForCode(tTargetCode, tVariants, tCategSpec);

		if (#tMissGroup > 0) then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OUT"], VUHDO_BS_COLOR_MISSING);

			if (tGoodTarget == nil or #tOorGroup > 0) then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_RNG_YELLOW);
				VUHDO_setBuffSwatchCount(tSwatchName, "" .. #tOorGroup);
				VUHDO_setBuffSwatchTimer(tSwatchName, 0, nil, tMaxCount);
			else
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_GO);
				VUHDO_setBuffSwatchCount(tSwatchName, "" .. (#tMissGroup + #tLowGroup));
				VUHDO_setBuffSwatchTimer(tSwatchName, 0, nil);
			end

		elseif (#tLowGroup > 0) then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_LOW"], VUHDO_BS_COLOR_LOW);

			if (tGoodTarget == nil) then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_RNG_RED);
			else
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_LOW);
			end

			VUHDO_setBuffSwatchCount(tSwatchName, "" .. #tLowGroup);
			VUHDO_setBuffSwatchTimer(tSwatchName, tLowestRest, tMaxCount);
		else
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OKAY"], VUHDO_BS_COLOR_OKAY);

			if (#tOkayGroup == 0) then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_N_A);
			elseif (tGoodTarget == nil) then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_RNG_RED);
			else
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_OK);
			end

			VUHDO_setBuffSwatchCount(tSwatchName, #tOkayGroup);
			if (tLowestRest == 0) then
				VUHDO_setBuffSwatchTimer(tSwatchName, nil);
			else
				VUHDO_setBuffSwatchTimer(tSwatchName, tLowestRest, tMaxCount);
			end
		end
	end

	if (not InCombatLockdown()) then
		aSwatch:SetAttribute("lowtarget", tLowestUnit);
		aSwatch:SetAttribute("goodtarget", tGoodTarget);
	end

	if (tLowGroup == nil) then
		tLowGroup = { };
	end

	if (tMissGroup == nil) then
		tMissGroup = { };
	end

	VUHDO_NUM_LOWS[tSwatchName] = #tLowGroup + #tMissGroup;
end



--
local tAllSwatches;
local tUpdSwatch;
local tUnit, tInfo;
local VUHDO_OLD_MISS_BUFFS = { };
function VUHDO_updateBuffPanel()
	if (VUHDO_isConfigDemoUsers()) then
		return;
	end

	twipe(VUHDO_OLD_MISS_BUFFS);
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		VUHDO_OLD_MISS_BUFFS[tUnit] = tInfo["missbuff"];
		tInfo["missbuff"] = nil;
	end

	tAllSwatches = VUHDO_getAllBuffSwatches();
	for _, tUpdSwatch in pairs(tAllSwatches) do
		if (tUpdSwatch:IsShown()) then
			VUHDO_updateBuffSwatch(tUpdSwatch);
		end
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (VUHDO_OLD_MISS_BUFFS[tUnit] ~= tInfo["missbuff"]) then
			tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(tUnit, tInfo["class"]);
			VUHDO_updateHealthBarsFor(tUnit, VUHDO_UPDATE_DEBUFF);
		end
	end
end



--
function VUHDO_execSmartBuffPre(self)
	if (InCombatLockdown()) then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_1, 1, 0.1, 0.1, 1);
		return false;
	end

	local tCheckSwatch;
	local tAllSwatches = VUHDO_getAllBuffSwatches();
	local tVariants = nil;
	local tTargetCode = nil;
	local tRefSpell = nil;
	local tMaxLow = 0;
	local tMaxLowSpell = nil;
	local tMaxLowTarget = nil;
	local tCategSpec;
	local tMissGroup, tLowGroup, tGoodTarget,
				tLowestRest, tLowestUnit, tOkayGroup,
				tOorGroup, tMaxCount;
	local tNumLow, tCooldown, tTotalCd;
	local tCooldown, tTotalCd;

	for _, tCheckSwatch in pairs(tAllSwatches) do
		if (tCheckSwatch:IsShown()) then
			tVariants = tCheckSwatch:GetAttribute("buff");
			tTargetCode = tCheckSwatch:GetAttribute("target");
			tCategSpec = tCheckSwatch:GetAttribute("buffname");
			tRefSpell = tVariants[1][1];

			tMissGroup, tLowGroup, tGoodTarget,
				tLowestRest, tLowestUnit, tOkayGroup,
				tOorGroup, tMaxCount
					= VUHDO_getMissingBuffsForCode(tTargetCode, tVariants, tCategSpec);

			tNumLow = #tMissGroup + #tLowGroup;
			if (VUHDO_BUFFS[tRefSpell] == nil or VUHDO_BUFFS[tRefSpell]["id"] == nil) then
				tCooldown, tTotalCd = 0, 0;
			else
				tCooldown, tTotalCd = VUHDO_getSpellCooldown(tRefSpell);
			end

			if (tNumLow > tMaxLow and tCooldown <= 1.5 and VUHDO_BUFF_TARGET_HOSTILE ~= tVariants[1][2]) then
				if (tGoodTarget == nil) then
					UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_2 .. tRefSpell, 1, 0.1, 0.1, 1);
				elseif (#tOorGroup > 0) then
					UIErrorsFrame:AddMessage("VuhDo: " .. #tOorGroup .. VUHDO_I18N_SMARTBUFF_ERR_3 .. tRefSpell, 1, 0.1, 0.1, 1);
				else
					tMaxLow = tNumLow;
					if (VUHDO_isUseSingleBuff(tCheckSwatch)) then
						tMaxLowTarget = tLowestUnit;
					else
						tMaxLowTarget = tGoodTarget;
					end

					tMaxLowSpell = VUHDO_getBuffVariantMaxTarget(tVariants)[1];
				end
			end
		end
	end

	if (tMaxLowSpell == nil) then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_4, 1, 1, 0.1, 1);
		return;
	end

	if (VUHDO_BUFFS[tMaxLowSpell] == nil or VUHDO_BUFFS[tMaxLowSpell]["id"] == nil) then
		tCooldown, tTotalCd = 0, 0;
	else
		tCooldown, tTotalCd = VUHDO_getSpellCooldown(tMaxLowSpell);
	end

	if (tCooldown > 0) then
		return;
	end

	local tName = VUHDO_RAID_NAMES[tMaxLowTarget] or VUHDO_RAID[tMaxLowTarget]["name"];

	UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_OKAY_1 .. tMaxLowSpell .. VUHDO_I18N_SMARTBUFF_OKAY_2 .. tName, 0.1, 1, 0.1, 1);
	VuhDoSmartCastGlassButton:SetAttribute("unit", tMaxLowTarget);
	VuhDoSmartCastGlassButton:SetAttribute("type1", "spell");
	VuhDoSmartCastGlassButton:SetAttribute("spell1", tMaxLowSpell);
end



--
function VUHDO_execSmartBuffPost()
	VuhDoSmartCastGlassButton:SetAttribute("unit", nil);
	VuhDoSmartCastGlassButton:SetAttribute("type1", nil);
end



--
function VUHDO_resetBuffSwatchInfos()
	twipe(VUHDO_LAST_COLORS);
end

