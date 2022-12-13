class PokeBattle_Move
    ########################################################
    ### AI functions
    ########################################################
    def getScore(score,user,target,skill=100)
        return score
    end

    # For moves that want to lie to the AI about their base damage
    # Or avoid side effects of the base damage method
    # Or give an estimate of the base damage when it can't be accurately measured at the point of choosing moves
    def pbBaseDamageAI(baseDmg,user,target,skill=100)
        pbBaseDamage(baseDmg,user,target)
    end

    # Same as the above, but for number of hits
    # Can return a float, for average hit amount on random moves
    def pbNumHitsAI(user,targets)
        return pbNumHits(user,target,true)
    end

    def hasKOEffect?(user,target); return false; end
end