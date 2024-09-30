#===============================================================================
# Poisons the target.
#===============================================================================
class PokeBattle_Move_Poison < PokeBattle_PoisonMove
end

# Empowered Sludge Wave
class PokeBattle_Move_EmpoweredSludgeWave < PokeBattle_Move_Poison
    include EmpoweredMove
end

#===============================================================================
# Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
# (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_CategoryDependsOnHigherDamagePoisonTarget < PokeBattle_Move_Poison
    def initialize(battle, move)
        super
        @category_override = 1
    end

    def calculateCategoryOverride(user, targets)
        return selectBestCategory(user, targets[0])
    end
end

#===============================================================================
# Poisons the target and decreases its Speed by 4 steps. (Toxic Thread)
#===============================================================================
class PokeBattle_Move_PoisonTargetLowerTargetSpd4 < PokeBattle_Move
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

# Empowered Poison Gas
class PokeBattle_Move_EmpoweredPoisonGas < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            next unless b.canPoison?(user, true, self)
            b.applyPoison(user)
        end
        transformType(user, :POISON)
    end
end