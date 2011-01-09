local mod	= DBM:NewMod("Ripsnarl", "DBM-Party-Cataclysm", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4518 $"):sub(12, -3))
mod:SetCreatureID(47626)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEvents(
)