--[[
-- You need edit this file for configuration ONLY if
-- TinyTipOptions is NOT loaded. Otherwise, the options
-- in this file do nothing.
--]]

if not TinyTipDB or not TinyTipDB.configured then
    local t = {
                --[[
                -- To select the TinyTip default, set the value to nil.
                --]]
                --                              -- default, option1, option2, etc.
                ["TargetsTooltipUnit"] = nil,   -- nil, 1, 2
                                                -- The default (nil) is to add it as a new line. 1 will
                                                -- add it to the name of the unit as Name : Target.
                                                -- 2 will disable this option.
                ["TargetsParty"] = nil,         -- nil, 1, 2
                                                -- The default (nil) is the
                                                -- number of people in your party targeting the unit.
                                                -- 1 will show all their names.
                                                -- 2 will disable this option.
                ["TargetsRaid"] = nil,          -- nil, 1
                                                -- The default (nil) is enabled.
                ["TargetsNoEventUpdate"] = nil  -- nil, true
                                                -- The default (nil) enables dynamic changing of
                                                -- targets in the tooltip via UNIT_TARGET.
    }

    TinyTip_StandAloneDB =  (TinyTip_StandAloneDB and setmetatable(t, {__index=TinyTip_StandAloneDB})) or t
    t = nil
end

