class TribalBonus
    attr_reader :tribeCounts
    attr_reader :tribesGivingBonus
    attr_accessor :trainer

    def initialize(trainer)
        @trainer = trainer
        updateTribeCount
    end

    def resetTribeCounts()
        @tribeCounts = {}
        @tribesGivingBonus = []
        # Reset all counts
        GameData::Tribe.each do |tribe|
            @tribeCounts[tribe.id] = 0
        end
    end

    def updateTribeCount()
        resetTribeCounts()

        # Count all tribes that exist for pokemon in player's party
        @trainer.party.each {|pokemon|
            tribes = pokemon.tribes
            tribes.each {|tribe|
                next if !@tribeCounts.has_key?(tribe)
                @tribeCounts[tribe] += 1
            }
        }
        
        GameData::Tribe.each do |tribeData|
            next unless @tribeCounts[tribeData.id] >= tribeData.threshold
            @tribesGivingBonus.push(tribeData.id)
        end
    end

    def getActiveBonusesList(concat = true, foe = false)
        list = []
        @tribesGivingBonus.each do |tribeID|
            description = getTribeName(tribeID)
            description += _INTL(" Tribe") if concat
            description += _INTL(" [O]") if foe
            list.push(description)
        end

        return list
    end

    def self.initStatBonusHash
        newBonusHash = {
            :HP => 0,
            :ATTACK => 0,
            :DEFENSE => 0,
            :SPECIAL_ATTACK => 0,
            :SPECIAL_DEFENSE => 0,
            :SPEED => 0,
        }
        return newBonusHash
    end

    def getTribeBonusStats(level)
        # Returns a hash of all bonuses given the current pokemon
        tribeBonuses = TribalBonus.initStatBonusHash

        if hasTribeBonus?(:LOYAL)
            smallBonus = getSingleStatBonusSmall(level)
            GameData::Stat.each_main_battle do |stat|
                tribeBonuses[stat.id] = smallBonus
            end
        end

        if hasTribeBonus?(:INDUSTRIOUS) && (!@trainer.is_a?(Player) || @trainer.money >= 100_000)
            mediumBonus = getSingleStatBonusMedium(level)
            GameData::Stat.each_main_battle do |stat|
                tribeBonuses[stat.id] = mediumBonus
            end
        end

        return tribeBonuses
    end

    def getSingleStatBonusSmall(level)
        return 5 + (level / 14).floor
    end

    def getSingleStatBonusMedium(level)
        return 8 + (level / 10).floor
    end

    def getSingleStatBonusLarge(level)
        return 10 + (level / 8).floor
    end

    def hasTribeBonus?(tribeID)
        return @tribesGivingBonus.include?(tribeID)
    end
end

class Pokemon
    def tribes
        if hasAbility?(:FRIENDTOALL) || hasItem?(:WILDCARD)
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

def playerTribalBonus()
    $Trainer.tribalBonus = TribalBonus.new($Trainer) unless $Trainer.tribalBonus
    $Trainer.tribalBonus.trainer = $Trainer unless $Trainer.tribalBonus.trainer
    return $Trainer.tribalBonus
end

def getTribeName(tribe_id)
    name = tribe_id.downcase
    name = name[0].upcase + name[1...]
    return name
end