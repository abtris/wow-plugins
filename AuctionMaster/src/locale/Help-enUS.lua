local L = LibStub("AceLocale-3.0"):NewLocale("AuctionMaster-Help", "enUS", true)
if (L) then
	
	-- "|r" is used to avoid the decimal point replacement with a comma

	L["4.x Releases"] = "4|r.|rx Releases"
	L["4xReleasesStatus"] = "Complete list of changes of the 4|r.|rx releases."
	L["4xReleases"] = [[
		<h1>4|r.|r2|r.2</h1>
		<p>* Fixed buyout snipe for auctions without buyout.</p>
		<p>* Added selection of item names for snipe configuration by left-shift clicking them in the bag.</p>
		<p>* Fixed progress bar for sell-scan.</p> 

		<h1>4|r.|r2|r.1</h1>
		<p>* Fixed snipes.</p>
		<p>* Tweaked wording on scan frame.</p>
		
		<h1>4|r.|r2|r.0</h1>
		<p>* Completely refactored scan tab. Now it's possible to define complete free searches, search for the defined snipes only, see the list of snipes and many more.</p> 
		<p>* Fixed sometimes long lasting full scans.</p>
		<p>* Some further buyout fixes, hopefully the last ones.</p>

		<h1>4|r.|r1|r.3</h1>
		<p>* Fixed buyout for full scans. If by chance cheaper items are found, then these are bought or bid.</p>
		<p>* Don't cleanup prices, when undercutting auctions.</p>

		<h1>4|r.|r1|r.2</h1>
		<p>* Fixed bidding on items without buyout price.</p>
		
		<h1>4|r.|r1|r.1</h1>
		<p>* Fixed buyout of multiple auctions, which was handled like a bid.</p>
		<p>* Fixed fix-price handling (when having automatic pricing turned off), which was broken since WoW-Patch 4.0.1.</p>
		<p>* Made the AuctionFrame draggable again, with corresponding addons like nDragIt.</p>

		<h1>4|r.|r1|r.0</h1>
		<p>* Reenabled multi-bid/buyout of auctions, which was broken since WoW-Patch 4.0.1.</p>
		<p>* Reenabled multi-cancel of auctions, which was broken since WoW-Patch 4.0.1.</p>
		<p>* Tweaked the full-scan, hopefully it causes fewer network problems.</p>
		<p>* Added progress-bar for full-scan and sell-scan.</p>

		<h1>4|r.|r0|r.0</h1>
		<p>* First fixes for WoW patch 4.0.1. The full scan doesn't seem to function, but selling items is now possible again.</p>
	]]
		
	L["3.x Releases"] = "3|r.|rx Releases"
	L["3xReleasesStatus"] = "Complete list of changes of the 3|r.|rx releases."
	L["3xReleases"] = [[
		<h1>3|r.|r40|r.3</h1>
		<p>* Fixed reactivation of AuctionMaster Gui for own auctions tab, after having deactivated it.</p>
		
		<h1>3|r.|r40|r.2</h1>
		<p>* Removed some obsolete configuration entries in the addon settings dialog. They has moved to the "Edit" dialog in the sell tab of the auction house.</p>
		
		<h1>3|r.|r40|r.1</h1>
		<p>* Accepting item ids (single numbers) as argument for the GetAuctionBuyout interface (http://www.wowwiki.com/GetAuctionBuyout).</p>
		
		<h1>3|r.|r40|r.0</h1>
		<p>* Refactored the configuration of sell settings like amount, stackize and price modifications. These settings may now be given for specific items, item-subtypes and item-types. If non of these categories was set, the default configuration will be taken. Just press "Edit" in sell tab and select the desired category you want to change. You should prefer to edit the item-type or -subtype settings.</p>
		<p>* Added new dropdown in the scan-frame to select the speed used for scanning the auction-house. If you encounter any network problems while scanning the auction-house you should select the next slower speed.</p>
		<p>* Select Undercut with automatic pricing, if others are above market.</p>
		<p>* Fixed some mappings for enchanting recipes resp. the corresponding scrolls.</p>
		<p>* Added support for GetAuctionBuyout interface (http://www.wowwiki.com/GetAuctionBuyout)</p>

		<h1>3|r.|r39|r.5</h1>
		<p>* Fixed duration bug caused by changes with patch 3.3.3.</p>

		<h1>3|r.|r39|r.4</h1>
		<p>* Fixed lua error caused by patch 3.3.3. Some graphical glitches remaining.</p>

		<h1>3|r.|r39|r.3</h1>
		<p>* Fixed rare lua error, occuring while opening the auction house.</p>
		
		<h1>3|r.|r39|r.2</h1>
		<p>* Readded the possibility to display the owners of auctions in the sell tab. You have to activate the owner column to see them (see change below). That will make the scans slightly slower.</p>
		<p>* Added the possibility to select the columns to be displayed in the auction tables. They may be (de)selected in the configuration menu of the tables in the upper right corner.</p>
		<p>* Added checkbox for selecting wheter the "GetAll" scan feature should be used. It's much faster, but may cause disconnects on some clients.</p>
		<p>* Avoids some chat-spam while scanning.</p>

		<h1>3|r.|r39|r.1</h1>
		<p>* Fixed lua error in localization files.</p>
		
		<h1>3|r.|r39|r.0</h1>
		<p>* Completely refactored the scan engine. It's now much faster, because it uses blizzard's getAll feature, which is available each 15 minutes. The "normal" scans are also faster, because they don't fetch the owner name of the auctions anymore.</p>
		<p>* Added a new tab for the scanner. It lists the auctions found during the scan. Currently there are the already known bookmark and sell price snipers, further are coming up soon. The auctions may be selected and bought at once.</p>
		<p>* Deactivated the average sniper, while refactoring the scan engine. It will be available again in one of the next releases.</p>
		<p>* Deactivated a workaround to handle missing auction update events from blizzard. This may cause that created auctions are not immediately visible in the seller tab. But on the other hand that should avoid the bad side-effects some people where reporting.</p>

		<h1>3|r.|r38|r.5</h1>
		<p>* Changed the default calculation method for the starting price. By default it's now set relative to the buyout price. If you want set it to the average starting price, you have to select "Calculate starting price" in the seller configuration.</p>
		<p>* Fixed a further lua error that could occur while scanning the own auctions.</p>

		<h1>3|r.|r38|r.4</h1>
		<p>* Probably fixed the lua error, some peolpe where reporting lately.</p>
		
		<h1>3|r.|r38|r.3</h1>
		<p>* Hopefully fixed the "item not found" error message, that sometimes occured when sniping items.</p>
		<p>* Improved the approximated historic market price of items. It's now adjusted to the current market price more slowly.</p>
		<p>* Changes in the seller tab like starting auctions, or canceling them, are now directly visible without refreshing the list of auctions.</p> 
		<p>* Readded sell value into the tooltip of auctions in the browse tab.</p>

		<h1>3|r.|r38|r.2</h1>
		<p>* Double clicking an item in the own auctions list now shows it in the search tab.</p>
		<p>* Fixed missing "size" menu in inventory table on seller tab.</p>
		<p>* Fixed resizing of the two tables on the seller tab.</p>
		<p>* Fixed error message caused by account bound items.</p> 
		<p>* Removed the missleading stop button while scanning own auctions. The whole thing will be refactored soon.</p>

		<h1>3|r.|r38|r.1</h1>
		<p>* Silenced the auction house bell while scanning own auctions.</p> 
		<p>* Fixed single item prices for stacked own auctions.</p>

		<h1>3|r.|r38|r.0</h1>
		<p>* Replaced blizzard's original auctions tab with an AuctionMaster table including current auction statistics. The original tab may be restored in the popup menu in the upper right corner.</p>
		<p>* Added a "scan auctions" button to the new auctions tab, which scans for own auctions only. That is much faster as a complete scan.</p>
		<p>* A "cancel undercut" button in the new auctions tab will cancel all own auctions, that has been undercut (there are other auctions with lower buyouts).</p>
		<p>* Finally a "cancel auctions" button in the new auctions tab will cancel immediately all auctions, that has been selected.</p>
		<p>* Selection in the several tables of AuctionMaster is now handled like done in Windows. A left click will select a single item and deselect it, if it was selected previously. If you press the ctrl button, while left clicking an item, any other selected item won't be deselected. If you press the shift button, while left clicking an item, you can select a whole range of items.</p>
		<p>* Fixed sorting according to name in inventory table (ticket 23)</p>

		<h1>3|r.|r37</h1>
		<p>* Reverted scan mode from "fast" to "normal" for scanning the item to be sold. This was the previous behaviour and I revert to it, until it's possible to select the desired scan mode for the operation.</p>
		<p>* Fixed sometimes "frozen" selling prices when switching the price model.</p> 
		<p>* Fixed market price sniping. Additionally it's now possible to select the number of times an item has to be seen at auction house, until it may be considered for market price sniping. The default value is 100.</p>
		<p>* Big thanks goes to Kaktus for the many bug reports he has submitted.</p>

		<h1>3|r.|r36</h1>
		<p>* Fixed rescan after posting all items of the same type and the automatic rescan after cancelling an auction.</p>
		
		<h1>3|r.|r35</h1>
		<p>* Fixed statistics for current auctions in the tooltip with deactivated price cleanup.</p>
		<p>* Fixed compatibility issue with the addon QuickAuctions (stack-trace after pressing "Post" in the addon).</p> 

		<h1>3|r.|r34</h1>
		<p>* Fixed incompatibility of latest release with Auctionator and perhaps with Quick Auctions.</p>
		
		<h1>3|r.|r33</h1>
		<p>* Improved the configuration of the tooltip messages. There is now a very compact style that may be chossen in the tooltip configuration section. It's not activated by default - although I love it very much. Some feedback which presentation (detailed or compact) is the "better" one would be perfect.</p>  
		<p>* The statistic calculation was totally rewritten. Had to reset the statistic data therefore, sorry for that. AuctionMaster is now able to show the total number of times an item has been seen in the auction house.</p>
		<p>* Added a new popup menu at the top-right corner to the tables found in the seller tab. The menu may be used to adjust the size of the table and the height of the rows.</p>
		<p>* Changed the way the rows in the tables of the seller tab may be selected. The checkbox was removed, the rows may now be selected by left clicking them.</p> 
		<p>* The seller tab now contains a table showing the inventory of the player. An item may be selected for sale by double-clicking it. The sizes of the inventory and auction tables may be adjusted with the corresponding menus in the top-right corner. I'm not finally satisfied with the inventory table, so it's by default minimized at the moment.</p>
		<p>* Added auction statistics to enchanter crafting window tooltip. Now you are able to see the auction statistics for the scrolls of enchantments. Thanks goes to my beloved Zahide, for dictating me the 251 mappings. Please contact me in the AuctionMaster forum, if you find a wrong mapping.</p>
		<p>* Added new directory src/api for addon developers who want to use AuctionMaster functionality. The API will remain stable, contrary to the internal implementation.</p> 
		<p>* Fixed bidding on auctions in sell tab.</p>
		<p>* Removed library ItemPrice, because the sell value may now be fetched directly.</p>

		<h1>3|r.|r32|r.|r2</h1>
		<p>* Hopefully fixed the bug that some people where reporting for the tooltip. I can't reproduce it by myself, so it's not for sure...</p>

		<h1>3|r.|r32|r.|r1</h1>
		<p>* Hotfix release for blizzard's patch 3.2.0</p>

		<h1>3|r.|r32</h1>
		<p>* Released first beta of new statistic calculation. If you want to test it, you have to select "New statistics module (BETA)" in the statistic configuration. It just shows the gathered statistics in the tooltip. It's not localized and the tooltip integration will change in future, it just shows the bare statistics. The buyout statistics will be further improved in one of the next releases.</p>
		<p>* Decreased the probability of the error message "Item not found" while sniping auctions.</p>
		<p>* Assured correct stack sizes just before creating auctions. Otherwise the creation will be aborted.</p>
		<p>* Disabled bid button in scan-snipe-dialog, if current user is the high bidder.</p>
		<p>* Fixed lower market price calculation.</p>

		<h1>3|r.|r31</h1>
		<p>* Fixed price model dropdown handling.</p>
		
		<h1>3|r.|r30</h1>
		<p>* Fixed bidding during auction scans.</p>
		
		<h1>3|r.|r29</h1>
		<p>* Readded selling price library ItemPrice-1.1 for getting more current selling prices.</p> 
		<p>* Fixed recalculation of auction prices after changig stack size or count.</p>
		<p>* Fixed display of starting bid instead of highest bid in seller tab.</p>
		
		<h1>3|r.|r28</h1>
		<p>* Fixed disappearance of auction paging buttons after scanning with AuctionMaster.</p>
		
		<h1>3|r.|r27</h1>
		<p>* Added a new sell info area in the seller tab, which displays information about the currently unused pricing types. Let's say you have choosen the default pricing type "per item", then the sell info area will display information for "per stack" and "overall" as well.</p>
		<p>* Fixed a bug for average sniping. The correct percentage values are calculated now again.</p>

		<h1>3|r.|r26</h1>
		<p>* Fixed for patch 3.1</p>
		
		<h1>3|r.|r25</h1>
		<p>* Made stack-size and count in seller tab editable. You're now able to set them via a drop down button like before, or by typing the desired value. If the value is not correct, the title turns red and it's not possible to create the auction.</p>
		<p>* The relative starting price dependant on the buyout price is now optional. By default it behaves now again like in the versions before 3.23.</p>
		<p>* Reactivated the configuration per console.</p>
		<p>* Improved the configuration dialog.</p>
		<p>* Fixed the "reset database" functions. Added a new overall reset function for the complete AuctionMaster database.</p>
		<p>* Fixed a bug in 3.24, which was so serious, that it never saw the light of the world.</p>
		
		<h1>3|r.|r23</h1>
		<p>* Added the possibility to modify the buyout price with an absolute value.</p>
		<p>* The bid is now calculated relatively to the buyout price. This will eliminate some obscure too low bid prices. The percentage is configurable, it defaults to 90%.</p>
		<p>* Moved the "bid type" dropdown from the seller tab into the configuration. It is seldomly changed and I needed the space.</p>
		
		<h1>3|r.|r22</h1>
		<p>* Fixed popup menu on AuctionMaster button.</p>
		<p>* Migrating pre version 3.21 snipes into the new database format.</p>
		
		<h1>3|r.|r21</h1>
		<p>* Added "Bid" and "Buyout" buttons to the seller window. Now you are able to easily buy the too cheap auctions of your competitors.</p>
		<p>* Completely switched to Ace3 libraries. All dependencies to Ace2 and Waterfall where removed.</p>

		<h1>3|r.|r20</h1>
		<p>* Refactored item table in seller tab. It's now able to select auctions and cancel them, if they are owned by the current user. In the future it will be able to bid/buyout auctions and the appearance of the table will be configurable.</p>
		<p>* Reactivated russian translation.</p>

		<h1>3|r.|r19</h1>
		<p>* Adapted to patch 3.0.8.</p>
		
		<h1>3|r.|r18</h1>
		<p>* Added new frame with the documentation and release notes of AuctionMaster. The release notes will automatically be shown, if the auction house is opened the first time with a new version of AuctionMaster. The documentation may be opened in the AuctionMaster popup menu.</p>
		<p>* Added configuration option for the default duration of auctions.</p>
		<p>* Fixed multiplier calculation for market price model.</p>
		<p>* Added longform "/auctionmaster" to the already existing "/am" console command.</p>
 
		<h1>3|r.|r17</h1>
		<p>* Added AuctionMaster portrait icon to auction house window. It may be used to start/stop a scan. It visualizes a currently running scan by showing a blinking animation. The preferred scan mode may be choosen by right clicking the portrait. Until this has been done, the portrait is blinking.</p>
		<p>* Moved tooltips to default location in the bottom right corner.</p>
	
		<h1>3|r.|r16</h1>
		<p>* Improved initialization code for Blizzard_AuctionUi LoadOnDemand capabilities.</p>
		<p>* Switched from LibRockLocale-1|r.|r0 to AceLocale-3|r.|r0.</p>

		<h1>3|r.|r15</h1>
		<p>* Renamed the average price model to market price. Renamed the old market price model to current price.</p>
		<p>* Added automatic price model selection as suggested by Derrekk. There is a checkbox in the upper left corner to activate it. Some aspects may be configured in the "Seller/Auto selling" section. Tried to visualize the decisions made by some icons in the upper left corner. Hover them with the mouse to see a tooltip with an explanation.</p>
		<p>* Added new price model "Selling price", which sets the auction price relative to the selling price of the item.</p>
		<p>* Changed modification of sell prices for price models like undercut. The modification is now configured as a multiplier, not as an addition or substraction of percent points. If the compared price should stay the same, 100% has to be configured now, not 0%. If the compared price should be halved, 50% has to be configured, not -50% any longer.</p>
		<p>* The tooltip statistics now show the correct selected number of items to be sold in the auction house window, not only for one item.</p>
		<p>* Default duration was set to 48 hours.</p>
		<p>* Added russian localization provided by StingerSoft.</p>

		<h1>3|r.|r14</h1>
		<p>* Added new AuctionMaster command menu to the auction house. This is used instead of the three buttons used before.</p>
		<p>* Added possibility to toggle the position of the AuctionMaster menu button (currently only left and right position).</p>
		<p>* Added "fast scan" mode. The normal and fast scan modes may be configured separately. By default the fast scan mode only asks to buy bookmarked items.</p>
		<p>* Added many new and updated sell prices.</p>
		<p>* Limit the item name in auction queries to the length of 62 bytes. Longer names may cause disconnects.</p>

		<h1>3|r.|r13</h1>
		<p>* Added many new and updated sell prices.</p>
		<p>* A sound is now signalling an item to buy or the completion of an auction house scan.</p>
		<p>* Default values for standard deviation cleanup of the auction statistics has been increased a little bit from 1.5 up to 2. This will cause some fewer auctions to be cut off because they are to far away from the average prices.</p>

		<h1>3|r.|r12</h1>
		<p>* Fixed sell price calculation code for asian languages.</p>
		<p>* Resetted old local sell price tables, because they may be bogus.</p>

		<h1>3|r.|r11</h1>
		<p>* Added many new sell prices.</p>

		<h1>3|r.|r10</h1>
		<p>* Replaced sell price library ItemPrice with an own implementation. A reminder in game will ask to submit any new or updated sell prices to be included in the database.</p>

		<h1>3|r.|r9</h1>
		<p>* Fix incorrect, outdated sell prices found in library item-price while visiting any vendor.</p>

		<h1>3|r.|r8</h1>
		<p>* Fixed missing automatic update of undercut prices after having scanned the current auctions for the selected item.</p>

		<h1>3|r.|r7</h1>
		<p>* Added possibility to select items to be sold by shift left clicking them in the inventory. May be deactivated in the "seller" section of the configuration.</p>
		<p>* Made AuctionMaster more compatible with other addons, which are also adding tabs to the auction frame. Tested with Auctionator.</p>
		<p>* Remembering previous pricing model and duration for each item sold. They will be selected automatically the next time the item should be sold. May be deactivated in the seller section of the configuration.</p>
		<p>* Added chinese translation, provided by GloomySunday@CWDG and Juha@CWDG.</p>

		<h1>3|r.|r6</h1>
		<p>* Fixed visualization of per-item and overall price in ask-to-buy dialog.</p>
		<p>* Fixed german translation for ask-to-buy messages because of sell-price undercut. Had to redesign the dialog a bit for that.</p>

		<h1>3|r.|r5</h1>
		<p>* Added average prices to status text in seller frame.</p>
		<p>* Added new pricing model "undercut". It will select a bid/buyout price, that is smaller as all other current auctions. The prices that are too far away from the average, will not be included (see the next new feature).</p>
		<p>* Cleanup statistic calculations with the standard deviation (see http://en.wikipedia.org/wiki/Standard_deviation). This will be done for the alltime statistics and the current auctions statistics. The multiplicator for the standard deviation is configurable in the statistic section of the configuration window.</p>
		<p>* The dialog for buying detected auctions (detected by sell-price, average, etc.) now shows the price per item (like before) and also the total price, if the stack size is larger than one. The total price is shown in parens.</p>

		<h1>3|r.|r4</h1>
		<p>* Made the the market price modifier configurable. The percent points to substract or add to the average market price may be set in an edit box near to the prizing model dropdown. If the corresponding checkbox labeled with "&lt;" is checked, the specified percentage value will be substracted.</p>

		<h1>3|r.|r3</h1>
		<p>* Fixed ticket 1: Snipes being missed. Items could be missed during scan when buying some.</p>
		<p>* The remembered maximal prizes for an item given during a scan are now resetted after the completion of the scan. The scan dialog will now ask you again the next time.</p> 
		<p>* Omit the AuctionMaster label in the tooltip if deselected in configuration.</p>
		<p>* Omit the sell price label in the tooltip if deselected in configuration.</p>

		<h1>3|r.|r2</h1>
		<p>* Renamed "Vendor" to "AuctionMaster". The old Vendor directory should be deleted in Interface/Addons.</p>

		<h1>3|r.|r1</h1>
		<p>* Fixed bug with never ending searching in auction house.</p>

		<h1>3|r.|r0</h1>
		<p>* Adapted to blizzard's changes for patch 3|r.|r0</p>]]

	L["Help"] = true
	L["Documentation"] = true
	L["DocumentationStatus"] = "Documentation of AuctionMaster."
	L["DocumentationSectionStatus"] = "Single section of the the documentation."
	
	L["doc_1_title"] = "Introduction"
	L["doc_1"] = [[
	<h1>Introduction</h1>
	<p>AuctionMaster is a compact auction house tool for being able to sell items like the wind, scanning auctions for item statistics, searching for wanted items in the auction house, looking for good opportunities among the current auctions and displaying the statistics gathered so far in the tooltip of any item.</p>
<p>AuctionMaster was formerly named Vendor, which seemed to be a missleading name for the purpose of the addon.</p>]]

	L["doc_2_title"] = "Why another one?"
	L["doc_2"] = [[
	<h1>Why another auction addon?</h1>
	<p>There are already well known and established auction tools available. But I wasn't very comfortable with them. I wanted to have a tool which is very compact, which doesn't overstrain me in the tooltip with too much information. On the other side it should be ease in use and totally driven by gui elements.</p>

	<p>And last but not least I just had fun to learn many new things while programming it.</p>]]

	L["doc_3_title"] = "Compatibility"
	L["doc_3"] = [[
	<h1>Compatibility with other auction addons</h1>

	<p>AuctionMaster adds a new tab to the auction window. It does that as compatible as possible. This way some other addons, which also add new tabs to the auction window won't get disturbed. But there is no gurantee, that all other auction addons, modifying the auction frame, will be compatible with AuctionMaster. It depends on how cautious the addon author was.</p>]]

	L["doc_4_title"] = "Features"
	L["doc_4"] = [[
	<h1>Features</h1>

	<p>AuctionMaster comes in a single directory, without any other dependencies. The needed Ace2 libraries are already contained in the AuctionMaster installation directory.</p>

	<p>The following sections will explain some of the main features of AuctionMaster.</p>

	<h2>Using the UI</h2>

	<p>All UI elements of AuctionMaster do have a tooltip description. Just point to the button in question and the tooltip with a short description will appear.</p>

	<p>If you still have a question, just look again in this text or write a comment in the forum.</p>

	<h2>Control buttons</h2>

	<p>After installing AuctionMaster you will see a button named AuctionMaster in the top right corner of the auction house window. There you will find shortcuts for beeing able to configure AuctionMaster, scan for all current auctions and create a snipe for the currently selected item.</p>

	<p>All three aspects will be explained in detail in the next sections.</p>

	<h2>Scanning auctions</h2>

	<p>AuctionMaster is able to scan all current auctions by pressing the Scan button. This may be done in the AuctionMaster popup menu or by using the portrait icon of the auction house. Afterwards a progress dialog will appear, which informs about the progress of the scan. If AuctionMaster encounters a previously sniped item or an auction with promising prices, it will ask you to bid for it or even buy it immediately. The limits for the latter feature may be configured. They shouldn't be set to low, otherwise the dialog will ask you too oftenly.</p>

	<p>The search for promising items will get better after some scans over a few days. Otherwise some odd prices may influence the statistics too much.</p>

	<p>AuctionMaster will maintain statistics of the scanned auctions. The prices are corrected by a standard deviation method. This may be configured in the statistic section of the configuration.</p>

	<h2>Sniping items</h2>

	<p>By pressing the Snipe button you may set a snipe for the currently selected item. A dialog will appear, which will ask you for the maximal bid and buyout price you are up to pay, if it will be encountered during an auction house scan. In this case a dialog will appear, where you can press a bid or buyout button to actually bid/buy the desired item.</p>

	<p>The snipes will be valid for each character. You may set the snipe with your main and buy the item with your auction house twink.</p>

	<h2>Selling items</h2>

	<p>AuctionMaster will add a fourth tab to the auction house for efficiently selling your items. The left section of the window is used to  describe the sale. The right section will display all current auctions of the same type.</p> 
	<p>By pressing the Refresh button, you may search for more current auctions of the same type. If the last scan is too old, AuctionMaster will automatically scan again - only for the selected item. This time may be configured (like many other things).</p>

	<p>You have to drag the item to be sold in the image in the upper left corner. Alternatively you may just shift left click the item to be sold in your inventory. AuctionMaster will automatically select the last prices, you have used the last time for this item.</p>

	<p>Beside that you are able to select the duration, the prices for bid and buyout, the stack size and the number of stacks. You don't have to prepare the stacks by yourself. AuctionMaster will do it for you. Just select the desired stack size and you're done.</p>

	<p>With Price calculation you can select the following price modes:</p>

<h3>Fixed price:</h3> 
<p>Just selects the bid and buyout prices you have used the last time.</p>

<h3>Current price:</h3> 
<p>Selects the average prices of the current auctions for the selected item. This may be influenced by a configurable percent amount. Will be modified by the configurable percentage value.</p>

<h3>Undercut:</h3> 
<p>Selects the lowest prices of the current auctions for the selected item. This may be influenced by a configurable percent amount. Will be modified by the configurable percentage value.</p>

<h3>Lower market threshold:</h3>
<p>Sets the buyout price to the first auction above the configured lower market threshold (defaults to 30% of the market price). The min bid price is set to exactly the lower market threshold. Will be modified by the configurable percentage value.</p>

<h3>Selling price:</h3>
<p>Selects the selling price of the given item. Will be modified by the configurable percentage value.</p>

<h3>Market price:</h3>
<p>Selects the average bid and buyout prices calculated for the last scans. Will be modified by the configurable percentage value.</p>

	<h2>Auction statistics in the tooltip</h2>

	<p>AuctionMaster will gather statistics for the scanned auction items. It will calculate the median for the prices found. The tooltip of any item will display the overall statistics for the bid and buyout prices and the same for the last scan. Additionally the sell price at the vendor will be displayed.</p>

	<p>For stacked items there will be displayed two prices. The first is for single items and the second (in parens) is for the price of the complete stack.</p>

	<p>The averages for the current server and faction will be displayed.</p>]]

	L["doc_5_title"] = "Configuration"
	L["doc_5"] = [[
	<h1>Configuration</h1>

	<p>Many things of the features described above are configurable. Just press the "Configuration" button and have a look at it. All configuration options are described by a tooltip. You have to point at it for a few seconds, then it will appear.</p>

	<p>There are too many options to describe them here in detail. Hopefully they are self-explaining.</p>]]

	L["doc_6_title"] = "Author"
	L["doc_6"] = [[
	<h1>Author</h1>

	<p>AuctionMaster was written by Udorn, a dusky shadow priest, always looking for some opposing souls to be consumed.</p>]]

	L["doc_7_title"] = "Acknowledgments"
	L["doc_7"] = [[
	<h1>Acknowledgements</h1>

	<p>A big thanks goes to the users of the AuctionMaster forum at Curse, for their support and many good suggestions.</p>

	<p>And some special thanks for translations and bug reporting go to:</p>

	<p>* GloomySunday@CWDG (Simplified Chinese and Bug reporting)</p>
	<p>* Juha@CWDG (Traditional Chinese)</p>
	<p>* StingerSoft (Russian)</p>
	<p>* Cremor (Bug reporting)</p>
	<p>* Kaktus (Bug reporting)</p>]]

end
