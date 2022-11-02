class TribalBonus
    attr_reader :tribeCounts

    def initialize
        resetTribeCounts()
    end

    def resetTribeCounts()
        @tribeCounts = {}
        # Reset all counts
        TRIBAL_DEFINITIONS.keys.each do |tribe_id|
            @tribeCounts[tribe_id] = 0
        end
    end

    def updateTribeCount()
        resetTribeCounts()

        # Count all tribes that exist for pokemon in player's party
        $Trainer.party.each {|pokemon|
            form = pokemon.form
            species = pokemon.species
            fSpecies = GameData::Species.get_species_form(species, form)
            compatibilities = fSpecies.compatibility
            compatibilities.each {|compatibility|
                next if !@tribeCounts.has_key?(compatibility)
                @tribeCounts[compatibility] += 1
            }
        }
    end

    def getTribeBonuses(pokemon)
        # Returns a hash of all bonuses given the current pokemon
        tribeBonuses = {
            :HP => 0,
            :ATTACK => 0,
            :DEFENSE => 0,
            :SPECIAL_ATTACK => 0,
            :SPECIAL_DEFENSE => 0,
            :SPEED => 0,
        }

        form = pokemon.form
        species = pokemon.species
        fSpecies = GameData::Species.get_species_form(species, form)
        compatibilities = fSpecies.compatibility
        compatibilities.each {|compatibility|
            next if !TRIBAL_DEFINITIONS.has_key?(compatibility)
            tribalBonusDefinition = TRIBAL_DEFINITIONS[compatibility]
            tribalThresholdDefinitions = tribalBonusDefinition[1]
            tribalThresholdDefinitions.each do |tribalThresholdDefinition|
                threshold = tribalThresholdDefinition[0]
                next if @tribeCounts[compatibility] < threshold

                thresholdStatBonuses = tribalThresholdDefinition[1]
                thresholdStatBonuses.each do |stat, bonus|
                    tribeBonuses[stat] += bonus
                end
            end
        }

        return tribeBonuses
    end

    def tribes
        return TRIBAL_DEFINITIONS.keys
    end

    def getTribeName(tribe_id)
        return TRIBAL_DEFINITIONS[tribe_id][0] || ""
    end
end
