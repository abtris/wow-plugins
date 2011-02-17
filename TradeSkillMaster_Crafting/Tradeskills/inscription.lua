-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu, Mischanix				 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --

-- The following functions are contained attached to this file:
-- Inscription:HasProfession() - determines if the player is a scribe

-- The following "global" (within the addon) variables are initialized in this file:
-- Inscription.slot - hardcoded list of the slot of every craft

-- ===================================================================================== --


-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local Inscription = TSM:NewModule("Inscription", "AceEvent-3.0")

local debug = function(...) TSM:Debug(...) end -- for debugging

-- determines if the player is a scribe
function Inscription:HasProfession()
	local professionIDs = {45357, 45358, 45359, 45360, 45361, 45363, 86008}
	for _, id in pairs(professionIDs) do
		if IsSpellKnown(id) then return true end
	end
end

function Inscription:GetSlot(itemID)
	if not itemID then return end
	local tableNum = TSM.db.profile.inscriptionGrouping
	return Inscription["slot"..tableNum][itemID]
end

function Inscription:GetInkMats(itemID)
	if not itemID then return end
	return Inscription.inks[itemID]
end

function Inscription:GetSlotList()
	local tableNum = TSM.db.profile.inscriptionGrouping
	return Inscription["slotList"..tableNum]
end

Inscription.slotList1 = {L["Blackfallow Ink"], L["Ink of the Sea"], L["Ethereal Ink"], L["Shimmering Ink"], L["Celestial Ink"], L["Jadefire Ink"],
	L["Lion's Ink"], L["Midnight Ink"], L["Misc Items"]}--, L["Inks"]}
	
Inscription.slotList2 = {L["Death Knight"], L["Druid"], L["Hunter"], L["Mage"], L["Paladin"], L["Priest"], L["Rogue"],
	L["Shaman"], L["Warlock"], L["Warrior"], L["Misc Items"]}--, L["Inks"]}

-- [itemID] = index in slot list
Inscription.slot1 = {
	[63481]=1, -- Blackfallow Ink
	[43374]=2, -- Ink of the Sea
	[43394]=2, -- Ink of the Sea
	[49084]=2, -- Ink of the Sea
	[50077]=2, -- Ink of the Sea
	[42745]=2, -- Ink of the Sea
	[42909]=2, -- Ink of the Sea
	[41102]=2, -- Ink of the Sea
	[42412]=2, -- Ink of the Sea
	[43552]=2, -- Ink of the Sea
	[41539]=2, -- Ink of the Sea
	[44928]=2, -- Ink of the Sea
	[41524]=2, -- Ink of the Sea
	[40899]=2, -- Ink of the Sea
	[40920]=2, -- Ink of the Sea
	[40908]=2, -- Ink of the Sea
	[40915]=2, -- Ink of the Sea
	[40900]=2, -- Ink of the Sea
	[40912]=2, -- Ink of the Sea
	[40921]=2, -- Ink of the Sea
	[40906]=2, -- Ink of the Sea
	[42739]=2, -- Ink of the Sea
	[42742]=2, -- Ink of the Sea
	[42748]=2, -- Ink of the Sea
	[42751]=2, -- Ink of the Sea
	[42753]=2, -- Ink of the Sea
	[42754]=2, -- Ink of the Sea
	[42899]=2, -- Ink of the Sea
	[42901]=2, -- Ink of the Sea
	[42902]=2, -- Ink of the Sea
	[42913]=2, -- Ink of the Sea
	[42914]=2, -- Ink of the Sea
	[42915]=2, -- Ink of the Sea
	[42917]=2, -- Ink of the Sea
	[41101]=2, -- Ink of the Sea
	[41107]=2, -- Ink of the Sea
	[41097]=2, -- Ink of the Sea
	[41110]=2, -- Ink of the Sea
	[41109]=2, -- Ink of the Sea
	[42954]=2, -- Ink of the Sea
	[42957]=2, -- Ink of the Sea
	[42958]=2, -- Ink of the Sea
	[42959]=2, -- Ink of the Sea
	[42965]=2, -- Ink of the Sea
	[42967]=2, -- Ink of the Sea
	[42968]=2, -- Ink of the Sea
	[42969]=2, -- Ink of the Sea
	[42971]=2, -- Ink of the Sea
	[43425]=2, -- Ink of the Sea
	[43412]=2, -- Ink of the Sea
	[43415]=2, -- Ink of the Sea
	[43419]=2, -- Ink of the Sea
	[43421]=2, -- Ink of the Sea
	[43430]=2, -- Ink of the Sea
	[43431]=2, -- Ink of the Sea
	[42396]=2, -- Ink of the Sea
	[42403]=2, -- Ink of the Sea
	[42404]=2, -- Ink of the Sea
	[42405]=2, -- Ink of the Sea
	[42407]=2, -- Ink of the Sea
	[42409]=2, -- Ink of the Sea
	[42414]=2, -- Ink of the Sea
	[42417]=2, -- Ink of the Sea
	[43533]=2, -- Ink of the Sea
	[43534]=2, -- Ink of the Sea
	[43537]=2, -- Ink of the Sea
	[43542]=2, -- Ink of the Sea
	[43547]=2, -- Ink of the Sea
	[43550]=2, -- Ink of the Sea
	[41517]=2, -- Ink of the Sea
	[41518]=2, -- Ink of the Sea
	[41526]=2, -- Ink of the Sea
	[41529]=2, -- Ink of the Sea
	[41534]=2, -- Ink of the Sea
	[41538]=2, -- Ink of the Sea
	[41552]=2, -- Ink of the Sea
	[42454]=2, -- Ink of the Sea
	[42456]=2, -- Ink of the Sea
	[42457]=2, -- Ink of the Sea
	[42459]=2, -- Ink of the Sea
	[42460]=2, -- Ink of the Sea
	[42463]=2, -- Ink of the Sea
	[42464]=2, -- Ink of the Sea
	[42472]=2, -- Ink of the Sea
	[43867]=2, -- Ink of the Sea
	[43868]=2, -- Ink of the Sea
	[43869]=2, -- Ink of the Sea
	[44684]=2, -- Ink of the Sea
	[42752]=2, -- Ink of the Sea
	[63539]=2, -- Ink of the Sea
	[66918]=2, -- Ink of the Sea
	[45732]=2, -- Ink of the Sea
	[45745]=2, -- Ink of the Sea
	[45604]=2, -- Ink of the Sea
	[45744]=2, -- Ink of the Sea
	[45757]=2, -- Ink of the Sea
	[45767]=2, -- Ink of the Sea
	[45783]=2, -- Ink of the Sea
	[45794]=2, -- Ink of the Sea
	[45603]=2, -- Ink of the Sea
	[45739]=2, -- Ink of the Sea
	[45766]=2, -- Ink of the Sea
	[45777]=2, -- Ink of the Sea
	[45782]=2, -- Ink of the Sea
	[44922]=2, -- Ink of the Sea
	[44920]=2, -- Ink of the Sea
	[44923]=2, -- Ink of the Sea
	[43539]=3, -- Ethereal Ink
	[43673]=3, -- Ethereal Ink
	[43671]=3, -- Ethereal Ink
	[43672]=3, -- Ethereal Ink
	[43535]=3, -- Ethereal Ink
	[43544]=3, -- Ethereal Ink
	[43400]=3, -- Ethereal Ink
	[50045]=3, -- Ethereal Ink
	[41105]=3, -- Ethereal Ink
	[43548]=3, -- Ethereal Ink
	[41527]=3, -- Ethereal Ink
	[42963]=3, -- Ethereal Ink
	[43553]=3, -- Ethereal Ink
	[40903]=3, -- Ethereal Ink
	[43825]=3, -- Ethereal Ink
	[44955]=3, -- Ethereal Ink
	[42911]=3, -- Ethereal Ink
	[42401]=3, -- Ethereal Ink
	[43428]=3, -- Ethereal Ink
	[43826]=3, -- Ethereal Ink
	[42749]=3, -- Ethereal Ink
	[42471]=3, -- Ethereal Ink
	[43551]=3, -- Ethereal Ink
	[41542]=3, -- Ethereal Ink
	[67484]=3, -- Ethereal Ink
	[42736]=3, -- Ethereal Ink
	[41094]=3, -- Ethereal Ink
	[42955]=3, -- Ethereal Ink
	[43827]=3, -- Ethereal Ink
	[43432]=3, -- Ethereal Ink
	[43554]=3, -- Ethereal Ink
	[40896]=3, -- Ethereal Ink
	[42906]=3, -- Ethereal Ink
	[42406]=3, -- Ethereal Ink
	[43549]=3, -- Ethereal Ink
	[42453]=3, -- Ethereal Ink
	[45601]=3, -- Ethereal Ink
	[45602]=3, -- Ethereal Ink
	[45625]=3, -- Ethereal Ink
	[45731]=3, -- Ethereal Ink
	[45736]=3, -- Ethereal Ink
	[45737]=3, -- Ethereal Ink
	[45738]=3, -- Ethereal Ink
	[45741]=3, -- Ethereal Ink
	[45742]=3, -- Ethereal Ink
	[45743]=3, -- Ethereal Ink
	[45753]=3, -- Ethereal Ink
	[45755]=3, -- Ethereal Ink
	[45756]=3, -- Ethereal Ink
	[45758]=3, -- Ethereal Ink
	[45761]=3, -- Ethereal Ink
	[45762]=3, -- Ethereal Ink
	[45764]=3, -- Ethereal Ink
	[45770]=3, -- Ethereal Ink
	[45771]=3, -- Ethereal Ink
	[45772]=3, -- Ethereal Ink
	[45779]=3, -- Ethereal Ink
	[45781]=3, -- Ethereal Ink
	[45790]=3, -- Ethereal Ink
	[45792]=3, -- Ethereal Ink
	[45799]=3, -- Ethereal Ink
	[45800]=3, -- Ethereal Ink
	[45806]=3, -- Ethereal Ink
	[45795]=3, -- Ethereal Ink
	[45769]=3, -- Ethereal Ink
	[45780]=3, -- Ethereal Ink
	[63420]=3, -- Ethereal Ink
	[68793]=3, -- Ethereal Ink
	[67482]=4, -- Shimmering Ink
	[45622]=4, -- Shimmering Ink
	[45775]=4, -- Shimmering Ink
	[45760]=4, -- Shimmering Ink
	[45768]=4, -- Shimmering Ink
	[45776]=4, -- Shimmering Ink
	[40901]=4, -- Shimmering Ink
	[42905]=4, -- Shimmering Ink
	[41103]=4, -- Shimmering Ink
	[43536]=4, -- Shimmering Ink
	[42399]=4, -- Shimmering Ink
	[43543]=4, -- Shimmering Ink
	[41541]=4, -- Shimmering Ink
	[42468]=4, -- Shimmering Ink
	[45804]=4, -- Shimmering Ink
	[43546]=4, -- Shimmering Ink
	[42974]=4, -- Shimmering Ink
	[43416]=4, -- Shimmering Ink
	[43541]=4, -- Shimmering Ink
	[43355]=5, -- Celestial Ink
	[43378]=5, -- Celestial Ink
	[40902]=5, -- Celestial Ink
	[42903]=5, -- Celestial Ink
	[41099]=5, -- Celestial Ink
	[42972]=5, -- Celestial Ink
	[42416]=5, -- Celestial Ink
	[41533]=5, -- Celestial Ink
	[42466]=5, -- Celestial Ink
	[40916]=5, -- Celestial Ink
	[42744]=5, -- Celestial Ink
	[42904]=5, -- Celestial Ink
	[41098]=5, -- Celestial Ink
	[42397]=5, -- Celestial Ink
	[42973]=5, -- Celestial Ink
	[41535]=5, -- Celestial Ink
	[43414]=5, -- Celestial Ink
	[42470]=5, -- Celestial Ink
	[45623]=5, -- Celestial Ink
	[45746]=5, -- Celestial Ink
	[45793]=5, -- Celestial Ink
	[45740]=5, -- Celestial Ink
	[43334]=6, -- Jadefire Ink
	[43351]=6, -- Jadefire Ink
	[43369]=6, -- Jadefire Ink
	[43372]=6, -- Jadefire Ink
	[43381]=6, -- Jadefire Ink
	[43385]=6, -- Jadefire Ink
	[43388]=6, -- Jadefire Ink
	[43392]=6, -- Jadefire Ink
	[43393]=6, -- Jadefire Ink
	[43674]=6, -- Jadefire Ink
	[43370]=6, -- Jadefire Ink
	[40919]=6, -- Jadefire Ink
	[42910]=6, -- Jadefire Ink
	[67486]=6, -- Jadefire Ink
	[67483]=6, -- Jadefire Ink
	[42738]=6, -- Jadefire Ink
	[41100]=6, -- Jadefire Ink
	[42966]=6, -- Jadefire Ink
	[42411]=6, -- Jadefire Ink
	[41540]=6, -- Jadefire Ink
	[42467]=6, -- Jadefire Ink
	[40909]=6, -- Jadefire Ink
	[43422]=6, -- Jadefire Ink
	[42746]=6, -- Jadefire Ink
	[42897]=6, -- Jadefire Ink
	[41104]=6, -- Jadefire Ink
	[42415]=6, -- Jadefire Ink
	[64493]=6, -- Jadefire Ink
	[42970]=6, -- Jadefire Ink
	[41547]=6, -- Jadefire Ink
	[43424]=6, -- Jadefire Ink
	[42473]=6, -- Jadefire Ink
	[68039]=6, -- Jadefire Ink
	[63416]=6, -- Jadefire Ink
	[45733]=6, -- Jadefire Ink
	[43316]=7, -- Lion's Ink
	[43331]=7, -- Lion's Ink
	[43365]=7, -- Lion's Ink
	[43368]=7, -- Lion's Ink
	[43373]=7, -- Lion's Ink
	[43377]=7, -- Lion's Ink
	[43386]=7, -- Lion's Ink
	[43389]=7, -- Lion's Ink
	[43398]=7, -- Lion's Ink
	[43725]=7, -- Lion's Ink
	[43360]=7, -- Lion's Ink
	[43376]=7, -- Lion's Ink
	[43380]=7, -- Lion's Ink
	[43344]=7, -- Lion's Ink
	[43391]=7, -- Lion's Ink
	[40924]=7, -- Lion's Ink
	[42898]=7, -- Lion's Ink
	[41106]=7, -- Lion's Ink
	[42961]=7, -- Lion's Ink
	[42398]=7, -- Lion's Ink
	[43423]=7, -- Lion's Ink
	[41530]=7, -- Lion's Ink
	[42461]=7, -- Lion's Ink
	[40914]=7, -- Lion's Ink
	[42735]=7, -- Lion's Ink
	[42900]=7, -- Lion's Ink
	[41092]=7, -- Lion's Ink
	[42962]=7, -- Lion's Ink
	[42400]=7, -- Lion's Ink
	[67487]=7, -- Lion's Ink
	[67485]=7, -- Lion's Ink
	[43417]=7, -- Lion's Ink
	[41532]=7, -- Lion's Ink
	[42458]=7, -- Lion's Ink
	[40923]=7, -- Lion's Ink
	[42737]=7, -- Lion's Ink
	[42908]=7, -- Lion's Ink
	[41108]=7, -- Lion's Ink
	[42964]=7, -- Lion's Ink
	[42402]=7, -- Lion's Ink
	[43427]=7, -- Lion's Ink
	[41536]=7, -- Lion's Ink
	[42465]=7, -- Lion's Ink
	[45734]=7, -- Lion's Ink
	[45789]=7, -- Lion's Ink
	[45747]=7, -- Lion's Ink
	[45797]=7, -- Lion's Ink
	[43332]=8, -- Midnight Ink
	[43335]=8, -- Midnight Ink
	[43356]=8, -- Midnight Ink
	[43338]=8, -- Midnight Ink
	[43350]=8, -- Midnight Ink
	[43339]=8, -- Midnight Ink
	[43359]=8, -- Midnight Ink
	[43364]=8, -- Midnight Ink
	[43361]=8, -- Midnight Ink
	[43366]=8, -- Midnight Ink
	[43367]=8, -- Midnight Ink
	[43340]=8, -- Midnight Ink
	[43342]=8, -- Midnight Ink
	[43371]=8, -- Midnight Ink
	[43379]=8, -- Midnight Ink
	[43343]=8, -- Midnight Ink
	[43390]=8, -- Midnight Ink
	[43395]=8, -- Midnight Ink
	[43396]=8, -- Midnight Ink
	[43397]=8, -- Midnight Ink
	[43399]=8, -- Midnight Ink
	[40913]=8, -- Midnight Ink
	[42741]=8, -- Midnight Ink
	[42907]=8, -- Midnight Ink
	[41096]=8, -- Midnight Ink
	[42956]=8, -- Midnight Ink
	[42408]=8, -- Midnight Ink
	[40922]=8, -- Midnight Ink
	[43413]=8, -- Midnight Ink
	[41531]=8, -- Midnight Ink
	[42455]=8, -- Midnight Ink
	[40897]=8, -- Midnight Ink
	[42743]=8, -- Midnight Ink
	[42912]=8, -- Midnight Ink
	[41095]=8, -- Midnight Ink
	[42960]=8, -- Midnight Ink
	[43418]=8, -- Midnight Ink
	[42410]=8, -- Midnight Ink
	[41537]=8, -- Midnight Ink
	[42462]=8, -- Midnight Ink
	[48720]=8, -- Midnight Ink
	[45735]=8, -- Midnight Ink
	[45778]=8, -- Midnight Ink
	[45785]=8, -- Midnight Ink
	[60838]=9, -- Misc Items
	[44210]=9, -- Misc Items
	[38322]=9, -- Misc Items
	[43515]=9, -- Misc Items
	[43655]=9, -- Misc Items
	[43654]=9, -- Misc Items
	[43657]=9, -- Misc Items
	[43656]=9, -- Misc Items
	[43661]=9, -- Misc Items
	[43660]=9, -- Misc Items
	[43664]=9, -- Misc Items
	[43663]=9, -- Misc Items
	[43667]=9, -- Misc Items
	[43666]=9, -- Misc Items
	[45854]=9, -- Misc Items
	[45849]=9, -- Misc Items
	[62242]=9, -- Misc Items
	[62241]=9, -- Misc Items
	[62240]=9, -- Misc Items
	[62233]=9, -- Misc Items
	[62231]=9, -- Misc Items
	[62236]=9, -- Misc Items
	[62245]=9, -- Misc Items
	[62244]=9, -- Misc Items
	[62243]=9, -- Misc Items
	[62235]=9, -- Misc Items
	[62234]=9, -- Misc Items
	[37101]=10, -- Inks
	[39469]=10, -- Inks
	[39774]=10, -- Inks
	[43116]=10, -- Inks
	[43118]=10, -- Inks
	[43120]=10, -- Inks
	[43122]=10, -- Inks
	[43124]=10, -- Inks
	[43126]=10, -- Inks
	[61978]=10, -- Inks
	[61981]=10, -- Inks
}

Inscription.slot2 = {
	[43673]=1, -- Death Knight
	[68793]=1, -- Death Knight
	[43534]=1, -- Death Knight
	[43536]=1, -- Death Knight
	[43539]=1, -- Death Knight
	[43541]=1, -- Death Knight
	[43543]=1, -- Death Knight
	[43546]=1, -- Death Knight
	[43551]=1, -- Death Knight
	[43553]=1, -- Death Knight
	[43554]=1, -- Death Knight
	[43672]=1, -- Death Knight
	[43825]=1, -- Death Knight
	[45800]=1, -- Death Knight
	[43827]=1, -- Death Knight
	[43549]=1, -- Death Knight
	[43548]=1, -- Death Knight
	[45799]=1, -- Death Knight
	[45806]=1, -- Death Knight
	[43533]=1, -- Death Knight
	[43550]=1, -- Death Knight
	[43544]=1, -- Death Knight
	[43535]=1, -- Death Knight
	[43547]=1, -- Death Knight
	[43671]=1, -- Death Knight
	[43542]=1, -- Death Knight
	[43552]=1, -- Death Knight
	[43537]=1, -- Death Knight
	[43826]=1, -- Death Knight
	[45804]=1, -- Death Knight
	[67487]=2, -- Druid
	[40916]=2, -- Druid
	[40914]=2, -- Druid
	[40913]=2, -- Druid
	[40912]=2, -- Druid
	[40909]=2, -- Druid
	[40906]=2, -- Druid
	[40903]=2, -- Druid
	[40900]=2, -- Druid
	[40919]=2, -- Druid
	[40922]=2, -- Druid
	[67485]=2, -- Druid
	[48720]=2, -- Druid
	[45603]=2, -- Druid
	[43332]=2, -- Druid
	[43331]=2, -- Druid
	[43316]=2, -- Druid
	[40924]=2, -- Druid
	[40923]=2, -- Druid
	[40897]=2, -- Druid
	[43674]=2, -- Druid
	[43334]=2, -- Druid
	[40896]=2, -- Druid
	[40902]=2, -- Druid
	[45623]=2, -- Druid
	[40915]=2, -- Druid
	[67484]=2, -- Druid
	[45601]=2, -- Druid
	[44928]=2, -- Druid
	[40921]=2, -- Druid
	[68039]=2, -- Druid
	[45602]=2, -- Druid
	[40908]=2, -- Druid
	[67486]=2, -- Druid
	[45622]=2, -- Druid
	[44922]=2, -- Druid
	[43335]=2, -- Druid
	[40899]=2, -- Druid
	[40920]=2, -- Druid
	[40901]=2, -- Druid
	[45604]=2, -- Druid
	[42903]=3, -- Hunter
	[42898]=3, -- Hunter
	[42900]=3, -- Hunter
	[42901]=3, -- Hunter
	[42904]=3, -- Hunter
	[42908]=3, -- Hunter
	[42909]=3, -- Hunter
	[42912]=3, -- Hunter
	[42914]=3, -- Hunter
	[42915]=3, -- Hunter
	[43338]=3, -- Hunter
	[43350]=3, -- Hunter
	[45731]=3, -- Hunter
	[45734]=3, -- Hunter
	[42897]=3, -- Hunter
	[42905]=3, -- Hunter
	[42910]=3, -- Hunter
	[42907]=3, -- Hunter
	[45733]=3, -- Hunter
	[45625]=3, -- Hunter
	[42913]=3, -- Hunter
	[43355]=3, -- Hunter
	[42911]=3, -- Hunter
	[42902]=3, -- Hunter
	[42917]=3, -- Hunter
	[42899]=3, -- Hunter
	[42906]=3, -- Hunter
	[43356]=3, -- Hunter
	[45732]=3, -- Hunter
	[43351]=3, -- Hunter
	[45735]=3, -- Hunter
	[42748]=4, -- Mage
	[44920]=4, -- Mage
	[42745]=4, -- Mage
	[42735]=4, -- Mage
	[42737]=4, -- Mage
	[42738]=4, -- Mage
	[42739]=4, -- Mage
	[42741]=4, -- Mage
	[42742]=4, -- Mage
	[42743]=4, -- Mage
	[42752]=4, -- Mage
	[42753]=4, -- Mage
	[43360]=4, -- Mage
	[43361]=4, -- Mage
	[45738]=4, -- Mage
	[42746]=4, -- Mage
	[42744]=4, -- Mage
	[43364]=4, -- Mage
	[42736]=4, -- Mage
	[45736]=4, -- Mage
	[63539]=4, -- Mage
	[42749]=4, -- Mage
	[43339]=4, -- Mage
	[44684]=4, -- Mage
	[45739]=4, -- Mage
	[42754]=4, -- Mage
	[45737]=4, -- Mage
	[45740]=4, -- Mage
	[50045]=4, -- Mage
	[43359]=4, -- Mage
	[42751]=4, -- Mage
	[63416]=4, -- Mage
	[44955]=4, -- Mage
	[41102]=5, -- Paladin
	[41092]=5, -- Paladin
	[41095]=5, -- Paladin
	[41098]=5, -- Paladin
	[41099]=5, -- Paladin
	[41100]=5, -- Paladin
	[41101]=5, -- Paladin
	[41103]=5, -- Paladin
	[41105]=5, -- Paladin
	[41107]=5, -- Paladin
	[41108]=5, -- Paladin
	[43365]=5, -- Paladin
	[43367]=5, -- Paladin
	[43868]=5, -- Paladin
	[45743]=5, -- Paladin
	[45746]=5, -- Paladin
	[43867]=5, -- Paladin
	[45742]=5, -- Paladin
	[41106]=5, -- Paladin
	[41109]=5, -- Paladin
	[45747]=5, -- Paladin
	[43369]=5, -- Paladin
	[43340]=5, -- Paladin
	[41097]=5, -- Paladin
	[43368]=5, -- Paladin
	[43869]=5, -- Paladin
	[45745]=5, -- Paladin
	[41094]=5, -- Paladin
	[45741]=5, -- Paladin
	[45744]=5, -- Paladin
	[41104]=5, -- Paladin
	[41096]=5, -- Paladin
	[41110]=5, -- Paladin
	[43366]=5, -- Paladin
	[66918]=5, -- Paladin
	[42404]=6, -- Priest
	[42403]=6, -- Priest
	[42397]=6, -- Priest
	[42398]=6, -- Priest
	[42400]=6, -- Priest
	[42402]=6, -- Priest
	[42406]=6, -- Priest
	[42408]=6, -- Priest
	[42410]=6, -- Priest
	[42411]=6, -- Priest
	[42415]=6, -- Priest
	[42416]=6, -- Priest
	[43342]=6, -- Priest
	[43371]=6, -- Priest
	[45756]=6, -- Priest
	[45757]=6, -- Priest
	[43373]=6, -- Priest
	[42414]=6, -- Priest
	[42407]=6, -- Priest
	[45753]=6, -- Priest
	[45755]=6, -- Priest
	[43374]=6, -- Priest
	[42401]=6, -- Priest
	[42396]=6, -- Priest
	[42405]=6, -- Priest
	[42399]=6, -- Priest
	[43372]=6, -- Priest
	[45760]=6, -- Priest
	[42409]=6, -- Priest
	[42417]=6, -- Priest
	[43370]=6, -- Priest
	[42412]=6, -- Priest
	[45758]=6, -- Priest
	[45766]=7, -- Rogue
	[42955]=7, -- Rogue
	[42956]=7, -- Rogue
	[42957]=7, -- Rogue
	[42958]=7, -- Rogue
	[42960]=7, -- Rogue
	[42961]=7, -- Rogue
	[42966]=7, -- Rogue
	[42970]=7, -- Rogue
	[42972]=7, -- Rogue
	[42973]=7, -- Rogue
	[42974]=7, -- Rogue
	[43343]=7, -- Rogue
	[43377]=7, -- Rogue
	[43379]=7, -- Rogue
	[43380]=7, -- Rogue
	[45768]=7, -- Rogue
	[43376]=7, -- Rogue
	[42967]=7, -- Rogue
	[45767]=7, -- Rogue
	[45761]=7, -- Rogue
	[45762]=7, -- Rogue
	[45764]=7, -- Rogue
	[42971]=7, -- Rogue
	[42959]=7, -- Rogue
	[45769]=7, -- Rogue
	[42954]=7, -- Rogue
	[42968]=7, -- Rogue
	[43378]=7, -- Rogue
	[42969]=7, -- Rogue
	[42963]=7, -- Rogue
	[42964]=7, -- Rogue
	[42962]=7, -- Rogue
	[64493]=7, -- Rogue
	[42965]=7, -- Rogue
	[63420]=7, -- Rogue
	[45777]=8, -- Shaman
	[41526]=8, -- Shaman
	[41531]=8, -- Shaman
	[41532]=8, -- Shaman
	[41533]=8, -- Shaman
	[41534]=8, -- Shaman
	[41536]=8, -- Shaman
	[41537]=8, -- Shaman
	[41540]=8, -- Shaman
	[41541]=8, -- Shaman
	[41547]=8, -- Shaman
	[43386]=8, -- Shaman
	[43388]=8, -- Shaman
	[43725]=8, -- Shaman
	[44923]=8, -- Shaman
	[45770]=8, -- Shaman
	[41530]=8, -- Shaman
	[41518]=8, -- Shaman
	[41539]=8, -- Shaman
	[45771]=8, -- Shaman
	[45772]=8, -- Shaman
	[41529]=8, -- Shaman
	[45778]=8, -- Shaman
	[41527]=8, -- Shaman
	[41552]=8, -- Shaman
	[45776]=8, -- Shaman
	[43344]=8, -- Shaman
	[41517]=8, -- Shaman
	[41538]=8, -- Shaman
	[41524]=8, -- Shaman
	[41542]=8, -- Shaman
	[41535]=8, -- Shaman
	[43381]=8, -- Shaman
	[43385]=8, -- Shaman
	[45775]=8, -- Shaman
	[45782]=9, -- Warlock
	[42458]=9, -- Warlock
	[42459]=9, -- Warlock
	[42461]=9, -- Warlock
	[42462]=9, -- Warlock
	[42464]=9, -- Warlock
	[42465]=9, -- Warlock
	[42467]=9, -- Warlock
	[42470]=9, -- Warlock
	[42472]=9, -- Warlock
	[42473]=9, -- Warlock
	[43389]=9, -- Warlock
	[43390]=9, -- Warlock
	[43391]=9, -- Warlock
	[45785]=9, -- Warlock
	[45789]=9, -- Warlock
	[42456]=9, -- Warlock
	[42455]=9, -- Warlock
	[45783]=9, -- Warlock
	[45779]=9, -- Warlock
	[45780]=9, -- Warlock
	[45781]=9, -- Warlock
	[43394]=9, -- Warlock
	[42453]=9, -- Warlock
	[42463]=9, -- Warlock
	[42457]=9, -- Warlock
	[42466]=9, -- Warlock
	[42460]=9, -- Warlock
	[43393]=9, -- Warlock
	[42468]=9, -- Warlock
	[43392]=9, -- Warlock
	[42471]=9, -- Warlock
	[42454]=9, -- Warlock
	[50077]=9, -- Warlock
	[63481]=10, -- Warrior
	[43395]=10, -- Warrior
	[43397]=10, -- Warrior
	[43399]=10, -- Warrior
	[43400]=10, -- Warrior
	[43412]=10, -- Warrior
	[43413]=10, -- Warrior
	[43414]=10, -- Warrior
	[43416]=10, -- Warrior
	[43417]=10, -- Warrior
	[43421]=10, -- Warrior
	[43422]=10, -- Warrior
	[43425]=10, -- Warrior
	[43427]=10, -- Warrior
	[43430]=10, -- Warrior
	[43431]=10, -- Warrior
	[67483]=10, -- Warrior
	[43428]=10, -- Warrior
	[43418]=10, -- Warrior
	[43419]=10, -- Warrior
	[45790]=10, -- Warrior
	[45792]=10, -- Warrior
	[49084]=10, -- Warrior
	[45795]=10, -- Warrior
	[43396]=10, -- Warrior
	[43398]=10, -- Warrior
	[67482]=10, -- Warrior
	[45797]=10, -- Warrior
	[43423]=10, -- Warrior
	[45794]=10, -- Warrior
	[43424]=10, -- Warrior
	[43415]=10, -- Warrior
	[43432]=10, -- Warrior
	[45793]=10, -- Warrior
	[60838]=11, -- Misc Items
	[44210]=11, -- Misc Items
	[38322]=11, -- Misc Items
	[43515]=11, -- Misc Items
	[43655]=11, -- Misc Items
	[43654]=11, -- Misc Items
	[43657]=11, -- Misc Items
	[43656]=11, -- Misc Items
	[43661]=11, -- Misc Items
	[43660]=11, -- Misc Items
	[43664]=11, -- Misc Items
	[43663]=11, -- Misc Items
	[43667]=11, -- Misc Items
	[43666]=11, -- Misc Items
	[45854]=11, -- Misc Items
	[45849]=11, -- Misc Items
	[62242]=11, -- Misc Items
	[62241]=11, -- Misc Items
	[62240]=11, -- Misc Items
	[62233]=11, -- Misc Items
	[62231]=11, -- Misc Items
	[62236]=11, -- Misc Items
	[62245]=11, -- Misc Items
	[62244]=11, -- Misc Items
	[62243]=11, -- Misc Items
	[62235]=11, -- Misc Items
	[62234]=11, -- Misc Items
	[37101]=12, -- Inks
	[39469]=12, -- Inks
	[39774]=12, -- Inks
	[43116]=12, -- Inks
	[43118]=12, -- Inks
	[43120]=12, -- Inks
	[43122]=12, -- Inks
	[43124]=12, -- Inks
	[43126]=12, -- Inks
	[61978]=12, -- Inks
	[61981]=12, -- Inks
}

Inscription.inks = {
	[37101] = { -- Ivory Ink
		herbs = {
			{itemID = 2449, pigmentPerMill = 3},
			{itemID = 2447, pigmentPerMill = 3},
			{itemID = 765, pigmentPerMill = 2.5},
		},
		pigment = 39151,
		pigmentPerInk = 1,
	},
	[39469] = { -- Moonglow Ink
		herbs = {
			{itemID = 2449, pigmentPerMill = 3},
			{itemID = 2447, pigmentPerMill = 3},
			{itemID = 765, pigmentPerMill = 2.5},
		},
		pigment = 39151,
		pigmentPerInk = 2,
	},
	[39774] = { -- Midnight Ink
		herbs = {
			{itemID = 785, pigmentPerMill = 2.5},
			{itemID = 2450, pigmentPerMill = 2.5},
			{itemID = 2452, pigmentPerMill = 2.5},
			{itemID = 2453, pigmentPerMill = 3},
			{itemID = 3820, pigmentPerMill = 3},
		},
		pigment = 39334,
		pigmentPerInk = 2,
	},
	[43116] = { -- Lion's Ink
		herbs = {
			{itemID = 3355, pigmentPerMill = 2.5},
			{itemID = 3369, pigmentPerMill = 2.5},
			{itemID = 3356, pigmentPerMill = 3},
			{itemID = 3357, pigmentPerMill = 3},
		},
		pigment = 39338,
		pigmentPerInk = 2,
	},
	[43118] = { -- Jadefire Ink
		herbs = {
			{itemID = 3819, pigmentPerMill = 3},
			{itemID = 3818, pigmentPerMill = 2.5},
			{itemID = 3821, pigmentPerMill = 2.5},
			{itemID = 3358, pigmentPerMill = 3.5},
		},
		pigment = 39339,
		pigmentPerInk = 2,
	},
	[43120] = { -- Celestial Ink
		herbs = {
			{itemID = 4625, pigmentPerMill = 2.5},
			{itemID = 8831, pigmentPerMill = 2.5},
			{itemID = 8836, pigmentPerMill = 2.5},
			{itemID = 8838, pigmentPerMill = 2.5},
			{itemID = 8839, pigmentPerMill = 3},
			{itemID = 8845, pigmentPerMill = 3},
			{itemID = 8846, pigmentPerMill = 3},
		},
		pigment = 39340,
		pigmentPerInk = 2,
	},
	[43122] = { -- Shimmering Ink
		herbs = {
			{itemID = 13464, pigmentPerMill = 2.5},
			{itemID = 13463, pigmentPerMill = 2.5},
			{itemID = 13465, pigmentPerMill = 3},
			{itemID = 13466, pigmentPerMill = 3},
			{itemID = 13467, pigmentPerMill = 3},
		},
		pigment = 39341,
		pigmentPerInk = 2,
	},
	[43124] = { -- Ethereal Ink
		herbs = {
			{itemID = 22786, pigmentPerMill = 2.5},
			{itemID = 22785, pigmentPerMill = 2.5},
			{itemID = 22789, pigmentPerMill = 2.5},
			{itemID = 22787, pigmentPerMill = 2.5}, -- Ragveil
			{itemID = 22790, pigmentPerMill = 3},
			{itemID = 22793, pigmentPerMill = 3},
			{itemID = 22791, pigmentPerMill = 3},
			{itemID = 22792, pigmentPerMill = 3},
		},
		pigment = 39342,
		pigmentPerInk = 2,
	},
	[43126] = { -- Ink of the Sea
		herbs = {
			{itemID = 37921, pigmentPerMill = 2.5},
			{itemID = 36901, pigmentPerMill = 2.5},
			{itemID = 36907, pigmentPerMill = 2.5},
			{itemID = 36904, pigmentPerMill = 2.5},
			{itemID = 39970, pigmentPerMill = 2.5}, -- Fire Leaf, not sure about the pigment in these two
			{itemID = 39969, pigmentPerMill = 2.5}, -- Fire Seed
			{itemID = 36903, pigmentPerMill = 3},
			{itemID = 36906, pigmentPerMill = 3},
			{itemID = 36905, pigmentPerMill = 3},
		},
		pigment = 39343,
		pigmentPerInk = 2,
	},
	[61978] = { -- Blackfallow Ink
		herbs = {
			{itemID = 52983, pigmentPerMill = 2.5},
			{itemID = 52984, pigmentPerMill = 2.5},
			{itemID = 52985, pigmentPerMill = 2.5},
			{itemID = 52986, pigmentPerMill = 2.5},
			{itemID = 52987, pigmentPerMill = 3},
			{itemID = 52988, pigmentPerMill = 3},
		},
		pigment = 61979,
		pigmentPerInk = 2,
	},
	[61981] = { -- Inferno Ink
		herbs = {
			{itemID = 52983, pigmentPerMill = 0.5},
			{itemID = 52984, pigmentPerMill = 0.5},
			{itemID = 52985, pigmentPerMill = 0.5},
			{itemID = 52986, pigmentPerMill = 0.5},
			{itemID = 52987, pigmentPerMill = 0.8},
			{itemID = 52988, pigmentPerMill = 0.8},
		},
		pigment = 61980,
		pigmentPerInk = 2,
	},
}