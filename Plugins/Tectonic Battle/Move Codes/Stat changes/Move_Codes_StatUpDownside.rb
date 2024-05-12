#===============================================================================
# Reduces the user's HP by half of max, and sets its Attack to maximum.
# (Belly Drum)
#===============================================================================
class PokeBattle_Move_MaxUserAtkLoseHalfOfTotalHP < PokeBattle_Move
    def statUp; return [:ATTACK,12]; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.hp <= hpLoss(user)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        return true unless user.pbCanRaiseStatStep?(:ATTACK, user, self, show_message)
        return false
    end

    def hpLoss(battler)
        return [(battler.totalhp / 2.0).ceil, 1].max
    end

    def pbEffectGeneral(user)
        user.pbReduceHP(hpLoss(user), false)
        user.pbMaximizeStatStep(:ATTACK, user, self)
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        stepsUp = 6 - user.steps[:ATTACK]
        score = getMultiStatUpEffectScore([:ATTACK, stepsUp], user, target)
        score -= 50
        return score
    end
end

#===============================================================================
# Reduces the user's HP by half of max, and sets its Sp. Atk to maximum.
#===============================================================================
class PokeBattle_Move_MaxUserSpAtkLoseHalfOfTotalHP < PokeBattle_Move
    def statUp; return [:SPECIAL_ATTACK,12]; end

    def pbMoveFailed?(user, _targets, show_message)
        hpLoss = [user.totalhp / 2, 1].max
        if user.hp <= hpLoss
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        return true unless user.pbCanRaiseStatStep?(:SPECIAL_ATTACK, user, self, show_message)
        return false
    end

    def pbEffectGeneral(user)
        hpLoss = [user.totalhp / 2, 1].max
        user.pbReduceHP(hpLoss, false)
        user.pbMaximizeStatStep(:SPECIAL_ATTACK, user, self)
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        stepsUp = 6 - user.steps[:SPECIAL_ATTACK]
        score = getMultiStatUpEffectScore([:SPECIAL_ATTACK, stepsUp], user, target)
        score -= 50
        return score
    end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 2 steps each.
# Increases the user's Attack, Speed and Special Attack by 3 steps each.
# (Shell Smash)
#===============================================================================
class PokeBattle_Move_LowerUserDefSpDef2RaiseUserAtkSpAtkSpd3 < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:ATTACK, 3, :SPECIAL_ATTACK, 3, :SPEED, 3]
        @statDown = DEFENDING_STATS_2
    end
end

#===============================================================================
# Increases the user's Speed by 4 steps. Lowers user's weight by 100kg.
# (Autotomize)
#===============================================================================
class PokeBattle_Move_RaiseUserSpeed4LowerUserWeight < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 4]
    end

    def pbEffectGeneral(user)
        if user.pbWeight + user.effects[:WeightChange] > 1
            user.effects[:WeightChange] -= 100
            @battle.pbDisplay(_INTL("{1} became lighter!", user.pbThis))
        end
        super
    end
end

#===============================================================================
# Raises all user's stats by 2 steps in exchange for the user losing 1/3 of its
# maximum HP, rounded down. Fails if the user would faint. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_RaiseUserMainStats2LoseThirdOfTotalHP < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ALL_STATS_2
    end

    def pbMoveFailed?(user, targets, show_message)
        if user.hp <= (user.totalhp / 3)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyFractionalDamage(1.0 / 3.0)
    end

    def getEffectScore(user, target)
        score = super
        score += getHPLossEffectScore(user, 0.33)
        return score
    end
end

#===============================================================================
# Increases each stat by 1 step. Prevents user from fleeing. (No Retreat)
#===============================================================================
class PokeBattle_Move_RaiseUserMainStats2TrapUser < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ALL_STATS_2
    end

    def pbMoveFailed?(user, targets, show_message)
        if user.effectActive?(:NoRetreat)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already committed to the battle!"))
            end
            return true
        end
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:NoRetreat)
    end
end

#===============================================================================
# Increases the user's Attack by 6 steps, but lowers its Speed by 6 steps.
# (Patient Blade)
#===============================================================================
class PokeBattle_Move_Trade6SpdForAtk < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:ATTACK,6]
        @statDown = [:SPEED,6]
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 6 steps, but lowers its Speed by 6 steps.
#===============================================================================
class PokeBattle_Move_Trade6SpdForSpAtk < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:sPECIAL_ATTACK,6]
        @statDown = [:SPEED,6]
    end
end

#===============================================================================
# Decreases the user's Sp. Def.
# Increases the user's Sp. Atk by 1 step, and Speed by 2 steps.
# (Shed Coat)
#===============================================================================
class PokeBattle_Move_RaiseUserSpAtk1Speed2LowerUserSpDef1 < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:SPEED, 3, :SPECIAL_ATTACK, 3]
        @statDown = [:SPECIAL_DEFENSE, 2]
    end
end