local mod	= DBM:NewMod("Razorgore", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 210 $"):sub(12, -3))
mod:SetCreatureID(12435, 99999)--Bogus detection to prevent invalid kill detection if razorgore happens to die in phase 1
mod:SetMinSyncRevision(168)
mod:RegisterCombat("yell", L.YellPull)
mod:SetWipeTime(45)--guesswork

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_EMOTE",
	"UNIT_DIED"
)

local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnConflagration		= mod:NewTargetAnnounce(23023)

local timerConflagration	= mod:NewTargetTimer(10, 23023)
local timerAddsSpawn		= mod:NewTimer(47, "TimerAddsSpawn", 19879)--Only for start of adds, not adds after the adds heh.

local phase2 = false

function mod:OnCombatStart(delay)
	timerAddsSpawn:Start()
	phase2 = false
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(23023) and args:IsDestTypePlayer() then
		warnConflagration:Show(args.destName)
		timerConflagration:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(23023) then
		timerConflagration:Start(args.destName)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.Phase2Emote or msg:find(L.Phase2Emote) then
		warnPhase2:Show()
		phase2 = true
	end
end

mod.CHAT_MSG_RAID_BOSS_EMOTE = mod.CHAT_MSG_MONSTER_EMOTE -- Not sure which is used yet so for time being support both.

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 12435 and phase2 then--Only trigger kill for unit_died if he dies in phase 2, otherwise it's an auto wipe.
		DBM:EndCombat(self)
	end
end