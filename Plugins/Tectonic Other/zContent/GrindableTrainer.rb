def progressGrindableTrainerStage
    $game_variables[32] += 1
    $MapFactory.getMap($game_map.map_id, false).need_refresh = true
    echoln("Progressing the grindable trainer stage.")
end

def setGrindableTrainerStage(value)
    $game_variables[32] = value
    $MapFactory.getMap($game_map.map_id, false).need_refresh = true
    echoln("Progressing the grindable trainer to stage #{value}.")
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
    nextStage = locationIndex + 1
    if $game_variables[32] < nextStage && hasAllBadgesUpTo?(locationIndex)
        setGrindableTrainerStage(nextStage)
    end
}