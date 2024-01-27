#===============================================================================
# Reduces the user's HP by half of max, and sets its Attack to maximum.
# (Belly Drum)
#===============================================================================
class PokeBattle_Move_03A < PokeBattle_Move
    def statUp; return [:ATTACK,12]; end

    def pbMoveFailed?(user, _targets, show_message)
        hpLoss = [user.totalhp / 2, 1].max
        if user.hp <= hpLoss
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        return true unless user.pbCanRaiseStatStep?(:ATTACK, user, self, show_message)
        return false
    end

    def pbEffectGeneral(user)
        hpLoss = [user.totalhp / 2, 1].max
        user.pbReduceHP(hpLoss, false)
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
# Decreases the user's Defense and Special Defense by 2 steps each.
# Increases the user's Attack, Speed and Special Attack by 3 steps each.
# (Shell Smash)
#===============================================================================
class PokeBattle_Move_035 < PokeBattle_StatUpDownMove
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
class PokeBattle_Move_031 < PokeBattle_StatUpMove
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