def useChromaClarion
    unless $PokemonEncounters.encounter_type
        pbMessage(_INTL("The Chroma Clarion cannot be used here!"))
        return 0
    end

    unless $Trainer.able_pokemon_count >= 3
        pbMessage(_INTL("You must have at least 3 able Pokémon to use the Chroma Clarion!"))
        return 0
    end

    unless $PokemonGlobal.chroma_clarion_recharge_steps <= 0
        pbMessage(_INTL("The Chroma Clarion is silent. Traverse wild areas to recharge it."))
        return 0
    end

    encounter_type = $PokemonEncounters.encounter_type
    
    encounters = []
    3.times do |i|
        species, level = $PokemonEncounters.choose_wild_pokemon(encounter_type)
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

    pbWildBattleCore(*encounters)

    $PokemonGlobal.chroma_clarion_recharge_steps = 30
    pbMessage(_INTL("The Chroma Clarion goes silent."))

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

Events.onStepTaken += proc { |_sender,_e|
    if $PokemonEncounters.encounter_type && !$PokemonEncounters.encounters_blocked?(true)
        $PokemonGlobal.chroma_clarion_recharge_steps = 0 if $PokemonGlobal.chroma_clarion_recharge_steps.nil?
        if $PokemonGlobal.chroma_clarion_recharge_steps > 0
            $PokemonGlobal.chroma_clarion_recharge_steps -= 1
            if $PokemonGlobal.chroma_clarion_recharge_steps <= 0
                pbMessage(_INTL("The Chroma Clarion returns to life, emitting a pleasing tone."))
            end
        end
    end
}