def useChromaClarion
    unless $PokemonEncounters.encounter_type
        pbMessage(_INTL("The Chroma Clarion cannot be used here!"))
        return 0
    end

    unless $Trainer.able_pokemon_count >= 3
        pbMessage(_INTL("You must have at least 3 able Pokémon to use the Chroma Clarion!"))
        return 0
    end

    encounter_type = $PokemonEncounters.encounter_type
    
    encounters = []
    3.times do |i|
        species, level = $PokemonEncounters.choose_wild_pokemon(encounter_type)
        level += 5
        pkmn = pbGenerateWildPokemon(species,level,false,true)

        pkmn.shinyRolls *= 2

        if rand(100) < 50
            pkmn.reset_moves
            move = getRandomNonLevelMove(species)
            pkmn.learn_move(move)
        end
        
        encounters.push(pkmn)
    end

    pbSEPlay("Anim/PRSFX- Mega Evolution Rayquaza3",150,60)

    pbWait(40)

    if $catching_minigame.active?
        pbCatchingMinigameWildBattleCore(*encounters)
    else
        pbWildBattleCore(*encounters)
    end

    #$PokemonGlobal.chroma_clarion_recharge_steps = 30
    #pbMessage(_INTL("The Chroma Clarion goes silent."))

    return 1
end

ItemHandlers::UseFromBag.add(:CHROMACLARION,proc { |item|
	next useChromaClarion
})

ItemHandlers::ConfirmUseInField.add(:CHROMACLARION,proc { |item|
    next true
})

ItemHandlers::UseInField.add(:CHROMACLARION,proc { |item|
	next useChromaClarion
})