-- $Id$
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

-- Atlas, an instance map browser
-- Initiator and previous author: Dan Gilbert, loglow@gmail.com
-- Maintainers: Lothaer, Dynaletik, Arith, Deadca7

local AtlasLocale = LibStub("AceLocale-3.0"):GetLocale("Atlas");
local BabbleSubZone = Atlas_GetLocaleLibBabble("LibBabble-SubZone-3.0");

--[[
************************************************************************************************
Global Atlas Strings

    Define the string IDs hear so that we can easily use them in UI XML.
    Translation should still be kept in translation file.
************************************************************************************************
--]]
ATLAS_TITLE			= AtlasLocale["ATLAS_TITLE"];

BINDING_HEADER_ATLAS_TITLE	= AtlasLocale["BINDING_HEADER_ATLAS_TITLE"];
BINDING_NAME_ATLAS_TOGGLE	= AtlasLocale["BINDING_NAME_ATLAS_TOGGLE"];
BINDING_NAME_ATLAS_OPTIONS	= AtlasLocale["BINDING_NAME_ATLAS_OPTIONS"];
BINDING_NAME_ATLAS_AUTOSEL	= AtlasLocale["BINDING_NAME_ATLAS_AUTOSEL"];

ATLAS_SLASH			= AtlasLocale["ATLAS_SLASH"];
ATLAS_SLASH_OPTIONS		= AtlasLocale["ATLAS_SLASH_OPTIONS"];

ATLAS_STRING_LOCATION		= AtlasLocale["ATLAS_STRING_LOCATION"];
ATLAS_STRING_LEVELRANGE		= AtlasLocale["ATLAS_STRING_LEVELRANGE"];
ATLAS_STRING_PLAYERLIMIT	= AtlasLocale["ATLAS_STRING_PLAYERLIMIT"];
ATLAS_STRING_SELECT_CAT		= AtlasLocale["ATLAS_STRING_SELECT_CAT"];
ATLAS_STRING_SELECT_MAP		= AtlasLocale["ATLAS_STRING_SELECT_MAP"];
ATLAS_STRING_SEARCH		= AtlasLocale["ATLAS_STRING_SEARCH"];
ATLAS_STRING_CLEAR		= AtlasLocale["ATLAS_STRING_CLEAR"];
ATLAS_STRING_MINLEVEL		= AtlasLocale["ATLAS_STRING_MINLEVEL"];

ATLAS_OPTIONS_BUTTON		= AtlasLocale["ATLAS_OPTIONS_BUTTON"];
ATLAS_OPTIONS_SHOWBUT		= AtlasLocale["ATLAS_OPTIONS_SHOWBUT"];
ATLAS_OPTIONS_SHOWBUT_TIP	= AtlasLocale["ATLAS_OPTIONS_SHOWBUT_TIP"];
ATLAS_OPTIONS_AUTOSEL		= AtlasLocale["ATLAS_OPTIONS_AUTOSEL"];
ATLAS_OPTIONS_AUTOSEL_TIP	= AtlasLocale["ATLAS_OPTIONS_AUTOSEL_TIP"];
ATLAS_OPTIONS_BUTPOS		= AtlasLocale["ATLAS_OPTIONS_BUTPOS"];
ATLAS_OPTIONS_TRANS		= AtlasLocale["ATLAS_OPTIONS_TRANS"];
ATLAS_OPTIONS_RCLICK		= AtlasLocale["ATLAS_OPTIONS_RCLICK"];
ATLAS_OPTIONS_RCLICK_TIP	= AtlasLocale["ATLAS_OPTIONS_RCLICK_TIP"];
ATLAS_OPTIONS_RESETPOS		= AtlasLocale["ATLAS_OPTIONS_RESETPOS"];
ATLAS_OPTIONS_ACRONYMS		= AtlasLocale["ATLAS_OPTIONS_ACRONYMS"];
ATLAS_OPTIONS_ACRONYMS_TIP	= AtlasLocale["ATLAS_OPTIONS_ACRONYMS_TIP"];
ATLAS_OPTIONS_SCALE		= AtlasLocale["ATLAS_OPTIONS_SCALE"];
ATLAS_OPTIONS_BUTRAD		= AtlasLocale["ATLAS_OPTIONS_BUTRAD"];
ATLAS_OPTIONS_CLAMPED		= AtlasLocale["ATLAS_OPTIONS_CLAMPED"];
ATLAS_OPTIONS_CLAMPED_TIP	= AtlasLocale["ATLAS_OPTIONS_CLAMPED_TIP"];
ATLAS_OPTIONS_CTRL		= AtlasLocale["ATLAS_OPTIONS_CTRL"];
ATLAS_OPTIONS_CTRL_TIP		= AtlasLocale["ATLAS_OPTIONS_CTRL_TIP"];

ATLAS_BUTTON_TOOLTIP_TITLE	= AtlasLocale["ATLAS_BUTTON_TOOLTIP_TITLE"];
ATLAS_BUTTON_TOOLTIP_HINT	= AtlasLocale["ATLAS_BUTTON_TOOLTIP_HINT"];
ATLAS_LDB_HINT			= AtlasLocale["ATLAS_LDB_HINT"];

ATLAS_OPTIONS_CATDD		= AtlasLocale["ATLAS_OPTIONS_CATDD"];
ATLAS_DDL_CONTINENT		= AtlasLocale["ATLAS_DDL_CONTINENT"];
ATLAS_DDL_CONTINENT_EASTERN	= AtlasLocale["ATLAS_DDL_CONTINENT_EASTERN"];
ATLAS_DDL_CONTINENT_EASTERN1	= AtlasLocale["ATLAS_DDL_CONTINENT_EASTERN"].." 1/2";
ATLAS_DDL_CONTINENT_EASTERN2	= AtlasLocale["ATLAS_DDL_CONTINENT_EASTERN"].." 2/2";
ATLAS_DDL_CONTINENT_KALIMDOR	= AtlasLocale["ATLAS_DDL_CONTINENT_KALIMDOR"];
ATLAS_DDL_CONTINENT_OUTLAND	= AtlasLocale["ATLAS_DDL_CONTINENT_OUTLAND"];
ATLAS_DDL_CONTINENT_NORTHREND	= AtlasLocale["ATLAS_DDL_CONTINENT_NORTHREND"];
ATLAS_DDL_CONTINENT_DEEPHOLM	= AtlasLocale["ATLAS_DDL_CONTINENT_DEEPHOLM"];
ATLAS_DDL_LEVEL			= AtlasLocale["ATLAS_DDL_LEVEL"];
ATLAS_DDL_LEVEL_UNDER45		= AtlasLocale["ATLAS_DDL_LEVEL_UNDER45"];
ATLAS_DDL_LEVEL_45TO60		= AtlasLocale["ATLAS_DDL_LEVEL_45TO60"];
ATLAS_DDL_LEVEL_60TO70		= AtlasLocale["ATLAS_DDL_LEVEL_60TO70"];
ATLAS_DDL_LEVEL_70TO80		= AtlasLocale["ATLAS_DDL_LEVEL_70TO80"];
ATLAS_DDL_LEVEL_80TO85		= AtlasLocale["ATLAS_DDL_LEVEL_80TO85"];
ATLAS_DDL_LEVEL_85PLUS		= AtlasLocale["ATLAS_DDL_LEVEL_85PLUS"];
ATLAS_DDL_PARTYSIZE		= AtlasLocale["ATLAS_DDL_PARTYSIZE"];
ATLAS_DDL_PARTYSIZE_5_AE	= AtlasLocale["ATLAS_DDL_PARTYSIZE_5_AE"];
ATLAS_DDL_PARTYSIZE_5_FS	= AtlasLocale["ATLAS_DDL_PARTYSIZE_5_FS"];
ATLAS_DDL_PARTYSIZE_5_TZ	= AtlasLocale["ATLAS_DDL_PARTYSIZE_5_TZ"];
ATLAS_DDL_PARTYSIZE_10_AN	= AtlasLocale["ATLAS_DDL_PARTYSIZE_10_AN"];
ATLAS_DDL_PARTYSIZE_10_OZ	= AtlasLocale["ATLAS_DDL_PARTYSIZE_10_OZ"];
ATLAS_DDL_PARTYSIZE_20TO40	= AtlasLocale["ATLAS_DDL_PARTYSIZE_20TO40"];
ATLAS_DDL_EXPANSION		= AtlasLocale["ATLAS_DDL_EXPANSION"];
ATLAS_DDL_EXPANSION_OLD_AO	= AtlasLocale["ATLAS_DDL_EXPANSION_OLD_AO"];
ATLAS_DDL_EXPANSION_OLD_PZ	= AtlasLocale["ATLAS_DDL_EXPANSION_OLD_PZ"];
ATLAS_DDL_EXPANSION_BC		= AtlasLocale["ATLAS_DDL_EXPANSION_BC"];
ATLAS_DDL_EXPANSION_WOTLK	= AtlasLocale["ATLAS_DDL_EXPANSION_WOTLK"];
ATLAS_DDL_EXPANSION_CATA	= AtlasLocale["ATLAS_DDL_EXPANSION_CATA"];
ATLAS_DDL_TYPE			= AtlasLocale["ATLAS_DDL_TYPE"];
ATLAS_DDL_TYPE_INSTANCE_AC	= AtlasLocale["ATLAS_DDL_TYPE_INSTANCE_AC"];
ATLAS_DDL_TYPE_INSTANCE_DR	= AtlasLocale["ATLAS_DDL_TYPE_INSTANCE_DR"];
ATLAS_DDL_TYPE_INSTANCE_SZ	= AtlasLocale["ATLAS_DDL_TYPE_INSTANCE_SZ"];
ATLAS_DDL_TYPE_ENTRANCE		= AtlasLocale["ATLAS_DDL_TYPE_ENTRANCE"];

ATLAS_INSTANCE_BUTTON		= AtlasLocale["ATLAS_INSTANCE_BUTTON"];
ATLAS_ENTRANCE_BUTTON		= AtlasLocale["ATLAS_ENTRANCE_BUTTON"];
ATLAS_SEARCH_UNAVAIL		= AtlasLocale["ATLAS_SEARCH_UNAVAIL"];

ATLAS_DEP_MSG1			= AtlasLocale["ATLAS_DEP_MSG1"];
ATLAS_DEP_MSG2			= AtlasLocale["ATLAS_DEP_MSG2"];
ATLAS_DEP_MSG3			= AtlasLocale["ATLAS_DEP_MSG3"];
ATLAS_DEP_OK			= AtlasLocale["ATLAS_DEP_OK"];

