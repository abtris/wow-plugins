local L = LibStub("AceLocale-3.0"):NewLocale("AuctionMaster", "enUS", true)
if (L) then
	-- AuctionMaster main section
	L["AuctionMaster"] = true
	L["Toggles the debugging mode."] = true
	L["Debug"] = true
	L["Configuration"] = true
	L["Opens a configuration window."] = true
	L["Developer"] = true
	L["Locale"] = true
	L["Selects the locale to be used for AuctionMaster. Reload of the UI with /rl needed."] = true
	L["Error: %s"] = true
	L["Activated"] = true
	L["auctionmaster_conf_help"] = "This is the configuration area of AuctionMaster. The several configurable modules, will be visible if you press the \"+\" button beneath the AuctionMaster title on the left side.\n\nIf you can't find the desired configuration option, you can simply ask for it in the AuctionMaster forum on wow.curse.com.\n\nIf you want to help improving AuctionMaster by adding new tranlations or correcting the existing ones, please contact me on wow.curse.com."
	L["Release notes"] = true
	L["Opens the documentation for AuctionsMaster."] = true
	L["Shows the release notes for AuctionsMaster."] = true
	L["Resets the complete database of AuctionMaster. This will set everything to it's default values. The GUI will be restarted for refreshing all modules of AuctionMaster."] = true
	L["Reset"] = true
	L["Do you really want to reset the AuctionMaster database? All data gathered will be lost!"] = true

	-- auction house
	L["AuctionHouse"] = true
	L["Start tab"] = true
	L["Tab to be selected when opening the auction house."] = true
	L["Snipe"] = true
	L["Scan"] = true
	L["Browse"] = true
	L["Bids"] = true
	L["Auctions"] = true
	L["Close"] = true
	L["Opens a window to select maximum prices for an item\nto be sniped during the next auction house scans."] = true
	L["Starts to scan the auction house to update\nstatistics and snipe for items."] = true
	L["Opens a configuration dialog for AuctionMaster."] = true
	L["Toggle position"] = true
	L["Left click for starting/stopping scan.\nRight click for selecting preferred scan mode."] = true
	L["Left click for starting/stopping scan.\nRight click for opening the scan window."] = true
	L["Please select a scan mode first. You can do that with a right click on the portrait icon."] = true
	L["Help"] = true
	L["New AuctionMaster release available"] = "New AuctionMaster release installed"
	L["Tiny"] = true
	L["Very small"] = true
	L["Small"] = true
	L["Medium"] = true
	L["Large"] = true
	L["Extra large"] = true
	L["Deactivated"] = true
	L["Size"] = true
	L["Columns"] = true
	L["Texture"] = true
		
	-- scanner
	L["Found no auctions, press \"Refresh\" to update the list."] = true
	L["Itms."] = true
	L["Stop"] = true
	L["There is already a running scan."] = true
	L["Name"] = true
	L["Seller"] = true
	L["Bid"] = true
	L["Buyout"] = true
	L["Auction Scan"] = true
	L["Scan page %d/%d\nPer page %.2f sec\nEstimated time remaining: %s"] = true
	L["Scan page %d/%d"] = true
	L["Finished scan"] = true
	L["Scanner"] = true
	L["Poor"] = true
	L["Common"] = true
	L["Uncommon"] = true
	L["Rare"] = true
	L["Epic"] = true
	L["Legendary"] = true
	L["Artifact"] = true
	L["Minimum quality"] = true
	L["Selects the minimum quality for items to be scanned in the auction house."] = true
	L["Resets the database of scan snapshots for the current realm and server."] = true
	L["Database of scan snapshots for current realm and server where reset."] = true
	L["Continue"] = true
	L["Pause"] = true
	L["Pauses any snipes for the current scan."] = true
	L["Opens the snipe dialog for this item."] = true
	L["Scan auction %s/%s - time left: %s"] = true
	L["Reason"] = true
	L["Scan finished after %s"] = true
	L["Do you want to bid on the following auctions?"] = true
	L["Buy confirmation"] = true
	L["Buy"] = true
	L["GetAll"] = true
	L["Enables the \"GetAll\" scan. This is faster, but may cause disconnects. Deactivate it, if you encounter disconnects during scans."] = true
	L["Performing getAll scan. This may last up to several minutes..."] = true
	L["Aborts the current scan."] = true
	L["Scans the auction house for updating statistics and sniping items. Uses a fast \"GetAll\" scan, if the scan button is displayed with a green background. This is only possible each 15 minutes."] = true
	L["Speed"] = true
	L["Too high scan speed may lead to disconnects. You should lower it, if you encounter problems."] = true
	L["off"] = true
	L["slow"] = true
	L["easy"] = true
	L["fast"] = true
	L["hurry"] = true
				
	-- seller
	L["Can't create stack of %d items, not enough available in inventory."] = true
	L["Found no empty bag place for building a new stack."] = true
	L["Error while picking up item."] = true
	L["Failed to create stack of %d items."] = true
	L["Per item"] = true
	L["Stack"] = "Per stack"
	L["Overall"] = true
	L["Fixed price"] = true
	L["Average price"] = true
	L["Market price"] = true
	L["Undercut"] = true
	L["Buyout < bid"] = true
	L["Starting Price"] = true
	L["Buyout Price"] = true
	L["optional"] = true
	L["Deposit:"] = true
	L["Create Auction"] = true
	L["Refresh"] = true
	L["Failed to sell item"] = true
	L["Auction Item"] = true
	L["Auction Duration"] = true
	L["Stack size"] = true
	L["Amount"] = true
	L["Price calculation"] = true
	L["Bid type"] = true
	L["Drag an item here to auction it"] = true
	L["Selects the size of the stacks to be sold."] = true
	L["Selects the number of stacks to be sold.\nThe number with the +-suffix sells\nalso any remaining items."] = true
	L["Selects the mode for calculating the sell prices.\nThe default mode Fixed price just select the last sell price."] = true
	L["Selects which prices should be shown in the bid and buyout input fields."] = true
	L["Refreshes the list of current auctions for the selected item to be sold."] = true
	L["Up-to-dateness: <= "] = true
	L["Sell"] = true
	L["Autorefresh time"] = true
	L["Selects the minimum time in seconds that has to be passed, before the auction house is automatically scanned for the item to be sold."] = true
	L["Pickup by click"] = true
	L["Pickup items to be soled, when they are shift left clicked."] = "Pickup items to be sold, when they are shift left clicked."
	L["Remember stacksize"] = true
	L["Automatically selects the stacksize used the last time for a given item."] = true
	L["Remember duration"] = true
	L["Automatically selects the duration used the last time for a given item."] = true
	L["Remember price model"] = true
	L["Automatically selects the price model used the last time for a given item."] = true
	L["Selling price"] = true
	L["Percentage to be multiplied with the min bid price."] = true
	L["Percentage to be multiplied with the buyout price."] = true
	L["Automatic"] = true
	L["Activates the automatic selection mode for the appropriate pricing model."] = true
	L["Current price"] = true
	L["Auto selling"] = true
	L["Settings for automatically selecting the best fitting price model."] = true
	L["Upper market threshold"] = true
	L["Minimal needed percentage of buyouts compared to market price, until they are assumed to be considerably above the market price."] = true
	L["Lower market threshold"] = true
	L["Maximal allowed percentage of buyouts compared to market price, until they are assumed to be considerably under the market price."] = true
	L["There are no other auctions for this item."] = true
	L["All other auctions are considerably above the market price."] = true
	L["Some other auctions are considerably under the market price."] = true
	L["Other auctions have to be undercut."] = true
	L["Default duration"] = true
	L["Default duration for creating auctions."] = true
	L["Cancel Auction"] = true
	L["Price modifier"] = true
	L["Bid multiplier"] = true
	L["Selects the percentage of the buyout price the bid value should be set to. A value of 100 will set it to the equal value as the buyout price. It will never fall under blizzard's suggested starting price, which is based on the vendor selling value of the item."] = true
	L["Selects the type of price modification."] = true
	L["Please correct the drop downs first!"] = true
	L["Calculate starting price"] = true
	L["Should the starting price be calculated? Otherwise it is dependant from the buyout price."] = true
	L["Aucts."] = true
	L["Left click auctions to select them for the available operations."] = true
	L["No matching auctions found."] = true
	L["Scans the auction house for the item to be sold."] = true
	L["Bids on all selected items."] = true
	L["Buys all selected items."] = true
	L["Cancels all own auctions that has been selected."] = true
	L["%s (My)"] = true
	L["%s (Bid)"] = true
	L["Placing bid with %s on %s x \"%s\""] = true
	L["Couldn't find auction \"%s\""] = true
	L["Many of the selling settings has to be given by pressing \"Edit\" in the sell tab. Here are only a few general settings left over."] = true
	-- sniper
	L["Set snipe"] = true
	L["Name:"] = true
	L["Type in name of the item here,/nor just drop it in."] = true
	L["Bid:"] = true
	L["Buyout:"] = true
	L["Set"] = true
	L["Cancel"] = true
	L["Buyout is less or equal %s."] = true
	L["Bid is less or equal %s."] = true
	L["Ok"] = true
	L["Item not found"] = true
	L["Not enough money"] = true
	L["Own auction"] = true
	L["Higher bid"] = true
	L["No more items of this type possible"] = true
	L["Snipe bid (%d)"] = true
	L["Snipe bid"] = true
	L["Snipe buyout (%d)"] = true
	L["Snipe buyout"] = true
	L["Database of snipes for current realm where reset."] = true
	L["Sniper"] = true
	L["Resets the database of snipes for the current realm."] = true
	L["Show snipes"] = true
	L["Selects whether any existing snipes should be shown in the GameTooltip."] = true
	L["Selects the number of (approximated) values, that should be taken for the moving average of the historically auction scan statistics."] = true
	L["Delete"] = true
	L["Snipe bookmarked"] = true
	L["Snipe for bookmarked items."] = true
	L["Snipe sell prices"] = true
	L["Snipe for items with higher sell prices."] = true
	L["Buyout is %s less than sell price (%d%%)."] = true
	L["Bid is %s less than sell price (%d%%)."] = true
	L["Minimum profit"] = true
	L["Minimum profit in silver that is needed before sniping for items. Will be ignored for bookmarked items."] = true
	L["Snipe average"] = true
	L["Snipe if the estimated profit according to the average values is higher as the given percent number. Set to zero percent to turn it off."] = true
	L["Buyout for %s possible profit (%d%%)."] = true
	L["Bid for %s possible profit (%d%%)."] = true
	L["Fast scan"] = true
	L["Settings for the normal scan mode."] = true
	L["Settings for the fast scan mode."] = true
	L["Do you really want to bid on this item?"] = true
	L["Do you really want to buy this item?"] = true
	L["Snipe average auctions count"] = true
	L["How often has the item in question to be seen in auction house, until it may be sniped according to the market price."] = true
	L["Sell prices"] = true
	L["Bookmarked"] = true
	L["Market prices"] = true
	L["Snipers"] = true
		
	-- statistic
	L["Bid (%d)"] = true
	L["Buyout (%d)"] = true
	L["Lower bid (%d)"] = true
	L["Lower bid"] = true
	L["Lower buyout (%d)"] = true
	L["Lower buyout"] = true
	L["Show historically averages"] = true
	L["Selects whether historically average values from auction scans should be shown in the GameTooltip."] = true
	L["Show current averages"] = true
	L["Selects whether current average values from auction scans should be shown in the GameTooltip."] = true
	L["Statistics"] = true
	L["Moving average"] = true
	L["< standard deviation multiplicator"] = true
	L["Selects the standard deviation multiplicator for statistical values to be removed, which are smaller than the average. The larger the multiplicator is selected, the lesser values are removed from the average calculation."] = true
	L["> standard deviation multiplicator"] = true
	L["Selects the standard deviation multiplicator for statistical values to be removed, which are larger than the average. The larger the multiplicator is selected, the lesser values are removed from the average calculation."] = true

	-- tooltip hook
	L["AuctionMaster statistics"] = true
	L["Selects whether any informations from AuctionMaster should be shown in the GameTooltip."] = true
	L["Tooltip"] = true
	L["AuctionMaster label"] = true
	L["Selects whether the AuctionMaster label should be shown in the GameTooltip."] = true
	L["Average min bid"] = true
	L["Average buyout"] = true
	L["Current auctions label"] = true
	L["Current min bid"] = true
	L["Current buyout"] = true
	L["Selects whether the average minimum bid prize should be shown in the GameTooltip."] = true
	L["Selects whether the average buyout prize should be shown in the GameTooltip."] = true
	L["Selects whether the label for current auctions should be shown in the GameTooltip."] = true
	L["Selects whether the current minimum bid prize should be shown in the GameTooltip."] = true
	L["Selects whether the current buyout prize should be shown in the GameTooltip."] = true
	L["All time auctions label"] = true
	L["Selects whether the label for all time auctions should be shown in the GameTooltip."] = true
	L["Current lower min bid"] = true
	L["Selects whether the current lower minimum bid prize should be shown in the GameTooltip."] = true
	L["Current lower buyout"] = true
    L["Selects whether the current lower buyout prize should be shown in the GameTooltip."] = true
	L["Compact auction information"] = true
	L["Detailed auction information"] = true
	L["Will display the number of current auctions and the corresponding lower buyout, if any. Otherwise it will display the number of historical values and the current market price."] = true
	L["Current auctions [%s]"] = true
	L["All time auctions [%s]"] = true
	L["Current auctions [%s](%d)"] = true
	L["All time auctions [%s](%d)"] = true
    L["Only market price color"] = true
    L["The color for the market price label in the compact auction info if there are no current auctions."] = true
	L["Always market price"] = true
    L["Will display a compact market price information even if there are current auctions."] = true
	L["Adjust current prices"] = true
	L["Will adjust the current prices with a standard deviation, configured in the statistics section."] = true

	-- items
	L["Items"] = true
	L["Reset database"] = true
	L["Resets the database of items for the current realm and server. This will delete all alltime statistics and sell prizes, so be careful."] = true
	L["Database of items for current realm/server where reset."] = true
	L["Do you really want to reset the database?"] = true
	L["Yes"] = true
	L["No"] = true
	L["Item Settings"] = true
	L["Default"] = true
	L["Stacksize"] = true
	L["General"] = true
	L["Remember amount"] = true
    L["Revert"] = true
    L["Edit"] = true
    L["Pricing modifier"] = true
    L["Specifies a modification to be done on the calculated prices, before starting an auctions."] = true
	L["Sub. money"] = true
	L["Sub. percent"] = true
	L["Add money"] = true
	L["Add percent"] = true
    L["None"] = true
    	
	-- auctions
	L["Lower"] = true
	L["Upper"] = true
	L["Average"] = true
	L["Extra Large"] = true
	L["Cancel Auctions"] = true
	L["Auctions may be selected with left clicks. Press the ctrl button, if you want to select multiple auctions. Press the shift button, if you want to select a range of auctions."] = true
	L["Cancels the selected auctions with just one click."] = true
	L["Scan Auctions"] = true
	L["Scans the auction house for your own auctions to update the statistics. Afterwards you will be able to see, whether you have been undercut (lower buyouts do exist). "] = true
	L["Cancel Undercut"] = true
	L["Automatically cancels all auctions where you have been undercut. There is no need to select them. Out-dated (greyed-out) statistics won't be considered, you have to press the scan button to refresh them."] = true
	L["There are no auctions to be scanned."] = true
	L["Time Left"] = true
	L["%s - Sold"] = true
	L["%s - %s"] = true
	L["Scanning auction %s/%s"] = true
	L["Can't cancel already sold auction"] = true
	L["There are out-dated statistics, you should press the scan-button first."] = true
	
	-- search scan frame
	L["Full scan"] = true
	L["(Fast scan possible)"] = true
	L["Scan speed"] = true
	L["Goes back to the search view."] = true
	L["Back"] = true
	L["Scans the auction house for for all snipes that has been set. Free custom searches may be declared as snipes."] = true
	L["Snipe scan"] = true
	L["(Scan for snipes only)"] = true
	L["Scanning snipe %d/%d (%s)"] = true
	L["Level range"] = true
	L["Rarity"] = true
	L["All"] = true
	L["Class"] = true
	L["Subclass"] = true
	L["Usable"] = true
	L["Max price"] = true
	L["Save name"] = true
	L["Save"] = true
	L["Search"] = true
	L["Fetch name"] = true
	L["Drop item here for copying it's name."] = true
	L["Snipes only"] = true
	L["New"] = true
	L["snipe_scan_label"] = "Snipe"
	L["(Check in scans)"] = true
	L["Item is on wanted list"] = true
	L["Last full scan: %s"] = true
	L["(Fast full-scan available in %s)"] = true
	L["(Fast full-scan currently not possible)"] = true
	L["(Fast full-scan deactivated)"] = true
		
end
