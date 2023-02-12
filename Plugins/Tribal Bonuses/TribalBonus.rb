class TribalBonus
    attr_reader :tribeCounts

    TRIBAL_BONUS_THRESHOLD = 5

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
            tribes = pokemon.tribes
            tribes.each {|tribe|
                next if !@tribeCounts.has_key?(tribe)
                @tribeCounts[tribe] += 1
            }
        }
    end

    def getActiveBonusesList(concat = true)
        updateTribeCount()

        list = []
        GameData::Tribe.each do |tribeData|
            next unless @tribeCounts[tribeData.id] >= TRIBAL_BONUS_THRESHOLD
            description = TribalBonus.getTribeName(tribeData.id)
            description += _INTL(" Tribe Bonus") if concat
            list.push(description)
        end

        return list
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

        pokemon.tribes.each { |tribe|
            next unless @tribeCounts[tribe] >= TRIBAL_BONUS_THRESHOLD
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

class Pokemon
    def tribes
        if @ability == :FRIENDTOALL || @item == :WILDCARD
            list = []
            GameData::Tribe.each do |tribeData|
                list.push(tribeData.id)
            end
            return list
        end
        fSpecies = GameData::Species.get_species_form(@species, @form)
        return fSpecies.tribes
    end
end