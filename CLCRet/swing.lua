local _, trueclass = UnitClass("player")
if trueclass ~= "PALADIN" then return end

local BGTEX = "Interface\\AddOns\\clcret\\textures\\minimalist"

local db

-- ripped from quartz swing code
local COMBATLOG_ME = bit.bor(
	COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001,
	COMBATLOG_OBJECT_REACTION_FRIENDLY or 0x00000010,
	COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100,
	COMBATLOG_OBJECT_TYPE_PLAYER or 0x00000400
)

local swingBar, width
local swingTime = 0
local swingEnd = 0

-- combat log check for swing hit or miss
function clcret:SWING_COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, combatEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if (combatEvent == "SWING_DAMAGE" or combatEvent == "SWING_MISSED") and (bit.band(sourceFlags, COMBATLOG_ME) == COMBATLOG_ME) then
		-- do the swing
		swingTime = UnitAttackSpeed('player')
		swingEnd = GetTime() + swingTime
		swingBar.labelSwing:SetText(('%.1f'):format(swingTime))
	end
end

-- update the position of the bar
function clcret:UpdateSwingBar()
	local remaining = swingEnd - GetTime()
	if remaining <= 0 then
		swingBar:Hide()
		return
	end
		
	swingBar:Show()
	local progress = width * remaining / swingTime - width
	swingBar.texture:SetPoint("RIGHT", swingBar, "LEFT", -progress, 0)
	swingBar.labelTimer:SetText(('%.1f'):format(remaining))
end


-- init the bar elements
function clcret:InitSwingBar()
	local frame = CreateFrame("Frame", "clcretswingBar", clcretFrame)
	frame:Hide()
	
	-- texture
	frame.texture = frame:CreateTexture(nil, "BACKGROUND")
	frame.texture:SetAllPoints()
	frame.texture:SetTexture(BGTEX)
	
	-- background
	frame.bgtexture = frame:CreateTexture(nil, "BACKGROUND")
	frame.bgtexture:SetAllPoints()
	frame.bgtexture:SetVertexColor(0, 0, 0, 0.5)
	frame.bgtexture:SetTexture(BGTEX)

	local fontFace, fontFlags
	
	-- label for swing speed
	frame.labelSwing = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Small")
	frame.labelSwing:SetPoint("LEFT", frame, "LEFT", 1, 1)
	frame.labelSwing:SetJustifyH("LEFT")
	
	-- label for timer
	frame.labelTimer = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Small")
	frame.labelTimer:SetPoint("RIGHT", frame, "RIGHT", -2, 1)

	swingBar = frame
	
	self:UpdateSwingBarLayout()
end


-- update whatever gets changed from options
function clcret:UpdateSwingBarLayout()
	db = clcret.db.profile
	local opt = db.swing
	
	swingBar:SetAlpha(1)
	swingBar.texture:SetVertexColor(unpack(opt.color))
	
	fontFace, _, fontFlags = swingBar.labelSwing:GetFont()
	swingBar.labelSwing:SetFont(fontFace, max(5, opt.height - 1), fontFlags)
	swingBar.labelSwing:SetWidth(max(5, opt.width - 2.2 * opt.height))
	swingBar.labelSwing:SetHeight(max(5, opt.height - 5))
	swingBar.labelTimer:SetFont(fontFace, max(5, opt.height - 1), fontFlags)
	
	swingBar:ClearAllPoints()
	
	swingBar:SetPoint(opt.point, clcretFrame, opt.pointParent, opt.x, opt.y)			
	swingBar:SetWidth(opt.width)
	swingBar:SetHeight(opt.height)
	
	width = opt.width
	
	-- show bar stuff
	swingBar.texture:Show()
	swingBar.bgtexture:Show()
	swingBar.labelSwing:Show()
	swingBar.labelTimer:Show()
end

-- toggle on and off
function clcret:ToggleSwingTimer()
	if db.swing.enabled then
		-- disable
		db.swing.enabled = false
		self:RegisterCLEU()
		
		-- hide the bar
		swingBar:Hide()
	else
		-- enable
		db.swing.enabled = true
		self:RegisterCLEU()
	end
end