#===============================================================================
# Puts the target to sleep.
#===============================================================================
class PokeBattle_Move_Sleep < PokeBattle_SleepMove
end

#===============================================================================
# Puts the target to sleep, but only if the user is Darkrai. (Dark Void)
#===============================================================================
class PokeBattle_Move_SleepTargetIfUserDarkrai < PokeBattle_SleepMove
    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:DARKRAI)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Puts the target to sleep. User loses half of their max HP as recoil. (Demon's Kiss)
#===============================================================================
class PokeBattle_Move_SleepTargetUserLosesHalfMaxHP < PokeBattle_SleepMove
    def pbEffectAgainstTarget(user, target)
        target.applySleep
        user.applyFractionalDamage(1.0 / 2.0)
    end

    def getEffectScore(user, _target)
        score = super
        score += getHPLossEffectScore(user, 0.5)
        return score
    end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target is at or below half health. (Lullaby)
#===============================================================================
class PokeBattle_Move_SleepTargetIfBelowHalfHP < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.hp > target.totalhp / 2
            @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)} is above half health!")) if show_message
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end
end

#===============================================================================
# Puts the target to sleep if they are at or below half health, and raises the user's attack. (Tranquil Tune)
#===============================================================================
class PokeBattle_Move_SleepTargetIfBelowHalfHPRaiseUserAtk1 < PokeBattle_Move_SleepTargetIfBelowHalfHP
    def pbEffectAgainstTarget(user, target)
        super
        user.tryRaiseStat(:ATTACK, user, move: self)
    end

    def getEffectScore(user, target)
        return getMultiStatUpEffectScore([:ATTACK, 1], user, target)
    end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target dealt damage to the user this turn. (Puff Ball)
#===============================================================================
class PokeBattle_Move_SleepTargetIfDealtDamageToUserThisTurn < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        unless user.lastAttacker.include?(target.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the #{target.pbThis(true)} didn't attack #{user.pbThis(true)} this turn!"))
            end
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end

    def pbFailsAgainstTargetAI?(user, target)
        return !target.canSleep?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if hasBeenUsed?(user)
        userSpeed = user.pbSpeed(true, move: self)
        targetSpeed = target.pbSpeed(true)
        return 0 if userSpeed > targetSpeed
        return 0 unless target.hasDamagingAttack?
        super
    end
end

#===============================================================================
# Puts the target to sleep if they are slower, then minimizes the user's speed. (Sedating Dust)
#===============================================================================
class PokeBattle_Move_SleepTargetIfSlowerThanUserMinUserSpeed < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.pbSpeed > user.pbSpeed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is slower than #{target.pbThis(true)}!"))
            end
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        target.applySleep
        user.pbMinimizeStatStep(:SPEED, user, self)
    end

    def getEffectScore(user, target)
        score = -30
        score -= user.steps[:SPEED] * 5
        return score
    end
end

#===============================================================================
# Target falls asleep. Can only be used during the Full Moon. (Bedtime)
#===============================================================================
class PokeBattle_Move_SleepTargetIfInFullMoonglow < PokeBattle_SleepMove
    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.fullMoon?
            @battle.pbDisplay(_INTL("But it failed, since it isn't a Full Moon!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Puts the target to sleep. Fails unless the target is dizzy. (Pacify)
#===============================================================================
class PokeBattle_Move_SleepTargetIfDizzy < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.dizzy?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't dizzy!")) if show_message
            return true
        end
        return !target.canSleep?(user, show_message, self, true)
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbCureStatus(false, :DIZZY)
        target.applySleep
    end
end

#===============================================================================
# Makes the target drowsy; it falls asleep at the end of the next turn. (Yawn)
#===============================================================================
class PokeBattle_Move_SleepTargetNextTurn < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Yawn)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already drowsy!")) if show_message
            return true
        end
        return true unless target.canSleep?(user, show_message, self)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Yawn, 2)
    end

    def getEffectScore(user, target)
        score = getSleepEffectScore(user, target)
        score -= 60
        return score
    end
end

# Empowered Yawn
class PokeBattle_Move_EmpoweredYawn < PokeBattle_Move_SleepTargetNextTurn
    include EmpoweredMove
end