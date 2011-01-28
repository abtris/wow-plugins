
--[[
local UnitBuffs = {}
local UnitDebuffs = {}
local UnitAuras = {}
--]]
local aurafont = "Interface\\Addons\\TidyPlates\\Media\\DefaultFont.ttf"
-- This Table stores the widget by ID'd GUID, so falloffs can be updated.
local WidgetList_GUID = {}


----------------------
-- PolledHideIn() - Registers a callback, which polls the frame until it expires, then hides the frame and removes the callback
----------------------
local PolledHideIn
do
	local Framelist = {}			-- Key = Frame, Value = Expiration Time
	local Watcherframe = CreateFrame("Frame")
	local WatcherframeActive = false
	local select = select
	local timeToUpdate = 0
	
	local function CheckFramelist(self)
		local curTime = GetTime()
		if curTime < timeToUpdate then return end
		local framecount = 0
		timeToUpdate = curTime + 1
		-- Cycle through the watchlist, hiding frames which are timed-out
		for frame, expiration in pairs(Framelist) do
			-- If expired...
			--print("Exp", expiration)
			if expiration < curTime then frame:Hide(); Framelist[frame] = nil
			-- If active...
			else 
				-- Update the frame
				frame:Update(expiration)
				framecount = framecount + 1 
			end
		end
		-- If no more frames to watch, unregister the OnUpdate script
		if framecount == 0 then Watcherframe:SetScript("OnUpdate", nil); WatcherframeActive = false end
	end
	
	function PolledHideIn(frame, expiration)
	
		if expiration == 0 then 
			
			frame:Hide()
			Framelist[frame] = nil
		else
			--print("Hiding in", expiration - GetTime())
			Framelist[frame] = expiration
			frame:Show()
			
			if not WatcherframeActive then 
				Watcherframe:SetScript("OnUpdate", CheckFramelist)
				WatcherframeActive = true
			end
		end
	end
end


------------------------------
-- Debuff Falloff Watcher
------------------------------

-- Watcher Frame
local WatcherFrame = CreateFrame("Frame", nil, WorldFrame )
local isEnabled = false
WatcherFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
WatcherFrame:RegisterEvent("UNIT_AURA")
WatcherFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
			
-- GUID/UnitID Lookup List
local updateCap = 1
local lastUpdate = 0
local isEnabled = false

local function WatcherFrameHandler(frame, event, ...)
	
	-- UNIT_AURA & UNIT_SPELLCAST_SUCCEEDED
	local unitid
	if event == "UNIT_AURA" then 
		unitid = ...
		if unitid == "target" then
			TidyPlates:Update()		-- General Update for Target	-- To do: Direct GUID Update
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		unitid = ...
		if unitid == "player" then
			TidyPlates:Update()		-- General Update for Mouseover or Target	-- To do: Direct GUID Update
		end
	end
		
	-- COMBAT_LOG_EVENT_UNFILTERED
	local timestamp, combatevent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellid, spellname = ...
	local WorkingAuraFrame, AuraIconIndex, AuraIconFrame
	
	if combatevent == "SPELL_AURA_REMOVED" then
		WorkingAuraFrame = WidgetList_GUID[destGUID]
		if WorkingAuraFrame then
			for AuraIconIndex, AuraIconFrame in pairs(WorkingAuraFrame.AuraFrames) do
				if AuraIconFrame.auraName == spellname then AuraIconFrame:Hide() end				
			end
		end
	end
end


		
-- Manual Hard-Enable
--WatcherFrame:SetScript("OnEvent", WatcherFrameHandler); isEnabled = true
-- [[
local function EnableAuraWatcher(arg)
	if arg then 
		WatcherFrame:SetScript("OnEvent", WatcherFrameHandler); isEnabled = true
	else WatcherFrame:SetScript("OnEvent", nil); isEnabled = false end
end
--]]




----------------------
-- Debuff Frame
----------------------
do
	
	-- Update an Aura Icon  (Polled by PolledHideIn)
	local function UpdateAuraIconFrame(frame, expiration)
		local timeleft = expiration-GetTime()
		local green, yellow, red = "|cFF84FF00", "|cFFFFB400", "|cFFFF0000"
		local textcolor
		if timeleft > 60 then frame.TimeLeft:SetText(green..ceil(timeleft/60).."m")
		else 
			if timeleft < 3 then textcolor = red 
			elseif timeleft < 5 then textcolor = yellow
			else textcolor = green end
			frame.TimeLeft:SetText(textcolor..ceil(timeleft)) 
		end
		-- This is where the text gets changed, coloring, and any scaling get done
	end

	local AuraBorderArt = "Interface\\AddOns\\TidyPlates\\widgets\\Aura\\AuraFrame"				-- FINISH ART
	local AuraGlowArt = "Interface\\AddOns\\TidyPlates\\widgets\\Aura\\AuraGlow"	
	local AuraTestArt = ""
	
	-- Create an Aura Icon
	local function CreateAuraIconFrame(parent)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetWidth(26); frame:SetHeight(14)
		
		-- Icon
		frame.Icon = frame:CreateTexture(nil, "BACKGROUND")
		frame.Icon:SetAllPoints(frame)
		--frame.Icon:SetTexCoord(.07, 1-.07, .23, 1-.23)  -- obj:SetTexCoord(left,right,top,bottom)
		frame.Icon:SetTexCoord(.07, 1-.07, .23, 1-.23)  -- obj:SetTexCoord(left,right,top,bottom)
		-- Border
		frame.Border = frame:CreateTexture(nil, "ARTWORK")
		frame.Border:SetWidth(32); frame.Border:SetHeight(32)
		frame.Border:SetPoint("CENTER", 1, -2)
		frame.Border:SetTexture(AuraBorderArt)
		-- Glow
		--frame.Glow = frame:CreateTexture(nil, "ARTWORK")
		--frame.Glow:SetAllPoints(frame.Border)
		--frame.Glow:SetTexture(AuraGlowArt)
		--  Time Text
		frame.TimeLeft = frame:CreateFontString(nil, "OVERLAY")
		frame.TimeLeft:SetFont(aurafont,9, "OUTLINE")
		frame.TimeLeft:SetShadowOffset(1, -1)
		frame.TimeLeft:SetShadowColor(0,0,0,1)
		frame.TimeLeft:SetPoint("RIGHT", 0, 8)
		frame.TimeLeft:SetWidth(26)
		frame.TimeLeft:SetHeight(16)
		frame.TimeLeft:SetJustifyH("RIGHT")
		--  Stacks
		frame.Stacks = frame:CreateFontString(nil, "OVERLAY")
		frame.Stacks:SetFont(aurafont,10, "OUTLINE")
		frame.Stacks:SetShadowOffset(1, -1)
		frame.Stacks:SetShadowColor(0,0,0,1)
		frame.Stacks:SetPoint("RIGHT", 0, -6)
		frame.Stacks:SetWidth(26)
		frame.Stacks:SetHeight(16)
		frame.Stacks:SetJustifyH("RIGHT")
		-- Information about the currently displayed aura
		frame.AuraInfo = {	
			Name = "",
			Icon = "",
			Stacks = 0,
			Expiration = 0,
			Type = "",
		}		
		frame.Update = UpdateAuraIconFrame
		frame:Hide()
		--frame:Show()
		return frame
	end
	
	--[[
	-- Debuff Colored Glow (not yet implemented)
	local DebuffColor = {
		Magic	= { r = 0.20, g = 0.60, b = 1.00 },
		Curse	= { r = 0.60, g = 0.00, b = 1.00 },
		Disease = { r = 0.60, g = 0.40, b = 0 },
		Poison = { r = 0.00, g = 0.60, b = 0 },
	}
	
	local function GetDebuffColor(dispellType)
		local color = DebuffColor[dispellType]
		if color then return color.r, color.g, color.b 
		else return 0,0,0,0 end
	end
	--]]
	
	-- Default Filter Function
	local auraDurationFilter = 600
	local function DefaultFilterFunction(debuff, unit) 
		if (debuff.duration < auraDurationFilter) then
			return true
		end
	end
	
	-- Search for Debuffs on a Unit
	local aura = {}
	local function UpdateWidget(frame, unit)	
		if unit.reaction == "FRIENDLY" then return end
		
		local unitid, expireTime
		local AuraFrames = frame.AuraFrames
		local AuraIconFrame
		-- AuraIconFrame, AuraFrame
		local auraCount = 0
		
		if unit.isTarget then unitid = "target"
		elseif unit.isMouseover then unitid = "mouseover" end
		
		if unitid then	-- unit.guid == UnitGUID(unitid)
			-- Reset Aura Frames and make sure the Widget is Shown
			for index = 1, 8 do	AuraFrames[index]:Hide() end
			frame:Show()
			
			-- Check the UnitIDs Debuffs
			for index = 1, 40 do
				-- Get Debuff Info
				local name, rank, icon, count, dispelType, duration, expires, caster, isStealable = UnitDebuff(unitid, index ,"PLAYER")
				--local name, rank, icon, count, dispelType, duration, expires, source, isStealable = UnitDebuff(unitid, index)
				
				-- Setup Aura Info Table
				aura.name, aura.rank, aura.icon, aura.count = name, rank, icon, count
				aura.dispelType, aura.duration, aura.expires = dispelType, duration, expires
				-- aura.source = source
				--aura.target, aura.targetguid = unit.name, unit.guid			
				
				if name and icon and frame.Filter(aura) then 
					auraCount = auraCount + 1
					AuraIconFrame = AuraFrames[auraCount]
					-- Send to Aura Display...
					
					AuraIconFrame.Icon:SetTexture(icon)
					if count > 1 then AuraIconFrame.Stacks:SetText(count)
					else  AuraIconFrame.Stacks:SetText("") end
					
					-- Store the aura info right on the icon frame
					AuraIconFrame.auraName = name
					AuraIconFrame.auraExpiration = expires
					AuraIconFrame.auraStacks = count
					AuraIconFrame.auraIcon = icon
					
					PolledHideIn(AuraIconFrame,expires)
					if auraCount > 7 then return end
				end
				
			end	
		elseif not unit.guid then
			frame:Hide()
		end

	end
	
	---------------------------------------------------------------
	--- Widget Link ...
	---------------------------------------------------------------
	-- Context Update (mouseover, target change)
	local function UpdateWidgetContext(frame, unit)
		-- Context Update
		local guid = unit.guid
		if guid then WidgetList_GUID[guid] = frame end
		frame.guid = guid
		frame.unit = unit

		-- Update widget *now*, depending on context
		if unit.isTarget or unit.isMouseover then
			UpdateWidget(frame, unit)
		end
	end

	local function ClearWidgetContext(frame)
		frame.unit = nil
		local guid = frame.guid
		if guid then
			WidgetList_GUID[guid] = nil
			frame.guid = nil
		end
	end

	---------------------------------------------------------------
	-- End "Widget Link" Code
	---------------------------------------------------------------
	
	-- Create the Main Widget Body and Icon Array
	local function CreateAuraWidget(parent)	
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetWidth(128); frame:SetHeight(32); frame:Show()
		frame.AuraFrames = {}
		local AuraFrames = frame.AuraFrames
		-- Create Aura Frames
		for index = 1, 8 do AuraFrames[index] = CreateAuraIconFrame(frame);  end
		-- Set Anchors, first row	
		AuraFrames[1]:SetPoint("LEFT", frame)
		for index = 2, 3 do AuraFrames[index]:SetPoint("LEFT", AuraFrames[index-1], "RIGHT", 5, 0) end
		-- .. second row
		AuraFrames[4]:SetPoint("BOTTOMLEFT", AuraFrames[1], "TOPLEFT", 0, 8)
		for index = 5, 6 do AuraFrames[index]:SetPoint("LEFT", AuraFrames[index-1], "RIGHT", 5, 0) end
		
		-- If the plate gets hidden, the icons reset to prevent mis-anchoring on a different unit
		frame:SetScript("OnHide", function() for index = 1, 4 do PolledHideIn(AuraFrames[index], 0) end end)	
		frame.Filter = DefaultFilterFunction

		--	Functions
		frame.UpdateContext = UpdateWidgetContext
		frame.Update = UpdateWidgetContext
		frame._Hide = frame.Hide
		frame.Hide = function() ClearWidgetContext(frame); frame:_Hide() end
		
		if not isEnabled then EnableAuraWatcher(true) end
		return frame
	end
	
	TidyPlatesWidgets.CreateAuraWidget = CreateAuraWidget
end


