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
                ["FAnchor"] = nil,           -- "BOTTOMRIGHT", "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT", "CURSOR", "SMART"
                                             -- If "HIDDEN" is given, then the tooltip will NOT be shown.
                                             -- Used only in Frames. TinyTip default (when nil) is BOTTOMRIGHT.
                                             -- "SMART" anchor will attempt to position the tooltip as to not obscure frames.
                ["FCursorAnchor"] = nil,     -- Which side of the cursor to anchor for frame units.
                                             -- TinyTip's default (when nil) is "BOTTOM".
                ["MAnchor"] = nil,           -- Used only for Mouseover units. Options same as above, with the
                                             -- addition of "GAMEDEFAULT". TinyTip Default is CURSOR.
                ["MCursorAnchor"] = nil,     -- Which side of the cursor to anchor for mouseover (world).
                ["FOffX"] = nil,             -- X offset for Frame units (horizontal).
                ["FOffY"] = nil,             -- Y offset for Frame units (vertical).
                ["MOffX"] = nil,             -- Offset for Mouseover units (World Frame).
                ["MOffY"] = nil              -- "     "       "       "       "
    }

    TinyTip_StandAloneDB =  (TinyTip_StandAloneDB and setmetatable(t, {__index=TinyTip_StandAloneDB})) or t
end

