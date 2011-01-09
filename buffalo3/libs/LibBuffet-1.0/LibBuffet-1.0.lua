---------------------------------------------------------------------------------------------------
-- Setup library
---------------------------------------------------------------------------------------------------
local MAJOR_VERSION = "LibBuffet-1.0"
local MINOR_VERSION = tonumber(("$Revision: 28 $"):match("(%d+)"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub") end

local libBuffet, oldLib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
local self = libBuffet
if not libBuffet then
	return
end

---------------------------------------------------------------------------------------------------
-- Debug stuff
---------------------------------------------------------------------------------------------------
local debug = false

local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message)
end


---------------------------------------------------------------------------------------------------
-- Event firing
---------------------------------------------------------------------------------------------------
libBuffet.events = libBuffet.events or LibStub("CallbackHandler-1.0"):New(libBuffet)

libBuffet.reasons = {
   buffed = "buffed",
   expired = "expired",
   cancelled = "cancelled",
   charges = "charges",
}

function libBuffet:FireBuffAdded(unitID, buff, reason)
   libBuffet.events:Fire("LibBuffet_BuffAdded", unitID, buff, libBuffet.reasonOverride or reason)
end

function libBuffet:FireBuffRemoved(unitID, buff, reason)
   libBuffet.events:Fire("LibBuffet_BuffRemoved", unitID, buff, libBuffet.reasonOverride or reason)
end

function libBuffet:FireRescanBeginning(unitID)
   libBuffet.events:Fire("LibBuffet_RescanBeginning", unitID)
end

function libBuffet:FireRescanFinished(unitID)
   libBuffet.events:Fire("LibBuffet_RescanFinished", unitID)
end

function libBuffet:FireBuffCountChanged(unitID, buff, oldCount)
   libBuffet.events:Fire("LibBuffet_BuffCountChanged", unitID, buff, oldCount)
end

function libBuffet:FireBuffIndexChanged(unitID, buff, oldIndex)
   libBuffet.events:Fire("LibBuffet_BuffIndexChanged", unitID, buff, oldIndex)
end

---------------------------------------------------------------------------------------------------
-- Data access
---------------------------------------------------------------------------------------------------
function libBuffet:BuffIterator(unitID, filter)
   local t = self.buffs[filter][unitID]
   if not t then return pairs({}) end
   if filter == "WEAPONS" then
      return pairs({t})
   end
   return pairs(t)
end

function libBuffet:GetBuffByID(unitID, filter, buffID)
   return self.buffs[filter][unitID][buffID]
end
---------------------------------------------------------------------------------------------------
-- Utility
---------------------------------------------------------------------------------------------------
function libBuffet:GetTimeLeft(buff)
   if buff.filter == "WEAPONS" then
      return buff.expiration / 1000
   else
      return buff.expiration - GetTime()
   end
end

function libBuffet:CancelBuff(buff)
   if buff.filter == "WEAPONS" then
      CancelItemTempEnchantment(buff.inventorySlot - 15)
   else
      CancelUnitBuff(buff.unitID, buff.index, buff.filter)
   end
end

function libBuffet:CopyBuffTable(buff)
   newBuff = {}
   for k,v in pairs(buff) do
      newBuff[k] = v
   end
   return newBuff
end
