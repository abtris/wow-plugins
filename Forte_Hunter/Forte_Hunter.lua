-- ForteXorcist v1.973.1 by Xus 26-12-2010 for 4.0.3
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
		-- DON'T SET ANYTHING WITH TRAVEL TIME TO DOT YET PLX
		ST:RegisterDefaultHasted(0); -- set abilities to not use haste in their durations by default
		
		ST:RegisterChannel(1510,0,2); -- Volley
		
 		ST:RegisterSpell(1543,	0,20,0,ST.UNIQUE);-- Flare
 		ST:RegisterSpell(1130,	1,300,0,ST.UNIQUE);-- Hunter's Mark
 		ST:RegisterSpell(1513,	1,020,0,ST.UNIQUE);-- Scare Beast
		ST:RegisterSpell(136,	0,010,0,ST.PET);-- Mend Pet
		ST:RegisterSpell(6991,	0,010,0,ST.PET);-- Feed Pet
 		ST:RegisterSpell(1978,	1,015,1,ST.SHARED);-- Serpent Sting
		ST:RegisterSpell(3034,	1,008,0,ST.SHARED); -- Viper Sting
		ST:RegisterSpell(3043,	1,020,0,ST.SHARED); -- Scorpid Sting
		ST:RegisterSpell(53301, 1,002,0,ST.DEFAULT);-- Explosive Shot
			ST:RegisterTickSpeed(53301, ST.DEFAULT); -- set tick speed to 1 instead of 3
		ST:RegisterSpell(2974 , 1,010,0,ST.UNIQUE); -- Wing Clip
		ST:RegisterSpell(19503, 1,004,0,ST.UNIQUE); -- scatter shot
		ST:RegisterSpell(19386, 1,030,0,ST.UNIQUE);	-- wyvern sting			
		ST:RegisterSpell(34490, 1,003,0,ST.UNIQUE);	-- silencing shot
		ST:RegisterSpell(50245, 1,004,0,ST.PET);	-- pet pin
		ST:RegisterSpell(35100, 1,004,0,ST.UNIQUE);	-- concussive barrage
		ST:RegisterSpell(3674, 1,015,1,ST.DEFAULT);	-- black arrow
		ST:RegisterSpell(53234, 1,000,1,ST.DEFAULT); -- Piercing Shots
			ST:RegisterTickSpeed(53234, 1); -- set tick speed to 1 instead of 3	

		ST:RegisterSpell(55749, 1,000,0,ST.PET,000,1,2);	-- pet acid spit (030 set to 000 because of travel time)			
		
		ST:RegisterCooldown(781,025);-- Disengage
			ST:RegisterCooldownModGlph(781,56844, -5); -- Glyph of Disengage
					
		--[[ST:RegisterCooldown(61006,015); -- Kill Shot
			ST:RegisterCooldownModGlph(61006,64304, -6); -- Glyph of Kill Shot
		ST:RegisterCooldown(49050,010); -- Aimed Shot
			ST:RegisterCooldownModGlph(49050,56869, -2); -- Glyph of Aimed Shot
		ST:RegisterCooldown(49048,010); -- Multi Shot
			ST:RegisterCooldownModGlph(49048,56882, -1); -- Glyph of Multi Shot
		ST:RegisterCooldown(49045,006); -- Arcane Shot]]


			-- hunter buffs
		ST:RegisterBuff(34692); -- The Beast Within
		ST:RegisterBuff(3045); -- Rapid Fire
		ST:RegisterBuff(56342); -- Lock and Load
		ST:RegisterBuff(34948); -- Rapid Killing
		ST:RegisterBuff(40487); -- Deadly Aim
		ST:RegisterBuff(53271); -- Master's call
		ST:RegisterBuff(19263); -- Deterrence
		ST:RegisterBuff(34477); -- Misdirection
		ST:RegisterBuff(53302); -- Sniper Training
		ST:RegisterBuff(34500); -- Expose Weakness
		ST:RegisterBuff(34833); -- Master Tactician
		ST:RegisterBuff(24604); -- Furious Howl
		ST:RegisterBuff(70728); -- Exploit Weakness (t10)
		ST:RegisterBuff(6150); -- Quick Shots (imp asp o t hawk)
		
		ST:RegisterSpell( 3355, 1,060,0,ST.UNIQUE); -- Freezing Trap
		ST:RegisterSpell(13809,	0,060,0,ST.UNIQUE); -- Frost Trap
 		ST:RegisterSpell(34600,	0,060,0,ST.UNIQUE); -- Snake Trap
 		ST:RegisterSpell(13813,	1,060,0,ST.UNIQUE); -- Explosive Trap
		ST:RegisterSpell(13795, 1,060,0,ST.UNIQUE); -- Immolation Trap
					
		--debuffname
 		ST:RegisterDebuff(3355); -- Freezing Trap Effect
		ST:RegisterDebuff(1130); -- Hunter's Mark
		
		ST:RegisterMeleeBuffs();
		ST:RegisterCasterBuffs();
	end
	if CD then
		tinsert(CD.Masters,{"^"..FW:SpellName(13795)}); -- immolation trap
		tinsert(CD.Masters,{"^"..FW:SpellName(1499)}); -- freezing trap
		tinsert(CD.Masters,{"^"..FW:SpellName(3044)}); -- arcane shot
		tinsert(CD.Masters,{"^"..FW:SpellName(19434)}); -- aimed shot
		
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