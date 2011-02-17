-- $Id: Atlas_Transportation-deDE.lua 1167 2011-01-07 13:33:23Z arithmandar $
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
local AL = AceLocale:NewLocale("Atlas_Transportation", "deDE", false);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas", "deDE", false);

if AL then
	AL["Death Knight Only"] = "Nur Todesritter";
	AL["Druid-only"] = "Nur Druiden";
	AL["Legend"] = "Legende";
	AL["Gryphon"] = "Greif";
	AL["Orb of Translocation"] = "Translokationskugel";
	AL["Portals"] = "Portale";
	AL["Portal / Waygate Path to the destination"] = "Portal / Torpfad zum Ziel";
	AL["Ship / Zeppelin sailing path to destination"] = "Schiff / Zeppelinpfad zum Ziel";
	AL["Requires honored faction with Sha'tari Skyguard"] = "Benötigt wohlwollenden Ruf bei Himmelswache der Sha'tari";
	AL["Seahorse"] = "Seepferdchen";
	AL["South of the path along Lake Elune'ara"] = "Südlich des Elune'ara Seewegs";
	AL["Taxi Nodes"] = "Flugpunkte";
	AL["Transportation Maps"] = "Beförderungsrouten";
	AL["Transporter"] = "Transporter";
	AL["West of the path to Timbermaw Hold"] = "Westlich des Weges zur Holzschlundfeste";
	AL["Wind Rider"] = "Windreiter";
	AL["Zeppelin Towers"] = "Zeppelintürme";

end