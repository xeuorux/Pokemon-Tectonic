#===============================================================================
# Decreases the target's Attack and Special Attack by 1 step each. (Singing Stone)
#===============================================================================
class PokeBattle_Move_59F < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_1
    end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 2 steps each. Always hits.
# (Noble Roar)
#===============================================================================
class PokeBattle_Move_13A < PokeBattle_TargetMultiStatDownMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_2
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# Debuff's target's attacking stats in hail. (Cold Shoulder)
#===============================================================================
class PokeBattle_Move_56A < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_2, user, move: self) if @battle.icy?
    end
end

#===============================================================================
# Decreases the target's Attack and Defense by 2 steps each. (Tickle)
#===============================================================================
class PokeBattle_Move_04A < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the target's Sp. Atk and Sp. Def by 2 steps each. (Prank)
#===============================================================================
class PokeBattle_Move_560 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Lowers the target's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 step each. (Ruin)
#===============================================================================
class PokeBattle_Move_047 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = ALL_STATS_1
    end
end

#===============================================================================
# Lowers the target's Defense and Evasion by 2. (Echolocate)
#===============================================================================
class PokeBattle_Move_52E < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2, :EVASION, 2]
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# Lowers the target's Sp. Def and Evasion by 2.
#===============================================================================
class PokeBattle_Move_LowerSpDef2Evasion2 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 2, :EVASION, 2]
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# Target's attacking stats are lowered by 5 steps. User faints. (Memento)
#===============================================================================
class PokeBattle_Move_0E2 < PokeBattle_TargetMultiStatDownMove
    def worksWithNoTargets?; return true; end

    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 5, :SPECIAL_ATTACK, 5]
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.totalhp, false)
        user.pbItemHPHealCheck
    end
    
    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# Minimizes the target's Speed and Evasiveness. (Freeze Ray)
#===============================================================================
class PokeBattle_Move_5C0 < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbMinimizeStatStep(:SPEED, user, self)
        target.pbMinimizeStatStep(:EVASION, user, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([:SPEED,4,:EVASION,4], user, target)
    end
end

# Empowered String Shot
class PokeBattle_Move_60A < PokeBattle_TargetMultiStatDownMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2, :ATTACK, 2, :SPECIAL_ATTACK, 2]
    end

    def pbEffectGeneral(user)
        transformType(user, :BUG)
    end
end