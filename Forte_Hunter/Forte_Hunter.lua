-- ForteXorcist v1.974 by Xus 09-01-2011 for 4.0.3
-- Module started by Destard/Stormstalker fixes by Caleb & Xus

if FW.CLASS == "HUNTER" then
	local FW = FW;
	local FWL = FW.L;
	local HT = FW:ClassModule("Hunter");

	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;

	if ST then
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack

		ST:RegisterDefaultHasted(0); -- set abilities to not use haste in their durations by default

		ST:RegisterSpell(20736, 0,06,0,ST.UNIQUE); 	-- Distracting Shot
		ST:RegisterSpell(51755, 0,60,0,ST.UNIQUE); 	-- Camouflage
		--ST:RegisterSpell(77769,	0,15,0,ST.UNIQUE);	-- Trap Launcher
		ST:RegisterSpell( 1543,	0,20,0,ST.UNIQUE);	-- Flare
		ST:RegisterSpell( 1130,	1,300,0,ST.UNIQUE);	-- Hunter's Mark
		ST:RegisterSpell( 1513,	1,020,0,ST.UNIQUE);	-- Scare Beast
		ST:RegisterSpell(  136,	0,010,0,ST.PET);	-- Mend Pet
		ST:RegisterSpell( 6991,	0,010,0,ST.PET);	-- Feed Pet
		ST:RegisterSpell( 1978,	1,015,1,ST.SHARED);	-- Serpent Sting
		ST:RegisterSpell(82654, 1,030,0,ST.DEFAULT);-- Widow Venom
		ST:RegisterSpell(53301, 1,002,0,ST.DEFAULT);-- Explosive Shot
			ST:RegisterTickSpeed(53301, ST.DEFAULT);-- set tick speed to 1 instead of 3
		ST:RegisterSpell( 2974, 1,010,0,ST.UNIQUE); -- Wing Clip
		ST:RegisterSpell(19503, 1,004,0,ST.UNIQUE); -- scatter shot
		ST:RegisterSpell(19386, 1,030,0,ST.UNIQUE);	-- wyvern sting
		ST:RegisterSpell(34490, 1,003,0,ST.UNIQUE);	-- silencing shot
		ST:RegisterSpell(50245, 1,004,0,ST.PET);	-- pet pin
		ST:RegisterSpell(35100, 1,004,0,ST.UNIQUE);	-- concussive barrage
		ST:RegisterSpell( 3674, 1,015,1,ST.DEFAULT);-- black arrow
		ST:RegisterSpell(53234, 1,000,1,ST.DEFAULT);-- Piercing Shots
			ST:RegisterTickSpeed(53234, 1); 		-- set tick speed to 1 instead of 3

		ST:RegisterCooldown(781,025);-- Disengage
			ST:RegisterCooldownModGlph(781,56844, -5); -- Glyph of Disengage
			
		--[[ST:RegisterCooldown(61006,015); -- Kill Shot
			ST:RegisterCooldownModGlph(61006,64304,	1, -6); -- Glyph of Kill Shot
		ST:RegisterCooldown(49050,010); -- Aimed Shot
			ST:RegisterCooldownModGlph(49050,56869,	1, -2); -- Glyph of Aimed Shot
		ST:RegisterCooldown(49048,010); -- Multi Shot
			ST:RegisterCooldownModGlph(49048,56882,	1, -1); -- Glyph of Multi Shot
		ST:RegisterCooldown(49045,006); -- Arcane Shot]]

		-- pet buffs/debuffs
		--ST:RegisterSpell(19615, 0,010,0,ST.DEFAULT); -- Frenzy Effect on pet

		ST:RegisterBuff(90355); -- Bloodlust / Heroism - Core Hound E
		ST:RegisterBuff(90361); -- Spirit Mend - Spirit Beast E
		ST:RegisterBuff(90363); -- Stat Boost (Bok) - Shale Spider
		ST:RegisterBuff(90364); -- Stamina Buff - Silithid E
		ST:RegisterBuff(24604); -- Critical Strike Buff - Wolf/Dog
		ST:RegisterBuff(90309); -- Critical Strike Buff - Devilsaur

		ST:RegisterSpell(58604, 1,010,0,ST.PET); -- Casting Speed Reduction - Core Hound E
		ST:RegisterSpell(50274, 1,009,0,ST.PET); -- Casting Speed Reduction - Sporebat
		ST:RegisterSpell(50285, 1,008,0,ST.PET); -- Attack Speed Reduction - Tallstrider
		ST:RegisterSpell(90314, 1,008,0,ST.PET); -- Attack Speed Reduction - Fox
		ST:RegisterSpell(50433, 1,006,0,ST.PET); -- Movement speed Reduction - Crocolisk
		ST:RegisterSpell(54644, 1,005,0,ST.PET); -- Movement speed Reduction - Chimaera E
		ST:RegisterSpell(35346, 1,006,0,ST.PET); -- Movement speed Reduction - Warp Stalker
		ST:RegisterSpell(54680, 1,008,0,ST.PET); -- Healing Debuff - Devilsaur E
		ST:RegisterSpell(54706, 1,005,0,ST.PET); -- Root - Silithid E
		ST:RegisterSpell( 4167, 1,005,0,ST.PET); -- Root - Spider
		ST:RegisterSpell(50318, 1,002,0,ST.PET); -- Silence / Interrupt - Moth
		ST:RegisterSpell(50498, 1,030,0,ST.PET); -- Armor Reduction (Sunder Armor) - Raptor
		ST:RegisterSpell(35387, 1,030,0,ST.PET); -- Armor Reduction (Sunder Armor) - Serpent
		ST:RegisterSpell(35290, 1,015,0,ST.PET); -- Increaed Bleed Damage - Boar
		ST:RegisterSpell(50271, 1,015,0,ST.PET); -- Increaed Bleed Damage - Hyena
		ST:RegisterSpell(34889, 1,045,0,ST.PET); -- Increased Magic Damage - Dragonhawk
		ST:RegisterSpell(24844, 1,045,0,ST.PET); -- Increased Magic Damage - Wind Serpent
		ST:RegisterSpell(55749, 1,025,0,ST.PET); -- Increased Physical Damage - Worm E
		ST:RegisterSpell(50518, 1,025,0,ST.PET); -- Increased Physical Damage - Ravager
		ST:RegisterSpell(50519, 1,002,0,ST.PET); -- Stun - Bird of Pray ?
		ST:RegisterSpell(56626, 1,002,0,ST.PET); -- Stun - Wasp
		ST:RegisterSpell(50256, 1,015,0,ST.PET); -- Physical Damage Reduction - Bear
		ST:RegisterSpell(50541, 1,010,0,ST.PET); -- Disarm - Scorpid

		ST:RegisterSpell(24394, 1,003,0,ST.PET); -- Intimidation

		-- hunter buffs
		ST:RegisterBuff(53434); -- Call of the Wild
		ST:RegisterBuff(82692); -- Focus Fire <NNF>
		ST:RegisterBuff(34692); -- The Beast Within
		ST:RegisterBuff( 3045); -- Rapid Fire
		ST:RegisterBuff(56453); -- Lock and Load
		ST:RegisterBuff(35099); -- Rapid Killing
		ST:RegisterBuff(40487); -- Deadly Aim
		ST:RegisterBuff(53271); -- Master's call
		ST:RegisterBuff(19263); -- Deterrence
		ST:RegisterBuff(34477); -- Misdirection
		ST:RegisterBuff(53304); -- Sniper Training
		ST:RegisterBuff(34839); -- Master Tactician
		ST:RegisterBuff(70728); -- Exploit Weakness (t10)
		
		ST:RegisterBuff(77769,1); -- Trap Launcher

		ST:RegisterSpell(34600,	0,060,0,ST.UNIQUE);-- Snake Trap

		ST:RegisterSpell(13809, 0,060,0,ST.UNIQUE);-- Ice Trap
		ST:RegisterSpell(13813,	0,060,0,ST.UNIQUE);-- Explosive Trap
		ST:RegisterSpell(13795, 1,060,0,ST.UNIQUE); -- Immolation Trap
		ST:RegisterSpell(1499, 1,060,0,ST.UNIQUE); -- Freezing Trap

		--debuffname
		ST:RegisterDebuff(3355); -- Freezing Trap Effect
		ST:RegisterDebuff(53338); -- Hunter's Mark
		ST:RegisterDebuff(20736); -- Distracting Shot

		ST:RegisterMeleeBuffs();
		ST:RegisterCasterBuffs();
		
		do
			local explosive_trap = FW:SpellName(13813); -- use name instead of id because of possible diff ids
			local ice_trap = FW:SpellName(13809); -- use name instead of id because of possible diff ids
			local snake_trap = FW:SpellName(34600); -- use name instead of id because of possible diff ids
			local PLAYER = FW.PLAYER;
			local select = select;
			local strsub = strsub;
			local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE;
			local band = bit.band;
			
			local function HT_CombatLogEvent(event,...)
				if select(4,...) == PLAYER then
					if select(2,...) == "SPELL_AURA_APPLIED" then
						if select(10,...) == explosive_trap then
							local i = ST.ST:find(explosive_trap,8);
							if i and ST.ST[i][15] == 1 then
								ST.ST[i][1] = GetTime()+20;
								ST.ST[i][14] = 0;
								ST.ST[i][15] = 0; -- use this to set as already triggered
								ST.ST[i][12] = 0; -- reset the fade event on refresh
							end
						elseif select(10,...) == ice_trap then
							local i = ST.ST:find(ice_trap,8);
							if i and ST.ST[i][15] == 1 then
								ST.ST[i][1] = GetTime()+30;
								ST.ST[i][14] = 0;
								ST.ST[i][15] = 0; -- use this to set as already triggered
								ST.ST[i][12] = 0; -- reset the fade event on refresh
							end
						end
					end
				elseif select(2,...) == "SWING_DAMAGE" then
					-- pet is mine and it's a snake
					if select(4,...) == FWL.SNAKE1 and band(select(5,...),COMBATLOG_OBJECT_AFFILIATION_MINE)>0 then
						local i = ST.ST:find(snake_trap,8);
						if i and ST.ST[i][15] == 1 then
							ST.ST[i][1] = GetTime()+15;
							ST.ST[i][14] = 0;
							ST.ST[i][15] = 0; -- use this to set as already triggered
							ST.ST[i][12] = 0; -- reset the fade event on refresh
						end
					end
				end
			end
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	HT_CombatLogEvent);
		end
	end
	if CD then
		tinsert(CD.Masters,{"^"..FW:SpellName(13795)}); -- immolation trap
		tinsert(CD.Masters,{"^"..FW:SpellName(1499)}); -- freezing trap

		CD:RegisterMeleePowerupCooldowns();
		CD:RegisterCasterPowerupCooldowns();

		CD:RegisterHiddenCooldown(nil,56453,22); -- Lock and Load

		local readiness = FW:SpellName(23989);
		local bestial_wrath = FW:SpellName(19574);

		CD:RegisterOnCooldownUsed(function(s,d)
			if s == readiness then
				local i = 1; -- needs testing, but should work in theory
				while i<=CD.CD.rows do
					if CD.CD[i][6]==1 then -- FLAG_SPELL only
						local spell = CD.CD[i][1];
						if spell ~= readiness and spell ~= bestial_wrath then
							CD:CheckCooldown(spell,GetTime(),0,"",1);
						end
					end
					i=i+1;
				end
			end
		end);
	end
end