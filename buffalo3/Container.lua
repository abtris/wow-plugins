local libBuffet = LibStub:GetLibrary("LibBuffet-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Buffalo3")
local LBF = LibStub("LibButtonFacade", true)

local Container = {}

-- Container Frames --
local GetContainerFrame, DepositContainerFrame = Buffalo3:GetCompost()

-- Container Objects --
local GetContainer, DepositContainer = Buffalo3:GetCompost()

function Container:New(savedVars, containerID)
   local newContainer = GetContainer()
   if not newContainer then 
      newContainer = setmetatable({}, {__index = self})
   end
   newContainer.savedVars = savedVars
   newContainer.id = containerID
   local frame = GetContainerFrame()
   if not frame then
      frame = CreateFrame("Frame", "Buffalo3_Container_"..containerID, UIParent, "Buffalo3ContainerTemplate")
      frame:SetMovable(true)
      frame:SetClampedToScreen(true)
   end
   newContainer.frame = frame
   frame.obj = newContainer
   --newContainer:Setup()
   return newContainer
end

local referenceColors = {
   {r = 0.1, g = 0.6, b = 0.1, a = 0.7},
   {r = 0.8, g = 0.2, b = 0.2, a = 0.7},
}
function Container:Setup()
   local unitIDs = self.savedVars.unitIDs
   local filters = self.savedVars.filter
   self.buttons = self.buttons or {}
   self.buffs = self.buffs or {}
   self.setup = true
   if LBF then
      LBF:RegisterSkinCallback("Buffalo3", Container.OnSkin, self)
      self.lbfGroup = LBF:Group("Buffalo3", self.savedVars.name)
      local style = self.savedVars.style
      self.lbfGroup:Skin(style.skinID, style.gloss, style.backdrop)
   end

   for unitID in pairs(unitIDs) do
      local manualRescanRequired = libBuffet:IsUnitRegistered(unitID)
      libBuffet:RegisterUnitForScanning(unitID)
      if manualRescanRequired then
         for filter in pairs(filters) do
            for buffID, buff in libBuffet:BuffIterator(unitID, filter) do
               if self:ContainsBuff(buff) then
                  self:AddBuff(buff, true)
               end
            end
         end
      end
   end
   self.setup = nil
   self:UpdateFramePosition()
   self:UpdateButtons()
   local frame = self.frame
   frame:Show()
   local color
   if filters["HELPFUL"] then
      color = referenceColors[1]
   else
      color = referenceColors[2]
   end
   frame.reference.pane:SetTexture(color.r, color.g, color.b, color.a)
   frame.reference.title:SetText(self.savedVars.name)
end

function Container:Release()
   local unitIDs = self.savedVars.unitIDs
   for unitID in pairs(unitIDs) do
      libBuffet:UnregisterUnitForScanning(unitID)
   end
   self:TrimBuffButtons(0)
   for i, buff in ipairs(self.buffs) do
      self.buffs[i] = nil
   end
   local frame = self.frame
   frame:Hide()
   DepositContainerFrame(frame)
   self.frame = nil
   if LBF then
      self.lbfGroup:Delete()
   end
   DepositContainer(self)
end

---------------------------------------------------------------------------------------------------
-- Class functions
---------------------------------------------------------------------------------------------------
function Container:AddBuff(buff, holdUpdate)
   if not self.buffs then
      -- This occurs in Buffalo3:SetupContainers, when there are two containers with the same unitIDs
      -- and one's Setup function is called. The events for the newly registered unit are sent out
      -- and propagated to the container that hasn't been set up yet, so there is no buffs table yet.
      -- Just ignoring the event here may be a bit ugly, but it is effective.
      return
   end
   table.insert(self.buffs, buff)
   if not holdUpdate then
      self:UpdateButtons()
   end
end

function Container:ContainsBuff(buff)
   local unitIDs = self.savedVars.unitIDs
   local filter = self.savedVars.filter
   return unitIDs[buff.unitID] and filter[buff.filter]
end

function Container:Disable()
   self.savedVars.enabled = false
   self:Release()
end

local anchorTable = {
   [true] = {
      [true] = "BOTTOMRIGHT",
      [false] = "BOTTOMLEFT",
   },
   [false] = {
      [true] = "TOPRIGHT",
      [false] = "TOPLEFT",
   },
}
function Container:GetAnchor()
   local anchor
   return anchorTable[self:GetGrowUpwards() or false][self:GetGrowLeft() or false]
end

local BUTTON_SIZE = Buffalo3.BuffButton.SIZE
function Container:GetButtonOffset(row, column, width, height)
   local xPadding = self.savedVars.xPadding
   local yPadding = self.savedVars.yPadding
   local scale = self.savedVars.buttonScale
   local x,y
   if self.savedVars.growUpwards then
      y = row*(BUTTON_SIZE + yPadding) - height / scale + BUTTON_SIZE
   else
      y = -row*(BUTTON_SIZE + yPadding)
   end
   if self.savedVars.growLeft then
      x = - column*(BUTTON_SIZE+xPadding) + width / scale - BUTTON_SIZE
   else
      x = column*(BUTTON_SIZE+xPadding)
   end
   return x,y
end

function Container:GetButtonScale()
   return self.savedVars.buttonScale
end

function Container:GetColumns()
   return self.savedVars.columns
end

function Container:GetFlashWarning(value)
   return self.savedVars.flashWarning
end

function Container:GetGrowLeft()
   return self.savedVars.growLeft
end

function Container:GetGrowUpwards()
   return self.savedVars.growUpwards
end

function Container:GetShowTimer(value)
   return self.savedVars.showTimer
end

function Container:GetXPadding()
   return self.savedVars.xPadding
end

function Container:GetYPadding()
   return self.savedVars.yPadding
end

function Container:HideReference()
   self.showingReference = false
   for i, button in ipairs(self.buttons) do
      button:HideReference()
   end
   self:UpdateButtons()
   self.frame.reference:Hide()
end

function Container:OnEnter()
   GameTooltip:SetOwner(self.frame)
   if not self.savedVars.locked then
      GameTooltip:SetText(L["Drag to reposition, right-click to show options"])
   else
      GameTooltip:SetText(L["Buff container is locked. To move it freely, please unanchor it in the options menu."])
   end
end

function Container:OnLeave()
   GameTooltip:Hide()
end

function Container:OnSkin(skinID, gloss, backdrop, group, button, colors)
   if group ~= self.savedVars.name then return end
   local styleOptions = self.savedVars.style
   styleOptions.skinID = skinID
   styleOptions.gloss = gloss
   styleOptions.backdrop = backdrop
   styleOptions.colors = colors
end

function Container:RemoveBuff(buff, holdUpdate)
   for i, myBuff in ipairs(self.buffs) do
      if buff.id == myBuff.id then
         table.remove(self.buffs, i)
      end
   end
   if not holdUpdate then
      self:UpdateButtons()
   end
end

function Container:SavePosition()
   local frame = self.frame
   local anchor = self.savedVars.anchor
   if self.savedVars.anchor.relativeTo ~= "UIParent" then
      return
   end
   if self:GetGrowUpwards() then
      anchor.yOffset = frame:GetBottom()
   else
      anchor.yOffset = frame:GetTop() - UIParent:GetHeight()
   end
   if self:GetGrowLeft() then
      anchor.xOffset = frame:GetRight() - UIParent:GetWidth()
   else
      anchor.xOffset = frame:GetLeft()
   end
end

local anchorTable = {
   [true] = {
      [true] = "BOTTOMRIGHT",
      [false] = "BOTTOMLEFT",
   },
   [false] = {
      [true] = "TOPRIGHT",
      [false] = "TOPLEFT",
   },
}
function Container:SetAnchor(point, relativeTo, relativePoint)
   local anchor = self.savedVars.anchor
   if not point or relativeTo == "UIParent" then
      point = anchorTable[self:GetGrowUpwards() or false][self:GetGrowLeft() or false]
      anchor.point = point
      anchor.relativePoint = point
      anchor.relativeTo = "UIParent"
      self.savedVars.locked = nil
      self:SavePosition()
      self:UpdateFramePosition()
      return
   end
   anchor.point = point
   if type(relativeTo) == "string" then
      anchor.relativeTo = relativeTo
   else
      anchor.relativeTo = relativeTo:GetName()
   end
   anchor.relativePoint = relativePoint
   self.savedVars.locked = true
   self:UpdateFramePosition()
end

function Container:SetAnchorXOffset(offset)
   local anchor = self.savedVars.anchor
   anchor.xOffset = offset
   self:UpdateFramePosition()
end

function Container:SetAnchorYOffset(offset)
   local anchor = self.savedVars.anchor
   anchor.yOffset = offset
   self:UpdateFramePosition()
end

function Container:SetButtonScale(newScale)
   if newScale == self.savedVars.buttonScale then
      return
   end
   self.savedVars.buttonScale = newScale
   self:UpdateButtonPositions()
end

function Container:SetColumns(newColumns)
   if newColumns == self.savedVars.columns then
      return
   end
   self.savedVars.columns = newColumns
   self:UpdateButtonPositions()
end

function Container:SetFlashWarning(value)
   self.savedVars.flashWarning = value
end

function Container:SetGrowHorizontalFirst(growHorizontalFirst)
   self.savedVars.growHorizontalFirst = growHorizontalFirst
   self:UpdateButtonPositions()
end

function Container:SetGrowLeft(growLeft)
   self.savedVars.growLeft = growLeft
   if self.savedVars.anchor.relativeTo == "UIParent" then
      self:SetAnchor()
   end
   self:SavePosition()
   self:UpdateButtonPositions()
end

function Container:SetGrowUpwards(growUp)
   self.savedVars.growUpwards = growUp
   if self.savedVars.anchor.relativeTo == "UIParent" then
      self:SetAnchor()
   end
   self:SavePosition()
   self:UpdateButtonPositions()
end

function Container:SetShowTimer(value)
   self.savedVars.showTimer = value
end

function Container:SetSortBy(value)
   self.savedVars.sortBy = value
   self:UpdateButtons()
end

function Container:SetXPadding(newPadding)
   if newPadding == self.savedVars.xPadding then
      return
   end
   self.savedVars.xPadding = newPadding
   self:UpdateButtonPositions()
end

function Container:SetYPadding(newPadding)
   if newPadding == self.savedVars.yPadding then
      return
   end
   self.savedVars.yPadding = newPadding
   self:UpdateButtonPositions()
end

function Container:ShowDropdown()
   DEFAULT_CHAT_FRAME:AddMessage("Dropdown not yet implemented, please use the GUI (/buffalo3) for now.")
end

local NR_OF_REFERENCE_BUTTONS = 20
function Container:ShowReference()
   self.showingReference = true
   self:TrimBuffButtons(NR_OF_REFERENCE_BUTTONS)
   self:UpdateButtonPositions()
   for i, button in ipairs(self.buttons) do
      button:ShowReference(i)
   end
   self.frame.reference:Show()
end

function Container:StartDrag()
   if self.isMoving or self.savedVars.locked then
      return
   end
   self.isMoving = true
   self.frame:StartMoving()
end

function Container:StopDrag()
   if self.isMoving then
      local frame = self.frame
      frame:StopMovingOrSizing()
      self.isMoving = false
      self:SavePosition()
      self:UpdateFramePosition()
   end
end

local sortFunctions = {
   byName = function(buff1, buff2)
      local name1 = buff1.name
      local name2 = buff2.name
      if not name1 then 
         return false
      end
      if not name2 then
         return true
      end
      return name1 < name2
   end,
   byTime = function(buff1, buff2)
      local expirationTime1 = buff1.expiration
      local expirationTime2 = buff2.expiration
      if expirationTime1 == 0 then
         return false
      end
      if expirationTime2 == 0 then
         return true
      end
      return expirationTime1 < expirationTime2
   end,
}

function Container:SortBuffs()
   table.sort(self.buffs, sortFunctions[self.savedVars.sortBy])
end

function Container:TrimBuffButtons(count)
   local buttons = self.buttons
   while count < #buttons do
      local buffButton = table.remove(buttons)
      if LBF then
         self.lbfGroup:RemoveButton(buffButton.frame, true)
      end
      buffButton:Release()
   end
   local prototype = Buffalo3.BuffButton
   while count > #buttons do
      local button = prototype:New()
      button:SetContainer(self)
      table.insert(buttons, button)
      if LBF then
         self.lbfGroup:AddButton(button.frame, button:GetButtonFacadeTable())
      end
   end
end

function Container:UpdateButtonPositions()
   local frame = self.frame
   if #self.buttons == 0 then
      frame:SetHeight(0)
      frame:SetWidth(0)
      self:UpdateFramePosition()
      return
   end
   local growHorizontalFirst = self.savedVars.growHorizontalFirst
   local columns, rows
   if growHorizontalFirst then
      columns = math.min(self.savedVars.columns, #self.buttons)
      if columns == 0 then columns = 1 end
      rows = max(math.ceil(#self.buttons / columns), 1)
   else
      rows = math.min(self.savedVars.columns, #self.buttons)
      if rows == 0 then rows = 1 end
      columns = max(math.ceil(#self.buttons / rows), 1)
   end
   local buttonScale = self.savedVars.buttonScale
   local buttonSize = BUTTON_SIZE * buttonScale
   local xPadding = self.savedVars.xPadding
   local yPadding = self.savedVars.yPadding
   local width = columns*(buttonSize + xPadding * buttonScale) - xPadding
   local height = rows*(buttonSize + yPadding * buttonScale) - yPadding
   frame:SetHeight(height)
   frame:SetWidth(width)
   self:UpdateFramePosition()
   local column, row
   for i, button in ipairs(self.buttons) do
      button:SetScale(buttonScale)
      button.frame:ClearAllPoints()
      if growHorizontalFirst then
         column = (i-1) % columns
         row = math.floor((i-1) / columns)
      else
         row = (i-1) % rows
         column = math.floor((i-1) / rows)
      end
      local x,y = self:GetButtonOffset(row, column, width, height)
      button.frame:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
      button.frame:SetParent(self.frame)
   end
end

function Container:UpdateButtons()
   if self.showingReference then return end
   self:TrimBuffButtons(#self.buffs)
   self:SortBuffs()
   for i, buff in ipairs(self.buffs) do
      local button = self.buttons[i]
      button:SetBuff(buff)
   end
   self:UpdateButtonPositions()
end

function Container:UpdateFramePosition()
   local frame = self.frame
   frame:ClearAllPoints()
   local anchor = self.savedVars.anchor
   frame:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.xOffset, anchor.yOffset)
end

---------------------------------------------------------------------------------------------------
-- Options
---------------------------------------------------------------------------------------------------
local optionsTemplate = {
   type = "group",
   args = {
      enable = {
         type = "toggle",
         name = L["Enable"],
         desc = L["Enable this container"],
         order = 0,
         set = function(info, value) 
            if value then
               Buffalo3:EnableContainer(name)
            else
               Buffalo3:EnableContainer(name)
            end
         end,
         get = function(info) 
            return containerSV.enabled
         end,
      },
      sort = {
         type = "select",
         name = L["Sort buffs by"],
         order = 5,
         values = {
            byName = L["name"],
            byTime = L["time left"],
         },
         set = function(info, value)
            info.handler:SetSortBy(value)
         end,
         get = function(info) return info.handler.savedVars.sortBy end,
      },
      flashing = {
         type = "toggle",
         name = L["Flash Warning"],
         desc = L["Flash the buff icon when there is only little time left"],
         order = 70,
         set = function(info, value) info.handler:SetFlashWarning(value) end,
         get = function(info) return info.handler:GetFlashWarning() end,
      },
      timer = {
         type = "toggle",
         name = L["Show Timer"],
         desc = L["Show timers beneath the buff"],
         order = 70,
         set = function(info, value) info.handler:SetShowTimer(value) end,
         get = function(info) return info.handler:GetShowTimer() end,
      },
      layout = {
         type = "group",
         name = L["Layout"],
         order = 10,
         inline = true,
         args = {
            buffSize = {
               type = "range",
               name = L["Buff Button Scale"],
               desc = L["Scale of the buff icons"],
               order = 20,
               min = 0.5,
               max = 3.0,
               step = 0.1,
               set = function(info, value) info.handler:SetButtonScale(value) end,
               get = function(info) return info.handler:GetButtonScale() end,
            },
            xPadding = {
               type = "range",
               name = L["Horizontal Padding"],
               desc = L["Horizontal space between buff buttons"],
               order = 20,
               min = -20,
               max = 50,
               step = 1,
               set = function(info, value) info.handler:SetXPadding(value) end,
               get = function(info) return info.handler:GetXPadding() end,
            },
            yPadding = {
               type = "range",
               name = L["Vertical Padding"],
               desc = L["Vertical space between buff buttons"],
               order = 20,
               min = -20,
               max = 50,
               step = 1,
               set = function(info, value) info.handler:SetYPadding(value) end,
               get = function(info) return info.handler:GetYPadding() end,
            },
            columns = {
               type = "range",
               name = L["Columns / Rows"],
               desc = L["Number of columns or rows before a 'linebreak'"],
               order = 20,
               min = 1,
               max = 20,
               step = 1,
               set = function(info, value) info.handler:SetColumns(value) end,
               get = function(info) return info.handler:GetColumns() end,
            },
            growUpwards = {
               type = "toggle",
               name = L["Expand upwards"],
               desc = L["Begin placing buff buttons to the bottom, then stack them up as more buffs are added."],
               order = 60,
               set = function(info, value) info.handler:SetGrowUpwards(value) end,
               get = function(info) return info.handler:GetGrowUpwards() end,
            },
            growLeft = {
               type = "toggle",
               name = L["Expand to the left"],
               desc = L["Begin placing buff buttons to the right, then expand to the left as more buffs are added."],
               order = 70,
               set = function(info, value) info.handler:SetGrowLeft(value) end,
               get = function(info) return info.handler:GetGrowLeft() end,
            },
            growthPrecedence = {
               type = "toggle",
               name = L["Grow horizontally first"],
               desc = L["Place buffs horizontally first, then vertically."],
               order = 70,
               set = function(info, value) info.handler:SetGrowHorizontalFirst(value) end,
               get = function(info) return info.handler.savedVars.growHorizontalFirst end,
            },
         },
      },
      anchoring = {
         type = "group",
         name = L["Anchoring"],
         order = 20,
         inline = true,
         args = {
            relativeTo = {
               type = "select",
               name = L["Anchor to container"],
               desc = L["Attach this container to another one"],
               order = 10,
               values = function(info) return Buffalo3:GetValidAnchors(info.handler) end,
               set = function(info, value)
                  local anchor = info.handler.savedVars.anchor
                  info.handler:SetAnchor(anchor.point, value, anchor.relativePoint) 
               end,
               get = function(info) return info.handler.savedVars.anchor.relativeTo end,
            },
            point = {
               type = "select",
               name = L["Point"],
               desc = L["Anchor point on this container"],
               order = 20,
               values = {
                  TOP = L["Top"],
                  TOPRIGHT = L["Top Right"],
                  RIGHT = L["Right"],
                  BOTTOMRIGHT = L["Bottom Right"],
                  BOTTOM = L["Bottom"],
                  BOTTOMLEFT = L["Bottom Left"],
                  LEFT = L["Left"],
                  TOPLEFT = L["Top Left"],
               },
               set = function(info, value)
                  local anchor = info.handler.savedVars.anchor
                  info.handler:SetAnchor(value, anchor.relativeTo, anchor.relativePoint) 
               end,
               get = function(info) return info.handler.savedVars.anchor.point end,
               disabled = function(info) return info.handler.savedVars.anchor.relativeTo == "UIParent" end,
            },
            relativePoint = {
               type = "select",
               name = L["Other Point"],
               desc = L["Anchor point on the other container"],
               order = 30,
               values = {
                  TOP = L["Top"],
                  TOPRIGHT = L["Top Right"],
                  RIGHT = L["Right"],
                  BOTTOMRIGHT = L["Bottom Right"],
                  BOTTOM = L["Bottom"],
                  BOTTOMLEFT = L["Bottom Left"],
                  LEFT = L["Left"],
                  TOPLEFT = L["Top Left"],
               },
               set = function(info, value)
                  local anchor = info.handler.savedVars.anchor
                  info.handler:SetAnchor(anchor.point, anchor.relativeTo, value) 
               end,
               get = function(info) return info.handler.savedVars.anchor.relativePoint end,
               disabled = function(info) return info.handler.savedVars.anchor.relativeTo == "UIParent" end,
            },
            xOffset = {
               type = "range",
               name = L["Horizontal Offset"],
               order = 40,
               min = -100,
               max = 100,
               step = 1,
               set = function(info, value) info.handler:SetAnchorXOffset(value) end,
               get = function(info) return info.handler.savedVars.anchor.xOffset end,
               disabled = function(info) return info.handler.savedVars.anchor.relativeTo == "UIParent" end,
            },
            yOffset = {
               type = "range",
               name = L["Vertical Offset"],
               order = 50,
               min = -100,
               max = 100,
               step = 1,
               set = function(info, value) info.handler:SetAnchorYOffset(value) end,
               get = function(info) return info.handler.savedVars.anchor.yOffset end,
               disabled = function(info) return info.handler.savedVars.anchor.relativeTo == "UIParent" end,
            },
         },
      },
   },
}

local function getOptionsTemplate(optionsContainer)
   for key, option in pairs(optionsTemplate.args) do
      option.handler = optionsContainer
   end
   return optionsTemplate
end

local function deepCopy(src, dest)
   for key, value in pairs(src) do
      if type(value) == "table" and key ~= "handler" then
         local newDest = dest[key]
         if not newDest then
            newDest = {}
            dest[key] = newDest
         end
         deepCopy(value, newDest)
      else
         dest[key] = value
      end
   end
end

function Container:GetOptions()
   local options = self.options
   if not options then
      options = {}
      deepCopy(getOptionsTemplate(self), options)
      options.name = self.savedVars.name
      self.options = options
   end
   return self.options
end


Buffalo3.Container = Container
