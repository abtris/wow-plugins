-- ForteXorcist v1.974.5 by Xus 14-02-2011 for 4.0.6

local FW = FW;
local FWL = FW.L;
local ST = FW:Module("Timer");
local CA = FW.Modules.Casting;
local CD = FW.Modules.Cooldown;

local PARTY = FW.PARTY;
local RAID = FW.RAID;
local GetTime = GetTime;
local strfind = strfind;
local gsub = string.gsub;
local strsub = strsub;
local UnitBuff = FW.UnitBuff;
local UnitDebuff = FW.UnitDebuff;
local UnitName = FW.FullUnitName;
local erase = FW.ERASE;
local pairs = pairs;
local ipairs = ipairs;
local unpack = unpack;
local _G = _G;
local math = math;
local abs = math.abs;
local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local max = math.max;
local pow = math.pow;
local instances = FW:NEW2D();

local FILTER_ALL = 1;

local maxlag = 1.00; -- lower is better, but once you get over this with your actual lag weird things may happen

local IGNORE = -1;
local NORMAL = 0;
local FADING_INSTANT = 1;
local FADING = 2;
local REMOVE = 3;
local FAILED = 4;

local FILTER_ALWAYS = FW.FILTER_ALWAYS;
local FILTER_SHOW = FW.FILTER_SHOW;
local FILTER_NONE = FW.FILTER_NONE;
local FILTER_HIDE = FW.FILTER_HIDE;
local FILTER_COLOR = FW.FILTER_COLOR;
local FILTER_SHOW_COLOR = FW.FILTER_SHOW_COLOR;

local PRIOR_NONE = 0;
local PRIOR_COOLDOWN = -1;
local PRIOR_DEBUFF = -2;
local PRIOR_SELF_DEBUFF = -3;
local PRIOR_POWERUP = -4;

ST.PRIOR_NONE = PRIOR_NONE;
ST.PRIOR_COOLDOWN = PRIOR_COOLDOWN;
ST.PRIOR_DEBUFF = PRIOR_DEBUFF;
ST.PRIOR_SELF_DEBUFF = PRIOR_SELF_DEBUFF;
ST.PRIOR_POWERUP = PRIOR_POWERUP;

local FADE_SHOW = {FWL.SHORT_HIDE,FWL.SHORT_FADE,FWL.SHORT_REMOVED,FWL.SHORT_RESISTED,FWL.SHORT_IMMUNE,FWL.SHORT_EVADED,FWL.SHORT_REFLECTED};
local MAX_DEBUFFS = 40;
local feign = FW:SpellName(57626);

local ActiveDots = FW:NEW2D();
local ST_OnTimerFade = {};
local ST_OnTimerBreak = {};
local ST_OnBuffGain = {};

local BuffDelay = 4.0; -- absolute maximum time before checking if a buff/debuff is still present after a cast
-- TO DO : ADD A FLAG FOR INSTANT OR TRAVEL TIME SPELLS TO IMPROVE TIMER!
-- TO DO : ACTUALLY ADD A 'WAITING' STATE TO TRAVEL TIME SPELLS IN WHICH THE TIMER STILL LISTENS FOR RESISTS

local st = FW:NEW2D();

local function addLinks(index)
	for i=1,instances.rows,1 do
		instances[i][2]:addLink(index);
	end
end
local function removeLinks(index)
	for i=1,instances.rows,1 do
		instances[i][2]:removeLink(index);
	end
end
local function eraseLinks()
	for i=1,instances.rows,1 do
		instances[i][2]:eraseLinks();
	end
end

local function rebuildLinks()
	for i=1,instances.rows,1 do
		instances[i][2]:rebuildLinks();
	end
end

local function setValueLinks(index,col,val)
	for i=1,instances.rows,1 do
		instances[i][2]:setValueLinks(index,col,val);
	end
end

local orig_insert = st.insert;
st.insert = function(self,...)
	orig_insert(self,...);
	addLinks(self.rows);
	--FXT();
end
local orig_remove = st.remove;
st.remove = function(self,index)
	orig_remove(self,index);
	if index then
		removeLinks(index);
	end
	--FXT();
end
local orig_erase = st.erase;
st.erase = function(self)
	orig_erase(self);
	eraseLinks();
	--FXT();
end

--[[function FXT()
	FW:Show("TIMERS");
	st:print();
	for i=1,instances.rows,1 do
		FW:Show("INSTANCE "..i);
		instances[i][2]:printLinks();
	end
end]]

local SpellAdd = {};
local Track = {};
local TrackBuffs = {};
local NonStacking = {};
local TrackSelfDebuffs = {};
local TrackDebuffs = {};
local TrackCooldowns = {};
local Tick = {}
local Hasted = {};
local Drain = {};
local SpellRename = {};

ST.ST = st; -- to access it from modules
ST.Track = Track;
ST.Tick = Tick;
ST.Hasted = Hasted;
ST.Drain = Drain;
ST.SpellRename = SpellRename;

local maxi = 100;
local sortSwapTable = {};
local function UpdateSortOrder(powerup,selfdebuff,debuff,cooldown,none)
	-- create a table for easier swapping
	sortSwapTable[PRIOR_NONE] = none;
	sortSwapTable[PRIOR_COOLDOWN] = cooldown;
	sortSwapTable[PRIOR_DEBUFF] = debuff;
	sortSwapTable[PRIOR_SELF_DEBUFF] = selfdebuff;
	sortSwapTable[PRIOR_POWERUP] = powerup;
	
	-- swap the priorities
	for i=1,st.rows,1 do
		if st[i][13] <= 0 or st[i][13] >= maxi then
			st[i][13] = sortSwapTable[ st[i][13] ];
		end
	end

	-- keep track of the current settings
	PRIOR_NONE = none;
	PRIOR_COOLDOWN = cooldown;
	PRIOR_DEBUFF = debuff;
	PRIOR_SELF_DEBUFF = selfdebuff;
	PRIOR_POWERUP = powerup;
	
	ST.PRIOR_NONE = PRIOR_NONE;
	ST.PRIOR_COOLDOWN = PRIOR_COOLDOWN;
	ST.PRIOR_DEBUFF = PRIOR_DEBUFF;
	ST.PRIOR_SELF_DEBUFF = PRIOR_SELF_DEBUFF;
	ST.PRIOR_POWERUP = PRIOR_POWERUP;
end

local str = {};
local ord = {};

local function ST_CreateSortOrder()
	-- "buff,selfdebuff,debuff,cooldown,notarget,target";

	str[1],str[2],str[3],str[4],str[5],str[6] = strsplit(" ",FW.Settings.TimerSortOrder);
	for i=1,6 do
		if not str[i] then
			FW.Settings.TimerSortOrder = FW.Default.TimerSortOrder;
			FW:RefreshOptions();
			ST_CreateSortOrder();
			return;
		end
	end
	local offset = -5; -- this is the default offset for 5 flags
	for i=1,6 do
		if str[i] == "target" then -- if target is seen make sure the next ones are always higher
			offset = maxi;
		else
			ord[ str[i] ] = offset + i;
		end
	end
	UpdateSortOrder(ord["buff"],ord["selfdebuff"],ord["debuff"],ord["cooldown"],ord["notarget"]);
end

--local combat_log_active = false; -- patch 3.1.3 has some combat log issues

--local pauzed;
--local pauzedq = {};

-- http://www.wowwiki.com/Diminishing_returns
-- i'll use the combat log to track this completely seperately
-- and simply look inside this new tracking table to see if my spell
-- will be affected
-- (preferably warn when immune even before you cast)
-- I will add an extra type bar to show returns as well, so you know
-- when your spell will have the full duration again


-- http://www.wowwiki.com/Debuff#List_of_shared_.28non-stacking.29_debuffs

--FW.STACK_CRIT = 1;
--[[
Critical strike chance increase (general)

    * Paladin Heart of the Crusader: Tier 2 Retribution talent, 2 ranks, causes judgements to increase critical strike chance against the target by 3% at max rank.
    * Shaman Totem of Wrath: Tier 9 Elemental talent ability, 3% to attacks and offensive spells, each shaman can only have one active Fire Totem at a time. 
]]
--FW.STACK_CRIT_MAGIC = 2;
--[[
Critical strike chance increase (spell)

    * Mage Enduring Winter: Tier 6 frost talent, 3 ranks, gives frost talent spells a 100% chance to apply the Winter's Chill debuff @ max rank, increasing spell critical strike chance by 1% per stack, stacks up to 5 times.
    * Mage Improved Scorch: Tier 4 fire talent, 3 ranks, gives Scorch a 100% chance to apply the Improved Scorch debuff (or applications of the Improved Scorch debuff if glyphed) @ max rank, increasing spell critical strike chance by 1% per stack, stacks up to 5 times.
    * Warlock Improved Shadow Bolt: Tier 1 Destruction talent, 5 ranks, causes Shadow Bolt to increase spell critical strike damage against the target by 5% @ max rank. 
]]
--FW.STACK_DAMAGE_BLEED = 3;
--[[
Damage increase (bleed)

    * Druid Mangle (Bear) / Mangle (Cat): Tier 9 Feral Combat talent abilities, +30%.
    * Warrior Trauma: Tier 6 Arms talent, +30%, triggered by melee critical strikes. 
]]
--FW.STACK_DAMAGE_MAGIC = 4;
--[[
Damage increase (magic)

    * Death knight Ebon Plaguebringer: Tier 9 Unholy talent, 3 ranks, requires 3 ranks of Crypt Fever. The death knight's diseases cause Ebon Plague instead of Crypt Fever, in addition to Crypt Fever's disease damage increase, Ebon Plague increases magic damage by 13% @ max rank.
    * Druid Earth and Moon: Tier 10 Balance talent, 3 ranks. Causes the druid's Starfire and Wrath spells to apply the Earth and Moon debuff, which increases magic damage taken by 13% @ max rank.
    * Warlock Curse of the Elements: +13% @ max rank, also reduces Arcane, Fire, Frost, Nature and Shadow resistance. 
]]
--FW.STACK_DAMAGE_PHYSICAL = 5;
--[[
Damage increase (physical)

    * Rogue Savage Combat: Tier 9 Combat talent, 2 ranks, causes the rogue's poison debuffs to increase physical damage caused to the target by 4%.
    * Warrior Blood Freny: Tier 9 Arms talent, 2 ranks, causes Deep Wounds and Rend to increase phyical damage caused to the target by 4%. 
]]
--FW.STACK_HEALING_DECREASE = 6;
--[[
Healing decrease

    * Hunter Aimed Shot: Tier 3 Marksmanship talent ability, -50%.
    * Rogue Wound Poison: -50%, each weapon can only have one poison applied to it at a time.
    * Warrior Furious Attacks: Tier 8 Fury talent, 2 ranks, gives whit melee attacks a chance to reduce healing by 25%, stacks 2 times, higher proc rate @ rank 2.
    * Warrior Mortal Strike: Tier 7 Arms talent ability, -50%. 
]]
--FW.STACK_HIT_DECREASE = 7;
--[[
Hit chance decrease (melee and ranged)

    * Druid Insect Swarm: Tier 5 Balance talent ability, -3%.
    * Hunter Scorpid Sting: -3%, each hunter can only have one sting active on each target. 
]]
--FW.STACK_HIT_INCREASE = 8;
--[[
Hit chance increase (spell)

    * Druid Improved Faerie Fire: Tier 7 Balance talent, 3 ranks, causes Faerie Fire to increase spell hit chance against the target by 3% @ max rank.
    * Priest Misery: Tier 8 Shadow talent, 3 ranks, causes Mind Flay, Shadow Word: Pain and Vampiric Touch spells to increase spell hit chance against the target by 3% @ max rank. 
]]

--[[Armor reduction

    * Minor (stacks with major)
    * Druid Faerie Fire / Faerie Fire (Feral): -5%, also prevents stealth.
    * Hunter Sting: Wasp ability, -5%, also prevents stealth.
    * Rogue Expose Armor: -20%.
    * Warlock Curse of Weakness: -5%, also reduces melee attack power, each warlock can only have one active curse per target.
    * Major (stacks with minor)
          o Hunter Acid Spit: Worm (Exotic Hunter pet) ability, -10%, stacks twice.
          o Rogue Expose Armor: -4% per application, stacks up to 5 times.
          o Warrior Sunder Armor: -4% per application, stacks up to 5 times. 
    * Unknown
          o Warrior Shattering Throw: -20%, known to stack with Sunder Armor, unsustainable. 

Attack interval increase (melee)

    * Death knight Frost Fever: Caused by Icy Touch, Hungering Cold, glyphed Howling Blast and glyphed Scourge Strike. Increases casting time and melee and ranged attack intervals by 14% (20% fully talented with Improved Icy Touch, a tier 1 Frost talent with 3 ranks).
    * Druid Infected Wounds: Tier 8 Feral Combat talent, 3 ranks, causes Mangle, Maul and Shred to apply the Infected Wound debuff, which stacks 2 times, and increases melee attack interval by 10% per application @ max rank, also reduces movement speed.
    * Mage Slow (mage): Tier 7 Arcane talent ability, increases melee and ranged attack intervals by 60%, also increases casting time, each mage can only have one Slow spell active at a time.
    * Paladin Judgements of the Just: Tier 9 Protection talent, 2 ranks, causes Judgements to increase melee attack intervals 20% @ max rank.
    * Warrior Thunder Clap: Reduces melee and ranged attack intervals by 10%. 

Attack interval increase (ranged)

    * Death knight Frost Fever: Caused by Icy Touch, Hungering Cold, glyphed Howling Blast and glyphed Scourge Strike. Increases casting time and melee and ranged attack intervals by 14% (20% fully talented with Improved Icy Touch, a tier 1 Frost talent with 3 ranks).
    * Mage Slow (mage): Tier 7 Arcane talent ability, increases melee and ranged attack intervals by 60%, also increases casting time.
    * Warrior Thunder Clap: Increases melee and ranged attack intervals by 10%. 

Attack power reduction (melee)

    * Druid Demoralizing Roar: -408 @ max rank (~571.2 fully talented with Feral Aggression, a tier 1 Feral Combat talent with 5 ranks), Bear Form and Dire Bear form only.
    * Hunter Demoralizing Screech: Carrion Bird ability, -210 @ max rank.
    * Warlock Curse of Weakness: -478 @ max rank (573 fully talented w/ Improved Curse of Weakness, a tier 2 Affliction talent with 2 ranks), also reduces armor.
    * Warrior Demoralizing Shout: -410 @ max rank (-574 fully talented with Improved Demoralizing Shout, a tier 2 Fury talent with 5 ranks). 

Casting time increase

    * Death knight Frost Fever: Caused by Icy Touch, Hungering Cold, glyphed Howling Blast and glyphed Scourge Strike. Increases casting, melee and ranged speed by 14% (20% fully talented with Improved Icy Touch, a tier 1 Frost talent with 3 ranks).
    * Mage Slow (mage): Tier 7 Arcane talent ability, +30%, also increases attack intervals, each mage can only have one Slow spell active at a time.
    * Rogue Mind-Numbing Poison: +30%, each weapon can only have one poison applied to it at a time.
    * Warlock Curse of Tongues: +30% @ max rank, each warlock can only have one active curse per target. 
]]

--[[local ST_Diminish = {
	-- name	PVP PVE category
	--Druid
	["Bash"] =  			{1,0,"Stun"},
	["Entangling Roots"] =  {1,0,"Root"},
	["Hibernate"] =  		{1,0,"Sleep"},
	["Cyclone"] =  			{1,1,"Blind/Cyclone"},
	["Celestial Focus"] =  	{1,1,"Stun Proc "},
	--Hunter  
	--Freezing Trap  No  No  None  
	--Entrapment  Yes  TBD  None  
	--Wyvern Sting  TBD  TBD  Sleep
	--Mage
	["Frost Nova"] = 		{1,0,"Root"},
	["Polymorph"] = 		{1,0,"Gouge/Polymorph/Sap"},
	["Impact"] = 			{1,1,"Stun"},
	["Frostbite"] = 		{1,0,"Root Proc"},
	--Shaman  
	--Frost Shock  No (in 2.3)  No  None 
	["Stoneclaw Totem"] = 	{1,1,"Stun Proc"},
	--Earth Shock  No  No  None  
	--Paladin
	["Hammer of Justice"] = {1,1,"Stun"},
	["Seal of Justice"] = 	{1,1,"Stun Proc"},
	--Priest
	["Psychic Scream"] = 	{1,0,"Fear"},
	["Mind Control"] = 		{1,0,"Charm"},
	["Blackout"] = 			{1,1,"Stun Proc"},
	--Rogue
	["Sap"] = 				{1,0,"Gouge/Polymorph/Sap"},
	["Gouge"] = 			{1,0,"Gouge/Polymorph/Sap"},
	["Blind"] = 			{1,1,"Blind/Cyclone"},
	["Cheap Shot"] = 		{1,1,"Stun"},
	["Kidney Shot"] = 		{1,1,"Kidney Shot"},
	["Mace Specialization"] = {1,1,"Stun Proc"},
	--Warlock 
	["Fear"] = 				{1,0,"Fear"},
	["Seduction"] = 		{1,0,"Fear"},
	["Howl of Terror"] = 	{1,0,"Fear"},
	["Death Coil"] = 		{1,0,"Horror"},
	["Shadowfury"] = 		{1,0,"Stun"},
	--Warrior
	["Mace Specialization (Stun)"] = {1,1,"Stun Proc"},
	["Charge"] = 			{1,1,"Stun"},
	["Intercept"] = 		{1,1,"Stun"},
	["Concussion"] = 		{1,1,"Stun"},
	--Hamstring  No  No  None  
};]]

local FW_RaidIconCoords  = {
	{0.00,0.25,0.00,0.25},
	{0.25,0.50,0.00,0.25},
	{0.50,0.75,0.00,0.25},
	{0.75,1.00,0.00,0.25},
	{0.00,0.25,0.25,0.50},
	{0.25,0.50,0.25,0.50},
	{0.50,0.75,0.25,0.50},
	{0.75,1.00,0.25,0.50}
};

--[[
st

1:Expiring at time
2:Cast Time
3:Duration of Spell
4:Target
5:Is Dot
6:Is Magic/Curse/Crowd Control etc
7:Texture
8:Name
9:Target Type (0:trash 1:boss 2:player)
10:ready to check for removal
11:GUID
12:Expire msg given
13:Unique ID (still using this to sort by, see flags)
14:Timer state 0:normal 1:expired instant 2:expired 3:removed 4+:failed
15:USED AS SPECIAL FLAG (HUNTER: TRAP NEEDS TRIGGERING)
16:Stacks or similar
17:Remove time
18:NOT USED (WAS Filter)
19:Raid target icon
20:Expire Time I'm using (#1 is always the real time)
21:NOT USED (WAS Currently used maximum time (#3 is always the real max time))
22:Haste duration factor (so lower than or equal to 1 usually)
23:NOT USED (WAS haste correction)

links
1:index at st
 -- copied from st to sort by only:
2: st13 Unique ID
3: st20 Expire Time I'm using
 -- instance specific values
4: Visibility in this instance
5: Filter
6: Currently used maximum time
7: Time at which 'hide long' was enabled
]]

local SORT_TIMER_ORDER=		{3};
local SORT_TIMER_ASC=		{true};	
local SORT_TIMER_ORDER2=	{2,3};
local SORT_TIMER_ASC2=		{true,true};

-- spell timer flags
local DEFAULT = 1;
local SHARED = 2;
local SHARED2 = 3;
local SHARED3 = 4;
local UNIQUE = 5;
-- above are scanned by standard as debuff
local PET = 6;
local POWERUP = 7;
local SELF_DEBUFF = 8;
local CHARM = 9;
local COOLDOWN = 10;
local DEBUFF = 11;
local DRAIN = 12;
-- below are scanned by standard as buff
local HEAL = 13;
local BUFF = 14;

ST.DEFAULT = DEFAULT;
ST.SHARED = SHARED;
ST.SHARED2 = SHARED2;
ST.SHARED3 = SHARED3;
ST.UNIQUE = UNIQUE;
ST.PET = PET;
ST.POWERUP = POWERUP;
ST.SELF_DEBUFF = SELF_DEBUFF;
ST.CHARM = CHARM;
ST.COOLDOWN = COOLDOWN;
ST.DEBUFF = DEBUFF;
ST.DRAIN = DRAIN;
ST.HEAL = HEAL;
ST.BUFF = BUFF;

ST.LAST_TIMER_FLAG = BUFF;

local types = {
	[DEFAULT] = "MagicEnable",
	[SHARED] = "CurseEnable",
	[SHARED2] = "Shared2Enable",
	[SHARED3] = "Shared3Enable",
	[UNIQUE] = "CrowdEnable",
	[PET] = "PetEnable",
	[POWERUP] = "BuffEnable",
	[SELF_DEBUFF] = "SelfDebuffEnable",
	[CHARM] = "CrowdEnable",
	[COOLDOWN] = "CooldownsEnable",
	[DEBUFF] = "DebuffsEnable",
	[DRAIN] = "DrainEnable",
	[HEAL] = "HealEnable",
	[BUFF] = "FriendlyBuffEnable",
};

--1:all 2:other debuffs 3:all other
local function FlagToFilterIndex(flag)
	if flag == DEBUFF or flag == POWERUP then
		return 2;
	elseif flag == COOLDOWN then
		return 4;
	elseif flag == SELF_DEBUFF then
		return 5;
	else -- all other
		return 3;
	end
end

local function addedByDefault(spell,flag)
	if flag > ST.LAST_TIMER_FLAG then
		return 1;
	elseif flag == DEBUFF then
		return TrackDebuffs[spell];
	elseif flag == POWERUP then
		return TrackBuffs[spell];
	elseif flag == COOLDOWN then
		return TrackCooldowns[spell];
	elseif flag == SELF_DEBUFF then
		return TrackSelfDebuffs[spell];
	elseif flag == DRAIN then
		return Drain[spell];
	else -- all other
		return Track[spell];
	end
end

local function FlagToFilter(frame,spell,flag)
	if frame.s.Filter[spell] then
		if flag == DEBUFF or flag == POWERUP then
			if frame.s.Filter[spell][2] and frame.s.Filter[spell][2][1]~=0 then
				return frame.s.Filter[spell][2];
			end
		elseif flag == COOLDOWN then
			if frame.s.Filter[spell][4] and frame.s.Filter[spell][4][1]~=0 then
				return frame.s.Filter[spell][4];
			end
		elseif flag == SELF_DEBUFF then
			if frame.s.Filter[spell][5] and frame.s.Filter[spell][5][1]~=0 then
				return frame.s.Filter[spell][5];
			end
		else -- all other
			if frame.s.Filter[spell][3] and frame.s.Filter[spell][3][1]~=0 then
				return frame.s.Filter[spell][3];
			end
		end
		-- all
		if frame.s.Filter[spell][1] and frame.s.Filter[spell][1][1]~=0 then
			return frame.s.Filter[spell][1];
		end
	end
end

local function FlagToAction(frame,spell,flag,ignore_default)
	if frame then -- if no frame is specified this is meant to check if any non-default spells are added for show
		local filter = FlagToFilter(frame,spell,flag);
		if filter and filter[1] ~= FILTER_NONE then
			if filter[1] == FILTER_COLOR then
				if addedByDefault(spell,flag) and frame.s[ types[flag] ] then
					return FILTER_COLOR;
				else
					return FILTER_HIDE;
				end
			else
				return filter[1];
			end
		else
			if addedByDefault(spell,flag) and frame.s[ types[flag] ] then
				return FILTER_NONE;
			else
				return FILTER_HIDE;
			end
		end
	else
		-- if no frame is given, check for custom filters in all instances
		-- this gives the addon a list of only the spells that are possible to show up
		-- don't check if enabled for default spells because of sound queues etc!!
		for i=1,instances.rows do 
			local filter = FlagToFilter(instances[i][2],spell,flag);
			if ( not ignore_default and addedByDefault(spell,flag) ) or (filter and ( filter[1] == FILTER_SHOW or filter[1] == FILTER_SHOW_COLOR )) then
				return FILTER_SHOW;
			end
		end
		return FILTER_NONE;
	end
end

function ST:GetFilterType(spell,flag) -- NO LONGER USED
	return 0;
end

local isMine = {["player"]=true,["pet"]=true,["vehicle"]=true};

local ST_SpecialRefresh = {};
function ST:RegisterSpecialRefresh(spell)
	spell = FW:SpellName(spell);
	ST_SpecialRefresh[spell] = 1;
end

function ST:RegisterSpellRename(spell,newname)
	SpellRename[(FW:SpellName(spell))] = (FW:SpellName(newname));
end

function ST:RegisterSpellAdd(spell,extraspell)
	spell = FW:SpellName(spell);
	if not SpellAdd[spell] then SpellAdd[spell] = {};end
	tinsert(SpellAdd[spell], (FW:SpellName(extraspell)) );
end
local default_hasted = 1;
-- best would if it can 'replace' the shared/curse behaviour with something more flexible
function ST:RegisterDefaultHasted(hasted)
	default_hasted = hasted;
end

function ST:RegisterSpell(spell, hastarget, duration, isdot, istype, reducedinpvp, hasted, stacks)
	local s,t = FW:SpellName(spell);
	if isdot == 1 or istype == HEAL then
		Tick[s] = 3;
		if not hasted then
			hasted = default_hasted;
		end
	end
	Track[s]={hastarget,duration,isdot,istype,reducedinpvp or 0,t or "",stacks or 0,hasted or 0};
end

function ST:RegisterChannel(spell, hastarget, tickspeed)
	spell = FW:SpellName(spell);
	Drain[spell] = {hastarget,tickspeed};
end

function ST:RegisterTickSpeed(spell, tick)
	spell = FW:SpellName(spell);
	Tick[spell] = tick;
end

function ST:RegisterHastedGlyph(spell, requires_glyph)
	spell = FW:SpellName(spell);
	requires_glyph = FW:SpellName(requires_glyph);
	if not FW.Glyph[requires_glyph] then FW.Glyph[requires_glyph] = 0; end
	if not Track[spell]["hg"] then Track[spell]["hg"] = {};end
	Track[spell]["hg"][requires_glyph] = 1;
end

function ST:RegisterHastedStance(spell, requires_stace)
	spell = FW:SpellName(spell);
	if not Track[spell]["hs"] then Track[spell]["hs"] = {};end
	if not Track[spell]["hs"][requires_stace] then Track[spell]["hs"][requires_stace] = 1;end
end

function ST:RegisterSpellModSetB(spell,setb,rank,modi)
	spell = FW:SpellName(spell);
	if not FW.SetBonus[setb] then FW.SetBonus[setb] = 0; end
	if not Track[spell]["s"] then Track[spell]["s"] = {};end
	if not Track[spell]["s"][setb] then Track[spell]["s"][setb] = {};end
	Track[spell]["s"][setb][rank] = modi;
end

function ST:RegisterSpellModTlnt(spell,tal,rank,modi) -- modi can now be a string for percentage based modifiers e.g. "150%" for adding 50%
	spell = FW:SpellName(spell);
	tal = FW:SpellName(tal);
	if not FW.Talent[tal] then FW.Talent[tal] = 0; end
	
	if type(modi) == "string" then
		modi = select(3,strfind(modi,"([%.%d]+)%%"));
		if modi then
			modi = tonumber(modi);
			if modi then
				modi=modi/100;
				if not Track[spell]["tp"] then Track[spell]["tp"] = {};end
				if not Track[spell]["tp"][tal] then Track[spell]["tp"][tal] = {};end
				Track[spell]["tp"][tal][rank] = modi;
			end
		end
	else
		if not Track[spell]["t"] then Track[spell]["t"] = {};end
		if not Track[spell]["t"][tal] then Track[spell]["t"][tal] = {};end
		Track[spell]["t"][tal][rank] = modi;
	end
end

function ST:RegisterSpellModGlph(spell,gl,modi)
	spell = FW:SpellName(spell);
	gl = FW:SpellName(gl);
	if not FW.Glyph[gl] then FW.Glyph[gl] = 0; end
	if not Track[spell]["g"] then Track[spell]["g"] = {};end
	Track[spell]["g"][gl] = modi;
end

function ST:RegisterSpellModComb(spell,points,modi)
	spell = FW:SpellName(spell);
	if not Track[spell]["c"] then Track[spell]["c"] = {};end
	Track[spell]["c"][points] = modi;
end

function ST:RegisterBuff(buff,nonstacking)
	buff = FW:SpellName(buff);
	TrackBuffs[buff] = 1;
	NonStacking[buff] = nonstacking;
end

function ST:RegisterSelfDebuff(debuff)
	debuff = FW:SpellName(debuff);
	TrackSelfDebuffs[debuff] = 1;
end

function ST:RegisterCooldown(spell,duration)
	local s,t = FW:SpellName(spell);
	TrackCooldowns[s] = {duration,t};
end

function ST:RegisterCooldownModSetB(spell,setb,rank,modi)
	spell = FW:SpellName(spell);
	if not FW.SetBonus[setb] then FW.SetBonus[setb] = 0; end
	if not TrackCooldowns[spell]["s"] then TrackCooldowns[spell]["s"] = {};end
	if not TrackCooldowns[spell]["s"][setb] then TrackCooldowns[spell]["s"][setb] = {};end
	TrackCooldowns[spell]["s"][setb][rank] = modi;
end

function ST:RegisterCooldownModTlnt(spell,tal,rank,modi) -- modi can now be a string for percentage based modifiers e.g. "150%" for adding 50%
	spell = FW:SpellName(spell);
	tal = FW:SpellName(tal);
	if not FW.Talent[tal] then FW.Talent[tal] = 0; end
	
	if type(modi) == "string" then
		modi = select(3,strfind(modi,"([%.%d]+)%%"));
		if modi then
			modi = tonumber(modi);
			if modi then
				modi=modi/100;
				if not TrackCooldowns[spell]["tp"] then TrackCooldowns[spell]["tp"] = {};end
				if not TrackCooldowns[spell]["tp"][tal] then TrackCooldowns[spell]["tp"][tal] = {};end
				TrackCooldowns[spell]["tp"][tal][rank] = modi;
			end
		end
	else
		if not TrackCooldowns[spell]["t"] then TrackCooldowns[spell]["t"] = {};end
		if not TrackCooldowns[spell]["t"][tal] then TrackCooldowns[spell]["t"][tal] = {};end
		TrackCooldowns[spell]["t"][tal][rank] = modi;
	end
end

function ST:RegisterCooldownModGlph(spell,gl,modi)
	spell = FW:SpellName(spell);
	gl = FW:SpellName(gl);
	if not FW.Glyph[gl] then FW.Glyph[gl] = 0; end
	if not TrackCooldowns[spell]["g"] then TrackCooldowns[spell]["g"] = {};end
	TrackCooldowns[spell]["g"][gl] = modi;
end

local function ST_CooldownDuration(s)
	local dura = 0;
	-- duration adjustments
	if TrackCooldowns[s] then
		dura = TrackCooldowns[s][1];
		-- change based on talents
		if TrackCooldowns[s]["t"] then
			for k, v in pairs(TrackCooldowns[s]["t"]) do
				if v[FW.Talent[k]] then
					dura = dura + v[FW.Talent[k]];
				end
			end
		end
		-- change based on setbonus
		if TrackCooldowns[s]["s"] then
			for k, v in pairs(TrackCooldowns[s]["s"]) do
				for n, a in pairs(v) do
					if FW.SetBonus[k] >= n then
						dura = dura + a;
					end
				end
			end
		end
		-- change based on glyphs
		if TrackCooldowns[s]["g"] then
			for k, v in pairs(TrackCooldowns[s]["g"]) do
				if FW.Glyph[k] and FW.Glyph[k] > 0 then
					dura = dura + v;
				end
			end
		end
	
		-- % change based on talents
		if TrackCooldowns[s]["tp"] then
			for k, v in pairs(TrackCooldowns[s]["tp"]) do
				if v[FW.Talent[k]] then
					dura = dura * v[FW.Talent[k]];
				end
			end
		end
	end
	return dura;
end


local function ST_AddNewCooldown(spell,dura,prior,texture)
	-- I use 'target type' to store the prior, triggered by cd module is higher prior
	local index = st:find2(COOLDOWN,6,spell,8);
	--if prior == 2 then FW:Show("cd");else FW:Show("st");end
	if not index or prior >= st[index][9] then
		st:remove(index);
		st:insert(dura+GetTime(),FW:CastTime(spell),dura,spell,0,COOLDOWN,texture,spell,prior,0,"none",0,PRIOR_COOLDOWN,0,1,0,0,"filter",0,dura+GetTime(),dura,1.0,0);		
	end
end

local function ST_OnCooldownUsed(spell,dura,flag,texture)
	if flag < CD.FLAG_BUFF or flag > CD.FLAG_ENCHANT then
		if FlagToAction(nil,spell,COOLDOWN) == FILTER_SHOW then
			ST_AddNewCooldown(spell,dura,2,texture);
		end
	end
end

local function ST_OnCooldownUpdate(spell,dura,flag,texture,end_time)
	--FW:Show("update");
	if flag < CD.FLAG_BUFF or flag > CD.FLAG_ENCHANT then
		local index = st:find2(COOLDOWN,6,spell,8);
		if index then
			st[index][1] = end_time;
			st[index][7] = texture;
		else
			--ST_OnCooldownUsed(spell,dura,flag,texture); -- is a bit ineffient here, make sure to update code below!
			if FlagToAction(nil,spell,COOLDOWN) == FILTER_SHOW then
				st:insert(dura+GetTime(),FW:CastTime(spell),dura,spell,0,COOLDOWN,texture,spell,prior,0,"none",0,PRIOR_COOLDOWN,0,1,0,0,"filter",0,dura+GetTime(),dura,1.0,0);		
			end
		end
	end
end
local function ST_OnCooldownReady(spell,flag)
	if flag < CD.FLAG_BUFF or flag > CD.FLAG_ENCHANT then -- FLAG_BUFF = 9 FLAG_ENCHANT = 11
		local index = st:find2(COOLDOWN,6,spell,8);
		if index then
			st[index][1] = GetTime();
			st[index][20] = st[index][1];
		end
	end
end

local function ST_SelfSuccess(spell)
	if TrackCooldowns[spell] then
		ST_AddNewCooldown(spell,ST_CooldownDuration(spell),1,TrackCooldowns[spell][2]);
	end
end

-- rebuild the RegisterDebuff function to take a 'doesn't stack' ID and priority number (will multiply this with the number of stacks to determine what to show)
-- RegisterSpell spells should never get overwritten by this feature

function ST:RegisterDebuff(debuff,stackid,prior)
	debuff = FW:SpellName(debuff);
	if not TrackDebuffs[debuff] then TrackDebuffs[debuff] = {}; end
	TrackDebuffs[debuff][1] = stackid or 0;
	TrackDebuffs[debuff][2] = prior or 1;
end

local function ST_FindSimilar(spell,guid,typ)
	for i=1,st.rows,1 do -- return only if this isnt a resist
		if st[i][14] <= REMOVE then
			-- this change causes bugs in some rare cases (but it should be like this)
			-- having fear on target #1, switching to #2 and casting a new fear and
			-- switching back to #1 while casting, will 'do nothing'
			-- (debuff check will notice that the fear is gone though)
			-- and is never applied to target #2 properly
			-- Does this mean that it finds 'itself' somehow and thinks that it should keep this old debuff?
			--                                               --_\
			if (st[i][8] == spell and (typ == UNIQUE and st[i][6] == typ or st[i][11] == guid)) 
			or (typ >= SHARED and typ <= SHARED3 and st[i][6] == typ and st[i][11] == guid) then
				return i;
			end
		end
	end
end

local function ST_AddDot2(unit,spell)
	if FW.Settings.TimerImprove --[[and combat_log_active]] then
		--FW:Debug("adding dot "..spell.." to "..unit);
		local index = ActiveDots:find2(unit,1,spell,2);
		if index then
			ActiveDots[index][3] = GetTime()+(Tick[spell] or 3)+FW.Settings.DotTicksDelayNew;
		else
			ActiveDots:insert( unit,spell,GetTime()+(Tick[spell] or 3)+FW.Settings.DotTicksDelayNew);
		end
	end
end

local function ST_AddDot(unit,guid,spell)
	ST_AddDot2(unit,spell);
	if guid ~= ""  and guid ~= "none" then
		ST_AddDot2(guid,spell);
	end
end

function ST:AddNewTimerSimple(expire,total,targetname,spell,targettype,id,icon,guid,haste,texture,stacks,typ)--only use for non-(de)buff based adding
	local found = ST_FindSimilar(spell,guid,typ);
	if found then -- found a spell i may need to remove - if it's an exact match keep using it
		if st[found][8] == spell and st[found][11] == guid and abs(st[found][1]-expire)<maxlag then 
			st[found][1] = expire;
			if abs(st[found][20]-expire)>maxlag then
				st[found][3] = total;
				st[found][20] = expire;
				--st[found][21] = total;
			end
			return;
		else
			st:remove(found);
		end
	end
	st:insert(expire,FW:CastTime(spell),total,targetname,0,typ,texture,spell,targettype,0,guid,ST_GetFadeTime(spell),id,0,1,stacks,0,"filter",icon,expire,total,haste,0);
end

function ST:AddNewTimer(expire,total,targetname,spell,targettype,id,icon,guid,haste,realduration) --only use for non-(de)buff based adding
	if total > 0 --[[or expire==0]] then -- dont add if duration isnt greater than 0
		local found = ST_FindSimilar(spell,guid,Track[spell][4]);
		local stacks = 0;
		if found then -- found a spell i may need to remove - if it's an exact match keep using it
			if st[found][8] == spell and st[found][11] == guid and abs(st[found][1]-expire)<maxlag then 
				st[found][1] = expire;
				if abs(st[found][20]-expire)>maxlag then
					st[found][3] = total;
					st[found][20] = expire;
					--st[found][21] = total;
				end
				--FW:Debug("using already present");
			else
				if Track[spell][7] > 0 then
					stacks = st[found][16] + 1;
					if stacks > Track[spell][7] then
						 stacks = Track[spell][7];
					end
				end
				--FW:Debug("using new");
				local extratime = 0;
				if Tick[spell] and st[found][11] == guid then -- must have ticks and be on the same target
					local oldhaste = st[found][22];
					local remaining = st[found][1]-GetTime();
					if remaining > 0 then
						extratime = remaining%(oldhaste*Tick[spell]);
					end
					--FW:Show(extratime);
				end
				st:remove(found);
				st:insert(expire+extratime,FW:CastTime(spell),total,targetname,Track[spell][3],Track[spell][4],Track[spell][6],spell,targettype,0,guid,ST_GetFadeTime(spell),id,0,1,stacks,0,"filter",icon,expire,total,haste,0);
			end
		else
			if Track[spell][7] > 0 then
				stacks = 1;
			end
			--FW:Debug("not found, new");
			st:insert(expire,FW:CastTime(spell),total,targetname,Track[spell][3],Track[spell][4],Track[spell][6],spell,targettype,0,guid,ST_GetFadeTime(spell),id,0,1,stacks,0,"filter",icon,expire,total,haste,0);
		end
		if Track[spell][3] == 1 then
			ST_AddDot(targetname,guid,spell);
		end
	end	
end

local function ST_Exception(set)
	if UnitName("target") then
		FW.Saved.Exceptions[UnitName("target")] = set;
	end
end

local function ST_HideTicks()
	for i=1,instances.rows,1 do
		instances[i][2]:HideTicks();
	end
end

local function ST_TimerShow(instance)
	if instance then
		instance:Update();
	else
		for i=1,instances.rows,1 do
			instances[i][2]:Update();
		end
	end
end
local function ST_SpellFail(s,resist,target,typ,id,icon,guid,...)
	if FW.Settings.TimerResistsEnable then 
		FW:Show(_G.CombatLog_OnEvent(_G.Blizzard_CombatLog_Filters.filters[_G.Blizzard_CombatLog_Filters.currentFilter], ...),unpack(FW.Settings.TimerResistsColor));
	end
	FW:PlaySound("TimerResistSound");
	for i=1,st.rows,1 do -- remove any other resist of this spell that's still on the bar
		if st[i][8] == s and st[i][14] >= FAILED and st[i][11] == guid then
			st:remove(i);
			break;
		end
	end
	st:insert(GetTime(),0,1,target,Track[s][3],Track[s][4],Track[s][6],s,typ,0,guid,0,id,resist,1,0,GetTime(),"filter",icon,GetTime(),1,1.0,0);	
end

local function ST_TrackedSuccess(spell,target,realduration,rank,targettype,s,p,id,icon,guid,delay,haste_old)
	if Track[s][1] ~= 1 then -- spells without a target
		target = s;
		targettype = 0;
		id = PRIOR_NONE;
		icon = 0;
		guid = "none";
	end
	 -- add an extra debuff! this is still very basic in functionality but it's something
	if SpellAdd[spell] then
		for i,a in ipairs(SpellAdd[spell]) do
			local ha = CA:HasteFactor(a);
			local dura = CA:Duration(a,p,targettype)*ha;
			--
			ST:AddNewTimer(GetTime()+dura-delay,dura,target,a,targettype,id,icon,guid,ha,dura);
		end
	end
	local haste = CA:HasteFactor(spell);
	local newdura;
	--FW:Show(realduration);
	--
	if Tick[spell] then
		newdura = math.floor(realduration/(Tick[spell]*haste))*Tick[spell]*haste;
	else
		newdura = realduration*haste;
	end
	--FW:Show(newdura);
	ST:AddNewTimer(GetTime()+newdura-delay,newdura,target,s,targettype,id,icon,guid,haste,realduration);
end

function ST:Fade(i,t)
	if i then
		if st[i][14] == IGNORE then -- if ignored already, remove instantly
			st[i][1] = 0;
		elseif st[i][14] ~= t then
			st[i][17] = GetTime();
			st[i][14] = t;
		end
	end
end

local function ST_BreakMessages(unit,mark,spell)
	for i, f in ipairs(ST_OnTimerBreak) do
		if f(unit,mark,spell) then
			FW:PlaySound("TimerBreakSound");
		end
	end
end

local maxdelay, maxdelay_instant = 0, 0;
local function ST_CalculateMaxDelay() -- calc new max delays
	maxdelay_instant = FW.Settings.TimerFadeSpeed;
	maxdelay = 0;
	for i=1,instances.rows,1 do
		maxdelay = max(maxdelay,instances[i][2].s.FailTime);
		maxdelay = max(maxdelay,instances[i][2].s.FadeTime);
	end
	maxdelay = maxdelay + maxdelay_instant;
end

local function ST_UpdateSpellTimers()--preferably only remove timers in this function and not outside
	local t = GetTime();
	local smooth = FW.Settings.TimerSmooth;
	local i = 1;
	
	while i <= st.rows do
		local t6,t14 = st[i][6],st[i][14];
		local timeleft = st[i][1]-t;
		st[i][20] = st[i][20] + (st[i][1]-st[i][20])/smooth;

		-- fade messages if time <= X sec
		if st[i][12] > 0 and timeleft <= st[i][12] and t14<=NORMAL then -- marked as not expiring
			st[i][12] = 0;
			
			local unit,mark = st[i][4],st[i][19];
			if mark~=0 then unit=FW.RaidIcons[mark]..unit;end
			CA:CastShow(ST_OnTimerFade[ st[i][8] ],unit);
			FW:PlaySound("TimerFadeSound");
		end	

		if t14 == IGNORE then -- instantly remove ignored timers on expire
			if timeleft <= 0 then
				st:remove(i);
			else
				i=i+1;
			end
		elseif t14 == NORMAL then -- set to fade
			if timeleft <= 0 and st[i][3] > 0 then
				-- normal fade and instant fade
				ST:Fade(i, (t6 == DRAIN or t6 == DEBUFF or t6 == POWERUP or t6 == SELF_DEBUFF) and FADING_INSTANT or FADING);
			end		
			i=i+1;
		else -- keep expired timers alive for X sec max
			if st[i][17] + ((t6 == DRAIN or t6 == DEBUFF or t6 == POWERUP or t6 == SELF_DEBUFF) and maxdelay_instant or maxdelay) < t then
				st:remove(i);
			else
				i=i+1;
			end
		end
	end
end

local function ST_ClearMobTimers()
	--FW:Debug("clear timer");
	local i = 1;
	while i <= st.rows do
		if st[i][6] <= PET and st[i][9] < 2 then -- remove all non-player timers except charms
			st:remove(i);
		else
			i=i+1;
		end
	end
end

-- OLD:
-- do NOT make this add my own dots that may be missing, this would correct the tiny chance
-- of the timer missing a cast, but would also make the manual remove function unusable...

local function ST_ScanForMissing(unit,guid,func)
	-- add any spells that i'm tracking that are mine
	local i=1;
	while true do
		local spell,rank,texture,stacks,_,total,expire,caster = func(unit,i);
		if spell then
			if isMine[caster] then
				if Track[spell] and Track[spell][1] == 1 then
					local index = st:find2(spell,8,guid,11)
					if not index or st[index][14] >= FADING_INSTANT then -- don't add when i already have this added
						--FW:Debug("moo??");
						--FW:Show(rank);
						local h = CA:HasteFactor(spell);
						local d = CA:Duration(spell,GetComboPoints("player",unit),unit)*h;
						--FW:Debug("guess: "..d.." real:"..total);
						ST:AddNewTimer(expire,total,UnitName(unit),spell,CA:Unique(unit),CA:GiveID(guid),GetRaidTargetIndex(unit) or 0,guid,h,0);
					end
				elseif FlagToAction(nil,spell,DEFAULT,1) == FILTER_SHOW then
					ST:AddNewTimerSimple(expire,total,UnitName(unit),spell,CA:Unique(unit),CA:GiveID(guid),GetRaidTargetIndex(unit) or 0,guid,CA:HasteFactor(spell),texture,stacks,func==UnitDebuff and DEFAULT or func==UnitBuff and BUFF);
				end
			end
			i=i+1;
		else
			break;
		end
	end
end

--[[function FW:TE()
	for key, val in pairs(Track) do
		if val[1]==1 then
			if not (val[4]<=UNIQUE or val[4] >=HEAL) then
				FW:Show("target, but type"..val[4]..": "..key);
			end
		else
			if val[4]<=UNIQUE or val[4] >=HEAL then
				FW:Show("no target, but type"..val[4]..": "..key);
			end
		end
	end
end]]

--main tracking for spells cast by you (type6: 9+ = friendly buff)
local function ST_CorrectionScan(unit)
	--FW:Show("standard scan "..unit);
	local guid = UnitGUID(unit);
	if guid then -- this unit exists, which is always nice
		local t = GetTime();
		-- remove or correct timers already on the spelltimer
		local i=1;
		while i<=st.rows do -- spelltimer part
			local t8 = st[i][8];
			if st[i][14]<=NORMAL then
				if st[i][11] == "" then -- uncertain cast, attempt to correct
					local expire; -- can be unfriendly or friendly now!
					if st[i][6]<HEAL then
						expire = FW:UnitHasYourDebuff(unit,t8);
					else
						expire = FW:UnitHasYourBuff(unit,t8);
					end
					-- does this unit maybe have this debuff on my timer?
					if expire then
						if st[i][6] == DRAIN then -- drains are special cases, and never added by debuff/buff scans
							if abs( expire-st[i][1] )<maxlag then
								st[i][9] = CA:Unique(unit);
								st[i][11] = guid;
								st[i][13] = CA:GiveID(guid);
								st[i][19] = GetRaidTargetIndex(unit) or 0;
								rebuildLinks(); -- IMPORTANT
							end
						else
							if abs( expire-st[i][1] )<maxlag or Tick[t8] and ((expire > st[i][1] - maxlag) and (expire - Tick[t8]*st[i][22] - maxlag < st[i][1])) then --if it's found for correction, it will be added anyway, so can remove this now
								st:remove(i);
								i=i-1;
							end
						end
						--FW:Debug("correct uncertain");
					end	
					
				elseif st[i][11] == guid then
				
					local t6 = st[i][6];
					if t6<=UNIQUE or t6 >=HEAL or t6 == CHARM or (t6 == PET and Track[t8] and Track[t8][1]==1) then -- only check the 'normal' buff/debuff types
						local expire,index,stacks,total,rank; -- can be unfriendly or friendly now!
						if t6<HEAL then
							expire,index,stacks,total,rank = FW:UnitHasYourDebuff(unit,t8);
						else
							expire,index,stacks,total,rank = FW:UnitHasYourBuff(unit,t8);
						end
						st[i][19] = GetRaidTargetIndex(unit) or 0;
						
						if st[i][10] == 0 then -- makes early (de)buff removing faster and hopefully bug free
							if expire then -- no need to match for duration here because i already have a fixed id
								st[i][10] = 1;-- i have already seen this debuff
								if expire > st[i][1] or abs(st[i][1]-expire)<maxlag then st[i][1] = expire;st[i][16] = stacks or 0; end
								--st[i][1] = expire;
							elseif (st[i][3]-st[i][1]+t) >= BuffDelay then
								st[i][10] = 1;-- it should have been on already at this time
							end						
						end
						
						-- do the other 'normal' stuff
						if expire then
							local haste = CA:HasteFactor(t8);
							if ST_SpecialRefresh[t8] and st[i][22] ~= haste and expire-st[i][1] > maxlag then
								st[i][22] = haste;
							end
							st[i][1] = expire;
							st[i][16] = stacks or 0;
							st[i][3] = total;
							
						elseif --[[index<=MAX_DEBUFFS and]] st[i][10] == 1 and st[i][1]-t >maxlag then -- dont remove if only maxlag left
							if not UnitIsDead(unit) then
								ST_BreakMessages(st[i][4],st[i][19],t8);
							end
							ST:Fade(i,REMOVE);
							--FW:Debug("remove");
						end
					end
				end	
			end
			i=i+1;
		end
		ST_ScanForMissing(unit,guid,UnitDebuff);
		ST_ScanForMissing(unit,guid,UnitBuff);
	end
end

local function ST_TargetDebuffs()
	local i = 1;	
	-- remove any faded debuffs that i'm tracking
	while i<= st.rows do
		if st[i][14] <= NORMAL and st[i][6] == DEBUFF then
			local has,index = FW:UnitHasDebuff("target",st[i][8]);
			if not has --[[and index<=MAX_DEBUFFS]] then
				ST:Fade(i,FADING_INSTANT);
			end
		end
		i=i+1;
	end
	i = 1;
	local t = GetTime();
	-- scan my target for debuffs that i want to track (and may not be mine)
	while true do
		local debuff,_,texture,count,_,total,expire,caster = UnitDebuff("target",i);
		if debuff then
			if FlagToAction(nil,debuff,DEBUFF) == FILTER_SHOW then
				local guid = UnitGUID("target");
				local index = st:find2(DEBUFF,6, debuff,8); -- find timers marked 'tdebuff' with this name
				if index then
					-- currently i'm not using guid for raid debuffs, so no need to update that
					if st[index][1] ~= expire or st[index][14] > NORMAL --[[or guid ~= st[index][11] ]]then
						st[index][1] = expire;
						--st[index][11] = guid;
						st[index][14] = 0;
						st[index][17] = 0;
						--st[index][12] = ST_GetFadeTime(debuff);
					end
					st[index][3] = total;
					st[index][16] = count or 0;

					--FW:Debug("tdebuff correct");
				elseif not st:find2(debuff,8,guid,11) then -- don't add when i already have this debuff added, but as my own cast
					--FW:Show("tdebuff insert");
					st:insert(expire,FW:CastTime(debuff),total,debuff,0,DEBUFF,texture,debuff,CA:Unique("target"),0,guid,0,PRIOR_DEBUFF,0,1,count or 0,0,"filter",GetRaidTargetIndex("target") or 0,expire,total,1.0,0);
				end
			end
			i=i+1;
		else
			break;
		end
	end
end

local function ST_PlayerBuffs()

	-- remove any faded buffs that i'm tracking
	local i = 1;
	while i<= st.rows do
		if st[i][14] <= NORMAL then 
			if st[i][6] == POWERUP then
				if not UnitBuff("player",st[i][8]) then
					ST:Fade(i,FADING_INSTANT);
				end
			elseif st[i][6] == SELF_DEBUFF then
				if not UnitDebuff("player",st[i][8]) then
					ST:Fade(i,FADING_INSTANT);
				end
			end
		end
		i=i+1;
	end
	i = 1;
	while true do
		local buff,_,texture,count,_,total,expire = UnitBuff("player",i);
		if buff then
			-- I also want people to be able to add powerups that may be missing!
			if FlagToAction(nil,buff,POWERUP) == FILTER_SHOW then
				local index = st:find2(POWERUP,6, buff,8);
				if index then
					if st[index][1] ~= expire or st[index][14] > NORMAL then
						st[index][1] = expire;
						st[index][17] = 0;
						st[index][14] = 0;
						--st[index][12] = ST_GetFadeTime(buff);
					end
					st[index][3] = total;
					--st[index][7] = texture;
					st[index][16] = (not NonStacking[buff] and count) or 0;
					
				else
					st:insert(expire,FW:CastTime(buff),total,buff,0,POWERUP,texture,buff,0,0,"none",0,PRIOR_POWERUP,0,1,(not NonStacking[buff] and count) or 0,0,"filter",0,expire,total,1.0,0);
					for n, f in	ipairs(ST_OnBuffGain) do
						f(buff);
					end
				end
			end
			i=i+1;
		else
			break;
		end
	end
	
	i = 1;
	while true do
		local buff,_,texture,count,_,total,expire = UnitDebuff("player",i);
		if buff then
			-- I also want people to be able to add powerups that may be missing!
			if FlagToAction(nil,buff,SELF_DEBUFF) == FILTER_SHOW then
				local index = st:find2(SELF_DEBUFF,6, buff,8);
				if index then
					if st[index][1] ~= expire or st[index][14] > NORMAL then
						st[index][1] = expire;
						st[index][17] = 0;
						st[index][14] = 0;
					end
					st[index][3] = total;
					st[index][16] = count or 0;
				else
					st:insert(expire,0,total,buff,0,SELF_DEBUFF,texture,buff,0,0,"none",0,PRIOR_SELF_DEBUFF,0,1,count or 0,0,"filter",0,expire,total,1.0,0);
					--[[for n, f in	ipairs(ST_OnSelfDebuffGain) do
						f(buff);
					end]]
				end
			end
			i=i+1;
		else
			break;
		end
	end
end

local function ST_AuraChanged(event,unit) -- triggered by "UNIT_AURA"
	-- do special stuff
	--FW:Show("aura "..unit);
	if unit == "target" then
		FW:DelayedExec(FW.Settings.Delay,1,ST_TargetDebuffs);
		--ST_TargetDebuffs(); -- really have to make this work!!
	elseif unit == "player" or unit == "vehicle" then
		FW:RegisterThrottle(ST_PlayerBuffs);
	end
	-- also do standard stuff
	FW:RegisterThrottle(ST_CorrectionScan,unit);
end

-- target/focus change tracking ONLY, doesnt look at debuffs anymore

local function ST_TargetChanged()
	FW:Changed("target");
	ST_TargetDebuffs();
	ST_CorrectionScan("target");
	
	rebuildLinks(); -- IMPORTANT
	local t = GetTime();
	for i=1,st.rows,1 do -- spelltimer part
		if st[i][11] == FW.target then -- briefly show hidden timers on reselect
			setValueLinks(i,7,t);
	 	end
	end
end

local function ST_FocusChanged()
	FW:Changed("focus");
	ST_CorrectionScan("focus");
	
	rebuildLinks(); -- IMPORTANT
	local t = GetTime();
	for i=1,st.rows,1 do -- spelltimer part
		if st[i][11] == FW.focus then -- briefly show hidden timers on reselect
			setValueLinks(i,7,t);
	 	end
	end
end

local function ST_MouseOverChanged() --with improvement enabled, I want to scan my mouseover target for removed debuffs
	FW:Changed("mouseover");
	ST_CorrectionScan("mouseover");
end

local scanned = {};
local function ST_ScanUnitDebuffs(unit)
	local guid = UnitGUID(unit);
	if guid and not scanned[guid] then
		scanned[guid] = 1;
		ST_CorrectionScan(unit);
	end
end

local function ST_RaidTargetScan()
	if not FW.Settings.TimerImproveRaidTarget then return;end
	erase(scanned);
	if GetNumRaidMembers() > 0 then	
		for i=1,GetNumRaidMembers(),1 do
			ST_ScanUnitDebuffs(RAID[i].."pet");
			ST_ScanUnitDebuffs(RAID[i].."target");
		end
	else
		for i=1,GetNumPartyMembers(),1 do
			ST_ScanUnitDebuffs(PARTY[i].."pet");
			ST_ScanUnitDebuffs(PARTY[i].."target");
		end
	end
end

-- also USED TO DO a normal scan on target, focus, mouseover, pet and pettarget
local function ST_ExtraScan()
	--FW:Show("extra scan");
	
	-- those never triggered by unitaura event:
	ST_CorrectionScan("mouseover");
	ST_CorrectionScan("pettarget");
	
	-- also scan the rest to make sure...
	ST_CorrectionScan("player");
	ST_CorrectionScan("target");
	ST_CorrectionScan("focus");
	ST_CorrectionScan("pet");
	
	-- and new unit tokens...
	ST_CorrectionScan("arena1");
	ST_CorrectionScan("arena2");
	ST_CorrectionScan("arena3");
	ST_CorrectionScan("arena4");
	ST_CorrectionScan("arena5");

	ST_CorrectionScan("boss1");
	ST_CorrectionScan("boss2");
	ST_CorrectionScan("boss3");
	ST_CorrectionScan("boss4");
end

local function ST_MobDies(guid)
	for i=1,st.rows,1 do
		if st[i][11] == guid then
			ST:Fade(i,REMOVE);
		end
	end
end

local function ST_RegisterImproved()
	ActiveDots:erase();
end

local function ST_RemoveDots()
	if FW.Settings.TimerImprove then
		local i=1;
		local t = GetTime();
		while i<= ActiveDots.rows do
			if ActiveDots[i][3] < t then
				local t1,t2 = unpack(ActiveDots[i]);
				ActiveDots:remove(i);
				
				if strfind(t1,"^0x") then
					for j=1,st.rows,1 do
						if st[j][11] == t1 and st[j][14] <= NORMAL and st[j][8] == t2 then
							ST:Fade(j,REMOVE);
							break;
						end
					end			
				else
					for j=1,st.rows,1 do
						if st[j][4] == t1 and st[j][14] <= NORMAL and st[j][8] == t2 then
							ST:Fade(j,REMOVE);
						end
					end
				end
				--FW:Show("removing "..t2.." on "..t1);
			else
				i=i+1;
			end
		end
	end
end

local colors = {
	[DEFAULT] = "MagicColor",
	[SHARED] = "CurseColor",
	[SHARED2] = "Shared2Color",
	[SHARED3] = "Shared3Color",
	[UNIQUE] = "CrowdColor",
	[PET] = "PetColor",
	[POWERUP] = "BuffColor",
	[SELF_DEBUFF] = "SelfDebuffColor",
	[CHARM] = "CrowdColor",
	[COOLDOWN] = "CooldownsColor",
	[DEBUFF] = "DebuffsColor",
	[DRAIN] = "DrainColor",
	[HEAL] = "HealColor",
	[BUFF] = "FriendlyBuffColor",
};

local function ColorVal(frame,v,total,flag,flag2,custom,spell)
	local r,g,b,a;
	if flag2 > REMOVE then
		if frame.s.HighlightEnable and v > -0.5 then
			r,g,b = FW:MixColors(-2*v,frame.s.HighlightColor,frame.s.FailColor);
		else
			r,g,b = unpack(frame.s.FailColor);
		end
	elseif flag2 == REMOVE then
		r,g,b = unpack(frame.s.FailColor);
	else	
		if frame.s.HighlightEnable and total-v<0.5 then
			if custom == FILTER_COLOR or custom == FILTER_SHOW_COLOR then
				local filter = FlagToFilter(frame,spell,flag);
				r,g,b = FW:MixColors2((total-v)*2,
				frame.s.HighlightColor[1],frame.s.HighlightColor[2],frame.s.HighlightColor[3],
				filter[2],filter[3],filter[4]
				);
			else
				r,g,b = FW:MixColors((total-v)*2,frame.s.HighlightColor,frame.s[colors[flag]]);
			end
		else
		 	if custom == FILTER_COLOR or custom == FILTER_SHOW_COLOR then
				r,g,b = unpack(FlagToFilter(frame,spell,flag),2,4);
			else
				r,g,b = unpack(frame.s[colors[flag]]);
			end
		end
	end
	--alpha
	if total == 0 then
		a = 1;
	elseif v <= 0 and frame.s.ExpiredEnable then
		r,g,b,a = unpack(frame.s.ExpiredColor);
	elseif frame.s.BlinkEnable and v <= frame.s.Blink and v>0 then
		-- if bg alpha is set to 0.5 or higher: move from baralpha to baralpha -0.5
		-- if bg alpha is set to lower than 0.5: move from baralpha to baralpha +0.5
		if frame.s.BarBackgroundAlpha >= 0.5 then
			a = frame.s.BarBackgroundAlpha-0.25*(1-cos(25*sqrt(v)));
		else
			a = frame.s.BarBackgroundAlpha+0.25*(1-cos(25*sqrt(v)));
		end
	else
		a=frame.s.BarBackgroundAlpha;
	end
	return r,g,b,a;
end

local function ST_DrawTimers()
	for i=1,instances.rows,1 do
		instances[i][2]:Draw();
	end
end

local function ST_ShowTimeFor(id)
	local target = st[id][4];
	if st[id][19] ~= 0 then 
		target = FW.RaidIcons[st[id][19]]..target;
	end
	FW:ShowTimeFor(st[id][8],target,st[id][1]-GetTime(),st[id][6] == COOLDOWN);
end

function ST_GetFadeTime(spellname)
	local what = ST_OnTimerFade[spellname];
	if what then
		local _,_,t = strfind(FW.Settings[what.."Msg"],"([%.%d]+)");
		if t then t = tonumber(t); end
		return t or 0.1;	
	else
		return 0;
	end
end

function ST:RegisterOnTimerFade(spellname,option)
	ST_OnTimerFade[spellname] = option;
end

function ST:RegisterOnTimerBreak(func)
	tinsert(ST_OnTimerBreak,func);
end

function ST:RegisterOnBuffGain(func)
	tinsert(ST_OnBuffGain,func);
end

local function NewTick(parent,n)
	local tick;
	parent.ticks[n] = parent:CreateTexture(nil,"OVERLAY");
	tick = parent.ticks[n];
	tick.parent = parent;
	tick:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark");
	tick:SetBlendMode("ADD");
	
	tick.Update = function(self)
		local s = self.parent.parent.parent.s;
		self:SetWidth(s.Height*0.5);
		self:SetHeight(s.Height*1.5);
	end;
	tick:Update();
	return tick;
end

local function NewStatusBar(parent)
	local bar = CreateFrame("Frame",nil,parent);
	bar.parent = parent;
	bar.texture = bar:CreateTexture(nil,"ARTWORK");
	bar.texture:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0);
	
	bar.origSetWidth = bar.SetWidth;
	bar.SetWidth = function(self,val)
		self:origSetWidth(val);
		self:SetValue(self.value);
	end
	bar.SetStatusBarColor = function(self,r,g,b,a)
		self.texture:SetVertexColor(r,g,b,a);
	end
	bar.GetStatusBarColor = function(self)
		return self.texture:GetVertexColor();
	end
	bar.SetValue = function(self,value)
		--[[if value < 0 then
			value = 0;
		elseif value > 1 then
			value = 1;
		end]]
		self.value = value;
		self.texture:SetTexCoord(0, value, 0, 1);
		self.texture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (value-1)*self:GetWidth(), 0);
	end
	bar.SetStatusBarTexture = function(self,texture)
		self.texture:SetTexture(texture);
	end
	bar:SetValue(1);
	return bar;
end

local function NewBar(parent,n)
	local bar;
	parent.bars[n] = NewStatusBar(parent);
	bar = parent.bars[n];
	bar.ticks = {};
	
	-- clickable icon
	bar.button = CreateFrame("Button",nil,bar);
	bar.button.spark = bar.button:CreateTexture(nil,"OVERLAY");
	bar.button.spark:SetPoint("CENTER",bar.button,"CENTER");
	bar.button.spark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark2");
	bar.button.spark:SetBlendMode("ADD");
	bar.button:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\ST");
	bar.button.texture = bar.button:GetNormalTexture();
	bar.button.texture:SetTexCoord(0.133,0.867,0.133,0.867);
	
	-- texts
	bar.name = bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.time = bar:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	bar.time:SetJustifyH("LEFT");
		
	--sparks
	bar.spark = bar:CreateTexture(nil,"OVERLAY");
	bar.spark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark");
	bar.spark:SetBlendMode("ADD");
	bar.spark:SetPoint("CENTER",bar,"CENTER");
	
	bar.castspark = bar:CreateTexture(nil,"OVERLAY");
	bar.castspark:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Spark");
	bar.castspark:SetBlendMode("ADD");
	bar.castspark:SetPoint("CENTER",bar,"CENTER");

	bar.castarea = bar:CreateTexture(nil,"OVERLAY");
	bar.castarea:SetPoint("LEFT",bar,"LEFT",0,0);
	bar.castarea:SetPoint("RIGHT",bar,"LEFT",0,0);
	bar.castarea:SetBlendMode("ADD");

	--raid target icon
	bar.raidicon = bar:CreateTexture(nil,"OVERLAY");
	bar.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
	
	--background
	bar.back = bar:CreateTexture(nil,"BACKGROUND");
	bar.back:SetAllPoints(bar);
	bar.back:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar");
	
	--scripts
	bar.button:SetScript("OnClick",function(self,button)
		if button == "RightButton" then
			if FW.Settings.RightClickIconOptions then
				FW:ScrollTo(FWL.SPELL_TIMER.." Color",1,bar.parent.parent.name);
				FW:SetFilterName(FWL.SPELL_TIMER.." Filter",st[bar.id][8],FlagToFilterIndex(st[bar.id][6]));
			end
		else
			if IsShiftKeyDown() then
				--put on ignore once
				st[bar.id][14] = IGNORE;
			else
				-- show duration
				ST_ShowTimeFor(bar.id);
			end
		end
	end);
	bar.button:SetScript("OnEnter",function(self)
		self.over=1;
		FW:ShowTip(self);
	end);
	bar.button:SetScript("OnLeave",function(self)
		self.over=nil;
		FW:HideTip(self);
	end);
	bar.button:SetScript("OnUpdate",function(self)
		if self.over and self.oldtitle ~= self.title then
			self.oldtitle = self.title;
			FW:ShowTip(self);
		end
	end);
	bar.button:RegisterForClicks("RightButtonUp","LeftButtonUp");

	--functions
	bar.NewTick = NewTick;
	bar.SetTicks = function(self,totaltime,interval,barval,r,g,b)
		local s = self.parent.parent.s;
		if s.TicksEnable then
			
			if totaltime > 0 then
				local w = bar:GetWidth();
				interval = w/(totaltime/interval);
				barval = barval*w;
				local dist = 0;
				if s.TicksNext then -- next only
					barval = barval-interval;
					while(dist<barval) do
						dist = dist + interval;
					end
					local tick = bar.ticks[1] or bar:NewTick(1);
					if dist<w and barval+interval>0 then
						tick:SetPoint("CENTER", bar, "LEFT", dist, 0);
						tick:SetVertexColor(r,g,b);
						tick:SetAlpha(s.Ticks);
						tick:Show();
					else
						tick:Hide();
					end
					
				else -- all ticks
					local i=1;
					while dist<barval and dist<w do
						local tick = bar.ticks[i] or bar:NewTick(i);
						tick:SetPoint("CENTER", bar, "LEFT", dist, 0);
						tick:SetVertexColor(r,g,b);
						tick:SetAlpha(s.Ticks);
						tick:Show();
						dist = dist + interval;
						i=i+1;
					end
					while bar.ticks[i] and bar.ticks[i]:IsShown() do
						bar.ticks[i]:Hide();
						i=i+1;
					end
				end
			else
				if s.TicksNext then
					if bar.ticks[1] then
						bar.ticks[1]:Hide();
					end
				else
					for i, tick in ipairs(bar.ticks) do
						tick:Hide();
					end
				end
			end
		end
	end
	bar.Update = function(self)
		local s = self.parent.parent.s;
	
		self:ClearAllPoints();
		self:SetHeight(s.Height);
		self:SetStatusBarTexture(s.Texture);
		self.castarea:SetTexture(s.Texture);
		self.back:SetTexture(s.Texture);
		
		self.button:SetWidth(s.Height);
		self.button.spark:SetWidth(s.Height*2.2);

		if s.SparkEnable then
			self.spark:SetWidth(s.Height);
			self.spark:SetHeight(s.Height*2);
			self.spark:SetAlpha(s.Spark);
			self.spark:Show();
		else
			self.spark:Hide();
		end
		self.castarea:SetHeight(s.Height);	
		self.castspark:SetWidth(s.Height*0.9);
		self.castspark:SetHeight(s.Height*1.8);
			
		self.castarea:SetAlpha(s.CastSpark);
		self.castspark:SetAlpha(s.CastSpark);	
	
		self.raidicon:SetWidth(s.Height);
		self.raidicon:SetAlpha(s.RaidTargets);
		
		self.name:SetFont(s.Font,s.FontSize);
		self.time:SetFont(s.Font,s.FontSize);
		self.time:SetTextColor(unpack(s.NormalColor));
		
		self.name:ClearAllPoints();
		self.name:SetPoint("CENTER", self, "CENTER",0,0);
		self.raidicon:SetPoint("CENTER", self, "CENTER",0,0);

		if s.Icon then -- icon is placed outside of the actual bar!!
			self:SetWidth(s.Width-s.Height-1);
			self.button:ClearAllPoints();
			if s.IconRight then -- icon on right side of bar
				self.button:SetPoint("TOPLEFT",self,"TOPRIGHT",1,0);
				self.button:SetPoint("BOTTOMLEFT",self,"BOTTOMRIGHT",1,0);
			else -- icon on left side of bar
				self.button:SetPoint("TOPRIGHT",self,"TOPLEFT",-1,0);
				self.button:SetPoint("BOTTOMRIGHT",self,"BOTTOMLEFT",-1,0);
			end
			self.button:Show();
		else
			self.button:Hide();
			self:SetWidth(s.Width);
		end
		if s.Time then
			self.time:ClearAllPoints();
			if s.TimeRight then -- time on right side of bar
				self.time:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, 0);
				self.time:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 0);
			else -- time on left side of bar
				self.time:SetPoint("TOPLEFT", self, "TOPLEFT", 2, 0);
				self.time:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 0);
			end
			if s.TimeSpaceEnable then
				self.time:SetWidth(s.TimeSpace);
			end
			self.time:Show();
		else
			self.time:Hide();
		end
		if s.Name then
			if s.TimeSpaceEnable then
				self.name:SetWidth(self:GetWidth()-2*s.TimeSpace-4); -- 4 margin (2 on both sizes)
			end
			self.name:SetHeight(self:GetHeight());
			self.name:Show();
		else
			self.name:Hide();
		end
		if s.RaidTargetsEnable then -- hide/show done on normal update
			
		end
	end;
	bar:Update();
	return bar;
end

local function NewGroup(parent,n)
	local group;
	parent.groups[n] = CreateFrame("Frame",nil,parent);
	group = parent.groups[n];
	group.bars = {};
	group.parent = parent;
	group.background = CreateFrame("Frame",nil,group);
	group.background:SetAllPoints(group);
	group.background:SetFrameLevel(1);	
		
	group.label = group:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");
	
	group.NewBar = NewBar;
	group.NewLabel = NewLabel;

	group.Finalize = function(self,i)
		while self.bars[i] and self.bars[i]:IsShown() do
			self.bars[i]:Hide();
			i=i+1;
		end
	end;
	
	group.Update = function(self)
		local s = self.parent.s;
		
		self:ClearAllPoints();
		self.label:ClearAllPoints();
		if s.Expand == true then 
			self:SetPoint("BOTTOM",self.parent,"BOTTOM");
		else
			self:SetPoint("TOP",self.parent,"TOP");
		end
		self:SetWidth(s.Width+s.Backdrop[6]*2);
		
		self.label:SetFont(s.LabelFont,s.LabelFontSize);
		self.background:SetBackdrop(self.parent.header.backdrop);
	end;
	group:Update();
	return group;
end

local function ST_NewTimerFrame(name,displayname)
	local frame = CreateFrame("Frame",nil,UIParent);
	frame.parent = UIParent;
	frame.name = name;
	frame.displayname = displayname;
	frame.groups = {};
	frame:SetPoint("CENTER",UIParent,"CENTER");	
	frame:SetHeight(20);
	
	frame.header = CreateFrame("Frame",nil,frame);
	frame.header:SetAllPoints(frame);
	frame.header.title = frame.header:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
	frame.header.title:SetAllPoints(frame);
	
	--scripts
	frame:SetScript("OnMouseDown",function(self,button)
		FW:StartMoving(self, button);
	end);
	frame:SetScript("OnMouseUp",function(self,button)
		FW:StopMoving(self);
		if FW:Moved() then return; end
		if button == "RightButton" then
			FW:ScrollTo(FWL.SPELL_TIMER,nil,frame.name);
		end
		PlaySound("igMainMenuOptionCheckBoxOn");
	end);

	--functions
	frame.NewGroup = NewGroup;
	
	local links = FW:NEW2D();

	local function VisibleUnit(id,guid)
		if id<=0 or id>=maxi then
			if guid == "" then
				return frame.s.UnknownTarget;
			else
				if id == PRIOR_NONE then
					return frame.s.NoTarget;
				elseif id == PRIOR_DEBUFF then	
					return frame.s.RaidDebuffs;
				else
					return frame.s.You;
				end
			end

		elseif guid==FW.target or guid==FW.focus then
			return (guid==FW.target and frame.s.Target) or (guid==FW.focus and frame.s.Focus);
		else
			return frame.s.Other;	
		end
	end
	
	local function Alpha(trigger,t)
		if t <= trigger then
			return 1;
		elseif t<trigger+FW.Settings.TimerFadeSpeed then 
			return 1 - pow( ((t-trigger)/FW.Settings.TimerFadeSpeed),3);
		else
			return 0;
		end
	end
	local function Visible(index)
		return (VisibleUnit( st[index][13], st[index][11]) and (st[index][14] < FAILED or frame.s.FailEnable) and FlagToAction(frame, st[index][8],st[index][6])) or FILTER_HIDE;
	end
	frame.addLink = function(self,index)
		local action = Visible(index);
		if action ~= FILTER_HIDE then
			--FW:Show("add");
			links:insert( index, st[index][13] , st[index][20] , 1, action, st[index][3], 0);
		end
	end
	frame.removeLink = function(self,index)
		--FW:Show("remove");
		links:remove( links:find( index , 1 ) );
		for i=1, links.rows do -- super important to update ids too!!
			if links[i][1] > index then
				links[i][1] = links[i][1] - 1;
			end
		end
	end
	frame.setValueLinks = function(self,index,col,val)
		local l = links:find( index , 1 );
		if l then
			links[l][col] = val;
		end
	end
	frame.eraseLinks = function(self)
		links:erase();
	end
	frame.printLinks = function(self)
		links:print();
	end
	frame.rebuildLinks = function(self)
		local action, l;
		for index=1,st.rows do
			action, l = Visible(index), links:find(index,1);
			if action == FILTER_HIDE then
				links:remove(l);
			else
				if not l then
					links:insert(index,st[index][13],st[index][20],1,action,st[index][3],0);
				end
			end
		end
	end
	frame.Draw = function(self)
		if not self:IsShown() then return; end
		local smooth = FW.Settings.TimerSmooth;
		local s = self.s;
		local baroffset = s.Backdrop[6];
		local index=1;
		local lastid;
		local higha = 0;
		local barvisibility = 0;
		local highh = 0;
		local bar,spark,label;
		local barval;
		local _,t1,t2,t3,t4,t6,t7,t8,t9,t10,t11,t13,t14,t15,t16,t17,t18,t19,t20,t21,t22;
		local i = 1;
		local g = 1; -- used for group index
		local groupsize = 0;
		local groupoffset = 0;
		local groupvisibility = 0;
		local group;
		local t = GetTime();
		local highestduration = 0; 
		--pre-compute stuff
		local k = 1;
		-- copy some values from st to sort links by
		for k=1, links.rows do
			i = links[k][1];
			links[k][2],links[k][3] = st[i][13],st[i][20]; -- set these for sorting only
			
			-- calc visibility
			t14,t17 = st[i][14],st[i][17];
			if t14 == IGNORE then
				links[k][4] = 0;
			elseif t14 == NORMAL then
				if s.HideLongerEnable and (not s.HideLongerNoBoss or st[i][9]~=1) and (st[i][1]-t) >= s.HideLonger then
					if links[k][7] == 0 then
						links[k][7] = t;
					end
				else
					links[k][7] = 0;
				end			
				if links[k][7] == 0 then
					links[k][4] = 1;
				else
					links[k][4] = Alpha(links[k][7]+s.HideTime,t); 
				end
			elseif t14 == FADING_INSTANT then
				links[k][4] = Alpha(t17,t); 
			elseif t14 == FADING then
				links[k][4] = Alpha(t17+s.FadeTime,t); 
			else -- removed/failed
				links[k][4] = Alpha(t17+s.FailTime,t); 
			end
		end
		if s.GroupID then
			if s.Outwands then
				SORT_TIMER_ASC2[2]=true;
			else
				SORT_TIMER_ASC2[2]=false;
			end
			links:sort(SORT_TIMER_ORDER2,SORT_TIMER_ASC2);
		else
			if s.Outwands then
				SORT_TIMER_ASC[1]=true;
			else
				SORT_TIMER_ASC[1]=false;
			end
			links:sort(SORT_TIMER_ORDER,SORT_TIMER_ASC);
		end
		
		local visible = 0;

		for k=1, links.rows do
			i = links[k][1];
			
			if (not s.MaxEnable or visible < s.Max) and links[k][4] > 0 then -- visibility (yes or no) based on num timers and alpha
				visible = visible + 1;

				if not s.ForceMax then
					t3 = st[i][3];
					if s.OneMax then
						if t3 > highestduration then
							if s.MaxTimeEnable and t3 > s.MaxTime then
								highestduration = s.MaxTime;
							else
								highestduration = t3;
							end
						end
					else
						if s.MaxTimeEnable and t3 > s.MaxTime then
							links[k][6] = s.MaxTime;
						else
							links[k][6] = t3;
						end
					end
				end
				-- pre-calculate group scaling and alpha (and pre-make groups)
				if s.GroupID and lastid ~= st[i][13] or lastid == nil then --  create a new group!
					group = self.groups[g] or self:NewGroup(g);
					g=g+1; -- new group number for next group
					group.factor = 0;
				end
				if group.factor < links[k][4] then
					group.factor = links[k][4];
				end
				lastid = st[i][13];
			else
				links[k][4] = 0;
			end
		end
		
		if s.ForceMax then
			highestduration = s.MaxTime;
			for k=1,links.rows do
				if links[k][4] == 1 then
					links[k][6] = links[k][6]+(highestduration-links[k][6])/smooth;
				end
			end
		elseif s.OneMax then
			for k=1,links.rows do
				if links[k][4] == 1 then
					links[k][6] = links[k][6]+(highestduration-links[k][6])/smooth;
				end
			end
		end
		
		
		lastid = nil;
		group = nil;
		g = 1;
		i=1;
		
		for k=1,links.rows do -- stuff to make it 'skip' certain timers for display
			t15 = links[k][4];
			if t15 > 0 then -- is visible
				_,t2,t3,t4,_,t6,t7,t8,t9,t10,t11,_,t13,t14,_,t16,_,t18,t19,t20,t21,t22 = unpack(st[ links[k][1] ]);
				-- add linked instance values
				t18 = links[k][5];
				t21 = links[k][6];
				
				-- GROUP AND BAR CREATION
				t1 = t20 - t;
				if t21 == 0 then
					t21 = 1;
				end
				--t20 = t20 - t;
				if s.GroupID then
					if lastid ~= t13 then --  create a new group!
						if group then
							group:Finalize(i);
							group:SetHeight( groupsize+group.bordersize );
							group.background:SetAlpha(groupvisibility);
							label:SetHeight(group.labelsize);
							label:SetAlpha(groupvisibility);
							groupoffset = groupoffset + group:GetHeight() + s.SpacingHeight*group.factor;
						end
						
						group = self.groups[g] or self:NewGroup(g);
						label = group.label;
						group.bordersize = s.Backdrop[6]*group.factor;
						group.labelsize = s.LabelHeight*group.factor;
						baroffset = group.bordersize;
						i=1;
						g=g+1; -- new group number for next group
						groupvisibility = 0;
						if t13 > 0 and t13 < maxi and s.Label then -- add a name label
							
							if s.ShowID and t9 == 0 then
								label:SetText("#"..t13.." "..t4);
							else
								label:SetText(t4);
							end
							if t11 == FW.target then
								label:SetTextColor(unpack(s.TargetColor));
							elseif t11 == FW.focus then
								label:SetTextColor(unpack(s.FocusColor));
							else
								label:SetTextColor(unpack(s.NormalColor));
							end
							if s.Expand == true then 
								label:SetPoint("BOTTOM",group,"BOTTOM",0,group.bordersize);
							else
								label:SetPoint("TOP",group,"TOP",0,-group.bordersize);
							end
							baroffset = baroffset + group.labelsize;
							label:Show();
						else
							label:Hide();
						end
						if s.TargetBgEnable and t11 == FW.target then
							group.background:SetBackdropBorderColor(unpack(s.TargetBgColor));
							group.background:SetBackdropColor(unpack(s.TargetBgColor));
						elseif s.FocusBgEnable and t11 == FW.focus then
							group.background:SetBackdropBorderColor(unpack(s.FocusBgColor));
							group.background:SetBackdropColor(unpack(s.FocusBgColor));
						else
							group.background:SetBackdropBorderColor(unpack(s.NormalBgColor));
							group.background:SetBackdropColor(unpack(s.NormalBgColor));
						end
					end
				else -- without grouping, just create one group to use for all bars
					if lastid == nil then
						group = self.groups[g] or self:NewGroup(g);
						label = group.label;
						group.bordersize = s.Backdrop[6]*group.factor;
						group.labelsize = s.LabelHeight*group.factor;
						label:Hide();
						g=g+1;
					end
					group.background:SetBackdropBorderColor(unpack(s.NormalBgColor));
					group.background:SetBackdropColor(unpack(s.NormalBgColor));
				end
				
				bar = group.bars[i] or group:NewBar(i);
				spark = bar.spark;
				
				-- SIZE AND ALPHA STUFF
				if s.Expand == true then
					if s.Icon and not s.IconRight then
						bar:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT",s.Height+1+s.Backdrop[6], baroffset);
					else
						bar:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT",s.Backdrop[6], baroffset);
					end
					group:SetPoint("BOTTOM",self,"BOTTOM",0, groupoffset);
				else
					if s.Icon and not s.IconRight then
						bar:SetPoint("TOPLEFT", group, "TOPLEFT",s.Height+1+s.Backdrop[6], -baroffset);
					else
						bar:SetPoint("TOPLEFT", group, "TOPLEFT",s.Backdrop[6], -baroffset);
					end
					group:SetPoint("TOP",self,"TOP",0, -groupoffset);
				end
				
				baroffset = baroffset + t15*s.Height;
				groupsize = baroffset;
				baroffset = baroffset + t15*s.Space;

				if t13<=0 or t13>=maxi or t11==FW.target or t14>REMOVE then
					barvisibility = t15;
				else
					barvisibility = s.NormalAlpha*t15;
				end
				if barvisibility > groupvisibility then
					groupvisibility = barvisibility;
				end
				bar:SetAlpha(barvisibility); 
				
				-- ALL OTHER STUFF
				if t19 == 0 or not s.RaidTargetsEnable then
					bar.raidicon:Hide();
				else
					bar.raidicon:SetTexCoord(unpack(FW_RaidIconCoords[t19]));
					bar.raidicon:SetHeight(t15*s.Height);
					bar.raidicon:Show();
				end
				local r,g,b,a = ColorVal(self,t1,t3,t6,t14,t18,t8);
				bar:SetStatusBarColor(r,g,b);
				bar.back:SetVertexColor(r,g,b,a);		
				r,g,b = FW:FixIntensity(r,g,b);
				
				if t1<0 then
					spark:Hide();
					t1=0;
				else
					if s.SparkEnable then
						spark:SetVertexColor(r,g,b);
						spark:SetAlpha(s.Spark);
						spark:Show();
					else
						spark:Hide();
					end
				end
				bar.button.title = FW:SecToTime(t1).." "..t8;
				bar.button.tip = t4.."\n"..FW:SecToTime(t1).."/"..FW:SecToTime(t3);
			
				--t1 = curent time, t3 = total time, t21 = adapted time			
				if t1>t21 then
					barval=1;
				else
					barval = t1/t21;
				end
				if s.TicksEnable and Tick[t8] then
					bar:SetTicks(t21,Tick[t8]*t22,barval,r,g,b);
				else
					bar:SetTicks(0,1,0,r,g,b);
				end
				--if s.Flip then
					--barval = barval-1;
				--end
				bar:SetValue(barval);
				bar.id = links[k][1];
				-- t1 = remaining, t2 = cast time, t3 = total time, t21 = maximum used (end of bar)
				
				local from,to = barval,barval;
				-- from is the original spark, to is the cast spark
				if s.CastSparkEnable then
					if t1<=t2 and t3>0 and (t1==0 or t6 ~= COOLDOWN) then -- Cast Spark, t3>0 to hide if it's a resist etc
						bar.button.spark:SetVertexColor(r,g,b);
						bar.button.spark:Show();
					else
						bar.button.spark:Hide();
					end
					-- manages the cast sparks REWRITE PLXX!!!
					if t2>0 and t1>0 and t3>0 and t6 ~= COOLDOWN then -- does have a cast time
						if t1>t2 then
							to = from-t2/t21;
						else
							to = 0;
						end
					else
						if s.OneMax and t1<t21 and (t6 <= UNIQUE or t6 >= HEAL or (t6==COOLDOWN and t2==0)) then
							if t1+CA.GlobalCooldown < t21 then
								to = from + CA.GlobalCooldown/t21;
							else
								to = 1;
							end
						elseif t6 == COOLDOWN and t2 > 0 and t1<t21 then
							if t1+t2 < t21 then
								to = from + t2/t21;
							else
								to = 1;
							end
						end
					end
				else
					bar.button.spark:Hide();
				end
				if to == from then
					bar.castarea:Hide();
					bar.castspark:Hide();
				else
					bar.castarea:SetVertexColor(r,g,b);
					bar.castspark:SetVertexColor(r,g,b);
					bar.castarea:Show();
					bar.castspark:Show();
					bar.castspark:SetPoint("CENTER", bar, "LEFT",to*bar:GetWidth(), 0);
					if to > from then
						to,from = from,to;
					end
					bar.castarea:SetTexCoord(to,from,0,1);
					bar.castarea:SetPoint("LEFT",bar,"LEFT",to*bar:GetWidth(),0);
					bar.castarea:SetPoint("RIGHT",bar,"LEFT",from*bar:GetWidth(),0);
				end
			
				if s.CustomTag then
					local str = s.CustomTagMsg;
					if t13 > 0 and t13 < maxi and t9 == 0 then -- add ID
						str = gsub(str,"id","#"..t13);
					else
						str = gsub(str,"id","");
					end
					if  t16 ~= 0 then -- add stacks
						str = gsub(str,"stacks","("..t16..")");
					else
						str = gsub(str,"stacks","");
					end
					if t4 ~= t8 then
						str = gsub(str,"target",t4);
					else
						str = gsub(str,"target","");
					end
					str = gsub(str,"spell",t8);
					bar.name:SetText(str);
				else
					if s.Spell or t4 == "" then
						t4 = t8;
					end
					if s.ShowID and t13 > 0 and t13 < maxi and t9 == 0 and not s.Spell then
						bar.name:SetText("#"..t13.." "..t4);
					elseif t16 ~= 0 then
						bar.name:SetText(t4.." ("..t16..")");
					else
						bar.name:SetText(t4);
					end
				end
				bar:SetHeight(t15*s.Height);
				bar.button.spark:SetHeight(t15*s.Height*2.2);
				
				if s.TargetEnable and t11 == FW.target then
					bar.name:SetTextColor(unpack(s.TargetColor));
				elseif s.FocusEnable and t11 == FW.focus then
					bar.name:SetTextColor(unpack(s.FocusColor));
				else
					bar.name:SetTextColor(unpack(s.NormalColor));
				end
				if t14 > REMOVE then
					bar.time:SetText(FADE_SHOW[t14]);
				elseif t3 == 0 then
					bar.time:SetText("");
				else
					bar.time:SetText(FW:SecToTimeD(t1));
				end
				bar.button.texture:SetTexture(t7);
				
				spark:SetPoint("CENTER", bar, "LEFT",barval*bar:GetWidth(), 0);
				if not s.TimeSpaceEnable and s.Time and s.Name then
					local w = bar.time:GetWidth() + 2; -- add the 2 margin here too
					bar.name:SetWidth(bar:GetWidth()-2*w-4); -- 4 margin (2 on both sizes)
				end
				lastid = t13;
			
				bar:Show();
				group:Show();
				i=i+1;
			end
		end
		-- bar/bg positioning
		if group then
			group:Finalize(i);
			group.background:SetAlpha(groupvisibility);
			group:SetHeight( groupsize+group.bordersize );
			label:SetHeight( group.labelsize );
			label:SetAlpha(groupvisibility);
			self.header:Hide();
		elseif not s.lock then
			self.header:Show();
		else
			self.header:Hide();
		end
		
		while self.groups[g] and self.groups[g]:IsShown() do
			self.groups[g]:Hide();
			g=g+1;
		end

	end
	frame.HideTicks = function(self)
		for g, group in ipairs(self.groups) do
			for b, bar in ipairs(group.bars) do
				for i, tick in ipairs(bar.ticks) do
					tick:Hide();
				end
			end
		end	
	end
	
	frame.Update = function(self)
		self.s = FW.Settings[self.name] or FW.Settings;
		if FW.Settings.GlobalFrameNames then
			_G["FX_"..self.name] = self;
		end
		
		if self.s.Enable then
			self:EnableMouse( not self.s.lock );
			self:SetAlpha(self.s.alpha);
			self:SetWidth(self.s.Width+self.s.Backdrop[6]*2);
			self:SetHeight(self.s.Height+self.s.Backdrop[6]*2);
			self:SetScale(self.s.scale);
			self.header.title:SetFont(self.s.LabelFont,self.s.LabelFontSize);
			self.header.title:SetText(self.displayname..FWL._RIGHTCLICK_FOR_OPTIONS);
			
			FW:SetBackdrop(self.header,unpack(self.s.Backdrop));
			self.header:SetBackdropBorderColor(unpack(self.s.NormalBgColor));
			self.header:SetBackdropColor(unpack(self.s.NormalBgColor));
			
			for g, group in ipairs(self.groups) do
				group:Update();
				for b, bar in ipairs(group.bars) do
					bar:Update();
					for j, tick in ipairs(bar.ticks) do
						tick:Update();
					end
				end
			end
			FW:CorrectPosition(self);
			self:SetFrameStrata(FW.Settings.TimerStrata);
			self:Show();
		else
			self:Hide();
		end
	end
	return frame;
end
function ST:AddTimerFlag(name)
	tinsert(types,name.."Enable");
	tinsert(colors,name.."Color");
end

-- cloning code
local function ST_NewTimerInstance(savename,displayname,from,copy_filters)
	if not instances:find(savename,1) then
		if savename ~= "Timer" then
			if not FW.Settings[savename] then
				FW.Settings[savename] = {};
			end
			FW:CopyCloneSettings(FW.Settings[from or "Timer"],FW.Settings[savename],copy_filters); -- init the config of this instance
		end
		local frame;
		if instances.rows < #instances then
			--FW:Show("recycling");
			local n = instances.rows+1;
			instances[n][1] = savename;
			frame = instances[n][2];
			instances[n][3] = displayname;
			instances.rows = n;
			frame.name = savename;
			frame.displayname = displayname;
		else
			--FW:Show("new instance");
			frame = ST_NewTimerFrame(savename,displayname);
			instances:insert(savename,frame,displayname);
		end
		FW:RegisterFrame(savename,frame,nil,displayname);
	end
end

local function ST_CreateTimerInstance(obj) -- create and permanently SAVE a new frame insatnce
	-- use obj.parent.parent.selected to see what i'm copying from
	local savename;
	local found;
	local n = 0;
	while not savename do
		n = n + 1;
		found = false;
		for k, v in ipairs(FW.Settings.CustomInstances["Timer"]) do
			if v[1] == "Timer"..n then
				found = true;
				break;
			end
		end
		if not found then
			savename = "Timer"..n;
		end
	end
	local displayname = FWL.CLONE..n;
	tinsert(FW.Settings.CustomInstances["Timer"],{savename,displayname}); -- actually save this instance
	ST_NewTimerInstance(savename,displayname,obj.parent.parent.selected,1); -- create the new frame and its options
	FW.Settings[savename].lock = false; -- make sure a new instance is always unlocked!
	obj.parent.parent[5] = savename;
	obj.parent.parent.selected = savename;
	FW:UseProfile(FW.Saved.PROFILE);
end

local function ST_RemoveAllInstances()
	while instances.rows > 1 do -- remove all but the defaut
		FW:UnregisterFrame(instances[2][1]);
		instances:remove(2);
	end
end

local function ST_RemoveTimerInstance(obj) -- permanently delete a SAVED frame instance
	local index = instances:find(obj.savename,1);
	if index then
		instances:remove(index);
		FW.Settings[obj.savename] = nil;
		for i, v in ipairs(FW.Settings.CustomInstances["Timer"]) do
			if v[1] == obj.savename then
				tremove(FW.Settings.CustomInstances["Timer"],i);
				break;
			end
		end
		FW:UnregisterFrame(obj.savename);
	end
	obj.parent.parent[5] = obj.parent.parent[7][1];
	obj.parent.parent.selected = obj.parent.parent[7][1];
	FW:BuildOptions();
	FW:RefreshOptions();
end

local function ST_RenameTimerInstance(obj,displayname)
	for i, v in ipairs(FW.Settings.CustomInstances["Timer"]) do
		if v[1] == obj.savename then
			FW.Settings.CustomInstances["Timer"][i][2] = displayname;
			local index = instances:find(obj.savename,1);
			if index then
				instances[index][2].displayname = displayname;
				instances[index][2]:Update();
			end
			FW:BuildOptions();
			FW:RefreshOptions();
			return;
		end
	end
end

local function ST_SelectTimerInstance(obj)
	obj.parent.parent[5] = obj.savename;
	obj.parent.parent.selected = obj.savename;
	FW:BuildOptions();
	FW:RefreshOptions();
end

local function ST_RemoveTimerInstanceDialog(obj)
	_G.StaticPopupDialogs["FX_CONFIRM_DELETE_CLONE"].obj = obj;
	_G.StaticPopupDialogs["FX_CONFIRM_DELETE_CLONE"].func = ST_RemoveTimerInstance;
	_G.StaticPopup_Show("FX_CONFIRM_DELETE_CLONE");
end

local tab_data = {
	"Timer", -- default selected value
	ST_CreateTimerInstance,
	ST_RemoveTimerInstanceDialog,
	ST_RenameTimerInstance,
	ST_SelectTimerInstance,
	nil,-- tab options table, make sure that this is loaded and updated when a profile is changed
}

local function ST_TimerFilterChange(instance)
	--FW:Show(tostring(instance));
	if instance then
		instance:rebuildLinks();
	else
		local i = 1;
		while i <= st.rows do
			if st[i][6] == DEBUFF or st[i][6] == POWERUP or st[i][6] == SELF_DEBUFF then -- kinda dirty, but it works
				st:remove(i);
			else
				i=i+1;
			end
		end
		ST_PlayerBuffs();
		ST_TargetDebuffs();
		
		rebuildLinks();
	end
end

function ST:TimerGroupEnable()
	ST_TimerFilterChange();
end

function ST:RegisterMeleeBuffs()

	ST:RegisterBuff(32182); -- Heroism
	ST:RegisterBuff(80353); -- Time Warp
	ST:RegisterBuff(2825); -- Bloodlust
	ST:RegisterBuff(33649); -- Rage of the Unraveller
	ST:RegisterBuff(33667); -- Ferocity
	ST:RegisterBuff(34519); -- Time's Favor, Moroes' Lucky Pocket Watch
	ST:RegisterBuff(43738); -- Primal Instinct, Idol of Terror
	ST:RegisterBuff(40464); -- Protector's Vigor, Shadowmoon Insignia
	ST:RegisterBuff(40729); -- Heightened Reflexes, Badge of Tenacity
	ST:RegisterBuff(35166); -- Lust for Battle
	ST:RegisterBuff(28507); -- Haste
	ST:RegisterBuff(35733); -- Ancient Power
	ST:RegisterBuff(32362); -- Burning Hatred
	ST:RegisterBuff(45053); -- Disdain
	ST:RegisterBuff(42084); -- Fury of the Crashing Waves
	ST:RegisterBuff(45401); -- Righteousness
	ST:RegisterBuff(35081); -- Band of the Eternal Champion
	ST:RegisterBuff(43716); -- Call of the Berserker
	ST:RegisterBuff(45040); -- Battle Trance
	ST:RegisterBuff(35476); -- Drums of Battle
	ST:RegisterBuff(35475); -- Drums of War
	ST:RegisterBuff(28093); -- Lightning Speed
	ST:RegisterBuff(20007); -- Holy Strength
	ST:RegisterBuff(57330); -- Horn of Winter (DK raid buff)
	ST:RegisterBuff(60305); -- Heart of a Dragon
	ST:RegisterBuff(60065); -- Reflection of Torment (mirror of thruth procc)
	ST:RegisterBuff(60054); -- Valor Medal of the First War 
	ST:RegisterBuff(60218); -- Essence of Gossamer 
	ST:RegisterBuff(65014); -- Pyrite Infuser
	ST:RegisterBuff(60437); -- Grim Toll
	ST:RegisterBuff(59620); -- Berserk, Enchant Weapon - Berserking
	ST:RegisterBuff(60286); -- Defender's Code
	ST:RegisterBuff(60258); -- Rune of Repulsion
	ST:RegisterBuff(60314); -- Fury of the Five Flights
	ST:RegisterBuff(50263); -- Quickness of the Sailor
	ST:RegisterBuff(64800); -- Wrathstone
	ST:RegisterBuff(64792); -- Blood of the Old God
	ST:RegisterBuff(53908); -- Speed (potion)
	ST:RegisterBuff(28494); -- Insane Strength Potion
	ST:RegisterBuff(60229); -- Greatness, str
	ST:RegisterBuff(60233); -- Greatness, agi	
	ST:RegisterBuff(54758); -- Hyperspeed Acceleration
	ST:RegisterBuff(67383); -- Unholy Force
	ST:RegisterBuff(50198); -- Fatal Flaws
	ST:RegisterBuff(72414); -- Frostforged Defender
	ST:RegisterBuff(72412); -- Frostforged Champion
	ST:RegisterBuff(59626); -- Black Magic
	ST:RegisterBuff(71485); -- Agility of the Vrykul
	ST:RegisterBuff(71487); -- Precision of the Iron Dwarves
	ST:RegisterBuff(71484); -- Strength of the Taunka
	ST:RegisterBuff(71491); -- Aim of the Iron Dwarves
	ST:RegisterBuff(71486); -- Power of the Taunka
	ST:RegisterBuff(71492); -- Speed of the Vrykul
	ST:RegisterBuff(67683); -- Celerity, Shard of the Crystal Heart
	ST:RegisterBuff(67708); -- Paragon
	ST:RegisterBuff(67671); -- Fury
	ST:RegisterBuff(53762); -- Indestructible (potion)
	ST:RegisterBuff(75456); -- Piercing Twilight
	ST:RegisterBuff(75480); -- Scaly Nimbleness
	
	ST:RegisterBuff(79633); -- Tol'vir Agility
	ST:RegisterBuff(79476); -- Volcanic Power
	ST:RegisterBuff(79475); -- Earthen Armor
	ST:RegisterBuff(79634); -- Golem's Strength
	ST:RegisterBuff(92104); -- Fluid Death, River of Death
	
	ST:RegisterBuff(92096); -- Left Eye of Rajh, Eye of Vengeance 
	ST:RegisterBuff(92069); -- Key to the Endless Chamber, Final Key
	ST:RegisterBuff(92126); -- Essence of the Cyclone, Twisted 
	ST:RegisterBuff(92108); -- Unheeded Warning, Heedless Carnage 
	ST:RegisterBuff(92124); -- Prestor's Talisman of Machination, Nefarious Plot 
	ST:RegisterBuff(92052); -- Grace of the Herald, Herald of Doom
	ST:RegisterBuff(91821); -- Crushing Weight, Race Against Death
	ST:RegisterBuff(91816); -- Heart of Rage, Rageheart
	ST:RegisterBuff(55775); -- Enchant Cloak - Swordguard Embroidery
	
	-- IMPORTANT DEBUFFS FROM OTHERS I WANT TO TRACK
	-- Death Knight
	ST:RegisterDebuff(81130); -- Scarlet Fever
	--warrior
 	ST:RegisterDebuff(58567); -- Sunder Armor
	--shaman
	ST:RegisterDebuff(30708); -- Totem of Wrath +3% crit all
	--paladin
	ST:RegisterDebuff(54499); -- Heart of the Crusader +3% crit all
	--druid
	ST:RegisterDebuff(  770); -- Faerie Fire
	ST:RegisterDebuff(33878); -- Mangle - Bear
	ST:RegisterDebuff(33876); -- Mangle - Cat
	ST:RegisterDebuff(46857); -- Trauma
	--rogue
	ST:RegisterDebuff(16511); -- Hemorrhage
	ST:RegisterDebuff(60842); -- Expose Armor
	ST:RegisterDebuff(58684); -- Savage Combat
	
end

function ST:RegisterCasterBuffs()
	ST:RegisterBuff(32182); -- Heroism
	ST:RegisterBuff(80353); -- Time Warp
	ST:RegisterBuff(2825); -- Bloodlust
	ST:RegisterBuff(28779); -- Essence of Sapphiron
	ST:RegisterBuff(23271); -- Ephemeral Power
	ST:RegisterBuff(44605); -- Spell Haste
	ST:RegisterBuff(24659); -- Unstable Power
	ST:RegisterBuff(35163); -- Blessing of the Silver Crescent
	ST:RegisterBuff(34747); -- Recurring Power
	ST:RegisterBuff(34321); -- Call of the Nexus
	ST:RegisterBuff(32108); -- Lesser Spell Blasting
	ST:RegisterBuff(25907); -- Spell Blasting
	ST:RegisterBuff(38348); -- Unstable Currents
	ST:RegisterBuff(35337); -- Spell Power
	ST:RegisterBuff(40396); -- Fel Infusion
	ST:RegisterBuff(33662);	-- Arcane Energy
	ST:RegisterBuff(39441); -- Aura of the Crusader
	ST:RegisterBuff(35084); -- Band of the Eternal Sage
	ST:RegisterBuff(43712); -- Mojo Madness
	ST:RegisterBuff(39530); -- Focus
	ST:RegisterBuff(46783); -- Crimson Serpent
	ST:RegisterBuff(48846); -- Runic Infusion
	ST:RegisterBuff(60064); -- Now is the time!
	ST:RegisterBuff(60492); -- Embrace of the Spider
	ST:RegisterBuff(60479); -- Forge Ember
	ST:RegisterBuff(60494); -- Dying Curse
	ST:RegisterBuff(47240); -- Demonic Pact
	ST:RegisterBuff(60486); -- Illustration of the Dragon Soul
	ST:RegisterBuff(60062); -- The Egg of Mortal Essence
	ST:RegisterBuff(65006); -- Eye of the Broodmother
	ST:RegisterBuff(64707); -- Scale of Fates
	ST:RegisterBuff(64712); -- Living Flame
	ST:RegisterBuff(57663); -- Totem of Wrath +spell dmg
	ST:RegisterBuff(60234); -- Greatness, int
	ST:RegisterBuff(60235); -- Greatness, spi
	ST:RegisterBuff(64411); -- Blessing of Ancient Kings
	ST:RegisterBuff(53909); -- Wild Magic
	ST:RegisterBuff(53908); -- Speed (potion)
	ST:RegisterBuff(67669); -- Elusive Power
	ST:RegisterBuff(54758); -- Hyperspeed Acceleration
	ST:RegisterBuff(55637); -- Lightweave
	ST:RegisterBuff(72416); -- Frostforged Sage
	ST:RegisterBuff(72418); -- Item - Icecrown Reputation Ring Healer Effect
	ST:RegisterBuff(71572); -- Cultivated Power
	ST:RegisterBuff(71601); -- Surge of Power
	--ST:RegisterBuff(71600); -- Surging Power
	ST:RegisterBuff(71564); -- Deadly Precision
	ST:RegisterBuff(59626); -- Black Magic
	ST:RegisterBuff(67683); -- Celerity, Shard of the Crystal Heart
	ST:RegisterBuff(67750); -- Energized
	ST:RegisterBuff(71584); -- Revitalized
	ST:RegisterBuff(71605); -- Siphoned Power
	ST:RegisterBuff(75473); -- Twilight Flames
	ST:RegisterBuff(75494); -- Twilight Renewal
	ST:RegisterBuff(64741); -- Pandora's Plea
	
	ST:RegisterBuff(91138); -- Tear of Blood, Cleansing Tears
	ST:RegisterBuff(91147); -- Blood of Isiset, Blessing of Isiset
	ST:RegisterBuff(91047); -- Stump of Time, Battle Magic
	ST:RegisterBuff(89091); -- Darkmoon Card: Volcano, Volcanic Destruction
	ST:RegisterBuff(91027); -- Heart of Ignacious, Heart's Revelation
	ST:RegisterBuff(91041); -- Heart of Ignacious, Heart's Judgement
	ST:RegisterBuff(74241); -- Enchant Weapon - Power Torrent
	ST:RegisterBuff(91024); -- Theralion's Mirror, Revelation
	
	ST:RegisterBuff(91007); -- Bell of Enraging Resonance, Dire Magic
	
	-- IMPORTANT DEBUFFS FROM OTHERS I WANT TO TRACK
	ST:RegisterDebuff(26017); -- Vindication, Retribution Debuff -10/20% stats on target
	
	ST:RegisterDebuff(51339); -- Decimate +5% dmg
	ST:RegisterDebuff(30708); -- Totem of Wrath +3% crit all
	ST:RegisterDebuff(54499); -- Heart of the Crusader +3% crit all

	ST:RegisterDebuff(33196);-- Misery
	ST:RegisterDebuff( 1490, FW.STACK_DAMAGE_MAGIC,3); -- Curse of the Elements (most 'stable')
	ST:RegisterDebuff(85547, FW.STACK_DAMAGE_MAGIC,3); -- Jinx: Curse of the Elements
	ST:RegisterDebuff(65142, FW.STACK_DAMAGE_MAGIC,2); -- Ebon Plague
	ST:RegisterDebuff(60433, FW.STACK_DAMAGE_MAGIC,1); -- Earth and Moon
	ST:RegisterDebuff(50510); -- Crypt Fever
	
	ST:RegisterDebuff(17800, FW.STACK_CRIT_MAGIC,5); -- Shadow and Flame +5% crit all schools	
	ST:RegisterDebuff(22959, FW.STACK_CRIT_MAGIC,5); -- Improved Scorch, +5% crit all schools
	ST:RegisterDebuff(12579, FW.STACK_CRIT_MAGIC,1); -- Winter's Chill, +1% crit all schools per stack (5max)
	
end

-- Race specific spell and buffs
if FW.RACE == "Draenei" then
	ST:RegisterSpell(59548,	1,015,0,ST.HEAL,000,1);
elseif FW.RACE == "Orc" then
	ST:RegisterBuff(33702);
elseif FW.RACE == "Tauren" then
	ST:RegisterSpell(20549,	0,002,0,ST.UNIQUE);
elseif FW.RACE == "Blood  Elf" then
	ST:RegisterSpell(25046,	0,002,0,ST.UNIQUE);
elseif FW.RACE == "Troll" then
	ST:RegisterBuff(26297);
elseif FW.RACE == "Dwarf" then
	ST:RegisterBuff(20594);
end
ST:RegisterBuff(55503); -- Lifeblood
ST:RegisterBuff(7001); -- Lightwell Renew
	
do
	local PLAYER = FW.PLAYER;
	local select = select;
	local dura = 30;
	
	local function ST_CombatLogEvent(event,...)
		local arg2 = select(2,...);
		--combat_log_active = true;
		if select(4,...) == PLAYER then
			
			if arg2 == "SPELL_PERIODIC_DAMAGE" or arg2 == "SPELL_PERIODIC_MISSED" then
				if FW.Settings.TimerImprove then 
					local arg10 = select(10,...);
					if Track[arg10] and Track[arg10][3]==1 then
						ST_AddDot(select(7,...),select(6,...),arg10);
					end
				end
			elseif arg2 == "SPELL_SUMMON" and (select(9,...) == 71843 or select(9,...) == 71844) then
				local expire = GetTime()+dura;
				local summon_valkyr = FWL.SUMMON_VALKYR or select(7,...);
				st:insert(expire,0,dura,summon_valkyr,0,PET,"Interface\\Icons\\Achievement_Boss_SvalaSorrowgrave",summon_valkyr,2,0,"none",0,PRIOR_NONE,0,1, 0 ,0,"filter",0,expire,dura,1.0,0);
			end
		else
			if arg2 == "UNIT_DIED" then
				ST_MobDies(select(6,...));
			end
		end
	end
	local lspell;
	local function ST_UpdateTest()
		local guid = UnitGUID("target") or "";
		local targetname = UnitName("target") or FWL.NOTARGET;
		local id = CA:GiveID(guid);
		if st.rows<50 then
			lspell = next(Track,lspell);
			if lspell then
				if Track[lspell][1] ~= 1 then
					targetname = lspell;
					id=0;icon=0;guid="none";
				end
				ST:AddNewTimer(
				GetTime()+Track[lspell][2],
				Track[lspell][2],
				targetname,
				lspell,
				CA:Unique("target"),
				id,
				0,
				guid,1.0,0);
			end
		end
	end
	local testing = false;
	function Test(frame)
		if frame then -- to avoid errors on profile change...
			testing = frame.s.Test;
		else
			testing = false;
		end
		for i=1,instances.rows,1 do
			instances[i][2].s.Test = testing; --  copy to all instances
		end
		if testing then
			FW:UnregisterToEvent("UPDATE_MOUSEOVER_UNIT",		ST_MouseOverChanged);
			FW:UnregisterToEvent("UNIT_AURA", 					ST_AuraChanged);
			FW:UnregisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	ST_CombatLogEvent);
			FW:UnregisterTimedEvent("SpellTimerInterval",		ST_ExtraScan);
			FW:UnregisterTimedEvent("SpellTimerInterval",		ST_RemoveDots);
			FW:UnregisterTimedEvent("UpdateInterval",			ST_RaidTargetScan);

			FW:RegisterTimedEvent("SpellTimerInterval",			ST_UpdateTest);		
		else
			FW:UnregisterTimedEvent("SpellTimerInterval",		ST_UpdateTest);
			
			st:erase(); -- remove all timers
			FW:RegisterToEvent("UPDATE_MOUSEOVER_UNIT",			ST_MouseOverChanged);
			FW:RegisterToEvent("UNIT_AURA", 					ST_AuraChanged);
			FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	ST_CombatLogEvent);
			FW:RegisterTimedEvent("SpellTimerInterval",			ST_ExtraScan);
			FW:RegisterTimedEvent("SpellTimerInterval",			ST_RemoveDots);
			FW:RegisterTimedEvent("UpdateInterval",				ST_RaidTargetScan);
			
			ST_PlayerBuffs(); -- add real timers back
			ST_TargetDebuffs();
		end
	end
	
	-- create default timer frame
	ST_NewTimerInstance("Timer",FWL.SPELL_TIMER);
	FW:RegisterLoadClones(function()
		ST_RemoveAllInstances();
		-- add the right ones
		for i, v in ipairs(FW.Settings.CustomInstances["Timer"]) do -- load custom instances
			ST_NewTimerInstance(v[1],v[2]);
		end

	end);
	
	FW:RegisterVariablesEvent(function()
	
		FW:RegisterToEvent("PLAYER_TARGET_CHANGED",			ST_TargetChanged);
		FW:RegisterToEvent("PLAYER_FOCUS_CHANGED",			ST_FocusChanged);
		FW:RegisterToEvent("UPDATE_MOUSEOVER_UNIT",			ST_MouseOverChanged);
		FW:RegisterToEvent("UNIT_AURA", 					ST_AuraChanged); --<-- apparently also needed for powerups
		FW:RegisterToEvent("COMBAT_LOG_EVENT_UNFILTERED",	ST_CombatLogEvent);
		
		FW:RegisterTimedEvent("AnimationInterval",	ST_UpdateSpellTimers);
		FW:RegisterTimedEvent("SpellTimerInterval",	ST_ExtraScan);
		FW:RegisterTimedEvent("SpellTimerInterval",	ST_RemoveDots);
		FW:RegisterTimedEvent("AnimationInterval",	ST_DrawTimers);
		FW:RegisterTimedEvent("UpdateInterval",		ST_RaidTargetScan);
		
		ST_CreateSortOrder();--init sorting direction (advanced settings)
		ST_CalculateMaxDelay();		
		
		tab_data[6] = FW.Settings.CustomInstances.Timer;
	end);
	
	CA:RegisterOnSelfCastFail(ST_SpellFail);
	CA:RegisterOnSelfCastTracked(ST_TrackedSuccess);
	CA:RegisterOnSelfCastEnd(ST_SelfSuccess); -- always triggered regardless of resists
	
	FW:RegisterDelayedLoadEvent(ST_PlayerBuffs);
	
	if CD then
		CD:RegisterOnCooldownUsed(ST_OnCooldownUsed);
		CD:RegisterOnCooldownUpdate(ST_OnCooldownUpdate);
		CD:RegisterOnCooldownReady(ST_OnCooldownReady);
	end
	
	FW:RegisterOnLeaveCombat(function()
		if FW.Settings.RemoveAfterCombat and not UnitIsDeadOrGhost("player") and not FW:UnitHasBuff("player",feign) then --  remove non-player timers when dropped from combat, keep if player died
			ST_ClearMobTimers();
		end
	end);
	FW:AddCommand("u",function(s)
		if s == "trash" then
			ST_Exception(0);
		elseif s == "boss" then
			ST_Exception(1);
		elseif s == "none" then
			ST_Exception(nil);
		end
	end);
	--FW:Show("Timer Module Loaded");
	
	FW:RegisterOnProfileChange(function() tab_data[6] = FW.Settings.CustomInstances.Timer; end);
	FW:RegisterOnProfileChange(ST_TimerFilterChange);
	FW:RegisterOnProfileChange(Test);
	
	FW:RegisterOnProfileChange(ST_CreateSortOrder);
	FW:RegisterOnProfileChange(ST_CalculateMaxDelay);
end

-- create options
FW:SetMainCategory(FWL.SPELL_TIMER,FW.ICON.ST,3,"TIMER","Timer","Timer",tab_data);

	FW:SetSubCategory(FW.NIL,FW.NIL,1,FW.EXPAND);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.ST_HINT1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.ST_HINT2);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.ST_HINT3);
		
	FW:SetSubCategory(FWL.BASIC,FW.ICON.BASIC,2,FW.EXPAND)
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.ENABLE,				FWL.ST_BASIC1_TT ,			"Enable",	ST_TimerShow);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.EXPAND_UP,			FWL.EXPAND_UP_TT,			"Expand",	ST_TimerShow);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_OUTWARDS,		FWL.TIMER_OUTWARDS_TT,		"Outwands");
		--FW:RegisterOption(FW.CHK,1,FW.NON,"Flip bar direction",	"",	"Flip");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TEST_BARS,			FWL.TEST_BARS_TT,			"Test",		Test);
	
	FW:SetSubCategory("Basic layout",FW.ICON.SPECIFIC,3)
		FW:RegisterOption(FW.CHK,1,FW.NON,"Show Count down text",	"",	"Time",		ST_TimerShow);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.COUNTDOWN_ON_RIGHT,	FWL.COUNTDOWN_ON_RIGHT_TT,	"TimeRight",		ST_TimerShow);

		FW:RegisterOption(FW.CHK,1,FW.NON,"Show icons",	"",	"Icon",		ST_TimerShow);
		FW:RegisterOption(FW.CHK,1,FW.NON,"Icon on right",	"",	"IconRight",		ST_TimerShow);
		
		FW:RegisterOption(FW.CHK,1,FW.NON,"Show unit/spell name text",	"",	"Name",		ST_TimerShow);
					
	FW:SetSubCategory(FWL.TIMER_FORMATS,FW.ICON.SPECIFIC,3)
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.DISPLAY_MODES7,	FWL.DISPLAY_MODES7_TT,	"GroupID");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.DISPLAY_MODES8,	FWL.DISPLAY_MODES8_TT,	"ShowID");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.DISPLAY_MODES9,	FWL.DISPLAY_MODES9_TT,	"Spell");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.DISPLAY_MODES10,	FWL.DISPLAY_MODES10_TT,	"Label");
		FW:RegisterOption(FW.MSG,1,FW.NON,FWL.CUSTOM_TAG,		FWL.CUSTOM_TAG_TT,		"CustomTag");
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.EXTRA1,			FWL.EXTRA1_TT,			"RaidTargets",	ST_TimerShow,0,1);	

	FW:SetSubCategory(FWL.SPARKS_AND_GLOW,FW.ICON.GLOW,3);
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.SHOW_SPARK,		FWL.TIMER_SPARK_TT..FWL._EDITBOX_TRANSPARENCY,		"Spark",		ST_TimerShow,0,1);
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.CAST_GLOW,		FWL.CAST_GLOW_TT..FWL._EDITBOX_TRANSPARENCY,		"CastSpark",	ST_TimerShow,0,1);
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.TICKS,			FWL.TICKS_TT..FWL._EDITBOX_TRANSPARENCY,			"Ticks",		ST_HideTicks,0,1);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TICKS_NEXT,		FWL.TICKS_NEXT_TT,		"TicksNext",	ST_HideTicks);

	FW:SetSubCategory(FWL.TIMER_MAXIMUM_TIME,FW.ICON.TIME,3)
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.ONEMAX,			FWL.ONEMAX_TT,			"OneMax");
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.MAXTIME,			FWL.MAXTIME_TT,			"MaxTime",		nil,0);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.FORCEMAX,			FWL.FORCEMAX_TT,		"ForceMax");
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.DISPLAY_TYPES3,	FWL.DISPLAY_TYPES3_TT,	"HideLonger",nil,0);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.DISPLAY_TYPES11,	FWL.DISPLAY_TYPES11_TT,	"HideLongerNoBoss");
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.DISPLAY_TYPES4,	FWL.DISPLAY_TYPES4_TT,	"HideTime",nil,0);
	
	FW:SetSubCategory(FWL.FADING,FW.ICON.FADE,3)
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.FADING3,			FWL.FADING3_TT,			"FadeTime",ST_CalculateMaxDelay,0,120);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.DISPLAY_TYPES6,	FWL.DISPLAY_TYPES6_TT,	"FailTime",ST_CalculateMaxDelay,0,120);
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.FADING1,			FWL.FADING1_TT,			"Blink", nil,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_BG_ALPHA,		FWL.BAR_BG_ALPHA_TT,	"BarBackgroundAlpha",	nil,0,1);		
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.EXPIRED,			FWL.EXPIRED_TT,			"Expired"		);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.HIGHLIGHT,		FWL.FADING5_TT,			"Highlight"		);

	FW:SetSubCategory(FWL.TIMER_UNITS,FW.ICON.UNITS,6)
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_RAID_DEBUFFS,	"",					"RaidDebuffs",	ST_TimerFilterChange);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_SHOW_TARGET,"",						"Target",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_SHOW_FOCUS,	"",						"Focus",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_SHOW_OTHER,	"",						"Other",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_SHOW_UKNOWN,	"",					"UnknownTarget",ST_TimerFilterChange);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.SHOW_WITHOUT_UNIT,	"",					"NoTarget",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.TIMER_SHOW_YOU,		"",					"You",			ST_TimerFilterChange);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.FADING6,			FWL.FADING6_TT,			"NormalAlpha",	nil,0.1,1);		
		
	FW:SetSubCategory(FWL.COLORING_FILTERING,FW.ICON.FILTER,7);
		FW:RegisterOption(FW.FIL,2,FW.LAS,FWL.CUSTOMIZE,		FWL.ST_CUSTOMIZE_TT,	"Filter",		ST_TimerFilterChange, FW.FilterListOptions, FW.STFilterListOptions);
		
	FW:SetSubCategory(FWL.MY_SPELLS,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.NORMAL_TYPE,		FWL.NORMAL_TYPE_TT,		"Magic",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.SHARED_TYPE,		FWL.SHARED_TYPE_TT,		"Curse",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.SHARED_TYPE2,		FWL.SHARED_TYPE2_TT,	"Shared2",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.SHARED_TYPE3,		FWL.SHARED_TYPE3_TT,	"Shared3",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.UNIQUE_TYPE,		FWL.UNIQUE_TYPE_TT,		"Crowd",		ST_TimerFilterChange);
		
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.PET,				FWL.DISPLAY_TYPES10_TT,	"Pet",			ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.FRIENDLY_BUFFS,	FWL.DISPLAY_TYPES9_TT,	"FriendlyBuff",	ST_TimerFilterChange);	
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.HEAL,				FWL.DISPLAY_TYPES8_TT,	"Heal",			ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.DRAIN,			FWL.DRAIN_TT,			"Drain",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.FAIL,				FWL.DISPLAY_TYPES5_TT,	"Fail",			ST_TimerFilterChange);
	
	FW:SetSubCategory(FWL.MY_COOLDOWNS,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.COOLDOWNS,		FWL.COOLDOWNS_TT,		"Cooldowns",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FW.DIS_COL..FWL.ALL_OTHER_COOLDOWNS,		"",				"CooldownsOther",	ST_TimerFilterChange);
		
	FW:SetSubCategory(FWL.BUFFS_DEBUFFS_ON_ME,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA);	
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.POWERUP_BUFFS,	FWL.DISPLAY_TYPES1_TT,	"Buff",				ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FW.DIS_COL..FWL.ALL_OTHER_BUFFS,			"",				"BuffOther",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.DEBUFFS,			FWL.DEBUFFS_TT,			"SelfDebuff",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FW.DIS_COL..FWL.ALL_OTHER_DEBUFFS,			"",			"SelfDebuffOther",	ST_TimerFilterChange);

	FW:SetSubCategory(FWL.RAID_DEBUFFS,FW.ICON.FILTER,7,nil,FW.REDUCED_ALPHA);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.OTHER_DEBUFFS,	FWL.OTHER_DEBUFFS_TT,	"Debuffs",		ST_TimerFilterChange);
		FW:RegisterOption(FW.CO2,1,FW.NON,FW.DIS_COL..FWL.ALL_OTHER_DEBUFFS,			"",			"DebuffsOther",	ST_TimerFilterChange);

	FW:SetSubCategory(FWL.SIZING,FW.ICON.SIZE,8);	
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_WIDTH,					"",					"Width",		ST_TimerShow,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_HEIGHT,					"",					"Height",		ST_TimerShow,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.BAR_SPACING,					"",					"Space",		ST_TimerShow,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.UNIT_SPACING,			FWL.UNIT_SPACING_TT,		"SpacingHeight",nil,0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.UNIT_LABEL_HEIGHT,	FWL.UNIT_LABEL_HEIGHT_TT,	"LabelHeight",	nil,0);
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.COUNTDOWN_WIDTH,		FWL.COUNTDOWN_WIDTH_TT,		"TimeSpace",	ST_TimerShow,nil,0);
		--FW:RegisterOption(FW.CHK,1,FW.NON,FWL.MAXIMIZE_SPACE,		FWL.MAXIMIZE_SPACE_TT,		"MaximizeName",	ST_TimerShow);
		FW:RegisterOption(FW.NU2,1,FW.NON,FWL.MAX_SHOWN,					"",					"Max",			nil,0);	

	FW:SetSubCategory(FWL.APPEARANCE,FW.ICON.APPEARANCE,9);	
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.NORMAL_TEXT,	FWL.NORMAL_TEXT_TT,	"Normal",	ST_TimerShow);
		FW:RegisterOption(FW.COL,1,FW.NON,FWL.FRAME_BACKGROUND,	"",				"NormalBg",	ST_TimerShow);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.TARGET_TEXT,	FWL.TARGET_TEXT_TT,	"Target");
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.FOCUS_TEXT,	FWL.FOCUS_TEXT_TT,	"Focus");		
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.TARGET_BACKGROUND,"",				"TargetBg",	ST_TimerShow);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.FOCUS_BACKGROUND,	"",				"FocusBg",	ST_TimerShow);
		FW:RegisterOption(FW.FNT,2,FW.LAS,FWL.BAR_FONT,			"",				"Font",		ST_TimerShow);
		FW:RegisterOption(FW.FNT,2,FW.LAS,FWL.LABEL_FONT,	FWL.LABEL_FONT_TT,	"LabelFont",ST_TimerShow);
		FW:RegisterOption(FW.TXT,2,FW.LAS,FWL.BAR_TEXTURE,		"",				"Texture",	ST_TimerShow);
		FW:RegisterOption(FW.BAC,2,FW.LAS,FWL.BACKDROP,			"",				"Backdrop",	ST_TimerShow);
	
-- non-intance-specific options
FW:SetMainCategory(FWL.RAID_MESSAGES,FW.ICON.MESSAGE,10,"RAIDMESSAGES");
	FW:SetSubCategory(FW.NIL,FW.NIL,1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.RAID_MESSAGES_HINT2);
		FW:RegisterOption(FW.CHK,2,FW.NON,FWL.SHOW_IN_RAID,		FWL.SHOW_IN_RAID_TT,	"OutputRaid");
		FW:RegisterOption(FW.MSG,2,FW.NON,FWL.SHOW_IN_CHANNEL,	FWL.SHOW_IN_CHANNEL_TT,	"Output");
		
	FW:SetSubCategory(FWL.FADING,FW.ICON.SPECIFIC,2);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.TIME_LEFT_HINT);
		FW:RegisterOption(FW.MS2,2,FW.NON,FWL.TIME_LEFT,			"",	"TimeLeft");
		FW:RegisterOption(FW.MS2,2,FW.NON,FWL.TIME_LEFT_NOTARGET,	"",	"TimeLeftNoTarg");
	
FW:SetMainCategory(FWL.SELF_MESSAGES,FW.ICON.SELFMESSAGE,11,"SELFMESSAGES");
	FW:SetSubCategory(FW.NIL,FW.NIL,1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.SELF_MESSAGES_HINT1);
		
	FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
		FW:RegisterOption(FW.CO2,1,FW.NON,FWL.SHOW_FAILED,	FWL.SHOW_FAILED_TT,"TimerResists");

FW:SetMainCategory(FWL.SOUND,FW.ICON.SOUND,12,"SOUND");
	FW:SetSubCategory(FW.NIL,FW.NIL,1);
		FW:RegisterOption(FW.INF,2,FW.NON,FWL.SOUND_HINT1);
	FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,2);
		FW:RegisterOption(FW.SND,2,FW.NON,FWL.FADE,"","TimerFadeSound");
		FW:RegisterOption(FW.SND,2,FW.NON,FWL.BREAK,"","TimerBreakSound");
		FW:RegisterOption(FW.SND,2,FW.NON,FWL.RESIST,"","TimerResistSound");
		
FW:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT");
	FW:SetSubCategory(FWL.SPELL_TIMER,FW.ICON.DEFAULT,3);
		FW:RegisterOption(FW.MS0,1,FW.NON,FWL.FRAME_LEVEL,FWL.FRAME_LEVEL_TT,	"TimerStrata", ST_TimerShow);
		FW:RegisterOption(FW.NUM,1,FW.NON,"Duration update smoothing",	"1 means timers are changed to their new duration instantly, 20 means a very smooth transition.",		"TimerSmooth",nil,1,20);
		FW:RegisterOption(FW.MS0,2,FW.NON,FWL.TIMER_SORT_ORDER,	FWL.TIMER_SORT_ORDER_TT,	"TimerSortOrder",	ST_CreateSortOrder);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.UPDATE_INTERVAL_SPELL_TIMER,	"",	"SpellTimerInterval",nil,0.1,1.0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.DELAY_DOT_TICKS,				"",	"DotTicksDelayNew",nil,0.5,3.0);
		FW:RegisterOption(FW.NUM,1,FW.NON,FWL.FADING4,	FWL.FADING4_TT,		"TimerFadeSpeed",ST_CalculateMaxDelay,0.0,1.0);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.EXTRA3,	FWL.EXTRA3_TT,		"TimerImprove",		ST_RegisterImproved);
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.EXTRA4,	FWL.EXTRA4_TT,		"TimerImproveRaidTarget");
		FW:RegisterOption(FW.CHK,1,FW.NON,FWL.EXTRA6,	FWL.EXTRA6_TT,		"RemoveAfterCombat");


-- following are used globally
FW.Default.CustomInstances.Timer = {};
FW.Default.TimerFadeSpeed = 0.5;
FW.Default.SpellTimerInterval = 0.20;
FW.Default.DotTicksDelayNew = 1.5; -- max 1.5 sec lag
FW.Default.TimerSmooth = 5;
FW.Default.TimerStrata = FW.Default.Strata;
FW.Default.TimerResistsEnable = true;
FW.Default.TimerResistsColor = 	{1.00,0.00,0.54};

FW.Default.TimerFadeSound = "Sound\\Spells\\ShaysBell.wav";
FW.Default.TimerFadeSoundEnable = true;
FW.Default.TimerFadeSoundVolume = 2;
FW.Default.TimerBreakSound = "Sound\\Spells\\SimonGame_Visual_LevelStart.wav";
FW.Default.TimerBreakSoundEnable = true;
FW.Default.TimerBreakSoundVolume = 4;
FW.Default.TimerResistSound = "Sound\\Spells\\SimonGame_Visual_BadPress.wav";
FW.Default.TimerResistSoundEnable = true;
FW.Default.TimerResistSoundVolume = 1;
FW.Default.TimerInstantSoundEnable = false;
FW.Default.TimerInstantSound = "Sound\\Spells\\ShadowWard.wav";
FW.Default.TimerInstantSoundVolume = 4;
FW.Default.TimerClearcastingSoundEnable = false;
FW.Default.TimerClearcastingSound = "Sound\\Spells\\SimonGame_Visual_GameStart.wav";
FW.Default.TimerClearcastingSoundVolume = 4;

FW.Default.RemoveAfterCombat = false;
FW.Default.TimerImprove = false;
FW.Default.TimerImproveRaidTarget = false;
FW.Default.TimerSortOrder = "buff selfdebuff debuff cooldown notarget target";

--following settings are stored for each instance of a spell timer
FW.Default.Timer = {};

FW.Default.Timer.Test = false;
FW.Default.Timer.Enable = true;
FW.Default.Timer.Max = 15;
FW.Default.Timer.MaxEnable = false;
FW.Default.Timer.Font = FW.Default.Font;
FW.Default.Timer.FontSize = FW.Default.FontSize;
FW.Default.Timer.Texture = FW.Default.Texture;
FW.Default.Timer.ShowID = false;
FW.Default.Timer.GroupID = true;
FW.Default.Timer.IgnoreLong = false;
FW.Default.Timer.Expand = true;
FW.Default.Timer.Background = true;

FW.Default.Timer.Time = true;
FW.Default.Timer.TimeRight = false;
FW.Default.Timer.Icon = true;
FW.Default.Timer.IconRight = false;
FW.Default.Timer.Name = true;

FW.Default.Timer.Flip = false;
FW.Default.Timer.Outwands = true;

FW.Default.Timer.BlinkEnable = true;
FW.Default.Timer.Blink = 3;
FW.Default.Timer.MaximizeName = false;
FW.Default.Timer.HideTime = 2;
FW.Default.Timer.FailTime = 2;
FW.Default.Timer.FadeTime = 1;
FW.Default.Timer.Spell = false;
FW.Default.Timer.Label = false;
FW.Default.Timer.LabelHeight = 18;
FW.Default.Timer.SpacingHeight = 2; -- between groups
FW.Default.Timer.LabelFont = FW.Default.Font;
FW.Default.Timer.LabelFontSize = FW.Default.FontSize;
FW.Default.Timer.RaidTargetsEnable = false;
FW.Default.Timer.RaidTargets = 0.7;
FW.Default.Timer.Target = true;
FW.Default.Timer.Focus = true;
FW.Default.Timer.Other = true;
FW.Default.Timer.NoTarget = true;
FW.Default.Timer.UnknownTarget = true;
FW.Default.Timer.You = true;
FW.Default.Timer.RaidDebuffs = true;

FW.Default.Timer.OneMax = true;
FW.Default.Timer.MaxTimeEnable = true;
FW.Default.Timer.MaxTime = 30;
FW.Default.Timer.ForceMax = false;
FW.Default.Timer.HideLongerEnable = false;
FW.Default.Timer.HideLonger = 30;
FW.Default.Timer.HideLongerNoBoss = false;

FW.Default.Timer.Height = 14;
FW.Default.Timer.Space = 2; -- between units
FW.Default.Timer.Width = 250;
FW.Default.Timer.NormalAlpha = 0.50;
FW.Default.Timer.BarBackgroundAlpha = 0.3;
FW.Default.Timer.TimeSpace = 25;
FW.Default.Timer.TimeSpaceEnable = true;

FW.Default.Timer.Filter = {};

FW.Default.Timer.ExpiredColor = 		{0.50,0.50,0.50,1.00};
FW.Default.Timer.ExpiredEnable = false;
FW.Default.Timer.DrainColor = 		{0.42,0.00,1.00};
FW.Default.Timer.DrainEnable = true;

FW.Default.Timer.CurseColor = 		{0.64,0.21,0.93};
FW.Default.Timer.CurseEnable = true;
FW.Default.Timer.Shared2Color = 		{0.00,0.54,0.42};
FW.Default.Timer.Shared2Enable = true;
FW.Default.Timer.Shared3Color = 		{1.00,0.50,0.00};
FW.Default.Timer.Shared3Enable = true;

FW.Default.Timer.CrowdColor = 		{0.00,1.00,0.50};
FW.Default.Timer.CrowdEnable = true;
FW.Default.Timer.MagicColor = 		{1.00,0.50,0.00};
FW.Default.Timer.MagicEnable = true;
FW.Default.Timer.PetColor = 			{1.00,0.00,0.95};
FW.Default.Timer.PetEnable = true;
FW.Default.Timer.HealColor = 			{0.00,1.00,0.00};
FW.Default.Timer.HealEnable = true;
FW.Default.Timer.FriendlyBuffColor = 	{1.00,1.00,0.00};
FW.Default.Timer.FriendlyBuffEnable = true;
FW.Default.Timer.HighlightColor =		{1.00,1.00,1.00};
FW.Default.Timer.HighlightEnable = true;
FW.Default.Timer.FailColor =			{1.00,0.00,0.30};
FW.Default.Timer.FailEnable = true;

FW.Default.Timer.BuffColor = 			{0.00,0.75,1.00};
FW.Default.Timer.BuffEnable = true;
FW.Default.Timer.BuffOtherColor = 			{0.50,0.50,0.50};
FW.Default.Timer.BuffOtherEnable = false;
FW.Default.Timer.DebuffsColor = 		{0.00,0.36,1.00};
FW.Default.Timer.DebuffsEnable = true;
FW.Default.Timer.DebuffsOtherColor = 		{0.00,0.18,0.50};
FW.Default.Timer.DebuffsOtherEnable = false;
FW.Default.Timer.CooldownsColor =		{1.00,0.39,0.35};
FW.Default.Timer.CooldownsEnable = true;
FW.Default.Timer.CooldownsOtherColor =		{0.50,0.20,0.18};
FW.Default.Timer.CooldownsOtherEnable = false;
FW.Default.Timer.SelfDebuffColor =		{1.00,0.00,0.00};
FW.Default.Timer.SelfDebuffEnable = true;
FW.Default.Timer.SelfDebuffOtherColor =		{0.50,0.00,0.00};
FW.Default.Timer.SelfDebuffOtherEnable = false;

FW.Default.Timer.NormalColor = 	{1.00,1.00,1.00,1.00};
FW.Default.Timer.TimeColor = 	{1.00,1.00,1.00,1.00};
FW.Default.Timer.TargetColor = 	{1.00,1.00,1.00,1.00};
FW.Default.Timer.TargetEnable = false;
FW.Default.Timer.FocusColor = 	{1.00,1.00,0.50,1.00};
FW.Default.Timer.FocusEnable = false;
FW.Default.Timer.NormalBgColor =	{0.00,0.00,0.00,0.50};
FW.Default.Timer.TargetBgColor = {0.00,0.00,0.00,1.00};
FW.Default.Timer.TargetBgEnable = false;
FW.Default.Timer.FocusBgColor = 	{1.00,1.00,0.50,1.00};
FW.Default.Timer.FocusBgEnable = false;

FW.Default.Timer.TicksEnable = true;
FW.Default.Timer.Ticks = 0.3;
FW.Default.Timer.TicksNext = true;

FW.Default.Timer.CastSparkEnable = true;
FW.Default.Timer.CastSpark = 0.3;
FW.Default.Timer.SparkEnable = true;
FW.Default.Timer.Spark = 0.7;

FW.Default.Timer.CustomTagMsg = "id target :: spell stacks";
FW.Default.Timer.CustomTag = false;

FW.Default.Timer.Backdrop = {
	"Interface\\AddOns\\Forte_Core\\Textures\\Background",
	"Interface\\AddOns\\Forte_Core\\Textures\\Border",
	false,16,5,3
}