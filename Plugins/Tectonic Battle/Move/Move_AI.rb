class PokeBattle_Move
    ########################################################
    ### AI functions
    ########################################################
    def getEffectScore(_user, _target)
        echoln("Move #{@name} has no effect scoring method defined! Returning 0.")
        return 0
    end

    # Scoring the effects that occur when the target is struck by the move
    # Ignore if the target will be fainted by the move
    # Ignored if the target has a substitute (unless the move pierces it)
    # Since all target affecting additional effects are blocked by substitute
    def getTargetAffectingEffectScore(_user, _target)
        return 0
    end

    # Scoring the effects that occur when the target is fainted by the move
    def getFaintEffectScore(_user, _target)
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
    def pbNumHitsAI(user, targets)
        return pbNumHits(user, targets, true)
    end

    def hasBeenUsed?(user)
        return user.movesUsed.include?(@id)
    end
end
