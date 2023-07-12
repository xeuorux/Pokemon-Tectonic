Events.onWildPokemonCreate += proc {|sender,e|
    pokemon = e[0]
    next unless $game_map.map_id == 20 # Alloyed Thicket maps
    next unless rand(100) < 20
    pokemon.setItems([:ALLOYEDLUMP])
}