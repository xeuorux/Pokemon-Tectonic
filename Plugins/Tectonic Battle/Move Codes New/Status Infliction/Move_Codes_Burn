#===============================================================================
# Burns the target.
#===============================================================================
class PokeBattle_Move_Burn < PokeBattle_BurnMove
end

#===============================================================================
# Burns the target. May cause the target to flinch. (Fire Fang)
#===============================================================================
class PokeBattle_Move_BurnFlinch < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canBurn?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyBurn(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getBurnEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end