Events.onMapLoadIn += proc { |_sender,_e|
    mapID = $game_map.map_id

    next unless $PokEstate.isInEstate?
    currentBox = $PokEstate.estate_box
    next unless $PokemonStorage[currentBox].full?

    unlockAchievement(:FILL_ENTIRE_POKESTATE_PLOT)
}