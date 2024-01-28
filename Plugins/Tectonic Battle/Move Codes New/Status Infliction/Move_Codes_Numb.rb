#===============================================================================
# Numbs the target.
#===============================================================================
class PokeBattle_Move_Numb < PokeBattle_NumbMove
end

#===============================================================================
# Numbs the target. Accuracy perfect in rain. Hits some
# semi-invulnerable targets. (Thunder)
#===============================================================================
class PokeBattle_Move_NumbRainAccurateHitsFlyers < PokeBattle_NumbMove
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
# Numbs the target. May cause the target to flinch. (Thunder Fang)
#===============================================================================
class PokeBattle_Move_NumbFlinch < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canNumb?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyNumb(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getNumbEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end

#===============================================================================
# Target is numbed if in eclipse. (Tidalkinesis)
#===============================================================================
class PokeBattle_Move_5FA < PokeBattle_NumbMove
    def pbAdditionalEffect(user, target)
        return unless @battle.eclipsed?
        super
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.eclipsed?
        super
    end
end

#===============================================================================
# Multi-hit move that can numb.
#===============================================================================
class PokeBattle_Move_5FB < PokeBattle_NumbMove
    include RandomHitable
end