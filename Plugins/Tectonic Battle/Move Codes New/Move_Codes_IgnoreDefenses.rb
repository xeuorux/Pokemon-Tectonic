#===============================================================================
# This attack is always a critical hit. (Frost Breath, Storm Throw)
#===============================================================================
class PokeBattle_Move_0A0 < PokeBattle_Move
    def pbCriticalOverride(_user, _target); return 1; end
end

#===============================================================================
# Always hits.
#===============================================================================
class PokeBattle_Move_0A5 < PokeBattle_Move
    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (Chip Away, Darkest Lariat, Sacred Sword)
#===============================================================================
class PokeBattle_Move_0A9 < PokeBattle_Move
    def pbCalcAccuracyMultipliers(user, target, multipliers)
        super
        modifiers[:evasion_step] = 0
    end

    def ignoresDefensiveStepBoosts?(_user, _target); return true; end

    def shouldHighlight?(_user, target)
        return target.hasRaisedDefenseSteps?
    end
end

#===============================================================================
# Ends target's protections immediately. (Feint)
#===============================================================================
class PokeBattle_Move_0AD < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
    end
end