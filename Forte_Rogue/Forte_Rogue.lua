-- ForteXorcist v1.974 by Xus 09-01-2011 for 4.0.3

if FW.CLASS == "ROGUE" then
	local FW = FW;
	local FWL = FW.L;
	local PR = FW:ClassModule("Rogue");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	if ST then
		-- istype: ST.DEFAULT	ST.SHARED ST.UNIQUE	ST.PET ST.POWERUP ST.CHARM ST.DEBUFF ST.DRAIN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack
		
		ST:RegisterDefaultHasted(0); -- set abilities to not use haste in their durations by default
		
		-- Abilities
		ST:RegisterSpell(  408, 1, 000,0,ST.UNIQUE); -- Kidney Shot
		ST:RegisterSpell( 2094, 1, 000,0,ST.UNIQUE); -- Blind
		ST:RegisterSpell( 6770, 1, 000,0,ST.UNIQUE); -- Sap
		ST:RegisterSpell(18425, 1, 000,0,ST.UNIQUE); -- Kick silence
		ST:RegisterSpell(32748, 1, 000,0,ST.UNIQUE); -- Deadly Throw interrupt
		ST:RegisterSpell( 1330, 1, 000,0,ST.UNIQUE); -- Garrote silence	
		ST:RegisterSpell( 1833, 1, 000,0,ST.UNIQUE); -- Cheap Shot
		ST:RegisterSpell( 1776, 1, 000,0,ST.UNIQUE); -- Gouge
		ST:RegisterSpell(51722, 1, 000,0,ST.UNIQUE); -- Dismantle
		ST:RegisterSpell(30981, 1, 000,0,ST.UNIQUE); -- Crippling Poison
		ST:RegisterSpell( 5760, 1, 000,0,ST.UNIQUE); -- Mind-numbing Poison
		ST:RegisterSpell(13218, 1, 000,0,ST.UNIQUE); -- Wound Poison

		ST:RegisterSpell(57293, 1, 000,0,ST.UNIQUE); -- Revealing Strike
		ST:RegisterSpell(31126, 1, 000,0,ST.UNIQUE); -- Blade Twisting
		
		ST:RegisterSpell(  703, 1, 000,1,ST.DEFAULT); -- Garrote
		ST:RegisterSpell( 1943, 1, 000,1,ST.DEFAULT); -- Rupture
			ST:RegisterTickSpeed(1943, 2); -- set tick speed to 2 instead of 3	

		--ST:RegisterSpell(57993, 1, 000,0,ST.DEFAULT); -- Envenom
		
		-- Poisons
		ST:RegisterSpell( 2818, 1,000,1,ST.DEFAULT); -- Deadly Poison
	
		-- Self buffs
		ST:RegisterBuff(13750); -- Adrenaline Rush
		ST:RegisterBuff(13877); -- Blade Flurry
		ST:RegisterBuff(14177); -- Cold Blood
		ST:RegisterBuff(5277); -- Evasion
		ST:RegisterBuff(2983); -- Sprint
		ST:RegisterBuff(31224); -- Cloak of Shadows
		ST:RegisterBuff(1856); -- Vanish
		ST:RegisterBuff(1966); -- Feint
		ST:RegisterBuff(51662); -- Hunger for Blood
		ST:RegisterBuff(57934); -- Tricks of the Trade
		ST:RegisterBuff(5171); -- Slice and Dice
		ST:RegisterBuff(32645); -- Envenom
		ST:RegisterBuff(73651); -- Recuperate
		
		ST:RegisterMeleeBuffs();			
	end
	if CD then
		CD:RegisterMeleePowerupCooldowns();
	end
end
