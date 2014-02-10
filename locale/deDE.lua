local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GnomTEC_CityMaps", "deDE")
if not L then return end

L["L_SHOWMAP"] = "Karte anzeigen"
L["L_OPTIONS_VIEW"] = "Anzeigeoptionen"
L["L_OPTIONS_VIEW_SHOWSTATICDATA"] = "Nutze zur Anzeige der Gebäudebelegung die internen, statischen Daten"
L["L_OPTIONS_VIEW_SHOWMSPDATA"] = "Nutze zur Anzeige der Gebäudebelegung Daten aus den RP-Flags der Spieler"
L["L_OPTIONS_VIEW_SHOWPOILABEL"] ="Zeige POI-Labels anstatt Icons"
L["L_OPTIONS_DATA"] = "Statische Gebäudebelegungsdaten"
L["L_OPTIONS_DATA_IRONFORGE"] ="Daten für Eisenschmiede"
L["L_OPTIONS_DATA_STORMWIND"] ="Daten für Sturmwind"