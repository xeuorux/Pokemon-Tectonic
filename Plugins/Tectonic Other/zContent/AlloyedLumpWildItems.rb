Events.onWildPokemonCreate += proc {|sender,e|
    pokemon = e[0]
    next unless [182,304,365,375].include?($game_map.map_id) # Alloyed Thicket maps
    next unless rand(100) < 20
    pokemon.setItems([:ALLOYEDLUMP])
}