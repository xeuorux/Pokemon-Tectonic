class TribalBonus
    attr_reader :tribeCounts

    def initialize
        resetTribeCounts()
    end

    def resetTribeCounts()
        @tribeCounts = {}
        # Reset all counts
        GameData::Tribe.each do |tribe|
            @tribeCounts[tribe.id] = 0
        end
    end

    def updateTribeCount()
        resetTribeCounts()

        # Count all tribes that exist for pokemon in player's party
        $Trainer.party.each {|pokemon|
            form = pokemon.form
            species = pokemon.species
            fSpecies = GameData::Species.get_species_form(species, form)
            tribes = fSpecies.tribes
            tribes.each {|tribe|
                next if !@tribeCounts.has_key?(tribe)
                @tribeCounts[tribe] += 1
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
        tribes = fSpecies.tribes
        tribes.each { |tribe|
            next unless @tribeCounts[tribe] >= 5
            GameData::Stat.each_main_battle do |stat|
                tribeBonuses[stat.id] = 5 + (pokemon.level / 14).floor
            end
        }

        return tribeBonuses
    end

    def self.getTribeName(tribe_id)
        name = tribe_id.downcase
        name = name[0].upcase + name[1...]
        return name
    end
end

