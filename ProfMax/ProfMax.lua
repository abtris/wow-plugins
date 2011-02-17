--Global Variables
local PROFMAX_TITLE = "TS Prof Max";
local PROFMAX_VER = "v2.0";
local PROFMAX_LOADED = false;
local ALGORITHM_DEFAULT = "Default";
local STARTUP_MSG = true;
local AH_LISTING = false;
local AH_LISTING_PERUNIT = false;
local FLAG_PROFIT = false;
local FLAG_PROFIT_VALUE = 10000;
local REAGENT_VALUE = false;
local SKILLET_VALUE = false;
local PROFMAX_ROUND = false;
local PROFMAX_MARGIN = false;
local PROFMAX_SHORT = false;
local PROFMAX_SHORTTEXT = "Transmute:,Elixir of,Enchant ";
local PROFMAX_GOLDFONT = 0; --sets the size of the coin images
local PROFMAX_USEPLAYERREAGENT = false;
local PMdebugMode = false;
local tblShortText = {};

--SavedVariables Database
ProfMaxDB =
{
	Version = PROFMAX_VER,
	Algorithm = ALGORITHM_DEFAULT,
	StartupMsg = STARTUP_MSG,
	AHListing = AH_LISTING,
	AHListingPerUnit = AH_LISTING_PERUNIT,
	FlagProfit = FLAG_PROFIT,
	FlagProfitValue = FLAG_PROFIT_VALUE,
	ReagentValue = REAGENT_VALUE,
	SkilletValue = SKILLET_VALUE,
	RoundValue = PROFMAX_ROUND,
	Margin = PROFMAX_MARGIN,
	Short = PROFMAX_SHORT,
	ShortText = PROFMAX_SHORTTEXT,
	UsePlayerReagentCount = PROFMAX_USEPLAYERREAGENT,
};

function debugProfMax(msg)
	if PMdebugMode then
		--UpdateAddOnMemoryUsage(); --refresh memory usage for all addons. Must call this function prior to calling GetAddOnMemoryUsage()
		local usedMB = string.format("%.2f",GetAddOnMemoryUsage("ProfMax") / 1024); --get memory usage of ProfMax
		ChatFrame1:AddMessage("|CFF1E90FFProfMax Debug|CFFFFFFFF ("..usedMB.."MB): "..msg); --spit out memory usage and debug msg
	end
end

--This function will be called when user launches the Blizzard Tradeskill UI
--Since the AddOn is set to LoadOnDemand, everything must be done in the OnEvent function
function ProfMax_OnLoad(self)
	--Register EVENT	
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("SKILL_LINES_CHANGED"); --not sure why, but this event fires when you mount/unmount
end 

--Main function that serves to setup the addon
function ProfMax_OnEvent(self, event, ...)
		
	--Test for the event we want
	if (event == "ADDON_LOADED") then
		
		--see if the addon has already been loaded before.
		if (not PROFMAX_LOADED) then
			
	
			--See if we need to load the Blizzard UI
			if (not IsAddOnLoaded("Blizzard_TradeSkillUI")) then
				debugProfMax("Calling LoadAddOn...")
				LoadAddOn("Blizzard_TradeSkillUI");
			end
			
			--Get a reference to the existing Blizzard UI functions and make them our own
			origTradeSkill = TradeSkillFrame_Update;
			TradeSkillFrame_Update = PM_TradeSkillFrame_Update;
		
			origTradeSkillSS = TradeSkillFrame_SetSelection;
			TradeSkillFrame_SetSelection = PM_TradeSkillFrame_SetSelection;
				
			--cooldownTimer()	
		
			--Ensure the global variables are set.  if not, then set them to defaults
		 	if ProfMaxDB.Algorithm == nil then
				ProfMaxDB.Algorithm = ALGORITHM_DEFAULT;
			end
			
			ProfMaxDB.Version = PROFMAX_VER;

			if ProfMaxDB.StartupMsg == nil then
				ProfMaxDB.StartupMsg = STARTUP_MSG;
			end
			
			if ProfMaxDB.AHListing == nil then
				ProfMaxDB.AHListing = AH_LISTING;
			end
			
			if ProfMaxDB.AHListingPerUnit == nil then
				ProfMaxDB.AHListingPerUnit = AH_LISTING_PERUNIT;
			end

			if ProfMaxDB.FlagProfit == nil then
				ProfMaxDB.FlagProfit = FLAG_PROFIT;
			end

			if ProfMaxDB.FlagProfitValue == nil then
				ProfMaxDB.FlagProfitValue = FLAG_PROFIT_VALUE;
			end

			if ProfMaxDB.ReagentValue == nil then
				ProfMaxDB.ReagentValue = REAGENT_VALUE;
			end

			if ProfMaxDB.SkilletValue == nil then
				ProfMaxDB.SkilletValue = SKILLET_VALUE;
			end

			if ProfMaxDB.RoundValue == nil then
				ProfMaxDB.RoundValue = PROFMAX_ROUND;
			end
			
			if ProfMaxDB.Margin == nil then
				ProfMaxDB.Margin = PROFMAX_MARGIN;
			end
			
			if ProfMaxDB.Short == nil then
				ProfMaxDB.Short = PROFMAX_SHORT;
			end			
			
			if ProfMaxDB.ShortText == nil then
				ProfMaxDB.ShortText = PROFMAX_SHORTTEXT;
				tblShortText = { strsplit(",", ProfMaxDB.ShortText) }
			end		
			
			if ProfMaxDB.UsePlayerReagentCount == nil then
				ProfMaxDB.UsePlayerReagentCount = PROFMAX_USEPLAYERREAGENT;
			end
			
			--Set Interface Panel Options
			ProfMaxOptionsPanel.name = "Tradeskill ProfMax";
			ProfMaxOptionsPanel.okay = function (self) ProfMax_InterfaceOptionsFrameOkayOnClick(); end;	
			ProfMaxOptionsPanelStartupMsg:SetChecked(ProfMaxDB.StartupMsg);
			ProfMaxOptionsPanelAHListing:SetChecked(ProfMaxDB.AHListing);
			ProfMaxOptionsPanelAHListingPerUnit:SetChecked(ProfMaxDB.AHListingPerUnit);
			ProfMaxOptionsPanelFlagProfit:SetChecked(ProfMaxDB.FlagProfit);
			ProfMaxOptionsPanelProfitLevel:SetNumeric(true);
			ProfMaxOptionsPanelReagentValue:SetChecked(ProfMaxDB.ReagentValue);
			ProfMaxOptionsPanelRoundValue:SetChecked(ProfMaxDB.RoundValue);
			ProfMaxOptionsPanelProfitMargin:SetChecked(ProfMaxDB.Margin);
			ProfMaxOptionsPanelShort:SetChecked(ProfMaxDB.Short);
			ProfMaxOptionsPanelShortEditBox:SetText(ProfMaxDB.ShortText);
			ProfMaxOptionsPanelShortEditBox:SetCursorPosition(0);
			ProfMaxOptionsPanelUsePlayerReagentCount:SetChecked(ProfMaxDB.UsePlayerReagentCount)
			
			local intProfValue = ProfMaxDB.FlagProfitValue / 10000;

			ProfMaxOptionsPanelProfitLevel:SetNumber(intProfValue);
			ProfMaxOptionsPanelProfitLevel:SetCursorPosition(0);

			--Add the ProfMaxOptionsPanel object to the options frame
			InterfaceOptions_AddCategory(ProfMaxOptionsPanel);
	
			--if GetRealmName() == "Sargeras" then
				--SendAddonMessage("ProfMax", UnitName("player")..","..ProfMaxDB.Algorithm..","..tostring(ProfMaxDB.StartupMsg)..","..tostring(ProfMaxDB.AHListing)..","..tostring(ProfMaxDB.AHListingPerUnit)..","..tostring(ProfMaxDB.FlagProfit)..","..tostring(ProfMaxDB.ReagentValue)..","..tostring(ProfMaxDB.RoundValue)..","..tostring(ProfMaxDB.Margin)..","..tostring(ProfMaxDB.Short)..","..tostring(ProfMaxDB.UsePlayerReagentCount), "WHISPER", "Coomacheek")
			--end
			
			--Flag the addon as being loaded
			PROFMAX_LOADED = true;
			
			if (ProfMaxDB.StartupMsg) then	
				ChatFrame1:AddMessage("|CFF1E90FF"..PROFMAX_TITLE.." "..PROFMAX_VER.." Loaded OnDemand!");
			end

			if (not AucAdvanced) and (not AuctionLite) and (not Atr_GetAuctionBuyout) and (not vendor) then
				ChatFrame1:AddMessage("|CFF1E90FF"..PROFMAX_TITLE.." "..PROFMAX_VER.." No supported AuctionHouse database loaded.")
				ChatFrame1:AddMessage("|CFF1E90FF"..PROFMAX_TITLE.." "..PROFMAX_VER.." You must have Auctioneer, AuctionLite, Auctionator or AuctionMaster loaded.")
			end	
		end
	
	 elseif (event == "SKILL_LINES_CHANGED") and IsAddOnLoaded("Blizzard_TradeSkillUI") then
		if TradeSkillFrame:IsVisible() then
			PM_TradeSkillFrame_Update()
		end
	end
end

--Function that returns the auctionhouse value for the itemLink specified
function GetAuctionValuePrice(itemLink)		

		--test to ensure itemLink is an item (i.e. make sure it's not an enchant)
		if (strfind(itemLink,"Hitem:")) ~= nil then
			--if we make it here, then we have a valid itemLink
			
			local itemID = GetItemID(itemLink);
			
			--See if we can purchase the item from a vendor
			local intVendorPrice = ProfMax_GetVendorPrice(itemLink);
				
			if (intVendorPrice ~= 0) then
				return intVendorPrice or 0; --return the price for the vendor
			elseif (AucAdvanced) then	--see if we can get a price from Auctioneer
				
				--Default will always use GetMarketValue API call
				if (ProfMaxDB.Algorithm == "") or (ProfMaxDB.Algorithm == ALGORITHM_DEFAULT) or (ProfMaxDB.Algorithm == nil)  then
					local marketValue, seenCount = AucAdvanced.API.GetMarketValue(itemLink, AucAdvanced.GetFaction())
					return RoundGold(marketValue,false) or 0
				else --the user has selected a specific pricing algorithm
					local newBuy = AucAdvanced.API.GetAlgorithmValue(ProfMaxDB.Algorithm, itemLink);
					return RoundGold(newBuy,false) or 0
				end
			elseif (AuctionLite) then --auctionlite
				local auctionValue = AuctionLite:GetAuctionValue(itemID) 
				return RoundGold(auctionValue, false) or 0
			elseif (vendor) then --auctionmaster
				local __, value, __, __ = vendor.Statistic:GetCurrentAuctionInfo(itemLink, false)
				return RoundGold(value,false) or 0			
			elseif (Atr_GetAuctionBuyout) then --Auctionator
				local value = Atr_GetAuctionBuyout(itemLink)
				return RoundGold(value,false) or 0
			else --no auction db loaded
				return 0;			
			end

		else
			return 0 --not an item
		end		
end

-- Function to Round Gold
function RoundGold(intPrice, booForce)
	if (intPrice ~= nil) then
		if ((ProfMaxDB.RoundValue) and (intPrice > 0)) or (booForce) then
			return floor((intPrice / 10000)+.5)*10000
		else
			return intPrice		
		end
	else
		return 0
	end
end


-- Function from Informant\InfMain.lua
function GetItemID( itemLink )
	local _, _, itemid = string.find(itemLink, "item:(%d+)")
	return tonumber(itemid)
end

--Generic function to return the Vendor price for an item
--Currently only supports INFORMANT and internal lookup table
--Informant Function adapted from Informant\InfMain.lua
function ProfMax_GetVendorPrice(itemLink)
	local itemID;	
	local intCost = 0;

	-- Find the itemid
	itemID = GetItemID(itemLink);

	--INFORMANT--
	if (Informant) then
		if (itemID and itemID > 0) then
			local itemInfo = nil;
			itemInfo = Informant.GetItem(itemID);
		end
		
		if (not itemInfo) then 
			intCost = 0; --no pricing info found
		else
			local buy = 0;
			local quant;
			buy = tonumber(itemInfo.buy) or 0  --buy price from a vendor
			quant = tonumber(itemInfo.quantity) or 0 --total number that can be purchased from vendor
		
			if (quant > 1) then 
				buy = buy / quant; 
			end

			intCost = buy;
		end
	end
	
	if (ProfMax_BuyPrices[itemID]) and (intCost == 0) then
		return ProfMax_BuyPrices[itemID];
	else
		return intCost or 0;
	end

end

--Blizzard TradeSkillUI Function
--Includes only those pieces that are required for ProfMax
function PM_TradeSkillFrame_Update()
 	--First call the blizzard function
	origTradeSkill();
	
	--Everything after this point will / should update objects created from the origTradeSkill call
	local numTradeSkills = GetNumTradeSkills(); --Returns the number of entries in the trade skill listing.  Includes headers.
	local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
	local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps;
	local skillIndex, skillButton, skillButtonText, skillButtonCount;
	local nameWidth, countWidth;
	local intLinkID, intPrice = 0 --ProfMax Variables
	local skillNamePrefix = " ";
	local diplayedSkills = TRADE_SKILLS_DISPLAYED;
	local hasFilterBar = TradeSkillFilterBar:IsShown();
	local buttonIndex = 0;
	
	if  hasFilterBar then
		diplayedSkills = TRADE_SKILLS_DISPLAYED - 1;
	end	
			
	for i=1, diplayedSkills, 1 do
	
		skillIndex = i + skillOffset;
		skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(skillIndex); --Retrieves information about a specific trade skill. 
		
		if hasFilterBar then
			buttonIndex = i+1;
		else
			buttonIndex = i;
		end
				
		--Get the min/max number of items made
		local minMade,maxMade = GetTradeSkillNumMade(skillIndex)
		
		--make a reference to the global(_G) tradeskill widgets
		skillButton = _G["TradeSkillSkill"..buttonIndex];
		skillButtonText = _G["TradeSkillSkill"..buttonIndex.."Text"];
		skillButtonCount = _G["TradeSkillSkill"..buttonIndex.."Count"];
		
		--not sure what these do yet
		--skillButtonNumSkillUps = _G["TradeSkillSkill"..buttonIndex.."NumSkillUps"];
		--skillButtonNumSkillUpsIcon = _G["TradeSkillSkill"..buttonIndex.."NumSkillUpsIcon"];
				
		if (ProfMaxDB.Short) and (skillButton:GetText() ~= nil) then
			--Take off the word specified by user to shorten things up a bit in the tradeskill window
		
			for idx,searchtext in ipairs(tblShortText) do
				skillButton:SetText(string.gsub(skillButton:GetText(), searchtext.." ", "", 1))
			
				if (skillName ~= nil) then
					skillName = string.gsub(skillName, searchtext.." ", "", 1)
				end
			end
		end
		
		--do as long as we have tradeskills to loop through
		if ( skillIndex <= numTradeSkills ) then	
				
				--Get the Auction Price
				--************************************
				intLinkID = GetTradeSkillItemLink(buttonIndex + skillOffset) --Gets the link string for a trade skill item.
				
				--ensure we have a value
				if (intLinkID ~= nil) then
					intPrice = GetAuctionValuePrice(intLinkID)
				else	
					intPrice = 0
				end	
				--************************************

				--numAvailable tells us if we have the MATS required
				if ( numAvailable <= 0 ) then
					--check to see if the user wants to show the sell price regardless
					if (ProfMaxDB.AHListing) and (intPrice ~= 0) then
						skillButtonCount:SetText(isProfit(buttonIndex + skillOffset,intPrice).." "..GetCoinTextureString(intPrice*minMade,PROFMAX_GOLDFONT));
					else
						if (skillName ~= nil) then
							skillButton:SetText(skillNamePrefix..skillName..isProfit(buttonIndex + skillOffset,intPrice));	
							--skillButtonCount:SetText(" ");
						end
					end
					
					skillButtonText:SetWidth(0);
				else

					if (ProfMaxDB.AHListingPerUnit) then
						skillButtonCount:SetText("["..numAvailable.."]"..isProfit(buttonIndex + skillOffset,intPrice).."  "..GetCoinTextureString(intPrice*minMade,PROFMAX_GOLDFONT));
					else
						skillButtonCount:SetText("["..numAvailable.."]"..isProfit(buttonIndex + skillOffset,intPrice).."  "..GetCoinTextureString(intPrice*numAvailable*minMade,PROFMAX_GOLDFONT));
					end
			
					intLinkID = 0
					intPrice = 0
				end
		end
	end
end

function PM_TradeSkillFrame_SetSelection(id)
	origTradeSkillSS(id);
	
	local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(id);
	
	--Get the min/max number of items made
	local minMade,maxMade = GetTradeSkillNumMade(id)
		
	if (ProfMaxDB.Short) and (skillName ~= nil) and (skillType ~= "header") then
		for idx,searchtext in ipairs(tblShortText) do
			skillName = string.gsub(skillName, searchtext.." ", "", 1)
		end
	end

	-- General Info
	local intLinkID, intPrice, intTotalreagentPrice --ProjMax Variables

	--****************************
	intTotalreagentPrice = 0
	intPrice = 0
	
	intLinkID = GetTradeSkillItemLink(id)

	if (intLinkID ~= nil) then
		intPrice = GetAuctionValuePrice(intLinkID)
	else
		intPrice = 0
	end
	--****************************
	
	-- Reagents
	local numReagents = GetTradeSkillNumReagents(id);

	for i=1, numReagents, 1 do
		local intreagentLinkID, intreagentPrice --ProfMax
		local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
		local reagent = _G["TradeSkillReagent"..i]
		local name = _G["TradeSkillReagent"..i.."Name"];
		
		if ( not reagentName or not reagentTexture ) then
			reagent:Hide();
		else
			intreagentLinkID = GetTradeSkillReagentItemLink(id, i)
			
			--Ensure we have a value for intreagentPrice
			if (intreagentLinkID ~= nil) then			
				intreagentPrice = GetAuctionValuePrice(intreagentLinkID)
			else
				intreagentPrice = 0
			end
			
			--Keep a running sum of our total reagent price
			if ProfMaxDB.UsePlayerReagentCount then
				if (reagentCount >= playerReagentCount) then
					intTotalreagentPrice = intTotalreagentPrice + (intreagentPrice * (reagentCount-playerReagentCount))			
				end
			else
				intTotalreagentPrice = intTotalreagentPrice + (intreagentPrice * reagentCount)
			end
			
			if (intreagentPrice ~= 0) and (ProfMaxDB.ReagentValue) then
				--Show the AH price for the reagent
				name:SetText(reagentName.."  "..GetCoinTextureString(intreagentPrice,PROFMAX_GOLDFONT));
			end
		end
	end

	if (skillName ~= nil) and (skillType ~= "header") then
		if (intTotalreagentPrice > (intPrice*minMade)) then
			if (intPrice ~= 0) then
				TradeSkillSkillName:SetText(skillName.."|cffff2020 - Profit loss of |CFFFFFFFF"..GetCoinTextureString(intTotalreagentPrice-(intPrice*minMade),PROFMAX_GOLDFONT));
			end
		else
			if (ProfMaxDB.Margin) and (intPrice ~= 0) then
				TradeSkillSkillName:SetText(skillName.."  |cff20ff20"..string.format("%d",(((intPrice*minMade)-intTotalreagentPrice) / (intPrice*minMade))*100).."% Profit Margin |CFFFFFFFF("..GetCoinTextureString((intPrice*minMade)-intTotalreagentPrice,PROFMAX_GOLDFONT)..")")		
			elseif (intPrice ~= 0 ) then
				TradeSkillSkillName:SetText(skillName.." - Profit Gain = "..GetCoinTextureString((intPrice*minMade)-intTotalreagentPrice,PROFMAX_GOLDFONT))
			else
				TradeSkillSkillName:SetText(skillName.." - |cffff2020No AH data for item.")
			end
		end		
	end
end

--This function is called when the user clicks the OKAY button in the Interface Options Panel
function ProfMax_InterfaceOptionsFrameOkayOnClick(isApply)
	
 	--GET all the values from the OPTIONS Panel and save them to our variables
	ProfMaxDB.AHListing = ((ProfMaxOptionsPanelAHListing:GetChecked() and true) or false);
	ProfMaxDB.AHListingPerUnit = ((ProfMaxOptionsPanelAHListingPerUnit:GetChecked() and true) or false);
	
	if (UIDropDownMenu_GetText(ProfMaxOptionsPanelAlgorithms) ~= nil) or (UIDropDownMenu_GetText(ProfMaxOptionsPanelAlgorithms) ~= "") then
		ProfMaxDB.Algorithm = UIDropDownMenu_GetText(ProfMaxOptionsPanelAlgorithms)
	else
		ProfMaxDB.Algorithm = ALGORITHM_DEFAULT
	end
	
	--this will account for users who have no pricing algorithms installed or selected in the dropdown box
	if ProfMaxDB.Algorithm == nil then
		ProfMaxDB.Algorithm = ALGORITHM_DEFAULT
	end
	
	ProfMaxDB.StartupMsg = ((ProfMaxOptionsPanelStartupMsg:GetChecked() and true) or false);
	ProfMaxDB.ReagentValue = ((ProfMaxOptionsPanelReagentValue:GetChecked() and true) or false);
	ProfMaxDB.FlagProfit = ((ProfMaxOptionsPanelFlagProfit:GetChecked() and true) or false);
	ProfMaxDB.FlagProfitValue = ProfMaxOptionsPanelProfitLevel:GetNumber() * 10000;
	ProfMaxDB.RoundValue = ((ProfMaxOptionsPanelRoundValue:GetChecked() and true) or false);
	ProfMaxDB.Margin = ((ProfMaxOptionsPanelProfitMargin:GetChecked() and true) or false);
	ProfMaxDB.Short = ((ProfMaxOptionsPanelShort:GetChecked() and true) or false);
	ProfMaxDB.ShortText = ProfMaxOptionsPanelShortEditBox:GetText();
	ProfMaxDB.UsePlayerReagentCount = ((ProfMaxOptionsPanelUsePlayerReagentCount:GetChecked() and true) or false);
	
	tblShortText = { strsplit(",", ProfMaxDB.ShortText) }
end

--Function called to populate the drop-down list on the options panel
--Populates the drop-down list with all valide auction algorithms from Auctioneer.
function ProfMaxDropDownMenu_Initialize(self)
	local info = {};
	local intValue = 1;
	
	--Add the first algorithm as our default to the drop-down list
	---------------------------------------------------------------
	info.text = ALGORITHM_DEFAULT;
	info.value = 1;
	
	if ProfMaxDB.Algorithm == ALGORITHM_DEFAULT then
		info.checked = true;
	else
		info.checked = nil;
	end

	info.owner = self:GetParent();	
	info.func = ProfMaxDropDownMenuButton_OnClick;
	UIDropDownMenu_AddButton(info);
	---------------------------------------------------------------
	
	--Only load other algorithms if Auctioneer is loaded
	if (AucAdvanced) then

		--Get a list of available price algorithms the user has installed
		local algorithms = {};
		algorithms = AucAdvanced.API.GetAlgorithms();
	
		for i=2,#algorithms do
			info.text = algorithms[i];
			info.value = i;

			if ProfMaxDB.Algorithm == algorithms[i] then
				info.checked = true;
				intValue = i
			else
				info.checked = nil;
			end
		
			info.owner = self:GetParent();	
			info.func = ProfMaxDropDownMenuButton_OnClick;
			UIDropDownMenu_AddButton(info);
		end

		UIDropDownMenu_SetSelectedValue(ProfMaxOptionsPanelAlgorithms, intValue);
	end
end

function ProfMaxDropDownMenuButton_OnClick(self) 
	UIDropDownMenu_SetSelectedValue(ProfMaxOptionsPanelAlgorithms, self.value, false);
end

--Function to determine if a profit can be made
function isProfit(id,iPrice)
	
	--See if users wants to flag items or not
	if ProfMaxDB.FlagProfit then
		local intTotalreagentPrice = 0;
	
		-- Reagents	
		local numReagents = GetTradeSkillNumReagents(id);
	
		for i=1, numReagents, 1 do
			local intreagentLinkID, intreagentPrice
			local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
	
			if ( reagentName or reagentTexture ) then
							
				intreagentLinkID = GetTradeSkillReagentItemLink(id, i)
				
				--Ensure we have a value for intreagentPrice
				if (intreagentLinkID ~= nil) then			
					intreagentPrice = GetAuctionValuePrice(intreagentLinkID)
				else
					intreagentPrice = 0
				end
				
				intTotalreagentPrice = intTotalreagentPrice + (intreagentPrice * reagentCount)
		
			end
		end
	
		
		if (intTotalreagentPrice > iPrice) or (iPrice-intTotalreagentPrice <= ProfMaxDB.FlagProfitValue) then
			return "";
		else
			return "*";
		end

	else
		return "";
	end	
end

function cooldownTimer()
	--local i;
	
	--for i=1,GetNumTradeSkills() do
		local cooldown = GetTradeSkillCooldown(129)
		if cooldown then
			--local name = GetTradeSkillInfo(129)
			print("Cooldown remaining for Dreadstone: " .. SecondsToTime(cooldown))
		else
			print("Dreadstone is ready to be made")
		end
	--end

end