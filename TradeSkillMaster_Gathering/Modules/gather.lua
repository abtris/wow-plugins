--load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Gather = TSM:NewModule("Gather", "AceEvent-3.0")

local backInGbank, totalGather, toProcess = {}, {}, {}
local busy = false

function Gather:OnInitialize()
	Gather:RegisterEvent("BANKFRAME_OPENED", "EventHandler")
	Gather:RegisterEvent("GUILDBANKFRAME_OPENED", "EventHandler")
end

local delay = CreateFrame("frame")
delay:Hide()
delay.func = function() end
delay.timeLeft = 0.5
delay:SetScript("OnShow", function(self) self.timeLeft = 0.5 end)
delay:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			delay.func()
			self:Hide()
		end
	end)
	
local doneGathering = CreateFrame("frame")
doneGathering:Hide()
doneGathering.timeout = 3
doneGathering.type = nil
doneGathering:SetScript("OnShow", function(self) self.timeLeft = self.timeout end)
doneGathering:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if not busy and self.timeLeft <= 0 then
			self:Hide()
			Gather:DoneGathering(self.type)
		end
	end)
doneGathering:RegisterEvent("BAG_UPDATE", function(self) self.timeLeft = 1 end)

function Gather:EventHandler(event)
	-- probably way overcomplicating it here...
	local rEvent = strsplit("_", event)
	rEvent = gsub(rEvent, "FRAME", "")
	
	if TSM.tasks[1] and TSM.tasks[1].location == rEvent then
		Gather:RegisterMessage("TSM"..rEvent, "GatherMaterials")
	end
end

function Gather:GatherMaterials(bType, bankItems)
	wipe(totalGather)
	local currentPlayer = UnitName("player")
	for itemID, quantity in pairs(TSM.tasks[1].items) do
		local numInBags = TSM.characters[currentPlayer].bags[itemID] or 0
		totalGather[itemID] = {inBags=(numInBags + quantity), toGather=quantity}
	end
	Gather:UnregisterMessage(bType)

	if bType == "TSMGUILDBANK" then
		delay.func = function() Gather:GatherGBank(bankItems) end
		delay:Show()
	elseif bType == "TSMBANK" then
		delay.func = function() Gather:GatherBank(bankItems) end
		delay:Show()
	end
end

local tabDelay = CreateFrame("frame")
tabDelay:Hide()
tabDelay.list = {}
tabDelay.timeLeft = 0.5
tabDelay:SetScript("OnShow", function() busy = true end)
tabDelay:SetScript("OnHide", function() busy = false end)
tabDelay:SetScript("OnUpdate", function(self, elapsed)
		self.timeLeft = self.timeLeft - elapsed
		if not self.list[1] then
			if self.timeLeft <= 0 then
				self:Hide()
			end
			return
		end
		local tab = self.list[1][1]
		if not tab then self:Hide() end
		
		if self.timeLeft <= 0 then
			self.timeLeft = 0.5
			_G["GuildBankTab"..tab.."Button"]:Click()
			if GetCurrentGuildBankTab() == tab then
				if self.ready then
					self.ready = nil
					Gather:PutBackInGbank(unpack(tremove(self.list, 1)))
				else
					self.ready = true
				end
			end
		end
	end)

function Gather:GatherGBank(bankItems)
	if not (TSM.tasks[1] and TSM.tasks[1].items) then return end
	wipe(backInGbank)
	for itemID, quantityNeeded in pairs(TSM.tasks[1].items) do
		if bankItems[itemID] then
			for _, item in pairs(bankItems[itemID]) do
				quantityNeeded = quantityNeeded - item.quantity
				AutoStoreGuildBankItem(item.tab, item.slot)
				if quantityNeeded < 0 then
					tinsert(tabDelay.list, {item.tab, item.slot, itemID, quantityNeeded*-1})
					tabDelay:Show()
					quantityNeeded = 0
				end
				if quantityNeeded == 0 then break end
			end
		end
		TSM.tasks[1].items[itemID] = nil
	end
	
	doneGathering.type = "GUILDBANK"
	doneGathering:Show()
end

function Gather:PutBackInGbank(tab, slot, itemID, quantity)
	if not tab then return end
	for bag=0, NUM_BAG_SLOTS do
		for bSlot=1, GetContainerNumSlots(bag) do
			local sID = TSMAPI:GetItemID(GetContainerItemLink(bag, bSlot))
			local num = select(2, GetContainerItemInfo(bag, bSlot))
			if sID and sID == itemID and num >= quantity and not TSM:IsSoulbound(bag, bSlot, sID) then
				SplitContainerItem(bag, bSlot, quantity)
				local column, button = ceil(slot/14), (slot-1)%14+1
				_G["GuildBankColumn"..column.."Button"..button]:Click()
				return
			end
		end
	end
end

function Gather:GatherBank(bankItems)
	wipe(toProcess)
	if not TSM.tasks[1].items then return end
	for itemID, quantityNeeded in pairs(TSM.tasks[1].items) do
		if bankItems[itemID] then
			for _, item in pairs(bankItems[itemID]) do
				if item.quantity > quantityNeeded then
					tinsert(toProcess, {bag=item.bag, slot=item.slot, grab=quantityNeeded, left=item.quantity-quantityNeeded})
					quantityNeeded = 0
				else
					quantityNeeded = quantityNeeded - item.quantity
					tinsert(toProcess, {bag=item.bag, slot=item.slot})
				end
				if quantityNeeded == 0 then break end
			end
		end
		TSM.tasks[1].items[itemID] = nil
	end
	
	if toProcess[1] then
		Gather:RegisterEvent("ITEM_LOCKED")
		Gather:RegisterEvent("ITEM_UNLOCKED")
		if toProcess[1].grab then
			SplitContainerItem(toProcess[1].bag, toProcess[1].slot, toProcess[1].grab)
		else
			UseContainerItem(toProcess[1].bag, toProcess[1].slot)
		end
	else
		busy = false
		doneGathering.type = "BANK"
		doneGathering:Show()
	end
end

function Gather:ITEM_LOCKED(_, bag, slot)
	if toProcess[1] and toProcess[1].bag == bag and toProcess[1].slot == slot then
		if toProcess[1].grab then
			if GetContainerNumFreeSlots(0) > 0 then
				PutItemInBackpack()
			else
				for bag=1, NUM_BAG_SLOTS do
					if GetContainerNumFreeSlots(bag) > 0 then
						PutItemInBag(ContainerIDToInventoryID(bag))
					end
				end
			end
		end
		toProcess[1].status = "locked"
	end
end

function Gather:ITEM_UNLOCKED(_, bag, slot)
	if toProcess[1] and toProcess[1].status == "locked" then
		local numLeft = select(2, GetContainerItemInfo(bag, slot))
		if not toProcess[1].left or numLeft == toProcess[1].left then
			tremove(toProcess, 1)
		else
			toProcess[1].grab = numLeft - toProcess[1].left
			toProcess[1].status = "unlocked"
		end
		
		if toProcess[1] then
			if toProcess[1].grab then
				SplitContainerItem(toProcess[1].bag, toProcess[1].slot, toProcess[1].grab)
			else
				UseContainerItem(toProcess[1].bag, toProcess[1].slot)
			end
		else
			busy = false
			Gather:UnregisterEvent("ITEM_LOCKED")
			Gather:UnregisterEvent("ITEM_UNLOCKED")
			doneGathering.type = "BANK"
			doneGathering:Show()
		end
	end
end

function Gather:DoneGathering(event)
	local gotEverything = true
	local stillNeed, gathered = {}, {}

	local currentPlayer = UnitName("player")
	for itemID, data in pairs(totalGather) do
		local inBags = TSM.characters[currentPlayer].bags[itemID] or 0
		gathered[itemID] = data.toGather - (data.inBags - inBags)
		TSM.tasks[1].items[itemID] = data.inBags - inBags
		if inBags < data.inBags then
			stillNeed[itemID] = data.inBags - inBags
			gotEverything = false
		end
	end
	
	if gotEverything then
		TSM:NextTask()
		return
	end

	local freeSlots = 0
	for bag=0, NUM_BAG_SLOTS do
		freeSlots = freeSlots + GetContainerNumFreeSlots(bag)
	end
	
	if freeSlots == 0 then
		local onPlayer = UnitName("player")
		for i, task in ipairs(TSM.tasks) do
			onPlayer = task.player or onPlayer
			if task.location == "MAIL" and onPlayer == currentPlayer then
				for itemID, quantity in pairs(gathered) do
					if task.items[itemID] then
						task.items[itemID] = task.items[itemID] - quantity
						if task.items[itemID] <= 0 then
							tremove(task.items, itemID)
						end
					end
				end
			end
		end
		local canMail = false
		for itemID, quantity in pairs(gathered) do
			if quantity > 0 then
				canMail = true
				break
			end
		end
		
		if canMail then
			tinsert(TSM.tasks, 1, {location="MAIL", items=gathered})
		else
			TSM:Print("Your bags are full and nothing in your bags is ready to be mailed. Please clear some items from your bags and try again.")
		end
	else
		
	end
	
	TSM.GUI:UpdateFrame()
end