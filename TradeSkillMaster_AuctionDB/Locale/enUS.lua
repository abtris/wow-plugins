local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "enUS", true)
if not L then return end

-- TradeSkillMaster_AuctionDB.lua
L["AuctionDB"] = true
L["resets the data"] = true
L["AuctionDB Market Value:"] = true
L["AuctionDB Min Buyout:"] = true
L["AuctionDB Seen Count:"] = true
L["Enable display of AuctionDB data in tooltip."] = true
L["Item Lookup:"] = true
L["No data for that item"] = true
L["%s has a market value of %s and was seen %s times last scan and %s times total. The stdDev is %s."] = true

-- Scanning.lua
L["Enchanting"] = true
L["Inscription"] = true
L["Jewelcrafting"] = true
L["Alchemy"] = true
L["Blacksmithing"] = true
L["Leatherworking"] = true
L["Tailoring"] = true
L["Engineering"] = true
L["Cooking"] = true
L["Complete AH Scan"] = true
L["AuctionDB - Run Scan"] = true
L["Ready in %s min and %s sec"] = true
L["Not Ready"] = true
L["Ready"] = true
L["AuctionDB - Auction House Scanning"] = true
L["Run Scan"] = true
L["Starts scanning the auction house based on the below settings.\n\nIf you are running a GetAll scan, your game client may temporarily lock up."] = true
L["Run GetAll Scan if Possible"] = true
L["If checked, a GetAll scan will be used whenever possible.\n\nWARNING: With any GetAll scan there is a risk you may get disconnected from the game."] = true
L["GetAll Scan:"] = true
L["Run GetAll Scan"] = true
L["Run Regular Scan"] = true
L["Professions to scan for:"] = true
L["If checked, a regular scan will scan for this profession."] = true
L["Auction house must be open in order to scan."] = true
L["AuctionDB - Scanning"] = true
L["Nothing to scan."] = true
L["Error: AuctionHouse window busy."] = true
L["AuctionDB - Scanning"] = true
L["Scan interupted due to auction house being closed."] = true
L["Scan complete!"] = true
L["|cffff0000WARNING:|r As of 4.0.1 there is a bug with GetAll scans only scanning a maximum of 42554 auctions from the AH which is less than your auction house currently contains. As a result, thousands of items may have been missed. Please use regular scans until blizzard fixes this bug."] = true
