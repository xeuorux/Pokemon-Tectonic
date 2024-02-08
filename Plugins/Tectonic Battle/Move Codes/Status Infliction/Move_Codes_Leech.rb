#===============================================================================
# Leeches the target.
#===============================================================================
class PokeBattle_Move_Leech < PokeBattle_LeechMove
end

#===============================================================================
# Leeches the target and reduces their attacking stats by 1 step each. (Sapping Seed)
#===============================================================================
class PokeBattle_Move_LeechTargetLowerTargetAtkSpAtk1 < PokeBattle_LeechMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if  !target.canLeech?(user, false, self) &&
            !target.pbCanLowerStatStep?(:ATTACK, user, self) &&
            !target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self)

            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be leeched or have either of its attacking stats lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.applyLeeched if target.canLeech?(user, false, self)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
    end
end

# Empowered Leech Seed
class PokeBattle_Move_EmpoweredLeechSeed < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyLeeched(user) if b.canLeech?(user, true, self)
        end
        transformType(user, :GRASS)
    end
end