#===============================================================================
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch)
#===============================================================================
class PokeBattle_Move_FailsIfTargetActed < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if @battle.choices[target.index][0] != :UseMove
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} didn't choose to attack!")) if show_message
            return true
        end
        oppMove = @battle.choices[target.index][2]
        if !oppMove ||
           (oppMove.function != "UseMoveTargetIsAboutToUse" && # Me First
           (target.movedThisRound? || oppMove.statusMove?))
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already moved this turn!")) if show_message
            return true
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
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
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
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
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
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't know Last Resort!"))
            end
            return true
        end
        unless hasOtherMoves
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no other moves!")) if show_message
            return true
        end
        if hasUnusedMoves
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} hasn't yet used all its other moves!"))
            end
            return true
        end
        return false
    end
end