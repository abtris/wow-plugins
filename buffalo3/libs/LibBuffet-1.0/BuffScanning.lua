local function print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

local libBuffet = LibStub("LibBuffet-1.0")
local self = libBuffet
---------------------------------------------------------------------------------------------------
-- Compost for buff tables
---------------------------------------------------------------------------------------------------
local cache = setmetatable({}, {__mode='k'})
local function DestroyBuffTable(t)
   t.cycle = nil
    cache[t] = true
end

local function GetBuffTable()
   local t = next(cache)
   if t then
      cache[t] = nil
   else
      t = {}
   end
   return t
end

---------------------------------------------------------------------------------------------------
-- Buff scanning
---------------------------------------------------------------------------------------------------
-- We scan at most this many buffs
local MAX_BUFFS = 40

-- All buffs / debuffs are saved here
libBuffet.buffs = {
   HELPFUL = {},
   HARMFUL = {},
   WEAPONS = {
   },
}

-- If two buffs have the exact same ID (see below), they have to (I hope) be applied at the same 
-- time, so we note the current time with each call to RescanUnit. If we find two buffs with the 
-- same ID within one cycle, they get consolidated.
local currentScanCycle = GetTime()

function libBuffet:ClearUnitBuffs(unitID, filter)
   local unitBuffs = self.buffs[filter][unitID]
   for buffID, buff in pairs(unitBuffs) do
      DestroyBuffTable(buff)
      unitBuffs[buffID] = nil
   end
   self.buffs[filter][unitID] = nil
end

-- Unique identifier for each buff. Unique meaning: same buff, same caster, same expiration
local buffIDTemplate = "%s:%s:%s:%f"
local function GetBuffID(name, rank, casterName, expirationTime)
  return string.format(buffIDTemplate, name, rank, casterName, expirationTime)
end

-- Returns a buff table or nil, if there is no buff at the requested position
function libBuffet:GetBuff(unitID, index, filter)
   if not filter then
      filter = "HELPFUL"
   end
   local unitBuffs = self.buffs[filter][unitID]
   local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitAura(unitID, index, filter)
   if not name then
      return 
   end
   local casterName, casterRealm 
   if unitCaster then
      casterName, casterRealm = UnitName(unitCaster)
   else
      casterName, casterRealm = UNKNOWN, UNKNOWN
   end
   local buffID = GetBuffID(name, rank, casterName, expirationTime)
   local buff = unitBuffs[buffID]
   if buff then
      if buff.cycle ~= currentScanCycle then
         if index ~= buff.index then
            local oldIndex = buff.index
            buff.index = index
            libBuffet:FireBuffIndexChanged(unitID, buff, oldIndex)
         end
         if count ~= buff.count then
            local oldCount = buff.count
            buff.count = count
            libBuffet:FireBuffCountChanged(unitID, buff, oldCount)
         end
         buff.cycle = currentScanCycle
         -- Not a new buff
         return buff
      else
         repeat 
            buffID = buffID.."+"
         until not unitBuffs[buffID]
      end
   end
   buff = GetBuffTable()
   buff.name = name
   buff.rank = rank
   buff.icon = icon
   buff.count = count
   buff.type = debuffType
   buff.duration = duration
   buff.expiration = expirationTime
   buff.casterID = unitCaster
   buff.casterName = casterName
   buff.stealable = isStealable
   buff.id = buffID
   buff.old = nil
   buff.index = index
   buff.unitID = unitID
   buff.filter = filter
   buff.cycle = currentScanCycle
   return buff
end

local EXPIRATION_TIME = 0.5
local filters = {"HELPFUL", "HARMFUL"}
local registeredUnits = libBuffet.registeredUnits
local reasons = libBuffet.reasons
function libBuffet:RescanUnit(unitID)
   if not registeredUnits[unitID] then return end
   currentScanCycle = GetTime()
   for i, filter in ipairs(filters) do
      -- Mark all current buffs as old
      local unitBuffs = self.buffs[filter][unitID]
      for buffID, buff in pairs(unitBuffs) do
         buff.old = true
      end
      -- Scan buffs
      for index=1,MAX_BUFFS do
         local buff = self:GetBuff(unitID, index, filter)
         if not buff then break end
         if buff.old then
            -- buff is still there
            buff.old = nil
         else
            libBuffet:FireBuffAdded(unitID, buff, reasons.buffed)
         end
         unitBuffs[buff.id] = buff
      end
      for buffID, buff in pairs(unitBuffs) do
         if buff.old then
            local _, _, latency = GetNetStats()
            if buff.expiration > 0 and self:GetTimeLeft(buff) <= latency/1000 + EXPIRATION_TIME then
               libBuffet:FireBuffRemoved(unitID, buff, reasons.expired)
            elseif buff.count == 1 then
               libBuffet:FireBuffRemoved(unitID, buff, reasons.charges)
            else
               libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
            end
            unitBuffs[buffID] = nil
            DestroyBuffTable(buff)
         end
      end
   end
end

function libBuffet:FullRescanUnit(unitID)
   if not registeredUnits[unitID] then return end
   self.reasonOverride = unitID
   self:FireRescanBeginning(unitID)
   self:RescanUnit(unitID)
   self:FireRescanFinished(unitID)
   self.reasonOverride = nil
end

local scanTooltip = CreateFrame( "GameTooltip", "LibBuffet-1.0_ScanningTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" )

function libBuffet:GetWeaponEnchantName(slot)
   local inventorySlot
   if slot == 1 then
      inventorySlot = 16
   elseif slot == 2 then
      inventorySlot = 17
   else
      return
   end
   scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
   scanTooltip:SetInventoryItem("player", inventorySlot)
   for i=1,scanTooltip:NumLines() do
      local mytext = getglobal("LibBuffet-1.0_ScanningTooltipTextLeft" .. i)
      local text = mytext:GetText()
      local enchantText = text:match("^(.+) %(%d+ min%)$") or text:match("^(.+) %(%d+ sec%)$") or text:match("^(.+) %(%d+ hour%)$")
      if enchantText then
         scanTooltip:Hide()
         return enchantText
      end
   end

   scanTooltip:Hide()
end

local mainhandBuff = {unitID = "mainhand", filter = "WEAPONS", inventorySlot = 16}
local offhandBuff = {unitID = "offhand", filter = "WEAPONS", inventorySlot = 17}
local weaponBuffs = libBuffet.buffs.WEAPONS
local WEAPONBUFFS_UPDATE_PERIOD = libBuffet.WEAPONBUFFS_UPDATE_PERIOD
function libBuffet:RescanWeaponBuffs()
   local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
   local unitID = "mainhand"
   if hasMainHandEnchant then
      local name = self:GetWeaponEnchantName(1)
      local icon = GetInventoryItemTexture("player", 16)
      local count = mainHandCharges
      local expiration = mainHandExpiration
      -- Let's see which events we have to fire
      local buff = weaponBuffs.mainhand
      local fireBuffAdded
      if not buff then
         fireBuffAdded = true
         buff = mainhandBuff
         weaponBuffs.mainhand = mainhandBuff
      end
      if buff.name and buff.name ~= name then
         libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
         fireBuffAdded = true
      elseif buff.expiration and buff.expiration < expiration then
         libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
         fireBuffAdded = true
      elseif buff.count and buff.count ~= count then
         local oldCount = buff.count
         buff.count = count
         libBuffet:FireBuffCountChanged(unitID, buff, oldCount)
      end
      buff.name = name
      buff.icon = icon
      buff.count = count
      buff.expiration = expiration
      buff.duration = max(buff.duration or 0, libBuffet:GetTimeLeft(buff))
      if fireBuffAdded then
         libBuffet:FireBuffAdded(unitID, buff, reasons.buffed)
      end
   else
      local buff = weaponBuffs.mainhand
      if buff then
         weaponBuffs.mainhand = nil
         local _, _, latency = GetNetStats()
         if buff.expiration > 0 and self:GetTimeLeft(buff) <= latency/1000 + WEAPONBUFFS_UPDATE_PERIOD then
            libBuffet:FireBuffRemoved(unitID, buff, reasons.expired)
         elseif buff.count == 1 then
            libBuffet:FireBuffRemoved(unitID, buff, reasons.charges)
         else
            libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
         end
      end
   end

   unitID = "offhand"
   if hasOffHandEnchant then
      local name = self:GetWeaponEnchantName(2)
      local icon = GetInventoryItemTexture("player", 17)
      local count = offHandCharges
      local expiration = offHandExpiration
      -- Let's see which events we have to fire
      local buff = weaponBuffs.offhand
      local fireBuffAdded
      if not buff then
         fireBuffAdded = true
         buff = offhandBuff
         weaponBuffs.offhand = offhandBuff
      end
      if buff.name and buff.name ~= name then
         libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
         fireBuffAdded = true
      elseif buff.expiration and buff.expiration < expiration then
         libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
         fireBuffAdded = true
      elseif buff.count and buff.count ~= count then
         local oldCount = buff.count
         buff.count = count
         libBuffet:FireBuffCountChanged(unitID, buff, oldCount)
      end
      buff.name = name
      buff.icon = icon
      buff.count = count
      buff.expiration = expiration
      buff.duration = max(buff.duration or 0, libBuffet:GetTimeLeft(buff))
      if fireBuffAdded then
         libBuffet:FireBuffAdded(unitID, buff, reasons.buffed)
      end
   else
      local buff = weaponBuffs.offhand
      if buff then
         weaponBuffs.offhand = nil
         local _, _, latency = GetNetStats()
         if buff.expiration > 0 and self:GetTimeLeft(buff) <= latency/1000 + EXPIRATION_TIME then
            libBuffet:FireBuffRemoved(unitID, buff, reasons.expired)
         elseif buff.count == 1 then
            libBuffet:FireBuffRemoved(unitID, buff, reasons.charges)
         else
            libBuffet:FireBuffRemoved(unitID, buff, reasons.cancelled)
         end
      end
   end

end
