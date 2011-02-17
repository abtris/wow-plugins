local TSMAuc = select(2, ...)
local Log = TSMAuc:NewModule("Log", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning")
local AceGUI = LibStub("AceGUI-3.0")

local statusLog, logIDs = {}, {}

function Log:Show()
	if Log.LogFrame then Log.LogFrame:Show() return end
	Log:CreateStatus()
	Log.LogFrame:Show()
end

function Log:Hide()
	if Log.LogFrame then Log.LogFrame:Hide() end
end

function Log:WipeLog()
	-- This will force it to create new rows for any new logs without having to wipe all of them
	-- table.wipe(logIDs)
	local h = logIDs["header"]
	table.wipe(logIDs)
	if h then logIDs["header"]=h end
	if #(statusLog) > 0 then
		Log:AddMessage("-------------------------------", "spacer")
	else
		self:UpdateStatusLog()
	end
end

-- Old log create function
function Log:CreateStatus()
	if Log.LogFrame then return end
	
	-- Try and stop UIObjects from clipping the status frame
	local function fixFrame()
		local frame = Log.LogFrame
		if AuctionsScrollFrame:IsVisible() then
			frame:SetParent(AuctionsScrollFrame)
		else
			frame:SetParent(AuctionFrameAuctions)
		end
		
		frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 10)
		for _, row in pairs(frame.rows) do
			row:SetFrameLevel(frame:GetFrameLevel() + 1)
		end
		
		-- Force it to be visible still
		if TSMAuc.db.global.showStatus then
			Log.LogFrame:Show()
		end
	end
	
	AuctionsScrollFrame:HookScript("OnHide", fixFrame)
	AuctionsScrollFrame:HookScript("OnShow", fixFrame)

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1}}

	local frame = CreateFrame("Frame", nil, AuctionsScrollFrame)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0, 0, 0, 0.95)
	frame:SetBackdropBorderColor(0.60, 0.60, 0.60, 1)
	frame:SetHeight(1)
	frame:SetWidth(1)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", AuctionsQualitySort, "BOTTOMLEFT", -2, -2)
	frame:SetPoint("BOTTOMRIGHT", AuctionsCloseButton, "TOPRIGHT", -5, 2)
	frame:SetScript("OnShow", function() Log:UpdateStatusLog() end)
	frame:EnableMouse(true)
	frame:Hide()

	frame.scroll = CreateFrame("ScrollFrame", "TSMAucLogScrollFrame", frame, "FauxScrollFrameTemplate")
	frame.scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
	frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -24, 1)
	frame.scroll:SetScript("OnVerticalScroll", function(self, value) FauxScrollFrame_OnVerticalScroll(self, value, 16, Log.UpdateStatusLog) end)

	frame.rows = {}

	-- Tooltips!
	local function showTooltip(self)
		if type(self.tooltip) == "string" and self.tooltip ~= "" then
			GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPLEFT")
			GameTooltip:SetText(self.tooltip, 1, 1, 1, nil, true)
			GameTooltip:Show()
		end
	end

	local function hideTooltip(self)
		GameTooltip:Hide()
	end

	for i=1, 21 do
		local row = CreateFrame("Button", nil, frame)
		row:SetWidth(1)
		row:SetHeight(16)
		row:SetPushedTextOffset(0, 0)
		row:SetScript("OnEnter", showTooltip)
		row:SetScript("OnLeave", hideTooltip)
		
		local text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		text:SetFont(GameFontHighlight:GetFont(), 11)
		text:SetAllPoints(row)
		text:SetJustifyH("LEFT")
		text:SetTextColor(0.95, 0.95, 0.95, 1)
		row:SetFontString(text)
		
		if i > 1 then
			row:SetPoint("TOPLEFT", frame.rows[i - 1], "BOTTOMLEFT", 0, 0)
			row:SetPoint("TOPRIGHT", frame.rows[i - 1], "BOTTOMRIGHT", 0, 0)
		else
			row:SetPoint("TOPLEFT", frame.scroll, "TOPLEFT", 2, 0)
			row:SetPoint("TOPRIGHT", frame.scroll, "TOPRIGHT", 0, 0)
		end

		frame.rows[i] = row
	end
	
	Log.LogFrame = frame
	
	fixFrame()
end

-- Adds a message to the log.  
-- Msg can be a string (plaintext logging)
-- or a table (advanced logging)  String argument will be obsoleted.
-- table format:
-- { scanType = "scanType", -- Post, Cancel, Status
--   scanData = { ... },
--   id = id, -- increments for every message
--   itemID = id, isHeader = bool }  Maybeh itemString support if it turns that way.
-- Post = {
--  action = "action" -- Skip, Fallback, Post
--  postedAmount = ...
--  totalPostingAmount = ...
--  restock = boolean
--  postedBid = ...
--  postedBuyout = ...
--  lowestBid = ... -- pertinent only if Fallback/Skip
--  lowestBuyout = ... -- ibidem
--  lowestBuyoutOwner = "..." } -- ibidem
-- Cancel = {
--  postedAmount = ...
--  totalPostingAmount = ...
--  action = "action" -- Cancel, Skip
--  postedBid, postedBuyout,
--  lowestBid, lowestBuyout,
--  lowestBuyoutOwners = {{bid, buyout, owner},...} }
-- Status = {
--  lowestBid, lowestBuyout, lowestBuyoutOwner
--  lowestBuyoutOwners = {{bid, buyout, owner},...} }
--  marketVolume, currentMarketMean }
function Log:AddMessage(msg, id)
	if not id then id = msg end
	if not logIDs[id] then
		logIDs[id] = #(statusLog) + 1
	end
	if type(msg) ~= "table" then
		if not id then return end
		statusLog[logIDs[id]] = msg or ""
	else
		statusLog[logIDs[id]] = msg
	end
	local scrollBar = TSMAucLogScrollFrameScrollBar
	local maxValue = scrollBar and select(2, scrollBar:GetMinMaxValues())
	if scrollBar and scrollBar:GetValue() <= maxValue then
		scrollBar:SetValue(maxValue+1)
		Log:UpdateStatusLog()
	else
		Log:UpdateStatusLog()
	end
end

-- Returns a formatted frame from a table as specified above
-- now recycles frames so we don't have a memory leak! (-sapu)
function Log:FormattedFrame(msgTable, oldFrame)
	local frame = oldFrame or CreateFrame("Frame")
	frame:SetWidth(1)
	frame:SetHeight(16)
	frame:ClearAllPoints()
	local ActionColors = {["Post"] = {r=12/255, g=45/255, b=62/255},
		["Skip"] = {r=51/255, g=61/255, b=33/255},
		["FallbackAbove"] = {r=4/255, g=0, b=88/255},
		["FallbackBelow"] = {r=32/255, g=80/255, b=3/255},
		["Cancel"] = {r=12/255, g=45/255, b=62/255} }
	local function showTooltip(self)
		if type(self.tooltip) == "string" and self.tooltip ~= "" then
			GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPLEFT")
			GameTooltip:SetText(self.tooltip, 1, 1, 1, nil, true)
			GameTooltip:Show()
		end
	end

	local function hideTooltip(self)
		GameTooltip:Hide()
	end
	
	local backdropTable = {bgFile="Interface\\QuestFrame\\UI-QuestLogTitleHighlight", tile=false,
	edgeFile="Interface\\BUTTONS\WHITE8X8", edgeSize=0,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }}
	
	local actionString = msgTable.scanData.action
	local fSize = 11
	if msgTable.isHeader then fSize = 10	end
	if msgTable.scanType ~= "Status" then
		if actionString == "Fallback" then -- Localize action strings
			if (msgTable.scanData.lowestBuyout or 0) > (TSMAuc.Config:GetConfigValue(msgTable.itemID, "threshold") or 0) then
				actionString = "FallbackAbove"
			else actionString = "FallbackBelow" end
		end
		local postPriceString = TSMAuc:FormatTextMoney(msgTable.scanData.postedBuyout, true) or "---"
		local postPriceTooltip = TSMAuc:FormatTextMoney(msgTable.scanData.postedBid) or "---"
		local lboPriceString = TSMAuc:FormatTextMoney(msgTable.scanData.lowestBuyout, true) or "---"
		local lboPriceTooltip = TSMAuc:FormatTextMoney(msgTable.scanData.lowestBid) or "---"
		local ownerString = msgTable.scanData.lowestBuyoutOwner or "---"
		local postString = ""
		local itemLink = ""
		if msgTable.itemID~=nil then
			itemLink = select(2, GetItemInfo(msgTable.itemID)) end
		if msgTable.stackSize~=nil and msgTable.stackSize ~= 1 then itemLink = itemLink.."x"..msgTable.stackSize end
		if msgTable.scanData.postedAmount~=nil then
			postString = msgTable.scanData.postedAmount.."/"..msgTable.scanData.totalPostingAmount
			if msgTable.scanData.restock then postString = postString.." |cffff0000(restock)|r" end
		end
		local ownerTooltip = ""
		if msgTable.scanData.lowestBuyoutOwners~=nil then
			local tooltipMessages = {}
			table.sort(msgTable.scanData.lowestBuyoutOwners, function(a,b) return a.buyout < b.buyout end)
			for _,t in ipairs(msgTable.scanData.lowestBuyoutOwners) do
				tinsert(tooltipMessages, t.owner.." @ "..TSMAuc:FormatTextMoney(t.buyout))
			end
			ownerTooltip = table.concat(tooltipMessages, "\n")
		end
		local backdropColor = {}
		if msgTable.isHeader then
			msgTable.scanData.action = msgTable.scanType .. ":"
			postPriceString = "Post Price"
			postPriceTooltip = "Post Price (bid)"
			lboPriceString = "Lowest Buyout"
			lboPriceTooltip = "Lowest Bid"
			ownerString = "Seller"
			ownerTooltip = "Seller List"
			itemLink = "[Item Name]"
			if msgTable.scanType == "Post" then
				postString = "Posted"
			else postString = "Canceled" end
			meanPriceString = "Market Mean"
			backdropColor.a = 1
			backdropColor.r = 0
			backdropColor.g = 0.15
			backdropColor.b = 0.15
		else
			backdropColor = ActionColors[actionString]
		end
		
		if frame.meanPriceText then frame.meanPriceText:Hide() end
		
		local actionText = frame.actionText or CreateFrame("Button", nil, frame)
		frame.actionText = actionText
		actionText:SetWidth(60)
		actionText:SetHeight(16)
		actionText:SetPushedTextOffset(0, 0)
		actionText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		actionText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
		local text = actionText.text or actionText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		actionText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(actionText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		actionText:SetFontString(text)
		actionText:SetText(msgTable.scanData.action)
		if msgTable.scanData.actionTooltip then
			actionText:SetScript("OnEnter", showTooltip)
			actionText:SetScript("OnLeave", hideTooltip)
			actionText.tooltip = msgTable.scanData.actionTooltip
		end
		
		local itemText = frame.itemText or CreateFrame("Button", nil, frame)
		frame.itemText = itemText
		itemText:SetWidth(180)
		itemText:SetHeight(16)
		itemText:SetPushedTextOffset(0, 0)
		itemText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		itemText:SetPoint("TOPLEFT", actionText, "TOPRIGHT", 3, 0)
		local text = itemText.text or itemText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		itemText.text = text
		text:SetFont(GameFontNormal:GetFont(), 11, "OUTLINE")
		text:SetAllPoints(itemText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		itemText:SetFontString(text)
		itemText:SetText(itemLink)
		
		local postPriceText = frame.postPriceText or CreateFrame("Button", nil, frame)
		frame.postPriceText = postPriceText
		postPriceText:SetWidth(80)
		postPriceText:SetHeight(16)
		postPriceText:SetPushedTextOffset(0,0)
		postPriceText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		postPriceText:SetPoint("TOPLEFT", itemText, "TOPRIGHT", 3, 0)
		text = postPriceText.text or postPriceText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		postPriceText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(postPriceText)
		text:SetJustifyH("RIGHT")
		text:SetTextColor(1, 1, 1, 1)
		postPriceText:SetFontString(text)
		postPriceText:SetScript("OnEnter", showTooltip)
		postPriceText:SetScript("OnLeave", hideTooltip)
		postPriceText.tooltip = postPriceTooltip
		postPriceText:SetText(postPriceString)
		
		local lboPriceText = frame.lboPriceText or CreateFrame("Button", nil, frame)
		frame.lboPriceText = lboPriceText
		lboPriceText:SetWidth(80)
		lboPriceText:SetHeight(16)
		lboPriceText:SetPushedTextOffset(0,0)
		lboPriceText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		lboPriceText:SetPoint("TOPLEFT", postPriceText, "TOPRIGHT", 3, 0)
		text = lboPriceText.text or lboPriceText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		lboPriceText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(lboPriceText)
		text:SetJustifyH("RIGHT")
		text:SetTextColor(1, 1, 1, 1)
		lboPriceText:SetFontString(text)
		lboPriceText:SetScript("OnEnter", showTooltip)
		lboPriceText:SetScript("OnLeave", hideTooltip)
		lboPriceText.tooltip = lboPriceTooltip
		lboPriceText:SetText(lboPriceString)
		
		local ownerText = frame.ownerText or CreateFrame("Button", nil, frame)
		frame.ownerText = ownerText
		ownerText:SetWidth(80)
		ownerText:SetHeight(16)
		ownerText:SetPushedTextOffset(0,0)
		ownerText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		ownerText:SetPoint("TOPLEFT", lboPriceText, "TOPRIGHT", 3, 0)
		text = ownerText.text or ownerText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		ownerText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(ownerText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		ownerText:SetFontString(text)
		ownerText:SetScript("OnEnter", showTooltip)
		ownerText:SetScript("OnLeave", hideTooltip)
		ownerText.tooltip = ownerTooltip
		ownerText:SetText(ownerString)
		
		local postText = frame.postText or CreateFrame("Button", nil, frame)
		frame.postText = postText
		postText:SetWidth(75)
		postText:SetHeight(16)
		postText:SetPushedTextOffset(0,0)
		postText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		postText:SetPoint("TOPLEFT", ownerText, "TOPRIGHT", 3, 0)
		text = postText.text or postText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		postText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(postText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		postText:SetFontString(text)
		postText:SetText(postString)
		
		frame:SetBackdrop(backdropTable)
		backdropColor = backdropColor or {r=1, g=1, b=1}
		frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a or 1)
		
		return frame--, backdropTable, backdropColor
	else
		local lboPriceString = TSMAuc:FormatTextMoney(msgTable.scanData.lowestBuyout, true) or "---"
		local lboPriceTooltip = TSMAuc:FormatTextMoney(msgTable.scanData.lowestBid) or "---"
		local ownerString = msgTable.scanData.lowestBuyoutOwner or "---"
		local postString
		if msgTable.scanData.marketVolume then postString = msgTable.scanData.marketVolume
			.." ("..(msgTable.scanData.postedAmount or 0)..")" end
		local itemLink = ""
		if msgTable.itemID then
			itemLink = select(2, GetItemInfo(msgTable.itemID)) end
		local ownerTooltip = ""
		local meanPriceString
		if msgTable.scanData.currentMarketMean then meanPriceString = TSMAuc:FormatTextMoney(msgTable.scanData.currentMarketMean, true) end
		if msgTable.scanData.lowestBuyoutOwners then
			local tooltipMessages = {}
			table.sort(msgTable.scanData.lowestBuyoutOwners, function(a,b) return a.buyout < b.buyout end)
			for _,t in ipairs(msgTable.scanData.lowestBuyoutOwners) do
				tinsert(tooltipMessages, t.owner.." @ "..TSMAuc:FormatTextMoney(t.buyout))
			end
			ownerTooltip = table.concat(tooltipMessages, "\n")
		end
		local backdropColor = {}
		if msgTable.isHeader then
			lboPriceString = "Lowest Buyout"
			lboPriceTooltip = "Lowest Bid"
			ownerString = "Seller"
			ownerTooltip = "Seller List"
			postString = "#Posted (by you)"
			meanPriceString = "Market Mean"
			itemLink = "[Item Name]"
			backdropColor.a = 1
			backdropColor.r = 0
			backdropColor.g = 0.15
			backdropColor.b = 0.15
		else
			local z = msgTable.scanData.lowestBuyout/msgTable.scanData.currentMarketMean
			backdropColor.r = 0.5*z
			backdropColor.g = 1-0.5*z
			backdropColor.b = 0.1
			if backdropColor.g < 0 then backdropColor.g = 0 end
			if backdropColor.r > 1 then backdropColor.r = 1 end
		end
		
		if frame.actionText then frame.actionText:Hide() end
		if frame.postPriceText then frame.postPriceText:Hide() end
		
		local itemText = frame.itemText or CreateFrame("Button", nil, frame)
		frame.itemText = itemText
		itemText:SetWidth(180)
		itemText:SetHeight(16)
		itemText:SetPushedTextOffset(0, 0)
		itemText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		itemText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
		local text = itemText.text or itemText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		itemText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize, "OUTLINE")
		text:SetAllPoints(itemText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		itemText:SetFontString(text)
		itemText:SetText(itemLink)
		
		local meanPriceText = frame.meanPriceText or CreateFrame("Button", nil, frame)
		frame.meanPriceText = meanPriceText
		meanPriceText:SetWidth(80)
		meanPriceText:SetHeight(16)
		meanPriceText:SetPushedTextOffset(0,0)
		meanPriceText:SetFrameLevel(Log.LogFrame:GetFrameLevel()+3)
		meanPriceText:SetPoint("TOPLEFT", itemText, "TOPRIGHT", 3, 0)
		text = meanPriceText.text or meanPriceText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		meanPriceText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(meanPriceText)
		text:SetJustifyH("RIGHT")
		text:SetTextColor(1, 1, 1, 1)
		meanPriceText:SetFontString(text)
		meanPriceText:SetScript("OnEnter", showTooltip)
		meanPriceText:SetScript("OnLeave", hideTooltip)
		meanPriceText:SetText(meanPriceString)
		
		local lboPriceText = frame.lboPriceText or CreateFrame("Button", nil, frame)
		frame.lboPriceText = lboPriceText
		lboPriceText:SetWidth(80)
		lboPriceText:SetHeight(16)
		lboPriceText:SetPushedTextOffset(0,0)
		lboPriceText:SetPoint("TOPLEFT", meanPriceText, "TOPRIGHT", 3, 0)
		text = lboPriceText.text or lboPriceText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		lboPriceText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(lboPriceText)
		text:SetJustifyH("RIGHT")
		text:SetTextColor(1, 1, 1, 1)
		lboPriceText:SetFontString(text)
		lboPriceText:SetScript("OnEnter", showTooltip)
		lboPriceText:SetScript("OnLeave", hideTooltip)
		lboPriceText.tooltip = lboPriceTooltip
		lboPriceText:SetText(lboPriceString)
		
		local ownerText = frame.ownerText or CreateFrame("Button", nil, frame)
		frame.ownerText = ownerText
		ownerText:SetWidth(80)
		ownerText:SetHeight(16)
		ownerText:SetPushedTextOffset(0,0)
		text = ownerText.text or ownerText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		ownerText.text = text
		ownerText:SetPoint("TOPLEFT", lboPriceText, "TOPRIGHT", 3, 0)
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(ownerText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		ownerText:SetFontString(text)
		ownerText:SetScript("OnEnter", showTooltip)
		ownerText:SetScript("OnLeave", hideTooltip)
		ownerText.tooltip = ownerTooltip
		ownerText:SetText(ownerString)
		
		local postText = frame.postText or CreateFrame("Button", nil, frame)
		frame.postText = postText
		postText:SetWidth(100)
		postText:SetHeight(16)
		postText:SetPushedTextOffset(0,0)
		postText:SetPoint("TOPLEFT", ownerText, "TOPRIGHT", 3, 0)
		text = postText.text or postText:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		postText.text = text
		text:SetFont(GameFontNormal:GetFont(), fSize)
		text:SetAllPoints(postText)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1, 1)
		postText:SetFontString(text)
		postText:SetText(postString)
		
		frame:SetBackdrop(backdropTable)
		frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a or 0.95)
		
		return frame--, backdropTable, backdropColor
	end
end

-- Scroll frame Update function
function Log:UpdateStatusLog()
	local totalLogs = #(statusLog)
	if not Log.LogFrame or not Log.LogFrame:IsVisible() then return end
	
	FauxScrollFrame_Update(Log.LogFrame.scroll, totalLogs, #(Log.LogFrame.rows), 16)
	
	local offset = FauxScrollFrame_GetOffset(Log.LogFrame.scroll)
	for id, row in pairs(Log.LogFrame.rows) do
		local msg = statusLog[offset + id]
		if id == 1 and logIDs["header"] then msg = statusLog[logIDs["header"]] end
		if row.Table then
			row.Table:Hide()
		end
		if type(msg) == "string" then
			row.tooltip = msg
			row:SetText(row.tooltip)
			row:Show()
		elseif type(msg) == "table" then
			row:SetText("")
			row.tooltip = nil
			row:Show()
			if row.Table then
				local frame = Log:FormattedFrame(msg, row.Table)
				frame:SetParent(row)
				frame:SetFrameLevel(row:GetFrameLevel()+1)
				frame:SetAllPoints(row)
				frame:Show()
				row.Table = frame
			else
				local frame = Log:FormattedFrame(msg)
				frame:SetParent(row)
				frame:SetFrameLevel(row:GetFrameLevel()+1)
				frame:SetAllPoints(row)
				frame:Show()
				row.Table = frame
			end
		end
		if id > totalLogs + 1 then
			row:Hide()
		end
	end
end