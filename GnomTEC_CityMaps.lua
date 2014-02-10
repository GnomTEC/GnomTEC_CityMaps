-- **********************************************************************
-- GnomTEC CityMaps
-- Version: 5.3.0.5
-- Author: GnomTEC
-- Copyright 2012-2013 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_CityMaps")

-- ----------------------------------------------------------------------
-- Legacy global variables and constants (will be deleted in future)
-- ----------------------------------------------------------------------
GnomTEC_CityMaps_Flags = {
	[GetRealmName()] = {
		[UnitName("player")] = {};
	},
}

GnomTEC_CityMaps_Options = {
	["ShowStaticData"] = true,
	["ShowMSPData"] = true,
}

-- ----------------------------------------------------------------------
-- Addon global Constants (local)
-- ----------------------------------------------------------------------

local CONST_POIICON_FREE = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_FREE"
local CONST_POIICON_FREE_WITH_NPC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_FREE_WITH_NPC"
local CONST_POIICON_USED = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_USED"
local CONST_POIICON_USED_WITH_NPC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_USED_WITH_NPC"
local CONST_POIICON_PUBLIC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_PUBLIC"
local CONST_POIICON_GNOMTEC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_GNOMTEC"

-- ----------------------------------------------------------------------
-- Addon global variables (local)
-- ----------------------------------------------------------------------

-- Main options menue with general addon information
local optionsMain = {
	name = "GnomTEC CityMaps",
	type = "group",
	args = {
		descriptionTitle = {
			order = 1,
			type = "description",
			name = "Interaktive Stadtkarten.\n\n",
		},
		descriptionAbout = {
			name = "About",
			type = "group",
			guiInline = true,
			order = 2,
			args = {
				descriptionVersion = {
				order = 1,
				type = "description",			
				name = "|cffffd700".."Version"..": ".._G["GREEN_FONT_COLOR_CODE"]..GetAddOnMetadata("GnomTEC_CityMaps", "Version"),
				},
				descriptionAuthor = {
					order = 2,
					type = "description",
					name = "|cffffd700".."Autor"..": ".."|cffff8c00".."GnomTEC",
				},
				descriptionEmail = {
					order = 3,
					type = "description",
					name = "|cffffd700".."Email"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"].."info@gnomtec.de",
				},
				descriptionWebsite = {
					order = 4,
					type = "description",
					name = "|cffffd700".."Website"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"].."http://www.gnomtec.de/",
				},
				descriptionLicense = {
					order = 5,
					type = "description",
					name = "|cffffd700".."Copyright"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"].."(c)2012-2013 by GnomTEC",
				},
			}
		},
		descriptionLogo = {
			order = 5,
			type = "description",
			name = "",
			image =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\GnomTEC-Logo",
			imageCoords = {0.0,1.0,0.0,1.0},
			imageWidth = 512,
			imageHeight = 128,
		},
	}
}

local optionsView = {
	name = L["L_OPTIONS_VIEW"],
	type = 'group',
	args = {
		CityMapsOptionShowStaticData = {
			type = "toggle",
			name = L["L_OPTIONS_VIEW_SHOWSTATICDATA"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps_Options["ShowStaticData"] = val;GnomTEC_CityMaps:SetMap(GnomTEC_CityMaps.db.char.displayedMap) end,
			get = function(info) return GnomTEC_CityMaps_Options["ShowStaticData"] end,
			width = 'full',
			order = 1
		},
		cityMapsOptionShowMSPData = {
			type = "toggle",
			name = L["L_OPTIONS_VIEW_SHOWMSPDATA"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps_Options["ShowMSPData"] = val;GnomTEC_CityMaps:SetMap(GnomTEC_CityMaps.db.char.displayedMap) end,
	   	get = function(info) return GnomTEC_CityMaps_Options["ShowMSPData"] end,
			width = 'full',
			order = 2
		},
	},
}


-- maps which are supported by addon
local availableMaps = {
--	["Stormwind City"] = {
--		text = "Sturmwind",
--		notCheckable = 1,
--		func = function () GnomTEC_CityMaps:SetMap("Stormwind City"); end,	
--		map1 = "Interface\\WorldMap\\StormwindCity\\StormwindCity1",
--		map2 = "Interface\\WorldMap\\StormwindCity\\StormwindCity2",
--		map3 = "Interface\\WorldMap\\StormwindCity\\StormwindCity3",
--		map4 = "Interface\\WorldMap\\StormwindCity\\StormwindCity4",
--		map5 = "Interface\\WorldMap\\StormwindCity\\StormwindCity5",
--		map6 = "Interface\\WorldMap\\StormwindCity\\StormwindCity6",
--		map7 = "Interface\\WorldMap\\StormwindCity\\StormwindCity7",
--		map8 = "Interface\\WorldMap\\StormwindCity\\StormwindCity8",
--		map9 = "Interface\\WorldMap\\StormwindCity\\StormwindCity9",
--		map10 = "Interface\\WorldMap\\StormwindCity\\StormwindCity10",
--		map11 = "Interface\\WorldMap\\StormwindCity\\StormwindCity11",
--		map12 = "Interface\\WorldMap\\StormwindCity\\StormwindCity12"
--	},
	["Ironforge"] = {
		text = "Eisenschmiede",
		notCheckable = 1,
		func = function () GnomTEC_CityMaps:SetMap("Ironforge"); end,
		map1 = "Interface\\WorldMap\\Ironforge\\Ironforge1",
		map2 = "Interface\\WorldMap\\Ironforge\\Ironforge2",
		map3 = "Interface\\WorldMap\\Ironforge\\Ironforge3",
		map4 = "Interface\\WorldMap\\Ironforge\\Ironforge4",
		map5 = "Interface\\WorldMap\\Ironforge\\Ironforge5",
		map6 = "Interface\\WorldMap\\Ironforge\\Ironforge6",
		map7 = "Interface\\WorldMap\\Ironforge\\Ironforge7",
		map8 = "Interface\\WorldMap\\Ironforge\\Ironforge8",
		map9 = "Interface\\WorldMap\\Ironforge\\Ironforge9",
		map10 = "Interface\\WorldMap\\Ironforge\\Ironforge10",
		map11 = "Interface\\WorldMap\\Ironforge\\Ironforge11",
		map12 = "Interface\\WorldMap\\Ironforge\\Ironforge12"
	},	
}

-- Last time when a timer event was triggerd
local lastTimerEvent = GetTime()

-- List of POIs
local POI = {
	["IF_A"] = {
		name = "Das Bankenviertel",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A",
		localId = "A",
		zone = "Ironforge",
		x = 0.305,
		y = 0.668,
		npc = true,
		public = true,
		usedBy = nil,
	},	
	["IF_A1"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A1",
		localId = "A1",
		zone = "Ironforge",
		x = 0.529,
		y = 0.885,		
		npc = nil,
		public = nil,
		usedBy = "Girmodan",
	},
	["IF_A2"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A2",
		localId = "A2",
		zone = "Ironforge",
		x = 0.496,
		y = 0.883,		
		npc = nil,
		public = nil,
		usedBy = "Lara Feuerkabel und Orilla",
	},
 	["IF_A3"] = {
		name = "---",
		description = "Großsteinmetz Marmorstein",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A3",
		localId = "A3",
		zone = "Ironforge",
		x = 0.388,
		y = 0.871,		
		npc = true,
		public = nil,
		usedBy = nil,
	},
 	["IF_A4"] = {
		name = "Besucherzentrum von Eisenschmiede",
		description = "Gildenmeister, Gildenhändler und Wappenröcke",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A4",
		localId = "A4",
		zone = "Ironforge",
		x = 0.362,
		y = 0.849,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A5"] = {
		name = "Auktionshaus",
		description = "Auktionatoren",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A5",
		localId = "A5",
		zone = "Ironforge",
		x = 0.252,
		y = 0.740,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A6"] = {
		name = "Barims Reagenzien",
		description = "Reagenzien",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A6",
		localId = "A6",
		zone = "Ironforge",
		x = 0.194,
		y = 0.575,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A7"] = {
		name = "Steinfeuertaverne",
		description = "Taverne",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A7",
		localId = "A7",
		zone = "Ironforge",
		x = 0.194,
		y = 0.522,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A8"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A8",
		localId = "A8",
		zone = "Ironforge",
		x = 0.266,
		y = 0.382,		
		npc = nil,
		public = nil,
		usedBy = "Lemu",
	},	
 	["IF_A9"] = {
		name = "Barbier",
		description = "Barbier",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A9",
		localId = "A9",
		zone = "Ironforge",
		x = 0.262,
		y = 0.512,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A10"] = {
		name = "Rüstkammer von Eisenschmiede",
		description = "Rüstungen",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A10",
		localId = "A10",
		zone = "Ironforge",
		x = 0.321,
		y = 0.589,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A11"] = {
		name = "Bank",
		description = "Bank",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A11",
		localId = "A11",
		zone = "Ironforge",
		x = 0.349,
		y = 0.623,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A12"] = {
		name = "Stahlzorns Waffenkaufhaus",
		description = "Waffenhändler",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A12",
		localId = "A12",
		zone = "Ironforge",
		x = 0.373,
		y = 0.676,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A13"] = {
		name = "Zischeldrehs Gemischtwaren",
		description = "Handwerkswaren",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A13",
		localId = "A13",
		zone = "Ironforge",
		x = 0.386,
		y = 0.753,		
		npc = true,
		public = nil,
		usedBy = nil,
	},	
 	["IF_A14"] = {
		name = "---",
		description = "Leerer Laden",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A14",
		localId = "A14",
		zone = "Ironforge",
		x = 0.409,
		y = 0.767,		
		npc = nil,
		public = nil,
		usedBy = "Silberbart's Kuriositäten",
	},	
 	["IF_A15"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A15",
		localId = "A15",
		zone = "Ironforge",
		x = 0.508,
		y = 0.783,		
		npc = nil,
		public = nil,
		usedBy = "Arom Goldbart",
	},	
	["IF_B"] = {
		name = "Das Mystikerviertel",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B",
		localId = "B",
		zone = "Ironforge",
		x = 0.310,
		y = 0.176,
		npc = true,
		public = true,
		usedBy = nil,
	},
	["IF_B1"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B1",
		localId = "B1",
		zone = "Ironforge",
		x = 0.209,
		y = 0.272,		
		npc = nil,
		public = nil,
		usedBy = "Söldnerbund Dämmersturm",
	},
	["IF_B2"] = {
		name = "---",
		description = "Leerer Laden",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B2",
		localId = "B2",
		zone = "Ironforge",
		x = 0.199,
		y = 0.204,
		npc = nil,
		public = nil,
		usedBy = "Handelsbund von Diarmai (völkergemischt)/ Strumhämmer",
	},
	["IF_B3"] = {
		name = "Der kämpfende Hexer",
		description = "Waffenhändler",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B3",
		localId = "B3",
		zone = "Ironforge",
		x = 0.229,
		y = 0.171,
		npc = true,
		public = nil,
		usedBy = nil,
	},	
	["IF_B4"] = {
		name = "Halle der Mysterien",
		description = "Portale",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B4",
		localId = "B4",
		zone = "Ironforge",
		x = 0.255,
		y = 0.084,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_B5"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B5",
		localId = "B5",
		zone = "Ironforge",
		x = 0.317,
		y = 0.047,
		npc = nil,
		public = nil,
		usedBy = nil,
	},
	["IF_B6"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B6",
		localId = "B6",
		zone = "Ironforge",
		x = 0.358,
		y = 0.026,
		npc = nil,
		public = nil,
		usedBy = "Togas",
	},
	["IF_B7"] = {
		name = "Maevas mystische Bekleidung",
		description = "Robenhändlerin",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B7",
		localId = "B7",
		zone = "Ironforge",
		x = 0.385,
		y = 0.055,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_B8"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B8",
		localId = "B8",
		zone = "Ironforge",
		x = 0.368,
		y = 0.226,
		npc = nil,
		public = nil,
		usedBy = "Nioni Silberstößel & Gamblin (WG)",
	},
	["IF_B9"] = {
		name = "Beerlangs Reagenzien",
		description = "Reagenzien",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B9",
		localId = "B9",
		zone = "Ironforge",
		x = 0.307,
		y = 0.277,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_C"] = {
		name = "Das düstere Viertell",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C",
		localId = "C",
		zone = "Ironforge",
		x = 0.491,
		y = 0.122,
		npc = true,
		public = true,
		usedBy = nil,
	},	
	["IF_C1"] = {
		name = "Bei Steinklinge",
		description = "Klingenhändler",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C1",
		localId = "C1",
		zone = "Ironforge",
		x = 0.450,
		y = 0.073,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_C2"] = {
		name = "Reisender Angler",
		description = "Angellehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C2",
		localId = "C2",
		zone = "Ironforge",
		x = 0.476,
		y = 0.071,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_C3"] = {
		name = "---",
		description = "Hexenmeisterlehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C3",
		localId = "C3",
		zone = "Ironforge",
		x = 0.503,
		y = 0.068,
		npc = true,
		public = nil,
		usedBy = "Erenea Kade",
	},
	["IF_C4"] = {
		name = "---",
		description = "Dämonenausbilder",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C4",
		localId = "C4",
		zone = "Ironforge",
		x = 0.533,
		y = 0.068,
		npc = true,
		public = nil,
		usedBy = "Garam Siedefaust & Luzula Schwarzgrund (Wohn- & Geschäftsräume)",
	},
	["IF_C5"] = {
		name = "---",
		description = "Schurkenlehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C5",
		localId = "C5",
		zone = "Ironforge",
		x = 0.518,
		y = 0.151,
		npc = true,
		public = nil,
		usedBy = "Breogir",
	},
	["IF_D"] = {
		name = "Die Halle der Forscher",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D",
		localId = "D",
		zone = "Ironforge",
		x = 0.635,
		y = 0.258,
		npc = true,
		public = true,
		usedBy = nil,
	},	
	["IF_D1"] = {
		name = "Bibliothek",
		description = "Bibliothek",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D1",
		localId = "D1",
		zone = "Ironforge",
		x = 0.720,
		y = 0.158,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_D2"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D2",
		localId = "D2",
		zone = "Ironforge",
		x = 0.643,
		y = 0.356,
		npc = nil,
		public = nil,
		usedBy = "GnomTEC Niederlassung Eisenschmiede|n(Effie Flammfix)",
		GnomTEC = true,
	},
	["IF_D3"] = {
		name = "---",
		description = "Leerer Laden",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D3",
		localId = "D3",
		zone = "Ironforge",
		x = 0.588,
		y = 0.250,
		npc = nil,
		public = nil,
		usedBy = "Thelsamar (Laden)",
	},
	["IF_D4"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D4",
		localId = "D4",
		zone = "Ironforge",
		x = 0.570,
		y = 0.192,
		npc = nil,
		public = nil,
		usedBy = "Thelsamar (Besprechungsraum)",
	},
	["IF_E"] = {
		name = "Tüftlerstadt",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E",
		localId = "E",
		zone = "Ironforge",
		x = 0.698,
		y = 0.499,
		npc = true,
		public = true,
		usedBy = nil,
	},	
	["IF_E1"] = {
		name = "---",
		description = "Leerer Laden",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E1",
		localId = "E1",
		zone = "Ironforge",
		x = 0.740,
		y = 0.479,
		npc = nil,
		public = nil,
		usedBy = nil,
	},
	["IF_E2"] = {
		name = "Sachen, die BUMM machen!",
		description = "Feuerwerksverkäufer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E2",
		localId = "E2",
		zone = "Ironforge",
		x = 0.734,
		y = 0.533,	
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_E3"] = {
		name = "Brausefitz´ Tränke und Mischgetränke",
		description = "Alchemielehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E3",
		localId = "E3",
		zone = "Ironforge",
		x = 0.666,
		y = 0.547,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_E4"] = {
		name = "Gerätehandel Sprungspindel",
		description = "Ingenieurslehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E4",
		localId = "E4",
		zone = "Ironforge",
		x = 0.679,
		y = 0.435,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_F"] = {
		name = "Das Militärviertel",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F",
		localId = "F",
		zone = "Ironforge",
		x = 0.627,
		y = 0.768,
		npc = true,
		public = true,
		usedBy = nil,
	},
	["IF_F1"] = {
		name = "Goldrauschs Jagdbedarf",
		description = "Schusswaffenhändler",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F1",
		localId = "F1",
		zone = "Ironforge",
		x = 0.723,
		y = 0.670,
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_F2"] = {
		name = "Bruuks Ecke",
		description = "Taverne",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F3",
		localId = "F2",
		zone = "Ironforge",
		x = 0.722,
		y = 0.740,
		npc = true,
		public = nil,
		usedBy = "Glofur Taverne",
	},
	["IF_F3"] = {
		name = "Halle der Waffen",
		description = "Kampfmeister und Klassenlehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F3",
		localId = "F3",
		zone = "Ironforge",
		x = 0.675,
		y = 0.846,
		npc = true,
		public = nil,
		usedBy = " Militär Eisenschmiede",
	},
	["IF_F4"] = {
		name = "Schlachtholzwaffen",
		description = "Streitkolben&Stäbe",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F4",
		localId = "F4",
		zone = "Ironforge",
		x = 0.617,
		y = 0.892,			
		npc = true,
		public = nil,
		usedBy = nil,
	},
	["IF_F5"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F5",
		localId = "F5",
		zone = "Ironforge",
		x = 0.576,
		y = 0.913,
		npc = nil,
		public = nil,
		usedBy = "Ballasch Donnerbart ",
	},
	["IF_F6"] = {
		name = "Felshelms Platten und Ketten",
		description = "Kettenrüstungen",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F6",
		localId = "F6",
		zone = "Ironforge",
		x = 0.551,
		y = 0.885,	
		npc = true,
		public = nil,
		usedBy = nil,
	},	
	["IF_F7"] = {
		name = "---",
		description = "Leerer Laden",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F7",
		localId = "F7",
		zone = "Ironforge",
		x = 0.590,
		y = 0.661,
		npc = nil,
		public = nil,
		usedBy = "Donnerbarts Donnerbüchsen",
	},		
	["IF_G"] = {
		name = " Die große Schmiede",
		description = "Öffentlicher Platz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G",
		localId = "G",
		zone = "Ironforge",
		x = 0.498,
		y = 0.449,
		npc = true,
		public = true,
		usedBy = nil,
	},	
	["IF_G1"] = {
		name = "Botschaft der Dunkeleisen Zwerge",
		description = "Botschaft",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G1",
		localId = "G1",
		zone = "Ironforge",
		x = 0.381,
		y = 0.458,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G2"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G2",
		localId = "G2",
		zone = "Ironforge",
		x = 0.368,
		y = 0.321,	
		npc = nil,
		public = nil,
		usedBy = "Baccùs Silberbarts",
	},
	["IF_G3"] = {
		name = "Lederwaren Feinspindel",
		description = "Lederverarbeizung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G3",
		localId = "G3",
		zone = "Ironforge",
		x = 0.403,
		y = 0.352,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G4"] = {
		name = "Tuchmacherei Steinbrauel",
		description = "Schneiderbedarf",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G4",
		localId = "G4",
		zone = "Ironforge",
		x = 0.438,
		y = 0.296,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G5"] = {
		name = "Bubriks Laden",
		description = "Handwerkswaren",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G5",
		localId = "G5",
		zone = "Ironforge",
		x = 0.467,
		y = 0.278,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G6"] = {
		name = "Tiefenbergbaugilde",
		description = "Bergbaulehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G6",
		localId = "G6",
		zone = "Ironforge",
		x = 0.504,
		y = 0.275,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G7"] = {
		name = "---",
		description = "Schamanenlehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G7",
		localId = "G7",
		zone = "Ironforge",
		x = 0.552,
		y = 0.300,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G8"] = {
		name = "Zum Bronzekessel",
		description = "Kochkunstlehrer",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G8",
		localId = "G8",
		zone = "Ironforge",
		x = 0.596,
		y = 0.376,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G9"] = {
		name = "Arkananien Distelflaum",
		description = "Inschriftenkunde und Verzauberungskunst",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G9",
		localId = "G9",
		zone = "Ironforge",
		x = 0.600,
		y = 0.450,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G10"] = {
		name = "---",
		description = "Leere Taverne",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G10",
		localId = "G10",
		zone = "Ironforge",
		x = 0.593,
		y = 0.497,	
		npc = nil,
		public = nil,
		usedBy = "Zum brodelnden Kupferkessel",
	},
	["IF_G11"] = {
		name = "---",
		description = "Leere Wohnung",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G11",
		localId = "G11",
		zone = "Ironforge",
		x = 0.579,
		y = 0.543,	
		npc = nil,
		public = nil,
		usedBy = "Graccas",
	},
	["IF_G12"] = {
		name = "Heiler von Eisenschmiede",
		description = "Kräuterkunde und Erste Hilfe",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G12",
		localId = "G12",
		zone = "Ironforge",
		x = 0.553,
		y = 0.579,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
	["IF_G13"] = {
		name = "---",
		description = "Leerer Laden",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G13",
		localId = "G13",
		zone = "Ironforge",
		x = 0.496,
		y = 0.612,	
		npc = nil,
		public = nil,
		usedBy = "Wachstube von Militär Eisenschmiede",
	},
	["IF_G14"] = {
		name = "Der Hohe Sitz",
		description = "Der Hohe Sitz",
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G14",
		localId = "G14",
		zone = "Ironforge",
		x = 0.421,
		y = 0.523,	
		npc = true,
		public = nil,
		usedBy = nil,
	},		
}

-- display of POI information is locked
local lockInfo = false

-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_CityMaps = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_CityMaps", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0")
local Tourist = LibStub("LibTourist-3.0") 

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC CityMaps Main", optionsMain)
LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC CityMaps View", optionsView)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC CityMaps Main", "GnomTEC CityMaps");
panelConfiguration = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC CityMaps View", L["L_OPTIONS_VIEW"], "GnomTEC CityMaps");


-- ----------------------------------------------------------------------
-- Local functions
-- ----------------------------------------------------------------------

-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

-- function to cleanup control sequences
local function cleanpipe( x )
	x = x or ""
	
	-- Filter coloring
	x = string.gsub( x, "|c%x%x%x%x%x%x%x%x", "" )
	x = string.gsub( x, "|r", "" )
	
	-- Filter links
	x = string.gsub( x, "|H.-|h", "" )
	x = string.gsub( x, "|h", "" )
	
	-- Filter textures
	x = string.gsub( x, "|T.-|t", "" )

	-- Filter battle.net friend's name
	x = string.gsub( x, "|K.-|k", "" )
	x = string.gsub( x, "|k", "" )

	-- Filter newline
	x = string.gsub( x, "|n", "" )
	
	-- at last filter any left escape
	x = string.gsub( x, "|", "/" )	
	
	return strtrim(x)
end

-- shows player position on map
function GnomTEC_CityMaps:ShowPlayerPosition()
	local player = UnitName("player")
	local posX, posY = GetPlayerMapPosition("player");
	local map = GetMapInfo();
	local zone = nil;
	local x,y;
	
	if not map then
		if GetCurrentMapZone() == 0 then
			if GetCurrentMapContinent() == 0 then
				zone = "Azeroth";
			elseif GetCurrentMapContinent() == -1 then
				zone = "Cosmic map";
			end
		end
	else
		zone = Tourist:GetEnglishZoneFromTexture(map);
	end
	
	x = 0;
	
	if (posX ~= 0 and posY ~= 0 and zone) then
		if (zone == "Stormwind") then
			-- Stormwind kennt LibTourist so nicht
			zone = "Stormwind City"
		end

		x,y = Tourist:TransposeZoneCoordinate(posX, posY, zone, self.db.char.displayedMap)
	end
		
	if (not x or not y) then
		-- Wir sind nicht auf einer Position die auf der aktuellen Karte angezeigt werden könnte
		local playerFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_PLAYER")
		if (playerFrame) then
			playerFrame:Hide()
		end
	else
	
		GNOMTEC_CITYMAPS_FRAME_POI:SetText("("..self.db.char.displayedMap.." ; "..string.format("%.3f",x).." ; "..string.format("%.3f",y)..")")
		-- compute frame offsets
		x = 1000.0 / 1024.0 * 600.0 * x	+ 15	-- visible texture / texturesize * framesize * position + offset
		y = -(667.0 / 778.0 * 450.0 * y) - 20	-- visible texture / texturesize * framesize * position - offest
		local playerFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_PLAYER")
		if (not playerFrame) then
			playerFrame = CreateFrame("Frame","GNOMTEC_CITYMAPS_FRAME_PLAYER",GNOMTEC_CITYMAPS_FRAME)
			playerFrame:SetFrameStrata(GNOMTEC_CITYMAPS_FRAME:GetFrameStrata());
			playerFrame:SetFrameLevel(GNOMTEC_CITYMAPS_FRAME:GetFrameLevel()+21)
			playerFrame:SetWidth(16); -- Set these to whatever height/width is needed 
			playerFrame:SetHeight(16); -- for your Texture

			local playerTexture = playerFrame:CreateTexture(nil,"OVERLAY");
			playerTexture:SetTexture("Interface\\WorldMap\\WorldMapPlayerIcon");
			playerTexture:SetAllPoints(playerFrame);
			playerFrame.texture = playerTexture;
			playerFrame:SetAlpha(1.0); 
			playerFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x,y)
			playerFrame:Show();
		else
			playerFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x,y)
			playerFrame:Show();		
		end	
	end			
end

-- function called when mouse enters the POI icon on map (attached in GnomTEC_CityMaps:ShowPOI())
local function GnomTEC_CityMaps_POIFrame_OnEnter(self)
	-- show tooltip
	
	local id = string.gsub(self:GetName(),"GNOMTEC_CITYMAPS_FRAME_POI_","");
	if (id and not lockedInfo) then
		if (POI[id]) then
			GNOMTEC_CITYMAPS_FRAME_INFO:SetFrameLevel(GNOMTEC_CITYMAPS_FRAME:GetFrameLevel()+25)
			if (POI[id].y < 0.5) then 
				GNOMTEC_CITYMAPS_FRAME_INFO:SetPoint("TOP",0,-230)
			else
				GNOMTEC_CITYMAPS_FRAME_INFO:SetPoint("TOP",0,-30)
			end
			GNOMTEC_CITYMAPS_FRAME_INFO_PICTURE:SetTexture(POI[id].picture);
			GNOMTEC_CITYMAPS_FRAME_INFO_NAME:SetText(POI[id].name)

			local mspText = ""
			local usedByText = ""

			if (GnomTEC_CityMaps_Options["ShowMSPData"]) then
				if POI[id].MSP then
					local realm = GetRealmName()
					if POI[id].MSP[realm] then
						local key, value
						local poiList = {}
						-- adding all entries to a list so we get no duplicates for same entries 
						-- made by different players
						for key,value in pairs(POI[id].MSP[realm]) do
							poiList[value] = true
						end
						for key,value in pairs(poiList) do
							if ("" ~= mspText) then
								mspText = mspText.."|n"
							end
							mspText = mspText..key
						end
					end
				end	
				if ("" == mspText) then
					mspText = "<frei>"
				end
				mspText = "|n|n|cFFFFFF80--- Genutzt von (dynamisch MSP)---|r|n"..mspText
			end
			
			if (GnomTEC_CityMaps_Options["ShowStaticData"]) then
				usedByText = "|n|n|cFFFFFF80--- Genutzt von (statische Liste)---|r|n"..(POI[id].usedBy or "<frei>")
			end

			GNOMTEC_CITYMAPS_FRAME_INFO_SCROLL_DESCRIPTION:SetText("|cFFFFFF80--- Engine ---|r|n"..POI[id].description..usedByText..mspText)
			GNOMTEC_CITYMAPS_FRAME_INFO_SCROLL:UpdateScrollChildRect()
			GNOMTEC_CITYMAPS_FRAME_INFO_SCROLL_SLIDER:SetMinMaxValues(0, GNOMTEC_CITYMAPS_FRAME_INFO_SCROLL:GetVerticalScrollRange())
			GNOMTEC_CITYMAPS_FRAME_INFO_SCROLL_SLIDER:SetValue(0) 
			GNOMTEC_CITYMAPS_FRAME_INFO_LOCALID:SetText(POI[id].localId)
			GNOMTEC_CITYMAPS_FRAME_INFO:Show();
		end
	end
end

-- function called when mouse leaves the POI icon on map (attached in GnomTEC_CityMaps:ShowPOI())
local function GnomTEC_CityMaps_POIFrame_OnLeave(self)
	if (not lockedInfo) then
		GNOMTEC_CITYMAPS_FRAME_INFO:Hide();
	end
end

-- function called when mouse is pressed on POI icon on map (attached in GnomTEC_CityMaps:ShowPOI())
local function GnomTEC_CityMaps_POIFrame_OnMouseDown(self)
	lockedInfo = true
	GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton:Show();
end

-- function called when close button of info frame is clicked (attached in GnomTEC_CityMaps:ShowPOI())
local function GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton_OnClick(self)
	lockedInfo = false
	GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton:Hide();
	GNOMTEC_CITYMAPS_FRAME_INFO:Hide();
end

-- function to display a POI on actual map
function GnomTEC_CityMaps:ShowPOI(id)

	local x,y = Tourist:TransposeZoneCoordinate(POI[id].x, POI[id].y, POI[id].zone, self.db.char.displayedMap)
		
	if (not x) then
		-- falls angezeigt dann entfernen
		local POIFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_POI_"..id)
		if (POIFrame) then
			POIFrame:Hide()
		end
	else		
		-- compute frame offsets
		x = 1000.0 / 1024.0 * 600.0 * x	+ 15	-- visible texture / texturesize * framesize * position + offset
		y = -(667.0 / 778.0 * 450.0 * y) - 20	-- visible texture / texturesize * framesize * position - offest

		local POIFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_POI_"..id)
		if (not POIFrame) then

			POIFrame = CreateFrame("Frame","GNOMTEC_CITYMAPS_FRAME_POI_"..id,GNOMTEC_CITYMAPS_FRAME)
			POIFrame:SetFrameStrata(GNOMTEC_CITYMAPS_FRAME:GetFrameStrata());
			POIFrame:SetFrameLevel(GNOMTEC_CITYMAPS_FRAME:GetFrameLevel()+20)
			POIFrame:SetWidth(16); -- Set these to whatever height/width is needed 
			POIFrame:SetHeight(16); -- for your Texture
			POIFrame:EnableMouse(true);
			POIFrame:HookScript("OnEnter",GnomTEC_CityMaps_POIFrame_OnEnter);
			POIFrame:HookScript("OnLeave",GnomTEC_CityMaps_POIFrame_OnLeave);		
			POIFrame:HookScript("OnMouseDown",GnomTEC_CityMaps_POIFrame_OnMouseDown);		
			local POITexture = POIFrame:CreateTexture(nil,"OVERLAY");
			POITexture:SetTexture(CONST_POIICON_FREE)	
			POITexture:SetAllPoints(POIFrame);
			POIFrame.texture = POITexture;			
			POIFrame:SetAlpha(1.0); 
		end

		local mspData = false
		if POI[id].MSP then
			local realm = GetRealmName()
			if POI[id].MSP[realm] then
				for key,value in pairs(POI[id].MSP[realm]) do
					mspData = true
				end
			end
		end	

		local POITexture = POIFrame.texture
		if (POI[id].public) then
			POITexture:SetTexture(CONST_POIICON_PUBLIC)
		elseif (POI[id].GnomTEC and GnomTEC_CityMaps_Options["ShowStaticData"]) then
			POITexture:SetTexture(CONST_POIICON_GNOMTEC)
		elseif ((POI[id].usedBy and GnomTEC_CityMaps_Options["ShowStaticData"]) or (mspData and GnomTEC_CityMaps_Options["ShowMSPData"]))then		
			if (POI[id].npc) then
				POITexture:SetTexture(CONST_POIICON_USED_WITH_NPC)
			else
				POITexture:SetTexture(CONST_POIICON_USED)				
			end
		else
			if (POI[id].npc) then
				POITexture:SetTexture(CONST_POIICON_FREE_WITH_NPC)
			else
				POITexture:SetTexture(CONST_POIICON_FREE)				
			end
		end					
		POIFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x, y)
		POIFrame:Show();		
	end			
end

-- function to set map which should be displayed
function GnomTEC_CityMaps:SetMap(map)
	if (not availableMaps[map]) then
		map = "Ironforge"
	end
	GNOMTEC_CITYMAPS_FRAME_SELECTMAP_BUTTON:SetText(availableMaps[map].text)
	GNOMTEC_CITYMAPS_FRAME_MAP1:SetTexture(availableMaps[map].map1)
	GNOMTEC_CITYMAPS_FRAME_MAP2:SetTexture(availableMaps[map].map2)
	GNOMTEC_CITYMAPS_FRAME_MAP3:SetTexture(availableMaps[map].map3)
	GNOMTEC_CITYMAPS_FRAME_MAP4:SetTexture(availableMaps[map].map4)
	GNOMTEC_CITYMAPS_FRAME_MAP5:SetTexture(availableMaps[map].map5)
	GNOMTEC_CITYMAPS_FRAME_MAP6:SetTexture(availableMaps[map].map6)
	GNOMTEC_CITYMAPS_FRAME_MAP7:SetTexture(availableMaps[map].map7)
	GNOMTEC_CITYMAPS_FRAME_MAP8:SetTexture(availableMaps[map].map8)
	GNOMTEC_CITYMAPS_FRAME_MAP9:SetTexture(availableMaps[map].map9)
	GNOMTEC_CITYMAPS_FRAME_MAP10:SetTexture(availableMaps[map].map10)
	GNOMTEC_CITYMAPS_FRAME_MAP11:SetTexture(availableMaps[map].map11)
	GNOMTEC_CITYMAPS_FRAME_MAP12:SetTexture(availableMaps[map].map12)
	
	self.db.char.displayedMap = map

	-- Hide player positions
	local playerFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_PLAYER")
	if (playerFrame) then
		playerFrame:Hide();		
	end	

	-- update POI display
	local key, value
	for key,value in pairs(POI) do
		GnomTEC_CityMaps:ShowPOI(key)
	end
end

-- callback function for timer events 
function GnomTEC_CityMaps:TimerEvent()
	local t = GetTime()
		
	-- Update Position every 5 second
	if ((t-lastTimerEvent) > 5) then
		GnomTEC_CityMaps:ShowPlayerPosition()
		
		lastTimerEvent = t
	end
end

-- update POI information with player data
function GnomTEC_CityMaps:UpdatePOI(realm, player)
	if not GnomTEC_CityMaps_Flags[realm] then GnomTEC_CityMaps_Flags[realm] = {} end
	if not GnomTEC_CityMaps_Flags[realm][player] then GnomTEC_CityMaps_Flags[realm][player] = {} end
	local r = GnomTEC_CityMaps_Flags[realm][player]
	local updatePOI = {}
	local key, value
	
	-- remove existing POI entries from player
	if (r.POI) then
		for key,value in pairs(r.POI) do
			if (POI[key]) then
				if (POI[key].MSP) then
					if (POI[key].MSP[realm]) then
						updatePOI[key] = true
						POI[key].MSP[realm][player] = nil
					end
				end
			end
		end
		r.POI = nil
	end
		
	for key, value in string.gmatch(r.HH or "", "(%w+_%w+)=([^%]]+)") do
		if (POI[key]) then
			if (not POI[key].MSP) then POI[key].MSP = {} end
			if (not POI[key].MSP[realm]) then POI[key].MSP[realm] = {} end
			if (not POI[key].MSP[realm]) then POI[key].MSP[realm] = {} end
			POI[key].MSP[realm][player] = value
			if (not r.POI) then r.POI = {} end
			r.POI[key] = value
			updatePOI[key] = true
		end
	end
	
	-- update POI display for changed POIs
	for key,value in pairs(updatePOI) do
		GnomTEC_CityMaps:ShowPOI(key)
	end
	
end

-- save data from MSP
function GnomTEC_CityMaps:SaveFlag(realm, player)
	if not GnomTEC_CityMaps_Flags[realm] then GnomTEC_CityMaps_Flags[realm] = {} end
	if not GnomTEC_CityMaps_Flags[realm][player] then GnomTEC_CityMaps_Flags[realm][player] = {} end
	local r = GnomTEC_CityMaps_Flags[realm][player]
	
	r.timeStamp = time()
	local p
	if (realm and (realm ~= GetRealmName())) then
		p = msp_GnomTEC.char[ player.."-"..realm ]
	else
		p = msp_GnomTEC.char[ player ]	
	end

	-- Name
	r.NA = emptynil( cleanpipe( p.field.NA ) )
	-- Home
	r.HH = emptynil( cleanpipe( p.field.HH ) )
	-- Additional not character relevant informations
	r.VA = emptynil( cleanpipe( p.field.VA ) )
		
	GnomTEC_CityMaps:UpdatePOI(realm,player)
	
	-- check for updates of our own flag (which we will not get the "normal" way
	realm = GetRealmName()
	player = UnitName("player")
	if not GnomTEC_CityMaps_Flags[realm] then GnomTEC_CityMaps_Flags[realm] = {} end
	if not GnomTEC_CityMaps_Flags[realm][player] then GnomTEC_CityMaps_Flags[realm][player] = {} end
	r = GnomTEC_CityMaps_Flags[realm][player]

	if (msp) then
		-- found flag addon using libMSP
		if (msp.my) then
			r.NA = emptynil( cleanpipe( msp.my['NA'] ) )
			-- Home
			r.HH = emptynil( cleanpipe( msp.my['HH'] ) )
			-- Additional not character relevant informations
			r.VA = emptynil( cleanpipe( msp.my['VA'] ) )
		end
	elseif (msptrp) then
		-- found Total RP2
		if (msptrp.my) then
			r.NA = emptynil( cleanpipe( msptrp.my['NA'] ) )
			-- Home
			r.HH = emptynil( cleanpipe( msptrp.my['HH'] ) )
			-- Additional not character relevant informations
			r.VA = emptynil( cleanpipe( msptrp.my['VA'] ) )
		end
	end

	GnomTEC_CityMaps:UpdatePOI(realm,player)
	

 end
 
 -- callback from MSP
 local function GnomTEC_CityMaps_MSPcallback(char)
	-- process new flag from char 
	local player, realm = strsplit( "-", char, 2 )
	realm = realm or GetRealmName()
	GnomTEC_CityMaps:SaveFlag(realm, player)
end

function GnomTEC_CityMaps:OpenConfiguration()
	InterfaceOptionsFrame_OpenToCategory(panelConfiguration)
	-- sometimes first call lands not on desired panel
	InterfaceOptionsFrame_OpenToCategory(panelConfiguration)
end
-- ----------------------------------------------------------------------
-- Frame event handler and functions
-- ----------------------------------------------------------------------

-- initialize drop down menu
local function GnomTEC_CityMaps_SelectMap_InitializeDropDown(level)
	local key, value
	
	for key,value in pairs(availableMaps) do	
		UIDropDownMenu_AddButton(value)
	end

end

-- select map drop down menu OnLoad
function GnomTEC_CityMaps:SelectMap_DropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GnomTEC_CityMaps_SelectMap_InitializeDropDown, "MENU")
end

-- select map drop down menu OnClick
function GnomTEC_CityMaps:SelectMap_Button_OnClick(self, button, down)
	ToggleDropDownMenu(1, nil, GNOMTEC_CITYMAPS_FRAME_SELECTMAP_DROPDOWN, self:GetName(), 0, 0)
end

-- ----------------------------------------------------------------------
-- Hook functions
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Event handler
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Addon OnInitialize, OnEnable and OnDisable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_CityMaps:OnInitialize()
 	-- Code that you want to run when the addon is first loaded goes here.
	self.db = LibStub("AceDB-3.0"):New("GnomTEC_CityMapsDB")

  	GnomTEC_CityMaps:Print("Willkommen bei GnomTEC_CityMaps")
  	  	
end

-- function called on enable of addon
function GnomTEC_CityMaps:OnEnable()
    -- Called when the addon is enabled

	GnomTEC_CityMaps:Print("GnomTEC_CityMaps Enabled")

	-- Initialize options which are propably not valid because they are new added in new versions of addon
	if (not self.db.char.displayedMap) then
		self.db.char.displayedMap = "Ironforge"			
	end
		
	-- set local parameters
	GnomTEC_CityMaps:SetMap(self.db.char.displayedMap)
	
	-- initialize hooks and events
	table.insert( msp_GnomTEC.callback.received, GnomTEC_CityMaps_MSPcallback )

	-- initialize some parts of GUI 
	GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton:HookScript("OnClick",GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton_OnClick);
	
end

-- function called on disable of addon
function GnomTEC_CityMaps:OnDisable()
    -- Called when the addon is disabled
    GnomTEC_CityMaps:UnregisterAllEvents();
    
    table.vanish( msp_GnomTEC.callback.received, GnomTEC_CityMaps_MSPcallback )
end

-- ----------------------------------------------------------------------
-- External API
-- ----------------------------------------------------------------------
