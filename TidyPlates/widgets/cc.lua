
-- CC by Raid Icon
local ccReference = {)

ccReference.["SKULL"] = {
	icon = "",
	expirationTime = 0,
}

ccReference.["CROSS"] = {}

ccReference.["STAR"] = {}

ccReference.["DIAMOND"] = {}

ccReference.["CIRCLE"] = {}

ccReference.["MOON"] = {}

ccReference.["SQUARE"] = {}

ccReference.["TRIANGLE"] = {}

-- The widget..
-- frame
-- frame.icon = texture
-- frame.timeremaining = fontstring
-- frame.clock = statusbar
-- frame.expirationTime = value
-- Handler: Theme.OnUpdate
-- OnUpdate: Checks the current raid icon against the CC reference list, and starts a PolledHideIn request for the statusbar

-- The watcher...
--[[
would this interface with another addon?
or should this be an independent design?

if it's independent, it'll need to check the aura time-remaining.  can it do that with UNIT_AURA?  
--]]
