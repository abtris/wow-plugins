-- $Id: Atlas_Transportation-esES.lua 1167 2011-01-07 13:33:23Z arithmandar $
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

--[[

-- Datos de Atlas (Español)
-- Traducido por --> maqjav|Marosth de Tyrande<--
-- maqjav@hotmail.com
-- Úlltima Actualización (last update): 31/12/2010

--]]
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("Atlas_Transportation", "esES", false);
-- Localize file must set above to false, for example:
--    local AL = AceLocale:NewLocale("Atlas", "deDE", false);

if AL then
	AL["Death Knight Only"] = "Solo caballeros de la muerte";		-- Taxi node in Acherus: The Ebon Hold, which is only for Death Knight
	AL["Druid-only"] = "Solo druidas";			-- Taxi node in Nighthaven, Moonglade which is only for Druid
	AL["Legend"] = "Leyenda";				-- The chart's legend, for example, the purple line means the portal's path
	AL["Gryphon"] = "Grifo";
	AL["Orb of Translocation"] = "Orbe de traslado";	-- The Orb in Silvermonn City and Ruins of Lordaeron
	AL["Portal Destinations"] = "Destinos de los portales";
	AL["Portals"] = "Portales";				
	AL["Portal / Waygate Path to the destination"] = "Portal / Puerta con destino";
	AL["Ship / Zeppelin sailing path to destination"] = "Barco / Velero Zepelín con destino";
	AL["Requires honored faction with Sha'tari Skyguard"] = "Requiere honorable con la facción Guardia del cielo Sha'tari";
	AL["Seahorse"] = "Cabllito de mar";				
	AL["South of the path along Lake Elune'ara"] = "Sur del camino a Lago Elune'ara";
	AL["Taxi Nodes"] = "Paradas de Taxi";			
	AL["Transportation Maps"] = "Mapas de Transportes";
	AL["Transporter"] = "Transportador";			-- The NPC who can transport you to other place
	AL["West of the path to Timbermaw Hold"] = "Oeste del camino al Puesto Vigóa del Cubil";
	AL["Wind Rider"] = "Jinete del viento";
	AL["Zeppelin Towers"] = "Aeropuertos Zepelín";		

end