-- ForteXorcist v1.974.7 by Xus 22-02-2011 for 4.0.6

if FW.CLASS == "WARLOCK" then
	local FW = FW;
	local WL = FW:ClassModule("Warlock");
	local FWL = FW.L;
	
	local UnitName = FW.FullUnitName;
	
	local CA = FW.Modules.Casting;
	local ST = FW.Modules.Timer;
	local CD = FW.Modules.Cooldown;
	
	--FW:RegisterSet("Voidheart Raiment",28963,28968,28966,28967,28964);
	
	--FW:RegisterCustomName(94310,"Dark Intent (Effect)");
	FW:RegisterCustomName(85768,FWL.DARK_INTENT_BUFF);
	
	if ST then
		-- istype: ST.DEFAULT ST.SHARED ST.UNIQUE ST.PET ST.CHARM ST.COOLDOWN ST.HEAL ST.BUFF
		-- spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stack

		-- id/name, ticks total
		ST:RegisterChannel(1120,1,3); -- Drain Soul
		ST:RegisterChannel(689,1,1); -- Drain Life
		ST:RegisterChannel(5138,1,1); -- Drain Mana
		ST:RegisterChannel(1949,0,1); -- Hellfire
		ST:RegisterChannel(5740,0,2); -- Rain of Fire
		ST:RegisterChannel(79268,0,3); -- Soul Harvest
		
		ST:RegisterSpell(85112,	1,007,1,ST.DEFAULT,000,0); -- Burning Embers
			ST:RegisterTickSpeed(85112, 1); -- set tick speed to 1 instead of 3
			
		ST:RegisterSpell(  348,	1,015,1,ST.DEFAULT); -- Immolate
			ST:RegisterSpecialRefresh(348);-- Immolate, refresh by Fel Flame
			--ST:RegisterSpellModSetB(348, 	"Voidheart Raiment", 4,  3);
		ST:RegisterSpell(  172,	1,018,1,ST.DEFAULT);-- Corruption
			ST:RegisterSpecialRefresh(172);-- Corruption refresh by Life Drain, Drain Soul, Haunt
			--ST:RegisterSpellModSetB(172,	"Voidheart Raiment", 4,  3);
		ST:RegisterSpell(30108,	1,015,1,ST.DEFAULT); -- Unstable Affliction
			ST:RegisterSpecialRefresh(30108);-- Unstable Affliction, refresh by Fel Flame
		
		ST:RegisterSpell(80240,	1,300,0,ST.UNIQUE); -- Bane of Havoc
		ST:RegisterSpell(  980,	1,024,1,ST.SHARED2); -- Bane of Agony
			ST:RegisterTickSpeed(980, 2); -- set tick speed to 2 instead of 3
			ST:RegisterSpellModGlph(980, 56282, 4);
		ST:RegisterSpell(  603,	1,060,1,ST.UNIQUE,000,0); -- Bane of Doom
			ST:RegisterTickSpeed(603, 15); -- set tick speed to 15 instead of 3
		
		ST:RegisterSpell( 1490,	1,300,0,ST.SHARED); -- Curse of the Elements
		ST:RegisterSpell(  702,	1,120,0,ST.SHARED); -- Curse of Weakness
		ST:RegisterSpell( 1714,	1,030,0,ST.SHARED,010); -- Curse of Tongues
		ST:RegisterSpell(46434,	1,030,0,ST.SHARED,012); -- Curse of Exhaustion
		ST:RegisterSpell(  710,	1,030,0,ST.UNIQUE,010); -- Banish
		ST:RegisterSpell( 5782,	1,020,0,ST.UNIQUE,010); -- Fear
		ST:RegisterSpell( 5484,	0,008,0,ST.UNIQUE); -- Howl of Terror
		ST:RegisterSpell( 1098,	1,300,0,ST.CHARM); -- Enslave Demon
		ST:RegisterSpell( 1122,	0,045,0,ST.PET); -- Infernal
			ST:RegisterSpellModTlnt(1122,85109,1,10);
			ST:RegisterSpellModTlnt(1122,85109,2,20);
		ST:RegisterSpell(18540,	0,045,0,ST.PET); -- Doomguard
			ST:RegisterSpellModTlnt(18540,85109,1,10);
			ST:RegisterSpellModTlnt(18540,85109,2,20);
		ST:RegisterSpell( 5697,	1,600,0,ST.BUFF); -- Unending Breath
		ST:RegisterSpell(48181,	1,000,0,ST.DEFAULT); -- Haunt (12sec set to 0 for travel time)
		ST:RegisterSpell(27243,	1,018,1,ST.DEFAULT); -- SoC
		ST:RegisterSpell(30283,	0,003,0,ST.UNIQUE); -- Shadowfury
		
		ST:RegisterSpell(47897,	1,000,1,ST.DEFAULT); -- Shadowflame
			ST:RegisterTickSpeed(47897, 2); -- set tick speed to 2 instead of 3
		ST:RegisterSpell(32385,	1,000,0,ST.DEFAULT); -- Shadow Embrace
		
		ST:RegisterSpell(85768,	1,1800,0,ST.BUFF); -- Dark Intent
		ST:RegisterSpell(71521,	0,015,0,ST.DEFAULT); -- Hand of Gul'dan
		
		ST:RegisterCooldown(17962,010); -- Conflag
			ST:RegisterCooldownModGlph(17962,56235,-2);
		ST:RegisterCooldown(50796,012); -- Chaos Bolt
		ST:RegisterCooldown(48181,008); -- Haunt
		ST:RegisterCooldown(71521,012); -- Hand of Gul'dan
		
		ST:RegisterSpell(6358,	1,030,0,ST.PET); -- Seduction
				
		--buffname
		ST:RegisterBuff(48018); -- Demonic Circle: Summon
		--ST:RegisterBuff(37378); -- Shadowflame
		--ST:RegisterBuff(37379); -- Flameshadow 
		ST:RegisterBuff(17941); -- Shadow Trance
		ST:RegisterBuff(51439); -- Backlash
		ST:RegisterBuff(47197); -- Eradication
		ST:RegisterBuff(61610); -- Metamorphosis
		ST:RegisterBuff(47283,1); -- Empowered Imp (set to non-stacking)
		ST:RegisterBuff(47383); -- Molten Core
		ST:RegisterBuff(63158); -- Decimation
		ST:RegisterBuff(54277); -- backdraft
		--ST:RegisterBuff(61595); -- demonic soul (t7 bonus)
		--ST:RegisterBuff(61082); -- spirits of the damned (t7 bonus)
		ST:RegisterBuff(63321); -- glyph of life tap buff
		ST:RegisterBuff(70840); -- Devious Minds
		ST:RegisterBuff(7812); -- Sacrifice
		
 		ST:RegisterBuff(54370); -- Nether Protection (Holy)
		ST:RegisterBuff(54371); -- Nether Protection (Fire)
		ST:RegisterBuff(54372); -- Nether Protection (Frost)
		ST:RegisterBuff(54373); -- Nether Protection (Arcane)
		ST:RegisterBuff(54374); -- Nether Protection (Shadow)
		ST:RegisterBuff(54375); -- Nether Protection (Nature)
		
		ST:RegisterBuff(85383); -- Improved Soul Fire
		ST:RegisterBuff(57669); -- Replenishment
		ST:RegisterBuff(94310); -- Dark Intent
		ST:RegisterBuff(79464); -- Demon Soul
		ST:RegisterBuff(79463); -- Demon Soul
		ST:RegisterBuff(79462); -- Demon Soul
		ST:RegisterBuff(79460); -- Demon Soul
		ST:RegisterBuff(79459); -- Demon Soul
		
		ST:RegisterBuff(88446); -- Demonic Rebirth
		ST:RegisterBuff(89937); -- Fel Spark
		
		-- important debuffs from others i want to track
		ST:RegisterDebuff(44836); -- Banish
		ST:RegisterDebuff(59669); -- Fear
		ST:RegisterDebuff(61191); -- Enslave Demon
		ST:RegisterDebuff(17928); -- Howl of Terror
		ST:RegisterDebuff(60946); -- Nightmare

		ST:RegisterCasterBuffs();

		FW.Default.Timer.Filter[FW:SpellName(48018)] = {nil,{-2,0.00,0.67,0.00}}; -- Demonic Circle: Summon
	end
	
	local t1,t2,t3,t4,t5,t6;
	local BP = {};
	
	local bp = FW:SpellName(47982);
	
	local function WL_ScanBloodpact(unit)
		local unitClass = select(2,UnitClass(unit));
		local unitName = UnitName(unit);
		if not unitClass or not unitName then return; end
		t1 = strlower(FW.Settings.BloodPactMsg);
		if strfind(t1,strlower(unitName)) or strfind(t1,strlower(unitClass)) or strfind(t1,"all") or (unit == "player" and strfind(t1,"self")) then
			t2 = UnitBuff(unit,bp);
			if BP[unitName] ~= t2 then
				if FW.Settings.BloodPact then
					if t2 then
						FW:Show(string.format(FWL._GAINED_BLOOD_PACT,unitName),unpack(FW.Settings.BloodpactGainColor));
					else
						FW:Show(string.format(FWL._LOST_BLOOD_PACT,unitName),unpack(FW.Settings.BloodpactLossColor));
					end
				end
				BP[unitName] = t2;
			end
		end
	end
	local PARTY = FW.PARTY;
	local RAID = FW.RAID;
	local function WL_BloodpactScan()
		if GetNumRaidMembers() > 0 then
			for i=1,GetNumRaidMembers(),1 do
				WL_ScanBloodpact(RAID[i]);
			end		
		else
			for i=1,GetNumPartyMembers(),1 do
				WL_ScanBloodpact(PARTY[i]);
			end
			WL_ScanBloodpact("player");
		end
	end
		
	FW:RegisterVariablesEvent(function()
		FW:RegisterTimedEvent("UpdateInterval",		WL_BloodpactScan);
	end);
	
	local devour = FW:SpellName(19505);
	local spelllock = FW:SpellName(19647);
	local consume = FW:SpellName(17767);
	local seduction = FW:SpellName(6358);
	
	if CA then
		local PetTarget = "";
	
		local sscast = FW:SpellName(20707);
		local summon = FW:SpellName(46546);
		local meeting = FW:SpellName(23598);
		local ritual = FW:SpellName(34143);
		
		CA:RegisterIsChannel(summon);
		
		CA:RegisterOnSelfCastStart(function(s,t)
			if s == summon then
				CA:CastShow("SummonStart",t);
			elseif s == sscast then
				CA:CastShow("SoulstoneStart",t);

			end
		end);
		CA:RegisterOnSelfCastCancel(function(s,t)
			if s == sscast then
				CA:CastShow("SoulstoneCancel",t); 
			elseif s == summon then
				CA:CastShow("SummonCancel",t);
			end
		end);
		CA:RegisterOnSelfCastSuccess(function(s,t,rank)
			if s == sscast then
				CA:CastShow("SoulstoneSuccess",t);
			elseif s == summon then
				CA:CastShow("SummonFinish",t);
			elseif s == ritual then
				CA:CastShow("SoulwellStart");
			elseif s == seduction then
				CA:CastShow("SeduceSuccess",t);
			end
		end);
		CA:RegisterOnPetCastSuccess(function(spell)
			if spell == devour then
				CA:CastShow("DevourMagicSuccess");
			elseif spell == spelllock then
				CA:CastShow("SpellLockSuccess");
			end
		end);
		CA:RegisterOnPetCastFailed(function(spell)
			if spell == devour then
				CA:CastShow("DevourMagicFailed");
			elseif spell == spelllock then
				CA:CastShow("SpellLockFailed");
			elseif spell == seduction then
				CA:CastShow("SeduceFailed");
			end
		end);
		CA:RegisterOnPetCastStart(function(spell)
			if spell == seduction then
				FW:DelayedExec(FW.Settings.PetTargetDelay,1,
					function()
						PetTarget = UnitName("pettarget");
						if PetTarget then
							CA:CastShow("SeduceStart",PetTarget);
						end
					end
				);
			end
		end);
	end
	if ST then
		local fear = FW:SpellName(5782);
		local banish = FW:SpellName(710);
		local enslave = FW:SpellName(1098);

		ST:RegisterOnTimerBreak(function(unit,mark,spell)
			if spell == fear then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("FearBreak",unit);
				return 1;
			elseif spell == banish then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("BanishBreak",unit);
				return 1;
			elseif spell == enslave then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("EnslaveBreak",unit);
				return 1;
			elseif spell == seduction then
				if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
				CA:CastShow("SeduceBreak",unit);
				return 1;
			end
		end);
		ST:RegisterOnTimerFade(fear,"FearFade");
		ST:RegisterOnTimerFade(banish,"BanishFade");
		ST:RegisterOnTimerFade(enslave,"EnslaveFade");
		ST:RegisterOnTimerFade(seduction,"SeduceFade");

		local backlash = FW:SpellName(51439);
		local shadowtrance = FW:SpellName(17941);
		local decimation = FW:SpellName(63158);
		ST:RegisterOnBuffGain(function(buff)
			if buff == backlash or buff == shadowtrance or buff == decimation then
				FW:PlaySound("TimerInstantSound");
			end
		end);
		
		
	end
	if CD then
		CD:RegisterOnCooldownReady(function(spell)
			if spell == devour then
				CA:CastShow("DevourMagicReady");
			elseif spell == spelllock then
				CA:CastShow("SpellLockReady");
			end
		end);
		
		CD:RegisterCooldownBuff(28176); -- fel armor
		CD:RegisterCooldownBuff(687); -- demon armor
		
		CD:RegisterCooldownBuff(18789); -- burning wish
		CD:RegisterCooldownBuff(18792); -- fel energy
		CD:RegisterCooldownBuff(35701); -- touch of shadow
		CD:RegisterCooldownBuff(18790); -- fel stamina
		
		CD:RegisterHiddenCooldown(nil,34935,08); -- Backlash	
		CD:RegisterHiddenCooldown(nil,85113,15); -- Improved Soul Fire
		
		CD:RegisterHiddenCooldown(nil,88446,120); -- Demonic Rebirth
		
		CD:RegisterCasterPowerupCooldowns();
	end
	
	FW:SetMainCategory(FWL.RAID_MESSAGES,FW.ICON.MESSAGE,10,"RAIDMESSAGES");
		FW:SetSubCategory(FW.NIL,FW.NIL,1,FW.EXPAND);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT1);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT2);
			FW:RegisterOption(FW.CHK,2,FW.NON,FWL.SHOW_IN_RAID,	FWL.SHOW_IN_RAID_TT,	"OutputRaid");
			FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SHOW_IN_CHANNEL,	FWL.SHOW_IN_CHANNEL_TT,"Output");
		
		if CA then
		FW:SetSubCategory(FWL.SUMMONING,FW.ICON.SPECIFIC,2);
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SUMMON_PORTAL,		"",	"SummonFinish");
							  
		FW:SetSubCategory(FWL.SOULSTONE_NORMAL,FW.ICON.SPECIFIC,2);
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SOULTONE_START,		"",	"SoulstoneStart");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SOULTONE_CANCEL,		"",	"SoulstoneCancel");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SOULTONE_SUCCESS,	"",	"SoulstoneSuccess");
			FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SOULTONE_START_W,	"",	"SoulstoneStartWhisper");
			FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SOULTONE_CANCEL_W,	"",	"SoulstoneCancelWhisper");
			FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SOULTONE_SUCCESS_W,	"",	"SoulstoneSuccessWhisper");
			
		FW:SetSubCategory(FWL.SOULWELL,FW.ICON.SPECIFIC,2);
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SOULWELL,		"",	"SoulwellStart");
		end

		FW:SetSubCategory(FWL.PET,FW.ICON.SPECIFIC,2);
			if CA then
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SEDUCE_START,		"",	"SeduceStart");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SEDUCE_SUCCESS,		"",	"SeduceSuccess");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SEDUCE_FAILED,		"",	"SeduceFailed");
			end
			if ST then
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SEDUCE_BREAK,		"",	"SeduceBreak");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SEDUCE_FADE,			"",	"SeduceFade");
			end
			if CA then
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SPELL_LOCK_SUCCESS,	"",	"SpellLockSuccess");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SPELL_LOCK_FAILED,	"",	"SpellLockFailed");
			end
			if CD then
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.SPELL_LOCK_READY,	"",	"SpellLockReady");
			end
			if CA then
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.DEVOUR_MAGIC_SUCCESS,"",	"DevourMagicSuccess");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.DEVOUR_MAGIC_FAILED,	"",	"DevourMagicFailed");
			end
			if CD then
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.DEVOUR_MAGIC_READY,	"",	"DevourMagicReady");
			end
		if ST then
		FW:SetSubCategory(FWL.BREAK_FADE,FW.ICON.SPECIFIC,2);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.BREAK_FADE_HINT1);
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.FEAR_BREAK,		"",	"FearBreak");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.FEAR_FADE,		"",	"FearFade");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.BANISH_BREAK,	"",	"BanishBreak");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.BANISH_FADE,		"",	"BanishFade");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.ENSLAVE_BREAK,	"",	"EnslaveBreak");
			FW:RegisterOption(FW.MS2,2,FW.NON,FWL.ENSLAVE_FADE,	"",	"EnslaveFade");
		end
		
	if ST then
	FW:SetMainCategory(FWL.SOUND,FW.ICON.SOUND,12,"SOUND");
		FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
			FW:RegisterOption(FW.SND,2,FW.NON,"Instant","","TimerInstantSound");
	end

	FW:SetMainCategory(FWL.SELF_MESSAGES,FW.ICON.SELFMESSAGE,11,"SELFMESSAGES");
		FW:SetSubCategory(FW.NIL,FW.NIL,1);
			FW:RegisterOption(FW.INF,2,FW.NON,FWL.SELF_MESSAGES_HINT1);
		
		FW:SetSubCategory(FWL.BLOOD_PACT,FW.ICON.BASIC,2)
			FW:RegisterOption(FW.MSG,1,FW.NON,FWL.BLOOD_PACT_ON,	FWL.BLOOD_PACT_TT,	"BloodPact");
			FW:RegisterOption(FW.COL,1,FW.NON,FWL.BLOOD_PACT_GAIN,		"",		"BloodpactGain");
			FW:RegisterOption(FW.COL,1,FW.NON,FWL.BLOOD_PACT_LOSS,		"",		"BloodpactLoss");
			
	FW:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT");
		FW:SetSubCategory(FWL.CASTING,FW.ICON.DEFAULT,2);
			FW:RegisterOption(FW.NUM,1,FW.NON,FWL.DELAY_PET_TARGET		,"",	"PetTargetDelay",nil,0.1,1);
	
	FW.Default.PetTargetDelay = 0.5; -- delay between pet cast start and target check
	

	--FW.Default.SummonStartWhisper = false;	FW.Default.SummonStartWhisperMsg = ">> You are being Summoned! <<";
	--FW.Default.SummonCancelWhisper = false;	FW.Default.SummonCancelWhisperMsg = "<< Your Summon was Cancelled >>";
	--FW.Default.SummonFailedWhisper = false;	FW.Default.SummonFailedWhisperMsg = "<< Your Summon Failed >>";

	FW.Default.SoulstoneSuccessWhisper = true;	FW.Default.SoulstoneSuccessWhisperMsg = ">> You are now soulstoned! <<";
	FW.Default.SoulstoneStartWhisper = false;	FW.Default.SoulstoneStartWhisperMsg = ">> Soulstoning you now <<";
	FW.Default.SoulstoneCancelWhisper = false;	FW.Default.SoulstoneCancelWhisperMsg = "<< Soulstoning cancelled >>";

	FW.Default.SummonFinish = 1;		FW.Default.SummonFinishMsg = ">> Opening Summoning Portal << Clicky clicky!"
	FW.Default.SoulstoneSuccess = 0;	FW.Default.SoulstoneSuccessMsg = "Soulstoned >> %s << Use it well!";
	FW.Default.SoulstoneStart = 1;		FW.Default.SoulstoneStartMsg = "Soulstoning >> %s << Now";
	FW.Default.SoulstoneCancel = 1;		FW.Default.SoulstoneCancelMsg = "Soulstoning >> %s << Cancelled";

	FW.Default.SeduceSuccess = 0;		FW.Default.SeduceSuccessMsg = "Seduced >> %s << Don't hit it!";
	FW.Default.SeduceStart = 0;			FW.Default.SeduceStartMsg = "Seducing >> %s << Now";
	FW.Default.SeduceFailed = 0;		FW.Default.SeduceFailedMsg = ">> Seduction Failed! <<";
	FW.Default.SeduceBreak = 1;			FW.Default.SeduceBreakMsg = ">> Seduction on %s Broke Early! <<";
	FW.Default.SeduceFade = 1;			FW.Default.SeduceFadeMsg = ">> Seduction on %s Fading in 3 seconds! <<";
	
	FW.Default.DevourMagicSuccess = 0;	FW.Default.DevourMagicSuccessMsg = ">> Devour Magic Used <<";
	FW.Default.DevourMagicFailed = 0;	FW.Default.DevourMagicFailedMsg = ">> Devour Magic Failed! <<";
	FW.Default.DevourMagicReady = 0;	FW.Default.DevourMagicReadyMsg = ">> Devour Magic ready <<";

	FW.Default.SpellLockSuccess = 0;	FW.Default.SpellLockSuccessMsg = ">> Spell Lock Used <<";
	FW.Default.SpellLockFailed = 0;		FW.Default.SpellLockFailedMsg = ">> Spell Lock Failed! <<";
	FW.Default.SpellLockReady = 0;		FW.Default.SpellLockReadyMsg = ">> Spell Lock ready <<";
	
	FW.Default.SoulwellStart = 0;		FW.Default.SoulwellStartMsg = "Summoning >> Soulwell << Yummie!";
	FW.Default.RitualOfDoomStart = 0;	FW.Default.RitualOfDoomStartMsg = "Want to end it all? Clicky clicky!";
	
	FW.Default.FearBreak = 0;		FW.Default.FearBreakMsg = ">> Fear on %s Broke Early! <<";
	FW.Default.FearFade = 0;		FW.Default.FearFadeMsg = ">> Fear on %s Fading in 3 seconds! <<";
	FW.Default.BanishBreak = 1;		FW.Default.BanishBreakMsg = ">> Banish on %s Broke Early! <<";
	FW.Default.BanishFade = 1;		FW.Default.BanishFadeMsg = ">> Banish on %s Fading in 3 seconds! <<";
	FW.Default.EnslaveBreak = 1;	FW.Default.EnslaveBreakMsg = ">> Enslave on %s Broke Early! <<";
	FW.Default.EnslaveFade = 1;		FW.Default.EnslaveFadeMsg = ">> Enslave on %s Fading in 3 seconds! <<";

	FW.Default.BloodPact = false;		FW.Default.BloodPactMsg = "warrior self";
	FW.Default.BloodpactGainColor = {1.00,0.40,0.00};
	FW.Default.BloodpactLossColor = {1.00,0.00,0.00};
	
	if CD then
		FW.Default.Cooldown.Filter[FW:SpellName(48020)] = 		{nil,nil,{-2,0.00,0.67,0.00}}; -- Demonic Circle: Teleport
		FW.Default.Cooldown.Filter[FW:SpellName(47541)] = 		{nil,nil,{-2,0.00,0.63,0.05}};--death coil
		FW.Default.Cooldown.Filter[FW:SpellName(6229)] = 		{nil,nil,{-2,0.63,0.00,1.00}};--shadow ward
		FW.Default.Cooldown.Filter[FW:SpellName(91713)] = 		{nil,nil,{-2,0.63,0.00,1.00}};--nether ward
		FW.Default.Cooldown.Filter[FW:SpellName(29893)] = 		{nil,nil,{-2,0.64,0.21,0.93}};--ritual of souls
		FW.Default.Cooldown.Filter[FW:SpellName(29858)] = 		{nil,nil,{-2,0.00,0.38,1.00}};--soulshatter
		FW.Default.Cooldown.Filter[FW:SpellName(34935)] = 		{nil,nil,{-1}};--backlash
	end
end
