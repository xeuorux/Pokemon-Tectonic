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

#===============================================================================
# Ends the opposing side's screen effects. (Brick Break, Psychic Fangs)
#===============================================================================
class PokeBattle_Move_10A < PokeBattle_Move
    def ignoresReflect?; return true; end

    def pbEffectWhenDealingDamage(_user, target)
        side = target.pbOwnSide
        side.eachEffect(true) do |effect, _value, data|
            side.disableEffect(effect) if data.is_screen?
        end
    end

    def sideHasScreens?(side)
        side.eachEffect(true) do |_effect, _value, data|
            return true if data.is_screen?
        end
        return false
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        targets.each do |b|
            next unless sideHasScreens?(b.pbOwnSide)
            hitNum = 1 # Wall-breaking anim
            break
        end
        super
    end

    def getEffectScore(_user, target)
        score = 0
        target.pbOwnSide.eachEffect(true) do |effect, value, data|
            next unless data.is_screen?
			case value
				when 2
					score += 30
				when 3
					score += 50
				when 4..999
					score += 130
            end	
        end
        return score
    end

    def shouldHighlight?(_user, target)
        return sideHasScreens?(target.pbOwnSide)
    end
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# It also ignores their abilities. (Rend)
#===============================================================================
class PokeBattle_Move_509 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        super
        @battle.moldBreaker = true unless specialUsage
    end

    def pbCalcAccuracyMultipliers(user, target, multipliers)
        super
        modifiers[EVA_STEP] = 0 # Accuracy stat step
    end

    def ignoresDefensiveStepBoosts?(_user, _target); return true; end

    def getEffectScore(_user, _target)
        return 10
    end

    def shouldHighlight?(_user, target)
        return target.hasRaisedDefenseSteps?
    end
end