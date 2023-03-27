class PokemonEvolutionScene
    def pbEvolutionSuccess
        # Play cry of evolved species
        frames = GameData::Species.cry_length(@newspecies, @pokemon.form)
        pbBGMStop
        Pokemon.play_cry(@newspecies, @pokemon.form)
        frames.times do
            Graphics.update
            pbUpdate
        end
        # Success jingle/message
        pbMEPlay("Evolution success")
        newspeciesname = GameData::Species.get(@newspecies).name
        pbMessageDisplay(@sprites["msgwindow"],
           _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
           @pokemon.name, newspeciesname)) { pbUpdate }
        @sprites["msgwindow"].text = ""
        # Check for consumed item and check if Pokémon should be duplicated
        pbEvolutionMethodAfterEvolution

        showPokemonChanges(@pokemon) do
            @pokemon.species = @newspecies
            @pokemon.form    = 0 if @pokemon.isSpecies?(:MOTHIM)
            @pokemon.calc_stats
        end

        # See and own evolved species
        $Trainer.pokedex.register(@pokemon)
        $Trainer.pokedex.set_owned(@newspecies)
        # Learn moves upon evolution for evolved species
        movelist = @pokemon.getMoveList
        for i in movelist
            next if i[0] != 0 && i[0] != @pokemon.level # 0 is "learn upon evolution"
            pbLearnMove(@pokemon, i[1], true) { pbUpdate }
        end
    end
end

def pbTopRightWindow(text, scene = nil, givenWidth = 198)
    window = Window_AdvancedTextPokemon.new(text)
    window.width = givenWidth
    window.x     = Graphics.width - window.width
    window.y     = 0
    window.z     = 99_999
    pbPlayDecisionSE
    loop do
        Graphics.update
        Input.update
        window.update
        scene.pbUpdate if scene
        break if Input.trigger?(Input::USE)
    end
    window.dispose
end

def showPokemonChanges(pokemon, &block)
    # Mark down pre-change stats
    oldTotalHP = pokemon.totalhp
    oldAttack = pokemon.attack
    oldDefense = pokemon.defense
    oldSpAtk = pokemon.spatk
    oldSpDef = pokemon.spdef
    oldSpeed = pokemon.speed
    # Mark down pre-change ability
    oldAbility = pokemon.ability
    # Modify Pokémon to make it evolved
    block.call
    # Show the stat changes
    hpDif = pokemon.totalhp - oldTotalHP
    hpDifStr = hpDif.to_s
    hpDifStr += " / " + (((hpDif.to_f / oldTotalHP.to_f) * 1000).ceil / 10.0).to_s + "%" if $DEBUG
    attackDif = pokemon.attack - oldAttack
    attackDifStr = attackDif.to_s
    attackDifStr += " / " + (((attackDif.to_f / oldAttack.to_f) * 1000).ceil / 10.0).to_s + "%" if $DEBUG
    defenseDif = pokemon.defense - oldDefense
    defenseDifStr = defenseDif.to_s
    defenseDifStr += " / " + (((defenseDif.to_f / oldDefense.to_f) * 1000).ceil / 10.0).to_s + "%" if $DEBUG
    spAtkDif = pokemon.spatk - oldSpAtk
    spAtkDifStr = spAtkDif.to_s
    spAtkDifStr += " / " + (((spAtkDif.to_f / oldSpAtk.to_f) * 1000).ceil / 10.0).to_s + "%" if $DEBUG
    spDefDif = pokemon.spdef - oldSpDef
    spDefDifStr = spDefDif.to_s
    spDefDifStr += " / " + (((spDefDif.to_f / oldSpDef.to_f) * 1000).ceil / 10.0).to_s + "%" if $DEBUG
    speedDif = pokemon.speed - oldSpeed
    speedDifStr = speedDif.to_s
    speedDifStr += " / " + (((speedDif.to_f / oldSpeed.to_f) * 1000).ceil / 10.0).to_s + "%" if $DEBUG
    if hpDif != 0 || attackDif != 0 || defenseDif != 0 ||
       spAtkDif != 0 || spDefDif != 0 || speedDif != 0
        pbTopRightWindow(
            _INTL("Max. HP<r>#{hpDif >= 0 ? '+' : ''}{1}\r\nAttack<r>#{attackDif >= 0 ? '+' : ''}{2}\r\nDefense<r>#{defenseDif >= 0 ? '+' : ''}{3}\r\nSp. Atk<r>#{spAtkDif >= 0 ? '+' : ''}{4}\r\nSp. Def<r>#{spDefDif >= 0 ? '+' : ''}{5}\r\nSpeed<r>#{speedDif >= 0 ? '+' : ''}{6}",
            hpDifStr, attackDifStr, defenseDifStr,
            spAtkDifStr, spDefDifStr, speedDifStr), nil, $DEBUG ? 260 : 198)
        pbTopRightWindow(
            _INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
            pokemon.totalhp, pokemon.attack, pokemon.defense, pokemon.spatk, pokemon.spdef, pokemon.speed), nil, $DEBUG ? 300 : 198)
    end
    # Show new ability if any
    if pokemon.ability != oldAbility
        ability_name = GameData::Ability.get(pokemon.ability).real_name
        pbMessage(_INTL("{1}'s ability was changed to {2}.", pokemon.name, ability_name))
    end
end
