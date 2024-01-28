#===============================================================================
# User takes recoil damage equal to 1/4 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_0FA < PokeBattle_RecoilMove
    def recoilFactor;  return 0.25; end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_0FB < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end
end

#===============================================================================
# User takes recoil damage equal to 1/2 of the damage this move dealt.
# (Head Smash, Light of Ruin)
#===============================================================================
class PokeBattle_Move_0FC < PokeBattle_RecoilMove
    def recoilFactor;  return 0.5; end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
#===============================================================================
class PokeBattle_Move_0FD < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target. (Flare Blitz)
#===============================================================================
class PokeBattle_Move_0FE < PokeBattle_RecoilMove
    def recoilFactor; return (1.0 / 3.0); end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyBurn(user) if target.canBurn?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getBurnEffectScore(user, target)
    end
end

#===============================================================================
# 100% Recoil Move (Thunder Belly)
#===============================================================================
class PokeBattle_Move_56B < PokeBattle_RecoilMove
    def recoilFactor; return 1.0; end
end

#===============================================================================
# If attack misses, user takes crash damage of 1/2 of max HP.
# (High Jump Kick, Jump Kick)
#===============================================================================
class PokeBattle_Move_10B < PokeBattle_Move
    def recoilMove?;        return true; end
    def unusableInGravity?; return true; end

    def pbCrashDamage(user)
        recoilDamage = user.totalhp / 2.0
        recoilMessage = _INTL("{1} kept going and crashed!", user.pbThis)
        user.applyRecoilDamage(recoilDamage, true, true, recoilMessage)
    end

    def getEffectScore(_user, _target)
        return (@accuracy - 100) * 2
    end
end

#===============================================================================
# If it deals less than 50% of the target’s max health, the user (Capacity Burst)
# takes the difference as recoil.
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.totalCalcedDamage < target.totalhp / 2
        recoilAmount = (target.totalhp / 2) - target.damageState.totalCalcedDamage
        recoilMessage = _INTL("#{user.pbThis} is hurt by leftover electricity!")
        user.applyRecoilDamage(recoilAmount, true, true, recoilMessage)
    end

    def getDamageBasedEffectScore(user,target,damage)
        return 0 if damage >= target.totalhp / 2
        recoilDamage = (target.totalhp / 2) - damage
        score = (-recoilDamage * 2 / user.totalhp).floor
        return score
    end
end