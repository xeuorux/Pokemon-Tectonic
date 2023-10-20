Events.onWildPokemonCreate += proc {|sender,e|
    pokemon = e[0]
    next unless $game_map.map_id == 20 # Alloyed Thicket maps
    chance = 10
    chance *= 2 if herdingActive?
    next unless rand(100) < chance
    pokemon.setItems([:ALLOYEDLUMP])
}