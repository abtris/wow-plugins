-- load the parent file (TSM) into a local variable and register this file as a module
local TSM = select(2, ...)
local Config = TSM:NewModule("Config", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0") -- load the AceGUI libraries


function Config:Load(parent)
	local professions = {"Enchanting", "Inscription", "Jewelcrafting", "Alchemy", "Blacksmithing", "Leatherworking",
		"Tailoring", "Engineering", "Cooking"}
	local crafters = TSM.Data:GetPlayers()
	local profession, crafter
	
	local page = {}
	if not Config.alphaTesting then
		page = {
			{	-- scroll frame to contain everything
				type = "ScrollFrame",
				layout = "list",
				children = {
					{
						type = "Spacer",
						quantity = 2,
					},
					{
						type = "Label",
						fullWidth = true,
						fontObject = GameFontNormalLarge,
						text = "Currently, Gathering simply tracks mats on your different alts from your personal bags, bank, and guild bank for use by TradeSkillMaster_Crafting.\n\nEventually, Gathering will automatically get mats from your alt's bag/bank/guildbank and mail them to your crafter. This feature will be coming soon and any updates will be provided on the curse page!",
					},
				},
			},
		}
	else
		page = {
			{	-- scroll frame to contain everything
				type = "ScrollFrame",
				layout = "flow",
				children = {
					{
						type = "Dropdown",
						label = "Profession to gather mats for:",
						list = professions,
						value = TSM.db.factionrealm.currentProfession,
						relativeWidth = 0.49,
						callback = function(self, _, value)
								self:SetValue(value)
								profession = professions[value]
								local siblings = self.parent.children
								for i, frame in ipairs(siblings) do
									if frame == self then
										siblings[i+3]:SetDisabled(not (profession and crafter))
										break
									end
								end
							end,
					},
					{
						type = "Dropdown",
						label = "Character you will craft on:",
						list = crafters,
						value = TSM.db.factionrealm.currentCrafter,
						relativeWidth = 0.49,
						callback = function(self, _, value)
								self:SetValue(value)
								crafter = crafters[value]
								local siblings = self.parent.children
								for i, frame in ipairs(siblings) do
									if frame == self then
										siblings[i+2]:SetDisabled(not (profession and crafter))
										break
									end
								end
							end,
					},
					{
						type = "Spacer"
					},
					{
						type = "Button",
						text = "READY SET GO!",
						relativeWidth = 1,
						disabled = not (profession and crafter),
						callback = function() TSMAPI:CloseFrame() TSM:BuildTaskList(profession, crafter) end,
					},
				},
			},
		}
	end
	
	TSMAPI:BuildPage(parent, page)
end