-- ForteXorcist v1.974 by Xus 09-01-2011 for 4.0.3
-- Paladin module for ForteXorcist started by Arono of Skywall

if FW.CLASS == "PALADIN" then

	local FW = FW;
	local FWL = FW.L;
	local PA = FW:ClassModule("Paladin");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	-- Tier 7
	--FW:RegisterSet("Redemption Plate",39638, 39639, 39640, 39641, 39642, 40579, 40580, 40581, 40583, 40584);
	
	--[[FW:RegisterCustomName(86669,FWL.GOAK_HOLY); -- Guardian of Ancient Kings (Holy)
	FW:RegisterCustomName(86659,FWL.GOAK_PROT); -- Guardian of Ancient Kings (Protection)
	FW:RegisterCustomName(86698,FWL.GOAK_RETR); -- Guardian of Ancient Kings (Retribution)]]
	                                               
	if ST then
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack
	
		-- NEW:
		
		-- Protection Spells
		ST:RegisterSpell(26017, 1, 000, 0, ST.DEFAULT); -- Vindication
		ST:RegisterSpell(68055, 1, 000, 0, ST.DEFAULT); -- Judgements of the Just
		ST:RegisterSpell(31803, 1, 015, 1, ST.DEFAULT); -- Censure
		
		-- Holy Spells
		ST:RegisterSpell(82327, 0, 010, 0, ST.HEAL); -- Holy Radiance
			ST:RegisterTickSpeed(82327, 1); -- set tick speed to 1 instead of 3
		ST:RegisterSpell(76669, 1, 008, 0, ST.BUFF); -- Illuminated Healing (Shield)
		
		ST:RegisterBuff(85497); -- Speed of Light
		ST:RegisterBuff(90311); -- Radiant (T11 4-Set)
		ST:RegisterBuff(88819); -- Daybreak
		ST:RegisterBuff(85509); -- Denounce
		ST:RegisterBuff(20050); -- Conviction
		
		ST:RegisterCooldown(20473, 006); -- Holy Shock
		
		-- Protection Spells
		ST:RegisterSpell(88063, 1, 006, 0, ST.BUFF); -- Guarded by the Light (Shield)
		
		--[[ST:RegisterSpell(86669, 0, 030, 0, ST.PET); -- Guardian of Ancient Kings (Holy)
		ST:RegisterSpell(86659, 0, 012, 0, ST.PET); -- Guardian of Ancient Kings (Protection)
		ST:RegisterSpell(86698, 0, 030, 0, ST.PET); -- Guardian of Ancient Kings (Retribution)]]
		
		ST:RegisterBuff(86659); -- Guardian of Ancient Kings

		ST:RegisterBuff(31850); -- Ardent Defender
		ST:RegisterBuff(70940); -- Divine Guardian
		ST:RegisterBuff(  498); -- Divine Protection
		
		ST:RegisterBuff(85416); -- Grand Crusader
		ST:RegisterBuff(85433); -- Sacred Duty
		ST:RegisterBuff(25780); -- Righteous Fury
		ST:RegisterBuff(84839); -- Vengeance
		
		-- Retribution Spells
		ST:RegisterBuff(31884); -- Avenging Wrath
		ST:RegisterBuff(84963); -- Inquisition
		ST:RegisterBuff(85803); -- Selfless Healer
		ST:RegisterBuff(87173); -- Long Arm of the Law
		ST:RegisterBuff(86700); -- Ancient Power
		
		ST:RegisterCooldown(35395, 004.5); -- Crusader Strike
		ST:RegisterCooldown(85285, 010); -- Rebuke

		-- END NEW
		
		-- Holy Spells
		ST:RegisterSpell(53563, 1, 060, 0, ST.BUFF); -- Beacon of Light
			ST:RegisterSpellModGlph(53563, 63865, 030); -- Glyph of Beacon of Light
		ST:RegisterSpell(26573, 0, 010, 0, ST.DEFAULT); -- Consecration
			ST:RegisterSpellModGlph(26573, 54928, 002); -- Glyph of Consecration
			ST:RegisterTickSpeed(26573, 1); -- set tick speed to 1 instead of 3	
		--ST:RegisterSpell(31842, 0, 015, 0, ST.DEFAULT); -- Divine Illumination
		ST:RegisterSpell( 2812, 0, 003, 0, ST.DEFAULT); -- Holy Wrath (stun)
		ST:RegisterSpell(  633, 1, 015, 0, ST.DEFAULT); -- Improved Lay on Hands
			ST:RegisterSpellModTlnt(633, 20234, 0, -15); -- Improved Lay on Hands
		ST:RegisterSpell(10326, 1, 020, 0, ST.DEFAULT); -- Turn Evil
		ST:RegisterSpell(879, 1, 000, 1, ST.DEFAULT,000,0); -- Exorcism
			ST:RegisterTickSpeed(879, 2); -- set tick speed to 2 instead of 3
			
		-- Protection Spells
		ST:RegisterSpell(31935, 1, 003, 0, ST.DEFAULT); -- Avenger's Shield (silence)
		ST:RegisterSpell(19752, 1, 180, 0, ST.DEFAULT); -- Divine Intervention	
		ST:RegisterSpell(64205, 0, 010, 0, ST.DEFAULT); -- Divine Sacrifice
		ST:RegisterSpell(  853, 1, 006, 0, ST.DEFAULT); -- Hammer of Justice (stun)
		ST:RegisterSpell( 1044, 1, 006, 0, ST.BUFF); -- Hand of Freedom
			ST:RegisterSpellModTlnt(1044, 20174, 1, 2); -- Guardian's Favor (Rank 1)
			ST:RegisterSpellModTlnt(1044, 20174, 1, 4); -- Guardian's Favor (Rank 2)
		ST:RegisterSpell( 1022, 1, 010, 0, ST.BUFF); -- Hand of Protection
		ST:RegisterSpell(62124, 1, 003, 0, ST.DEFAULT); -- Hand of Reckoning
		ST:RegisterSpell( 6940, 1, 012, 0, ST.BUFF); -- Hand of Sacrifice
		ST:RegisterSpell( 1038, 1, 010, 0, ST.BUFF); -- Hand of Salvation
	
		-- Retribution Spells
		ST:RegisterSpell(20066, 1, 060, 0, ST.DEFAULT); -- Repentance (stun)

		-- Holy Buffs
		ST:RegisterBuff(31821); -- Aura Mastery	
		ST:RegisterBuff(31842); -- Divine Favor
		ST:RegisterBuff(43837); -- Enlightenment (T5 4-Set)
		ST:RegisterBuff(64891); -- Holy Mending (T8 2-Set)
		ST:RegisterBuff(53672,1); -- Infusion of Light (set to non-stacking)
		ST:RegisterBuff(53655); -- Judgements of the Pure
		ST:RegisterBuff(31834); -- Light's Grace
		ST:RegisterBuff(53659); -- Sacred Cleansing
		ST:RegisterBuff(54428); -- Divine Plea
		
		-- Protection Buffs
		ST:RegisterBuff(64883); -- Aegis (T8 4-Set)
		ST:RegisterBuff(37193); -- Infused Shield (T5 4-Set)
		ST:RegisterBuff(642); -- Divine Shield
		ST:RegisterBuff(20925); -- Holy Shield
		
		-- Retribution Buffs
		ST:RegisterBuff(59578,1); -- The Art of War
		ST:RegisterBuff(57669); -- Replenishment
		ST:RegisterBuff(20050); -- Vengeance
		ST:RegisterBuff(85696); -- Zealotry
		ST:RegisterBuff(90174); -- Hand of Light
		
		ST:RegisterDebuff(25771); -- Forbearance
		
		ST:RegisterCasterBuffs();
		ST:RegisterMeleeBuffs();
	end
	if CD then
		-- Holy Buffs
		CD:RegisterCooldownBuff(20165); -- Seal of Insight

		-- Protection Buffs
		CD:RegisterCooldownBuff(20217); -- Blessing of Kings
		CD:RegisterCooldownBuff(25780); -- Righteous Fury
		CD:RegisterCooldownBuff(20164); -- Seal of Justice
		CD:RegisterCooldownBuff(20154); -- Seal of Righteousness

		-- Retribution Buffs
		CD:RegisterCooldownBuff(19740); -- Blessing of Might
		CD:RegisterCooldownBuff(31801); -- Seal of Truth
		
		CD:RegisterCasterPowerupCooldowns();
		CD:RegisterMeleePowerupCooldowns();
	end
end

