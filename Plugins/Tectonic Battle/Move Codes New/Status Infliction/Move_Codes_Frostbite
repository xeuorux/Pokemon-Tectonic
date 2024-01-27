#===============================================================================
# Frostbite's the target.
#===============================================================================
class PokeBattle_Move_Frostbite < PokeBattle_FrostbiteMove
end

#===============================================================================
# Frostbites the target. Accuracy perfect in hail. (Blizzard)
#===============================================================================
class PokeBattle_Move_FrostbiteHailAccurate < PokeBattle_FrostbiteMove
    def pbBaseAccuracy(user, target)
        return 0 if @battle.icy?
        return super
    end
end

#===============================================================================
# Frostbites the target. May cause the target to flinch. (Ice Fang)
#===============================================================================
class PokeBattle_Move_FrostbiteFlinch < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canFrostbite?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyFrostbite(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getFrostbiteEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end