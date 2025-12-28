#===============================================================================
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch, Sinister Spines)
#===============================================================================
class PokeBattle_Move_FailsIfTargetActed < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if @battle.choices[target.index][0] != :UseMove
            @battle.pbDisplay(_INTL("But it failed, since {1} didn't choose to attack!", target.pbThis(true))) if show_message
            return true
        end
        oppMove = @battle.choices[target.index][2]
        if !oppMove
            @battle.pbDisplay(_INTL("But it failed, since {1} already moved this turn!", target.pbThis(true))) if show_message
            return true
        end
        if oppMove.function != "UseMoveTargetIsAboutToUse" # Me First
            if target.movedThisRound?
                @battle.pbDisplay(_INTL("But it failed, since {1} already moved this turn!", target.pbThis(true))) if show_message
                return true
            end
            if oppMove.statusMove?
                @battle.pbDisplay(_INTL("But it failed, since {1} didn't choose to attack!", target.pbThis(true))) if show_message
                return true
            end
        end
        return false
    end

    def pbFailsAgainstTargetAI?(user, target)
        if user.ownersPolicies.include?(:PREDICTS_PLAYER)
            return !@battle.aiPredictsAttack?(user,target.index)
        else
            return true unless target.hasDamagingAttack?
            return true if hasBeenUsed?(user)
            return false
        end
    end

    def getEffectScore(user, target)
        return -10
    end

    def shouldShade?(user, target); return false; end
end

#===============================================================================
# Fails if this isn't the user's first turn. (First Impression)
#===============================================================================
class PokeBattle_Move_FailsIfNotUserFirstTurn < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't {1}'s first turn!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Can only be used on the first turn. Deals more damage if the user was hurt this turn. (Stare Down)
#===============================================================================
class PokeBattle_Move_StareDown < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't {1}'s first turn!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.lastAttacker.include?(target.index)
        return baseDmg
    end

    def getEffectScore(user, target)
        return getWantsToBeSlowerScore(user, target, 3, move: self)
    end
end

#===============================================================================
# Fails unless user has already used all other moves it knows. (Last Resort)
#===============================================================================
class PokeBattle_Move_FailsIfUserHasUnusedMove < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        hasThisMove = false
        hasOtherMoves = false
        hasUnusedMoves = false
        user.eachMove do |m|
            hasThisMove    = true if m.id == @id
            hasOtherMoves  = true if m.id != @id
            hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
        end
        unless hasThisMove
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} doesn't know Last Resort!", user.pbThis(true)))
            end
            return true
        end
        unless hasOtherMoves
            @battle.pbDisplay(_INTL("But it failed, since {1} has no other moves!", user.pbThis(true))) if show_message
            return true
        end
        if hasUnusedMoves
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since {1} hasn't yet used all its other moves!", user.pbThis(true)))
            end
            return true
        end
        return false
    end
end