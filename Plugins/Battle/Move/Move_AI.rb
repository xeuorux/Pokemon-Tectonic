class PokeBattle_Move
    ########################################################
    ### AI functions
    ########################################################
    def getEffectScore(_user, _target)
        echoln("Move #{@name} has no effect scoring method defined! Returning 0.")
        return 0
    end

    # For moves that want to lie to the AI about their base damage
    # Or avoid side effects of the base damage method
    # Or give an estimate of the base damage when it can't be accurately measured at the point of choosing moves
    def pbBaseDamageAI(baseDmg, user, target)
        pbBaseDamage(baseDmg, user, target)
    end

    # Same as the above, but for number of hits
    # Can return a float, for average hit amount on random moves
    def pbNumHitsAI(user, _targets)
        return pbNumHits(user, target, true)
    end

    def hasKOEffect?(_user, _target); return false; end
end
