Buffalo3 = LibStub("AceAddon-3.0"):NewAddon("Buffalo3", "AceEvent-3.0")
--Luggage.db = LibStub:GetLibrary("AceDB-3.0"):New("LuggageDB")
local libBuffet = LibStub:GetLibrary("LibBuffet-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Buffalo3")


---------------------------------------------------------------------------------------------------
-- Init and Profiles
---------------------------------------------------------------------------------------------------
function Buffalo3:OnInitialize() 
   Buffalo3.db = LibStub("AceDB-3.0"):New("Buffalo3DB", Buffalo3.defaultOptions)
   LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Buffalo3", Buffalo3.GetOptionsTable)
   LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Buffalo3", "Buffalo3", nil)
end

function Buffalo3:OnEnable()
   libBuffet.RegisterCallback(Buffalo3, "LibBuffet_BuffAdded")
   libBuffet.RegisterCallback(Buffalo3, "LibBuffet_BuffRemoved")
   self.db.RegisterCallback(Buffalo3, "OnProfileChanged")
   self.db.RegisterCallback(Buffalo3, "OnProfileCopied")
   self.db.RegisterCallback(Buffalo3, "OnProfileDeleted")
   self.db.RegisterCallback(Buffalo3, "OnProfileReset")
   SlashCmdList["BUFFALO3"] = function() LibStub("AceConfigDialog-3.0"):Open("Buffalo3") end
   SLASH_BUFFALO31 = "/buffalo3";
   if self.db.profile.disableBlizzardBuffs then
      self:DisableBlizzardBuffs()
   end
   self:SetupContainers()
end

function Buffalo3:OnDisable()
   libBuffet.UnregisterCallback(Buffalo3, "LibBuffet_BuffAdded")
   libBuffet.UnregisterCallback(Buffalo3, "LibBuffet_BuffRemoved")
   if self.db.profile.disableBlizzardBuffs then
      self:EnableBlizzardBuffs()
      self.db.profile.disableBlizzardBuffs = true
   end
   for id, container in pairs(self.containers) do
      container:Disable()
   end
end

function Buffalo3:ReloadAll()
   for id, container in pairs(self.containers) do
      self:DisableContainer(id)
   end
   self:SetupContainers()
end

function Buffalo3:OnProfileChanged()
   self:ReloadAll()
end

function Buffalo3:OnProfileCopied()
   self:ReloadAll()
end

function Buffalo3:OnProfileDeleted()
   self:ReloadAll()
end

function Buffalo3:OnProfileReset()
   self:ReloadAll()
end

---------------------------------------------------------------------------------------------------
-- Event Handling
---------------------------------------------------------------------------------------------------
function Buffalo3:LibBuffet_BuffAdded(event, unitID, buff)
   for name, container in pairs(self.containers) do
      if container:ContainsBuff(buff) then
         container:AddBuff(buff)
      end
   end
end

function Buffalo3:LibBuffet_BuffRemoved(event, unitID, buff)
   for name, container in pairs(self.containers) do
      if container:ContainsBuff(buff) then
         container:RemoveBuff(buff)
      end
   end
end

---------------------------------------------------------------------------------------------------
-- Containers
---------------------------------------------------------------------------------------------------
function Buffalo3:DisableContainer(id)
   local containers = self.containers
   if not containers[id] then
      error("Cannot find container with name \""..id.."\", ignoring disable request")
      return
   end
   local container = containers[id]
   for containerID, otherContainer in pairs(self.containers) do
      if container ~= otherContainer and otherContainer.savedVars.anchor.relativeTo == container.frame:GetName() then
         otherContainer:SetAnchor(nil)
      end
   end
   container:Disable()
   containers[id] = nil
end

function Buffalo3:EnableContainer(id)
   local containers = self.containers
   if containers[id] then
      error("Container with name \""..id.."\" already active")
   end
   local containerOptions = self.db.profile.containers[id]
   if not containerOptions then
      error("Could not find saved variables for container \""..id.."\"")
   end
   containerOptions.enabled = true
   containers[id] = Buffalo3.Container:New(containerOptions, id)
   containers[id]:Setup()
   if self.showingReference then
      containers[id]:ShowReference()
   end
end

Buffalo3.containers = {}
function Buffalo3:SetupContainers()
   local containerOptions = self.db.profile.containers
   local containers = self.containers
   for containerID, savedVars in pairs(containerOptions) do
      if savedVars.enabled then
         containers[containerID] = Buffalo3.Container:New(savedVars, containerID)
      end
   end
   for containerID, container in pairs(containers) do
      container:Setup()
   end
end

---------------------------------------------------------------------------------------------------
-- Options
---------------------------------------------------------------------------------------------------
function Buffalo3:DisableBlizzardBuffs()
   self.db.profile.disableBlizzardBuffs = true
   BuffFrame:Hide()
   TemporaryEnchantFrame:Hide()
end

function Buffalo3:HideReference()
    self.showingReference = nil
    for id, container in pairs(self.containers) do
        container:HideReference()
    end
end

function Buffalo3:EnableBlizzardBuffs()
   self.db.profile.disableBlizzardBuffs = false
   BuffFrame:Show()
   TemporaryEnchantFrame:Show()
end

function Buffalo3:ShowReference()
    self.showingReference = true
    for id, container in pairs(self.containers) do
        container:ShowReference()
    end
end

function Buffalo3:GetValidAnchors(containerToAnchor)
   local validAnchors = {UIParent = L["None"]}
   for containerID, container in pairs(self.containers) do
      local circularAnchoring = container.savedVars.anchor.relativeTo == containerToAnchor.frame:GetName()
      if container ~= containerToAnchor and not circularAnchoring then
         validAnchors[container.frame:GetName()] = container.savedVars.name
      end
   end
   return validAnchors
end

---------------------------------------------------------------------------------------------------
-- Flashing
---------------------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:Show()
local time = 0
local FLASH_FREQUENCY = 4
local MIN_ALPHA = 0.2
local MAX_ALPHA = 0.9
Buffalo3.flashAlpha = 0.2
frame:SetScript("OnUpdate", function(frame, elapsed)
   time = time + elapsed
   Buffalo3.flashAlpha = MIN_ALPHA + (MAX_ALPHA - MIN_ALPHA)*(0.5*math.sin(FLASH_FREQUENCY*time) + 0.5)
end)
