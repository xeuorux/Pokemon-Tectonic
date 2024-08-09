#===============================================================================
# Halves the target's current HP. (Nature's Madness, Super Fang)
#===============================================================================
class PokeBattle_Move_FixedDamageHalfTargetHP < PokeBattle_FixedDamageMove
    def pbFixedDamage(_user, target)
        damage = target.hp / 2.0
        damage *= target.hpBasedEffectResistance if target.boss?
        return damage.round
    end
end

#===============================================================================
# Halves the target's current HP. (Mouthful)
# User gains half the HP it inflicts as damage.
#===============================================================================
class PokeBattle_Move_FixedDamageHalfTargetHealUserByHalfOfDamageDone < PokeBattle_FixedDamageMove
    def healingMove?; return true; end

    def drainFactor(_user, _target); return 0.5; end

    def shouldDrain?(_user, _target); return true; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0 || !shouldDrain?(user, target)
        hpGain = (target.damageState.hpLost * drainFactor(user, target)).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end

    def pbFixedDamage(_user, target)
        damage = target.hp / 2.0
        damage *= hpBasedEffectResistance if target.boss?
        return damage.round
    end

    def getEffectScore(user, target)
        score = 40 * drainFactor(user, target)
        score *= 1.5 if user.hasActiveAbilityAI?(:ROOTED)
        score *= 2.0 if user.hasActiveAbilityAI?(:GLOWSHROOM) && user.battle.moonGlowing?
        score *= 1.3 if user.hasActiveItemAI?(:BIGROOT)
        score *= 2 if user.belowHalfHealth?
        score *= -1 if target.hasActiveAbilityAI?(:LIQUIDOOZE) || user.healingReversed?
        return score
    end
end

#===============================================================================
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
#===============================================================================
class PokeBattle_Move_LowerTargetHPToUserHP < PokeBattle_FixedDamageMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if user.hp >= target.hp
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s health is greater than #{target.pbThis(true)}'s!"))
            end
            return true
        end
        if target.boss?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is an Avatar!")) if show_message
            return true
        end
        return false
    end
    
    def pbFailsAgainstTargetAI?(user, target)
        return false if user.ownersPolicies.include?(:FEAR) && target.hp > 1 # Assume will be hit to 1
        return pbFailsAgainstTarget?(user, target, false)
    end

    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbFixedDamage(user, target)
        return target.hp - user.hp
    end
    
    def getEffectScore(user, target)
        score = 0 
        if !@battle.battleAI.userMovesFirst?(self, user, target) && target.hasDamagingAttack?
            if user.ownersPolicies.include?(:FEAR) 
                score += 330 # huge bonus because always getting a -70% from being outsped and killed, reduce when AI understands focus sash
            else
                score += 20
            end
        end
        return score
    end
end