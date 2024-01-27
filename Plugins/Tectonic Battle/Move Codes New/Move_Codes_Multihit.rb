#===============================================================================
# Hits twice.
#===============================================================================
class PokeBattle_Move_0BD < PokeBattle_Move
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

#===============================================================================
# Hits twice as Beedrill and four times as Wornet. (Multi-Needle)
#===============================================================================
class PokeBattle_Move_0BE < PokeBattle_Move
    def multiHitMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:BEEDRILL) && !user.countsAs?(:WORNET)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no stingers!"))
            end
            return true
        end
        return false
    end
    
    def pbNumHits(user, _targets, _checkingForAI = false)
        if user.countsAs?(:WORNET)
            return 5
        elsif user.countsAs?(:BEEDRILL)
            return 3
        end
    end
end

#===============================================================================
# Hits 2-5 times.
#===============================================================================
module RandomHitable
    def multiHitMove?; return true; end

    def pbNumHits(user, _targets, _checkingForAI = false)
        if user.hasActiveItem?(:LOADEDDICE)
            hitChances = [4, 5]
        else
            hitChances = [2, 2, 3, 3, 4, 5]
        end
        if user.hasActiveAbility?(%i[SKILLLINK PERFECTLUCK])
            numHits = hitChances.last
        else
            numHits = hitChances.sample
        end
        return numHits
    end

    def pbNumHitsAI(user, _targets)
        return 5 if user.hasActiveAbilityAI?(%i[SKILLLINK PERFECTLUCK])
        return 4.5 if user.hasActiveItem?(:LOADEDDICE)
        return 19.0 / 6.0 # Average
    end
end

class PokeBattle_Move_0C0 < PokeBattle_Move
    include RandomHitable
end

#===============================================================================
# Hits X times, where X is the number of non-user unfainted status-free Pokémon
# in the user's party (not including partner trainers). Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
#===============================================================================
class PokeBattle_Move_0C1 < PokeBattle_PartyAttackMove
    def initialize(battle, move)
        super
        @statUsed = :ATTACK
    end
end

#===============================================================================
# Hits X times, where X is the number of non-user unfainted status-free Pokémon
# in the user's party (not including partner trainers). Fails if X is 0.
# Base power of each hit depends on the base Sp. Atk stat for the species of that
# hit's participant. (Volley)
#===============================================================================
class PokeBattle_Move_129 < PokeBattle_PartyAttackMove
    def initialize(battle, move)
        super
        @statUsed = :SPECIAL_ATTACK
    end
end