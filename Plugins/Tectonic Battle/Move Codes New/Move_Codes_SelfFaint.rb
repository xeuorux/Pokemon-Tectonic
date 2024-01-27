#===============================================================================
# Inflicts fixed damage equal to user's current HP. (Final Gambit)
# User faints (if successful).
#===============================================================================
class PokeBattle_Move_0E1 < PokeBattle_FixedDamageMove
    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbOnStartUse(user, _targets)
        @finalGambitDamage = user.hp
    end

    def pbFixedDamage(_user, _target)
        return @finalGambitDamage
    end

    def pbBaseDamageAI(_baseDmg, user, _target)
        return user.hp
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        return score
    end
end