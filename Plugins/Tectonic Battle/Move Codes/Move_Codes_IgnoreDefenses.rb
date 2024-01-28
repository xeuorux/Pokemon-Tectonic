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
# Always hits. Ends target's protections immediately. (Hyperspace Hole)
#===============================================================================
class PokeBattle_Move_147 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def pbAccuracyCheck(_user, _target); return true; end

    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
    end
end

#===============================================================================
# Decreases the user's Defense by 1 step. Always hits. Ends target's
# protections immediately. (Hyperspace Fury)
#===============================================================================
class PokeBattle_Move_13B < PokeBattle_StatDownMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:HOOPA)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif user.form != 1
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbAccuracyCheck(_user, _target); return true; end

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
# Ends target's protections, screens, and substitute immediately. (Siege Breaker)
#===============================================================================
class PokeBattle_Move_12E < PokeBattle_Move
    def ignoresSubstitute?; return true; end
    def ignoresReflect?; return true; end
    
    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
        target.disableEffect(:Substitute)
    end

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
        score += 20 if target.substituted?
        return score
    end

    def shouldHighlight?(_user, target)
        return true if sideHasScreens?(target.pbOwnSide)
        return true if target.substituted?
        return false
    end
end

#===============================================================================
# Ignores all abilities that alter this move's success or damage.
# (Moongeist Beam, Sunsteel Strike)
#===============================================================================
class PokeBattle_Move_163 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        super
        @battle.moldBreaker = true unless specialUsage
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

#===============================================================================
# Ignores all abilities that alter this move's success or damage. This move is
# physical if user's Attack is higher than its Special Attack (after applying
# stat steps), and special otherwise. (Photon Geyser)
#===============================================================================
class PokeBattle_Move_164 < PokeBattle_Move_163
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end
end