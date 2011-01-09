-- Globals
TITAN_PANEL_PLACE_TOP = 1;
TITAN_PANEL_PLACE_BOTTOM = 2;
TITAN_PANEL_PLACE_BOTH = 3;
TITAN_PANEL_MOVING = 0;

-- Locals
local TITAN_PANEL_DROPOFF_ADDON = nil;
local TITAN_PANEL_MOVE_ADDON = nil

local TitanMovableModule = LibStub("AceAddon-3.0"):NewAddon("TitanMovable", "AceHook-3.0", "AceTimer-3.0")
local _G = getfenv(0);
local InCombatLockdown	= _G.InCombatLockdown;

--Determines the optimal magic number based on resolution
local menuBarTop = 55;
local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)");
if ( tonumber(width) / tonumber(height ) > 4/3 ) then
	--Widescreen resolution
	menuBarTop = 75;
end


local TitanMovable = {};
local TitanMovableData = {
	PlayerFrame = {frameName = "PlayerFrame", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -4, position = TITAN_PANEL_PLACE_TOP},
	TargetFrame = {frameName = "TargetFrame", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -4, position = TITAN_PANEL_PLACE_TOP},
	PartyMemberFrame1 = {frameName = "PartyMemberFrame1", frameArchor = "TOPLEFT", xArchor = "LEFT", y = -128, position = TITAN_PANEL_PLACE_TOP},
	TicketStatusFrame = {frameName = "TicketStatusFrame", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = 0, position = TITAN_PANEL_PLACE_TOP},
--	TemporaryEnchantFrame = {frameName = "TemporaryEnchantFrame", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = -13, position = TITAN_PANEL_PLACE_TOP},
	ConsolidatedBuffs = {frameName = "ConsolidatedBuffs", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = -13, position = TITAN_PANEL_PLACE_TOP},
	BuffFrame = {frameName = "BuffFrame", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = -13, position = TITAN_PANEL_PLACE_TOP},
	MinimapCluster = {frameName = "MinimapCluster", frameArchor = "TOPRIGHT", xArchor = "RIGHT", y = 0, position = TITAN_PANEL_PLACE_TOP},
	WorldStateAlwaysUpFrame = {frameName = "WorldStateAlwaysUpFrame", frameArchor = "TOP", xArchor = "CENTER", y = -15, position = TITAN_PANEL_PLACE_TOP},
	MainMenuBar = {frameName = "MainMenuBar", frameArchor = "BOTTOM", xArchor = "CENTER", y = 0, position = TITAN_PANEL_PLACE_BOTTOM},
	MultiBarRight = {frameName = "MultiBarRight", frameArchor = "BOTTOMRIGHT", xArchor = "RIGHT", y = 98, position = TITAN_PANEL_PLACE_BOTTOM},
	VehicleMenuBar = {frameName = "VehicleMenuBar", frameArchor = "BOTTOM", xArchor = "CENTER", y = 0, position = TITAN_PANEL_PLACE_BOTTOM},	
}

local function TitanMovableFrame_CheckThisFrame(frameName)
	-- Add to the table that will checked.
	-- Once 'full' the table will be looped through to see
	-- if the frame must be moved or not.
	table.insert(TitanMovable, frameName)
end

local function TitanMovable_GetPanelYOffset(framePosition)
	-- framePosition is top or bottom. Return the Y offset
	-- depending on which bars the user has shown.
	--
	-- Both top & bottom are figured out but only the
	-- requested postion is returned
	local barnum_top = 0;
	local barnum_bot = 0

	-- If user has the top adjust set then determine the
	-- top offset
	if not TitanPanelGetVar("ScreenAdjust") then
		if TitanPanelGetVar("Bar_Show") then
			barnum_top = 1
		end
		if TitanPanelGetVar("Bar2_Show") then
			barnum_top = 2
		end
	end
	-- If user has the top adjust set then determine the
	-- bottom offset
	if not TitanPanelGetVar("AuxScreenAdjust") then
		if TitanPanelGetVar("AuxBar_Show") then
			barnum_bot = 1
		end
		if TitanPanelGetVar("AuxBar2_Show") then
			barnum_bot = 2
		end
	end
	
	local scale = TitanPanelGetVar("Scale")
	-- return the requested offset
	-- 0 will be returned if the user has not bars showing
	-- or the scale is not valid
	if scale and framePosition then
		if framePosition == TITAN_PANEL_PLACE_TOP then
			return (-TITAN_PANEL_BAR_HEIGHT * scale)*(barnum_top);
		elseif framePosition == TITAN_PANEL_PLACE_BOTTOM then
			return (TITAN_PANEL_BAR_HEIGHT * scale)*(barnum_bot);
		end
	end
	return 0
end

local function TitanMovableFrame_GetXOffset(frame, point)
	-- A valid frame and point is requried
	-- Determine a proper X offset using the given point (position)
	if frame and point then
		if point == "LEFT" and frame:GetLeft() and UIParent:GetLeft() then
			return frame:GetLeft() - UIParent:GetLeft();
		elseif point == "RIGHT" and frame:GetRight() and UIParent:GetRight() then
			return frame:GetRight() - UIParent:GetRight();			
		elseif point == "TOP" and frame:GetTop() and UIParent:GetTop() then
			return frame:GetTop() - UIParent:GetTop();
		elseif point == "BOTTOM" and frame:GetBottom() and UIParent:GetBottom() then
			return frame:GetBottom() - UIParent:GetBottom();
		elseif point == "CENTER" and frame:GetLeft() and frame:GetRight() 
		and UIParent:GetLeft() and UIParent:GetRight() then
		   local framescale = frame.GetScale and frame:GetScale() or 1;
			return (frame:GetLeft()* framescale + frame:GetRight()
				* framescale - UIParent:GetLeft() - UIParent:GetRight()) / 2;
		end
	end
	-- In case the inputs were invalid or
	-- if the point was not relevant to the frame then return 0
	return 0;
end

function TitanMovableFrame_CheckFrames(position)
	-- Depending on position (top / bottom / both) determine
	-- the farmes that may need to be moved
	--
	-- reset the frames to move
	TitanMovable = {};

	-- check top as requested
	if (position == TITAN_PANEL_PLACE_TOP) 
	or position == TITAN_PANEL_PLACE_BOTH then
		-- Move PlayerFrame		
		TitanMovableFrame_CheckThisFrame(PlayerFrame:GetName())
			
		-- Move TargetFrame		
		TitanMovableFrame_CheckThisFrame(TargetFrame:GetName())		

		-- Move PartyMemberFrame		
		TitanMovableFrame_CheckThisFrame(PartyMemberFrame1:GetName())

		-- Move TicketStatusFrame
		if TitanPanelGetVar("TicketAdjust") then
			TitanMovableFrame_CheckThisFrame(TicketStatusFrame:GetName())
		end
		
		-- Move TemporaryEnchantFrame. 
		-- Seems this will be deprecated in the future in favor of BuffFrame ...
--		TitanMovableFrame_CheckThisFrame(TemporaryEnchantFrame:GetName())
	
		-- Move MinimapCluster
		if not CleanMinimap then
			if not TitanPanelGetVar("MinimapAdjust") then
				TitanMovableFrame_CheckThisFrame(MinimapCluster:GetName())
			end
		end
		-- Move BuffFrame
		TitanMovableFrame_CheckThisFrame(BuffFrame:GetName())
		TitanMovableFrame_CheckThisFrame(ConsolidatedBuffs:GetName())

		-- Move WorldStateAlwaysUpFrame				
		TitanMovableFrame_CheckThisFrame(WorldStateAlwaysUpFrame:GetName());
	end
	
	-- check bottom as requested
	if (position == TITAN_PANEL_PLACE_BOTTOM) 
	or position == TITAN_PANEL_PLACE_BOTH then
		
		-- Move MainMenuBar		
		TitanMovableFrame_CheckThisFrame(MainMenuBar:GetName());
	
		-- Move MultiBarRight
		TitanMovableFrame_CheckThisFrame(MultiBarRight:GetName());
		
		-- Move VehicleMenuBar		
		TitanMovableFrame_CheckThisFrame(VehicleMenuBar:GetName());
	end
end

function TitanMovableFrame_MoveFrames(position)
	-- Once the frames to check have been collected, 
	-- move them as needed.
	local frameData, frame, frameName, frameArchor, xArchor, y, xOffset, yOffset, panelYOffset;
	
	-- Collect the frames we need to move
	TitanMovableFrame_CheckFrames(position);
	
	-- move them...
	if not InCombatLockdown() then
		for index, value in pairs(TitanMovable) do						
			frameData = TitanMovableData[value];
			if frameData then
				frame = _G[frameData.frameName];
				frameName = frameData.frameName;
				frameArchor = frameData.frameArchor;
			end

			if frame and (not frame:IsUserPlaced()) then
				xArchor = frameData.xArchor;
				y = frameData.y;
				
				panelYOffset = TitanMovable_GetPanelYOffset(frameData.position);
				xOffset = TitanMovableFrame_GetXOffset(frame, xArchor);
				
				-- properly adjust buff frame(s) if GM Ticket is visible
--				if (frameName == "TemporaryEnchantFrame"
--				or frameName == "ConsolidatedBuffs")
				if (frameName == "ConsolidatedBuffs")
				and TicketStatusFrame:IsVisible()
				and TitanPanelGetVar("TicketAdjust") then
					yOffset = (-TicketStatusFrame:GetHeight()) + panelYOffset
				else
					yOffset = y + panelYOffset;
				end

				-- properly adjust MinimapCluster if its border is hidden
				if frameName == "MinimapCluster" 
				and MinimapBorderTop 
				and not MinimapBorderTop:IsShown() then					
					yOffset = yOffset + (MinimapBorderTop:GetHeight() * 3/5) - 5
				end
				
				-- adjust the MainMenuBar according to its scale
				if  frameName == "MainMenuBar" and MainMenuBar:IsVisible() then
					local framescale = MainMenuBar:GetScale() or 1;
				    yOffset =  yOffset / framescale;
				end
				
				-- account for Reputation Status Bar (doh)
				local playerlevel = UnitLevel("player");
				if frameName == "MultiBarRight" 
				and ReputationWatchStatusBar:IsVisible() 
				and playerlevel < _G["MAX_PLAYER_LEVEL"] then
					yOffset = yOffset + 8;
				end
				
				frame:ClearAllPoints();		
				frame:SetPoint(frameArchor, "UIParent", frameArchor, 
					xOffset, yOffset);
			else
				--Leave frame where it is as it has been moved by a user
			end
			-- Move bags as needed
			updateContainerFrameAnchors();
		end
	end
end

local function Titan_TicketStatusFrame_OnShow()  
-- always check the routine we are overriding!
	-- The Blizz routine moved the buffs to the right. 
	-- This keeps them where they were to avoid
	-- odd placement of the temp & consolidated buffs. 
	-- Depending on the exact steps used the 
	-- placement of temp buffs is inconsistent 
	-- (likely Blizz but more testing needed)
	local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_TOP);
	if not InCombatLockdown() or (InCombatLockdown()) then
--	and not TemporaryEnchantFrame:IsProtected()) then
		if not TitanPanelGetVar("ScreenAdjust") 
		and TitanPanelGetVar("TicketAdjust") then
			ConsolidatedBuffs:SetPoint("TOPRIGHT", TicketStatusFrame:GetParent(), 
				"TOPRIGHT", -180, (-TicketStatusFrame:GetHeight() + panelYOffset));
		else
			ConsolidatedBuffs:SetPoint("TOPRIGHT", TicketStatusFrame:GetParent(), 
				"TOPRIGHT", -180, (-TicketStatusFrame:GetHeight()));
		end
	end
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_TOP, false)
--	ConsolidatedBuffs:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", -205, (-self:GetHeight()));
end

local function Titan_TicketStatusFrame_OnHide()
	local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_TOP);
	-- this is to replicate Blizzard's check in FrameXML/HelpFrame.xml
	if not GMChatStatusFrame or not GMChatStatusFrame:IsShown() then 
		if not InCombatLockdown() or (InCombatLockdown()) then
--		and not TemporaryEnchantFrame:IsProtected()) then
			if not TitanPanelGetVar("ScreenAdjust") then
				ConsolidatedBuffs:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", 
					-180, -13 + panelYOffset);
			else
				ConsolidatedBuffs:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", 
					-180, -13);
			end
		end
	end
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_TOP, false)
--[[ Blizz code
	if( not GMChatStatusFrame or not GMChatStatusFrame:IsShown() ) then
		ConsolidatedBuffs:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -180, -13);
	end
--]]
end

local function Titan_FCF_UpdateDockPosition()
	if not Titan__InitializedPEW
	or not TitanPanelGetVar("LogAdjust") 
	or TitanPanelGetVar("AuxScreenAdjust") then 
		return 
	end
	
	if not InCombatLockdown() or (InCombatLockdown() 
	and not _G["DEFAULT_CHAT_FRAME"]:IsProtected()) then
		local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM);
		local scale = TitanPanelGetVar("Scale");
		if scale then
			panelYOffset = panelYOffset + (24 * scale) -- after 3.3.5 an additional adjust was needed. why? idk
		end

--[[ Blizz code
		if _G["DEFAULT_CHAT_FRAME"]:IsUserPlaced() then
			if _G["SIMPLE_CHAT"] ~= "1" then return end
		end
		
		local chatOffset = 85 + panelYOffset;
		if GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() then
			if MultiBarBottomLeft:IsVisible() then
				chatOffset = chatOffset + 55;
			else
				chatOffset = chatOffset + 15;
			end
		elseif MultiBarBottomLeft:IsVisible() then
			chatOffset = chatOffset + 15;
		end
		_G["DEFAULT_CHAT_FRAME"]:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, chatOffset);
		FCF_DockUpdate();
--]]
		if ( DEFAULT_CHAT_FRAME:IsUserPlaced() ) then
			return;
		end
		
		local chatOffset = 85 + panelYOffset; -- Titan change to adjust Y offset
		if ( GetNumShapeshiftForms() > 0 or HasPetUI() or PetHasActionBar() ) then
			if ( MultiBarBottomLeft:IsShown() ) then
				chatOffset = chatOffset + 55;
			else
				chatOffset = chatOffset + 15;
			end
		elseif ( MultiBarBottomLeft:IsShown() ) then
			chatOffset = chatOffset + 15;
		end
		DEFAULT_CHAT_FRAME:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 
			32, chatOffset);
		FCF_DockUpdate();
	end
end

local function Titan_ContainerFrames_Relocate()
--[[ doc
-- The Blizz routine "ContainerFrames_Relocate" should be
-- examined for any conditions it checks and any changes to the SetPoint.
-- If Blizz changes the anchor points the SetPoint here must change as well!!
--
-- Titan uses a secure POST hook to adjust the Y offset ONLY.
--
-- The Blizz routine calculates X & Y offsets to UIParent (screen)
-- so there is not need to store the prior offsets.
-- Like the Blizz routine we search through the visible bags.
-- Unlike the Blizz routine we only care about the first of each column
-- to adjust for Titan.
-- This way the Blizz code does not need to be copied here.
--]]
	if not TitanPanelGetVar("BagAdjust") then 
		return 
	end

	local panelYOffset = TitanMovable_GetPanelYOffset(TITAN_PANEL_PLACE_BOTTOM)
	local off_y = 10000 -- something ridiculously high
	local bottom_y = 0
	local right_x = 0

	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = _G[frameName];
		bottom_y = frame:GetBottom()
		if ( bottom_y < off_y ) then
			-- Start a new column
			right_x = frame:GetRight()
			frame:ClearAllPoints();		
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), 
				"BOTTOMLEFT", -- changed because we are taking the current x value
				right_x, -- x is not adjusted
				bottom_y + panelYOffset -- y
			)
		end
		off_y = bottom_y
	end
end

local function TitanMovableFrame_AdjustBlizzardFrames()
	if not InCombatLockdown() then
		Titan_FCF_UpdateDockPosition();
		Titan_ContainerFrames_Relocate();
	end
end

local function Titan_ManageFramesVehicle()
	TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTH, false)
end

local function Titan_ManageVehicles()		
	TitanMovableModule:CancelAllTimers()
	TitanMovableModule:ScheduleTimer(Titan_ManageFramesVehicle, 2)
--	TitanMovableModule:ScheduleTimer(Titan_ManageFramesNew, 2)
end

local function Titan_AdjustUIScale()	
	-- Refresh panel scale and buttons	
	Titan_AdjustScale()
end

function TitanPanel_AdjustFrames(position, blizz)
	-- Adjust frame positions top only, bottom only, or both
	TitanMovableFrame_MoveFrames(position)

	-- move the Blizzard frames if requested
	if blizz and position == TITAN_PANEL_PLACE_BOTTOM then
		TitanMovableFrame_AdjustBlizzardFrames()
	end
end

function Titan_ManageFramesNew()
	if Titan__InitializedPEW then
		-- We know the desired bars are now drawn so we can adjust
		TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTTOM, false)
	end
end

function Titan_AdjustScale()		
	TitanPanel_SetScale();
	
	TitanPanel_ClearAllBarTextures()
	TitanPanel_CreateBarTextures()

	for idx,v in pairs (TitanBarData) do
		TitanPanel_SetTexture(TITAN_PANEL_DISPLAY_PREFIX..TitanBarData[idx].name
			, TITAN_PANEL_PLACE_TOP);
	end

	TitanPanelBarButton_DisplayBarsWanted()
	TitanPanel_RefreshPanelButtons();
end

function TitanMovable_SecureFrames()
	if Titan__InitializedPEW then
	else
--TitanDebug ("Test delay of secure hooks!!!")
		-- We know the desired bars are now drawn so we can adjust
		TitanMovableModule:SecureHook("FCF_UpdateDockPosition", Titan_FCF_UpdateDockPosition) -- FloatingChatFrame
		TitanMovableModule:SecureHook("UIParent_ManageFramePositions", Titan_ManageFramesNew) -- UIParent.lua
		TitanPanel_AdjustFrames(TITAN_PANEL_PLACE_BOTTOM, false)
	end
end

-- Titan Hooks
-- Overwrite Blizzard Frame positioning functions
TitanMovableModule:SecureHook(TicketStatusFrame, "Show", Titan_TicketStatusFrame_OnShow) -- HelpFrame.xml
TitanMovableModule:SecureHook(TicketStatusFrame, "Hide", Titan_TicketStatusFrame_OnHide) -- HelpFrame.xml
TitanMovableModule:SecureHook("updateContainerFrameAnchors", Titan_ContainerFrames_Relocate) -- ContainerFrame.lua
TitanMovableModule:SecureHook(WorldMapFrame, "Hide", Titan_ManageFramesNew) -- WorldMapFrame.lua
TitanMovableModule:SecureHook("VehicleSeatIndicator_SetUpVehicle", Titan_ManageVehicles) -- VehicleMenuBar.lua
TitanMovableModule:SecureHook("VehicleSeatIndicator_UnloadTextures", Titan_ManageVehicles) -- VehicleMenuBar.lua
-- Properly Adjust UI Scale if set
-- Note: These are the least intrusive hooks we could think of, to properly adjust the Titan Bar(s)
-- without having to resort to a SetCvar secure hook. Any addon using SetCvar should make sure to use the 3rd
-- argument in the API call and trigger the CVAR_UPDATE event with an appropriate argument so that other addons
-- can detect this behavior and fire their own functions (where applicable).
TitanMovableModule:SecureHook("VideoOptionsFrameOkay_OnClick", Titan_AdjustUIScale) -- VideoOptionsFrame.lua
TitanMovableModule:SecureHook(VideoOptionsFrame, "Hide", Titan_AdjustUIScale) -- VideoOptionsFrame.xml
