#===============================================================================
# Numbs the target.
#===============================================================================
class PokeBattle_Move_Numb < PokeBattle_NumbMove
end

# Empowered Thunderbolt / Dragon Breath
class PokeBattle_Move_EmpoweredThunderbolt < PokeBattle_Move_Numb
    include EmpoweredMove
end

#===============================================================================
# Numbs the target. Accuracy perfect in rainstorm. Hits some
# semi-invulnerable targets. (Thunder)
#===============================================================================
class PokeBattle_Move_NumbTargetAlwaysHitsInRainstormHitsTargetInSky < PokeBattle_NumbMove
    def hitsFlyingTargets?; return true; end

    def immuneToRainDebuff?; return false; end

    def pbBaseAccuracy(user, target)
        return 0 if @battle.rainy?
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.rainy?
    end
end

#===============================================================================
# May cause the target to be numbed or to lower their Defense by two steps. (Thunder Fang, Volt Crunch)
#===============================================================================
class PokeBattle_Move_NumbTargetLowerTargetDef2 < PokeBattle_Move_StatusTargetLowerTargetDef2
    def initialize(battle, move)
        super
        @statusToApply = :NUMB
    end
end

#===============================================================================
# Multi-hit move that can numb.
#===============================================================================
class PokeBattle_Move_HitTwoToFiveTimesNumb < PokeBattle_NumbMove
    include RandomHitable
end

#===============================================================================
# Numbs the target and reduces their attacking stats by 1 step each. (Heaven's Eyes)
#===============================================================================
class PokeBattle_Move_NumbTargetLowerTargetAtkSpAtk1 < PokeBattle_NumbMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if  !target.canNumb?(user, false, self) &&
            !target.pbCanLowerStatStep?(:ATTACK, user, self) &&
            !target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self)

            @battle.pbDisplay(_INTL("But it failed, since {1} can't be numbed or have either of its attacking stats lowered!", target.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyNumb if target.canNumb?(user, false, self)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
    end
end

# Empowered Numb
class PokeBattle_Move_EmpoweredNumb < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyNumb(user) if b.canNumb?(user, true, self)
        end
        transformType(user, :ELECTRIC)
    end
end