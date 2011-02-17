local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Mailing", "enUS", true)
if not L then return end

-- TradeSkillMaster_Mailing.lua
L["Mailing Options"] = true
L["Open All"] = true
L["TradeSkillMaster_Mailing: Auto-Mail"] = true
L["Runs TradeSkillMaster_Mailing's auto mailer, the last patch of mails will take ~10 seconds to send.\n\n[WARNING!] You will not get any confirmation before it starts to send mails, it is your own fault if you mistype your bankers name."] = true
L["How many seconds until the mailbox will retrieve new data and you can continue looting mail."] = true
L["Waiting..."] = true
L["Opening..."] = true
L["Cannot finish auto looting, inventory is full or too many unique items."] = true
L["%d mail"] = true
L["No items to send."] = true
L["Mailed items off to %s!"] = true

-- config.lua
L["Options"] = true
L["Auto Recheck Mail"] = true
L["Automatically rechecks mail every 60 seconds when you have too much mail.\n\nIf you loot all mail with this enabled, it will wait and recheck then keep auto looting."] = true
L["Don't Display Money Received"] = true
L["Checking this will stop TradesSkillMaster_Mailing from displaying money collected from your mailbox after auto looting"] = true
L["Add Mail Target"] = true
L["Auto mailing will let you setup groups and specific items that should be mailed to another characters."] = true
L["Check your spelling! If you typo a name, it will send to the wrong person."] = true
L["Player Name"] = true
L["The name of the player to send items to.\n\nCheck your spelling!"] = true
L["No player name entered."] = true
L["Player \"%s\" is already a mail target."] = true
L["Remove Mail Target"] = true
L["Items/Groups to Add:"] = true
L["Items/Groups to remove:"] = true