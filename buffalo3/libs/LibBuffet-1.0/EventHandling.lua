local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

local libBuffet = LibStub("LibBuffet-1.0")
local self = libBuffet
---------------------------------------------------------------------------------------------------
-- Event handling of incoming events
---------------------------------------------------------------------------------------------------
libBuffet.events = libBuffet.events or 
  LibStub("CallbackHandler-1.0"):New(libBuffet)

-- Set up frame for event handling. Code blatantly copied from LibMobHealth-4.0
-- (sorry, ckknight!) and modified to better suit our purpose
local frame = CreateFrame("Frame", "LibBuffet-1.0_Frame")

frame:SetScript("OnEvent", function(this, event, ...)
	this[event](libBuffet, ...)
end)

libBuffet.registeredUnits = {}

libBuffet.requiredEventsPerUnit = {
   focus = {
      "UNIT_AURA",
      "PLAYER_FOCUS_CHANGED",
   },
   focustarget = {
      "UNIT_AURA",
      "PLAYER_FOCUS_CHANGED",
      "UNIT_TARGET",
   },
   player = {
      "UNIT_AURA",
   },
   pet = {
      "UNIT_AURA",
      "UNIT_PET",
   },
   pettarget = {
      "UNIT_AURA",
      "UNIT_PET",
      "UNIT_TARGET",
   },
   vehicle = {
      "UNIT_AURA",
      "UNIT_ENTERED_VEHICLE",
   },
   vehicletarget = {
      "UNIT_AURA",
      "UNIT_ENTERED_VEHICLE",
      "UNIT_TARGET",
   },
   target = {
      "UNIT_AURA",
      "PLAYER_TARGET_CHANGED",
   },
   targettarget = {
      "UNIT_AURA",
      "PLAYER_TARGET_CHANGED",
      "UNIT_TARGET",
   },
   mouseover = {
      "UNIT_AURA",
      "UPDATE_MOUSEOVER_UNIT",
   },
   mainhand = {
   },
   offhand = {
   },
}
for i=1,4 do
   libBuffet.requiredEventsPerUnit["party"..i] = {
      "UNIT_AURA",
      "PARTY_MEMBERS_CHANGED",
   }
   libBuffet.requiredEventsPerUnit["party"..i.."target"] = {
      "UNIT_AURA",
      "UNIT_TARGET",
      "PARTY_MEMBERS_CHANGED",
   }
   libBuffet.requiredEventsPerUnit["partypet"..i] = {
      "UNIT_AURA",
      "UNIT_PET",
      "PARTY_MEMBERS_CHANGED",
   }
end
for i=1,40 do
   libBuffet.requiredEventsPerUnit["raid"..i] = {
      "UNIT_AURA",
      "RAID_ROSTER_UPDATE",
   }
   libBuffet.requiredEventsPerUnit["raid"..i.."target"] = {
      "UNIT_AURA",
      "RAID_ROSTER_UPDATE",
   }
   libBuffet.requiredEventsPerUnit["raidpet"..i] = {
      "UNIT_AURA",
      "UNIT_PET",
      "RAID_ROSTER_UPDATE",
   }
end
for i=1,4 do
   libBuffet.requiredEventsPerUnit["arena"..i] = {
      "UNIT_AURA",
      "ARENA_OPPONENT_UPDATE",
   }
   libBuffet.requiredEventsPerUnit["arena"..i.."target"] = {
      "UNIT_AURA",
      "ARENA_OPPONENT_UPDATE",
      "UNIT_TARGET",
   }
end

libBuffet.registeredEventsCounter = {
   PARTY_MEMBERS_CHANGED = 0,
   PLAYER_FOCUS_CHANGED = 0,
   PLAYER_TARGET_CHANGED = 0,
   RAID_ROSTER_UPDATE = 0,
   UNIT_AURA = 0,
   UNIT_ENTERED_VEHICLE = 0,
   UNIT_PET = 0,
   UNIT_TARGET = 0,
   UPDATE_MOUSEOVER_UNIT = 0,
}

function frame:PARTY_MEMBERS_CHANGED()
   for i=1,4 do
      local unitID = "party"..i
      self:FullRescanUnit(unitID)
      local petID = unitID.."pet"
      self:FullRescanUnit(petID)
      local targetID = unitID.."target"
      self:FullRescanUnit(targetID)
   end
end

function frame:PLAYER_FOCUS_CHANGED()
   local unitID = "focus"
   self:FullRescanUnit(unitID)
   local targetID = "focustarget"
   self:FullRescanUnit(targetID)
end

function frame:PLAYER_TARGET_CHANGED()
   local unitID = "target"
   self:FullRescanUnit(unitID)
   local targetID = "targettarget"
   self:FullRescanUnit(targetID)
end

function frame:RAID_ROSTER_UPDATE()
   for i=1,40 do
      local unitID = "raid"..i
      self:FullRescanUnit(unitID)
      local petID = unitID.."pet"
      self:FullRescanUnit(petID)
      local targetID = unitID.."target"
      self:FullRescanUnit(targetID)
   end
end

function frame:UNIT_AURA(unitID)
   self:RescanUnit(unitID)
end

function frame:UNIT_ENTERED_VEHICLE(unitID)
   if unitID ~= "player" then
      return
   end
   local unitID = "vehicle"
   self:FullRescanUnit(unitID)
end

function frame:UNIT_PET(unitID)
   local petID = unitID.."pet"
   self:FullRescanUnit(petID)
end

function frame:UNIT_TARGET(unitID)
   local targetID = unitID.."target"
   self:FullRescanUnit(targetID)
end

function frame:UPDATE_MOUSEOVER_UNIT()
   self:FullRescanOfUnit("mouseover")
end

libBuffet.WEAPONBUFFS_UPDATE_PERIOD = 0.2
local WEAPONBUFFS_UPDATE_PERIOD = libBuffet.WEAPONBUFFS_UPDATE_PERIOD
local timeSinceLastUpdate = 0.0
local function UpdateTempEnchants(frame, elapsed)
   timeSinceLastUpdate = timeSinceLastUpdate + elapsed
   if timeSinceLastUpdate > WEAPONBUFFS_UPDATE_PERIOD then
      timeSinceLastUpdate = 0.0
      libBuffet:RescanWeaponBuffs()
   end
end

function libBuffet:RegisterUnitForScanning(unitID)
   if libBuffet.registeredUnits[unitID] then
      libBuffet.registeredUnits[unitID] = libBuffet.registeredUnits[unitID] + 1
      local requiredEvents = self.requiredEventsPerUnit[unitID]
      for i, eventName in ipairs(requiredEvents) do
         frame:RegisterEvent(eventName)
         self.registeredEventsCounter[eventName] = self.registeredEventsCounter[eventName] + 1
      end
   elseif unitID == "mainhand" or unitID == "offhand" then
      if not libBuffet.registeredUnits["weapons"] then
         frame:SetScript("OnUpdate", UpdateTempEnchants)
         libBuffet.registeredUnits["weapons"] = 0
      end
      libBuffet.registeredUnits["weapons"] = libBuffet.registeredUnits["weapons"] + 1
   else
      local requiredEvents = self.requiredEventsPerUnit[unitID]
      if not requiredEvents then
         error("This unit id is not yet supported by LibBuffet-1.0, please contact the author to fix this.")
         return
      end
      for i, eventName in ipairs(requiredEvents) do
         frame:RegisterEvent(eventName)
         self.registeredEventsCounter[eventName] = self.registeredEventsCounter[eventName] + 1
      end
      self.buffs.HELPFUL[unitID] = {}
      self.buffs.HARMFUL[unitID] = {}
      libBuffet.registeredUnits[unitID] = 1
      self:FullRescanUnit(unitID)
   end
end

function libBuffet:UnregisterUnitForScanning(unitID)
   local requiredEvents = self.requiredEventsPerUnit[unitID]
   if unitID == "offhand" or unitID == "mainhand" then
      unitID = "weapons"
   end
   if not requiredEvents then
      error("This unit id is not yet supported by LibBuffet-1.0, please contact the author to fix this.")
      return
   end
   for i, eventName in ipairs(requiredEvents) do
      self.registeredEventsCounter[eventName] = self.registeredEventsCounter[eventName] - 1
      if self.registeredEventsCounter[eventName] == 0 then
         frame:UnregisterEvent(eventName)
      end
   end
   if libBuffet.registeredUnits[unitID] then
      libBuffet.registeredUnits[unitID] = libBuffet.registeredUnits[unitID] - 1
   else
      return
   end
   if libBuffet.registeredUnits[unitID] == 0 then
      libBuffet.registeredUnits[unitID] = nil
      if unitID == "weapons" then
         libBuffet.buffs.WEAPONS.mainhand = nil
         libBuffet.buffs.WEAPONS.offhand = nil
         frame:SetScript("OnUpdate", nil)
      else
         self:ClearUnitBuffs(unitID, "HELPFUL")
         self:ClearUnitBuffs(unitID, "HARMFUL")
      end
   end
end

function libBuffet:IsUnitRegistered(unitID)
   return self.registeredUnits[unitID] and self.registeredUnits[unitID] > 0
end
