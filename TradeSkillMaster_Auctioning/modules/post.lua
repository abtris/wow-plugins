local TSMAuc = select(2, ...)
local Post = TSMAuc:NewModule("Post", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Auctioning") -- loads the localization table

local BIG_NUMBER = 100000000000 -- 10 million gold
local stats, postQueue, currentItem = {}, {}, {}
local totalToPost, totalPosted, count = 0, 0, 0
local totalToScan, totalScanned = 0, 0
local timedOut = false
local bagSlots = {}

function Post:StartScan()
	local tempList = {}
	local scanList = {}

	TSMAuc:UpdateItemReverseLookup()
	TSMAuc:UpdateGroupReverseLookup()
	
	wipe(stats)
	wipe(postQueue)
	wipe(currentItem)
	totalToPost, totalPosted, count = 0, 0, 0
	isScanning, timedOut = true, false
	
	for bag=0, 4 do
		if TSMAuc:IsValidBag(bag) then
			for slot=1, GetContainerNumSlots(bag) do
				local itemID = TSMAuc:GetItemString(GetContainerItemLink(bag, slot))
				if itemID and TSMAuc.itemReverseLookup[itemID] then
					tempList[itemID] = true
				end
			end
		end
	end
	
	for itemID in pairs(tempList) do
		local name = GetItemInfo(itemID)
		tinsert(scanList, {name=name, itemID=itemID})
	end
	
	sort(scanList, function(a, b)
			-- Makes sure that the items that stack the lowest are posted first to free up space for items
			-- that stack higher
			local aStack = select(8, GetItemInfo(a.itemID)) or 20
			local bStack = select(8, GetItemInfo(b.itemID)) or 20
			
			if aStack == bStack then
				return Post:GetNumInBags(a.itemID) < Post:GetNumInBags(b.itemID)
			end
			
			return aStack < bStack
		end)
		
	TSMAuc.Manage.postScanning:Show()
	TSMAuc.Manage.stopPostingButton:Show()
	totalToScan, totalScanned = #(scanList), 0
	
	if totalToScan == 0 then
		TSMAuc.Log:AddMessage(L["You do not have any items to post"], "poststatus")
		TSMAuc.Manage.donePosting:Show()
		TSMAuc.Manage.postScanning:Hide()
		TSMAuc.Manage.stopPostingButton:Hide()
		return
	end
	TSMAuc.Log:AddMessage({scanType="Post", isHeader=true, scanData={}}, "header")
	
	Post:RegisterMessage("TSMAuc_QUERY_UPDATE", "MessageHandler")
	Post:RegisterMessage("TSMAuc_STOP_SCAN", "MessageHandler")
	Post:RegisterMessage("TSMAuc_AH_CLOSED", "MessageHandler")
	TSMAPI:LockSidebar()
	TSMAPI:ShowSidebarStatusBar()
	TSMAPI:SetSidebarStatusBarText("Scanning")
	TSMAPI:UpdateSidebarStatusBar(0, true)
	TSMAPI:CreateTimeDelay("updatePostStatus", 0, function()
			local postStatus = floor((totalScanned/totalToScan)*(count/totalToPost)*100)
			if totalToPost == 0 or totalToScan == 0 then postStatus = 0 end
			TSMAPI:UpdateSidebarStatusBar(postStatus)
		end, 0.3)
	
	
	TSMAuc.Scan:StartItemScan(scanList)
end

function Post:MessageHandler(msg, ...)
	if msg == "TSMAuc_QUERY_UPDATE" then
		local text, item = ...
		if text == "done" then
			totalScanned = totalScanned + 1
			TSMAPI:UpdateSidebarStatusBar((totalScanned/totalToScan)*100, true)
			Post:ProcessItem(item.itemID)
		end
	elseif msg == "TSMAuc_STOP_SCAN" then
		TSMAPI:SetSidebarStatusBarText(L["Posting"])
		isScanning = false
		local interrupted = ...
		if interrupted or #(postQueue) == 0 then
			Post:StopPosting()
		end
	elseif msg == "TSMAuc_AH_CLOSED" then
		Post:StopPosting()
	end
end

local isInvalid = function(value)
	if abs(value) > BIG_NUMBER or value == 0 then
		return true
	end
end

function Post:ProcessItem(itemID)
	if not itemID then return end
	
	local name, itemLink, _, _, _, _, _, stackCount = GetItemInfo(itemID)
	local perAuction = math.min(stackCount, TSMAuc.Config:GetConfigValue(itemID, "perAuction"))
	local maxCanPost = math.floor(Post:GetNumInBags(itemID) / perAuction)
	local postCap = TSMAuc.Config:GetConfigValue(itemID, "postCap")
	local threshold = TSMAuc.Config:GetConfigValue(itemID, "threshold")
	local auctionsCreated, activeAuctions = 0, 0
	
	-- don't post this item if their threshold or fallback is 0 or some really big number
	local fallbackValue = TSMAuc.Config:GetConfigValue(itemID, "fallback")
	if isInvalid(threshold) then
		return TSMAuc:Print(format(L["Did not post %s because your threshold (%s) is invalid. Check your settings."], itemLink or name or itemID, threshold))
	elseif isInvalid(fallbackValue) then
		return TSMAuc:Print(format(L["Did not post %s because your fallback (%s) is invalid. Check your settings."], itemLink or name or itemID, fallbackValue))
	end
	
	TSMAuc.Log:AddMessage(string.format(L["Scanning %s"], itemLink), name)
	
	local perAuctionIsCap = TSMAuc.Config:GetBoolConfigValue(itemID, "perAuctionIsCap")
	
	if maxCanPost == 0 then
		if perAuctionIsCap then
			perAuction = Post:GetNumInBags(itemID)
			maxCanPost = 1
		else
			TSMAuc.Log:AddMessage(format(L["Skipped %s need %s for a single post, have %s"], itemLink, "|cff20ff20"..perAuction.."|r", "|cff20ff20"..Post:GetNumInBags(itemID).."|r"), name)
			return
		end
	end

	local buyout, bid, _, isPlayer, isWhitelist = TSMAuc.Scan:GetLowestAuction(itemID)
	local msgTable = {scanType="Post", itemID=itemID, stackSize=perAuction, scanData={}}
	-- Check if we're going to go below the threshold
	if buyout and TSMAuc.Config:GetConfigValue(itemID, "reset") == "none" then
		-- Smart undercutting is enabled, and the auction is for at least 1 gold, round it down to the nearest gold piece
		local testBuyout = buyout
		if TSMAuc.db.global.smartUndercut and testBuyout > COPPER_PER_GOLD then
			testBuyout = math.floor(buyout / COPPER_PER_GOLD) * COPPER_PER_GOLD
		else
			testBuyout = testBuyout - TSMAuc.Config:GetConfigValue(itemID, "undercut")
		end
		
		if testBuyout < threshold and buyout <= threshold then
			msgTable.scanData={action="Skip", actionReason="below threshold", postedAmount = activeAuctions, totalPostingAmount = postCap, lowestBuyout=buyout}
			TSMAuc.Log:AddMessage(msgTable, name)
			return
		end
	end
	-- Auto fallback is on, and lowest buyout is below threshold, instead of posting them all
	-- use the post count of the fallback tier
	local resetMethod = TSMAuc.Config:GetConfigValue(itemID, "reset")
	if resetMethod ~= "none" and buyout and buyout <= threshold then
		local fallbackBuyout = (resetMethod == "custom" and TSMAuc.Config:GetConfigValue(itemID, "resetPrice")) or TSMAuc.Config:GetConfigValue(itemID, resetMethod)
		local fallbackBid = fallbackBuyout * TSMAuc.Config:GetConfigValue(itemID, "bidPercent")
		activeAuctions = TSMAuc.Scan:GetPlayerAuctionCount(itemID, fallbackBuyout, fallbackBid)
	elseif isPlayer or isWhitelist then
		-- Either the player or a whitelist person is the lowest teir so use this tiers quantity of items
		activeAuctions = TSMAuc.Scan:GetPlayerAuctionCount(itemID, buyout or 0, bid or 0)
	end
	
	-- If we have a post cap of 20, and 10 active auctions, but we can only have 5 of the item then this will only let us create 5 auctions
	-- however, if we have 20 of the item it will let us post another 10
	auctionsCreated = math.min(postCap - activeAuctions, maxCanPost)
	if auctionsCreated <= 0 then
		msgTable.scanData={action="Skip", postedAmount=activeAuctions, actionReason="too many posted", totalPostingAmount = postCap}
		TSMAuc.Log:AddMessage(msgTable, name)
		return
	end
	
	-- Warn that they don't have enough to post
	if maxCanPost < postCap then
		msgTable.scanData={action="Post", restock=true, postedAmount = 0, totalPostingAmount = maxCanPost}
		TSMAuc.Log:AddMessage(msgTable, name)
	end
	
	if not Post:QueueItemToPost({name=name, link=itemLink, itemID=itemID, stackSize=perAuction, numStacks=auctionsCreated}) then
		stats[itemID] = (stats[itemID] or 0) + auctionsCreated
	end
end

function Post:QueueItemToPost(queue)
	if not queue then return true end
	
	local name, link = queue.name, queue.link
	local itemID = queue.itemID or TSMAuc:GetItemString(link)
	local bag, slot = Post:FindItemSlot(itemID)
	if not (bag and slot and itemID) then return true end
	local lowestBuyout, lowestBid, lowestOwner, isWhitelist, isPlayer = TSMAuc.Scan:GetLowestAuction(itemID)
	
	-- Set our initial costs
	local fallbackCap, buyoutTooLow, bidTooLow, reset, bid, buyout, differencedPrice, buyoutThresholded
	local fallback = TSMAuc.Config:GetConfigValue(itemID, "fallback")
	local threshold = TSMAuc.Config:GetConfigValue(itemID, "threshold")
	local priceThreshold = TSMAuc.Config:GetConfigValue(itemID, "priceThreshold")
	local priceDifference = TSMAuc.Scan:CompareLowestToSecond(itemID, lowestBuyout)
	local resetMethod = TSMAuc.Config:GetConfigValue(itemID, "reset")
	
	-- Difference between lowest that we have and second lowest is too high, undercut second lowest instead
	if isPlayer and priceDifference and priceDifference >= priceThreshold then
		differencedPrice = true
		lowestBuyout, lowestBid = TSMAuc.Scan:GetSecondLowest(itemID, lowestBuyout)
	end
		
	-- No other auctions up, default to fallback
	if not lowestOwner then
		buyout = TSMAuc.Config:GetConfigValue(itemID, "fallback")
		bid = buyout * TSMAuc.Config:GetConfigValue(itemID, "bidPercent")
	-- Item goes below the threshold price, default it to fallback
	elseif resetMethod ~= "none" and lowestBuyout <= threshold then
		reset = true
		buyout = (resetMethod == "custom" and TSMAuc.Config:GetConfigValue(itemID, "resetPrice")) or TSMAuc.Config:GetConfigValue(itemID, resetMethod)
		bid = buyout * TSMAuc.Config:GetConfigValue(itemID, "bidPercent")
	-- Either we already have one up or someone on the whitelist does
	elseif (isPlayer or isWhitelist) and not differencedPrice then
		buyout = lowestBuyout
		bid = lowestBid
	-- We got undercut :(
	else
		local goldTotal = lowestBuyout / COPPER_PER_GOLD
		-- Smart undercutting is enabled, and the auction is for at least 1 gold, round it down to the nearest gold piece
		-- the math.floor(blah) == blah check is so we only do a smart undercut if the price isn't a whole gold piece and not a partial
		if TSMAuc.db.global.smartUndercut and lowestBuyout > COPPER_PER_GOLD and goldTotal ~= math.floor(goldTotal) then
			buyout = math.floor(goldTotal) * COPPER_PER_GOLD
		else
			buyout = lowestBuyout - TSMAuc.Config:GetConfigValue(itemID, "undercut")
		end
		
		-- Check if we're posting something too high
		if buyout > (fallback * TSMAuc.Config:GetConfigValue(itemID, "fallbackCap")) then
			buyout = fallback
			fallbackCap = true
		end
		
		-- Check if we're posting too low!
		if buyout < threshold then
			buyout = threshold
			buyoutThresholded = true
		end
		
		bid = math.floor(buyout * TSMAuc.Config:GetConfigValue(itemID, "bidPercent"))

		-- Check if the bid is too low
		if bid < threshold then
			bid = threshold
			bidTooLow = true
		end
	end
	
	local quantityText = queue.stackSize > 1 and " x " .. queue.stackSize or ""
	
	-- Increase the bid/buyout based on how many items we're posting
	bid = math.floor(bid * queue.stackSize)
	buyout = math.floor(buyout * queue.stackSize)
	local msgTable = {scanType="Post", itemID=itemID, stackSize=queue.stackSize, scanData={lowestBid=lowestBid, lowestBuyout=lowestBuyout, lowestBuyoutOwner=lowestOwner, postedBid=bid, postedBuyout=buyout, postedAmount=stats[itemID], totalPostingAmount=queue.numStacks}}
	if (resetMethod == "fallback" and lowestBuyout and threshold and lowestBuyout <= threshold) or fallbackCap then msgTable.scanData.action = "Fallback"
	else msgTable.scanData.action = "Post" end
	TSMAuc.Log:AddMessage(msgTable, name)
	
	local function IsGem(itemID)
		return TSMAPI:GetNewGem(itemID) and true
	end
	
	local time = TSMAuc.Config:GetConfigValue(itemID, "postTime")
	time = (time == 48 and 3) or (time == 24 and 2) or 1
	if IsGem(itemID) then -- if it's a gem we need to do something special
		local locations = {}
		local used = {}
		for bag=0, 4 do
			for slot=1, GetContainerNumSlots(bag) do
				local sID = TSMAuc:GetItemString(GetContainerItemLink(bag, slot))
				if sID and IsGem(sID) then
					for _, fID in pairs(TSMAPI:GetOldGems(itemID)) do
						if sID == fID and not used[bag.."@"..slot] then
							locations[sID] = locations[sID] or {}
							tinsert(locations[sID], {bag=bag, slot=slot})
							used[bag.."@"..slot] = true
						end
					end
				end
			end
		end
		for itemID, slots in pairs(locations) do
			if queue.numStacks == 0 then break end
			local quantity = #(slots)
			if quantity > queue.numStacks then quantity = queue.numStacks end
			
			for i=1, quantity do
				tinsert(postQueue, {bag=slots[1].bag, slot=slots[1].slot, bid=bid, buyout=buyout, time=time, stackSize=1, numStacks=1, itemID=itemID})
				totalToPost = totalToPost + 1
			end
			queue.numStacks = queue.numStacks - quantity
		end
	else
		local locations
		if queue.numStacks > 1 then
			locations = Post:FindItemSlot(itemID, true)
		end
		for i=1, queue.numStacks do
			local oBag, oSlot
			if locations and locations[i] then
				oBag, oSlot = locations[i].bag, locations[i].slot
			elseif locations then
				oBag, oSlot = locations[1].bag, locations[1].slot
			else
				oBag, oSlot = bag, slot
			end
			tinsert(postQueue, {bag=oBag, slot=oSlot, bid=bid, buyout=buyout, time=time, stackSize=queue.stackSize, numStacks=1, itemID=itemID})
			totalToPost = totalToPost + 1
		end
	end
	
	Post:UpdatePostFrame()
end

function Post:FindItemSlot(findLink, allLocations, ignoreBagSlot)
	local locations = {}
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			local itemID = TSMAuc:GetItemString(link)
			if itemID and itemID == findLink and not TSMAuc.Config:IsSoulbound(bag, slot, itemID) and (ignoreBagSlot and not ignoreBagSlot[bag.."$"..slot] or not ignoreBagSlot) then
				tinsert(locations, {bag=bag, slot=slot})
				if not allLocations then
					return bag, slot
				end
			end
		end
	end
	return allLocations and CopyTable(locations)
end

function Post:GetNumInBags(itemID)
	local oldGems = TSMAPI:GetOldGems(itemID)
	if not oldGems then return GetItemCount(itemID) end
	local num = 0
	
	for _, sID in pairs(oldGems) do
		num = num + GetItemCount(sID)
	end
	
	for i=0, NUM_BAG_SLOTS do
		if GetBagName(i) == GetItemInfo(itemID) then
			num = num - 1
		end
	end
	
	return num
end

function Post:UpdatePostFrame()
	if not Post.frame then
		TSMAuc.Manage:BuildAHFrame("Post")
	end
	
	if not Post.frame:IsVisible() then
		Post:StartPosting()
	end
	TSMAuc.Manage.postScanning:Hide()
	TSMAuc.Manage.stopPostingButton:Hide()
	
	ClearCursor()
	Post.frame.button:SetText(format(L["Post Auction %s / %s"], totalPosted, totalToPost))
	if currentItem and currentItem.itemID then
		local _,_,link,_,_,_,_,_,_,_,texture = pcall(function() return GetItemInfo(currentItem.itemID) end)
		
		Post.frame.link:SetText(link)
		Post.frame.stackSize:SetText(format(L["Stack Size: %s"], currentItem.stackSize))
		Post.frame.numStacks:SetText(format(L["Number of Stacks: %s"], currentItem.numStacks))
		Post.frame.bid:SetText(format(L["Bid: %s"], TSMAuc:FormatTextMoney(currentItem.bid)))
		Post.frame.buyout:SetText(format(L["Buyout: %s"], TSMAuc:FormatTextMoney(currentItem.buyout)))
		
		if texture then
			Post.frame.iconButton:SetNormalTexture(texture)
		end
		Post.frame.iconButton.link = link
	end
end

function Post:StartPosting()
	wipe(bagSlots)
	Post.frame:Show()
	TSMAuc.Manage.donePosting:Hide()
	Post:RegisterEvent("CHAT_MSG_SYSTEM")
	Post:UpdateItem()
end

local timeout = CreateFrame("Frame")
timeout:Hide()
timeout:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 or (not select(3, GetContainerItemInfo(postQueue[1].bag, postQueue[1].slot)) and not AuctionsCreateAuctionButton:IsEnabled()) then
			timedOut = true
			tremove(postQueue, 1)
			Post:UpdateItem()
		end
	end)

-- Check if an auction was posted and move on if so
function Post:CHAT_MSG_SYSTEM(_, msg)
	if msg == ERR_AUCTION_STARTED then
		count = count + 1
	end
end

function Post:ValidateBagSlot(inSlot)
	local bag, slot, quantity = currentItem.bag, currentItem.slot, currentItem.stackSize
	local slotID = bag.."$"..slot
	local link = GetContainerItemLink(bag, slot)
	local itemID = TSMAuc:GetItemString(link)
	-- if the item in the expected slot is not the item we were expecting or
	-- is not a large enough stack to post from this slot, find a new one!
	if itemID ~= currentItem.itemID or inSlot < quantity then
		-- ignore all slots that don't have enough items to post the current auction from
		local ignoreItems = {}
		for loc, num in pairs(bagSlots[currentItem.itemID]) do
			if num < quantity then
				ignoreItems[loc] = true
			end
		end
		ignoreItems[bag.."$"..slot] = true
		local nBag, nSlot = Post:FindItemSlot(itemID, nil, ignoreItems)
		return nBag, nSlot
	end
	return bag, slot
end

function Post:PostItem()
	timeout.timeLeft = (currentItem.numStacks or 1) * 5
	timeout:Show()
	if not AuctionFrameAuctions.duration then
		-- taken from Auctioneer
		-- Fix in case Blizzard_AuctionUI hasn't set this value yet (causes an error otherwise)
		AuctionFrameAuctions.duration = 2
	end
	
	-- populate the bagSlots table with the current status of the player's bags
	if not bagSlots[currentItem.itemID] then
		bagSlots[currentItem.itemID] = {}
		for _, item in ipairs(Post:FindItemSlot(currentItem.itemID, true)) do
			bagSlots[currentItem.itemID][item.bag.."$"..item.slot] = select(2, GetContainerItemInfo(item.bag, item.slot))
		end
	end
	
	-- validate / get a new bag and slot for this item
	local vBag, vSlot = Post:ValidateBagSlot(bagSlots[currentItem.itemID][currentItem.bag.."$"..currentItem.slot])
	currentItem.bag, currentItem.slot = (vBag or currentItem.bag), (vSlot or currentItem.slot)
	if not currentItem.bag or not currentItem.slot then error("Invalid bag / slot: "..(currentItem.bag or "nil")..", "..(currentItem.slot or "nil")..", "..currentItem.itemID..", "..currentItem.stackSize) end
	bagSlots[currentItem.itemID][currentItem.bag.."$"..currentItem.slot] = bagSlots[currentItem.itemID][currentItem.bag.."$"..currentItem.slot] - currentItem.stackSize
	
	PickupContainerItem(currentItem.bag, currentItem.slot)
	ClickAuctionSellItemButton(AuctionsItemButton, "LeftButton")
	StartAuction(currentItem.bid, currentItem.buyout, currentItem.time, currentItem.stackSize, currentItem.numStacks)
	Post.frame.button:Disable()
end

function Post:SkipItem()
	local toSkip = {}
	local skipped = tremove(postQueue, 1)
	count = count + 1
	for i, item in ipairs(postQueue) do
		if item.itemID == skipped.itemID and item.bid == skipped.bid and item.buyout == skipped.buyout then
			tinsert(toSkip, i)
		end
	end
	sort(toSkip, function(a, b) return a > b end)
	for _, index in ipairs(toSkip) do
		tremove(postQueue, index)
		count = count + 1
	end
	Post:UpdateItem()
end

local function DelayFrame()
	if not isScanning and #(postQueue) == 0 then
		Post:StopPosting()
		TSMAPI:CancelFrame("postDelayFrame")
	elseif #(postQueue) > 0 then
		Post:UpdateItem()
		TSMAPI:CancelFrame("postDelayFrame")
	end
end
	
local countFrame = CreateFrame("Frame")
countFrame:Hide()
countFrame.count = -1
countFrame.timeLeft = 10
countFrame:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if count >= totalToPost or self.timeLeft <= 0 then
			self:Hide()
			Post:StopPosting()
		elseif count ~= self.count then
			self.count = count
			self.timeLeft = (totalToPost - count) * 2
		end
	end)

function Post:UpdateItem()
	timeout:Hide()
	if #(postQueue) == 0 then
		Post.frame.button:Disable()
		if isScanning then
			TSMAPI:CreateFunctionRepeat("postDelayFrame", DelayFrame)
		else
			countFrame:Show()
		end
		return
	end

	totalPosted = totalPosted + 1
	wipe(currentItem)
	currentItem = CopyTable(postQueue[1])
	Post:UpdatePostFrame()
	Post.frame.button:Enable()
end

function Post:StopPosting()
	TSMAuc.Log:AddMessage(L["Finished Posting"], "finished")
	TSMAuc.Log:WipeLog()
	if Post.frame then Post.frame:Hide() Post.frame.button:Disable() end
	TSMAPI:CancelFrame("postDelayFrame")
	TSMAPI:CancelFrame("updatePostStatus")
	TSMAPI:HideSidebarStatusBar()
	TSMAPI:UnlockSidebar()
	
	TSMAuc.Manage.donePosting:Show()
	TSMAuc.Manage.postScanning:Hide()
	TSMAuc.Manage.stopPostingButton:Hide()
	Post:UnregisterEvent("CHAT_MSG_SYSTEM")
	Post:UnregisterMessage("TSMAuc_QUERY_UPDATE")
	Post:UnregisterMessage("TSMAuc_STOP_SCAN")
	Post:UnregisterMessage("TSMAuc_AH_CLOSED")
	
	wipe(currentItem)
	totalToPost, totalPosted = 0, 0
	isScanning, timedOut = false, false
end