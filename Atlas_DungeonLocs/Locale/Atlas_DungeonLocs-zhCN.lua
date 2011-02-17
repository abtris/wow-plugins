-- $Id: Atlas_DungeonLocs-zhCN.lua 1167 2011-01-07 13:33:23Z arithmandar $
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

-- Atlas Localization Data (Chinese)
-- Initial translation by DiabloHu
-- Version : Chinese (by DiabloHu)
-- $Date: 2011-01-07 14:33:23 +0100 (Fr, 07. Jan 2011) $
-- $Revision: 1167 $
-- http://www.dreamgen.cn


local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("Atlas_DungeonLocs", "zhCN", false);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas_DungeonLocs", "deDE", false);
if AL then
	--Common
	AL["Battlegrounds"] = "战场";
	AL["Blue"] = "蓝色";
	AL["Dungeon Locations"] = "副本分布";
	AL["Green"] = "绿";
	AL["Instances"] = "副本地下城";
	AL["White"] = "白色";

	--Zones
	AL["Crusaders' Coliseum"] = "十字军大竞技场";
end
