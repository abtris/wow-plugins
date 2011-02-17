-- ForteXorcist v1.974.5 by Xus 14-02-2011 for 4.0.6

if FW.CLASS == "WARRIOR" then
	local FW = FW;
	local FWL = FW.L;
	local WR = FW:ClassModule("Warrior");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	if ST then
	
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack
		ST:RegisterDefaultHasted(0); -- set abilities to not use haste in their durations by default
		
		ST:RegisterSpell(7386,	1,030,0,ST.DEFAULT,000,0,3); -- Sunder Armor
		ST:RegisterSpell(355,	1,003,0,ST.UNIQUE); -- Taunt
		ST:RegisterSpell(694,	1,006,0,ST.UNIQUE); -- Mocking Blow
		ST:RegisterSpell(676,	1,010,0,ST.UNIQUE); -- Disarm
		ST:RegisterSpell(12294,	1,010,0,ST.DEFAULT); -- Mortal Strike
		ST:RegisterSpell(12834,	1,006,1,ST.DEFAULT); -- Deep Wounds
			ST:RegisterTickSpeed(12834, 1); -- set tick speed to 1 instead of 3
		ST:RegisterSpell(772,	1,015,1,ST.DEFAULT); -- Rend
			ST:RegisterSpellModGlph(772, 58399, 6);
		ST:RegisterSpell(1715,	1,015,0,ST.DEFAULT); -- Hamstring
		ST:RegisterSpell(1160,	0,030,0,ST.UNIQUE); -- Demoralizing Shout   
		ST:RegisterSpell(5246,	0,008,0,ST.UNIQUE); -- Intimidating Shout
		ST:RegisterSpell(6343,	0,030,0,ST.UNIQUE); -- Thunder Clap
		ST:RegisterSpell(12323,	0,006,0,ST.UNIQUE); -- Piercing Howl	 
		ST:RegisterSpell(50720,	1,1800,0,ST.BUFF); -- Vigilance
		
		ST:RegisterSpell(86346,	1,006,0,ST.DEFAULT); -- Colossus Smash
		ST:RegisterSpell(85388,	1,005,0,ST.DEFAULT); -- Throwdown
		
		--buffname,duration
		ST:RegisterBuff(29131); -- Bloodrage
		ST:RegisterBuff(469); -- Commanding Shout
		ST:RegisterBuff(12880); -- Enrage
		ST:RegisterBuff(29801); -- Rampage
		ST:RegisterBuff(12328); -- Sweeping Strikes
		ST:RegisterBuff(12292);	-- Death Wish
		
		ST:RegisterBuff(6673); -- Battle Shout
		ST:RegisterBuff(18499); -- Berserker Rage
		ST:RegisterBuff(1719); -- Recklessness
		
		ST:RegisterBuff(56636); -- Taste for Blood
	
		-- Slam!
		ST:RegisterBuff(46916);	
		
		ST:RegisterBuff(85730); -- Deadly Calm
		ST:RegisterBuff(1134); -- Inner Rage
		ST:RegisterBuff(50685); -- Incite
		ST:RegisterBuff(84584); -- Slaughter
		
		--debuffs
		ST:RegisterDebuff(58567); -- Sunder Armor
		ST:RegisterDebuff(12294); -- Mortal Strike
		ST:RegisterDebuff(1715); -- Hamstring
		ST:RegisterDebuff(6343); -- Thunder Clap
		ST:RegisterDebuff(1160); -- Demoralizing Shout    
		ST:RegisterDebuff(20511); -- Intimidating Shout
		ST:RegisterDebuff(12323); -- Piercing Howl
		
		ST:RegisterDebuff(86346); -- Colossus Smash
		ST:RegisterDebuff(85388); -- Throwdown
		
		ST:RegisterMeleeBuffs();
	end
	if CD then
		CD:RegisterCooldownBuff(6673); -- Battle Shout
		CD:RegisterHiddenCooldown(nil,60503,6); -- Taste for Blood
		CD:RegisterMeleePowerupCooldowns();
	end
end
