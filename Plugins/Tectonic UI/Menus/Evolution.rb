class PokemonEvolutionScene
    def pbEndScreen
        pbDisposeMessageWindow(@sprites["msgwindow"])
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
        @bgviewport.dispose
        @msgviewport.dispose
        $PokemonTemp.dependentEvents.refresh_sprite(false)
    end

    # Opens the evolution screen
    def pbEvolution(cancancel = true)
        metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
        metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
        metaplayer1.play
        metaplayer2.play
        pbBGMStop
        @pokemon.play_cry
        pbMessageDisplay(@sprites["msgwindow"],
           _INTL("\\se[]What? {1} is evolving!\\^", @pokemon.name)) { pbUpdate }
        pbMessageWaitForInput(@sprites["msgwindow"], 50, true) { pbUpdate }
        pbPlayDecisionSE
        oldstate  = pbSaveSpriteState(@sprites["rsprite1"])
        oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])
        pbMEPlay("Evolution start")
        pbBGMPlay("Evolution")
        canceled = false
        begin
            pbUpdateNarrowScreen
            metaplayer1.update
            metaplayer2.update
            Graphics.update
            Input.update
            pbUpdate(true)
            if Input.trigger?(Input::BACK) && cancancel
                pbBGMStop
                pbPlayCancelSE
                canceled = true
                break
            end
        end while metaplayer1.playing? && metaplayer2.playing?
        pbFlashInOut(canceled, oldstate, oldstate2)
        if canceled
            pbMessageDisplay(@sprites["msgwindow"],
               _INTL("Huh? {1} stopped evolving!", @pokemon.name)) { pbUpdate }
            return false
        else
            pbEvolutionSuccess
            return true
        end
    end

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
        unless $PokemonSystem.prompt_level_moves == 1
            movelist = @pokemon.getMoveList
            for i in movelist
                next if i[0] != 0 && i[0] != @pokemon.level # 0 is "learn upon evolution"
                pbLearnMove(@pokemon, i[1], true) { pbUpdate }
            end
        end

        @pokemon.changeHappiness("evolution")
    end

    def self.pbDuplicatePokemon(pkmn, new_species)
        new_pkmn = pkmn.clone
        new_pkmn.species   = new_species
        new_pkmn.name      = nil
        new_pkmn.markings  = 0
        new_pkmn.poke_ball = :POKEBALL
        new_pkmn.removeItems
        new_pkmn.clearAllRibbons
        new_pkmn.calc_stats
        new_pkmn.heal
        # Add duplicate Pokémon to party
        $Trainer.party.push(new_pkmn)
        # See and own duplicate Pokémon
        $Trainer.pokedex.register(new_pkmn)
        $Trainer.pokedex.set_owned(new_species)
    end
end