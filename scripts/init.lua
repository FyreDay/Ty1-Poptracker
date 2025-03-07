
local variant = Tracker.ActiveVariantUID

-- Items
require("scripts/items_import")

-- Logic
require("scripts/logic/logic_helper")
require("scripts/logic/logic_main")

-- Maps
if Tracker.ActiveVariantUID == "maps-u" then
    Tracker:AddMaps("maps/maps-u.json")  
else
    Tracker:AddMaps("maps/maps.jsonc")  
end  

if PopVersion and PopVersion >= "0.23.0" then
    Tracker:AddLocations("locations/dungeons.json")
end

-- Layout
require("scripts/layouts_import")

-- Locations
Tracker:AddLocations("locations/rainbowcliffs_locs.jsonc")
Tracker:AddLocations("locations/twoup_locs.jsonc")
Tracker:AddLocations("locations/witp_locs.jsonc")
Tracker:AddLocations("locations/shiprex_locs.jsonc")
Tracker:AddLocations("locations/botrt_locs.jsonc")
Tracker:AddLocations("locations/snowworries_locs.jsonc")
Tracker:AddLocations("locations/outbacksafari_locs.jsonc")
Tracker:AddLocations("locations/lyrelyre_locs.jsonc")
Tracker:AddLocations("locations/btbs_locs.jsonc")
Tracker:AddLocations("locations/rmts_locs.jsonc")

Tracker:AddLocations("locations/other_locs.jsonc")
-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.26.0" then
    require("scripts/autotracking")
end