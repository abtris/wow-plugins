-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu, Mischanix				 		  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
-- ------------------------------------------------------------------------------------- --

-- The following functions are contained attached to this file:
-- Engineering:HasProfession() - determines if the player is an tailor

-- The following "global" (within the addon) variables are initialized in this file:
-- Engineering.slot - hardcoded list of the slot of every craft

-- ===================================================================================== --


-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Crafting") -- loads the localization table
local Engineering = TSM:NewModule("Engineering", "AceEvent-3.0")

local debug = function(...) TSM:Debug(...) end -- for debugging

-- determines if the player is an tailor
function Engineering:HasProfession()
	local professionIDs = {4036, 4037, 4038, 12656, 30350, 51306, 82774}
	for _, id in pairs(professionIDs) do
		if IsSpellKnown(id) then return true end
	end
end

function Engineering:GetSlot(itemID)
	if not itemID then return end
	return Engineering.slot[itemID]
end

Engineering.slotList = {L["Armor"], L["Guns"], L["Scopes"], L["Consumables"], L["Explosives"], L["Companions"], L["Trinkets"], L["Misc Items"]}

Engineering.slot = {
	[18168]=1, -- Armor
	[60403]=1, -- Armor
	[41112]=1, -- Armor
	[44740]=1, -- Armor
	[44741]=1, -- Armor
	[44742]=1, -- Armor
	[40767]=1, -- Armor
	[40865]=1, -- Armor
	[23762]=1, -- Armor
	[23763]=1, -- Armor
	[23824]=1, -- Armor
	[35581]=1, -- Armor
	[23825]=1, -- Armor
	[23758]=1, -- Armor
	[23761]=1, -- Armor
	[60223]=1, -- Armor
	[40895]=1, -- Armor
	[48933]=1, -- Armor
	[23836]=1, -- Armor
	[23835]=1, -- Armor
	[19998]=1, -- Armor
	[19999]=1, -- Armor
	[16022]=1, -- Armor
	[18639]=1, -- Armor
	[18638]=1, -- Armor
	[45631]=1, -- Armor
	[18634]=1, -- Armor
	[10504]=1, -- Armor
	[30542]=1, -- Armor
	[30544]=1, -- Armor
	[16008]=1, -- Armor
	[16009]=1, -- Armor
	[18637]=1, -- Armor
	[18984]=1, -- Armor
	[15999]=1, -- Armor
	[18986]=1, -- Armor
	[10576]=1, -- Armor
	[10588]=1, -- Armor
	[10726]=1, -- Armor
	[10503]=1, -- Armor
	[10506]=1, -- Armor
	[7189]=1, -- Armor
	[10518]=1, -- Armor
	[10724]=1, -- Armor
	[10501]=1, -- Armor
	[10502]=1, -- Armor
	[10721]=1, -- Armor
	[10720]=1, -- Armor
	[10500]=1, -- Armor
	[10577]=1, -- Armor
	[10716]=1, -- Armor
	[4396]=1, -- Armor
	[4397]=1, -- Armor
	[4393]=1, -- Armor
	[10499]=1, -- Armor
	[4385]=1, -- Armor
	[4381]=1, -- Armor
	[7506]=1, -- Armor
	[4373]=1, -- Armor
	[4368]=1, -- Armor
	[60222]=1, -- Armor
	[41168]=2, -- Guns
	[44504]=2, -- Guns
	[32756]=2, -- Guns
	[18282]=2, -- Guns
	[59364]=2, -- Guns
	[59367]=2, -- Guns
	[59598]=2, -- Guns
	[59599]=2, -- Guns
	[23748]=2, -- Guns
	[23747]=2, -- Guns
	[16007]=2, -- Guns
	[16004]=2, -- Guns
	[23746]=2, -- Guns
	[23742]=2, -- Guns
	[15995]=2, -- Guns
	[10510]=2, -- Guns
	[10508]=2, -- Guns
	[4383]=2, -- Guns
	[4379]=2, -- Guns
	[4372]=2, -- Guns
	[4369]=2, -- Guns
	[4362]=2, -- Guns
	[6219]=2, -- Guns
	[59594]=3, -- Scopes
	[59595]=3, -- Scopes
	[59596]=3, -- Scopes
	[41167]=3, -- Scopes
	[23766]=3, -- Scopes
	[41146]=3, -- Scopes
	[23765]=3, -- Scopes
	[18283]=3, -- Scopes
	[23764]=3, -- Scopes
	[4407]=3, -- Scopes
	[44739]=3, -- Scopes
	[10548]=3, -- Scopes
	[10546]=3, -- Scopes
	[4406]=3, -- Scopes
	[4405]=3, -- Scopes
	[20475]=4, -- Consumables
	[19026]=4, -- Consumables
	[9312]=4, -- Consumables
	[9313]=4, -- Consumables
	[9318]=4, -- Consumables
	[23768]=4, -- Consumables
	[23771]=4, -- Consumables
	[25886]=4, -- Consumables
	[60853]=5, -- Explosives
	[40536]=5, -- Explosives
	[42641]=5, -- Explosives
	[44951]=5, -- Explosives
	[40771]=5, -- Explosives
	[23819]=5, -- Explosives
	[23841]=5, -- Explosives
	[23827]=5, -- Explosives
	[23737]=5, -- Explosives
	[23826]=5, -- Explosives
	[32413]=5, -- Explosives
	[16040]=5, -- Explosives
	[23736]=5, -- Explosives
	[16005]=5, -- Explosives
	[18594]=5, -- Explosives
	[15993]=5, -- Explosives
	[10562]=5, -- Explosives
	[10586]=5, -- Explosives
	[18641]=5, -- Explosives
	[4394]=5, -- Explosives
	[10514]=5, -- Explosives
	[10646]=5, -- Explosives
	[4398]=5, -- Explosives
	[18588]=5, -- Explosives
	[4395]=5, -- Explosives
	[4852]=5, -- Explosives
	[4390]=5, -- Explosives
	[10507]=5, -- Explosives
	[4380]=5, -- Explosives
	[4378]=5, -- Explosives
	[4384]=5, -- Explosives
	[4374]=5, -- Explosives
	[4370]=5, -- Explosives
	[6714]=5, -- Explosives
	[4365]=5, -- Explosives
	[4367]=5, -- Explosives
	[4360]=5, -- Explosives
	[4358]=5, -- Explosives
	[59597]=6, -- Companions
	[60216]=6, -- Companions
	[21277]=6, -- Companions
	[15996]=6, -- Companions
	[11825]=6, -- Companions
	[11826]=6, -- Companions
	[4401]=6, -- Companions
	[60403]=7, -- Trinkets
	[40767]=7, -- Trinkets
	[40865]=7, -- Trinkets
	[23836]=7, -- Trinkets
	[23835]=7, -- Trinkets
	[16022]=7, -- Trinkets
	[18639]=7, -- Trinkets
	[18638]=7, -- Trinkets
	[45631]=7, -- Trinkets
	[18634]=7, -- Trinkets
	[18637]=7, -- Trinkets
	[10576]=7, -- Trinkets
	[10720]=7, -- Trinkets
	[10577]=7, -- Trinkets
	[10716]=7, -- Trinkets
	[4396]=7, -- Trinkets
	[4397]=7, -- Trinkets
	[4381]=7, -- Trinkets
	[7506]=7, -- Trinkets
	[60217]=8, -- Misc Items
	[68049]=8, -- Misc Items
	[60858]=8, -- Misc Items
	[60218]=8, -- Misc Items
}