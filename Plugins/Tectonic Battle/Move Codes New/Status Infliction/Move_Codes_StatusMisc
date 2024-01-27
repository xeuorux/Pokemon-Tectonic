#===============================================================================
# Burns, frostbites, or numbs the target. (Tri Attack)
#===============================================================================
class PokeBattle_Move_017 < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        case @battle.pbRandom(3)
        when 0 then target.applyBurn(user)      if target.canBurn?(user, false, self)
        when 1 then target.applyFrostbite(user) if target.canFrostbite?(user, false, self)
        when 2 then target.applyNumb(user)      if target.canNumb?(user, false, self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        burnScore = getBurnEffectScore(user, target)
        frostBiteScore = getFrostbiteEffectScore(user, target)
        numbScore = getNumbEffectScore(user, target)
        return (burnScore + frostBiteScore + numbScore) / 3
    end
end