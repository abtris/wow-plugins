-- don't load if class is wrong
local _, class = UnitClass("player")
if class ~= "PALADIN" then return end

local GetTime = GetTime
local dbg

local db

-- @defines
--------------------------------------------------------------------------------
local gcdId 				= 85256 -- tv for gcd
-- list of spellId
local howId 				=	24275	-- hammer of wrath
local csId 					= 35395	-- crusader strike
local tvId					= 85256	-- templar's verdict
local inqId					= 84963	-- inquisition
local dsId					= 53385	-- divine storm
local jId						= 20271	-- judgement
local consId				= 26573	-- consecration
local exoId					= 879		-- exorcism
local hwId					= 2812 	-- holy wrath
local zealId				= 85696 -- zealotry
local inqId					= 84963 -- inquisition
-- csName to pass as argument for melee range checks
local csName			= GetSpellInfo(csId)
-- buffs
local buffZeal 	= GetSpellInfo(zealId)	-- zealotry
local buffDP		= GetSpellInfo(90174)		-- divine purpose
local buffAoW		= GetSpellInfo(59578)		-- the art of war
local buffInq 	= GetSpellInfo(inqId)		-- inquisition

-- status vars
local s1, s2
local s_ctime, s_otime, s_gcd, s_hp, s_inq, s_zeal, s_aow, s_dp, s_haste, s_targetType
local justCS, justCSHP = 0, 0

-- the queue
local q = {}

local function GetCooldown(id)
	local start, duration = GetSpellCooldown(id)
	local cd = start + duration - s_ctime - s_gcd
	if cd < 0 then return 0 end
	return cd
end

-- actions ---------------------------------------------------------------------
local actions = {
	-- inquisition, apply, 3 hp
	inqa = {
		id = inqId,
		GetCD = function()
			if s_inq <= 0 and (s_hp >= db.inqApplyMin or s_dp > 0) then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100	-- make sure it's not shown for next skill
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "apply Inquisition",
	},
	inqahp = {
		id = inqId,
		GetCD = function()
			if s_inq <= 0 and s_hp >= db.inqApplyMin then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100	-- make sure it's not shown for next skill
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "apply Inquisition at x HP",
	},
	inqadp = {
		id = inqId,
		GetCD = function()
			if s_inq <= 0 and s_dp > 0 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100	-- make sure it's not shown for next skill
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "apply Inquisition at DP",
	},
	inqr = {
		id = inqId,
		GetCD = function()
			if s_inq <= db.inqRefresh and (s_hp >= db.inqRefreshMin or s_dp > 0) then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100	-- make sure it's not shown for next skill
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "refresh Inquisition",
	},
	inqrhp = {
		id = inqId,
		GetCD = function()
			if s_inq <= db.inqRefresh and s_hp >= db.inqRefreshMin then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100	-- make sure it's not shown for next skill
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "refresh Inquisition at x HP",
	},
	inqrdp = {
		id = inqId,
		GetCD = function()
			if s_inq <= db.inqRefresh and s_dp > 0 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_inq = 100	-- make sure it's not shown for next skill
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "refresh Inquisition at DP",
	},
	exoud = {
		id = exoId,
		GetCD = function()
			if (targetType == db.undead or targetType == db.demon) and s_aow > 0 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_aow = 0 -- make sure it's not shown for next skill
		end,
		info = "Exorcism with guaranteed crit",
	},
	exo = {
		id = exoId,
		GetCD = function()
			if s_aow > 0 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
			s_aow = 0 -- make sure it's not shown for next skill
		end,
		info = "Exorcism",
	},
	how = {
		id = howId,
		GetCD = function()
			if IsUsableSpell(howId) and s1 ~= howId then
				return GetCooldown(howId)
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Hammer of Wrath",
	},
	tv = {
		id = tvId,
		GetCD = function()
			if s_hp >= 3 or s_dp > 0 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "Templar's Verdict",
	},
	tvhp = {
		id = tvId,
		GetCD = function()
			if s_hp >= 3 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "Templar's Verdict at 3 HP",
	},
	tvdp = {
		id = tvId,
		GetCD = function()
			if s_dp > 0 then
				return 0
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if s_dp > 0 then s_dp = 0 else s_hp = 0 end -- adjust hp/dp
		end,
		info = "Templar's Verdict at DP",
	},
	cs = {
		id = csId,
		GetCD = function()
			if s_hp >= 3 then return 100 end
			if s1 == csId then
				return (4.5 / s_haste - 1.5)
			else
				return GetCooldown(csId)
			end
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
			if db.predictCS then
				if s_zeal > 0 then
					s_hp = 3
				else
					s_hp = s_hp + 1
				end
			end
		end,
		info = "Crusader Strike",
	},
	j = {
		id = jId,
		GetCD = function()
			if s1 ~= jId then
				return GetCooldown(jId) + db.jClash
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5
		end,
		info = "Judgement",
	},
	hw = {
		id = hwId,
		GetCD = function()
			if s1 ~= hwId then
				return GetCooldown(hwId) + db.hwClash
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Holy Wrath",
	},
	cons = {
		id = consId,
		GetCD = function()
			if s1 ~= consId and UnitPower("player") > db.consMana then
				return GetCooldown(consId) + db.consClash
			end
			return 100
		end,
		UpdateStatus = function()
			s_ctime = s_ctime + s_gcd + 1.5 / s_haste
		end,
		info = "Consecration",
	},
}
clcret.RR_actions = actions
--------------------------------------------------------------------------------

function clcret.RR_UpdateQueue()
	-- get the current db
	db = clcret.db.profile.rotation

	q = {}
	for v in string.gmatch(db.prio, "[^ ]+") do
		if actions[v] then
			table.insert(q, v)
		else
			print("clcret", "invalid action:", v)
		end
	end
	db.prio = table.concat(q, " ")
end

local function GetBuff(buff)
	local left
	_, _, _, _, _, _, expires = UnitBuff("player", buff, nil, "PLAYER")
	if expires then
		left = expires - s_ctime - s_gcd
		if left < 0 then left = 0 end
	else
		left = 0
	end
	return left
end

-- reads all the interesting data
local function GetStatus()
	-- current time
	s_ctime = GetTime()
	
	-- gcd value
	local start, duration = GetSpellCooldown(gcdId)
	s_gcd = start + duration - s_ctime
	if s_gcd < 0 then s_gcd = 0 end
	
	-- the buffs
	s_dp = GetBuff(buffDP)
	s_aow = GetBuff(buffAoW)
	s_zeal = GetBuff(buffZeal)
	s_inq = GetBuff(buffInq)
	
	-- client hp and haste
	s_hp = UnitPower("player", SPELL_POWER_HOLY_POWER)
	s_haste = 1 + UnitSpellHaste("player") / 100
	
	-- adjust hp with + 1 after a cs
	---[[
	if s_ctime - justCS < db.hpDelay then
		if justCSHP == s_hp then
			if s_zeal > 0 then
				s_hp = 3
			else
				s_hp = s_hp + 1
			end
		else
			justCS = 0
		end
	end
	--]]
	
	-- undead/demon -> different exorcism
	s_targetType = UnitCreatureType("target")
end

local function GetNextAction()
	local n = #q
	
	-- parse once, get cooldowns, return first 0
	for i = 1, n do
		local action = actions[q[i]]
		local cd = action.GetCD()
		if cd == 0 then
			return action.id, q[i]
		end
		action.cd = cd
	end
	
	-- parse again, return min cooldown
	local minQ = 1
	local minCd = actions[q[1]].cd
	for i = 2, n do
		local action = actions[q[i]]
		if minCd > action.cd then
			minCd = action.cd
			minQ = i
		end
	end
	return actions[q[minQ]].id, q[minQ]
end

function clcret.RetRotation()
	-- get the current db
	db = clcret.db.profile.rotation

	s1 = nil
	GetStatus()
	local action
	s1, action = GetNextAction()
	s_otime = s_ctime -- save it so we adjust buffs for next
	actions[action].UpdateStatus()
	
	-- adjust buffs
	s_otime = s_ctime - s_otime
	s_dp = max(0, s_dp - s_otime)
	s_aow = max(0, s_aow - s_otime)
	s_zeal = max(0, s_zeal - s_otime)
	s_inq = max(0, s_inq - s_otime)
	
	s2, action = GetNextAction()
	
	return s1, s2
end

local ef = CreateFrame("Frame") 
ef:Hide()
ef:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
ef:SetScript("OnEvent", function(self, event, unit, spell)
	if not db then return end
	if db.predictCS and spell == csName and unit == "player" then
		justCSHP = UnitPower("player", SPELL_POWER_HOLY_POWER)
		if justCSHP < 3 then
			justCS = GetTime()
		end
	end
end)
