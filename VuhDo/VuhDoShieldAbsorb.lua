local VUHDO_SHIELD_LEFT = { };
local VUHDO_SHIELD_SIZE = { };
local VUHDO_SHIELD_EXPIRY = { };
local sEmpty = { };


--
local VUHDO_PLAYER_GUID = -1;
local pairs = pairs;
local ceil = ceil;
local GetTime = GetTime;

function VUHDO_shieldAbsorbInitBurst()
	VUHDO_PLAYER_GUID = UnitGUID("player");
end


--
local function VUHDO_initShieldValue(aUnit, aShieldName, anAmount, aDuration)
	if ((anAmount or 0) == 0) then
		--VUHDO_xMsg("ERROR: Failed to init shield " .. aShieldName .. " on " .. aUnit, anAmount);
		return;
	end

	if (VUHDO_SHIELD_LEFT[aUnit] == nil) then
		VUHDO_SHIELD_LEFT[aUnit], VUHDO_SHIELD_SIZE[aUnit], VUHDO_SHIELD_EXPIRY[aUnit] = {}, {}, {};
	end

	VUHDO_SHIELD_LEFT[aUnit][aShieldName] = anAmount;
	VUHDO_SHIELD_SIZE[aUnit][aShieldName] = anAmount;
	VUHDO_SHIELD_EXPIRY[aUnit][aShieldName] = GetTime() + aDuration;
	--VUHDO_xMsg("Init shield " .. aShieldName .. " on " .. aUnit .. " for " .. anAmount);
end



--
local function VUHDO_updateShieldValue(aUnit, aShieldName, anAmount, aDuration)
	if ((VUHDO_SHIELD_SIZE[aUnit] or sEmpty)[aShieldName] == nil) then
		return;
	end

	if (VUHDO_SHIELD_LEFT[aUnit][aShieldName] <= anAmount) then
		VUHDO_SHIELD_EXPIRY[aUnit][aShieldName] = GetTime() + aDuration;
		--VUHDO_Msg("Shield overwritten");
	end

	VUHDO_SHIELD_LEFT[aUnit][aShieldName] = anAmount;
	--VUHDO_Msg("Updated shield " .. aShieldName .. " on " .. aUnit .. " to " .. anAmount);
end



--
local function VUHDO_removeShield(aUnit, aShieldName)
	if ((VUHDO_SHIELD_SIZE[aUnit] or sEmpty)[aShieldName] == nil) then
		return;
	end

	VUHDO_SHIELD_SIZE[aUnit][aShieldName] = nil;
	VUHDO_SHIELD_LEFT[aUnit][aShieldName] = nil;
	VUHDO_SHIELD_EXPIRY[aUnit][aShieldName] = nil;
	--VUHDO_Msg("Removed shield " .. aShieldName .. " from " .. aUnit);
end



--
local tNow;
local tUnit, tAllShields;
local tShieldName, tExpiry;
function VUHDO_removeObsoleteShields()
	tNow = GetTime();
	for tUnit, tAllShields in pairs(VUHDO_SHIELD_EXPIRY) do
		for tShieldName, tExpiry in pairs(tAllShields) do
			if (tExpiry < tNow) then
				VUHDO_removeShield(tUnit, tShieldName);
			end
		end
	end
end



--
local tInit;
function VUHDO_getShieldLeftCount(aUnit, aShield)
	tInit = (VUHDO_SHIELD_SIZE[aUnit] or sEmpty)[aShield] or 0;

	if (tInit > 0) then
		return ceil(4 * ((VUHDO_SHIELD_LEFT[aUnit] or sEmpty)[aShield] or 0) / tInit);
	else
		return 0;
	end
end



--
local VUHDO_SHIELDS = {
	[VUHDO_SPELL_ID.POWERWORD_SHIELD] = 30,
	[VUHDO_SPELL_ID.DIVINE_AEGIS] = 12,
	[VUHDO_SPELL_ID.ILLUMINATED_HEALING] = 5,
};



--
local tUnit;
function VUHDO_parseCombatLogShieldAbsorb(aMessage, aSrcGuid, aDstGuid, aShieldName, anAmount)
	if (VUHDO_PLAYER_GUID ~= aSrcGuid or VUHDO_SHIELDS[aShieldName] == nil) then
		return;
	end

	tUnit = VUHDO_RAID_GUIDS[aDstGuid];
	if (tUnit == nil) then
		return;
	end

	if ("SPELL_AURA_REFRESH" == aMessage) then
		VUHDO_updateShieldValue(tUnit, aShieldName, anAmount, VUHDO_SHIELDS[aShieldName]);
	elseif ("SPELL_AURA_APPLIED" == aMessage) then
		VUHDO_initShieldValue(tUnit, aShieldName, anAmount, VUHDO_SHIELDS[aShieldName]);
	elseif ("SPELL_AURA_REMOVED" == aMessage
		or "SPELL_AURA_BROKEN" == aMessage
		or "SPELL_AURA_BROKEN_SPELL" == aMessage) then
		VUHDO_removeShield(tUnit, aShieldName);
	end
end
