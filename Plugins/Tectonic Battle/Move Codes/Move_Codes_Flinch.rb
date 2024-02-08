#===============================================================================
# Causes the target to flinch.
#===============================================================================
class PokeBattle_Move_Flinch < PokeBattle_FlinchMove
end

#===============================================================================
# Hits twice. Causes the target to flinch. (Double Iron Bash)
#===============================================================================
class PokeBattle_Move_HitTwoTimesFlinchTarget < PokeBattle_FlinchMove
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

#===============================================================================
# Causes the target to flinch. Fails if the user is not asleep. (Snore)
#===============================================================================
class PokeBattle_Move_FlinchTargetFailsIfUserNotAsleep < PokeBattle_FlinchMove
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
class PokeBattle_Move_FlinchTargetFailsIfNotUserFirstTurn < PokeBattle_FlinchMove
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

#===============================================================================
# Lowers the target's Speed. Flinch chance. (Crackling Cloud)
#===============================================================================
class PokeBattle_Move_FlinchTargetLowerTargetSpd1 < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute

        target.tryLowerStat(:SPEED, user, move: self, increment: 1)

        # Flinching aspect
        chance = pbAdditionalEffectChance(user, target, @calcType, 50)
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = getMultiStatDownEffectScore([:SPEED, 1], user, target)

        # Flinching aspect
        chance = pbAdditionalEffectChance(user, target, @calcType, 50)
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            baseScore = baseDamage * 10 / user.level
            score += getFlinchingEffectScore(baseScore, user, target, self)
        end
        return score
    end
end