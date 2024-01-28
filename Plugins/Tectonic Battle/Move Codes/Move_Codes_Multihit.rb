#===============================================================================
# Hits twice.
#===============================================================================
class PokeBattle_Move_0BD < PokeBattle_Move
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

#===============================================================================
# Hits thrice.
#===============================================================================
class PokeBattle_Move_500 < PokeBattle_Move
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 3; end
end

#===============================================================================
# Hits 3 times and always critical. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_Move_0A0
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 3; end
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
# This move is physical if user's Attack is higher than its Special Attack (Multi-Strike)
# It hits between 2-5 times in a row.
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_Move
    include RandomHitable

    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end
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

#===============================================================================
# Hits in 2 volleys. The second volley targets the original target's ally if it
# has one (that can be targeted), or the original target if not. A battler
# cannot be targeted if it is is immune to or protected from this move somehow,
# or if this move will miss it. (Dragon Darts)
# NOTE: This move sometimes shows a different failure message compared to the
#       official games. This is because of the order in which failure checks are
#       done (all checks for each target in turn, versus all targets for each
#       check in turn). This is considered unimportant, and since correcting it
#       would involve extensive code rewrites, it is being ignored.
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move_0BD
    def pbNumHits(_user, _targets, checkingForAI = false)
        if checkingForAI
            return 2
        else
            return 1
        end
    end

    # Hit again if only at the 0th hit
    def pbRepeatHit?(hitNum = 0)
        return hitNum < 1
    end

    def pbModifyTargets(targets, user)
        return if targets.length != 1
        choices = []
        targets[0].eachAlly do |b|
            user.pbAddTarget(choices, user, b, self)
        end
        return if choices.empty?
        idxChoice = (choices.length > 1) ? @battle.pbRandom(choices.length) : 0
        user.pbAddTarget(targets, user, choices[idxChoice], self, !pbTarget(user).can_choose_distant_target?)
    end

    def pbShowFailMessages?(targets)
        if targets.length > 1
            valid_targets = targets.select { |b| !b.fainted? && !b.damageState.unaffected }
            return valid_targets.length <= 1
        end
        return super
    end

    def pbDesignateTargetsForHit(targets, hitNum)
        valid_targets = []
        targets.each do |b|
            next if b.damageState.unaffected || b.damageState.fainted
            valid_targets.push(b)
        end
        indexThisHit = hitNum % targets.length
        if indexThisHit == 2
            if valid_targets[2]
                return [valid_targets[2]]
            else
                indexThisHit = 1
            end
        end
        return [valid_targets[1]] if indexThisHit == 1 && valid_targets[1]
        return [valid_targets[0]]
    end
end

#===============================================================================
# Does Dragon-Darts style hit redirection, plus
# each target hit loses 1 step of Speed. (Tar Volley)
#===============================================================================
class PokeBattle_Move_592 < PokeBattle_Move_17C
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:SPEED, user, move: self)
    end
end