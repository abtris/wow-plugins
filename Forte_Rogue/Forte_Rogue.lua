-- ForteXorcist v1.974.5 by Xus 14-02-2011 for 4.0.6

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

		local sap = FW:SpellName(6770);
		ST:RegisterOnTimerBreak(function(unit,mark,spell)
			if spell == sap then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("SapBreak",unit);
			end
		end);
		ST:RegisterOnTimerFade(sap,"SapFade");		
	end
	if CD then
		CD:RegisterMeleePowerupCooldowns();
	end
	
	FW:SetMainCategory(FWL.RAID_MESSAGES,FW.ICON.MESSAGE,10,"RAIDMESSAGES");
		FW:SetSubCategory(FW.NIL,FW.NIL,1);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT1);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT2);
			FW:RegisterOption(FW.CHK,2,FW.NON,FWL.SHOW_IN_RAID,		FWL.SHOW_IN_RAID_TT,    "OutputRaid");
			FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SHOW_IN_CHANNEL,	FWL.SHOW_IN_CHANNEL_TT,	"Output");

	if ST then
		FW:SetSubCategory(FWL.BREAK_FADE,FW.ICON.SPECIFIC,2);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.BREAK_FADE_HINT1);
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SAP_BREAK,		"",    "SapBreak");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SAP_FADE,		"",    "SapFade");
	end
	
	FW.Default.OutputRaid = true;
	FW.Default.Output = true;
	FW.Default.OutputMsg = "MyProRogueChannel";

	FW.Default.SapBreak = 0;	FW.Default.SapBreakMsg = ">> Sap on %s Broke Early! <<";
	FW.Default.SapFade = 0;	FW.Default.SapFadeMsg = ">> Sap on %s Fading in 3 seconds! <<";
	
end
