--[[
-- Name: TinyTipPositioning
-- Author: Thrae of Maelstrom (aka "Matthew Carras")
-- Release Date:
-- Release Version: 2.0
--
-- Thanks to #wowace, #dongle, and #wowi-lounge on Freenode as always for
-- optimization assistance. Thanks to AF_Tooltip_Mini for the idea that
-- became TinyTip.
--
-- Note: If running TinyTip without TinyTipOptions, see
-- StandAloneConfig.lua for manual configuration options.
--]]

local _G = getfenv(0)

--[[---------------------------------------------
-- Local References
----------------------------------------------]]
local UIParent, GameTooltip = _G.UIParent, _G.GameTooltip

local L = _G.TinyTipLocale

--[[----------------------------------------------------------------------
-- Module Support
------------------------------------------------------------------------]]

local modulecore, name = TinyTip, "TinyTipPositioning"

local module, UpdateFrame, db
if not modulecore then
    module = {}
    module.name, module.localizedname = name, name
else
    local localizedname, reason
    _, localizedname, _, _, _, reason = GetAddOnInfo(name)
    if (not reason or reason ~= "MISSING") and not IsAddOnLoaded(name) then return end -- skip internal loading if module is external
    module = modulecore:NewModule(name)
    module.name, module.localizedname = name, localizedname or name
end

--[[-------------------------------------------------------
-- Event Handling
---------------------------------------------------------]]

local OnUpdateSet
local function OnHide(self,...)
        if OnUpdateSet then self:SetScript("OnUpdate", nil) OnUpdateSet = nil end
end

--[[-------------------------------------------------------
-- Anchoring and Positioning
---------------------------------------------------------]]

-- Used to stick GameTooltip to the cursor with offsets.
local getcpos = _G.GetCursorPosition
local function OnUpdate(self, time)
            local x,y = getcpos()
            local uiscale,tscale = UIParent:GetScale(), GameTooltip:GetScale()
            local tooltip = self.tooltip
            tooltip:ClearAllPoints()
            tooltip:SetPoint(self.Anchor or "BOTTOM", UIParent, "BOTTOMLEFT",
                            (x + self.OffX) / uiscale / tscale,
                            (y + self.OffY) / uiscale / tscale)
end

-- Thanks to cladhaire for most of this one.
-- Used for FAnchor = "SMART"
local function SmartSetOwner(owner, setX, setY, tooltip)
    if not owner then owner = UIParent end
    if not tooltip then tooltip = this end
    if not setX then setX = 0 end
    if not setY then setY = 0 end

    local x,y = owner:GetCenter()
    local left, right = owner:GetLeft(), owner:GetRight()
    local top, bottom = owner:GetTop(), owner:GetBottom()
    local scrWidth, scrHeight = GetScreenWidth(), GetScreenHeight()
    local scale = owner:GetScale()

    -- sanity check
    if x == nil or y == nil or left == nil or right == nil or
       top == nil or bottom == nil or scale == nil or
       scrWidth == nil or scrHeight == nil or
       scrWidth < 0 or scrHeight < 0 then
            return
    end

    setX = setX * scale
    setY = setY * scale
    x = x * scale
    y = y * scale
    left = left * scale
    right = right * scale
    top = top * scale
    bottom = bottom * scale
    local width, anchorPoint = right - left

    if y <= (scrHeight / 2) then
        top = top + setY
        anchorPoint = "TOP"
        if top < 0 then
            setY = setY - top
        end
    else
        setY = -setY
        bottom = bottom + setY
        anchorPoint = "BOTTOM"
        if bottom > scrHeight then
            setY = setY + (scrHeight - bottom)
        end
    end

    if x <= (scrWidth / 2) then
        left = left + setX
        if anchorPoint == "BOTTOM" then
            anchorPoint = anchorPoint.."RIGHT"
            setX = setX - width
            if (left < 0) then
                setX = setX - left
            end
        else
            anchorPoint = anchorPoint.."LEFT"
            if left < 0 then
                setX = setX - left
            end
        end
    else
        setX = -setX
        right = right + setX
        if anchorPoint == "BOTTOM" then
            anchorPoint = anchorPoint.."LEFT"
            setX = setX + width
            if (right > scrWidth) then
                setX = setX - (right - scrWidth)
            end
        else
            anchorPoint = anchorPoint.."RIGHT"
            if (right > scrWidth) then
                setX = setX + (scrWidth - right)
            end
        end
    end

    scale = tooltip:GetScale()
    tooltip:ClearAllPoints()
    tooltip:SetOwner(owner, "ANCHOR_"..anchorPoint, setX / scale, setY / scale)
end

local OriginalGameTooltipSetDefaultAnchor = nil
local function SetDefaultAnchor(tooltip,owner,...)
    if OnUpdateSet then UpdateFrame:SetScript("OnUpdate", nil) end
    if module.onstandby then
        return
    end

    local Anchor, CAnchor, OffX, OffY
    if tooltip == GameTooltip then
        if owner ~= UIParent then -- frame units
            if (not db["HideInFrames"] and type(owner.GetUnit) == "function") or not owner.GetUnit then
                if InCombatLockdown() then -- in combat
                    if not db["HideInCombat"] then
                        Anchor, OffX, OffY = db["CFAnchor"] or db["FAnchor"] or "GAMEDEFAULT", db["CFOffX"] or db["FOffX"] or 0, db["CFOffY"] or db["FOffY"] or 0
                    end
                else
                    Anchor, OffX, OffY = db["FAnchor"] or "GAMEDEFAULT", db["FOffX"] or 0, db["FOffY"] or 0
                end
            end
            CAnchor = db["FCursorAnchor"]
        else
            if InCombatLockdown() then
                if not db["HideInCombat"] then
                    Anchor, OffX, OffY = db["MFAnchor"] or db["MAnchor"] or "CURSOR", db["MFOffX"] or db["MOffX"] or 0, db["MFOffY"] or db["MOffY"] or 0
                end
            else
                Anchor, OffX, OffY = db["MAnchor"] or "CURSOR", db["MOffX"] or 0, db["MOffY"] or 0
            end
            CAnchor = db["MCursorAnchor"]
        end
    elseif db["EtcAnchor"] or db["EtcOffX"] or db["EtcOffY"] then
        Anchor, OffX, OffY = db["EtcAnchor"] or "GAMEDEFAULT", db["EtcOffX"] or 0, db["EtcOffY"] or 0
    end

    if not Anchor or not OffX or not OffY then return end -- sanity / disabled check

    if Anchor == "CURSOR" then
        if OffX ~= 0 or OffY ~= 0 or CAnchor then
            UpdateFrame.OffX, UpdateFrame.OffY, UpdateFrame.Anchor, UpdateFrame.tooltip = OffX, OffY, CAnchor, tooltip
            UpdateFrame:SetScript("OnUpdate", OnUpdate)
            OnUpdateSet = true
        else
            tooltip:SetOwner(owner, "ANCHOR_CURSOR")
        end
    elseif Anchor == "SMART" then
        SmartSetOwner(owner, OffX, OffY, tooltip)
    else
        tooltip:SetOwner(owner, "ANCHOR_NONE")
        tooltip:ClearAllPoints()
        tooltip:SetPoint((Anchor ~= "GAMEDEFAULT" and Anchor) or "BOTTOMRIGHT",
                          UIParent,
                         (Anchor ~= "GAMEDEFAULT" and Anchor) or "BOTTOMRIGHT",
                          OffX - ((Anchor == "GAMEDEFAULT"
                         and (CONTAINER_OFFSET_X - 13)) or 0),
                         OffY + ((Anchor == "GAMEDEFAULT" and CONTAINER_OFFSET_Y) or 0))
    end
end

--[[-------------------------------------------------------
-- Initialization States
----------------------------------------------------------]]


function module:ReInitialize(_db)
    db = _db or db
end

function module:Standby()
end
--]]

-- For initializing the database and hooking functions.
local hookedSetDefaultAnchor = nil
function module:Initialize()
    db = ( modulecore and modulecore:GetDB() ) or TinyTip_StandAloneDB or {}

    if not hookedSetDefaultAnchor then
        hooksecurefunc("GameTooltip_SetDefaultAnchor", SetDefaultAnchor)
        hookedSetDefaultAnchor = true
    end
end

-- Setting variables that only need to be set once goes here.
function module:Enable()
    self:ReInitialize()
end

-- TinyTipModuleCore NOT loaded
local EventFrame
if not modulecore then
    local function OnEvent(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == module.name then
            module:Initialize()
            if not module.loaded then
                module:Enable()
            end
            self:UnregisterEvent("ADDON_LOADED")
        elseif event == "PLAYER_LOGIN" then
                module.loaded = true
                module:Enable()
        end
    end
    EventFrame = CreateFrame("Frame", nil, GameTooltip)
    EventFrame:RegisterEvent("ADDON_LOADED")
    EventFrame:RegisterEvent("PLAYER_LOGIN")
    EventFrame:SetScript("OnEvent", OnEvent)
    UpdateFrame = EventFrame

else
    UpdateFrame = CreateFrame("Frame", nil, GameTooltip)
end

-- Update frame used for GameTooltip-related update and handler scripts
UpdateFrame:SetScript("OnHide", OnHide)
UpdateFrame:Show()

