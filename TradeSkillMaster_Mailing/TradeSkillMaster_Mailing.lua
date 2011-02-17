-- register this file with Ace Libraries
local TSM = select(2, ...)
TSM = LibStub("AceAddon-3.0"):NewAddon(TSM, "TradeSkillMaster_Mailing", "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries

TSM.version = GetAddOnMetadata("TradeSkillMaster_Mailing","X-Curse-Packaged-Version") or GetAddOnMetadata("TradeSkillMaster_Mailing", "Version") -- current version of the addon
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Mailing") -- loads the localization table

local eventThrottle = CreateFrame("Frame", nil, MailFrame)
local bagTimer, itemTimer, cacheFrame, activeMailTarget, mailTimer, lastTotal, autoLootTotal, waitingForData, resetIndex
local lockedItems, mailTargets = {}, {}
local playerName = string.lower(UnitName("player"))
local allowTimerStart = true
local LOOT_MAIL_INDEX = 1
local MAIL_WAIT_TIME = 0.30
local RECHECK_TIME = 2
local FOUND_POSTAL


local savedDBDefaults = {
	factionrealm = {
		mailTargets = {},
		mailItems = {},
		test = 1,
	},
	profile = {
		autoCheck = true,
		dontDisplayMoneyCollected = false,
	},
}

function TSM:OnEnable()
	-- load the savedDB into TSM.db
	TSM.db = LibStub:GetLibrary("AceDB-3.0"):New("TradeSkillMaster_MailingDB", savedDBDefaults, true)
	TSM.Config = TSM.modules.Config

	TSMAPI:RegisterModule("TradeSkillMaster_Mailing", TSM.version, GetAddOnMetadata("TradeSkillMaster_Mailing", "Author"), GetAddOnMetadata("TradeSkillMaster_Mailing", "Notes"))
	TSMAPI:RegisterIcon(L["Mailing Options"], "Interface\\Icons\\Inv_Letter_20", function(...) TSM.Config:Load(...) end, "TradeSkillMaster_Mailing", "options")
	
	if TSM.db.factionrealm.test == 1 then
		TSM.db.factionrealm.test = 2
		wipe(TSM.db.factionrealm.mailItems)
		wipe(TSM.db.factionrealm.mailTargets)
	end
	
	local function showTooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:SetText(self.tooltip, 1, 1, 1, nil, true)
		GameTooltip:Show()
	end
	local function hideTooltip(self)
		GameTooltip:Hide()
	end

	-- Mass opening
	local button = CreateFrame("Button", nil, InboxFrame, "UIPanelButtonTemplate")
	button:SetText(L["Open All"])
	button:SetHeight(24)
	button:SetWidth(130)
	button:SetPoint("BOTTOM", InboxFrame, "CENTER", -10, -165)
	button:SetScript("OnClick", function(self) TSM:StartAutoLooting() end)

	-- Don't show mass opening if Postal is enabled since postals button will block _Mailing's
	if( select(6, GetAddOnInfo("Postal")) == nil ) then
		FOUND_POSTAL = true
		button:Hide()
	end
	
	self.massOpening = button
	
	local check = CreateFrame("Button", "TSM_MailingSendMail", InboxFrame, "UIPanelButtonTemplate")
	check:SetHeight(26)
	check:SetWidth(250)
	check:SetText(L["TradeSkillMaster_Mailing: Auto-Mail"])
	check:SetFrameStrata("HIGH")
	check:SetScript("OnEnter", showTooltip)
	check:SetScript("OnLeave", hideTooltip)
	check:SetScript("OnHide", function()
		TSM:Stop()
	end)
	check:SetScript("OnClick", function(self)
		MailFrameTab2:Click()
		TSM:Start()
	end)
	check:SetPoint("TOPLEFT", MailFrame, "TOPLEFT", 70, 13)
	check.tooltip = L["Runs TradeSkillMaster_Mailing's auto mailer, the last patch of mails will take ~10 seconds to send.\n\n[WARNING!] You will not get any confirmation before it starts to send mails, it is your own fault if you mistype your bankers name."]
		
	-- Hide Inbox/Send Mail text, it's wasted space and makes my lazyly done checkbox look bad. Also hide the too much mail warning
	local noop = function() end
	InboxTooMuchMail:Hide()
	InboxTooMuchMail.Show = noop
	InboxTooMuchMail.Hide = noop
	
	InboxTitleText:Hide()
	SendMailTitleText:Hide()

	-- Timer for mailbox cache updates
	cacheFrame = CreateFrame("Frame", nil, MailFrame)
	cacheFrame:SetScript("OnEnter", showTooltip)
	cacheFrame:SetScript("OnLeave", hideTooltip)
	cacheFrame:EnableMouse(true)
	cacheFrame.tooltip = L["How many seconds until the mailbox will retrieve new data and you can continue looting mail."]
	cacheFrame:SetScript("OnUpdate", function(self, elapsed)
		if( not waitingForData ) then
			local seconds = self.endTime - GetTime()
			if( seconds <= 0 ) then
				-- Look for new mail
				-- Sometimes it fails and isn't available at exactly 60-61 seconds, and more like 62-64, will keep rechecking every 2 seconds
				-- until data becomes available
				if( TSM.db.profile.autoCheck ) then
					waitingForData = true
					self.timeLeft = RECHECK_TIME
					cacheFrame.text:SetText(nil)
					
					CheckInbox()
				else
					self:Hide()
				end
				
				return
			end
			
			cacheFrame.text:SetFormattedText("%d", seconds)
		else
			self.timeLeft = self.timeLeft - elapsed
			if( self.timeLeft <= 0 ) then
				self.timeLeft = RECHECK_TIME
				CheckInbox()
			end
		end
	end)
	
	cacheFrame.text = cacheFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	cacheFrame.text:SetFont(GameFontHighlight:GetFont(), 30, "THICKOUTLINE")
	cacheFrame.text:SetPoint("CENTER", MailFrame, "TOPLEFT", 40, -35)
	cacheFrame:Hide()
	
	self.totalMail = MailFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	self.totalMail:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -60 + (FOUND_POSTAL and -24 or 0), -18)

	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("MAIL_INBOX_UPDATE")
end


-- Deal swith auto looting of mail!
function TSM:StartAutoLooting()
	local total
	autoLootTotal, total = GetInboxNumItems()
	if( autoLootTotal == 0 and total == 0 ) then return end
	
	if( TSM.db.profile.autoCheck and autoLootTotal == 0 and total > 0 ) then
		self.massOpening:SetText(L["Waiting..."])
	end
	
	self:RegisterEvent("UI_ERROR_MESSAGE")
	self.massOpening:Disable()
	TSM.moneyCollected = 0
	self:AutoLoot()
end

function TSM:AutoLoot()
	-- Already looted everything after the invalid indexes we had, so fail it
	if( LOOT_MAIL_INDEX > 1 and LOOT_MAIL_INDEX > GetInboxNumItems() ) then
		if( resetIndex ) then
			self:StopAutoLooting(true)
		else
			resetIndex = true
			LOOT_MAIL_INDEX = 1
			self:AutoLoot()
		end
		return
	end
	
	local money, cod, _, items, _, _, _, _, isGM = select(5, GetInboxHeaderInfo(LOOT_MAIL_INDEX))
	if( not isGM and ( not cod or cod <= 0 ) and ( ( money and money > 0 ) or ( items and items > 0 ) ) ) then
		mailTimer = nil
		self.massOpening:SetText(L["Opening..."])
		if(money > 0) then
			TSM.moneyCollected = TSM.moneyCollected + money
		end
		AutoLootMailItem(LOOT_MAIL_INDEX)
	-- Can't grab the first mail, but we have a second so increase it and try again
	elseif( GetInboxNumItems() > LOOT_MAIL_INDEX ) then
		LOOT_MAIL_INDEX = LOOT_MAIL_INDEX + 1
		self:AutoLoot()
	end
end


local GOLD_TEXT = "|cffffd700g|r"
local SILVER_TEXT = "|cffc7c7cfs|r"
local COPPER_TEXT = "|cffeda55fc|r"

function TSM:FormatTextMoney(money)
	local money = tonumber(money)
	if not money then return end
	local gold = math.floor(money / COPPER_PER_GOLD)
	local silver = math.floor((money - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER)
	local copper = math.floor(money%COPPER_PER_SILVER)
	local text = ""
	
	-- Add gold
	if gold > 0 then
		text = string.format("%d%s ", gold, GOLD_TEXT)
	end
	
	-- Add silver
	if silver > 0 then
		text = string.format("%s%d%s ", text, silver, SILVER_TEXT)
	end
	
	-- Add copper if we have no silver/gold found, or if we actually have copper
	if copper > 0 then
		text = string.format("%s%d%s ", text, copper, COPPER_TEXT)
	end
	return string.trim(text)
end

function TSM:StopAutoLooting(failed)
	if( failed ) then
		TSM:Print(L["Cannot finish auto looting, inventory is full or too many unique items."])
	end
	
	-- Immediately send off, as we know we won't (likely) be needing anything more
	if( self:GetPendingAttachments() > 0 ) then
		self:SendMail()
	end

	resetIndex = nil
	autoLootTotal = nil
	LOOT_MAIL_INDEX = 1
	
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self.massOpening:SetText(L["Open All"])
	self.massOpening:Enable()
	
	--Tell user how much money has been collected if they don't have it turned off in TradeSkillMaster_Mailing options
	if(TSM.moneyCollected and TSM.moneyCollected > 0 and (not TSM.db.profile.dontDisplayMoneyCollected)) then
		TSM:Print(TSM:FormatTextMoney(TSM.moneyCollected) .. " Collected")
		TSM.moneyCollected = 0
	end
	

end

function TSM:UI_ERROR_MESSAGE(event, msg)
	if( msg == ERR_INV_FULL or msg == ERR_ITEM_MAX_COUNT ) then
		-- Send off our pending mail first to free up more room to auto loot
		if( msg == ERR_INV_FULL and activeMailTarget and self:GetPendingAttachments() > 0 ) then
			self.massOpening:SetText(L["Waiting..."])
			autoLootTotal = -1
			bagTimer = MAIL_WAIT_TIME
			eventThrottle:Show()

			self:SendMail()
			return
		end
		
		-- Try the next index in case we can still loot more such as in the case of glyphs
		LOOT_MAIL_INDEX = LOOT_MAIL_INDEX + 1
		
		-- If we've exhausted all slots, but we still have <50 and more mail pending, wait until new data comes and keep looting it
		local current, total = GetInboxNumItems()
		if( LOOT_MAIL_INDEX > current ) then
			if( LOOT_MAIL_INDEX > total and total <= 50 ) then
				self:StopAutoLooting(true)
			else
				self.massOpening:SetText(L["Waiting..."])
			end
			return
		end
		
		mailTimer = MAIL_WAIT_TIME
		eventThrottle:Show()
	end
end

function TSM:MAIL_INBOX_UPDATE()
	local current, total = GetInboxNumItems()
	-- Yay nothing else to loot, so nothing else to update the cache for!
	if( cacheFrame.endTime and current == total and lastTotal ~= total ) then
		cacheFrame.endTime = nil
		cacheFrame:Hide()
	-- Start a timer since we're over the limit of 50 items before waiting for it to recache
	elseif( ( cacheFrame.endTime and current >= 50 and lastTotal ~= total ) or ( current >= 50 and allowTimerStart ) ) then
		resetIndex = nil
		allowTimerStart = nil
		waitingForData = nil
		lastTotal = total
		cacheFrame.endTime = GetTime() + 64
		cacheFrame:Show()
	end
	
	-- The last item we setup to auto loot is finished, time for the next one
	if( (not self.massOpening:IsEnabled()) and autoLootTotal ~= current ) then
		autoLootTotal = GetInboxNumItems()
		
		-- If we're auto checking mail when new data is available, will wait and continue auto looting, otherwise we just stop now
		if( TSM.db.profile.autoCheck and current == 0 and total > 0 ) then
			self.massOpening:SetText(L["Waiting..."])
		elseif( current == 0 and ( not TSM.db.profile.autoCheck or total == 0 ) ) then
			self:StopAutoLooting()
		else
			self:AutoLoot()
		end
	end
	
	if( total > 0 ) then
		self.totalMail:SetFormattedText(L["%d mail"], total)
	else
		self.totalMail:SetText(nil)
	end
end

function TSM:MAIL_CLOSED()
	resetIndex = nil
	allowTimerStart = true
	waitingForData = nil
	self:StopAutoLooting()
end

-- Deals with auto sending mail to people
function TSM:TargetHasItems(checkLocks)
	TSM.Config:UpdateItemsInGroup()
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			local itemID = TSMAPI:GetItemID(GetContainerItemLink(bag, slot))
			local locked = select(3, GetContainerItemInfo(bag, slot))
			local target = TSM.db.factionrealm.mailItems[itemID] or TSM.Config.itemsInGroup[itemID]
			if( target and activeMailTarget == target and ( not checkLocks or checkLocks and not locked ) ) then
				return true
			end
		end
	end
	
	return false
end

function TSM:FindNextMailTarget()
	TSM.Config:UpdateItemsInGroup()
	table.wipe(mailTargets)
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			local itemID = TSMAPI:GetItemID(GetContainerItemLink(bag, slot))
			local locked = select(3, GetContainerItemInfo(bag, slot))
			local target = TSM.db.factionrealm.mailItems[itemID] or TSM.Config.itemsInGroup[itemID]
			if( not locked and target ) then
				target = string.lower(target)
				mailTargets[target] = (mailTargets[target] or 0) + 1
			end
		end
	end

	-- Obviously, we don't want to send mail to ourselves
	mailTargets[playerName] = nil
	
	-- Find the highest one to dump as much inventory as we can to make more room for looting
	local highestTarget, targetCount
	for target, count in pairs(mailTargets) do
		if( not highestTarget or targetCount < count ) then
			highestTarget = target
			targetCount = count
		end
	end
	
	return highestTarget
end

function TSM:Start()
	activeMailTarget = self:FindNextMailTarget()
	
	-- This is more to give users the visual que that hey, it's actually going to send to this person, even thought this field has no bearing on who it's sent to
	if( activeMailTarget ) then
		SendMailNameEditBox:SetText(activeMailTarget)
	else
		TSM:Print(L["No items to send."])
	end
	
	self:RegisterEvent("BAG_UPDATE")
	self:UpdateBags()
end

function TSM:Stop()
	self:UnregisterEvent("BAG_UPDATE")
	
	bagTimer = nil
	itemTimer = nil
end

function TSM:SendMail()
	if( not activeMailTarget ) then return end
	
	TSM:Print(string.format(L["Mailed items off to %s!"], activeMailTarget))
	SendMail(activeMailTarget, SendMailSubjectEditBox:GetText() or "Mass mailing", "")

	itemTimer = nil
	activeMailTarget = nil

	-- Wait twice as much time to make sure it gets sent off
	if( self.massOpening:IsEnabled() == 0 ) then
		autoLootTotal = -1
		mailTimer = MAIL_WAIT_TIME * 2
		eventThrottle:Show()
	end
end

function TSM:GetPendingAttachments()
	local totalAttached = 0
	for i=1, ATTACHMENTS_MAX_SEND do
		if( GetSendMailItem(i) ) then
			totalAttached = totalAttached + 1
		end
	end
	
	return totalAttached
end

function TSM:UpdateBags()
	TSM.Config:UpdateItemsInGroup()
	-- Nothing else to send to this person, so we can send off now
	if( activeMailTarget and not self:TargetHasItems() and not itemTimer ) then
		if( self.massOpening:IsEnabled() == 0 ) then
			itemTimer = 2
			eventThrottle:Show()
		else
			if not firstMail then
				self:SendMail()
			end
		end
	end
	
	-- No mail target, let's try and find one
	if( not activeMailTarget ) then
		activeMailTarget = self:FindNextMailTarget()
		if( activeMailTarget ) then
			SendMailNameEditBox:SetText(activeMailTarget)
		end
	end

	-- If we exit before the loot after send checks then it will stop too early
	if( not activeMailTarget ) then return end

	-- Otherwise see if we can send anything off
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			local itemID = TSMAPI:GetItemID(GetContainerItemLink(bag, slot))
			local quantity, locked = select(2, GetContainerItemInfo(bag, slot))
			
			if( not locked ) then lockedItems[bag .. slot] = nil end
			
			-- Can't use something that's still locked
			local target = TSM.db.factionrealm.mailItems[itemID] or TSM.Config.itemsInGroup[itemID]
			if( target and activeMailTarget and string.lower(target) == activeMailTarget ) then
				-- When creating lots of glyphs, or anything that stacks really this will stop it from sending too early
				if( locked and lockedItems[bag .. slot] and lockedItems[bag .. slot] ~= quantity ) then
					lockedItems[bag .. slot] = quantity
					itemTimer = self.massOpening:IsEnabled() == 0 and 3 or GetTradeSkillLine() == "UNKNOWN" and 1 or 10
					eventThrottle:Show()
				-- Not locked, let's add it up!
				elseif( not locked ) then
					local totalAttached = self:GetPendingAttachments()
					
					-- Too many attached, nothing we can do yet
					if( totalAttached >= ATTACHMENTS_MAX_SEND ) then return end

					PickupContainerItem(bag, slot)
					ClickSendMailItemButton()
					
					lockedItems[bag .. slot] = quantity

					-- Hit cap, send us off
					if( (totalAttached + 1) >= ATTACHMENTS_MAX_SEND ) then
						self:SendMail()
					-- No more unlocked items to send for this target, wait TargetHasItems
					elseif( not self:TargetHasItems(true) ) then
						itemTimer = self.massOpening:IsEnabled() == 0 and 3 or GetTradeSkillLine() == "UNKNOWN" and 1 or 10
						eventThrottle:Show()
					end
				end
			end
		end
	end
end

-- Bag updates are fun and spammy, throttle them to every 0.20 seconds
function TSM:BAG_UPDATE()
	bagTimer = 0.20
	eventThrottle:Show()
end

eventThrottle:SetScript("OnUpdate", function(self, elapsed)
	if( bagTimer ) then
		bagTimer = bagTimer - elapsed
		if( bagTimer <= 0 ) then
			bagTimer = nil
			TSM:UpdateBags()
		end
	end
	
	if( itemTimer ) then
		itemTimer = itemTimer - elapsed
		if( itemTimer <= 0 ) then
			itemTimer = nil
			
			if( activeMailTarget ) then
				TSM:SendMail()
			end
		end
	end
	
	if( mailTimer ) then
		mailTimer = mailTimer - elapsed
		if( mailTimer <= 0 ) then
			TSM:AutoLoot()
		end
	end
	
	if( not bagTimer and not itemTimer and not mailTimer ) then
		self:Hide()
	end
end)
eventThrottle:Hide()