-- ForteXorcist v1.974.5 by Xus 14-02-2011 for 4.0.6

if FW.CLASS == "DEATHKNIGHT" then
	local FW = FW;
	local FWL = FW.L;
	local DK = FW:ClassModule("DeathKnight");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	if ST then
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack
		ST:RegisterDefaultHasted(0); -- set abilities to not use haste in their durations by default
		CA:RegisterGCDStance(3,1.0);
		
		ST:RegisterSpellRename(45477,55095); -- Icy Touch to Frost Fever
		ST:RegisterSpell(55095,	1,021,1,ST.DEFAULT); -- Frost Fever
			ST:RegisterSpellModTlnt(55095,49036,1,4); -- 49036 = Epidemic
			ST:RegisterSpellModTlnt(55095,49036,2,8);
			ST:RegisterSpellModTlnt(55095,49036,3,12);
			
		ST:RegisterSpellRename(45462,59879); -- Plague Strike to Blood Plague
		ST:RegisterSpell(59879,	1,021,1,ST.DEFAULT); -- Blood Plague
			ST:RegisterSpellModTlnt(59879,49036,1,4); -- 49036 = Epidemic
			ST:RegisterSpellModTlnt(59879,49036,2,8);
			ST:RegisterSpellModTlnt(59879,49036,3,12);
			
		ST:RegisterSpell(45524,	1,008,0,ST.UNIQUE); -- Chains of Ice
		ST:RegisterSpell(47528,	1,004,0,ST.UNIQUE); -- Mind Freeze
		ST:RegisterSpell(47476,	1,005,0,ST.UNIQUE); -- Strangulate
		
		ST:RegisterSpell(49576,	1,003,0,ST.UNIQUE); -- Death Grip
		ST:RegisterSpell(56222,	1,003,0,ST.UNIQUE); -- Dark Command
		
		ST:RegisterSpell(49016,	1,030,0,ST.BUFF); -- Hysteria
		ST:RegisterSpell(57532,	0,300,0,ST.PET); -- "Eye of Acherus"
			
		ST:RegisterSpell(43265, 0,010,0,ST.DEFAULT); -- D&D
			ST:RegisterTickSpeed(43265, 1); -- make this show ticks
		ST:RegisterSpell(49194, 1,000,1,ST.DEFAULT); -- Unholy Blight
			ST:RegisterTickSpeed(49194, 1); -- make this show ticks
		
		ST:RegisterSpell(51714, 1,020,0,ST.DEFAULT); -- Frost Vulnerability
		ST:RegisterSpell(49206, 0,030,0,ST.PET); -- Gargoyle
		ST:RegisterSpell(63560, 0,030,0,ST.PET); -- Dark Transformation
		
		--ST:RegisterSpell(65142, 1,000,0,ST.DEFAULT); -- Ebon Plague
		
		ST:RegisterBuff(60068); -- Path of Frost
		--
		ST:RegisterBuff(50449); -- "Bloody Vengeance"
		ST:RegisterBuff(55972); -- "Abominable Might"
		ST:RegisterBuff(50421); -- "Scent of Blood"
		ST:RegisterBuff(55233); -- "Vampiric Blood" (prolly not the debuff id)
		
		ST:RegisterBuff(58130); -- Icebound Fortitude
		ST:RegisterBuff(53766); -- Anti-Magic Shell		
		ST:RegisterBuff(53365); -- Unholy Strength
		ST:RegisterBuff(49028); -- Dancing Rune Weapon	
		ST:RegisterBuff(51271); -- Unbreakable Armor
		ST:RegisterBuff(50152); -- Acclimation	
		ST:RegisterBuff(50887); -- Icy Talons
		
		ST:RegisterBuff(49222); -- Bone Shield
	
		ST:RegisterBuff(52424); -- Retaliation, from DK trinket
		ST:RegisterBuff(60826); -- Sigil of Haunted Dreams 	
		ST:RegisterBuff(62146); -- Sigil of the Unfaltering Knight	

		ST:RegisterBuff(55670); -- Desecration
		ST:RegisterBuff(50466); -- Death Trance! (instant cast)
		ST:RegisterBuff(49039); -- Lichborne
		ST:RegisterBuff(51124); -- Killing Machine (instant cast)
		
		ST:RegisterBuff(66803); -- Desolation
		ST:RegisterBuff(59052); -- Freezing Fog (no runes used for howling blast)
		ST:RegisterBuff(71227); -- Indomitable
		ST:RegisterBuff(51460); -- Runic Corruption
		ST:RegisterBuff(81340); -- Sudden Doom
	
		ST:RegisterMeleeBuffs();
		ST:RegisterCasterBuffs();
		
		ST:RegisterBuff(51052); -- Anti-Magic Zone
		
		-- Old shaman code Code to track totems, also used for the ghoul!
		local SH_CurrentTotem = {"","","",""};
		local function SH_TotemUpdate(event,index)
			-- Fire = 1 Earth = 2 Water = 3 Air = 4
			local _, name, startTime, duration, icon = GetTotemInfo(index);
			--FW:Show(tostring(name))
			--FW:Show(tostring(startTime))
			--FW:Show(tostring(duration))
			if SH_CurrentTotem[index] ~= "" then
				local i = ST.ST:find(SH_CurrentTotem[index],8);
				if i then
					if name ~= "" then
						ST.ST:remove(i);
					else
						if ST.ST[i][1]-GetTime()<0.75 then
							ST:Fade(i,2);
						else
							ST:Fade(i,3);
						end
					end
				end
			end
			if name ~= "" then
				ST.ST:insert(startTime+duration,0,duration,name,0,ST.PET,icon,name,2,0,"none",0,ST.PRIOR_NONE,0,1,0,0,"filter",0,startTime+duration,duration,1.0,0);
			end
			SH_CurrentTotem[index] = name;
		end
		FW:RegisterToEvent("PLAYER_TOTEM_UPDATE", SH_TotemUpdate);
	end
	if CD then
		CD:RegisterMeleePowerupCooldowns();
		
		local RUNETYPE_BLOOD = 1;
		local RUNETYPE_UNHOLY = 2;
		local RUNETYPE_FROST = 3;
		local RUNETYPE_DEATH = 4;
		
		local iconTextures = {
			[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood",
			[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy",
			[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost",
			[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death",
		}
		-- don't alter the texture for these group masters
		tinsert(CD.Masters,{"^"..FWL.RUNE_BLOOD});
		tinsert(CD.Masters,{"^"..FWL.RUNE_UNHOLY});
		tinsert(CD.Masters,{"^"..FWL.RUNE_FROST});
		
		local runeNames = {
			FWL.RUNE_BLOOD,
			FWL.RUNE_UNHOLY,
			FWL.RUNE_FROST,
		}
		local runeToType = {
			1,1,
			2,2,
			3,3
		}
		-- add a system to support runes, will use new icon override system	in future	
		local function DK_RuneUpdate(event,rune--[[,usable]])
			local r = GetRuneType(rune);
			local t = runeToType[rune];
			--FW:Show(event.." "..tostring(r));
			if r then
				local start, duration, runeReady = GetRuneCooldown(rune);
				--FW:Show(start.." "..duration.." "..tostring(runeReady));
				if runeReady then
					CD:CheckCooldown(runeNames[t].." ("..rune..")",0,0,iconTextures[r],CD.LAST_FLAG+t)-- 10 is currently the last original type
				else
					CD:CheckCooldown(runeNames[t].." ("..rune..")",start,duration,iconTextures[r],CD.LAST_FLAG+t)-- 10 is currently the last original type
				end
			end
		end
		FW:RegisterToEvent("RUNE_POWER_UPDATE",DK_RuneUpdate);
		FW:RegisterToEvent("RUNE_TYPE_UPDATE", DK_RuneUpdate);
		
		CD:RegisterCooldownBuff(49222); -- bone shield
		CD:RegisterCooldownBuff(60068); -- path of frost
		CD:RegisterCooldownBuff(57330); -- horn of winter
		
		FW:SetMainCategory(FWL.COOLDOWN_TIMER,FW.ICON.CD,4,"COOLDOWN","Cooldown","Cooldown");
			FW:SetSubCategory(FWL.MY_COOLDOWNS,FW.ICON.FILTER,5);
				FW:RegisterOption(FW.CO2,1,FW.NON,FWL.RUNE_BLOOD,			"",	"RuneBlood",	CD.CooldownGroupEnable);	
				FW:RegisterOption(FW.CO2,1,FW.NON,FWL.RUNE_UNHOLY,			"",	"RuneDeath",	CD.CooldownGroupEnable);	
				FW:RegisterOption(FW.CO2,1,FW.NON,FWL.RUNE_FROST,			"",	"RuneFrost",	CD.CooldownGroupEnable);	
		
		FW.Default.Cooldown.RuneBloodColor = {1.00,0.00,0.00};
		FW.Default.Cooldown.RuneBloodEnable = true;
		FW.Default.Cooldown.RuneDeathColor = {0.20,0.80,0.00};
		FW.Default.Cooldown.RuneDeathEnable = true;
		FW.Default.Cooldown.RuneFrostColor = {0.00,0.43,1.00};
		FW.Default.Cooldown.RuneFrostEnable = true;
		
		CD:AddCooldownFlag("RuneBlood");
		CD:AddCooldownFlag("RuneDeath");
		CD:AddCooldownFlag("RuneFrost");
	end
end
