-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu, Mischanix				 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --

-- The following functions are contained attached to this file:
-- Cooking:HasProfession() - determines if the player is an tailor

-- The following "global" (within the addon) variables are initialized in this file:
-- Cooking.slot - hardcoded list of the slot of every craft

-- ===================================================================================== --


-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local Cooking = TSM:NewModule("Cooking", "AceEvent-3.0")

local debug = function(...) TSM:Debug(...) end -- for debugging

-- determines if the player is an tailor
function Cooking:HasProfession()
	local professionIDs = {2550, 3102, 3413, 18260, 33359, 51296, 88053}
	for _, id in pairs(professionIDs) do
		if IsSpellKnown(id) then return true end
	end
end

function Cooking:GetSlot(itemID)
	if not itemID then return end
	return Cooking.slot[itemID]
end

Cooking.slotList = {L["Level 1-35"], L["Level 36-70"], L["Level 71+"]}

Cooking.slot = {
	[44837]=1, -- Level 1-35
	[34832]=1, -- Level 1-35
	[33924]=1, -- Level 1-35
	[30816]=1, -- Level 1-35
	[6290]=1, -- Level 1-35
	[2679]=1, -- Level 1-35
	[787]=1, -- Level 1-35
	[17197]=1, -- Level 1-35
	[12224]=1, -- Level 1-35
	[6888]=1, -- Level 1-35
	[5472]=1, -- Level 1-35
	[2681]=1, -- Level 1-35
	[2680]=1, -- Level 1-35
	[27635]=1, -- Level 1-35
	[24105]=1, -- Level 1-35
	[5473]=1, -- Level 1-35
	[2888]=1, -- Level 1-35
	[17198]=1, -- Level 1-35
	[5474]=1, -- Level 1-35
	[67230]=1, -- Level 1-35
	[27636]=1, -- Level 1-35
	[22645]=1, -- Level 1-35
	[7676]=1, -- Level 1-35
	[6890]=1, -- Level 1-35
	[6316]=1, -- Level 1-35
	[5525]=1, -- Level 1-35
	[5477]=1, -- Level 1-35
	[5476]=1, -- Level 1-35
	[5095]=1, -- Level 1-35
	[4592]=1, -- Level 1-35
	[3662]=1, -- Level 1-35
	[3220]=1, -- Level 1-35
	[2687]=1, -- Level 1-35
	[2684]=1, -- Level 1-35
	[2683]=1, -- Level 1-35
	[2682]=1, -- Level 1-35
	[733]=1, -- Level 1-35
	[724]=1, -- Level 1-35
	[6657]=1, -- Level 1-35
	[44836]=1, -- Level 1-35
	[21072]=1, -- Level 1-35
	[5526]=1, -- Level 1-35
	[5478]=1, -- Level 1-35
	[2685]=1, -- Level 1-35
	[1082]=1, -- Level 1-35
	[5479]=1, -- Level 1-35
	[12209]=1, -- Level 1-35
	[5527]=1, -- Level 1-35
	[5480]=1, -- Level 1-35
	[4593]=1, -- Level 1-35
	[3727]=1, -- Level 1-35
	[3726]=1, -- Level 1-35
	[3666]=1, -- Level 1-35
	[3665]=1, -- Level 1-35
	[3664]=1, -- Level 1-35
	[3663]=1, -- Level 1-35
	[1017]=1, -- Level 1-35
	[20074]=1, -- Level 1-35
	[3728]=1, -- Level 1-35
	[44840]=1, -- Level 1-35
	[13851]=1, -- Level 1-35
	[12214]=1, -- Level 1-35
	[12213]=1, -- Level 1-35
	[12212]=1, -- Level 1-35
	[12210]=1, -- Level 1-35
	[10841]=1, -- Level 1-35
	[8364]=1, -- Level 1-35
	[6038]=1, -- Level 1-35
	[4594]=1, -- Level 1-35
	[4457]=1, -- Level 1-35
	[3729]=1, -- Level 1-35
	[21217]=2, -- Level 36-70
	[17222]=2, -- Level 36-70
	[12217]=2, -- Level 36-70
	[12215]=2, -- Level 36-70
	[44839]=2, -- Level 36-70
	[33004]=2, -- Level 36-70
	[18045]=2, -- Level 36-70
	[16766]=2, -- Level 36-70
	[13932]=2, -- Level 36-70
	[13931]=2, -- Level 36-70
	[13930]=2, -- Level 36-70
	[13929]=2, -- Level 36-70
	[13928]=2, -- Level 36-70
	[13927]=2, -- Level 36-70
	[12218]=2, -- Level 36-70
	[12216]=2, -- Level 36-70
	[6887]=2, -- Level 36-70
	[46691]=2, -- Level 36-70
	[35565]=2, -- Level 36-70
	[35563]=2, -- Level 36-70
	[20452]=2, -- Level 36-70
	[18254]=2, -- Level 36-70
	[13935]=2, -- Level 36-70
	[13934]=2, -- Level 36-70
	[13933]=2, -- Level 36-70
	[44838]=2, -- Level 36-70
	[33874]=2, -- Level 36-70
	[33867]=2, -- Level 36-70
	[33866]=2, -- Level 36-70
	[31673]=2, -- Level 36-70
	[31672]=2, -- Level 36-70
	[30155]=2, -- Level 36-70
	[27667]=2, -- Level 36-70
	[27666]=2, -- Level 36-70
	[27665]=2, -- Level 36-70
	[27664]=2, -- Level 36-70
	[27663]=2, -- Level 36-70
	[27662]=2, -- Level 36-70
	[27661]=2, -- Level 36-70
	[27660]=2, -- Level 36-70
	[27659]=2, -- Level 36-70
	[27658]=2, -- Level 36-70
	[27657]=2, -- Level 36-70
	[27656]=2, -- Level 36-70
	[27655]=2, -- Level 36-70
	[27651]=2, -- Level 36-70
	[21023]=2, -- Level 36-70
	[33825]=2, -- Level 36-70
	[34411]=3, -- Level 71+
	[33872]=3, -- Level 71+
	[33053]=3, -- Level 71+
	[33052]=3, -- Level 71+
	[33048]=3, -- Level 71+
	[62790]=3, -- Level 71+
	[62680]=3, -- Level 71+
	[62676]=3, -- Level 71+
	[62674]=3, -- Level 71+
	[62673]=3, -- Level 71+
	[62660]=3, -- Level 71+
	[62659]=3, -- Level 71+
	[62658]=3, -- Level 71+
	[62657]=3, -- Level 71+
	[62656]=3, -- Level 71+
	[62655]=3, -- Level 71+
	[62654]=3, -- Level 71+
	[62653]=3, -- Level 71+
	[62652]=3, -- Level 71+
	[62651]=3, -- Level 71+
	[62289]=3, -- Level 71+
	[44953]=3, -- Level 71+
	[43492]=3, -- Level 71+
	[43491]=3, -- Level 71+
	[43490]=3, -- Level 71+
	[43488]=3, -- Level 71+
	[43480]=3, -- Level 71+
	[43478]=3, -- Level 71+
	[43268]=3, -- Level 71+
	[43015]=3, -- Level 71+
	[43005]=3, -- Level 71+
	[43004]=3, -- Level 71+
	[43001]=3, -- Level 71+
	[43000]=3, -- Level 71+
	[42999]=3, -- Level 71+
	[42998]=3, -- Level 71+
	[42997]=3, -- Level 71+
	[42996]=3, -- Level 71+
	[42995]=3, -- Level 71+
	[42994]=3, -- Level 71+
	[42993]=3, -- Level 71+
	[42942]=3, -- Level 71+
	[34769]=3, -- Level 71+
	[34768]=3, -- Level 71+
	[34767]=3, -- Level 71+
	[34766]=3, -- Level 71+
	[34765]=3, -- Level 71+
	[34764]=3, -- Level 71+
	[34763]=3, -- Level 71+
	[34762]=3, -- Level 71+
	[34761]=3, -- Level 71+
	[34760]=3, -- Level 71+
	[34759]=3, -- Level 71+
	[34758]=3, -- Level 71+
	[34757]=3, -- Level 71+
	[34756]=3, -- Level 71+
	[34755]=3, -- Level 71+
	[34754]=3, -- Level 71+
	[34753]=3, -- Level 71+
	[34752]=3, -- Level 71+
	[34751]=3, -- Level 71+
	[34750]=3, -- Level 71+
	[34749]=3, -- Level 71+
	[34748]=3, -- Level 71+
	[34747]=3, -- Level 71+
	[62677]=3, -- Level 71+
	[62675]=3, -- Level 71+
	[62672]=3, -- Level 71+
	[62671]=3, -- Level 71+
	[62670]=3, -- Level 71+
	[62669]=3, -- Level 71+
	[62668]=3, -- Level 71+
	[62667]=3, -- Level 71+
	[62666]=3, -- Level 71+
	[62665]=3, -- Level 71+
	[62664]=3, -- Level 71+
	[62663]=3, -- Level 71+
	[62662]=3, -- Level 71+
	[62661]=3, -- Level 71+
	[62649]=3, -- Level 71+
	[62290]=3, -- Level 71+
	[39520]=3, -- Level 71+
	[45932]=3, -- Level 71+
}