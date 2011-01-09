local libBuffet = LibStub:GetLibrary("LibBuffet-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Buffalo3")

local BuffButton = {}
BuffButton.SIZE = 30

-- Itembutton Frames --
local GetBuffButtonFrame, DepositBuffButtonFrame = Buffalo3:GetCompost()

-- Itembutton Objects --
local GetBuffButton, DepositBuffButton = Buffalo3:GetCompost()

local buffButtonNumber = 0
function BuffButton:New()
   local newButton = GetBuffButton()
   if not newButton then 
      newButton = setmetatable({}, {__index = self})
   end
   local frame = GetBuffButtonFrame()
   if not frame then
      frame = CreateFrame("Button", "Buffalo3_BuffButton_"..buffButtonNumber, nil, "Buffalo3ButtonTemplate")
      frame:SetScript("OnUpdate", BuffButton.OnUpdate)
      frame:RegisterForClicks("RightButtonUp")
      frame:SetHeight(BuffButton.SIZE)
      frame:SetWidth(BuffButton.SIZE)
      buffButtonNumber = buffButtonNumber + 1
   end
   newButton.frame = frame
   frame.obj = newButton
   return newButton
end

function BuffButton:Release()
   self:SetBuff(nil)
   local frame = self.frame
   frame.obj = nil
   frame:SetParent(UIParent)
   frame:ClearAllPoints()
   frame:Hide()
   frame.icon:SetTexture(0.0, 0.0, 0.0, 1.0)
   DepositBuffButtonFrame(frame)
   self.frame = nil
   self.lbfTable = nil
   self.container = nil
   DepositBuffButton(self)
end

---------------------------------------------------------------------------------------------------
-- Class functions
---------------------------------------------------------------------------------------------------

function BuffButton:GetFlashWarning()
   local duration = self.buff.duration
   return (not duration or duration > 0) and self.container.savedVars.flashWarning
end

function BuffButton:GetButtonFacadeTable()
   if self.lbfTable then return self.lbfTable end
   local frame = self.frame
   self.lbfTable = {
      Icon = frame.icon,
      Count = frame.count,
      Border = frame.border,
   }
   return self.lbfTable
end

function BuffButton:GetShowTimer()
   if not self.container.savedVars.showTimer then
      return false
   end
   return self.buff.duration > 0 and SHOW_BUFF_DURATIONS == "1"
end

function BuffButton:Hide()
   local frame = self.frame
   frame:ClearAllPoints()
   frame:SetParent(UIParent)
   frame:Hide()
end

function BuffButton:HideReference()
   self.frame:SetScript("OnUpdate", BuffButton.OnUpdate)
   self:SetBuff(self.buff)
end

function BuffButton:OnClick(button, down)
   local buff = self.buff
   if not buff then return end
   if button == "RightButton" then
      libBuffet:CancelBuff(buff)
   end
end

function BuffButton:OnEnter()
   local buff = self.buff
   if self.container.showingReference then
      self.container:OnEnter()
      return
   end
   GameTooltip:SetOwner(self.frame, "ANCHOR_BOTTOMLEFT")
   if buff.filter == "HELPFUL" or buff.filter == "HARMFUL" then
      GameTooltip:SetUnitAura(buff.unitID, buff.index, buff.filter)
   elseif buff.filter == "WEAPONS" then
      GameTooltip:SetInventoryItem("player", buff.inventorySlot);
   end
end

function BuffButton:OnLeave()
   GameTooltip:Hide()
end

local UPDATE_PERIOD = 0.1
function BuffButton.OnUpdate(frame, elapsed)
   local self = frame.obj
   if self:GetFlashWarning() then
      local buff = self.buff
      local timeLeft = libBuffet:GetTimeLeft(buff)
      if ( timeLeft < BUFF_DURATION_WARNING_TIME ) then
         self.frame:SetAlpha(Buffalo3.flashAlpha)
      else
         self.frame:SetAlpha(1.0)
      end
   end
   self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed
   if self.timeSinceLastUpdate < UPDATE_PERIOD then return end
   self.timeSinceLastUpdate = 0.0
   local buff = self.buff
   if buff.count > 1 then
      self.frame.count:SetText(buff.count)
      self.frame.count:Show()
   else
      self.frame.count:Hide()
   end
   if self:GetShowTimer() then
      local timeLeft = libBuffet:GetTimeLeft(buff)
      local durationText = frame.duration
      durationText:SetFormattedText(SecondsToTimeAbbrev(timeLeft))
      if ( timeLeft < BUFF_DURATION_WARNING_TIME ) then
         durationText:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
      else
         durationText:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      end
      durationText:Show()
   else
      frame.duration:Hide()
   end
end

function BuffButton:SetBuff(buff)
   local frame = self.frame
   self.buff = buff
   if not buff then
      frame.icon:SetTexture(nil)
      frame.count:Hide()
      frame.duration:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      self:Hide()
      return
   end
   self.timeSinceLastUpdate = 0
   self:UpdateBorder()
   frame.icon:SetTexture(buff.icon)
   frame:SetAlpha(1.0)
   frame:Show()
end

function BuffButton:SetContainer(container)
   self.container = container
   self.frame:SetFrameLevel(container.frame:GetFrameLevel() + 1)
end

function BuffButton:SetScale(scale)
   local frame = self.frame
   frame:SetScale(scale)
end

function BuffButton:ShowReference(number)
   local frame = self.frame
   frame:SetAlpha(1.0)
   if not self.buff then
      frame.icon:SetTexture(0.5, 0.5, 0.5, 0.9)
   end
   frame:SetScript("OnUpdate", nil)
   frame.duration:SetText(number)
   frame.duration:Show()
   frame.border:Hide()
   frame.symbol:Hide()
   frame:Show()
end

function BuffButton:UpdateBorder()
   local buff = self.buff
   if not buff then return end
   local frame = self.frame
   if buff.filter == "HELPFUL" then
      frame.border:Hide()
      frame.symbol:Hide()
      return
   end
   frame.border:Show()
   local color
   if buff.filter == "WEAPONS" then
      color = {r = 0.4, g = 0.1, b = 0.4}
   else
      color = DebuffTypeColor[buff.type or "none"]
   end
   frame.border:SetVertexColor(color.r, color.g, color.b)
   if ENABLE_COLORBLIND_MODE == "1" then
      frame.symbol:Show();
      frame.symbol:SetText(DebuffTypeSymbol[debuffType or "none"] or "");
   else
      frame.symbol:Hide();
   end
end

Buffalo3.BuffButton = BuffButton
