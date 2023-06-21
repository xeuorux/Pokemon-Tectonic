def progressGrindableTrainerStage
    $game_variables[32] += 1
    $MapFactory.getMap($game_map.map_id, false).need_refresh = true
    echoln("Progressing the grindable trainer stage.")
end

# Progress the grindable trainer stage when moving into the next gym town
# After having defeated the previous gym
Events.onMapChange += proc { |_sender,_e|
    mapID = $game_map.map_id

    grindableTrainerLocations = [
        56, # Novo Town
        6, # LuxTech Campus
        8, # Velenz
        155, # Prizca West
        187, # Prizca East
        217, # Sweetrock Harbor
        214, # Team Chasm HQ
        318, # Tournament Grounds
    ]

    next unless grindableTrainerLocations.include?(mapID)

    locationIndex = grindableTrainerLocations.index(mapID) + 1
    if locationIndex == $game_variables[32] && hasAllBadgesUpTo?(locationIndex)
        progressGrindableTrainerStage
    end
}