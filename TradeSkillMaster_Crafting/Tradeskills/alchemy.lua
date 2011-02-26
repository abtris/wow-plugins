-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu, Mischanix				 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --

-- The following functions are contained attached to this file:
-- Alchemy:HasProfession() - determines if the player is an alchemist

-- The following "global" (within the addon) variables are initialized in this file:
-- Alchemy.slot - hardcoded list of the slot of every craft

-- ===================================================================================== --


-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local Alchemy = TSM:NewModule("Alchemy", "AceEvent-3.0")

local debug = function(...) TSM:Debug(...) end -- for debugging

-- determines if the player is an alchemist
function Alchemy:HasProfession()
	local professionIDs = {2259, 3101, 3464, 11611, 28596, 51304, 80731}
	for _, id in pairs(professionIDs) do
		if IsSpellKnown(id) then return true end
	end
end

function Alchemy:GetSlot(itemID)
	if not itemID then return end
	return Alchemy.slot[itemID]
end

Alchemy.slotList = {L["Elixir"], L["Potion"], L["Flask"], L["Other Consumable"], L["Transmutes"], L["Misc Items"]}

Alchemy.slot = {
	[58084]=1, -- Elixir
	[58089]=1, -- Elixir
	[58092]=1, -- Elixir
	[58093]=1, -- Elixir
	[58094]=1, -- Elixir
	[58143]=1, -- Elixir
	[58144]=1, -- Elixir
	[58148]=1, -- Elixir
	[39666]=1, -- Elixir
	[40068]=1, -- Elixir
	[40070]=1, -- Elixir
	[40072]=1, -- Elixir
	[40073]=1, -- Elixir
	[40076]=1, -- Elixir
	[40078]=1, -- Elixir
	[40097]=1, -- Elixir
	[40109]=1, -- Elixir
	[44325]=1, -- Elixir
	[44327]=1, -- Elixir
	[44328]=1, -- Elixir
	[44329]=1, -- Elixir
	[44330]=1, -- Elixir
	[44331]=1, -- Elixir
	[44332]=1, -- Elixir
	[22835]=1, -- Elixir
	[22840]=1, -- Elixir
	[22848]=1, -- Elixir
	[22834]=1, -- Elixir
	[31679]=1, -- Elixir
	[22831]=1, -- Elixir
	[32068]=1, -- Elixir
	[22830]=1, -- Elixir
	[22827]=1, -- Elixir
	[22833]=1, -- Elixir
	[32067]=1, -- Elixir
	[28104]=1, -- Elixir
	[32063]=1, -- Elixir
	[22823]=1, -- Elixir
	[22824]=1, -- Elixir
	[22825]=1, -- Elixir
	[32062]=1, -- Elixir
	[28102]=1, -- Elixir
	[28103]=1, -- Elixir
	[20004]=1, -- Elixir
	[13454]=1, -- Elixir
	[13452]=1, -- Elixir
	[13453]=1, -- Elixir
	[13447]=1, -- Elixir
	[13445]=1, -- Elixir
	[8827]=1, -- Elixir
	[9224]=1, -- Elixir
	[9233]=1, -- Elixir
	[9264]=1, -- Elixir
	[20007]=1, -- Elixir
	[21546]=1, -- Elixir
	[9088]=1, -- Elixir
	[9187]=1, -- Elixir
	[9197]=1, -- Elixir
	[9206]=1, -- Elixir
	[9155]=1, -- Elixir
	[9179]=1, -- Elixir
	[9154]=1, -- Elixir
	[18294]=1, -- Elixir
	[10592]=1, -- Elixir
	[3828]=1, -- Elixir
	[8951]=1, -- Elixir
	[17708]=1, -- Elixir
	[8949]=1, -- Elixir
	[3826]=1, -- Elixir
	[3825]=1, -- Elixir
	[3391]=1, -- Elixir
	[3390]=1, -- Elixir
	[6373]=1, -- Elixir
	[3389]=1, -- Elixir
	[3388]=1, -- Elixir
	[3383]=1, -- Elixir
	[45621]=1, -- Elixir
	[5996]=1, -- Elixir
	[6662]=1, -- Elixir
	[2457]=1, -- Elixir
	[2458]=1, -- Elixir
	[3382]=1, -- Elixir
	[2454]=1, -- Elixir
	[5997]=1, -- Elixir
	[57099]=2, -- Potion
	[57194]=2, -- Potion
	[58090]=2, -- Potion
	[58091]=2, -- Potion
	[58145]=2, -- Potion
	[58146]=2, -- Potion
	[58488]=2, -- Potion
	[58489]=2, -- Potion
	[57193]=2, -- Potion
	[58487]=2, -- Potion
	[57191]=2, -- Potion
	[57192]=2, -- Potion
	[67415]=2, -- Potion
	[33447]=2, -- Potion
	[33448]=2, -- Potion
	[40077]=2, -- Potion
	[40081]=2, -- Potion
	[40087]=2, -- Potion
	[40093]=2, -- Potion
	[40211]=2, -- Potion
	[40212]=2, -- Potion
	[40213]=2, -- Potion
	[40214]=2, -- Potion
	[40215]=2, -- Potion
	[40216]=2, -- Potion
	[40217]=2, -- Potion
	[22850]=2, -- Potion
	[34440]=2, -- Potion
	[39671]=2, -- Potion
	[40067]=2, -- Potion
	[22849]=2, -- Potion
	[31677]=2, -- Potion
	[22836]=2, -- Potion
	[22837]=2, -- Potion
	[22838]=2, -- Potion
	[22839]=2, -- Potion
	[22841]=2, -- Potion
	[22842]=2, -- Potion
	[22844]=2, -- Potion
	[22845]=2, -- Potion
	[22846]=2, -- Potion
	[22847]=2, -- Potion
	[31676]=2, -- Potion
	[22832]=2, -- Potion
	[22871]=2, -- Potion
	[22829]=2, -- Potion
	[22828]=2, -- Potion
	[22826]=2, -- Potion
	[28101]=2, -- Potion
	[13506]=2, -- Potion
	[18253]=2, -- Potion
	[20002]=2, -- Potion
	[28100]=2, -- Potion
	[13444]=2, -- Potion
	[13456]=2, -- Potion
	[13457]=2, -- Potion
	[13458]=2, -- Potion
	[13459]=2, -- Potion
	[13461]=2, -- Potion
	[13462]=2, -- Potion
	[20008]=2, -- Potion
	[13455]=2, -- Potion
	[3386]=2, -- Potion
	[13446]=2, -- Potion
	[13442]=2, -- Potion
	[13443]=2, -- Potion
	[3387]=2, -- Potion
	[9172]=2, -- Potion
	[3928]=2, -- Potion
	[9144]=2, -- Potion
	[12190]=2, -- Potion
	[4623]=2, -- Potion
	[9030]=2, -- Potion
	[9036]=2, -- Potion
	[6149]=2, -- Potion
	[6050]=2, -- Potion
	[6052]=2, -- Potion
	[5633]=2, -- Potion
	[3823]=2, -- Potion
	[6049]=2, -- Potion
	[3827]=2, -- Potion
	[1710]=2, -- Potion
	[5634]=2, -- Potion
	[6048]=2, -- Potion
	[3385]=2, -- Potion
	[929]=2, -- Potion
	[3384]=2, -- Potion
	[6051]=2, -- Potion
	[6372]=2, -- Potion
	[2455]=2, -- Potion
	[2456]=2, -- Potion
	[2459]=2, -- Potion
	[4596]=2, -- Potion
	[5631]=2, -- Potion
	[858]=2, -- Potion
	[118]=2, -- Potion
	[58085]=3, -- Flask
	[58086]=3, -- Flask
	[58087]=3, -- Flask
	[58088]=3, -- Flask
	[67438]=3, -- Flask
	[40079]=3, -- Flask
	[44939]=3, -- Flask
	[46376]=3, -- Flask
	[46377]=3, -- Flask
	[46378]=3, -- Flask
	[46379]=3, -- Flask
	[22851]=3, -- Flask
	[22853]=3, -- Flask
	[22854]=3, -- Flask
	[22861]=3, -- Flask
	[22866]=3, -- Flask
	[33208]=3, -- Flask
	[13510]=3, -- Flask
	[13511]=3, -- Flask
	[13512]=3, -- Flask
	[13513]=3, -- Flask
	[58142]=4, -- Other Consumable
	[32839]=4, -- Other Consumable
	[32849]=4, -- Other Consumable
	[32850]=4, -- Other Consumable
	[32851]=4, -- Other Consumable
	[32852]=4, -- Other Consumable
	[8956]=4, -- Other Consumable
	[36919]=5, -- Transmutes
	[36922]=5, -- Transmutes
	[36925]=5, -- Transmutes
	[36928]=5, -- Transmutes
	[36931]=5, -- Transmutes
	[36934]=5, -- Transmutes
	[52190]=5, -- Transmutes
	[52191]=5, -- Transmutes
	[52192]=5, -- Transmutes
	[52193]=5, -- Transmutes
	[52194]=5, -- Transmutes
	[52195]=5, -- Transmutes
	[52303]=5, -- Transmutes
	[41266]=5, -- Transmutes
	[41334]=5, -- Transmutes
	[25867]=5, -- Transmutes
	[25868]=5, -- Transmutes
	[23571]=5, -- Transmutes
	[41163]=5, -- Transmutes
	[35622]=5, -- Transmutes
	[35623]=5, -- Transmutes
	[35624]=5, -- Transmutes
	[35625]=5, -- Transmutes
	[35627]=5, -- Transmutes
	[36860]=5, -- Transmutes
	[21884]=5, -- Transmutes
	[21885]=5, -- Transmutes
	[21886]=5, -- Transmutes
	[22451]=5, -- Transmutes
	[22452]=5, -- Transmutes
	[22456]=5, -- Transmutes
	[22457]=5, -- Transmutes
	[7076]=5, -- Transmutes
	[7078]=5, -- Transmutes
	[7082]=5, -- Transmutes
	[12360]=5, -- Transmutes
	[12803]=5, -- Transmutes
	[12808]=5, -- Transmutes
	[6037]=5, -- Transmutes
	[3577]=5, -- Transmutes
	[6370]=6, -- Misc Items
	[56850]=6, -- Misc Items
	[44958]=6, -- Misc Items
	[6371]=6, -- Misc Items
	[3829]=6, -- Misc Items
	[8956]=6, -- Misc Items
	[40195]=6, -- Misc Items
	[3824]=6, -- Misc Items
	[13423]=6, -- Misc Items
}