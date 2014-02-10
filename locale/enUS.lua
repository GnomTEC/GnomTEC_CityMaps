-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("GnomTEC_CityMaps", "enUS", true)
if not L then return end

L["L_SHOWMAP"] = "Show map"
L["L_OPTIONS_VIEW"] = "Display options"
L["L_OPTIONS_VIEW_SHOWSTATICDATA"] = "Use internal, static data for display of building usage"
L["L_OPTIONS_VIEW_SHOWMSPDATA"] = "Use data from rp flags for display of building usage"
L["L_OPTIONS_DATA"] = "Management of static data of building usage"
L["L_OPTIONS_DATA_IRONFORGE"] ="Data for Ironforge"