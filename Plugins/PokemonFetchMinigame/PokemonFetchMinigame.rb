class PokemonFetchingMinigame
    attr_reader :target_species_data
    attr_reader :rerolls_available

    def initialize()
        @target_species_data = nil
        @rerolls_available = 1
    end

    def talkToFetchRequester()
        if $Trainer.able_pokemon_count == 1 && DONATE_POKEMON
            pbMessage("You only have one Pokemon with you. I couldn't possibly take it from you!")
        elsif !@target_species_data.nil?
            discussExistingRequest()
        else
            if DONATE_POKEMON
                pbMessage("Would you like to ")
            end
        end
    end

    def discussExistingRequest()
        pbMessage(_INTL("Do you have a #{target_species_data.real_name} for me?"))
        pbMessage()
        pbChoosePokemon(1,3, proc { |poke|
            poke.species == @target_species_data.species
        })

        if pbGet(1) == -1
            pbMessage(_INTL("Come back when you have a #{target_species_data.real_name} for me."))
        else
            chosenPokemon = $Trainer.party[pbGet(1)]
            if DONATE_POKEMON
                if pokemon.egg?
                    pbDisplay(_INTL("You can't donate an Egg."))
                    return
                end
                return unless pbConfirmMessageSerious(_INTL("Are you sure you want to donate {1}?",chosenPokemon.name))
            end
            pbMessage(_INTL("Amazing, what an interesting species!"))
            pbMessage(_INTL("Here's your reward!"))
            giveReward(chosenPokemon.species)
            @target_species_data = nil
        end
    end

    def giveReward(species)
        value = speciesValue(species)

        items = nil
        case value
        when 0..10
            items = [[:GREATBALL,2],:EXPCANDYS,:MAXREPEL,:PRETTYFEATHER]
        when 11..20
            items = [[:ULTRABALL,2],:EXPCANDYM,:RELICCOPPER,:MAXREVIVE]
        when 21..30
            items = [[:REPEATBALL,2],:EXPCANDYL,:RAREBONE]
        when 31..40
            items = [:MASTERBALL,:EXPCANDYXL,:COMETSHARD]
        end

        item = items.sample

        if item.is_a?(Array)
            pbReceiveItem(item[0],item[1])
        else
            pbReceiveItem(item)
        end
    end

    def speciesValue(species)
        speciesData = GameData::Species.get(species)
        rareness = Math.sqrt(255 / speciesData.catch_rate)

        levelAccessible = 10

        score = (rareness * levelAccessible) / 3
        return score.ceil
    end
end