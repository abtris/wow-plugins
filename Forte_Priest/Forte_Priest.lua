-- ForteXorcist v1.974 by Xus 09-01-2011 for 4.0.3

if FW.CLASS == "PRIEST" then
	local FW = FW;
	local FWL = FW.L;
	local PR = FW:ClassModule("Priest");
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	FW:RegisterSet("Absolution Regalia",31061,31064,31067,31070,31065,34434,34528,34563);
	FW:RegisterSet("Velen's/Zabra's Regalia",
		48072,48073,48074,48075,48076,
		48077,48078,48079,48080,48081,
		48082,48083,48084,48085,48086,
		48087,48088,48089,48090,48091,
		48092,48093,48094,48095,48096,
		48097,48098,48099,48100,48101
	);	
		
	if ST then
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack
 		
 		ST:RegisterSpell(589,	1,018,1,ST.DEFAULT); -- Shadow Word: Pain
			ST:RegisterSpecialRefresh(589);
			ST:RegisterSpellModSetB(589,	"Absolution Regalia", 2, 3);
		ST:RegisterSpell(34914,	1,015,1,ST.DEFAULT); -- Vampiric Touch
			ST:RegisterSpellModSetB(34914,	"Velen's/Zabra's Regalia", 2, 6);
 		ST:RegisterSpell(34433,	0,015,0,ST.PET); -- Shadowfiend
 		ST:RegisterSpell(8122,	0,008,0,ST.UNIQUE); -- Psychic Scream
			ST:RegisterSpellModGlph(8122, 56177, 2); -- Glyph of Psychic Scream
 		ST:RegisterSpell(9484,	1,050,0,ST.UNIQUE); -- Shackle Undead
		ST:RegisterSpell(453,	1,015,0,ST.UNIQUE); -- Mind Soothe
		ST:RegisterSpell(17,	1,030,0,ST.BUFF); -- Power Word: Shield
		ST:RegisterSpell(139,	1,012,0,ST.HEAL); -- Renew

		ST:RegisterSpell(2944,	1,024,1,ST.UNIQUE); -- Devouring Plague 
		ST:RegisterSpell(15487,	1,005,0,ST.UNIQUE); -- Silence
		ST:RegisterSpell(14914, 1,007,1,ST.DEFAULT); -- holy fire
			ST:RegisterTickSpeed(14914, 1); -- set tick speed to 1 instead of 3
		
		ST:RegisterSpell(33076,	1,030,0,ST.BUFF); -- Prayer of Mending
		ST:RegisterSpell(14893,	1,015,0,ST.BUFF); -- Inspiration
		--ST:RegisterSpell(  552, 1,012,0,ST.BUFF); -- Abolish Disease		
		ST:RegisterSpell(33206, 1,008,0,ST.BUFF); -- Pain Suppression
		ST:RegisterSpell(10060, 1,015,0,ST.BUFF); -- Power Infusion
		ST:RegisterSpell(47788, 1,010,0,ST.BUFF); -- Guardian Spirit
		
		ST:RegisterSpell(47509, 1,012,0,ST.BUFF); -- Divine Aegis
		ST:RegisterSpell(47516, 1,015,0,ST.BUFF,000,1,3); -- Grace
		ST:RegisterSpell(70772, 1,009,0,ST.HEAL); -- Blessed Healing (2 set T10)
		ST:RegisterSpell(87178, 1,012,0,ST.DEFAULT,000,1,3); -- Mind Spike
		
		ST:RegisterCooldown(8092,008); -- Mind Blast
			ST:RegisterCooldownModTlnt(8092,	15273, 1, -0.5); -- Improved Mind Blast
			ST:RegisterCooldownModTlnt(8092,	15273, 2, -1.0);
			ST:RegisterCooldownModTlnt(8092,	15273, 3, -1.5);
			ST:RegisterCooldownModTlnt(8092,	15273, 4, -2.0);
			ST:RegisterCooldownModTlnt(8092,	15273, 5, -2.5);
		ST:RegisterCooldown(32379,012); -- Shadow Word: Death
		
		-- COPY-PASTED FROM CURSE:
		ST:RegisterCooldown(88682,015); -- Holy Word: Aspire 
		ST:RegisterCooldownModTlnt(88682, 14898, 1, -2.25); -- Tome of Light rank 1 
		ST:RegisterCooldownModTlnt(88682, 14898, 2, -4.5); --Tome of Light rank 2 

		ST:RegisterCooldown(88625,025); -- Holy Word: Chastise 
		ST:RegisterCooldownModTlnt(88625, 14898, 1, -3.75); --Tome of Light rank 1 
		ST:RegisterCooldownModTlnt(88625, 14898, 2, -7.5); --Tome of Light rank 2 

		ST:RegisterCooldown(88684,020); -- Holy Word: Serenity 
		ST:RegisterCooldownModTlnt(88684, 14898, 1, -3); --Tome of Light rank 1 
		ST:RegisterCooldownModTlnt(88684, 14898, 2, -6); --Tome of Light rank 2 

		ST:RegisterCooldown(88686,018); -- Holy Word: Sanctuary
		----------
				
		-- id/name, ticks total
		ST:RegisterChannel(15407,1,1); -- Mind Flay
		ST:RegisterChannel(48045,1,1); -- Mind Sear
		
		--Priest Buffs
		ST:RegisterBuff(63731); -- Serendipity
		ST:RegisterBuff(33151); -- Surge of Light
		ST:RegisterBuff(59887); -- Borrowed Time
		ST:RegisterBuff(34754); -- Holy Concentration
		ST:RegisterBuff(586); -- Fade
		ST:RegisterBuff(588); -- Inner fire
		ST:RegisterBuff(73413); -- Inner Will
		ST:RegisterBuff(15257); -- Shadow Weaving
		ST:RegisterBuff(47585); -- Dispersion
		ST:RegisterBuff(27839); -- Vampiric Embrace
		ST:RegisterBuff(45237); -- Focused Will

		--debuffname,mineonly
			
		-- weakened soul
 		ST:RegisterDebuff(6788);

		ST:RegisterCasterBuffs();
		
	end
	if CD then
		do
			local PLAYER = FW.PLAYER;
			local rapture,texture = FW:SpellName(47755); -- use name instead of id because of diff ranks
			local select = select;
			local function PR_CombatLogEvent(event,...)
				if select(4,...) == PLAYER and select(10,...) == rapture then
					CD:HiddenCooldown(rapture, 012, texture);
				end
			end
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	PR_CombatLogEvent);
		end
	
		CD:RegisterCooldownBuff(15290); -- Vampiric Embrace
		CD:RegisterCooldownBuff(48168); -- Inner Fire
		CD:RegisterCooldownBuff(73413); -- Inner Will
		CD:RegisterCasterPowerupCooldowns();
	end
end
