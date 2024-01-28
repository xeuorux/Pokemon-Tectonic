#===============================================================================
# Poisons the target.
#===============================================================================
class PokeBattle_Move_Poison < PokeBattle_PoisonMove
end

#===============================================================================
# Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
# (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move_005
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, targets)
        return selectBestCategory(user, targets[0])
    end
end

#===============================================================================
# Poisons the target and decreases its Speed by 4 steps. (Toxic Thread)
#===============================================================================
class PokeBattle_Move_159 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.canPoison?(user, false, self) &&
           !target.pbCanLowerStatStep?(:SPEED, user, self)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be poisoned or have its Speed lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyPoison(user) if target.canPoison?(user, false, self)
        target.tryLowerStat(:SPEED, user, increment: 4, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        score = getMultiStatDownEffectScore([:SPEED,4],user,target)
        score += getPoisonEffectScore(user, target)
        return score
    end
end