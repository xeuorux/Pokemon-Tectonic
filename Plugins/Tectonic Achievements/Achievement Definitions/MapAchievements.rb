Events.onMapChange += proc { |_sender,_e|
    mapID = $game_map.map_id

    next unless mapID == 155 # Prizca West
    next if pbGetSelfSwitch(28,'A',11) # Avatar of Terrakion defeated

    $unlockPrizcaWestBeforeTerrakionAchievement = true
}

Events.onMapChange += proc { |_sender,_e|
    mapID = $game_map.map_id

    next unless mapID == 331 # Frostflow Farms Center
    next if pbHasItem?(:SURFBOARD)

    $unlockFrostflowBeforeSurfAchievement = true
    
}

Events.onStepTaken += proc { |_sender,_e|
    if $unlockPrizcaWestBeforeTerrakionAchievement
        unlockAchievement(:PRIZCA_WEST_BEFORE_TERRAKION)
        $unlockPrizcaWestBeforeTerrakionAchievement = false
    end

    if $unlockFrostflowBeforeSurfAchievement
        unlockAchievement(:FROSTFLOW_CENTER_BEFORE_SURF)
        $unlockFrostflowBeforeSurfAchievement = false
    end
}