-- **********************************************************************
-- GnomTEC CityMaps
-- Version: 8.2.0.28
-- Author: GnomTEC
-- Copyright 2012-2019 by GnomTEC
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

-- static data
GnomTEC_CityMaps_UsedBy = {}

-- Announcements which will flash POI icons
GnomTEC_CityMaps_Announcements = {}

-- options
GnomTEC_CityMaps_Options = {
	["ShowStaticData"] = true,
	["ShowMSPData"] = true,
	["ShowPOILabel"] = false,
}

-- ----------------------------------------------------------------------
-- Addon global Constants (local)
-- ----------------------------------------------------------------------

-- internal used version number since WoW only updates from TOC on game start
local addonVersion = "8.2.0.28"

-- addonInfo for addon registration to GnomTEC API
local addonInfo = {
	["Name"] = "GnomTEC CityMaps",
	["Version"] = addonVersion,
	["Date"] = "2019-06-26",
	["Author"] = "Peter Jack",
	["Email"] = "info@gnomtec.de",
	["Website"] = "http://www.gnomtec.de/",
	["Copyright"] = "(c)2012-2019 by GnomTEC",
}

-- GnomTEC API revision
local GNOMTEC_REVISION = 0

-- Log levels
local LOG_FATAL 	= 0
local LOG_ERROR	= 1
local LOG_WARN		= 2
local LOG_INFO 	= 3
local LOG_DEBUG 	= 4

local CONST_POIICON_FREE = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_FREE"
local CONST_POIICON_FREE_WITH_NPC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_FREE_WITH_NPC"
local CONST_POIICON_USED = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_USED"
local CONST_POIICON_USED_WITH_NPC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_USED_WITH_NPC"
local CONST_POIICON_PUBLIC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_PUBLIC"
local CONST_POIICON_GNOMTEC = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_GNOMTEC"
local CONST_POIICON_FLASH = "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POIICON_FLASH"

-- default static data (initialized with "Die Aldor" demo data)
local CONST_USEDBY_DEFAULT = {
	["Die Aldor"] = {
		["IF_A1"]="Girmodan",
		["IF_A2"]=nil,
		["IF_A3"]=nil,
		["IF_A4"]=nil,
		["IF_A5"]=nil,
		["IF_A6"]=nil,
		["IF_A7"]=nil,
		["IF_A8"]=nil,
		["IF_A9"]=nil,
		["IF_A10"]=nil,
		["IF_A11"]=nil,
		["IF_A12"]=nil,
		["IF_A13"]=nil,
		["IF_A14"]="Brabrax Erzblut",
		["IF_A15"]="Gombrin Eisenbräu",
		["IF_B1"]="Söldnerbund Dämmersturm",
		["IF_B2"]="Handelsbund von Diarmai (völkergemischt)/ Strumhämmer",
		["IF_B3"]=nil,
		["IF_B4"]=nil,
		["IF_B5"]="Bartrand Stahlhammer",
		["IF_B6"]="Togas",
		["IF_B7"]=nil,
		["IF_B8"]="Nioni Silberstößel & Gamblin (WG)",
		["IF_B9"]=nil,
		["IF_C1"]=nil,
		["IF_C2"]=nil,
		["IF_C3"]="Erenea Kade",
		["IF_C4"]="Garam Siedefaust & Luzula Schwarzgrund (Wohn- & Geschäftsräume)",
		["IF_C5"]="Breogir",
		["IF_D1"]=nil,
		["IF_D2"]="GnomTEC Niederlassung Eisenschmiede|n(Effie Flammfix)",
		["IF_D3"]="Brizzle",
		["IF_D4"]="Zum verdroschen Orc (Graccas)",
		["IF_E1"]=nil,
		["IF_E2"]=nil,
		["IF_E3"]=nil,
		["IF_E4"]=nil,
		["IF_F1"]=nil,
		["IF_F2"]="Pension",
		["IF_F3"]=" Militär Eisenschmiede",
		["IF_F4"]=nil,
		["IF_F5"]="Ballasch Donnerbart",
		["IF_F6"]=nil,
		["IF_F7"]="Donnerbarts Donnerbüchsen",
		["IF_G1"]=nil,
		["IF_G2"]="Soillona",
		["IF_G3"]=nil,
		["IF_G4"]=nil,
		["IF_G5"]=nil,
		["IF_G6"]=nil,
		["IF_G7"]="Lorimbur Stahlhammer",
		["IF_G8"]=nil,
		["IF_G9"]=nil,
		["IF_G10"]="Zum brodelnden Kupferkessel",
		["IF_G11"]="Graccas",
		["IF_G12"]=nil,
		["IF_G13"]="Wachstube von Militär Eisenschmiede",
		["IF_G14"]=nil,
	},
}
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
			name = L["L_OPTIONS_TITLE"],
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
				name = "|cffffd700".."Version"..": ".._G["GREEN_FONT_COLOR_CODE"]..addonInfo["Version"],
				},
				descriptionAuthor = {
					order = 2,
					type = "description",
					name = "|cffffd700".."Author"..": ".."|cffff8c00"..addonInfo["Author"],
				},
				descriptionEmail = {
					order = 3,
					type = "description",
					name = "|cffffd700".."Email"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..addonInfo["Email"],
				},
				descriptionWebsite = {
					order = 4,
					type = "description",
					name = "|cffffd700".."Website"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..addonInfo["Website"],
				},
				descriptionLicense = {
					order = 5,
					type = "description",
					name = "|cffffd700".."Copyright"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..addonInfo["Copyright"],
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
		cityMapsOptionShowPOILabel = {
			type = "toggle",
			name = L["L_OPTIONS_VIEW_SHOWPOILABEL"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps_Options["ShowPOILabel"] = val;GnomTEC_CityMaps:SetMap(GnomTEC_CityMaps.db.char.displayedMap) end,
	   	get = function(info) return GnomTEC_CityMaps_Options["ShowPOILabel"] end,
			width = 'full',
			order = 3
		},
	},
}

local optionsData = {
	name = L["L_OPTIONS_DATA"].." (Realm: "..GetRealmName()..")",
	type = 'group',
	args = {
		cityMapsOptionDataIronforgeDefault = {
			type = "toggle",
			name = L["L_OPTIONS_DATA_IRONFORGE_DEFAULT"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps:SetStaticDataIsDefault(GetRealmName(),"Ironforge",val) end,
	   	get = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Ironforge") end,
			width = 'full',
			order = 1
		},		
		CityMapsOptionDataIronforge = {
			type = "input",
			name = L["L_OPTIONS_DATA_IRONFORGE"],
			desc = "",
			disabled = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Ironforge") end,
			set = function(info,val) GnomTEC_CityMaps:ImportStaticData(GetRealmName(),"Ironforge",val) end,
    		get = function(info) return GnomTEC_CityMaps:ExportStaticData(GetRealmName(),"Ironforge") end,
			multiline = 10,
			width = 'full',
			order = 2
		},
		cityMapsOptionDataStormwindDefault = {
			type = "toggle",
			name = L["L_OPTIONS_DATA_STORMWIND_DEFAULT"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps:SetStaticDataIsDefault(GetRealmName(),"Stormwind",val) end,
	   	get = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Stormwind") end,
			width = 'full',
			order = 3
		},		
		CityMapsOptionDataStormwind = {
			type = "input",
			name = L["L_OPTIONS_DATA_STORMWIND"],
			desc = "",
			disabled = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Stormwind") end,
			set = function(info,val) GnomTEC_CityMaps:ImportStaticData(GetRealmName(),"Stormwind",val) end,
    		get = function(info) return GnomTEC_CityMaps:ExportStaticData(GetRealmName(),"Stormwind") end,
			multiline = 10,
			width = 'full',
			order = 4
		},
		cityMapsOptionDataDarnassusDefault = {
			type = "toggle",
			name = L["L_OPTIONS_DATA_DARNASSUS_DEFAULT"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps:SetStaticDataIsDefault(GetRealmName(),"Darnassus",val) end,
	   	get = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Darnassus") end,
			width = 'full',
			order = 5
		},		
		CityMapsOptionDataDarnassus = {
			type = "input",
			name = L["L_OPTIONS_DATA_DARNASSUS"],
			desc = "",
			disabled = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Darnassus") end,
			set = function(info,val) GnomTEC_CityMaps:ImportStaticData(GetRealmName(),"Darnassus",val) end,
    		get = function(info) return GnomTEC_CityMaps:ExportStaticData(GetRealmName(),"Darnassus") end,
			multiline = 10,
			width = 'full',
			order = 6
		},
		cityMapsOptionDataDalaranDefault = {
			type = "toggle",
			name = L["L_OPTIONS_DATA_DALARAN_DEFAULT"],
			desc = "",
			set = function(info,val) GnomTEC_CityMaps:SetStaticDataIsDefault(GetRealmName(),"Dalaran",val) end,
	   	get = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Dalaran") end,
			width = 'full',
			order = 7
		},		
		CityMapsOptionDataDalaran = {
			type = "input",
			name = L["L_OPTIONS_DATA_DALARAN"],
			desc = "",
			disabled = function(info) return GnomTEC_CityMaps:GetStaticDataIsDefault(GetRealmName(),"Dalaran") end,
			set = function(info,val) GnomTEC_CityMaps:ImportStaticData(GetRealmName(),"Dalaran",val) end,
    		get = function(info) return GnomTEC_CityMaps:ExportStaticData(GetRealmName(),"Dalaran") end,
			multiline = 10,
			width = 'full',
			order = 8
		},
	},
}



-- maps which are supported by addon
local availableMaps = {
	["Ironforge"] = {
		text = L["L_IRONFORGE"],
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
	["Stormwind City"] = {
		text = L["L_STORMWIND"],
		notCheckable = 1,
		func = function () GnomTEC_CityMaps:SetMap("Stormwind City"); end,	
		map1 = "Interface\\WorldMap\\StormwindCity\\StormwindCity1",
		map2 = "Interface\\WorldMap\\StormwindCity\\StormwindCity2",
		map3 = "Interface\\WorldMap\\StormwindCity\\StormwindCity3",
		map4 = "Interface\\WorldMap\\StormwindCity\\StormwindCity4",
		map5 = "Interface\\WorldMap\\StormwindCity\\StormwindCity5",
		map6 = "Interface\\WorldMap\\StormwindCity\\StormwindCity6",
		map7 = "Interface\\WorldMap\\StormwindCity\\StormwindCity7",
		map8 = "Interface\\WorldMap\\StormwindCity\\StormwindCity8",
		map9 = "Interface\\WorldMap\\StormwindCity\\StormwindCity9",
		map10 = "Interface\\WorldMap\\StormwindCity\\StormwindCity10",
		map11 = "Interface\\WorldMap\\StormwindCity\\StormwindCity11",
		map12 = "Interface\\WorldMap\\StormwindCity\\StormwindCity12"
	},
	["Darnassus"] = {
		text = L["L_DARNASSUS"],
		notCheckable = 1,
		func = function () GnomTEC_CityMaps:SetMap("Darnassus"); end,	
		map1 = "Interface\\WorldMap\\Darnassus\\Darnassus1",
		map2 = "Interface\\WorldMap\\Darnassus\\Darnassus2",
		map3 = "Interface\\WorldMap\\Darnassus\\Darnassus3",
		map4 = "Interface\\WorldMap\\Darnassus\\Darnassus4",
		map5 = "Interface\\WorldMap\\Darnassus\\Darnassus5",
		map6 = "Interface\\WorldMap\\Darnassus\\Darnassus6",
		map7 = "Interface\\WorldMap\\Darnassus\\Darnassus7",
		map8 = "Interface\\WorldMap\\Darnassus\\Darnassus8",
		map9 = "Interface\\WorldMap\\Darnassus\\Darnassus9",
		map10 = "Interface\\WorldMap\\Darnassus\\Darnassus10",
		map11 = "Interface\\WorldMap\\Darnassus\\Darnassus11",
		map12 = "Interface\\WorldMap\\Darnassus\\Darnassus12"
	},
	["Dalaran"] = {
		text = L["L_DALARAN"],
		notCheckable = 1,
		func = function () GnomTEC_CityMaps:SetMap("Dalaran"); end,	
		map1 = "Interface\\WorldMap\\Dalaran\\Dalaran1_1",
		map2 = "Interface\\WorldMap\\Dalaran\\Dalaran1_2",
		map3 = "Interface\\WorldMap\\Dalaran\\Dalaran1_3",
		map4 = "Interface\\WorldMap\\Dalaran\\Dalaran1_4",
		map5 = "Interface\\WorldMap\\Dalaran\\Dalaran1_5",
		map6 = "Interface\\WorldMap\\Dalaran\\Dalaran1_6",
		map7 = "Interface\\WorldMap\\Dalaran\\Dalaran1_7",
		map8 = "Interface\\WorldMap\\Dalaran\\Dalaran1_8",
		map9 = "Interface\\WorldMap\\Dalaran\\Dalaran1_9",
		map10 = "Interface\\WorldMap\\Dalaran\\Dalaran1_10",
		map11 = "Interface\\WorldMap\\Dalaran\\Dalaran1_11",
		map12 = "Interface\\WorldMap\\Dalaran\\Dalaran1_12"
	},
}

-- Last time when a timer event was triggerd
local lastTimerEvent = GetTime()

-- List of POIs
local POI = {
	["IF_A"] = {
		name = L["L_IF_A_NAME"],
		description = L["L_IF_A_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A",
		localId = "A",
		zone = "Ironforge",
		x = 0.311,
		y = 0.662,
		npc = true,
		public = true,
	},	
	["IF_A1"] = {
		name = L["L_IF_A1_NAME"],
		description = L["L_IF_A1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A1",
		localId = "A1",
		zone = "Ironforge",
		x = 0.527,
		y = 0.864,		
		npc = nil,
		public = nil,
	},
	["IF_A2"] = {
		name = L["L_IF_A2_NAME"],
		description = L["L_IF_A2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A2",
		localId = "A2",
		zone = "Ironforge",
		x = 0.496,
		y = 0.883,		
		npc = nil,
		public = nil,
	},
 	["IF_A3"] = {
		name = L["L_IF_A3_NAME"],
		description = L["L_IF_A3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A3",
		localId = "A3",
		zone = "Ironforge",
		x = 0.388,
		y = 0.871,		
		npc = true,
		public = nil,
	},
 	["IF_A4"] = {
		name = L["L_IF_A4_NAME"],
		description = L["L_IF_A4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A4",
		localId = "A4",
		zone = "Ironforge",
		x = 0.362,
		y = 0.849,		
		npc = true,
		public = nil,
	},	
 	["IF_A5"] = {
		name = L["L_IF_A5_NAME"],
		description = L["L_IF_A5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A5",
		localId = "A5",
		zone = "Ironforge",
		x = 0.252,
		y = 0.740,		
		npc = true,
		public = nil,
	},	
 	["IF_A6"] = {
		name = L["L_IF_A6_NAME"],
		description = L["L_IF_A6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A6",
		localId = "A6",
		zone = "Ironforge",
		x = 0.201,
		y = 0.566,		
		npc = true,
		public = nil,
	},	
 	["IF_A7"] = {
		name = L["L_IF_A7_NAME"],
		description = L["L_IF_A7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A7",
		localId = "A7",
		zone = "Ironforge",
		x = 0.194,
		y = 0.522,		
		npc = true,
		public = nil,
	},	
 	["IF_A8"] = {
		name = L["L_IF_A8_NAME"],
		description = L["L_IF_A8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A8",
		localId = "A8",
		zone = "Ironforge",
		x = 0.266,
		y = 0.382,		
		npc = nil,
		public = nil,
	},	
 	["IF_A9"] = {
		name = L["L_IF_A9_NAME"],
		description = L["L_IF_A9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A9",
		localId = "A9",
		zone = "Ironforge",
		x = 0.262,
		y = 0.512,		
		npc = true,
		public = nil,
	},	
 	["IF_A10"] = {
		name = L["L_IF_A10_NAME"],
		description = L["L_IF_A10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A10",
		localId = "A10",
		zone = "Ironforge",
		x = 0.321,
		y = 0.589,		
		npc = true,
		public = nil,
	},	
 	["IF_A11"] = {
		name = L["L_IF_A11_NAME"],
		description = L["L_IF_A11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A11",
		localId = "A11",
		zone = "Ironforge",
		x = 0.349,
		y = 0.623,		
		npc = true,
		public = nil,
	},	
 	["IF_A12"] = {
		name = L["L_IF_A12_NAME"],
		description = L["L_IF_A12_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A12",
		localId = "A12",
		zone = "Ironforge",
		x = 0.362,
		y = 0.668,		
		npc = true,
		public = nil,
	},	
 	["IF_A13"] = {
		name = L["L_IF_A13_NAME"],
		description = L["L_IF_A13_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A13",
		localId = "A13",
		zone = "Ironforge",
		x = 0.386,
		y = 0.753,		
		npc = true,
		public = nil,
	},	
 	["IF_A14"] = {
		name = L["L_IF_A14_NAME"],
		description = L["L_IF_A14_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A14",
		localId = "A14",
		zone = "Ironforge",
		x = 0.409,
		y = 0.767,		
		npc = nil,
		public = nil,
	},	
 	["IF_A15"] = {
		name = L["L_IF_A15_NAME"],
		description = L["L_IF_A15_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_A15",
		localId = "A15",
		zone = "Ironforge",
		x = 0.508,
		y = 0.783,		
		npc = nil,
		public = nil,
	},	
	["IF_B"] = {
		name = L["L_IF_B_NAME"],
		description = L["L_IF_B_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B",
		localId = "B",
		zone = "Ironforge",
		x = 0.310,
		y = 0.176,
		npc = true,
		public = true,
	},
	["IF_B1"] = {
		name = L["L_IF_B1_NAME"],
		description = L["L_IF_B1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B1",
		localId = "B1",
		zone = "Ironforge",
		x = 0.209,
		y = 0.272,		
		npc = nil,
		public = nil,
	},
	["IF_B2"] = {
		name = L["L_IF_B2_NAME"],
		description = L["L_IF_B2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B2",
		localId = "B2",
		zone = "Ironforge",
		x = 0.199,
		y = 0.204,
		npc = nil,
		public = nil,
	},
	["IF_B3"] = {
		name = L["L_IF_B3_NAME"],
		description = L["L_IF_B3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B3",
		localId = "B3",
		zone = "Ironforge",
		x = 0.229,
		y = 0.171,
		npc = true,
		public = nil,
	},	
	["IF_B4"] = {
		name = L["L_IF_B4_NAME"],
		description = L["L_IF_B4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B4",
		localId = "B4",
		zone = "Ironforge",
		x = 0.255,
		y = 0.084,
		npc = true,
		public = nil,
	},
	["IF_B5"] = {
		name = L["L_IF_B5_NAME"],
		description = L["L_IF_B5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B5",
		localId = "B5",
		zone = "Ironforge",
		x = 0.317,
		y = 0.047,
		npc = nil,
		public = nil,
	},
	["IF_B6"] = {
		name = L["L_IF_B6_NAME"],
		description = L["L_IF_B6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B6",
		localId = "B6",
		zone = "Ironforge",
		x = 0.358,
		y = 0.026,
		npc = nil,
		public = nil,
	},
	["IF_B7"] = {
		name = L["L_IF_B7_NAME"],
		description = L["L_IF_B7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B7",
		localId = "B7",
		zone = "Ironforge",
		x = 0.385,
		y = 0.055,
		npc = true,
		public = nil,
	},
	["IF_B8"] = {
		name = L["L_IF_B8_NAME"],
		description = L["L_IF_B8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B8",
		localId = "B8",
		zone = "Ironforge",
		x = 0.368,
		y = 0.226,
		npc = nil,
		public = nil,
	},
	["IF_B9"] = {
		name = L["L_IF_B9_NAME"],
		description = L["L_IF_B9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_B9",
		localId = "B9",
		zone = "Ironforge",
		x = 0.307,
		y = 0.277,
		npc = true,
		public = nil,
	},
	["IF_C"] = {
		name = L["L_IF_C_NAME"],
		description = L["L_IF_C_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C",
		localId = "C",
		zone = "Ironforge",
		x = 0.491,
		y = 0.122,
		npc = true,
		public = true,
	},	
	["IF_C1"] = {
		name = L["L_IF_C1_NAME"],
		description = L["L_IF_C1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C1",
		localId = "C1",
		zone = "Ironforge",
		x = 0.450,
		y = 0.073,
		npc = true,
		public = nil,
	},
	["IF_C2"] = {
		name = L["L_IF_C2_NAME"],
		description = L["L_IF_C2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C2",
		localId = "C2",
		zone = "Ironforge",
		x = 0.476,
		y = 0.071,
		npc = true,
		public = nil,
	},
	["IF_C3"] = {
		name = L["L_IF_C3_NAME"],
		description = L["L_IF_C3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C3",
		localId = "C3",
		zone = "Ironforge",
		x = 0.503,
		y = 0.068,
		npc = true,
		public = nil,
	},
	["IF_C4"] = {
		name = L["L_IF_C4_NAME"],
		description = L["L_IF_C4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C4",
		localId = "C4",
		zone = "Ironforge",
		x = 0.533,
		y = 0.068,
		npc = true,
		public = nil,
	},
	["IF_C5"] = {
		name = L["L_IF_C5_NAME"],
		description = L["L_IF_C5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_C5",
		localId = "C5",
		zone = "Ironforge",
		x = 0.518,
		y = 0.151,
		npc = true,
		public = nil,
	},
	["IF_D"] = {
		name = L["L_IF_D_NAME"],
		description = L["L_IF_D_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D",
		localId = "D",
		zone = "Ironforge",
		x = 0.635,
		y = 0.258,
		npc = true,
		public = true,
	},	
	["IF_D1"] = {
		name = L["L_IF_D1_NAME"],
		description = L["L_IF_D1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D1",
		localId = "D1",
		zone = "Ironforge",
		x = 0.720,
		y = 0.158,
		npc = true,
		public = nil,
	},
	["IF_D2"] = {
		name = L["L_IF_D2_NAME"],
		description = L["L_IF_D2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D2",
		localId = "D2",
		zone = "Ironforge",
		x = 0.643,
		y = 0.356,
		npc = nil,
		public = nil,
	},
	["IF_D3"] = {
		name = L["L_IF_D3_NAME"],
		description = L["L_IF_D3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D3",
		localId = "D3",
		zone = "Ironforge",
		x = 0.588,
		y = 0.250,
		npc = nil,
		public = nil,
	},
	["IF_D4"] = {
		name = L["L_IF_D4_NAME"],
		description = L["L_IF_D4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_D4",
		localId = "D4",
		zone = "Ironforge",
		x = 0.570,
		y = 0.192,
		npc = nil,
		public = nil,
	},
	["IF_E"] = {
		name = L["L_IF_E_NAME"],
		description = L["L_IF_E_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E",
		localId = "E",
		zone = "Ironforge",
		x = 0.698,
		y = 0.499,
		npc = true,
		public = true,
	},	
	["IF_E1"] = {
		name = L["L_IF_E1_NAME"],
		description = L["L_IF_E1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E1",
		localId = "E1",
		zone = "Ironforge",
		x = 0.740,
		y = 0.479,
		npc = nil,
		public = nil,
	},
	["IF_E2"] = {
		name = L["L_IF_E2_NAME"],
		description = L["L_IF_E2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E2",
		localId = "E2",
		zone = "Ironforge",
		x = 0.734,
		y = 0.533,	
		npc = true,
		public = nil,
	},
	["IF_E3"] = {
		name = L["L_IF_E3_NAME"],
		description = L["L_IF_E3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E3",
		localId = "E3",
		zone = "Ironforge",
		x = 0.666,
		y = 0.547,
		npc = true,
		public = nil,
	},
	["IF_E4"] = {
		name = L["L_IF_E4_NAME"],
		description = L["L_IF_E4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_E4",
		localId = "E4",
		zone = "Ironforge",
		x = 0.679,
		y = 0.435,
		npc = true,
		public = nil,
	},
	["IF_F"] = {
		name = L["L_IF_F_NAME"],
		description = L["L_IF_F_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F",
		localId = "F",
		zone = "Ironforge",
		x = 0.627,
		y = 0.768,
		npc = true,
		public = true,
	},
	["IF_F1"] = {
		name = L["L_IF_F1_NAME"],
		description = L["L_IF_F1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F1",
		localId = "F1",
		zone = "Ironforge",
		x = 0.723,
		y = 0.670,
		npc = true,
		public = nil,
	},
	["IF_F2"] = {
		name = L["L_IF_F2_NAME"],
		description = L["L_IF_F2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F2",
		localId = "F2",
		zone = "Ironforge",
		x = 0.722,
		y = 0.740,
		npc = true,
		public = nil,
	},
	["IF_F3"] = {
		name = L["L_IF_F3_NAME"],
		description = L["L_IF_F3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F3",
		localId = "F3",
		zone = "Ironforge",
		x = 0.675,
		y = 0.846,
		npc = true,
		public = nil,
	},
	["IF_F4"] = {
		name = L["L_IF_F4_NAME"],
		description = L["L_IF_F4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F4",
		localId = "F4",
		zone = "Ironforge",
		x = 0.617,
		y = 0.892,			
		npc = true,
		public = nil,
	},
	["IF_F5"] = {
		name = L["L_IF_F5_NAME"],
		description = L["L_IF_F5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F5",
		localId = "F5",
		zone = "Ironforge",
		x = 0.575,
		y = 0.905,
		npc = nil,
		public = nil,
	},
	["IF_F6"] = {
		name = L["L_IF_F6_NAME"],
		description = L["L_IF_F6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F6",
		localId = "F6",
		zone = "Ironforge",
		x = 0.551,
		y = 0.885,	
		npc = true,
		public = nil,
	},	
	["IF_F7"] = {
		name = L["L_IF_F7_NAME"],
		description = L["L_IF_F7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_F7",
		localId = "F7",
		zone = "Ironforge",
		x = 0.590,
		y = 0.661,
		npc = nil,
		public = nil,
	},		
	["IF_G"] = {
		name = L["L_IF_G_NAME"],
		description = L["L_IF_G_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G",
		localId = "G",
		zone = "Ironforge",
		x = 0.498,
		y = 0.449,
		npc = true,
		public = true,
	},	
	["IF_G1"] = {
		name = L["L_IF_G1_NAME"],
		description = L["L_IF_G1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G1",
		localId = "G1",
		zone = "Ironforge",
		x = 0.381,
		y = 0.458,	
		npc = true,
		public = nil,
	},		
	["IF_G2"] = {
		name = L["L_IF_G2_NAME"],
		description = L["L_IF_G2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G2",
		localId = "G2",
		zone = "Ironforge",
		x = 0.368,
		y = 0.321,	
		npc = nil,
		public = nil,
	},
	["IF_G3"] = {
		name = L["L_IF_G3_NAME"],
		description = L["L_IF_G3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G3",
		localId = "G3",
		zone = "Ironforge",
		x = 0.403,
		y = 0.352,	
		npc = true,
		public = nil,
	},		
	["IF_G4"] = {
		name = L["L_IF_G4_NAME"],
		description = L["L_IF_G4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G4",
		localId = "G4",
		zone = "Ironforge",
		x = 0.438,
		y = 0.296,	
		npc = true,
		public = nil,
	},		
	["IF_G5"] = {
		name = L["L_IF_G5_NAME"],
		description = L["L_IF_G5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G5",
		localId = "G5",
		zone = "Ironforge",
		x = 0.467,
		y = 0.278,	
		npc = true,
		public = nil,
	},		
	["IF_G6"] = {
		name = L["L_IF_G6_NAME"],
		description = L["L_IF_G6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G6",
		localId = "G6",
		zone = "Ironforge",
		x = 0.504,
		y = 0.275,	
		npc = true,
		public = nil,
	},		
	["IF_G7"] = {
		name = L["L_IF_G7_NAME"],
		description = L["L_IF_G7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G7",
		localId = "G7",
		zone = "Ironforge",
		x = 0.552,
		y = 0.300,	
		npc = true,
		public = nil,
	},		
	["IF_G8"] = {
		name = L["L_IF_G8_NAME"],
		description = L["L_IF_G8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G8",
		localId = "G8",
		zone = "Ironforge",
		x = 0.596,
		y = 0.376,	
		npc = true,
		public = nil,
	},		
	["IF_G9"] = {
		name = L["L_IF_G9_NAME"],
		description = L["L_IF_G9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G9",
		localId = "G9",
		zone = "Ironforge",
		x = 0.600,
		y = 0.450,	
		npc = true,
		public = nil,
	},		
	["IF_G10"] = {
		name = L["L_IF_G10_NAME"],
		description = L["L_IF_G10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G10",
		localId = "G10",
		zone = "Ironforge",
		x = 0.593,
		y = 0.497,	
		npc = nil,
		public = nil,
	},
	["IF_G11"] = {
		name = L["L_IF_G11_NAME"],
		description = L["L_IF_G11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G11",
		localId = "G11",
		zone = "Ironforge",
		x = 0.579,
		y = 0.543,	
		npc = nil,
		public = nil,
	},
	["IF_G12"] = {
		name = L["L_IF_G12_NAME"],
		description = L["L_IF_G12_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G12",
		localId = "G12",
		zone = "Ironforge",
		x = 0.553,
		y = 0.579,	
		npc = true,
		public = nil,
	},		
	["IF_G13"] = {
		name = L["L_IF_G13_NAME"],
		description = L["L_IF_G13_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G13",
		localId = "G13",
		zone = "Ironforge",
		x = 0.465,
		y = 0.600,	
		npc = nil,
		public = nil,
	},
	["IF_G14"] = {
		name = L["L_IF_G14_NAME"],
		description = L["L_IF_G14_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_IF_G14",
		localId = "G14",
		zone = "Ironforge",
		x = 0.421,
		y = 0.523,	
		npc = true,
		public = nil,
	},	
	["SW_A"] = {
		name = L["L_SW_A_NAME"],
		description = L["L_SW_A_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A",
		zone = "Stormwind City",
		x = 0.528,
		y = 0.555,
		npc = true,
		public = true,
	},	
	["SW_A1"] = {
		name = L["L_SW_A1_NAME"],
		description = L["L_SW_A1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A1",
		zone = "Stormwind City",
		x = 0.528,
		y = 0.508,		
		npc = true,
		public = nil,
	},
	["SW_A2"] = {
		name = L["L_SW_A2_NAME"],
		description = L["L_SW_A2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A2",
		zone = "Stormwind City",
		x = 0.568,
		y = 0.470,		
		npc = true,
		public = nil,
	},
	["SW_A3"] = {
		name = L["L_SW_A3_NAME"],
		description = L["L_SW_A3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A3",
		zone = "Stormwind City",
		x = 0.578,
		y = 0.494,		
		npc = nil,
		public = nil,
	},
	["SW_A4"] = {
		name = L["L_SW_A4_NAME"],
		description = L["L_SW_A4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A4",
		zone = "Stormwind City",
		x = 0.564,
		y = 0.533,		
		npc = true,
		public = nil,
	},
	["SW_A5"] = {
		name = L["L_SW_A5_NAME"],
		description = L["L_SW_A5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A5",
		zone = "Stormwind City",
		x = 0.537,
		y = 0.600,		
		npc = true,
		public = nil,
	},
	["SW_A6"] = {
		name = L["L_SW_A6_NAME"],
		description = L["L_SW_A6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A6",
		zone = "Stormwind City",
		x = 0.489,
		y = 0.550,		
		npc = true,
		public = nil,
	},
	["SW_A7"] = {
		name = L["L_SW_A7_NAME"],
		description = L["L_SW_A7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A7",
		zone = "Stormwind City",
		x = 0.603,
		y = 0.568,		
		npc = true,
		public = nil,
	},
	["SW_A8"] = {
		name = L["L_SW_A8_NAME"],
		description = L["L_SW_A8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A8",
		zone = "Stormwind City",
		x = 0.527,
		y = 0.630,		
		npc = nil,
		public = nil,
	},
	["SW_A9"] = {
		name = L["L_SW_A9_NAME"],
		description = L["L_SW_A9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A9",
		zone = "Stormwind City",
		x = 0.503,
		y = 0.614,		
		npc = true,
		public = nil,
	},
	["SW_B"] = {
		name = L["L_SW_B_NAME"],
		description = L["L_SW_B_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B",
		zone = "Stormwind City",
		x = 0.631,
		y = 0.339,
		npc = true,
		public = true,
	},	
	["SW_B1"] = {
		name = L["L_SW_B1_NAME"],
		description = L["L_SW_B1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B1",
		zone = "Stormwind City",
		x = 0.590,
		y = 0.369,		
		npc = true,
		public = nil,
	},
	["SW_B2"] = {
		name = L["L_SW_B2_NAME"],
		description = L["L_SW_B2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B2",
		zone = "Stormwind City",
		x = 0.590,
		y = 0.335,		
		npc = true,
		public = nil,
	},
	["SW_B3"] = {
		name = L["L_SW_B3_NAME"],
		description = L["L_SW_B3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B3",
		zone = "Stormwind City",
		x = 0.616,
		y = 0.357,		
		npc = true,
		public = nil,
	},
	["SW_B4"] = {
		name = L["L_SW_B4_NAME"],
		description = L["L_SW_B4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B4",
		zone = "Stormwind City",
		x = 0.613,
		y = 0.318,		
		npc = true,
		public = nil,
	},
	["SW_B5"] = {
		name = L["L_SW_B5_NAME"],
		description = L["L_SW_B5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B5",
		zone = "Stormwind City",
		x = 0.639,
		y = 0.295,		
		npc = true,
		public = nil,
	},
	["SW_B6"] = {
		name = L["L_SW_B6_NAME"],
		description = L["L_SW_B6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B6",
		zone = "Stormwind City",
		x = 0.650,
		y = 0.329,		
		npc = true,
		public = nil,
	},
	["SW_B7"] = {
		name = L["L_SW_B7_NAME"],
		description = L["L_SW_B7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B7",
		zone = "Stormwind City",
		x = 0.672,
		y = 0.372,		
		npc = true,
		public = nil,
	},
	["SW_B8"] = {
		name = L["L_SW_B8_NAME"],
		description = L["L_SW_B8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B8",
		zone = "Stormwind City",
		x = 0.650,
		y = 0.495,		
		npc = true,
		public = nil,
	},
	["SW_B9"] = {
		name = L["L_SW_B9_NAME"],
		description = L["L_SW_B9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B9",
		zone = "Stormwind City",
		x = 0.637,
		y = 0.474,		
		npc = true,
		public = nil,
	},
	["SW_B10"] = {
		name = L["L_SW_B10_NAME"],
		description = L["L_SW_B10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B10",
		zone = "Stormwind City",
		x = 0.669,
		y = 0.466,		
		npc = true,
		public = nil,
	},
	["SW_C"] = {
		name = L["L_SW_C_NAME"],
		description = L["L_SW_C_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C",
		zone = "Stormwind City",
		x = 0.751,
		y = 0.628,
		npc = true,
		public = true,
	},	
	["SW_C1"] = {
		name = L["L_SW_C1_NAME"],
		description = L["L_SW_C1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C1",
		zone = "Stormwind City",
		x = 0.753,
		y = 0.550,		
		npc = true,
		public = nil,
	},
	["SW_C2"] = {
		name = L["L_SW_C2_NAME"],
		description = L["L_SW_C2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C2",
		zone = "Stormwind City",
		x = 0.736,
		y = 0.568,		
		npc = true,
		public = nil,
	},
	["SW_C3"] = {
		name = L["L_SW_C3_NAME"],
		description = L["L_SW_C3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C3",
		zone = "Stormwind City",
		x = 0.738,
		y = 0.590,		
		npc = true,
		public = nil,
	},
	["SW_C4"] = {
		name = L["L_SW_C4_NAME"],
		description = L["L_SW_C4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C4",
		zone = "Stormwind City",
		x = 0.767,
		y = 0.581,		
		npc = true,
		public = nil,
	},
	["SW_C5"] = {
		name = L["L_SW_C5_NAME"],
		description = L["L_SW_C5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C5",
		zone = "Stormwind City",
		x = 0.767,
		y = 0.613,		
		npc = true,
		public = nil,
	},
	["SW_C6"] = {
		name = L["L_SW_C6_NAME"],
		description = L["L_SW_C6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C6",
		zone = "Stormwind City",
		x = 0.802,
		y = 0.624,		
		npc = true,
		public = nil,
	},
	["SW_C7"] = {
		name = L["L_SW_C7_NAME"],
		description = L["L_SW_C7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C7",
		zone = "Stormwind City",
		x = 0.798,
		y = 0.694,		
		npc = true,
		public = nil,
	},
	["SW_C8"] = {
		name = L["L_SW_C8_NAME"],
		description = L["L_SW_C8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C8",
		zone = "Stormwind City",
		x = 0.758,
		y = 0.665,		
		npc = true,
		public = nil,
	},
	["SW_C9"] = {
		name = L["L_SW_C9_NAME"],
		description = L["L_SW_C9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C9",
		zone = "Stormwind City",
		x = 0.727,
		y = 0.628,		
		npc = true,
		public = nil,
	},
	["SW_C10"] = {
		name = L["L_SW_C10_NAME"],
		description = L["L_SW_C10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C10",
		zone = "Stormwind City",
		x = 0.713,
		y = 0.580,		
		npc = true,
		public = nil,
	},
	["SW_C11"] = {
		name = L["L_SW_C11_NAME"],
		description = L["L_SW_C11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C11",
		zone = "Stormwind City",
		x = 0.699,
		y = 0.579,		
		npc = true,
		public = nil,
	},
	["SW_D"] = {
		name = L["L_SW_D_NAME"],
		description = L["L_SW_D_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D",
		zone = "Stormwind City",
		x = 0.630,
		y = 0.712,
		npc = true,
		public = true,
	},	
	["SW_D1"] = {
		name = L["L_SW_D1_NAME"],
		description = L["L_SW_D1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D1",
		zone = "Stormwind City",
		x = 0.645,
		y = 0.773,		
		npc = true,
		public = nil,
	},
	["SW_D2"] = {
		name = L["L_SW_D2_NAME"],
		description = L["L_SW_D2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D2",
		zone = "Stormwind City",
		x = 0.633,
		y = 0.746,		
		npc = true,
		public = nil,
	},
	["SW_D3"] = {
		name = L["L_SW_D3_NAME"],
		description = L["L_SW_D3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D3",
		zone = "Stormwind City",
		x = 0.616,
		y = 0.723,		
		npc = true,
		public = nil,
	},
	["SW_D4"] = {
		name = L["L_SW_D4_NAME"],
		description = L["L_SW_D4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D4",
		zone = "Stormwind City",
		x = 0.624,
		y = 0.676,		
		npc = true,
		public = nil,
	},
	["SW_D5"] = {
		name = L["L_SW_D5_NAME"],
		description = L["L_SW_D5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D5",
		zone = "Stormwind City",
		x = 0.636,
		y = 0.690,		
		npc = true,
		public = nil,
	},
	["SW_D6"] = {
		name = L["L_SW_D6_NAME"],
		description = L["L_SW_D6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D6",
		zone = "Stormwind City",
		x = 0.643,
		y = 0.719,		
		npc = true,
		public = nil,
	},
	["SW_D7"] = {
		name = L["L_SW_D7_NAME"],
		description = L["L_SW_D7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D7",
		zone = "Stormwind City",
		x = 0.665,
		y = 0.747,		
		npc = true,
		public = nil,
	},
	["SW_D8"] = {
		name = L["L_SW_D8_NAME"],
		description = L["L_SW_D8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D8",
		zone = "Stormwind City",
		x = 0.625,
		y = 0.773,		
		npc = true,
		public = nil,
	},
	["SW_D9"] = {
		name = L["L_SW_D9_NAME"],
		description = L["L_SW_D9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D9",
		zone = "Stormwind City",
		x = 0.609,
		y = 0.748,		
		npc = true,
		public = nil,
	},
	["SW_D10"] = {
		name = L["L_SW_D10_NAME"],
		description = L["L_SW_D10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D10",
		zone = "Stormwind City",
		x = 0.590,
		y = 0.692,		
		npc = true,
		public = nil,
	},
	["SW_D11"] = {
		name = L["L_SW_D11_NAME"],
		description = L["L_SW_D11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D11",
		zone = "Stormwind City",
		x = 0.613,
		y = 0.656,		
		npc = true,
		public = nil,
	},
	["SW_D12"] = {
		name = L["L_SW_D12_NAME"],
		description = L["L_SW_D12_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D12",
		zone = "Stormwind City",
		x = 0.594,
		y = 0.773,		
		npc = true,
		public = nil,
	},
	["SW_D13"] = {
		name = L["L_SW_D13_NAME"],
		description = L["L_SW_D13_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D13",
		zone = "Stormwind City",
		x = 0.578,
		y = 0.665,		
		npc = true,
		public = nil,
	},
	["SW_D14"] = {
		name = L["L_SW_D14_NAME"],
		description = L["L_SW_D14_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D14",
		zone = "Stormwind City",
		x = 0.699,
		y = 0.711,		
		npc = true,
		public = nil,
	},
	["SW_E"] = {
		name = L["L_SW_E_NAME"],
		description = L["L_SW_E_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E",
		zone = "Stormwind City",
		x = 0.494,
		y = 0.836,
		npc = true,
		public = true,
	},	
	["SW_E1"] = {
		name = L["L_SW_E1_NAME"],
		description = L["L_SW_E1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E1",
		zone = "Stormwind City",
		x = 0.430,
		y = 0.774,		
		npc = true,
		public = nil,
	},
	["SW_E2"] = {
		name = L["L_SW_E2_NAME"],
		description = L["L_SW_E2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E2",
		zone = "Stormwind City",
		x = 0.422,
		y = 0.819,		
		npc = true,
		public = nil,
	},
	["SW_E3"] = {
		name = L["L_SW_E3_NAME"],
		description = L["L_SW_E3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E3",
		zone = "Stormwind City",
		x = 0.390,
		y = 0.858,		
		npc = true,
		public = nil,
	},
	["SW_E4"] = {
		name = L["L_SW_E4_NAME"],
		description = L["L_SW_E4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E4",
		zone = "Stormwind City",
		x = 0.450,
		y = 0.864,		
		npc = true,
		public = nil,
	},
	["SW_E5"] = {
		name = L["L_SW_E5_NAME"],
		description = L["L_SW_E5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E5",
		zone = "Stormwind City",
		x = 0.477,
		y = 0.819,		
		npc = true,
		public = nil,
	},
	["SW_E6"] = {
		name = L["L_SW_E6_NAME"],
		description = L["L_SW_E6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E6",
		zone = "Stormwind City",
		x = 0.521,
		y = 0.842,		
		npc = true,
		public = nil,
	},
	["SW_E7"] = {
		name = L["L_SW_E7_NAME"],
		description = L["L_SW_E7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E7",
		zone = "Stormwind City",
		x = 0.506,
		y = 0.906,		
		npc = true,
		public = nil,
	},
	["SW_E8"] = {
		name = L["L_SW_E8_NAME"],
		description = L["L_SW_E8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E8",
		zone = "Stormwind City",
		x = 0.492,
		y = 0.872,		
		npc = true,
		public = nil,
	},
	["SW_E9"] = {
		name = L["L_SW_E9_NAME"],
		description = L["L_SW_E9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E9",
		zone = "Stormwind City",
		x = 0.553,
		y = 0.851,		
		npc = true,
		public = nil,
	},
	["SW_E10"] = {
		name = L["L_SW_E10_NAME"],
		description = L["L_SW_E10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E10",
		zone = "Stormwind City",
		x = 0.539,
		y = 0.817,		
		npc = true,
		public = nil,
	},
	["SW_E11"] = {
		name = L["L_SW_E11_NAME"],
		description = L["L_SW_E11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E11",
		zone = "Stormwind City",
		x = 0.527,
		y = 0.761,		
		npc = true,
		public = nil,
	},
	["SW_E12"] = {
		name = L["L_SW_E12_NAME"],
		description = L["L_SW_E12_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E12",
		zone = "Stormwind City",
		x = 0.515,
		y = 0.684,		
		npc = true,
		public = nil,
	},
	["SW_E13"] = {
		name = L["L_SW_E13_NAME"],
		description = L["L_SW_E13_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E13",
		zone = "Stormwind City",
		x = 0.499,
		y = 0.737,		
		npc = true,
		public = nil,
	},
	["SW_E14"] = {
		name = L["L_SW_E14_NAME"],
		description = L["L_SW_E14_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E14",
		zone = "Stormwind City",
		x = 0.516,
		y = 0.738,		
		npc = true,
		public = nil,
	},
	["SW_E15"] = {
		name = L["L_SW_E15_NAME"],
		description = L["L_SW_E15_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E15",
		zone = "Stormwind City",
		x = 0.534,
		y = 0.739,		
		npc = true,
		public = nil,
	},
	["SW_F"] = {
		name = L["L_SW_F_NAME"],
		description = L["L_SW_F_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F",
		zone = "Stormwind City",
		x = 0.402,
		y = 0.608,
		npc = true,
		public = true,
	},	
	["SW_F1"] = {
		name = L["L_SW_F1_NAME"],
		description = L["L_SW_F1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F1",
		zone = "Stormwind City",
		x = 0.377,
		y = 0.566,		
		npc = false,
		public = nil,
	},
	["SW_G"] = {
		name = L["L_SW_G_NAME"],
		description = L["L_SW_G_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "G",
		zone = "Stormwind City",
		x = 0.371,
		y = 0.440,
		npc = true,
		public = true,
	},	
	["SW_G1"] = {
		name = L["L_SW_G1_NAME"],
		description = L["L_SW_G1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "G1",
		zone = "Stormwind City",
		x = 0.304,
		y = 0.291,		
		npc = nil,
		public = nil,
	},	
	["SW_G2"] = {
		name = L["L_SW_G2_NAME"],
		description = L["L_SW_G2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "G2",
		zone = "Stormwind City",
		x = 0.295,
		y = 0.475,		
		npc = nil,
		public = nil,
	},	
	["SW_G3"] = {
		name = L["L_SW_G3_NAME"],
		description = L["L_SW_G3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "G3",
		zone = "Stormwind City",
		x = 0.058,
		y = 0.069,		
		npc = nil,
		public = nil,
	},	
	["SW_H"] = {
		name = L["L_SW_H_NAME"],
		description = L["L_SW_H_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "H",
		zone = "Stormwind City",
		x = 0.462,
		y = 0.289,
		npc = true,
		public = true,
	},	
	["SW_I"] = {
		name = L["L_SW_I_NAME"],
		description = L["L_SW_I_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "I",
		zone = "Stormwind City",
		x = 0.575,
		y = 0.190,
		npc = true,
		public = true,
	},	
	["SW_I1"] = {
		name = L["L_SW_I1_NAME"],
		description = L["L_SW_I1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "I1",
		zone = "Stormwind City",
		x = 0.579,
		y = 0.248,		
		npc = true,
		public = nil,
	},	
	["SW_I2"] = {
		name = L["L_SW_I2_NAME"],
		description = L["L_SW_I2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "I2",
		zone = "Stormwind City",
		x = 0.515,
		y = 0.125,		
		npc = nil,
		public = nil,
	},	
	["SW_I3"] = {
		name = L["L_SW_I3_NAME"],
		description = L["L_SW_I3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "I3",
		zone = "Stormwind City",
		x = 0.516,
		y = 0.059,		
		npc = nil,
		public = nil,
	},	
	["SW_J"] = {
		name = L["L_SW_J_NAME"],
		description = L["L_SW_J_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "J",
		zone = "Stormwind City",
		x = 0.674,
		y = 0.170,
		npc = true,
		public = true,
	},	
	["SW_K"] = {
		name = L["L_SW_K_NAME"],
		description = L["L_SW_K_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K",
		zone = "Stormwind City",
		x = 0.745,
		y = 0.185,
		npc = true,
		public = true,
	},	
	["SW_K1"] = {
		name = L["L_SW_K1_NAME"],
		description = L["L_SW_K1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K1",
		zone = "Stormwind City",
		x = 0.757,
		y = 0.162,		
		npc = nil,
		public = nil,
	},	
	["SW_K2"] = {
		name = L["L_SW_K2_NAME"],
		description = L["L_SW_K2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K2",
		zone = "Stormwind City",
		x = 0.767,
		y = 0.180,		
		npc = nil,
		public = nil,
	},	
	["SW_K3"] = {
		name = L["L_SW_K3_NAME"],
		description = L["L_SW_K3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K3",
		zone = "Stormwind City",
		x = 0.762,
		y = 0.202,		
		npc = nil,
		public = nil,
	},	
	["SW_K4"] = {
		name = L["L_SW_K4_NAME"],
		description = L["L_SW_K4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K4",
		zone = "Stormwind City",
		x = 0.729,
		y = 0.193,		
		npc = true,
		public = nil,
	},	
	["SW_K5"] = {
		name = L["L_SW_K5_NAME"],
		description = L["L_SW_K5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K5",
		zone = "Stormwind City",
		x = 0.728,
		y = 0.167,		
		npc = nil,
		public = nil,
	},	
	["SW_K6"] = {
		name = L["L_SW_K6_NAME"],
		description = L["L_SW_K6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "K6",
		zone = "Stormwind City",
		x = 0.715,
		y = 0.273,		
		npc = true,
		public = nil,
	},	
	["SW_L"] = {
		name = L["L_SW_L_NAME"],
		description = L["L_SW_L_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "L",
		zone = "Stormwind City",
		x = 0.792,
		y = 0.397,
		npc = true,
		public = true,
	},	
	["SW_L1"] = {
		name = L["L_SW_L1_NAME"],
		description = L["L_SW_L1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "L1",
		zone = "Stormwind City",
		x = 0.810,
		y = 0.344,		
		npc = true,
		public = nil,
	},	
	["SW_L2"] = {
		name = L["L_SW_L2_NAME"],
		description = L["L_SW_L2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "L2",
		zone = "Stormwind City",
		x = 0.849,
		y = 0.252,		
		npc = true,
		public = nil,
	},	
	["SW_L3"] = {
		name = L["L_SW_L3_NAME"],
		description = L["L_SW_L3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "L3",
		zone = "Stormwind City",
		x = 0.872,
		y = 0.363,		
		npc = true,
		public = nil,
	},	
	["DN_A"] = {
		name = L["L_DN_A_NAME"],
		description = L["L_DN_A_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A",
		zone = "Darnassus",
		x = 0.429,
		y = 0.604,
		npc = true,
		public = true,
	},	
	["DN_A1"] = {
		name = L["L_DN_A1_NAME"],
		description = L["L_DN_A1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A1",
		zone = "Darnassus",
		x = 0.436,
		y = 0.511,		
		npc = true,
		public = nil,
	},
	["DN_A2"] = {
		name = L["L_DN_A2_NAME"],
		description = L["L_DN_A2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A2",
		zone = "Darnassus",
		x = 0.431,
		y = 0.805,		
		npc = true,
		public = nil,
	},
	["DN_A3"] = {
		name = L["L_DN_A3_NAME"],
		description = L["L_DN_A3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A3",
		zone = "Darnassus",
		x = 0.372,
		y = 0.811,		
		npc = true,
		public = nil,
	},
	["DN_A4"] = {
		name = L["L_DN_A4_NAME"],
		description = L["L_DN_A4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A4",
		zone = "Darnassus",
		x = 0.367,
		y = 0.699,		
		npc = nil,
		public = nil,
	},
	["DN_A5"] = {
		name = L["L_DN_A5_NAME"],
		description = L["L_DN_A5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A5",
		zone = "Darnassus",
		x = 0.496,
		y = 0.694,		
		npc = true,
		public = nil,
	},
	["DN_A6"] = {
		name = L["L_DN_A6_NAME"],
		description = L["L_DN_A6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "A6",
		zone = "Darnassus",
		x = 0.494,
		y = 0.809,		
		npc = nil,
		public = nil,
	},
	["DN_B"] = {
		name = L["L_DN_B_NAME"],
		description = L["L_DN_B_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B",
		zone = "Darnassus",
		x = 0.424,
		y = 0.349,
		npc = true,
		public = true,
	},	
	["DN_B1"] = {
		name = L["L_DN_B1_NAME"],
		description = L["L_DN_B1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B1",
		zone = "Darnassus",
		x = 0.385,
		y = 0.361,		
		npc = true,
		public = nil,
	},
	["DN_B2"] = {
		name = L["L_DN_B2_NAME"],
		description = L["L_DN_B2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B2",
		zone = "Darnassus",
		x = 0.382,
		y = 0.333,		
		npc = true,
		public = nil,
	},
	["DN_B3"] = {
		name = L["L_DN_B3_NAME"],
		description = L["L_DN_B3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B3",
		zone = "Darnassus",
		x = 0.380,
		y = 0.306,		
		npc = nil,
		public = nil,
	},
	["DN_B4"] = {
		name = L["L_DN_B4_NAME"],
		description = L["L_DN_B4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B4",
		zone = "Darnassus",
		x = 0.401,
		y = 0.286,		
		npc = true,
		public = nil,
	},
	["DN_B5"] = {
		name = L["L_DN_B5_NAME"],
		description = L["L_DN_B5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B5",
		zone = "Darnassus",
		x = 0.436,
		y = 0.285,		
		npc = true,
		public = nil,
	},
	["DN_B6"] = {
		name = L["L_DN_B6_NAME"],
		description = L["L_DN_B6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B6",
		zone = "Darnassus",
		x = 0.419,
		y = 0.264,		
		npc = nil,
		public = nil,	
	},
	["DN_B7"] = {
		name = L["L_DN_B7_NAME"],
		description = L["L_DN_B7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B7",
		zone = "Darnassus",
		x = 0.452,
		y = 0.276,		
		npc = true,
		public = nil,	
	},
	["DN_B8"] = {
		name = L["L_DN_B8_NAME"],
		description = L["L_DN_B8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "B8",
		zone = "Darnassus",
		x = 0.436,
		y = 0.259,		
		npc = true,
		public = nil,	
	},
	["DN_C"] = {
		name = L["L_DN_C_NAME"],
		description = L["L_DN_C_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "C",
		zone = "Darnassus",
		x = 0.493,
		y = 0.164,
		npc = true,
		public = true,
	},	
	["DN_D"] = {
		name = L["L_DN_D_NAME"],
		description = L["L_DN_D_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D",
		zone = "Darnassus",
		x = 0.569,
		y = 0.366,
		npc = true,
		public = true,
	},	
	["DN_D1"] = {
		name = L["L_DN_D1_NAME"],
		description = L["L_DN_D1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D1",
		zone = "Darnassus",
		x = 0.552,
		y = 0.247,		
		npc = nil,
		public = nil,
	},		
	["DN_D2"] = {
		name = L["L_DN_D2_NAME"],
		description = L["L_DN_D2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D2",
		zone = "Darnassus",
		x = 0.600,
		y = 0.269,		
		npc = nil,
		public = nil,
	},		
	["DN_D3"] = {
		name = L["L_DN_D3_NAME"],
		description = L["L_DN_D3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D3",
		zone = "Darnassus",
		x = 0.629,
		y = 0.321,		
		npc = nil,
		public = nil,
	},		
	["DN_D4"] = {
		name = L["L_DN_D4_NAME"],
		description = L["L_DN_D4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D4",
		zone = "Darnassus",
		x = 0.640,
		y = 0.382,		
		npc = true,
		public = nil,
	},		
	["DN_D5"] = {
		name = L["L_DN_D5_NAME"],
		description = L["L_DN_D5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D5",
		zone = "Darnassus",
		x = 0.515,
		y = 0.396,		
		npc = nil,
		public = nil,
	},		
	["DN_D6"] = {
		name = L["L_DN_D6_NAME"],
		description = L["L_DN_D6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D6",
		zone = "Darnassus",
		x = 0.505,
		y = 0.366,		
		npc = true,
		public = nil,
	},		
	["DN_D7"] = {
		name = L["L_DN_D7_NAME"],
		description = L["L_DN_D7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D7",
		zone = "Darnassus",
		x = 0.507,
		y = 0.341,		
		npc = true,
		public = nil,
	},		
	["DN_D8"] = {
		name = L["L_DN_D8_NAME"],
		description = L["L_DN_D8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D8",
		zone = "Darnassus",
		x = 0.516,
		y = 0.316,		
		npc = true,
		public = nil,
	},		
	["DN_D9"] = {
		name = L["L_DN_D9_NAME"],
		description = L["L_DN_D9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D9",
		zone = "Darnassus",
		x = 0.545,
		y = 0.299,		
		npc = true,
		public = nil,
	},		
	["DN_D10"] = {
		name = L["L_DN_D10_NAME"],
		description = L["L_DN_D10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D10",
		zone = "Darnassus",
		x = 0.570,
		y = 0.307,		
		npc = true,
		public = nil,
	},		
	["DN_D11"] = {
		name = L["L_DN_D11_NAME"],
		description = L["L_DN_D11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D11",
		zone = "Darnassus",
		x = 0.585,
		y = 0.336,		
		npc = true,
		public = nil,
	},	
	["DN_D12"] = {
		name = L["L_DN_D12_NAME"],
		description = L["L_DN_D12_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D12",
		zone = "Darnassus",
		x = 0.597,
		y = 0.372,		
		npc = true,
		public = nil,
	},		
	["DN_D13"] = {
		name = L["L_DN_D13_NAME"],
		description = L["L_DN_D13_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D13",
		zone = "Darnassus",
		x = 0.613,
		y = 0.406,		
		npc = false,
		public = nil,
	},		
	["DN_D14"] = {
		name = L["L_DN_D14_NAME"],
		description = L["L_DN_D14_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "D14",
		zone = "Darnassus",
		x = 0.543,
		y = 0.390,		
		npc = true,
		public = nil,
	},		
	["DN_E"] = {
		name = L["L_DN_E_NAME"],
		description = L["L_DN_E_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E",
		zone = "Darnassus",
		x = 0.657,
		y = 0.497,
		npc = true,
		public = true,
	},	
	["DN_E1"] = {
		name = L["L_DN_E1_NAME"],
		description = L["L_DN_E1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "E1",
		zone = "Darnassus",
		x = 0.759,
		y = 0.470,		
		npc = true,
		public = nil,
	},		
	["DN_F"] = {
		name = L["L_DN_F_NAME"],
		description = L["L_DN_F_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F",
		zone = "Darnassus",
		x = 0.589,
		y = 0.600,
		npc = true,
		public = true,
	},		
	["DN_F1"] = {
		name = L["L_DN_F1_NAME"],
		description = L["L_DN_F1_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F1",
		zone = "Darnassus",
		x = 0.571,
		y = 0.651,		
		npc = nil,
		public = nil,
	},		
	["DN_F2"] = {
		name = L["L_DN_F2_NAME"],
		description = L["L_DN_F2_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F2",
		zone = "Darnassus",
		x = 0.553,
		y = 0.622,		
		npc = nil,
		public = nil,
	},		
	["DN_F3"] = {
		name = L["L_DN_F3_NAME"],
		description = L["L_DN_F3_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F3",
		zone = "Darnassus",
		x = 0.556,
		y = 0.592,		
		npc = true,
		public = nil,
	},		
	["DN_F4"] = {
		name = L["L_DN_F4_NAME"],
		description = L["L_DN_F4_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F4",
		zone = "Darnassus",
		x = 0.556,
		y = 0.561,		
		npc = nil,
		public = nil,
	},		
	["DN_F5"] = {
		name = L["L_DN_F5_NAME"],
		description = L["L_DN_F5_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F5",
		zone = "Darnassus",
		x = 0.608,
		y = 0.583,		
		npc = true,
		public = nil,
	},		
	["DN_F6"] = {
		name = L["L_DN_F6_NAME"],
		description = L["L_DN_F6_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F6",
		zone = "Darnassus",
		x = 0.603,
		y = 0.631,		
		npc = true,
		public = nil,
	},		
	["DN_F7"] = {
		name = L["L_DN_F7_NAME"],
		description = L["L_DN_F7_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F7",
		zone = "Darnassus",
		x = 0.595,
		y = 0.683,		
		npc = true,
		public = nil,
	},		
	["DN_F8"] = {
		name = L["L_DN_F8_NAME"],
		description = L["L_DN_F8_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F8",
		zone = "Darnassus",
		x = 0.576,
		y = 0.711,		
		npc = true,
		public = nil,
	},	
	["DN_F9"] = {
		name = L["L_DN_F9_NAME"],
		description = L["L_DN_F9_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F9",
		zone = "Darnassus",
		x = 0.552,
		y = 0.757,		
		npc = true,
		public = nil,
	},	
	["DN_F10"] = {
		name = L["L_DN_F10_NAME"],
		description = L["L_DN_F10_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F10",
		zone = "Darnassus",
		x = 0.525,
		y = 0.775,		
		npc = true,
		public = nil,
	},	
	["DN_F11"] = {
		name = L["L_DN_F11_NAME"],
		description = L["L_DN_F11_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F11",
		zone = "Darnassus",
		x = 0.652,
		y = 0.604,		
		npc = nil,
		public = nil,
	},	
	["DN_F12"] = {
		name = L["L_DN_F12_NAME"],
		description = L["L_DN_F12_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F12",
		zone = "Darnassus",
		x = 0.647,
		y = 0.687,		
		npc = true,
		public = nil,
	},	
	["DN_F13"] = {
		name = L["L_DN_F13_NAME"],
		description = L["L_DN_F13_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F13",
		zone = "Darnassus",
		x = 0.625,
		y = 0.745,		
		npc = nil,
		public = nil,
	},	
	["DN_F14"] = {
		name = L["L_DN_F14_NAME"],
		description = L["L_DN_F14_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F14",
		zone = "Darnassus",
		x = 0.595,
		y = 0.792,		
		npc = nil,
		public = nil,
	},	
	["DN_F15"] = {
		name = L["L_DN_F15_NAME"],
		description = L["L_DN_F15_DESC"],
		picture =  "Interface\\AddOns\\GnomTEC_CityMaps\\Textures\\POI_NONE",
		localId = "F15",
		zone = "Darnassus",
		x = 0.547,
		y = 0.836,		
		npc = true,
		public = nil,
	},	

}

-- display of POI information is locked
local lockInfo = false

-- config panel
local panelConfiguration = nil

-- ----------------------------------------------------------------------
-- Startup initialization
-- ----------------------------------------------------------------------

GnomTEC_CityMaps = LibStub("AceAddon-3.0"):NewAddon("GnomTEC_CityMaps", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0")
local Tourist = LibStub("LibTourist-3.0") 

LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC CityMaps Main", optionsMain)
LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC CityMaps View", optionsView)
LibStub("AceConfig-3.0"):RegisterOptionsTable("GnomTEC CityMaps Data", optionsData)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC CityMaps Main", "GnomTEC CityMaps");
panelConfiguration = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC CityMaps View", L["L_OPTIONS_VIEW"], "GnomTEC CityMaps");
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("GnomTEC CityMaps Data", L["L_OPTIONS_DATA"], "GnomTEC CityMaps");

-- ----------------------------------------------------------------------
-- Local stubs for the GnomTEC API
-- ----------------------------------------------------------------------

local function GnomTEC_LogMessage(level, message)
	if (level < LOG_DEBUG) then
		GnomTEC_CityMaps:Print(message)
	end
end

local function GnomTEC_RegisterAddon()
end

-- ----------------------------------------------------------------------
-- Local functions
-- ----------------------------------------------------------------------

-- function which returns also nil for empty strings
local function emptynil( x ) return x ~= "" and x or nil end

-- function to cleanup control sequences
local function cleanpipe( x )
	x = x or ""
	
	-- Filter TRP2 {} color codes
	x = string.gsub( x, "{%x%x%x%x%x%x}", "" )
	
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
	local posX, posY, zone, uiMapID = Tourist:GetBestZoneCoordinate()
	local x,y;
	
	zone = Tourist:GetReverseLookupTable()[zone]

	x = 0;
	
	if (posX ~= 0 and posY ~= 0 and zone) then
		x,y = Tourist:TransposeZoneCoordinate(posX, posY, Tourist:GetLookupTable()[zone], Tourist:GetLookupTable()[self.db.char.displayedMap])
		-- LibTourist do not limit the transpose to the map (eg between SW and IF it will transpose outside of 0<x/y<1
		if (x) then
			if (x < 0) or (x > 1) then
				x = nil
			end
		end
		if (y) then
			if (y < 0) or (y > 1) then
				y = nil
			end
		end
	end
		
	if (not x or not y) then
		GNOMTEC_CITYMAPS_FRAME_POI:SetText("("..(Tourist:GetLookupTable()[zone] or "???").." ; "..string.format("%.3f",posX).." ; "..string.format("%.3f",posY)..")")
		-- Wir sind nicht auf einer Position die auf der aktuellen Karte angezeigt werden könnte
		local playerFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_PLAYER")
		if (playerFrame) then
			playerFrame:Hide()
		end
	else
		GNOMTEC_CITYMAPS_FRAME_POI:SetText("("..Tourist:GetLookupTable()[self.db.char.displayedMap].." ; "..string.format("%.3f",x).." ; "..string.format("%.3f",y)..")")
		-- compute frame offsets
		x = 1000.0 / 1024.0 * 600.0 * x	+ 15	-- visible texture / texturesize * framesize * position + offset
		y = -(667.0 / 768.0 * 450.0 * y) - 20	-- visible texture / texturesize * framesize * position - offest
		local playerFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_PLAYER")
		if (not playerFrame) then
			playerFrame = CreateFrame("Frame","GNOMTEC_CITYMAPS_FRAME_PLAYER",GNOMTEC_CITYMAPS_FRAME)
			playerFrame:SetFrameStrata(GNOMTEC_CITYMAPS_FRAME:GetFrameStrata());
			playerFrame:SetFrameLevel(GNOMTEC_CITYMAPS_FRAME:GetFrameLevel()+21)
			playerFrame:SetWidth(16);  
			playerFrame:SetHeight(16); 

			local playerTexture = playerFrame:CreateTexture(nil,"OVERLAY");
			playerTexture:SetTexture("Interface\\WorldMap\\WorldMapPlayerIcon");
			playerTexture:SetAllPoints(playerFrame);
			playerFrame.texture = playerTexture;
			playerFrame:SetAlpha(1.0); 
			playerFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x,y)
			playerFrame:Show();
		else
			if (1.0 == playerFrame:GetAlpha()) then
				playerFrame:SetAlpha(0.8); 
			else
				playerFrame:SetAlpha(1.0); 
			end
			playerFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x,y)
			playerFrame:Show();		
		end	
	end			
end

-- function called when mouse enters the POI icon on map (attached in GnomTEC_CityMaps:ShowPOI())
local function GnomTEC_CityMaps_POIFrame_OnEnter(self)
   local relam = GetRealmName();
   
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
			local announcementsText = ""

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
				usedByText = "|n|n|cFFFFFF80--- Genutzt von (statische Liste)---|r|n"..(GnomTEC_CityMaps_UsedBy[GetRealmName()][id] or "<frei>")
			end
			
			if (GnomTEC_CityMaps_Announcements[id]) then
				for key,value in pairs(GnomTEC_CityMaps_Announcements[id]["ANNOUNCEMENTS"]) do
					announcementsText = key..": "..value["DATE"].." ("..value["TIME_START"].."-"..value["TIME_END"]..") - "..value["ANNOUNCEMENT"].."|n"
				end
			end
			if ("" ~= announcementsText) then
				announcementsText = "|n|n|cFFFFFF80--- Ankündigungen---|r|n"..announcementsText
			end
			
			GNOMTEC_CITYMAPS_FRAME_INFO_SCROLL_DESCRIPTION:SetText("|cFFFFFF80--- Engine ---|r|n"..POI[id].description..usedByText..mspText..announcementsText)
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

	local x,y = Tourist:TransposeZoneCoordinate(POI[id].x, POI[id].y, Tourist:GetLookupTable()[POI[id].zone], Tourist:GetLookupTable()[self.db.char.displayedMap])
	-- LibTourist do not limit the transpose to the map (eg between SW and IF it will transpose outside of 0<x/y<1
	if (x) then
		if (x < 0) or (x > 1) then
			x = nil
		end
	end
	if (y) then
		if (y < 0) or (y > 1) then
			y = nil
		end
	end

		
	if (not x) then
		-- falls angezeigt dann entfernen
		local POIFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_POI_"..id)
		if (POIFrame) then
			POIFrame:Hide()
		end
	else		
		-- compute frame offsets
		x = 1000.0 / 1024.0 * 600.0 * x	+ 15	-- visible texture / texturesize * framesize * position + offset
		y = -(667.0 / 768.0 * 450.0 * y) - 20	-- visible texture / texturesize * framesize * position - offest

		local POIFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_POI_"..id)
		if (not POIFrame) then

			POIFrame = CreateFrame("Frame","GNOMTEC_CITYMAPS_FRAME_POI_"..id,GNOMTEC_CITYMAPS_FRAME)
			POIFrame:SetFrameStrata(GNOMTEC_CITYMAPS_FRAME:GetFrameStrata());
			POIFrame:SetFrameLevel(GNOMTEC_CITYMAPS_FRAME:GetFrameLevel()+20)
			POIFrame:SetWidth(12); 
			POIFrame:SetHeight(12);
			POIFrame:EnableMouse(true);
			POIFrame:HookScript("OnEnter",GnomTEC_CityMaps_POIFrame_OnEnter);
			POIFrame:HookScript("OnLeave",GnomTEC_CityMaps_POIFrame_OnLeave);		
			POIFrame:HookScript("OnMouseDown",GnomTEC_CityMaps_POIFrame_OnMouseDown);		
			local POITexture = POIFrame:CreateTexture(nil,"OVERLAY");
			POITexture:SetTexture(CONST_POIICON_FREE)	
			POITexture:SetAllPoints(POIFrame);
			POIFrame.texture = POITexture;			
			POIFrame:SetAlpha(1.0); 
			local POILabel = POIFrame:CreateFontString();
			POILabel:SetPoint("CENTER", POIFrame, "CENTER", 0, 0)
			POILabel:SetFontObject(GameFontHighlightSmall)
			POILabel:SetText(POI[id].localId)
			POIFrame.label = POILabel
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
		local POILabel = POIFrame.label
		
		if (POI[id].public) then
			POITexture:SetTexture(CONST_POIICON_PUBLIC)
			POILabel:SetText("|cFF0000FF"..POI[id].localId.."|r")
		elseif ((GnomTEC_CityMaps_UsedBy[GetRealmName()][id] and GnomTEC_CityMaps_Options["ShowStaticData"]) or (mspData and GnomTEC_CityMaps_Options["ShowMSPData"]))then		
			if (POI[id].npc) then
				POITexture:SetTexture(CONST_POIICON_USED_WITH_NPC)
				POILabel:SetText("|cFFFF0000"..POI[id].localId.."|r")
			else
				POITexture:SetTexture(CONST_POIICON_USED)	
				POILabel:SetText("|cFFFF0000"..POI[id].localId.."|r")			
			end
		else
			if (POI[id].npc) then
				POITexture:SetTexture(CONST_POIICON_FREE_WITH_NPC)
				POILabel:SetText("|cFF00FF00"..POI[id].localId.."|r")
			else
				POITexture:SetTexture(CONST_POIICON_FREE)
				POILabel:SetText("|cFF00FF00"..POI[id].localId.."|r")			
			end
		end					
		POIFrame:SetPoint("CENTER",GNOMTEC_CITYMAPS_FRAME,"TOPLEFT", x, y)
		
		if (GnomTEC_CityMaps_Options["ShowPOILabel"]) then
			POITexture:Hide()
			POILabel:Show()
		else
			POITexture:Show()
			POILabel:Hide()
		end
		POIFrame:Show();		
	end			
end

-- function to let some POI flash on actual map
function GnomTEC_CityMaps:FlashPOIs()
	local hour,minute = GetGameTime();
	local actualTime = hour*100 + minute
	local calendarTime = C_Calendar.GetDate();
	local actualDate = string.format("%04u%02u%02u",calendarTime.year,calendarTime.month,calendarTime.monthDay)
	local cleanup = false
		
	-- flash all POIs which have a actual announcement
	for key,value in pairs(GnomTEC_CityMaps_Announcements) do
	 	local POIFrame = getglobal("GNOMTEC_CITYMAPS_FRAME_POI_"..key)
		if (POIFrame and POI[key]) then
		 	if ((value["DATE"] == actualDate) and (value["TIME_END"] >= actualTime)) then
				local POITexture = POIFrame.texture
				if (POITexture:GetTexture() == CONST_POIICON_FLASH) then
					GnomTEC_CityMaps:ShowPOI(key)
				else
					POITexture:SetTexture(CONST_POIICON_FLASH)
				end
			elseif ((value["DATE"] < actualDate) or ((value["DATE"] == actualDate) and (value["TIME_END"] < actualTime))) then
				GnomTEC_CityMaps:ShowPOI(key)
				cleanup = true
			end
		end
	end
	
	-- cleanup announcements
	if (cleanup) then
		GnomTEC_CityMaps:CleanupAnnouncement()	
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
		
	-- Update Position every second and flash some POIs
	if ((t-lastTimerEvent) > 1) then
		GnomTEC_CityMaps:ShowPlayerPosition()
		
		GnomTEC_CityMaps:FlashPOIs()
		
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
		p = msp.char[ player.."-"..realm ]
	else
		p = msp.char[ player ]	
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

function GnomTEC_CityMaps:SetStaticDataIsDefault(realm, map, isDefault)
	if (not GnomTEC_CityMaps_UsedBy[realm]) then GnomTEC_CityMaps_UsedBy[realm] = {} end

	if ("Ironforge" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["IF_ISDEFAULT"] = isDefault;
	elseif ("Stormwind" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["SW_ISDEFAULT"] = isDefault;
	elseif ("Darnassus" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["DN_ISDEFAULT"] = isDefault;
	elseif ("Dalaran" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["DA_ISDEFAULT"] = isDefault;
	end
	
	-- set static data to default values if selected so
	if (isDefault) then
		-- clear all static usage information of the selected map
		for key,value in pairs(POI) do
			if ("Ironforge" == map) then
				if (1 == string.find(key,"IF_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = nil;
				end
			elseif ("Stormwind" == map) then
				if (1 == string.find(key,"SW_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = nil;
				end
			elseif ("Darnassus" == map) then
				if (1 == string.find(key,"DN_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = nil;
				end
			elseif ("Dalaran" == map) then
				if (1 == string.find(key,"DA_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = nil;
				end
			end
		end	

		-- add static usage information of the selected map from default data
		if (not CONST_USEDBY_DEFAULT[realm]) then CONST_USEDBY_DEFAULT[realm] = {} end
		for key, value in pairs(POI) do
			if (POI[key]) then
				if ("Ironforge" == map) then
					if (1 == string.find(key,"IF_(%a+)(%d+)")) then
						GnomTEC_CityMaps_UsedBy[realm][key] = CONST_USEDBY_DEFAULT[realm][key]
					end
				elseif ("Stormwind" == map) then
					if (1 == string.find(key,"SW_(%a+)(%d+)")) then
						GnomTEC_CityMaps_UsedBy[realm][key] = CONST_USEDBY_DEFAULT[realm][key]
					end
				elseif ("Darnassus" == map) then
					if (1 == string.find(key,"DN_(%a+)(%d+)")) then
						GnomTEC_CityMaps_UsedBy[realm][key] = CONST_USEDBY_DEFAULT[realm][key]
					end
				elseif ("Dalaran" == map) then
					if (1 == string.find(key,"DA_(%a+)(%d+)")) then
						GnomTEC_CityMaps_UsedBy[realm][key] = CONST_USEDBY_DEFAULT[realm][key]
					end
				end
			end
		end
	
		-- refresh POIs of the selected map

		-- update all static usage information of the selected map
		for key,value in pairs(POI) do
			if ("Ironforge" == map) then
				if (1 == string.find(key,"IF_(%a+)(%d+)")) then
					GnomTEC_CityMaps:ShowPOI(key)
				end
			elseif ("Stormwind" == map) then
				if (1 == string.find(key,"SW_(%a+)(%d+)")) then
					GnomTEC_CityMaps:ShowPOI(key)
				end
			elseif ("Darnassus" == map) then
				if (1 == string.find(key,"DN_(%a+)(%d+)")) then
					GnomTEC_CityMaps:ShowPOI(key)
				end
			elseif ("Dalaran" == map) then
				if (1 == string.find(key,"DA_(%a+)(%d+)")) then
					GnomTEC_CityMaps:ShowPOI(key)
				end
			end
		end
		
	end
end

function GnomTEC_CityMaps:GetStaticDataIsDefault(realm, map)
	if (not GnomTEC_CityMaps_UsedBy[realm]) then GnomTEC_CityMaps_UsedBy[realm] = {} end

	if ("Ironforge" == map) then
		return GnomTEC_CityMaps_UsedBy[realm]["IF_ISDEFAULT"]
	elseif ("Stormwind" == map) then
		return GnomTEC_CityMaps_UsedBy[realm]["SW_ISDEFAULT"]
	elseif ("Darnassus" == map) then
		return GnomTEC_CityMaps_UsedBy[realm]["DN_ISDEFAULT"]
	elseif ("Dalaran" == map) then
		return GnomTEC_CityMaps_UsedBy[realm]["DA_ISDEFAULT"]
	end
	
	return false
end

function GnomTEC_CityMaps:ImportStaticData(realm, map, text)
	local key, value

	if (not GnomTEC_CityMaps_UsedBy[realm]) then GnomTEC_CityMaps_UsedBy[realm] = {} end
	
	-- clear all static usage information of the selected map
	for key,value in pairs(POI) do
		if ("Ironforge" == map) then
			if (1 == string.find(key,"IF_(%a+)(%d+)")) then
				GnomTEC_CityMaps_UsedBy[realm][key] = nil;
			end
		elseif ("Stormwind" == map) then
			if (1 == string.find(key,"SW_(%a+)(%d+)")) then
				GnomTEC_CityMaps_UsedBy[realm][key] = nil;
			end
		elseif ("Darnassus" == map) then
			if (1 == string.find(key,"DN_(%a+)(%d+)")) then
				GnomTEC_CityMaps_UsedBy[realm][key] = nil;
			end
		elseif ("Dalaran" == map) then
			if (1 == string.find(key,"DA_(%a+)(%d+)")) then
				GnomTEC_CityMaps_UsedBy[realm][key] = nil;
			end
		end
	end
	if ("Ironforge" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["IF_ISDEFAULT"] = false;
	elseif ("Stormwind" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["SW_ISDEFAULT"] = false;
	elseif ("Darnassus" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["DN_ISDEFAULT"] = false;
	elseif ("Dalaran" == map) then
		GnomTEC_CityMaps_UsedBy[realm]["DA_ISDEFAULT"] = false;
	end
	
	-- add static usage information of the selected map from text input
	for key, value in string.gmatch(text or "", "(%w+_%w+)=([^%]]+)") do
		if (POI[key]) then
			if ("Ironforge" == map) then
				if (1 == string.find(key,"IF_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = emptynil( string.gsub(value or "","||","|") )
				end
			elseif ("Stormwind" == map) then
				if (1 == string.find(key,"SW_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = emptynil( string.gsub(value or "","||","|") )
				end
			elseif ("Darnassus" == map) then
				if (1 == string.find(key,"DN_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = emptynil( string.gsub(value or "","||","|") )
				end
			elseif ("Dalaran" == map) then
				if (1 == string.find(key,"DA_(%a+)(%d+)")) then
					GnomTEC_CityMaps_UsedBy[realm][key] = emptynil( string.gsub(value or "","||","|") )
				end
			end
		end
	end
	
	-- refresh POIs of the selected map

	-- update all static usage information of the selected map
	for key,value in pairs(POI) do
		if ("Ironforge" == map) then
			if (1 == string.find(key,"IF_(%a+)(%d+)")) then
				GnomTEC_CityMaps:ShowPOI(key)
			end
		elseif ("Stormwind" == map) then
			if (1 == string.find(key,"SW_(%a+)(%d+)")) then
				GnomTEC_CityMaps:ShowPOI(key)
			end
		elseif ("Darnassus" == map) then
			if (1 == string.find(key,"DN_(%a+)(%d+)")) then
				GnomTEC_CityMaps:ShowPOI(key)
			end
		elseif ("Dalaran" == map) then
			if (1 == string.find(key,"DA_(%a+)(%d+)")) then
				GnomTEC_CityMaps:ShowPOI(key)
			end
		end
	end
	
end

local function sortPOInameFunction(a, b)
	local aArea = string.match(a,"(%a+_%a+)")
	local bArea = string.match(b,"(%a+_%a+)")
	local aNumber = tonumber(string.match(a,"(%d+)"))
	local bNumber = tonumber(string.match(b,"(%d+)"))
	
	return (aArea < bArea) or ((aArea == bArea) and (aNumber < bNumber))
end

function GnomTEC_CityMaps:ExportStaticData(realm,map)
	local exportList = {}
	local exportData = ""
	local key, value

	if (not GnomTEC_CityMaps_UsedBy[realm]) then GnomTEC_CityMaps_UsedBy[realm] = {} end

	-- search for data to export
	for key,value in pairs(POI) do
		if ("Ironforge" == map) then
			if (1 == string.find(key,"IF_(%a+)(%d+)")) then
				table.insert(exportList,key)
			end
		elseif ("Stormwind" == map) then
			if (1 == string.find(key,"SW_(%a+)(%d+)")) then
				table.insert(exportList,key)
			end
		elseif ("Darnassus" == map) then
			if (1 == string.find(key,"DN_(%a+)(%d+)")) then
				table.insert(exportList,key)
			end
		elseif ("Dalaran" == map) then
			if (1 == string.find(key,"DA_(%a+)(%d+)")) then
				table.insert(exportList,key)
			end
		end
	end
	
	-- Create export string
	table.sort(exportList, sortPOInameFunction)
	for key,value in pairs(exportList) do
		exportData = exportData.."["..value.."="..string.gsub(GnomTEC_CityMaps_UsedBy[realm][value] or "","|","||").."]|n"
	end
	return exportData
end

function GnomTEC_CityMaps:CleanupAnnouncement()
	local hour,minute = GetGameTime();
	local actualTime = hour*100 + minute
	local calendarTime = C_Calendar.GetDate();
	local actualDate = string.format("%04u%02u%02u",calendarTime.year,calendarTime.month,calendarTime.monthDay)

	-- cleanup announcements
	local cleanup = {}
	for key,value in pairs(GnomTEC_CityMaps_Announcements) do
		-- cleanup announcement from single players
		local cleanup_a = {}
		for key_a,value_a in pairs(GnomTEC_CityMaps_Announcements[key]["ANNOUNCEMENTS"]) do
			if ((value_a["DATE"] < actualDate) or ((value_a["DATE"] == actualDate) and (value_a["TIME_END"] < actualTime))) then
				cleanup_a[key_a] = true
			end
		end
		for key_a,value_a in pairs(cleanup_a) do
			GnomTEC_CityMaps_Announcements[key]["ANNOUNCEMENTS"][key_a] = nil
		end
		
		local time_start = nil
		local time_end = nil
		local date = nil
		-- recalculate date, time_start and time_end for earliest announcement for the poi
		for key_a,value_a in pairs(GnomTEC_CityMaps_Announcements[key]["ANNOUNCEMENTS"]) do
			if (not date) then
				date = value_a["DATE"]
				time_start = value_a["TIME_START"]
				time_end = value_a["TIME_END"]
			elseif (date > value_a["DATE"]) then
				date = value_a["DATE"]
				time_start = value_a["TIME_START"]
				time_end = value_a["TIME_END"]
			elseif (date == value_a["DATE"]) then
				if (time_start > value_a["TIME_START"]) then
					date = value_a["DATE"]
					time_start = value_a["TIME_START"]
					time_end = value_a["TIME_END"]
				end
			end			
		end
		
		if (not date) then
			cleanup[key] = true
		else
			value["DATE"] = date
			value["TIME_START"] = time_start
			value["TIME_END"] = time_end
		end
	end
	for key,value in pairs(cleanup) do
		GnomTEC_CityMaps_Announcements[key] = nil
	end

end

function GnomTEC_CityMaps:CheckAnnouncement(sender, message)
	local player, realm = strsplit( "-", sender, 2 )
	realm = string.gsub(realm or GetRealmName(), "%s+", "")
	for poi, value in string.gmatch(message,"%*(%a+_%a+%d+)([:0-9%*]+)") do
		local time_start = nil
		local time_end = nil
		local time_duration = nil
		local pattern = "%*"..string.gsub(poi..value,"%*","%%%*")
		local announcement = string.gsub(message,pattern,"")
		poi = string.upper(poi)
		value = string.gsub(value,":",":0")
		for time in string.gmatch(value,":(%d+)") do
			if (not time_start) then
				time_start = tonumber(time)
			elseif (not time_end) then
				time_end = tonumber(time)
			elseif (not time_duration) then
				time_duration = tonumber(time)
			end			
		end
	
		if (not GnomTEC_CityMaps_Announcements[poi]) then
			GnomTEC_CityMaps_Announcements[poi] = {}
		end
		if (not GnomTEC_CityMaps_Announcements[poi]["ANNOUNCEMENTS"]) then
			GnomTEC_CityMaps_Announcements[poi]["ANNOUNCEMENTS"] = {}
		end

		local hour,minute = GetGameTime();
		local actualTime = hour*100 + minute
		local calendarTime = C_Calendar.GetDate();
		local actualDate = string.format("%04u%02u%02u",calendarTime.year,calendarTime.month,calendarTime.monthDay)
		
		-- calculate time values
		if (not time_start) then
			time_start = actualTime			
		elseif (time_start > 2359) or (0 == time_start) then
			time_start = actualTime
		end
		
		if (not time_end) then
			time_end = 2359			
		elseif (time_end > 2359) or (0 == time_end) or (time_end < time_start) then
			time_end = 2359
		end
		
		if (time_duration) then
			if (time_duration > 0) then
				time_end = time_start + time_duration
				if (time_end > 2359) then
					time_end = 2359
				end
			end
		end
		
		if (time_end < time_start) then
		
		end

		GnomTEC_CityMaps_Announcements[poi]["ANNOUNCEMENTS"][player.."-"..realm] = {
			["ANNOUNCEMENT"] = announcement,
			["DATE"] = actualDate,
			["TIME_START"] = time_start,
			["TIME_END"] = time_end,			
		}
		
		GnomTEC_CityMaps:CleanupAnnouncement()
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
function GnomTEC_CityMaps:CHAT_MSG_CHANNEL(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_EMOTE(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_GUILD(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_OFFICER(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_PARTY(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_RAID(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_SAY(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_TEXT_EMOTE(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_WHISPER(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

function GnomTEC_CityMaps:CHAT_MSG_YELL(eventName, message, sender)	
	GnomTEC_CityMaps:CheckAnnouncement(sender, message)
end

-- ----------------------------------------------------------------------
-- Addon OnInitialize, OnEnable and OnDisable
-- ----------------------------------------------------------------------

-- function called on initialization of addon
function GnomTEC_CityMaps:OnInitialize()
 	-- Code that you want to run when the addon is first loaded goes here.
	self.db = LibStub("AceDB-3.0"):New("GnomTEC_CityMapsDB")

  	GnomTEC_RegisterAddon()
  	GnomTEC_LogMessage(LOG_INFO, "Willkommen bei GnomTEC_CityMaps")
  	  	
end

-- function called on enable of addon
function GnomTEC_CityMaps:OnEnable()
    -- Called when the addon is enabled
	local realm = GetRealmName()

	GnomTEC_LogMessage(LOG_INFO, "GnomTEC_CityMaps Enabled")

	-- Initialize options which are propably not valid because they are new added in new versions of addon
	if (not self.db.char.displayedMap) then
		self.db.char.displayedMap = "Ironforge"			
	end
		
	-- set local parameters
	
	-- initialize global data which yet is empty
	if not GnomTEC_CityMaps_UsedBy[realm] then
		GnomTEC_CityMaps_UsedBy[realm] = {}
		GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Ironforge", true)
		GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Stormwind", true)
		GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Darnassus", true)		
		GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Dalaran", true)		
	end
	
	-- initialize map
	GnomTEC_CityMaps:SetMap(self.db.char.displayedMap)

	-- update static data with defaults	when defaults are used
	GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Ironforge", GnomTEC_CityMaps:GetStaticDataIsDefault(realm, "Ironforge"))
	GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Stormwind", GnomTEC_CityMaps:GetStaticDataIsDefault(realm, "Stormwind"))
	GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Darnassus", GnomTEC_CityMaps:GetStaticDataIsDefault(realm, "Darnassus"))
	GnomTEC_CityMaps:SetStaticDataIsDefault(realm, "Dalaran", GnomTEC_CityMaps:GetStaticDataIsDefault(realm, "Dalaran"))
		
	-- initialize hooks and events
	table.insert( msp.callback.received, GnomTEC_CityMaps_MSPcallback )
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_CHANNEL");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_EMOTE");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_GUILD");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_OFFICER");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_PARTY");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_RAID");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_SAY");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_TEXT_EMOTE");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_WHISPER");
	GnomTEC_CityMaps:RegisterEvent("CHAT_MSG_YELL");

	-- initialize some parts of GUI 
	GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton:HookScript("OnClick",GNOMTEC_CITYMAPS_FRAME_INFO_CloseButton_OnClick);
	
	-- setup POI data base with informations from MSP flags
	if GnomTEC_CityMaps_Flags[realm] then
		local key, value
		for key,value in pairs(GnomTEC_CityMaps_Flags[realm]) do
			GnomTEC_CityMaps:UpdatePOI(realm, key)
		end
	end	
	
	-- cleanup announcements
	GnomTEC_CityMaps:CleanupAnnouncement()	
end

-- function called on disable of addon
function GnomTEC_CityMaps:OnDisable()
    -- Called when the addon is disabled
    GnomTEC_CityMaps:UnregisterAllEvents();
    
    table.vanish( msp.callback.received, GnomTEC_CityMaps_MSPcallback )
end

-- ----------------------------------------------------------------------
-- External API
-- ----------------------------------------------------------------------
