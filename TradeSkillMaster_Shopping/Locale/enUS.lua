-- TradeSkillMaster_Shopping Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Shopping/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Shopping", "enUS", true)
if not L then return end

-- Automatic.lua
L["Shopping - Crafting Mats"] = true
L["Shopping will automatically buy materials you need for your craft queue in TradeSkillMaster_Crafting.\n\nNote that all queues will be shopped for so make sure you clear any queues you don't want to buy mats for."] = true
L["Start Shopping for Crafting Mats!"] = true
L["Shopping - Automatic Mode"] = true
L["Skip Current Item"] = true
L["Skips the item currently being shopped for."] = true
L["Exit Automatic Mode"] = true
L["Cancels automatic mode and allows manual searches to resume."] = true
L["Done shopping."] = true

-- Dealfinder.lua
L["Shopping - Dealfinding"] = true
L["Add Item to Dealfinder List:"] = true
L["You can either drag an item into this box, paste (shift click) an item link into this box, or enter an itemID."] = true
L["<Invalid! See Tooltip>"] = true
L["Max Price (Per 1 Item):"] = true
L["The max price (per 1 item) you want to have a Dealfinder scan buy something for. \n\nMust be entered in the form of \"#g#s#c\". For example \"5g24s98c\" would be 5 gold 24 silver 98 copper."] = true
L["Add Item"] = true
L["Scans for all items in your Dealfinder list."] = true
L["Item was already in the Dealfinder list. Price has been overriden (old price was %s)."] = true
L["Edit Selected Item"] = true
L["Scans for all items in your Dealfinder list."] = true
L["Delete Selected Item"] = true
L["Scans for all items in your Dealfinder list."] = true
L["BUY"] = true
L["Buy the next cheapest auction."] = true
L["SKIP"] = true
L["Skip this auction."] = true
L["Run Dealfinder Scan"] = true
L["Configures your Dealfinder list."] = true
L["Configure Dealfinder List"] = true
L["No auctions are under your Dealfinder prices."] = true
L["No more auctions"] = true
L["%s%% above maximum price."] = true
L["%s%% below maximum price."] = true
L["%s below your Dealfinding price."] = true
L["per item"] = true
L["Total Spent this Session:"] = true
L["No more auctions."] = true

-- Destroying.lua
L["Shopping - Milling / Disenchanting / Prospecting"] = true
L["Ivory Ink"] = true
L["Moonglow Ink"] = true
L["Midnight Ink"] = true
L["Lion's Ink"] = true
L["Jadefire Ink"] = true
L["Celestial Ink"] = true
L["Shimmering Ink"] = true
L["Ethereal Ink"] = true
L["Ink of the Sea"] = true
L["Blackfallow Ink"] = true
L["Inferno Ink"] = true
L["Select an ink which you would like to buy for (through milling herbs)."] = true
L["Select an enchanting mat which you would like to buy for (through disenchanting items)."] = true
L["Select a raw gem which you would like to buy for (through prospecting ore)."] = true
L["Even Stacks Only"] = true
L["If checked, when buying ore / herbs only stacks that are evenly divisible by 5 will be purchased."] = true
L["Mode:"] = true
L["Shop for items to Disenchant"] = true
L["Shop for items to Mill"] = true
L["Shop for items to Prospect"] = true
L["Milling"] = true
L["Prospecting"] = true
L["Disenchanting"] = true
L["Buy for:"] = true
L["GO"] = true
L["Start buying!"] = true
L["Total Spent this Session: %s Bought this Session: %sAverage Cost Per  this session: %s"] = true
L["Total Spent this Session: %sRaw Gems Bought this Session: %sAverage Cost Per Raw Gem this session: %s"] = true
L["Total Spent this Session: %sInks Bought this Session: %sAverage Cost Per Ink this session: %s"] = true
L["Total Spent this Session: %sEnchanting Mats Bought this Session: %sAverage Cost Per Enchanting Mat this session: %s"] = true
L["Max Price (optional):"] = true
L["The most you want to pay for something. \n\nMust be entered in the form of \"#g#s#c\". For example \"5g24s98c\" would be 5 gold 24 silver 98 copper."] = true
L["Quantity (optional)"] = true
L["How many you want to buy."] = true
L["Manual controls disabled when Shopping in automatic mode.\n\nClick on the \"Exit Automatic Mode\" button to enable manual controls."] = true
L["BUY"] = true
L["Buy the next cheapest auction."] = true
L["SKIP"] = true
L["Skip this auction."] = true
L["Total Spent this Session: %sAverage Cost Per  this session: %s"] = true
L["Total Spent this Session: %sAverage Cost Per Raw Gem this session: %s"] = true
L["Total Spent this Session: %sAverage Cost Per Ink this session: %s"] = true
L["Total Spent this Session: %sAverage Cost Per Enchanting Mat this session: %s"] = true
L["No auctions for this item."] = true
L["Found %s at this price."] = true
L["%s @ %s(~%s per )"] = true
L["%s @ %s(~%s per Raw Gem)"] = true
L["%s @ %s(~%s per Ink)"] = true
L["%s @ %s(~%s per Enchanting Mat)"] = true
L["Bought at least the max quantity set for this item."] = true
L["Cata - Blue Quality"] = true
L["Cata - Green Quality"] = true
L["BC - Green Quality"] = true
L["BC - Blue Quality"] = true
L["Wrath - Green Quality"] = true
L["Wrath - Blue Quality"] = true
L["Wrath - Epic Quality"] = true

-- General.lua
L["Shopping - General Buying"] = true
L["Name of item to serach for:"] = true
L["What would you like to buy?"] = true
L["No auctions matched \"%s\""] = true
L["No more auctions for this item."] = true
L["Buying: %s(%s at this price)"] = true
L["%s @ %s(%s per)"] = true
L["Total Spent this Session: %sItems Bought This Session: %sAverage Cost Per Item this Session: %s"] = true
L["No auctions found."] = true

-- Scan.lua
L["Auction house must be open in order to scan."] = true
L["Nothing to scan."] = true
L["Shopping - Scanning"] = true
L["Scan interupted due to auction house being closed."] = true
L["Scan interupted due to automatic mode being canceled."] = true