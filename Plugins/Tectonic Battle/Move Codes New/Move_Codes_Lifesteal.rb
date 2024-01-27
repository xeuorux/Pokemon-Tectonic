#===============================================================================
# User gains half the HP it inflicts as damage.
#===============================================================================
class PokeBattle_Move_0DD < PokeBattle_DrainMove
    def drainFactor(_user, _target); return 0.5; end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Deals double damage if the target is asleep.
# (Dream Absorb)
#===============================================================================
class PokeBattle_Move_0DE < PokeBattle_DrainMove
    def drainFactor(_user, _target); return 0.5; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.asleep?
        return baseDmg
    end
end

#===============================================================================
# Drains 2/3s if target hurt the user this turn (Trap Jaw)
#===============================================================================
class PokeBattle_Move_557 < PokeBattle_Move
    def healingMove?; return true; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0
        return unless user.lastAttacker.include?(target.index)
        hpGain = (target.damageState.hpLost * 2 / 3).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end

    def getEffectScore(user, target)
        return getWantsToBeSlowerScore(user, target, 3, move: self)
    end
end

#===============================================================================
# Averages the user's and target's current HP. (Pain Split)
#===============================================================================
class PokeBattle_Move_05A < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.boss?
            @battle.pbDisplay(_INTL("But it failed, since the target is an avatar!")) if show_message
            return true
        end
        if user.boss?
            @battle.pbDisplay(_INTL("But it failed, since the user is an avatar!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        newHP = (user.hp + target.hp) / 2
        if user.hp > newHP
            user.pbReduceHP(user.hp - newHP, false, false)
        elsif user.hp < newHP
            user.pbRecoverHP(newHP - user.hp, false, true, false)
        end
        if target.hp > newHP
            target.pbReduceHP(target.hp - newHP, false, false)
        elsif target.hp < newHP
            target.pbRecoverHP(newHP - target.hp, false, true, false)
        end
        @battle.pbDisplay(_INTL("The battlers shared their pain!"))
        user.pbItemHPHealCheck
        target.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        if user.hp >= (user.hp + target.hp) / 2
            return 0
        else
            return 100
        end
    end
end