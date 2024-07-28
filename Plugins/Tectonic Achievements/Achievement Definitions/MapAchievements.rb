Events.onMapLoadIn += proc { |_sender,_e|
    mapID = $game_map.map_id

    next unless mapID == 155 # Prizca West
    next if pbGetSelfSwitch(28,'A',11) # Avatar of Terrakion defeated

    unlockAchievement(:REACH_PRIZCA_WEST_BEFORE_TERRAKION)
}

Events.onMapLoadIn += proc { |_sender,_e|
    mapID = $game_map.map_id

    next unless mapID == 331 # Frostflow Farms Center
    next if pbHasItem?(:SURFBOARD)

    unlockAchievement(:REACH_FROSTFLOW_CENTER_BEFORE_SURF)
}