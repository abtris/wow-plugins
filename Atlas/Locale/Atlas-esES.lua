-- $Id: Atlas-esES.lua 1220 2011-01-28 13:36:29Z dynaletik $
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
local AL = AceLocale:NewLocale("Atlas", "esES", false);

-- Atlas Spanish Localization
-- Traducido por --> maqjav|Marosth de Tyrande<--
-- maqjav@gmail.com
-- Última Actualización (last update): 23/01/2011

if ( GetLocale() == "esES" ) then
-- Define the leading strings to be ignored while sorting
-- Ex: The Stockade
AtlasSortIgnore = {"the (.+)"};

AtlasZoneSubstitutions = {
	["Ahn'Qiraj"] = "Templo de Ahn'Qiraj";
	["The Temple of Atal'Hakkar"] = "El Templo de Atal'Hakkar";
};
end


if AL then
--************************************************
-- UI terms and common strings
--************************************************
	AL["ATLAS_TITLE"] = "Atlas";

	AL["BINDING_HEADER_ATLAS_TITLE"] = "Enlaces Atlas";
	AL["BINDING_NAME_ATLAS_TOGGLE"] = "Barra del Atlas";
	AL["BINDING_NAME_ATLAS_OPTIONS"] = "Opciones de la Barra";
	AL["BINDING_NAME_ATLAS_AUTOSEL"] = "Auto-Selecciona";

	AL["ATLAS_SLASH"] = "/atlas";
	AL["ATLAS_SLASH_OPTIONS"] = "opciones";

	AL["ATLAS_STRING_LOCATION"] = "Localización";
	AL["ATLAS_STRING_LEVELRANGE"] = "Rango de nivel";
	AL["ATLAS_STRING_PLAYERLIMIT"] = "Límite de Jugadores";
	AL["ATLAS_STRING_SELECT_CAT"] = "Seleccionar Categoría";
	AL["ATLAS_STRING_SELECT_MAP"] = "Seleccionar Mapa";
	AL["ATLAS_STRING_SEARCH"] = "Buscar";
	AL["ATLAS_STRING_CLEAR"] = "Limpiar";
	AL["ATLAS_STRING_MINLEVEL"] = "Nivel mínimo";

	AL["ATLAS_OPTIONS_BUTTON"] = "Opciones";
	AL["ATLAS_OPTIONS_SHOWBUT"] = "Mostrar botón en el minimapa";
	AL["ATLAS_OPTIONS_SHOWBUT_TIP"] = "Muestra el botón de Atlas en el minimapa.";
	AL["ATLAS_OPTIONS_AUTOSEL"] = "Auto-Seleccionar mazmorra";
	AL["ATLAS_OPTIONS_AUTOSEL_TIP"] = "Auto seleccionar mapa de mazmorra. Atlas detectará tu posición y elegirá mostrarte el mapa mas idóneo.";
	AL["ATLAS_OPTIONS_BUTPOS"] = "Posición del icono";
	AL["ATLAS_OPTIONS_TRANS"] = "Transparencia";
	AL["ATLAS_OPTIONS_RCLICK"] = "Botón derecho para mapa del mundo";
	AL["ATLAS_OPTIONS_RCLICK_TIP"] = "Activa click derecho en la ventana del Atlas para cambiar al mapa del mundo.";
	AL["ATLAS_OPTIONS_RESETPOS"] = "Resetear posición";
	AL["ATLAS_OPTIONS_ACRONYMS"] = "Mostrar acrónimos";
	AL["ATLAS_OPTIONS_ACRONYMS_TIP"] = "Muestra el acrónimo de la mazmorra en los detalles del mapa.";
	AL["ATLAS_OPTIONS_SCALE"] = "Escala";
	AL["ATLAS_OPTIONS_BUTRAD"] = "Radio del botón";
	AL["ATLAS_OPTIONS_CLAMPED"] = "Ajustar ventana a la pantalla";
	AL["ATLAS_OPTIONS_CLAMPED_TIP"] = "Fija la ventana de Atlas. Desactiva el poder mover la ventana de Atlas fuera de la pantalla del juego.";
	AL["ATLAS_OPTIONS_CTRL"] = "Pulsar control para ver las herramientas";
	AL["ATLAS_OPTIONS_CTRL_TIP"] = "Activa mostrar ventanas emergentes de texto mientras pulsas Ctrl y pasas el ratón por encima de la información del mapa. Es util cuando el texto es demasiado largo y no se puede mostrar en la ventana.";

	AL["ATLAS_BUTTON_TOOLTIP_TITLE"] = "Atlas";
	AL["ATLAS_BUTTON_TOOLTIP_HINT"] = "Click izquierdo para abrir Atlas.\nClick central para opciones.\nClick derecho y arrastrar para mover el icono.";
	AL["ATLAS_LDB_HINT"] = "Click izquierdo para abrir Atlas.\nClick central para opciones.\nClick derecho para mostrar el menú.";

	AL["ATLAS_OPTIONS_CATDD"] = "Ordenar los mapas de mazmorra por:";
	AL["ATLAS_DDL_CONTINENT"] = "Continente";
	AL["ATLAS_DDL_CONTINENT_EASTERN"] = "Mazmorras de los Reinos del Este";
	AL["ATLAS_DDL_CONTINENT_KALIMDOR"] = "Mazmorras de Kalimdor";
	AL["ATLAS_DDL_CONTINENT_OUTLAND"] = "Mazmorras de Terrallende";
	AL["ATLAS_DDL_CONTINENT_NORTHREND"] = "Mazmorras de Rasganorte";
	AL["ATLAS_DDL_CONTINENT_DEEPHOLM"] = "Mazmorras de Infralar";
	AL["ATLAS_DDL_LEVEL"] = "Nivel";
	AL["ATLAS_DDL_LEVEL_UNDER45"] = "Mazmorras de nivel inferior a 45";
	AL["ATLAS_DDL_LEVEL_45TO60"] = "Mazmorras de nivel 45-60";
	AL["ATLAS_DDL_LEVEL_60TO70"] = "Mazmorras de nivel 60-70";
	AL["ATLAS_DDL_LEVEL_70TO80"] = "Mazmorras de nivel 70-80";
	AL["ATLAS_DDL_LEVEL_80TO85"] = "Mazmorras de nivel 80-85";
	AL["ATLAS_DDL_LEVEL_85PLUS"] = "Mazmorras de nivel 85+";
	AL["ATLAS_DDL_PARTYSIZE"] = "Tamaño del grupo";
	AL["ATLAS_DDL_PARTYSIZE_5_AE"] = "Mazmorras para 5 jugadores A-E";
	AL["ATLAS_DDL_PARTYSIZE_5_FS"] = "Mazmorras para 5 jugadores F-S";
	AL["ATLAS_DDL_PARTYSIZE_5_TZ"] = "Mazmorras para 5 jugadores T-Z";
	AL["ATLAS_DDL_PARTYSIZE_10_AN"] = "Mazmorras para 10 jugadores A-N";
	AL["ATLAS_DDL_PARTYSIZE_10_OZ"] = "Mazmorras para 10 jugadores O-Z";
	AL["ATLAS_DDL_PARTYSIZE_20TO40"] = "Mazmorras para 20-40 jugadores";
	AL["ATLAS_DDL_EXPANSION"] = "Expansión";
	AL["ATLAS_DDL_EXPANSION_OLD_AO"] = "Antiguas Mazmorras A-O";
	AL["ATLAS_DDL_EXPANSION_OLD_PZ"] = "Antiguas Mazmorras P-Z";
	AL["ATLAS_DDL_EXPANSION_BC"] = "Mazmorras de Burning Crusade";
	AL["ATLAS_DDL_EXPANSION_WOTLK"] = "Mazmorras Wrath of the Lich King";
	AL["ATLAS_DDL_EXPANSION_CATA"] = "Mazmorras de Cataclysm";
	AL["ATLAS_DDL_TYPE"] = "Tipo";
	AL["ATLAS_DDL_TYPE_INSTANCE_AC"] = "Mazmorras A-C";
	AL["ATLAS_DDL_TYPE_INSTANCE_DR"] = "Mazmorras D-R";
	AL["ATLAS_DDL_TYPE_INSTANCE_SZ"] = "Mazmorras S-Z";
	AL["ATLAS_DDL_TYPE_ENTRANCE"] = "Entradas";

	AL["ATLAS_INSTANCE_BUTTON"] = "Mazmorra";
	AL["ATLAS_ENTRANCE_BUTTON"] = "Entrada";
	AL["ATLAS_SEARCH_UNAVAIL"] = "Buscar no disponible";

	AL["ATLAS_DEP_MSG1"] = "Atlas ha detectado uno o varios modulos sin actualizar.";
	AL["ATLAS_DEP_MSG2"] = "Se han sido desactivados para este personaje.";
	AL["ATLAS_DEP_MSG3"] = "Borralos de tu directorio AddOns.";
	AL["ATLAS_DEP_OK"] = "Vale";

--************************************************
-- Zone Names, Acronyms, and Common Strings
--************************************************

	--Common strings
	AL["East"] = "Este";
	AL["North"] = "Norte";
	AL["South"] = "Sur";
	AL["West"] = "Oeste";

	--World Events, Festival
	AL["Brewfest"] = "Festival de la cerveza";
	AL["Hallow's End"] = "Halloween";
	AL["Love is in the Air"] = "Amor en el aire";
	AL["Lunar Festival"] = "Festival lunar";
	AL["Midsummer Festival"] = "Festival del solsticio de verano";
	--Misc strings
	AL["Adult"] = "Adulto";
	AL["AKA"] = "AKA";
	AL["Arcane Container"] = "Contenedor Arcano";	
	AL["Arms Warrior"] = "Guerrero Armas";
	AL["Attunement Required"] = "Armonización requerida";
	AL["Back"] = "Atras";
	AL["Basement"] = "Sótano";
	AL["Blacksmithing Plans"] = "Planos de herrero";
	AL["Boss"] = "Jefe";
	AL["Chase Begins"] = "Comienza persecución";
	AL["Chase Ends"] = "Final persecución";
	AL["Child"] = "Niño";
	AL["Connection"] = "Conexión";
	AL["DS2"] = "DS2";
	AL["Elevator"] = "Ascensor";
	AL["End"] = "Fin";
	AL["Engineer"] = "Ingeniero";	
	AL["Entrance"] = "Entrada";
	AL["Event"] = "Evento";
	AL["Exalted"] = "Exaltado";
	AL["Exit"] = "Salida";
	AL["Fourth Stop"] = "Cuarta parada";
	AL["Front"] = "Frente";
	AL["Ghost"] = "Fantasma";
	AL["Graveyard"] = "Cementerio";
	AL["Heroic"] = "Heróico";
	AL["Holy Paladin"] = "Paladín Sagrado";
	AL["Holy Priest"] = "Sacerdote Sagrado";
	AL["Hunter"] = "Cazador";
	AL["Imp"] = "Duendecillo";
	AL["Inside"] = "Dentro";
	AL["Key"] = "Llave";
	AL["Lower"] = "Abajo";
	AL["Mage"] = "Mago";
	AL["Meeting Stone"] = "Piedra de encuentro";
	AL["Middle"] = "Medio";
	AL["Monk"] = "Monje";	
	AL["Moonwell"] = "Claro de la luna";
	AL["Optional"] = "Opcional";
	AL["Orange"] = "Naranja";
	AL["Outside"] = "Fuera";
	AL["Paladin"] = "Paladín";
	AL["Portal"] = "Portal";
	AL["Priest"] = "Sacerdote";
	AL["Protection Warrior"] = "Guerrero Protección";
	AL["Purple"] = "Morado";
	AL["Random"] = "Aleatorio";
	AL["Rare"] = "Raro";
	AL["Reputation"] = "Reputación";
	AL["Repair"] = "Reparar";
	AL["Retribution Paladin"] = "Paladín Reprensión";
	AL["Rewards"] = "Recompensas";
	AL["Rogue"] = "Pícaro";
	AL["Second Stop"] = "Segunda parada";
	AL["Shadow Priest"] = "Sacerdote Sombras";
	AL["Shaman"] = "Chamán";
	AL["Side"] = "Lado";
	AL["Spawn Point"] = "Punto de aparición";
	AL["Start"] = "Comienzo";
	AL["Summon"] = "Invocar";
	AL["Teleporter"] = "Teletransportador";
	AL["Third Stop"] = "Tercera parada";
	AL["Tiger"] = "Tigre";
	AL["Top"] = "Arriba";
	AL["Underwater"] = "Bajo el agua";
	AL["Unknown"] = "Desconocido";
	AL["Upper"] = "Arriba";
	AL["Varies"] = "Varios";
	AL["Wanders"] = "Rondando";
	AL["Warlock"] = "Brujo";
	AL["Warrior"] = "Guerrero";
	AL["Wave 5"] = "Ola 5";
	AL["Wave 6"] = "Ola 6";
	AL["Wave 10"] = "Ola 10";
	AL["Wave 12"] = "Ola 12";
	AL["Wave 18"] = "Ola 18";

	--Classic Acronyms
	AL["AQ"] = "AQ"; -- Ahn'Qiraj
	AL["AQ20"] = "AQ20"; -- Ruins of Ahn'Qiraj
	AL["AQ40"] = "AQ40"; -- Temple of Ahn'Qiraj
	AL["Armory"] = "Armería"; -- Armory
	AL["BFD"] = "CB"; -- Blackfathom Deeps, Cavernas de Brazanegra
	AL["BRD"] = "PRN"; -- Blackrock Depths, Profundidades de Roca Negra
	AL["BRM"] = "MRN"; -- Blackrock Mountain, Montaña Roca Negra"
	AL["BWL"] = "GAN"; -- Blackwing Lair, Guarida Alanegra
	AL["Cath"] = "Cated"; --Catedral
	AL["DM"] = "LM"; -- Dire Maul, La Masacre	
	AL["Gnome"] = "Gnome"; -- Gnomeregan
	AL["GY"] = "Cemen"; -- Graveyard, Cementerio
	AL["LBRS"] = "CRNI"; -- Lower Blackrock Spire
	AL["Lib"] = "Lib"; -- Library
	AL["Mara"] = "Mara"; -- Maraudon
	AL["MC"] = "MC";-- Molten Core, Núcleo de Magma
	AL["RFC"] = "SI"; -- Ragefire Chasm, Sima Ignea
	AL["RFD"] = "ZR"; --Razorfen Downs, Zahúrda Rajacieno
	AL["RFK"] = "HR"; -- Razorfen Kraul, Horado Rajacieno
	AL["Scholo"] = "Scholo"; -- Scholomance
	AL["SFK"] = "CCO"; -- Shadowfang Keep, Castillo de Colmillo Oscuro"
	AL["SM"] = "ME"; -- Scarlet Monastery, Monasterio Escarlata
	AL["ST"] = "TA"; -- Sunken Temple, Templo de Atal'Hakkar
	AL["Strat"] = "Strat"; -- Stratholme
	AL["Stocks"] = "Mazmorras"; -- The Stockade, Las Mazmorras
	AL["UBRS"] = "CRNS"; -- Upper Blackrock Spire, Cumbre de Roca Negra
	AL["Ulda"] = "Ulda"; -- Uldaman
	AL["VC"] = "LMM"; --The Deadmines, Las Minas de la Muerte
	AL["WC"] = "CL"; -- Wailing Caverns, Las Cuevas de los Lamentos
	AL["ZF"] = "ZF"; -- Zul'Farrak

	--BC Acronyms
	AL["AC"] = "CA"; --Criptas Auchenai 
	AL["Arca"] = "Arca";
	AL["Auch"] = "Auch";
	AL["BF"] = "HS"; --orno de Sangre
	AL["BT"] = "TO"; --Templo Oscuro	
	AL["Bota"] = "Inver"; --El Invernáculo
	AL["CoT"] = "CdT"; --Cavernas del Tiempo
	AL["CoT1"] = "CdT1"; --Laderas de Trabalomas
	AL["CoT2"] = "CdT2"; --La Ciénaga Negra
	AL["CoT3"] = "CdT3"; --El Monte Hyjal
	AL["CR"] = "RCT"; --Reserva Colmillo Torcido
	AL["GL"] = "Gruul"; --Guarida de Gruul
	AL["HC"] = "CFI"; --Ciudadela del Fuego Infernal
	AL["Kara"] = "Kara";
	AL["MaT"] = "BM"; --Bancal del Magister
	AL["Mag"] = "Mag"; --Guarida de Magtheridon
	AL["Mech"] = "Mech"; --El Mechanar
	AL["MT"] = "TM"; --Tumbas de Maná
	AL["Ramp"] = "Murallas"; --Murallas del Fuego Infernal
	AL["SC"] = "CSS"; --Caverna Santuario Serpiente
	AL["Seth"] = "Seth"; --Salas Sethekk
	AL["SH"] = "SA"; --Las Salas Arrasadas
	AL["SL"] = "LS"; --Laberinto de las sombras
	AL["SP"] = "Recinto"; --Recinto de los Esclavos
	AL["SuP"] = "MPS"; --Meseta del pozo del Sol
	AL["SV"] = "CV"; --Cámara de Vapor
	AL["TK"] = "CT"; --El Castillo de la Tempestad
	AL["UB"] = "Soti"; --La Sotiénaga
	AL["ZA"] = "ZA"; -- Zul'Aman

	--WotLK Acronyms
	AL["AK, Kahet"] = "Kahet"; -- Ahn'kahet
	AL["AN, Nerub"] = "AN, Nerub"; -- Azjol-Nerub
	AL["Champ"] = "Camp"; -- Trial of the Champion
	AL["CoT-Strat"] = "Strat, CdT-Strat"; -- Culling of Stratholme
	AL["Crus"] = "Cruz"; -- Trial of the Crusader
	AL["DTK"] = "DTK"; -- Drak'Tharon Keep
	AL["FoS"] = "FdA"; 
	AL["FH1"] = "FH1"; -- The Forge of Souls
	AL["Gun"] = "Gun"; -- Gundrak
	AL["HoL"] = "CdR"; -- Halls of Lightning
	AL["HoR"] = "CdR"; 
	AL["FH3"] = "CR3"; -- Halls of Reflection
	AL["HoS"] = "CdP"; -- Halls of Stone
	AL["IC"] = "CCH"; -- Icecrown Citadel
	AL["Nax"] = "Nax"; -- Naxxramas
	AL["Nex, Nexus"] = "Nexo"; -- The Nexus
	AL["Ocu"] = "Oculus"; -- The Oculus
	AL["Ony"] = "Ony"; -- Onyxia's Lair
	AL["OS"] = "SO"; -- The Obsidian Sanctum
	AL["PoS"] = "FdS"; 
	AL["FH2"] = "CR2"; -- Pit of Saron
	AL["RS"] = "SR"; -- The Ruby Sanctum
	AL["TEoE"] = "OE"; -- The Eye of Eternity
	AL["UK, Keep"] = "GU, Guarida"; -- Utgarde Keep
	AL["Uldu"] = "Uldu"; -- Ulduar
	AL["UP, Pinn"] = "PU, Pinaculo"; -- Utgarde Pinnacl
	AL["VH"] = "BV"; -- The Violet Hold
	AL["VoA"] = "CdA"; -- Vault of Archavon

	--Zones not included in LibBabble-Zone
	AL["Crusaders' Coliseum"] = "Coliseo de los Cruzados";

	--Cataclysm Acronyms
	--AL["AM"] = "AM"; --Abyssal Maw
	AL["BH"] = "BH"; --Baradin Hold
	AL["BoT"] = "BoT"; --Bastion of Twilight
	AL["BRC"] = "BRC"; --Blackrock Caverns
	AL["BWD"] = "BWD"; --Blackwing Descent
	--AL["CoT-WA"] = "CoT-WA"; --War of the Ancients
	AL["GB"] = "GB"; --Grim Batol
	AL["HoO"] = "HoO"; --Halls of Origination
	AL["LCoT"] = "LCoT"; --Lost City of the Tol'vir 
	--AL["SK"] = "SK"; --Sulfuron Keep
	AL["TSC"] = "TSC"; --The Stonecore
	AL["TWT"] = "TWT"; --Throne of the Four Winds
	AL["ToTT"] = "ToTT"; --Throne of the Tides
	AL["VP"] = "VP"; --The Vortex Pinnacle

--************************************************
-- Instance Entrance Maps
--************************************************

	--Auchindoun (Entrance)
	AL["Ha'Lei"] = "Ha'Lei";
	AL["Greatfather Aldrimus"] = "Abuelo Aldrimus";
	AL["Clarissa"] = "Clarissa";
	AL["Ramdor the Mad"] = "Ramdor el Loco";
	AL["Horvon the Armorer <Armorsmith>"] = "Horvon el Armero <Forjador de armaduras>";
	AL["Nexus-Prince Haramad"] = "Príncipe-nexo Haramad";
	AL["Artificer Morphalius"] = "Artificiero Morphalius";
	AL["Mamdy the \"Ologist\""] = "Mamdy el  \"Todólogo\"";
	AL["\"Slim\" <Shady Dealer>"] = "\"Flaco\" <Vendedor sospechoso>";
	AL["\"Captain\" Kaftiz"] = "\"Capitán\" Kaftiz";
	AL["Isfar"] = "Isfar";
	AL["Field Commander Mahfuun"] = "Comandante de campo Mahfuun";
	AL["Spy Grik'tha"] = "Espía Grik'tha";
	AL["Provisioner Tsaalt"] = "Proveedor Tsaalt";
	AL["Dealer Tariq <Shady Dealer>"] = "Tratante Tariq <Vendedor sospechoso>";

	--Blackfathom Deeps (Entrance)

	--Blackrock Mountain (Entrance)
	AL["Bodley"] = "Bodley";
	AL["Lothos Riftwaker"] = "Lothos Levantagrietas";
	AL["Orb of Command"] = "Orbe de orden";
	AL["Scarshield Quartermaster <Scarshield Legion>"] = "Intendente del Escudo del Estigma <Legión Escudo del Estigma>";
	AL["The Behemoth"] = "El Behemoth";

	--Caverns of Time (Entrance)
	AL["Steward of Time <Keepers of Time>"] = "Administrador del Tiempo <Vigilantes del Tiempo>";
	AL["Alexston Chrome <Tavern of Time>"] = "Alexston Cromo <La Taberna del Tiempo>";
	AL["Yarley <Armorer>"] = "Yarley <Armero>";
	AL["Bortega <Reagents & Poison Supplies>"] = "Bortega <Suministros de venenos y componentes>";
	AL["Alurmi <Keepers of Time Quartermaster>"] = "Alurmi <Intendente de los Vigilantes del Tiempo>";
	AL["Galgrom <Provisioner>"] = "Galgrom <Galgrom>";
	AL["Zaladormu"] = "Zaladormu";
	AL["Soridormi <The Scale of Sands>"] = "Soridormi <La Escama de las Arenas>";
	AL["Arazmodu <The Scale of Sands>"] = "Arazmodu <La Escama de las Arenas>";
	AL["Andormu <Keepers of Time>"] = "Andormu <Vigilantes del Tiempo";
	AL["Nozari <Keepers of Time>"] = "Nozari <Vigilantes del Tiempo>";
	AL["Anachronos <Keepers of Time>"] = "Anacronos <Vigilantes del Tiempo>";

	--Caverns of Time: Hyjal (Entrance)
	AL["Indormi <Keeper of Ancient Gem Lore>"] = "Indormi <Vigilante de conocimiento de gemas antiguas>";
	AL["Tydormu <Keeper of Lost Artifacts>"] = "Tydormu <Vigilante de artefactos perdidos>";

	--Coilfang Reservoir (Entrance)
	AL["Watcher Jhang"] = "Vigía Jhang";
	AL["Mortog Steamhead"] = "Mortog Testavapor";

	--Dire Maul (Entrance)
	AL["Dire Pool"] = "Estanque Funesto";
	AL["Dire Maul Arena"] = "Arena de La Masacre";
	AL["Elder Mistwalker"] = "Ancestro Caminalba";

	--Gnomeregan (Entrance)
	AL["Torben Zapblast <Teleportation Specialist>"] = "Torben Pumzas <Especialista en teletransporte>";

	--Hellfire Citadel (Entrance)
	AL["Steps and path to the Blood Furnace"] = "Escaleras y camino hacia Hornos de Sangre";
	AL["Path to the Hellfire Ramparts and Shattered Halls"] = "Camino a Murallas y Salas Arrasadas";
	AL["Meeting Stone of Magtheridon's Lair"] = "Piedra de encuentro de la Guarida de Magtheridon";
	AL["Meeting Stone of Hellfire Citadel"] = "Piedra de encuentro de la Ciudadela de Fuego Infernal";

	--Icecrown Citadel (Entrance)

	--Karazhan (Entrance)
	AL["Archmage Leryda"] = "Archimaga Leryda";
	AL["Archmage Alturus"] = "Archimago Alturus";
	AL["Apprentice Darius"] = "Aprendiz Darius";
	AL["Stairs to Underground Pond"] = "Escaleras a Underground Pond";
	AL["Stairs to Underground Well"] = "Escaleras a Underground Well";
	AL["Charred Bone Fragment"] = "Trozo de hueso carbonizado";

	--Maraudon (Entrance)
	AL["The Nameless Prophet"] = "El profeta sin nombre";

	--Scarlet Monastery (Entrance)

	--The Deadmines (Entrance)

	--Sunken Temple (Entrance)
	AL["Priestess Udum'bra"] = "Sacerdotisa Udum'bra";
	AL["Gomora the Bloodletter"] = "Gomora el Flebotomista";

	--Uldaman (Entrance)

	--Ulduar (Entrance)
	AL["Shavalius the Fancy <Flight Master>"] = "Shavalius el Extravagante <Maestro de vuelo>";
	AL["Chester Copperpot <General & Trade Supplies>"] = "Chester Tarrodecobre <Suministros generales y objetos comerciales>";
	AL["Slosh <Food & Drink>"] = "Slosh <Alimentos y bebidas>";

	--Wailing Caverns (Entrance)

--************************************************
-- Kalimdor Instances (Classic)
--************************************************

	--Blackfathom Deeps
	AL["Shrine of Gelihast"] = "Santuario de Gelihast";
	AL["Fathom Stone"] = "Núcleo de las profundidades";
	AL["Lorgalis Manuscript"] = "Manuscrito de Lorgalis";
	AL["Scout Thaelrid"] = "Guardia Argenta Thaelrid <El Alba Argenta>";
	AL["Flaming Eradicator"] = "Erradicador flameante";
	AL["Altar of the Deeps"] = "Altar de las profundidades";
	AL["Ashelan Northwood"] = "Ashelan Bosquenorte";
	AL["Relwyn Shadestar"] = "Relwyn Sombrestrella";
	AL["Sentinel Aluwyn"] = "Centinela Aluwyn";
	AL["Sentinel-trainee Issara"] = "Centinela practicante Issara";
	AL["Je'neu Sancrea <The Earthen Ring>"] = "Je'neu Sancrea <El Anillo de la Tierra>";
	AL["Zeya"] = "Zeya";

	--Dire Maul (East)
	AL["\"Ambassador\" Dagg'thol"] = "\"Embajador\" Dagg'thol";
	AL["Furgus Warpwood"] = "Furgus Alabeo";
	AL["Old Ironbark"] = "Viejo Cortezaférrea";
	AL["Ironbark the Redeemed"] = "Cortezaférrea el Redimido";

	--Dire Maul (North)
	AL["Druid of the Talon"] = "Druida de la Garfa";
	AL["Stonemaul Ogre"] = "Ogro Quebrantarrocas";
	AL["Knot Thimblejack"] = "Knot Llavededo";

	--Dire Maul (West)
	AL["J'eevee's Jar"] = "Jarra de J'eevee";
	AL["Ferra"] = "Ferra";
	AL["Estulan <The Highborne>"] = "Estulan <Los Altonato>";
	AL["Shen'dralar Watcher"] = "Vigía Shen'dralar";
	AL["Pylons"] = "Pilones";
	AL["Ancient Equine Spirit"] = "Antiguo espíritu equino";
	AL["Shen'dralar Ancient"] = "Ancestro Shen'dralar";
	AL["Falrin Treeshaper"] = "Falrin Tallarbol";
	AL["Lorekeeper Lydros"] = "Tradicionalista Lydros";
	AL["Lorekeeper Javon"] = "Tradicionalista Javon";
	AL["Lorekeeper Kildrath"] = "Tradicionalista Kildrath";
	AL["Lorekeeper Mykos"] = "Tradicionalista Mykos";
	AL["Shen'dralar Provisioner"] = "Proveedor Shen'dralar";

	--Maraudon	
	AL["Elder Splitrock"] = "Ancestro Parterroca";

	--Ragefire Chasm
	AL["Bovaal Whitehorn"] = "Bovaal Cuernoblanco";
	AL["Stone Guard Kurjack"] = "Guardia de piedra Kurjack";

	--Razorfen Downs
	AL["Koristrasza"] = "Koristrasza";
	AL["Belnistrasz"] = "Belnistrasz";

	--Razorfen Kraul
	AL["Auld Stonespire"] = "Auld Picopiedra";
	AL["Razorfen Spearhide"] = "Cuerolanza de Rajacieno";
	AL["Spirit of Agamaggan <Ancient>"] = "Espíritu de Agamaggan <Anciano>";
	AL["Willix the Importer"] = "Willix el Importador";

	--Ruins of Ahn'Qiraj
	AL["Four Kaldorei Elites"] = "Cuatro Elites Kaldorei";
	AL["Captain Qeez"] = "Capitán Condurso";
	AL["Captain Tuubid"] = "Capitán Tuubid";
	AL["Captain Drenn"] = "Capitán Drenn";
	AL["Captain Xurrem"] = "Capitán Xurrem";
	AL["Major Yeggeth"] = "Mayor Yeggeth";
	AL["Major Pakkon"] = "Mayor Pakkon";
	AL["Colonel Zerran"] = "Coronel Zerran";
	AL["Safe Room"] = "Habitación segura";

	--Temple of Ahn'Qiraj
	AL["Andorgos <Brood of Malygos>"] = "Andorgos <Camada de Malygos>";
	AL["Vethsera <Brood of Ysera>"] = "Vethsera <Camada de Ysera>";
	AL["Kandrostrasz <Brood of Alexstrasza>"] = "Kandrostrasz <Camada de Alexstrasza>";
	AL["Arygos"] = "Arygos";
	AL["Caelestrasz"] = "Caelestrasz";
	AL["Merithra of the Dream"] = "Merithra del Sueño";

	--Wailing Caverns
	AL["Disciple of Naralex"] = "Discípulo de Naralex";

	--Zul'Farrak
	AL["Chief Engineer Bilgewhizzle <Gadgetzan Water Co.>"] = "Ingeniero jefe Pasaquillas <Compañía de aguas de Gadgetzan>";
	AL["Mazoga's Spirit"] = "Espíritu de Mazoga";
	AL["Tran'rek"] = "Tran'rek";
	AL["Weegli Blastfuse"] = "Weegli Plomofundido";
	AL["Raven"] = "Cuervo";
	AL["Elder Wildmane"] = "Ancestro Barvacrín";

--****************************
-- Eastern Kingdoms Instances
--****************************

	--Blackrock Depths
	AL["Relic Coffer Key"] = "Llave del arca de reliquias";
	AL["Dark Keeper Key"] = "Llave de guarda oscuro";
	AL["The Black Anvil"] = "El Yunquenegro";
	AL["The Vault"] = "Cámara Negra";
	AL["Watchman Doomgrip"] = "Vigía Presaletal";
	AL["High Justice Grimstone"] = "Alto Justiciero Pedrasiniestra";
	AL["Elder Morndeep"] = "Ancestro Alborhondo";
	AL["Schematic: Field Repair Bot 74A"] = "Esquema: robot de reparación de campo 74A";
	AL["Private Rocknot"] = "Soldado Sinroca";
	AL["Mistress Nagmara"] = "Coima Nagmara";
	AL["Summoner's Tomb"] = "Tumba de los invocadores"; --Check
	AL["Jalinda Sprig <Morgan's Militia>"] = "Jalinda Espiga <Milicia de Morgan>";
	AL["Oralius <Morgan's Militia>"] = "Oralius <Milicia de Morgan>";
	AL["Thal'trak Proudtusk <Kargath Expeditionary Force>"] = "Thal'trak Colmillo Orgulloso <Fuerza Expedicionaria de Kargath>";
	AL["Galamav the Marksman <Kargath Expeditionary Force>"] = "Galamav el Tirador <Fuerza Expedicionaria de Kargath>";
	AL["Maxwort Uberglint"] = "Maxwort Suprandor";
	AL["Tinkee Steamboil"] = "Tinkee Vaporio";
	AL["Yuka Screwspigot <Engineering Supplies>"] = "Yuka Llavenrosca <Suministros de ingeniería>";
	AL["Abandonded Mole Machine"] = "Máquina topo abandonada";
	AL["Kevin Dawson <Morgan's Militia>"] = "Kevin Dawson <Milicia de Morgan>";
	AL["Lexlort <Kargath Expeditionary Force>"] = "Lexlort <Fuerza Expedicionaria de Kargath>";
	AL["Prospector Seymour <Morgan's Militia>"] = "Prospector Seymour <Milicia de Morgan>";
	AL["Razal'blade <Kargath Expeditionary Force>"] = "Razal'filo <Fuerza Expedicionaria de Kargath>";
	AL["The Shadowforge Lock"] = "El candado de Forjatiniebla";
	AL["Mayara Brightwing <Morgan's Militia>"] = "Mayara Alasol <Milicia de Morgan>";
	AL["Hierophant Theodora Mulvadania <Kargath Expeditionary Force>"] = "Hierofante Theodora Mulvadania <Fuerza Expedicionaria de Kargath>";
	AL["Lokhtos Darkbargainer <The Thorium Brotherhood>"] = "Lokhtos Tratoscuro <La Hermandad del Torio>";
	AL["Mountaineer Orfus <Morgan's Militia>"] = "Montaraz Orfus <Milicia de Morgan>";
	AL["Thunderheart <Kargath Expeditionary Force>"] = "Corazón Atronador <Fuerza Expedicionaria de Kargath>";
	AL["Marshal Maxwell <Morgan's Militia>"] = "Mariscal Maxwell <Milicia de Morgan>";
	AL["Warlord Goretooth <Kargath Expeditionary Force>"] = "Señor de la guerra Dientegore <Fuerza Expedicionaria de Kargath>";
	AL["The Black Forge"] = "La Forjanegra";
	AL["Core Fragment"] = "Trozo del Núcleo";
	AL["Shadowforge Brazier"] = "Brasero Forjatiniebla"; --Check

	--Blackrock Spire (Lower)
	AL["Urok's Tribute Pile"] = "Pila de tributo a Urok";
	AL["Acride <Scarshield Legion>"] = "Infiltrado del Escudo del Estigma <Legión Escudo del Estigma>"; --Check
	AL["Elder Stonefort"] = "Ancestro Petraforte";
	AL["Roughshod Pike"] = "Pica férrea";

	--Blackrock Spire (Upper)
	AL["Finkle Einhorn"] = "Finkle Unicornín";
	AL["Drakkisath's Brand"] = "El orbe de orden";
	AL["Father Flame"] = "Padre llama";

	--Blackwing Lair
	AL["Orb of Domination"] = "Orbe de Dominacion"; --Check
	AL["Master Elemental Shaper Krixix"] = "Maestro de los elementos Formacio Krixix";

	--Gnomeregan
	AL["Chomper"] = "Mastic";
	AL["Blastmaster Emi Shortfuse"] = "Maestro Destructor Emi Plomocorto";
	AL["Murd Doc <S.A.F.E.>"] = "Murd Doc <S.E.G.U.R.O.>";
	AL["Tink Sprocketwhistle <Engineering Supplies>"] = "Tink Silbadentado <Suministros de ingeniería>";
	AL["The Sparklematic 5200"] = "El Destellamatic 5200";
	AL["Mail Box"] = "Buzón";
	AL["B.E Barechus <S.A.F.E.>"] = "B.E Barechus <S.E.G.U.R.O.>";
	AL["Face <S.A.F.E.>"] = "Cara <S.E.G.U.R.O.>";
	AL["Hann Ibal <S.A.F.E.>"] = "Hann Ibal <S.E.G.U.R.O.>";

	--Molten Core

	--Scholomance
	AL["Blood of Innocents"] = "Sangre de los Inocentes";	
	AL["Divination Scryer"] = "Cristal de adivinación";
	AL["Alexi Barov <House of Barov>"] = "Alexi Barov <Casa Barov>";
	AL["Weldon Barov <House of Barov>"] = "Weldon Barov <Casa Barov>";
	AL["Eva Sarkhoff"] = "Eva Sarkhoff";
	AL["Lucien Sarkhoff"] = "Lucien Sarkhoff";
	AL["The Deed to Caer Darrow"] = "Las escrituras de Castel Darrow";
	AL["The Deed to Southshore"] = "Las escrituras de Costasur";
	AL["Torch Lever"] = "Antocha palanca";
	AL["The Deed to Tarren Mill"] = "Las escrituras de Molino Tarren";
	AL["The Deed to Brill"] = "Las escrituras de Rémol";

	--Shadowfang Keep
	AL["Apothecary Trio"] = "Trío de boticarios ";
	AL["Apothecary Hummel <Crown Chemical Co.>"] = "Boticario Hummel <Químicos La Corona, S.L.> ";
	AL["Apothecary Baxter <Crown Chemical Co.>"] = "Boticario Baxter <Químicos La Corona, S.L.>";
	AL["Apothecary Frye <Crown Chemical Co.>"] = "Boticario Frye <Químicos La Corona, S.L.>";
	AL["Packleader Ivar Bloodfang"] = "Maestro de manada Ivar Colmillo de Sangre";
	AL["Deathstalker Commander Belmont"] = "Comandante Mortacechador Belmont";
	AL["Haunted Stable Hand"] = "Mozo de cuadra encantado";
	AL["Investigator Fezzen Brasstacks"] = "Investigator Fezzen Brasstacks"; --FALTA		

	--SM: Armory
	AL["Joseph the Crazed"] = "Joseph el Enloquecido";
	AL["Dark Ranger Velonara"] = "Forestal oscura Velonara";
	AL["Dominic"] = "Dominic";

	--SM: Cathedral
	AL["Cathedral"] = "Catedral"; -- Subzone of Scarlet Monastery
	AL["Joseph the Insane <Scarlet Champion>"] = "Joseph el Loco <Campeón Escarlata>";

	--SM: Graveyard
	AL["Vorrel Sengutz"] = "Vorrel Sengutz";
	AL["Pumpkin Shrine"] = "Calabaza Santuario";
	AL["Joseph the Awakened"] = "Joseph el Despierto";

	--SM: Library
	AL["Library"] = "Librería";
	AL["Compendium of the Fallen"] = "Compendio de los Caídos";

	--Stratholme - Crusader's Square
	AL["Various Postbox Keys"] = "Varias llaves de los buzones";
	AL["Crusade Commander Eligor Dawnbringer <Brotherhood of the Light>"] = "Comandante de Cruzada Eligor Albar <Hermandad de la Luz>";
	AL["Master Craftsman Wilhelm <Brotherhood of the Light>"] = "Maestro artesano Wilhelm <Hermandad de la Luz>";
	AL["Packmaster Stonebruiser <Brotherhood of the Light>"] = "Maestro de manada Mazadura <Hermandad de la Luz>";
	AL["Stratholme Courier"] = "Mensajero de Stratholme";
	AL["Fras Siabi's Postbox"] = "Buzón de Fras Siabi";
	AL["King's Square Postbox"] = "Buzón de la Plaza del Rey";
	AL["Festival Lane Postbox"] = "Buzón de la calle del Festival";
	AL["Elder Farwhisper"] = "Ancestro Levesusurro";
	AL["Market Row Postbox"] = "Buzón de la Fila del Mercado";
	AL["Crusaders' Square Postbox"] = "Buzón de la Plaza del Cruzado";

	--Stratholme - The Gauntlet
	AL["Elders' Square Postbox"] = "Buzón de la plaza de los Ancianos";
	AL["Archmage Angela Dosantos <Brotherhood of the Light>"] = "Archimaga Angela Dosantos <Hermandad de la Luz>";
	AL["Crusade Commander Korfax <Brotherhood of the Light>"] = "Comandante de Cruzada Korfax <Hermandad de la Luz>";

	--The Deadmines
	AL["Lumbering Oaf"] = "Patán inútil";
	AL["Lieutenant Horatio Laine"] = "Teniente Horatio Laine";
	AL["Kagtha"] = "Kagtha";
	AL["Slinky Sharpshiv"] = "Finta Navajazos";
	AL["Quartermaster Lewis <Quartermaster>"] = "Intendente Lewis <Intendente>";
	AL["Miss Mayhem"] = "Miss Caos";
	AL["Vend-O-Tron D-Luxe"] = "Vendo-trón Deluxe";

	--The Stockade
	AL["Rifle Commander Coe"] = "Comandante de rifles Coe";
	AL["Warden Thelwater"] = "Celador Thelagua";
	AL["Nurse Lillian"] = "Enfermera Lillian";

	--The Sunken Temple
	AL["Lord Itharius"] = "Lord Itharius";
	AL["Elder Starsong"] = "Ancestro Canción Estrella"; --Check

	--Uldaman
	AL["Staff of Prehistoria"] = "Basón de Prehistoria";
	AL["Baelog's Chest"] = "El Cofre de Baelog";
	AL["Kand Sandseeker <Explorer's League>"] = "Kand Buscadunas <Liga de Expedicionarios>";
	AL["Lead Prospector Durdin <Explorer's League>"] = "Prospector jefe Durdin <Liga de Expedicionarios>";
	AL["Olga Runesworn <Explorer's League>"] = "Olga Jurarruna <Liga de Expedicionarios>";
	AL["Aoren Sunglow <The Reliquary>"] = "Aoren Brillo del Sol <El Relicario>";
	AL["High Examiner Tae'thelan Bloodwatcher <The Reliquary>"] = "Alto examinador Tae'thelan Mirasangre <El Relicario>";
	AL["Lidia Sunglow <The Reliquary>"] = "Lidia Brillo del Sol <El Relicario>";
	AL["Ancient Treasure"] = "Tesoro Antiguo";
	AL["The Discs of Norgannon"] = "Los Discos de Norgannon";

--*******************
-- Burning Crusade Instances
--*******************

	--Auch: Auchenai Crypts
	AL["Auchenai Key"] = "Llave Auchenai";
	AL["Avatar of the Martyred"] = "Avatar de los Martirizados";
	AL["D'ore"] = "D'ore";

	--Auch: Mana-Tombs
	AL["The Eye of Haramad"] = "El ojo de Haramad";
	AL["Shadow Lord Xiraxis"] = "Señor de las Sombras Xiraxis";
	AL["Ambassador Pax'ivi"] = "Embajador Pax'ivi";
	AL["Cryo-Engineer Sha'heen"] = "Crioingeniero Sha'heen";
	AL["Ethereal Transporter Control Panel"] = "Panel de control del transportador etéreo";

	--Auch: Sethekk Halls
	AL["Lakka"] = "Lakka";
	AL["The Saga of Terokk"] = "Esbirro de Terokk";

	--Auch: Shadow Labyrinth
	AL["The Codex of Blood"] = "El Códice de Sangre";
	AL["First Fragment Guardian"] = "Guardián del Primer Fragmento";
	AL["Spy To'gun"] = "Espía To'gun";

	--Black Temple (Start)
	AL["Towards Reliquary of Souls"] = "Hacia Relicario de Almas";
	AL["Towards Teron Gorefiend"] = "Hacia Teron Sanguino";
	AL["Towards Illidan Stormrage"] = "Hacia Illidan Tempestira";
	AL["Spirit of Olum"] = "Espíritu de Olum";
	AL["Spirit of Udalo"] = "Espíritu de Udalo";
	AL["Aluyen <Reagents>"] = "Aluyen <Vendedor de Componentes>";
	AL["Okuno <Ashtongue Deathsworn Quartermaster>"] = "Okuno <Provisiones Juramorte Lengua de ceniza>";
	AL["Seer Kanai"] = "Profeta Kanai";

	--Black Temple (Basement)

	--Black Temple (Top)

	--CR: Serpentshrine Cavern
	AL["Seer Olum"] = "Profeta Olum";

	--CR: The Slave Pens
	AL["Reservoir Key"] = "Llave de dóposito";--omitted from other CR
	AL["Weeder Greenthumb"] = "Desherbador Pulgaverde";
	AL["Skar'this the Heretic"] = "Skar'this el Herético";
	AL["Naturalist Bite"] = "Naturalista Mordisco";

	--CR: The Steamvault
	AL["Main Chambers Access Panel"] = "Panel de acceso de la cámara principal";
	AL["Second Fragment Guardian"] = "Guardián del Segundo Fragmento";

	--CR: The Underbog
	AL["The Underspore"] = "La Sotoespora";
	AL["Earthbinder Rayge"] = "Lingaterra Rayge";

	--CoT: The Black Morass
	AL["Opening of the Dark Portal"] = "Apertura del Portal Oscuro";
	AL["Key of Time"] = "Llave del tiempo";
	AL["Sa'at <Keepers of Time>"] = "Sa'at <Vigilantes del Tiempo>";
	AL["The Dark Portal"] = "El Portal Oscuro";

	--CoT: Hyjal Summit
	AL["Battle for Mount Hyjal"] = "Batalla por el Monte Hyjal";
	AL["Alliance Base"] = "Base de la Alianza";
	AL["Lady Jaina Proudmoore"] = "Lady Jaina Valiente";
	AL["Horde Encampment"] = "Campamento de la Horda";
	AL["Thrall <Warchief>"] = "Thrall <Jefe de Guerra>";
	AL["Night Elf Village"] = "Pueblo de los Elfos de la Noche";
	AL["Tyrande Whisperwind <High Priestess of Elune>"] = "Tyrande Susurravientos <Suma sacerdotisa de Elune>";

	--CoT: Old Hillsbrad Foothills
	AL["Escape from Durnholde Keep"] = "Escape del Castillo de Durnholde";
	AL["Erozion"] = "Erozion";
	AL["Brazen"] = "Brazen";
	AL["Landing Spot"] = "Punto de Aterrizaje";
	AL["Thrall"] = "Thrall";
	AL["Taretha"] = "Taretha";
	AL["Don Carlos"] = "Don Carlos";
	AL["Guerrero"] = "Guerrero";
	AL["Thomas Yance <Travelling Salesman>"] = "Thomas Yance <Vendedor ambulante>";
	AL["Aged Dalaran Wizard"] = "Zhaorí Dalaran envejecido";
	AL["Jonathan Revah"] = "Jonathan Revah";
	AL["Jerry Carter"] = "Jerry Carter";
	AL["Helcular"] = "Helcular";
	AL["Farmer Kent"] = "Granjero Kent";
	AL["Sally Whitemane"] = "Sally Melenablanca";
	AL["Renault Mograine"] = "Renault Mograine";
	AL["Little Jimmy Vishas"] = "Pequeño Jimmy Vishas";
	AL["Herod the Bully"] = "Herod el Matón";
	AL["Nat Pagle"] = "Nat Pagle";
	AL["Hal McAllister"] = "Hal McAllister";
	AL["Zixil <Aspiring Merchant>"] = "Zixil <Aspirante a mercader>";
	AL["Overwatch Mark 0 <Protector>"] = "Robovigilante Mark 0 <Protector>";
	AL["Southshore Inn"] = "Posada de Costasur";
	AL["Captain Edward Hanes"] = "Capitán Edward Hanes";
	AL["Captain Sanders"] = "Capitán Sanders";
	AL["Commander Mograine"] = "Comandante Mograine";
	AL["Isillien"] = "Isillien";
	AL["Abbendis"] = "Abbendis";
	AL["Fairbanks"] = "Ribalimpia";
	AL["Taelan"] = "Taelan";
	AL["Barkeep Kelly <Bartender>"] = "Posadero Kelly <Camarero>";
	AL["Frances Lin <Barmaid>"] = "Frances Lin <Camarera>";
	AL["Chef Jessen <Speciality Meat & Slop>"] = "Jefe Jessen <Especialidad en carne y bazofia>";
	AL["Stalvan Mistmantle"] = "Stalvan Mantoniebla";
	AL["Phin Odelic <The Kirin Tor>"] = "Phin Odelic <Los Kirin Tor>";
	AL["Magistrate Henry Maleb"] = "Magistrado Henry Maleb";
	AL["Raleigh the True"] = "Raleigh el Auténtico";
	AL["Nathanos Marris"] = "Nathanos Marris";
	AL["Bilger the Straight-laced"] = "Maestro cervecero Bilger";
	AL["Innkeeper Monica"] = "Tabernera Monica";
	AL["Julie Honeywell"] = "Julie Pozo de Miel";
	AL["Jay Lemieux"] = "Jay Lemieux";
	AL["Young Blanchy"] = "Joven Blanchy";

	--Gruul's Lair

	--HFC: The Blood Furnace
	AL["Flamewrought Key"] = "Llave de Forjallamas";

	--HFC: Hellfire Ramparts
	AL["Reinforced Fel Iron Chest"] = "Cofre de hierro vil reforzado";

	--HFC: Magtheridon's Lair

	--HFC: The Shattered Halls
	AL["Shattered Hand Executioner"] = "Ejecutor Mano Destrozada";
	AL["Private Jacint"] = "Soldado Jacint";
	AL["Rifleman Brownbeard"] = "Rifleman Brownbeard";
	AL["Captain Alina"] = "Capitán Alina";
	AL["Scout Orgarr"] = "Explorador Orgarr";
	AL["Korag Proudmane"] = "Korag Proudmane";
	AL["Captain Boneshatter"] = "Capitán Huesodestrozado";
	AL["Randy Whizzlesprocket"] = "Randy Whizzlesprocket";
	AL["Drisella"] = "Drisella";

	--Karazhan Start
	AL["The Master's Key"] = "La llave del maestro";
	AL["Baroness Dorothea Millstipe"] = "Baronesa Dorothea Tallolino";
	AL["Lady Catriona Von'Indi"] = "Lady Catriona Von'Indi";
	AL["Lady Keira Berrybuck"] = "Lady Keira Bayadol";
	AL["Baron Rafe Dreuger"] = "Barón Rafe Dreuger";
	AL["Lord Robin Daris"] = "Lord Robin Daris";
	AL["Lord Crispin Ference"] = "Lord Crispin Ference";
	AL["Red Riding Hood"] = "Caperucita Roja";
	AL["Wizard of Oz"] = "El mago de Oz";
	AL["The Master's Terrace"] = "El Bancal del Maestro";
	AL["Servant Quarters"] = "Aposentos de los sirvientes";
	AL["Hastings <The Caretaker>"] = "Hastings <El Custodio>";
	AL["Berthold <The Doorman>"] = "Berthold <El Portero>";
	AL["Calliard <The Nightman>"] = "Calliard <El Hombre de la noche>";
	AL["Koren <The Blacksmith>"] = "Koren <El Herrero>";
	AL["Bennett <The Sergeant at Arms>"] = "Bennett <El Sargento de Armas>";
	AL["Keanna's Log"] = "Apuntes de Keanna";
	AL["Ebonlocke <The Noble>"] = "Cerranegro <El Noble>";
	AL["Sebastian <The Organist>"] = "Sebastian <El Organista>";
	AL["Barnes <The Stage Manager>"] = "Barnes <El Director de escena>";

	--Karazhan End
	AL["Path to the Broken Stairs"] = "Camino a las Escaleras Rotas";
	AL["Broken Stairs"] = "Escaleras rotas";
	AL["Ramp to Guardian's Library"] = "Rampa a la Biblioteca del Guardián";
	AL["Suspicious Bookshelf"] = "Publicaciones sospechosas";
	AL["Ramp up to the Celestial Watch"] = "Subida a la Vista Celestial";
	AL["Ramp down to the Gamesman's Hall"] = "Bajada a la Sala de Juegos";
	AL["Ramp to Medivh's Chamber"] = "Rampa a la Cámara de Medivh";
	AL["Spiral Stairs to Netherspace"] = "Escaleras de caracol a Rencor Abisal";
	AL["Wravien <The Mage>"] = "Wravien <El Mago>";
	AL["Gradav <The Warlock>"] = "Gradav <El Brujo>";
	AL["Kamsis <The Conjurer>"] = "Kamsis <La Conjuradora>";
	AL["Ythyar"] = "Ythyar";
	AL["Echo of Medivh"] = "Eco de Medivh";

	--Magisters Terrace
	AL["Fel Crystals"] = "Cristales Viles";
	AL["Apoko"] = "Apoko";
	AL["Eramas Brightblaze"] = "Eramas Llamarada Brillante";
	AL["Ellrys Duskhallow"] = "Ellrys Anochecher Santificado";
	AL["Fizzle"] = "Fizel";
	AL["Garaxxas"] = "Garaxxas";
	AL["Sliver <Garaxxas' Pet>"] = "Tajada <Mascota de Garaxxas>";
	AL["Kagani Nightstrike"] = "Kajani Golpe de la Noche";
	AL["Warlord Salaris"] = "Señor de la Guerra Salaris";
	AL["Yazzai"] = "Yazzai";
	AL["Zelfan"] = "Zelfan";
	AL["Tyrith"] = "Tyrith";
	AL["Scrying Orb"] = "Orbe de visión";

	--Sunwell Plateau
	AL["Madrigosa"] = "Madrigosa";

	--TK: The Arcatraz
	AL["Warpforged Key"] = "Llave forjada de distorsión";
	AL["Millhouse Manastorm"] = "Molino Tormenta de maná";
	AL["Third Fragment Guardian"] = "Guardián del Tercer Fragmento";
	AL["Udalo"] = "Udalo";

	--TK: The Botanica

	--TK: The Mechanar
	AL["Overcharged Manacell"] = "Célula de maná sobrecargada";

	--TK: The Eye

	--Zul'Aman
	AL["Harrison Jones"] = "Harrison Jones";
	AL["Tanzar"] = "Tanzar";
	AL["The Map of Zul'Aman"] = "Mapa de Zul'Aman de Budd";
	AL["Harkor"] = "Harkor";
	AL["Kraz"] = "Kraz";
	AL["Ashli"] = "Ashli";
	AL["Thurg"] = "Thurg";
	AL["Gazakroth"] = "Gazakroth";
	AL["Lord Raadan"] = "Lord Raadan";
	AL["Darkheart"] = "Corazón Oscuro";
	AL["Alyson Antille"] = "Alyson Antille";
	AL["Slither"] = "Slither";
	AL["Fenstalker"] = "Fenstalker";
	AL["Koragg"] = "Koragg";
	AL["Zungam"] = "Zungam";
	AL["Forest Frogs"] = "Ranas del bosque";
	AL["Kyren <Reagents>"] = "Kyren <Componentes>";
	AL["Gunter <Food Vendor>"] = "Gunter <Vendedor de comida>";
	AL["Adarrah"] = "Adarrah";
	AL["Brennan"] = "Brennan";
	AL["Darwen"] = "Darwen";
	AL["Deez"] = "Deez";
	AL["Galathryn"] = "Galathryn";
	AL["Mitzi"] = "Mitzi";
	AL["Mannuth"] = "Mannuth";

--*****************
-- WotLK Instances
--*****************

	--Azjol-Nerub: Ahn'kahet: The Old Kingdom
	AL["Ahn'kahet Brazier"] = "Blandón Ahn'kahet"; --Check

	--Azjol-Nerub: Azjol-Nerub
	AL["Watcher Gashra"] = "Vigía Gashra";
	AL["Watcher Narjil"] = "Vigía Narjil";
	AL["Watcher Silthik"] = "Vigía Silthik";
	AL["Elder Nurgen"] = "Ancestro Nurgen";

	--Caverns of Time: The Culling of Stratholme
	AL["The Culling of Stratholme"] = "La Matanza de Stratholme";
	AL["Scourge Invasion Points"] = "Puntos Invasión de la Plaga";
	AL["Guardian of Time"] = "Guardián del Tiempo";
	AL["Chromie"] = "Cromi";

	--Drak'Tharon Keep
	AL["Kurzel"] = "Kurzel";
	AL["Elder Kilias"] = "Ancestro Kilias";
	AL["Drakuru's Brazier"] = "El blandón de Drakuru"; --Check

	--The Frozen Halls: Halls of Reflection
	--3 beginning NPCs omitted, see The Forge of Souls
	AL["Wrath of the Lich King"] = "El Rey Exánime";
	AL["The Captain's Chest"] = "El cofre del Capitán";

	--The Frozen Halls: Pit of Saron
	--6 beginning NPCs omitted, see The Forge of Souls
	AL["Martin Victus"] = "Martin Victus";
	AL["Gorkun Ironskull"] = "Gorkun Testahierro";
	AL["Rimefang"] = "Dientefrío";

	--The Frozen Halls: The Forge of Souls
	--Lady Jaina Proudmoore omitted, in Hyjal Summit
	AL["Archmage Koreln <Kirin Tor>"] = "Archimago Koreln <Kirin Tor>";
	AL["Archmage Elandra <Kirin Tor>"] = "Archimaga Elandra <Kirin Tor>";
	AL["Lady Sylvanas Windrunner <Banshee Queen>"] = "Lady Sylvanas Brisaveloz <Reina alma en pena>";
	AL["Dark Ranger Loralen"] = "Forestal oscura Loralen";
	AL["Dark Ranger Kalira"] = "Forestal oscura Kalira";

	--Gundrak
	AL["Elder Ohanzee"] = "Ancestro Ohanzee";

	--Icecrown Citadel
	AL["To next map"] = "Al siguiente mapa";
	AL["From previous map"] = "Desde mapa anterior";
	AL["Upper Spire"] = "Aguja Superior";
	AL["Sindragosa's Lair"] = "Guarida de Sindragosa";
	AL["Stinky"] = "Apestoso";
	AL["Precious"] = "Precioso";

	--Naxxramas
	AL["Mr. Bigglesworth"] = "Sr. Biguelvalor";
	AL["Frostwyrm Lair"] = "Guarida Vermis de Escarcha";
	AL["Teleporter to Middle"] = "Teletransporte al centro";

	--The Obsidian Sanctum
	AL["Black Dragonflight Chamber"] = "Cámara del vuelo Negro"; --Check

	--Onyxia's Lair

	--The Ruby Sanctum
	AL["Red Dragonflight Chamber"] = "La cámara del Vuelo de Dragones Rojo";

	--The Nexus: The Eye of Eternity
	AL["Key to the Focusing Iris"] = "Llave del Iris de enfoque";	

	--The Nexus: The Nexus
	AL["Berinand's Research"] = "Investigación de Berinand";
	AL["Elder Igasho"] = "Ancestro Igasho";

	--The Nexus: The Oculus
	AL["Centrifuge Construct"] = "Ensamblaje de centrifugadora";
	AL["Cache of Eregos"] = "Alijo de Eregos";

	--Trial of the Champion
	AL["Champions of the Alliance"] = "Campeones de la Alianza";
	AL["Marshal Jacob Alerius"] = "Mariscal Jacob Alerius";
	AL["Ambrose Boltspark"] = "Ambrose Chisparrayo";
	AL["Colosos"] = "Colosos";
	AL["Jaelyne Evensong"] = "Jaelyne Unicanto";
	AL["Lana Stouthammer"] = "Lana Martillotenaz";
	AL["Champions of the Horde"] = "Campeones de la Horda";

	--Trial of the Crusader
	AL["Heroic: Trial of the Grand Crusader"] = "Heróica: Prueba del Gran Cruzado";
	AL["Cavern Entrance"] = "Entrada a la caverna";

	--Ulduar General
	AL["Celestial Planetarium Key"] = "Llave de El Planetario Celestial";
	AL["The Siege"] = "El asedio";
	AL["The Keepers"] = "Los vigilantes"; --C Check

	--Ulduar A
	AL["Tower of Life"] = "Torre de Vida";
	AL["Tower of Flame"] = "Torre de Llamas";
	AL["Tower of Frost"] = "Torre de Escarcha";
	AL["Tower of Storms"] = "Torre de Tormentas";

	--Ulduar B
	AL["Prospector Doren"] = "Prospector Doren";
	AL["Archivum Console"] = "Consola de El Archivum";

	--Ulduar C
	AL["Sif"] = "Sif";

	--Ulduar D

	--Ulduar E

	--Ulduar: Halls of Lightning

	--Ulduar: Halls of Stone
	AL["Tribunal Chest"] = "Cofre del tribunal";
	AL["Elder Yurauk"] = "Ancestro Yurauk";
	AL["Brann Bronzebeard"] = "Brann Barbabronce";

	--Utgarde Keep: Utgarde Keep
	AL["Dark Ranger Marrah"] = "Forestal oscura Marrah";
	AL["Elder Jarten"] = "Ancestro Jarten";

	--Utgarde Keep: Utgarde Pinnacle
	AL["Brigg Smallshanks"] = "Brigg Espinillas";
	AL["Elder Chogan'gada"] = "Ancestro Chogan'gada";

	--Vault of Archavon

	--The Violet Hold
	AL["The Violet Hold Key"] = "Llave de El Bastión Violeta";

--*********************
-- Cataclysm Instances
--*********************

	--Abyssal Maw
	--AL["TBD"] = "TBD"; --To Be Determined

	--Baradin Hold

	--Blackrock Caverns

	--Blackwing Descent

	--Caverns of Time: War of the Ancients

	--Grim Batol
	AL["Baleflame"] = "Fardollama";
	AL["Farseer Tooranu <The Earthen Ring>"] = "Clarividente Tooranu <El Anillo de la Tierra>";
	AL["Velastrasza"] = "Velastrasza";

	--Halls of Origination

	--Lost City of the Tol'vir
	AL["Captain Hadan"] = "Capitán Hadan";
	AL["Augh"] = "Augh";

	--Sulfuron Keep

	--The Bastion of Twilight

	--The Stonecore
	AL["Earthwarden Yrsa <The Earthen Ring>"] = "Celadora de la tierra Yrsa"; --Needs Acronym

	--The Vortex Pinnacle
	AL["Itesh"] = "Itesh";

	--Throne of the Four Winds

	--Throne of the Tides
	AL["Captain Taylor"] = "Capitán Taylor";
	AL["Legionnaire Nazgrim"] = "Legionario Nazgrim";
	AL["Neptulon"] = "Neptulon";

end