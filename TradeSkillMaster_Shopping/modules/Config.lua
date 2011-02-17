local TSM = select(2, ...)
local Config = TSM:NewModule("Config", "AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TradeSkillMaster_Shopping") -- loads the localization table

function Config:Load(parent)
	local page = {
		{
			type = "ScrollFrame",
			layout = "list",
			children = {
				{
					type = "InlineGroup",
					layout = "flow",
					title = "General Options",
					children = {
						{
							type = "Label",
							text = "Test",
						},
					},
				},
			},
		},
	}
end