-- **********************************************************************
-- GnomTEC CityMaps
-- Version: 5.3.0.3
-- Author: GnomTEC
-- Copyright 2012-2013 by GnomTEC
-- http://www.gnomtec.de/
-- **********************************************************************
-- load localization first.
local L = LibStub("AceLocale-3.0"):GetLocale("GnomTEC_CityMaps")

-- ----------------------------------------------------------------------
-- Addon global Constants (local)
-- ----------------------------------------------------------------------

local CONST_POIICON_FREE = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_FREE"
local CONST_POIICON_NPC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_NPC"
local CONST_POIICON_USED = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_USED"
local CONST_POIICON_PUBLIC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_PUBLIC"

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
			picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\GnomTEC-Logo",
			imageCoords = {0.0,1.0,0.0,1.0},
			imageWidth = 512,
			imageHeight = 128,
		},
	}
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
	["SW_694_580"] = {
		name = "Der Silberschild",
		description = "Schildhändler",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.694,
		y = 0.580,
	},
	["SW_716_581"] = {
		name = "Stiefel des Thans",
		description = "Schusterei",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.716,
		y = 0.581,
	},
	["SW_718_634"] = {
		name = "Der schützende Balg",
		description = "Lederrüstungen",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.718,
		y = 0.634,
	},
	["SW_773_616"] = {
		name = "Begrenzte Immunität",
		description = "Kettenrüstungen",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.773,
		y = 0.616,
	},
	["SW_769_580"] = {
		name = "Ehrliche Klingen",
		description = "Klingenhändler",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.769,
		y = 0.580,
	},
	["SW_735_564"] = {
		name = "Schöne schwere Waffen",
		description = "Zweihandwaffenhändler",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.735,
		y = 0.564,
	},
	["SW_753_551"] = {
		name = "Zum Pfeifenden Schwein",
		description = "Taverne",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.753,
		y = 0.551,
	},
	["SW_738_580"] = {
		name = "Die Fünf Tödlichen Gifte",
		description = "Gifthändler",
		usedBy = "<frei>",
		localId = "--",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		zone = "Stormwind City",
		x = 0.738,
		y = 0.580,
	},
	["IF_A"] = {
		name = "Das Bankenviertel",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "A",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A",
		zone = "Ironforge",
		x = 0.305,
		y = 0.668,
	},	
	["IF_A1"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Girmodan",
		localId = "A1",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A1",
		zone = "Ironforge",
		x = 0.529,
		y = 0.885,		
	},
	["IF_A2"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Lara Feuerkabel und Orilla",
		localId = "A2",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A2",
		zone = "Ironforge",
		x = 0.496,
		y = 0.883,		
	},
 	["IF_A3"] = {
		name = "---",
		description = "Großsteinmetz Marmorstein",
		usedBy = "<frei>",
		localId = "A3",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A3",
		zone = "Ironforge",
		x = 0.388,
		y = 0.871,		
	},
 	["IF_A4"] = {
		name = "Besucherzentrum von Eisenschmiede",
		description = "Gildenmeister, Gildenhändler und Wappenröcke",
		usedBy = "<frei>",
		localId = "A4",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A4",
		zone = "Ironforge",
		x = 0.362,
		y = 0.849,		
	},	
 	["IF_A5"] = {
		name = "Auktionshaus",
		description = "Auktionatoren",
		usedBy = "<frei>",
		localId = "A5",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A5",
		zone = "Ironforge",
		x = 0.252,
		y = 0.740,		
	},	
 	["IF_A6"] = {
		name = "Barims Reagenzien",
		description = "Reagenzien",
		usedBy = "<frei>",
		localId = "A6",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A6",
		zone = "Ironforge",
		x = 0.194,
		y = 0.575,		
	},	
 	["IF_A7"] = {
		name = "Steinfeuertaverne",
		description = "Taverne",
		usedBy = "<frei>",
		localId = "A7",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A7",
		zone = "Ironforge",
		x = 0.194,
		y = 0.522,		
	},	
 	["IF_A8"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Lemu",
		localId = "A8",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A8",
		zone = "Ironforge",
		x = 0.266,
		y = 0.382,		
	},	
 	["IF_A9"] = {
		name = "Barbier",
		description = "Barbier",
		usedBy = "<frei>",
		localId = "A9",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A9",
		zone = "Ironforge",
		x = 0.262,
		y = 0.512,		
	},	
 	["IF_A10"] = {
		name = "Rüstkammer von Eisenschmiede",
		description = "Rüstungen",
		usedBy = "<frei>",
		localId = "A10",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A10",
		zone = "Ironforge",
		x = 0.321,
		y = 0.589,		
	},	
 	["IF_A11"] = {
		name = "Bank",
		description = "Bank",
		usedBy = "<frei>",
		localId = "A11",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A11",
		zone = "Ironforge",
		x = 0.349,
		y = 0.623,		
	},	
 	["IF_A12"] = {
		name = "Stahlzorns Waffenkaufhaus",
		description = "Waffenhändler",
		usedBy = "<frei>",
		localId = "A12",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A12",
		zone = "Ironforge",
		x = 0.373,
		y = 0.676,		
	},	
 	["IF_A13"] = {
		name = "Zischeldrehs Gemischtwaren",
		description = "Handwerkswaren",
		usedBy = "<frei>",
		localId = "A13",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A13",
		zone = "Ironforge",
		x = 0.386,
		y = 0.753,		
	},	
 	["IF_A14"] = {
		name = "---",
		description = "Leerer Laden",
		usedBy = "Silberbart's Kuriositäten",
		localId = "A14",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A14",
		zone = "Ironforge",
		x = 0.409,
		y = 0.767,		
	},	
 	["IF_A15"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Arom Goldbart",
		localId = "A15",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A15",
		zone = "Ironforge",
		x = 0.508,
		y = 0.783,		
	},	
	["IF_B"] = {
		name = "Das Mystikerviertel",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "B",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B",
		zone = "Ironforge",
		x = 0.310,
		y = 0.176,
	},
	["IF_B1"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Söldnerbund Dämmersturm",
		localId = "B1",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B1",
		zone = "Ironforge",
		x = 0.209,
		y = 0.272,		
	},
	["IF_B2"] = {
		name = "---",
		description = "Leerer Laden",
		usedBy = "Handelsbund von Diarmai (völkergemischt)/ Strumhämmer",
		localId = "B2",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B2",
		zone = "Ironforge",
		x = 0.199,
		y = 0.204,
	},
	["IF_B3"] = {
		name = "Der kämpfende Hexer",
		description = "Waffenhändler",
		usedBy = "<frei>",
		localId = "B3",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B3",
		zone = "Ironforge",
		x = 0.229,
		y = 0.171,
	},	
	["IF_B4"] = {
		name = "Halle der Mysterien",
		description = "Portale",
		usedBy = "<frei>",
		localId = "B4",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B4",
		zone = "Ironforge",
		x = 0.255,
		y = 0.084,
	},
	["IF_B5"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "<frei>",
		localId = "B5",
		icon = CONST_POIICON_FREE,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B5",
		zone = "Ironforge",
		x = 0.317,
		y = 0.047,
	},
	["IF_B6"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Togas",
		localId = "B6",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B6",
		zone = "Ironforge",
		x = 0.358,
		y = 0.026,
	},
	["IF_B7"] = {
		name = "Maevas mystische Bekleidung",
		description = "Robenhändlerin",
		usedBy = "<frei>",
		localId = "B7",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B7",
		zone = "Ironforge",
		x = 0.385,
		y = 0.055,
	},
	["IF_B8"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Nioni Silberstößel & Gamblin (WG)",
		localId = "B8",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B8",
		zone = "Ironforge",
		x = 0.368,
		y = 0.226,
	},
	["IF_B9"] = {
		name = "Beerlangs Reagenzien",
		description = "Reagenzien",
		usedBy = "<frei>",
		localId = "B9",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B9",
		zone = "Ironforge",
		x = 0.307,
		y = 0.277,
	},
	["IF_C"] = {
		name = "Das düstere Viertell",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "C",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C",
		zone = "Ironforge",
		x = 0.491,
		y = 0.122,
	},	
	["IF_C1"] = {
		name = "Bei Steinklinge",
		description = "Klingenhändler",
		usedBy = "<frei>",
		localId = "C1",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C1",
		zone = "Ironforge",
		x = 0.450,
		y = 0.073,
	},
	["IF_C2"] = {
		name = "Reisender Angler",
		description = "Angellehrer",
		usedBy = "<frei>",
		localId = "C2",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C2",
		zone = "Ironforge",
		x = 0.476,
		y = 0.071,
	},
	["IF_C3"] = {
		name = "---",
		description = "Hexenmeisterlehrer",
		usedBy = "Erenea Kade",
		localId = "C3",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C3",
		zone = "Ironforge",
		x = 0.503,
		y = 0.068,
	},
	["IF_C4"] = {
		name = "---",
		description = "Dämonenausbilder",
		usedBy = "Garam Siedefaust & Luzula Schwarzgrund (Wohn- & Geschäftsräume)",
		localId = "C4",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C4",
		zone = "Ironforge",
		x = 0.533,
		y = 0.068,
	},
	["IF_C5"] = {
		name = "---",
		description = "Schurkenlehrer",
		usedBy = "Breogir",
		localId = "C5",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C5",
		zone = "Ironforge",
		x = 0.518,
		y = 0.151,
	},
	["IF_D"] = {
		name = "Die Halle der Forscher",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "D",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D",
		zone = "Ironforge",
		x = 0.635,
		y = 0.258,
	},	
	["IF_D1"] = {
		name = "Bibliothek",
		description = "Bibliothek",
		usedBy = "<frei>",
		localId = "D1",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D1",
		zone = "Ironforge",
		x = 0.720,
		y = 0.158,
	},
	["IF_D2"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "<frei>",
		localId = "D2",
		icon = CONST_POIICON_FREE,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D2",
		zone = "Ironforge",
		x = 0.643,
		y = 0.356,
	},
	["IF_D3"] = {
		name = "---",
		description = "Leerer Laden",
		usedBy = "Thelsamar (Laden)",
		localId = "D3",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D3",
		zone = "Ironforge",
		x = 0.588,
		y = 0.250,
	},
	["IF_D4"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Thelsamar (Besprechungsraum)",
		localId = "D4",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D4",
		zone = "Ironforge",
		x = 0.570,
		y = 0.192,
	},
	["IF_E"] = {
		name = "Tüftlerstadt",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "E",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E",
		zone = "Ironforge",
		x = 0.698,
		y = 0.499,
	},	
	["IF_E1"] = {
		name = "---",
		description = "Leerer Laden",
		usedBy = "<frei>",
		localId = "E1",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E1",
		zone = "Ironforge",
		x = 0.740,
		y = 0.479,
	},
	["IF_E2"] = {
		name = "Sachen, die BUMM machen!",
		description = "Feuerwerksverkäufer",
		usedBy = "<frei>",
		localId = "E2",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E2",
		zone = "Ironforge",
		x = 0.734,
		y = 0.533,	
	},
	["IF_E3"] = {
		name = "Brausefitz´ Tränke und Mischgetränke",
		description = "Alchemielehrer",
		usedBy = "<frei>",
		localId = "E3",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E3",
		zone = "Ironforge",
		x = 0.666,
		y = 0.547,
	},
	["IF_E4"] = {
		name = "Gerätehandel Sprungspindel",
		description = "Ingenieurslehrer",
		usedBy = "<frei>",
		localId = "E4",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E4",
		zone = "Ironforge",
		x = 0.679,
		y = 0.435,
	},
	["IF_F"] = {
		name = "Das Militärviertel",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "F",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F",
		zone = "Ironforge",
		x = 0.627,
		y = 0.768,
	},
	["IF_F1"] = {
		name = "Goldrauschs Jagdbedarf",
		description = "Schusswaffenhändler",
		usedBy = "<frei>",
		localId = "F1",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F1",
		zone = "Ironforge",
		x = 0.723,
		y = 0.670,
	},
	["IF_F2"] = {
		name = "Bruuks Ecke",
		description = "Taverne",
		usedBy = "Glofur Taverne",
		localId = "F2",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F3",
		zone = "Ironforge",
		x = 0.722,
		y = 0.740,
	},
	["IF_F3"] = {
		name = "Halle der Waffen",
		description = "Kampfmeister und Klassenlehrer",
		usedBy = " Militär Eisenschmiede",
		localId = "F3",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F3",
		zone = "Ironforge",
		x = 0.675,
		y = 0.846,
	},
	["IF_F4"] = {
		name = "Schlachtholzwaffen",
		description = "Streitkolben&Stäbe",
		usedBy = "<frei>",
		localId = "F4",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F4",
		zone = "Ironforge",
		x = 0.617,
		y = 0.892,			
	},
	["IF_F5"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Ballasch Donnerbart ",
		localId = "F5",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F5",
		zone = "Ironforge",
		x = 0.576,
		y = 0.913,
	},
	["IF_F6"] = {
		name = "Felshelms Platten und Ketten",
		description = "Kettenrüstungen",
		usedBy = "<frei>",
		localId = "F6",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F6",
		zone = "Ironforge",
		x = 0.551,
		y = 0.885,	
	},	
	["IF_F7"] = {
		name = "---",
		description = "Leerer Laden",
		usedBy = "Donnerbarts Donnerbüchsen",
		localId = "F7",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F7",
		zone = "Ironforge",
		x = 0.590,
		y = 0.661,
	},		
	["IF_G"] = {
		name = " Die große Schmiede",
		description = "Öffentlicher Platz",
		usedBy = "<frei>",
		localId = "G",
		icon = CONST_POIICON_PUBLIC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G",
		zone = "Ironforge",
		x = 0.498,
		y = 0.449,
	},	
	["IF_G1"] = {
		name = "Botschaft der Dunkeleisen Zwerge",
		description = "Botschaft",
		usedBy = "<frei>",
		localId = "G1",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G1",
		zone = "Ironforge",
		x = 0.381,
		y = 0.458,	
	},		
	["IF_G2"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Baccùs Silberbarts",
		localId = "G2",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G2",
		zone = "Ironforge",
		x = 0.368,
		y = 0.321,	
	},
	["IF_G3"] = {
		name = "Lederwaren Feinspindel",
		description = "Lederverarbeizung",
		usedBy = "<frei>",
		localId = "G3",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G3",
		zone = "Ironforge",
		x = 0.403,
		y = 0.352,	
	},		
	["IF_G4"] = {
		name = "Tuchmacherei Steinbrauel",
		description = "Schneiderbedarf",
		usedBy = "<frei>",
		localId = "G4",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G4",
		zone = "Ironforge",
		x = 0.438,
		y = 0.296,	
	},		
	["IF_G5"] = {
		name = "Bubriks Laden",
		description = "Handwerkswaren",
		usedBy = "<frei>",
		localId = "G5",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G5",
		zone = "Ironforge",
		x = 0.467,
		y = 0.278,	
	},		
	["IF_G6"] = {
		name = "Tiefenbergbaugilde",
		description = "Bergbaulehrer",
		usedBy = "<frei>",
		localId = "G6",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G6",
		zone = "Ironforge",
		x = 0.504,
		y = 0.275,	
	},		
	["IF_G7"] = {
		name = "---",
		description = "Schamanenlehrer",
		usedBy = "<frei>",
		localId = "G7",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G7",
		zone = "Ironforge",
		x = 0.552,
		y = 0.300,	
	},		
	["IF_G8"] = {
		name = "Zum Bronzekessel",
		description = "Kochkunstlehrer",
		usedBy = "<frei>",
		localId = "G8",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G8",
		zone = "Ironforge",
		x = 0.596,
		y = 0.376,	
	},		
	["IF_G9"] = {
		name = "Arkananien Distelflaum",
		description = "Inschriftenkunde und Verzauberungskunst",
		usedBy = "<frei>",
		localId = "G9",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G9",
		zone = "Ironforge",
		x = 0.600,
		y = 0.450,	
	},		
	["IF_G10"] = {
		name = "---",
		description = "Leere Taverne",
		usedBy = "Zum brodelnden Kupferkessel",
		localId = "G10",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G10",
		zone = "Ironforge",
		x = 0.593,
		y = 0.497,	
	},
	["IF_G11"] = {
		name = "---",
		description = "Leere Wohnung",
		usedBy = "Graccas",
		localId = "G11",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G11",
		zone = "Ironforge",
		x = 0.579,
		y = 0.543,	
	},
	["IF_G12"] = {
		name = "Heiler von Eisenschmiede",
		description = "Kräuterkunde und Erste Hilfe",
		usedBy = "<frei>",
		localId = "G12",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G12",
		zone = "Ironforge",
		x = 0.553,
		y = 0.579,	
	},		
	["IF_G13"] = {
		name = "---",
		description = "Leerer Laden",
		usedBy = "Wachstube von Militär Eisenschmiede",
		localId = "G13",
		icon = CONST_POIICON_USED,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G13",
		zone = "Ironforge",
		x = 0.496,
		y = 0.612,	
	},
	["IF_G14"] = {
		name = "Der Hohe Sitz",
		description = "Der Hohe Sitz",
		usedBy = "<frei>",
		localId = "G14",
		icon = CONST_POIICON_NPC,
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G14",
		zone = "Ironforge",
		x = 0.421,
		y = 0.523,	
	},		


}

-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_CityMaps = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_CityMaps", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0")
local Tourist = LibStub("LibTourist-3.0") 

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC CityMaps Main", optionsMain)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC CityMaps Main", "GnomTEC CityMaps");

-- ----------------------------------------------------------------------
-- Local functions
-- ----------------------------------------------------------------------

-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

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
	if (id) then
		if (POI[id]) then
			GNOMTEC_CITYMAPS_FRAME_INFO:SetFrameLevel(GNOMTEC_CITYMAPS_FRAME:GetFrameLevel()+25)
			if (POI[id].y < 0.5) then 
				GNOMTEC_CITYMAPS_FRAME_INFO:SetPoint("TOP",0,-230)
			else
				GNOMTEC_CITYMAPS_FRAME_INFO:SetPoint("TOP",0,-30)
			end
			GNOMTEC_CITYMAPS_FRAME_INFO_PICTURE:SetTexture(POI[id].picture);
			GNOMTEC_CITYMAPS_FRAME_INFO_NAME:SetText(POI[id].name)
			GNOMTEC_CITYMAPS_FRAME_INFO_DESCRIPTION:SetText("|cFFFFFF80--- Engine ---|r|n"..POI[id].description.."|n|n|cFFFFFF80--- Genutzt von ---|r|n"..POI[id].usedBy)
			GNOMTEC_CITYMAPS_FRAME_INFO_LOCALID:SetText(POI[id].localId)
			GNOMTEC_CITYMAPS_FRAME_INFO:Show();
		end
	end
end

-- function called when mouse leaves the player icon on map (attached in GnomTEC_CityMaps:ShowPOI())
local function GnomTEC_CityMaps_POIFrame_OnLeave(self)
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

			local POITexture = POIFrame:CreateTexture(nil,"OVERLAY");
			POITexture:SetTexture(POI[id].icon);
			POITexture:SetAllPoints(POIFrame);
			POIFrame.texture = POITexture;
			POIFrame:SetAlpha(1.0); 
			POIFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x, y)
			POIFrame:Show();
		else
			POIFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x, y)
			POIFrame:Show();		
		end
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
	
end

-- function called on disable of addon
function GnomTEC_CityMaps:OnDisable()
    -- Called when the addon is disabled
    GnomTEC_CityMaps:UnregisterAllEvents();
end

-- ----------------------------------------------------------------------
-- External API
-- ----------------------------------------------------------------------
