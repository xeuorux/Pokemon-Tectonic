#===============================================================================
# Decreases the target's Attack by 1 step.
#===============================================================================
class PokeBattle_Move_5E6 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 1]
    end
end

#===============================================================================
# Decreases the target's Attack by 2 steps.
#===============================================================================
class PokeBattle_Move_042 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2]
    end
end

# Empowered Growl
class PokeBattle_Move_629 < PokeBattle_Move_042
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.tryRaiseStat(:ATTACK, user, move: self, increment: 2)
    end
end

#===============================================================================
# Summons Eclipse for 8 turns and lowers the Attack of all enemies by 2 steps. (Wingspan Eclipse)
#===============================================================================
class PokeBattle_Move_52F < PokeBattle_Move_042
    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Eclipse, 8, false) unless @battle.primevalWeatherPresent?
    end

    def getEffectScore(user, target)
        return getWeatherSettingEffectScore(:Eclipse, user, @battle, 8)
    end
end

#===============================================================================
# Decreases the target's Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_5E7 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 3]
    end
end

#===============================================================================
# Decreases the target's Attack by 4 steps.
#===============================================================================
class PokeBattle_Move_04B < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 4]
    end
end

#===============================================================================
# Decreases the target's Attack by 5 steps. (Feather Dance)
#===============================================================================
class PokeBattle_Move_5F1 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 5]
    end
end

#===============================================================================
# Decreases the target's Defense by 1 step.
#===============================================================================
class PokeBattle_Move_5E8 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the target's Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_043 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the target's Defense by 3 step.
#===============================================================================
class PokeBattle_Move_5E9 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end
end

#===============================================================================
# Target's Defense is lowered by 3 steps if in sandstorm. (Grindstone)
#===============================================================================
class PokeBattle_Move_5F8 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return unless @battle.sandy?
        target.tryLowerStat(@statDown[0], user, increment: @statDown[1], move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.sandy?
        return getMultiStatDownEffectScore(@statDown, user, target)
    end

    def shouldHighlight?(_user, _target)
        return @battle.sandy?
    end
end

#===============================================================================
# Decreases the target's Defense by 4 steps.
#===============================================================================
class PokeBattle_Move_04C < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 4]
    end
end

#===============================================================================
# Decreases the target's Speed by 1 step.
#===============================================================================
class PokeBattle_Move_5EA < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1]
    end
end

#===============================================================================
# Decreases the target's Speed by 2 steps.
#===============================================================================
class PokeBattle_Move_044 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2]
    end
end

#===============================================================================
# Decreases the target's Speed by 3 step.
#===============================================================================
class PokeBattle_Move_5EB < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 3]
    end
end

#===============================================================================
# Decreases the target's Speed by 4 steps.
#===============================================================================
class PokeBattle_Move_04D < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 4]
    end
end

# Empowered Rock Tomb
class PokeBattle_Move_638 < PokeBattle_Move_04D
    include EmpoweredMove
end

#===============================================================================
# Decreases the target's Special Attack by 1 step.
#===============================================================================
class PokeBattle_Move_5EC < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 1]
    end
end

#===============================================================================
# Decreases the target's Special Attack by 2 steps.
#===============================================================================
class PokeBattle_Move_045 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2]
    end
end

# Empowered Dazzle
class PokeBattle_Move_630 < PokeBattle_Move_045
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self, increment: 2)
    end
end

#===============================================================================
# Decreases the target's Special Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_5ED < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 3]
    end
end

#===============================================================================
# Decreases the target's Special Attack by 4 steps. (Eerie Impulse)
#===============================================================================
class PokeBattle_Move_13D < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# Decreases the target's Sp. Atk by 5 steps. (Star Dance)
#===============================================================================
class PokeBattle_Move_5F3 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 5]
    end
end

# Empowered Mystical Fire
class PokeBattle_Move_658 < PokeBattle_TargetStatDownMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 6]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 1 step.
#===============================================================================
class PokeBattle_Move_5EF < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_046 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 3 steps.
#===============================================================================
class PokeBattle_Move_5F0 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 4 steps.
#===============================================================================
class PokeBattle_Move_04F < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 4]
    end
end

#===============================================================================
# Target's highest stat is lowered by 4 steps. (Loom Over)
#===============================================================================
class PokeBattle_Move_522 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return !target.pbCanLowerStatStep?(target.highestStat, user, self, show_message)
    end

    def pbEffectAgainstTarget(user, target)
        target.tryLowerStat(target.highestStat, user, increment: 4, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([target.highestStat, 4], user, target)
    end
end

# Empowered Loom Over
class PokeBattle_Move_621 < PokeBattle_Move_522
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        transformType(user, :DRAGON)
    end
end

#===============================================================================
# Reduce's the target's highest attacking stat. (Scale Glint)
#===============================================================================
class PokeBattle_Move_5AA < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        if target.pbAttack > target.pbSpAtk
            target.pbLowerMultipleStatSteps([:ATTACK,1], user, move: self)
        else
            target.pbLowerMultipleStatSteps([:SPECIAL_ATTACK,1], user, move: self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        if target.pbAttack > target.pbSpAtk
            statDownArray = [:ATTACK,1]
        else
            statDownArray = [:SPECIAL_ATTACK,1]
        end
        return getMultiStatDownEffectScore(statDownArray, user, target)
    end
end