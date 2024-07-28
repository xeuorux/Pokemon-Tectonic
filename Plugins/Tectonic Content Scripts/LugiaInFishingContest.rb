Events.onWildPokemonCreate += proc {|sender,e|
    next unless $game_map.map_id == 239 && $catching_minigame.active? # Ocean fishing contest
    next if $Trainer.pokedex.owned?(:LUGIA)

    chance = 1
    chance *= 2 if $catching_minigame.highScore > 0
    chance *= 2 if $catching_minigame.highScore > 40
    chance *= 2 if $catching_minigame.highScore > 80
    chance *= 2 if herdingActive?

    next unless rand(200) < chance

    pokemon = e[0]
    overwriteWildPokemonSpecies(pokemon,:LUGIA)
    pokemon.level = [getLevelCap,45].min
    pokemon.reset_moves
}

Events.onWildPokemonCreate += proc {|sender,e|
    next unless $catching_minigame.active? # Ocean fishing contest
    pokemon = e[0]
    pokemon.shinyRolls *= 2
}