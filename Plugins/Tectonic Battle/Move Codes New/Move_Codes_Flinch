#===============================================================================
# Causes the target to flinch.
#===============================================================================
class PokeBattle_Move_Flinch < PokeBattle_FlinchMove
end

#===============================================================================
# Causes the target to flinch. Fails if the user is not asleep. (Snore)
#===============================================================================
class PokeBattle_Move_FlinchWhileAsleep < PokeBattle_FlinchMove
    def usableWhenAsleep?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        return false
    end

    def pbMoveFailedAI?(user, targets)
        return true unless user.willStayAsleepAI?
        return pbMoveFailed?(user, targets, false)
    end
end

#===============================================================================
# Causes the target to flinch. Fails if this isn't the user's first turn.
# (Fake Out)
#===============================================================================
class PokeBattle_Move_FlinchFirstTurnUseOnly < PokeBattle_FlinchMove
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        return false
    end

    def getTargetAffectingEffectScore(user, target)
        score = getFlinchingEffectScore(100, user, target, self)
        return score
    end
end