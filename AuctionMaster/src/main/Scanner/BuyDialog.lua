--[[
	Copyright (C) Udorn (Blackhand)
	
	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.	
--]]

--[[
	Asks the user for confirmation to buy a list of auctions.
--]]
vendor.BuyDialog = {}
vendor.BuyDialog.prototype = {}
vendor.BuyDialog.metatable = {__index = vendor.BuyDialog.prototype}

local log = vendor.Debug:new("BuyDialog")

local L = vendor.Locale.GetInstance()

local FRAME_HEIGHT = 300
local FRAME_WIDTH = 450
local TABLE_WIDTH = FRAME_WIDTH - 10
local TABLE_HEIGHT = FRAME_HEIGHT - 45
local TABLE_X_OFF = 5
local TABLE_Y_OFF = -40

--[[
	Wait until the user made a decison.
--]]
local function _WaitForDecision(self)
	while (not self.decisionMade) do
		coroutine.yield()
	end	
end

local function _OnOk(self)
	vendor.Scanner:PlaceAuctionBid(self.ahType, self.auctions)
	self.decisionMade = 1
	self:Hide()
end

local function _OnCancel(self)
	self.decisionMade = 0
	self:Hide()
end

--[[
	Initilaizes the frame.
--]]
local function _InitFrame(self)
	local frame = CreateFrame("Frame", nil, UIParent, "VendorDialogTemplate")
	frame.obj = self
	self.frame = frame
	frame:SetWidth(FRAME_WIDTH)
	frame:SetHeight(FRAME_HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:SetScript("OnMouseDown", function() this:StartMoving() end)
	frame:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
				
	-- intro text
	local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetPoint("TOPLEFT", 5, -10)
	text:SetText(L["Do you want to bid on the following auctions?"])
	
	-- auctions table
	local itemModel = vendor.ScannerItemModel:new(true)
	self.itemModel = itemModel
	itemModel.descriptors[vendor.ScannerItemModel.REASON].minWidth = 70
	itemModel.descriptors[vendor.ScannerItemModel.REASON].weight = 15
	local itemTableCfg = {
		rowHeight = 20,
		selected = {
			[1] = vendor.ScannerItemModel.TEXTURE,
			[2] = vendor.ScannerItemModel.NAME,
			[3] = vendor.ScannerItemModel.REASON,
			[4] = vendor.ScannerItemModel.BID,
			[5] = vendor.ScannerItemModel.BUYOUT
		},
	}
	
	local cmds = {
		[1] = {
			title = L["Ok"],
    		arg1 = self,
    		func = _OnOk,
    	},
    	[2] = {
    		title = L["Cancel"],
    		arg1 = self,
    		func = _OnCancel,
    	},
	}
	local cfg = {
		name = "AMBuyDialogAuctions",
		parent = frame,
		itemModel = itemModel,
		cmds = cmds,
		config = itemTableCfg,
		width = TABLE_WIDTH,
		height = TABLE_HEIGHT,
		xOff = TABLE_X_OFF,
		yOff = TABLE_Y_OFF,
		sortButtonBackground = true,
	}
	local itemTable = vendor.ItemTable:new(cfg)
	self.itemTable = itemTable
end

--[[ 
	Creates a new instance.
--]]
function vendor.BuyDialog:new()
	local instance = setmetatable({}, self.metatable)
	_InitFrame(instance)
	instance.frame:Hide()
	return instance
end

--[[
	Asks the user to buy or bid the given item and performs it.
--]]
--function vendor.BuyDialog.prototype:AskToBuy(itemLink, count, minBid, bidAmount, minIncrement, buyout, reason, index, doBid, doBuyout, highBidder)
--	local isShown = self.frame:IsShown();
--	local bid = math.max(minBid, bidAmount or 0)
--	self.scanFrame:Hide();
--	self.buyFrame:Show()
--	if (doBid or doBuyout) then
--		log:Debug("doBid: %s doBuyout: %s", doBid or "false", doBuyout or "false")
--		self.buyGrp:Hide()
--		self.ackBuyGrp:Show()
--	else
--		log:Debug("doBid and doBuyout where not set")
--		self.buyGrp:Show()
--		self.ackBuyGrp:Hide()
--	end
--	if (highBidder) then
--		self.doBidBt:Disable()
--	else
--		self.doBidBt:Enable()
--	end
--	self.doBuyoutBt:Disable();
--	self.bid = math.max(minBid, (bidAmount or 0) + (minIncrement or 0))
--	self.buyout = buyout;
--	self.doBid = doBid
--	self.doBuyout = doBuyout
--	self.index = index;
--	self.count = count;
--	if (itemLink) then
--		local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
--		if (itemName) then
--			self.itemIcon:SetNormalTexture(itemTexture);
--			self.itemName:SetText(itemName);
--			if (count > 1) then
--				self.itemCount:SetText(count);
--				self.itemCount:Show();
--			else
--				self.itemCount:Hide();
--			end
--			self.itemLink = itemLink;
--			if (bid and bid > 0) then
--				if (count > 1) then
--					self.bidBt:SetText(vendor.Format.FormatMoneyValues(bid / count, bid));
--				else
--					self.bidBt:SetText(vendor.Format.FormatMoney(bid));
--				end
--			else
--				self.bidBt:SetText("")
--			end
--			if (buyout and buyout > 0) then
--				if (count > 1) then
--					self.buyoutBt:SetText(vendor.Format.FormatMoneyValues(buyout / count, buyout));
--				else
--					self.buyoutBt:SetText(vendor.Format.FormatMoney(buyout));
--				end
--			else
--				self.buyoutBt:SetText("")
--			end
--			self.reasonTxt:SetText(reason);
--			self.decisionMade = nil;
--			self.name = itemName;
--			if (buyout and buyout > 0) then
--				self.doBuyoutBt:Enable();
--			end
--			PlaySound("AuctionWindowOpen")
--			self.frame:Show();
--			_WaitForDecision(self);
--			if (not isShown) then
--				self.frame:Hide();
--			end
--		end
--	end
--	self.scanFrame:Show();
--	self.buyFrame:Hide();
--end

--[[
	Opens the dialog and shows the given auctions. Returns true, if the user bought them.
--]]
function vendor.BuyDialog.prototype:AskToBuy(ahType, auctions)
	log:Debug("AskToBuy enter")
	self.decisionMade = nil
	self.ahType = ahType
	self.auctions = auctions
	local itemModel = self.itemModel
	itemModel:Clear()
	log:Debug("AskToBuy 1")
	for i=1,#auctions do
		local info = auctions[i]
		itemModel:AddItem(info.itemLink, info.itemLinkKey, info.name, info.texture, info.timeLeft, info.count, 
			info.minBid, 0, info.buyout, info.bidAmount, "", info.reason, "", 0, info.quality)
	end
	log:Debug("AskToBuy 2")
	self.frame:Show()
	self.itemTable:Show()
	log:Debug("AskToBuy 3")
	_WaitForDecision(self)
	log:Debug("AskToBuy 4")
	return (self.decisionMade and (1 == self.decisionMade)) 
end

--[[
	Hides the dialog frame.
--]]
function vendor.BuyDialog.prototype:Hide()
	self.frame:Hide();
end

--[[
	Returns whether the dialog is visible
--]]
function vendor.BuyDialog.prototype:IsVisible()
	return self.frame:IsVisible()
end
