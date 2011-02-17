-- $Id: Atlas_Transportation-zhCN.lua 1167 2011-01-07 13:33:23Z arithmandar $
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
-- http://ngacn.cc


local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("Atlas_Transportation", "zhCN", false);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas", "deDE", false);

if AL then
	AL["Death Knight Only"] = "死亡骑士专用";	-- Taxi node in Acherus: The Ebon Hold, which is only for Death Knight
	AL["Druid-only"] = "德鲁伊专用";
	AL["Legend"] = "图例";				-- The chart's legend, for example, the purple line means the portal's path
	AL["Orb of Translocation"] = "传送之门";
	AL["Portal Destinations"] = "传送门目的地";
	AL["Portals"] = "传送门";
	AL["Portal / Waygate Path to the destination"] = "传送门 / 界门传往目的地的路径";
	AL["Ship / Zeppelin sailing path to destination"] = "船只 / 飞船航向目的地的路径";
	AL["Requires honored faction with Sha'tari Skyguard"] = "需要 沙塔尔天空卫队 - 尊敬";
	AL["Seahorse"] = "海马";
	AL["South of the path along Lake Elune'ara"] = "月神湖旁小径的南方";
	AL["Taxi Nodes"] = "飞航点";
	AL["Transportation Maps"] = "交通线路图";
	AL["Transporter"] = "输送者";
	AL["West of the path to Timbermaw Hold"] = "通往木喉要塞道路的西方";
	AL["Zeppelin Towers"] = "飞船空塔";

end
