class TribalBonus
    attr_reader :tribeCounts
    attr_reader :tribesGivingBonus
    attr_accessor :trainer

    TRIBAL_BONUS_THRESHOLD = 5

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
            next unless @tribeCounts[tribeData.id] >= TRIBAL_BONUS_THRESHOLD
            @tribesGivingBonus.push(tribeData.id)
        end
    end

    def getActiveBonusesList(concat = true, foe = false)
        #updateTribeCount()

        list = []
        @tribesGivingBonus.each do |tribeID|
            description = TribalBonus.getTribeName(tribeID)
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

    def getTribeBonuses(level)
        # Returns a hash of all bonuses given the current pokemon
        tribeBonuses = TribalBonus.initStatBonusHash

        @tribesGivingBonus.each do |tribeID|
            GameData::Stat.each_main_battle do |stat|
                tribeBonuses[stat.id] = 5 + (level / 14).floor
            end
        end

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

def playerTribalBonus()
    unless $Trainer.tribalBonus
        $Trainer.tribalBonus = TribalBonus.new($Trainer)
    end
    unless $Trainer.tribalBonus.trainer
        $Trainer.tribalBonus.trainer = $Trainer
    end
    return $Trainer.tribalBonus
end