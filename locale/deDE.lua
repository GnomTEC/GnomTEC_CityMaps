local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GnomTEC_CityMaps", "deDE")
if not L then return end

L["L_SHOWMAP"] = "Karte anzeigen"
L["L_OPTIONS_VIEW"] = "Anzeigeoptionen"
L["L_OPTIONS_VIEW_SHOWSTATICDATA"] = "Nutze zur Anzeige der Gebäudebelegung die internen, statischen Daten"
L["L_OPTIONS_VIEW_SHOWMSPDATA"] = "Nutze zur Anzeige der Gebäudebelegung Daten aus den RP-Flags der Spieler"