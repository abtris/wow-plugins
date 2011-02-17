-- $Id: Atlas_Transportation-enUS.lua 1167 2011-01-07 13:33:23Z arithmandar $
--[[

	Atlas, a World of Warcraft instance map browser
	Copyright 2005-2010 Dan Gilbert <dan.b.gilbert@gmail.com>
	Copyright 2010-2011 Lothaer <lothayer@gmail.com >, Atlas Team

	This file is part of Atlas.

	Atlas is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Atlas is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Atlas; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

--]]

local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("Atlas_Transportation", "enUS", true);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas", "deDE", false);

if AL then
	AL["Death Knight Only"] = "Death Knight Only";		-- Taxi node in Acherus: The Ebon Hold, which is only for Death Knight
	AL["Druid-only"] = "Druid-only";			-- Taxi node in Nighthaven, Moonglade which is only for Druid
	AL["Legend"] = "Legend";				-- The chart's legend, for example, the purple line means the portal's path
	AL["Gryphon"] = "Gryphon";
	AL["Orb of Translocation"] = "Orb of Translocation";	-- The Orb in Silvermonn City and Ruins of Lordaeron
	AL["Portals"] = "Portals";
	AL["Portal / Waygate Path to the destination"] = "Portal / Waygate Path to the destination";
	AL["Ship / Zeppelin sailing path to destination"] = "Ship / Zeppelin sailing path to destination";
	AL["Requires honored faction with Sha'tari Skyguard"] = "Requires honored faction with Sha'tari Skyguard";
	AL["Seahorse"] = "Seahorse";
	AL["South of the path along Lake Elune'ara"] = "South of the path along Lake Elune'ara";
	AL["Taxi Nodes"] = "Taxi Nodes";
	AL["Transportation Maps"] = "Transportation Maps";
	AL["Transporter"] = "Transporter";			-- The NPC who can transport you to other place
	AL["West of the path to Timbermaw Hold"] = "West of the path to Timbermaw Hold";
	AL["Wind Rider"] = "Wind Rider";
	AL["Zeppelin Towers"] = "Zeppelin Towers";

end