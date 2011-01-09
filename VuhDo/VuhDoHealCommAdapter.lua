-- BURST CACHE ---------------------------------------------------
local UnitGetIncomingHeals = UnitGetIncomingHeals;
local sIsOthers, sIsOwn;
function VUHDO_healCommAdapterInitBurst()
	sIsOthers = VUHDO_CONFIG["SHOW_INCOMING"];
	sIsOwn = VUHDO_CONFIG["SHOW_OWN_INCOMING"];
end


----------------------------------------------------


local VUHDO_INC_HEAL = { };



--
function VUHDO_getIncHealOnUnit(aUnit)
	return VUHDO_INC_HEAL[aUnit] or 0;
end



--
local tAllIncoming;
function VUHDO_determineIncHeal(aUnit)
	if (sIsOthers) then
		tAllIncoming = UnitGetIncomingHeals(aUnit) or 0;
		if (not sIsOwn) then
			tAllIncoming = tAllIncoming - (UnitGetIncomingHeals(aUnit, "player") or 0);
			if (tAllIncoming < 0) then
				VUHDO_INC_HEAL[aUnit] = 0;
			else
				VUHDO_INC_HEAL[aUnit] = tAllIncoming;
			end
		else
			VUHDO_INC_HEAL[aUnit] = tAllIncoming;
		end
	else
		VUHDO_INC_HEAL[aUnit] = UnitGetIncomingHeals(aUnit, "player") or 0;
	end
end
