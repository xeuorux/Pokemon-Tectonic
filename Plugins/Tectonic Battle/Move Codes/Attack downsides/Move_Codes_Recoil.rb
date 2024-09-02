#===============================================================================
# User takes recoil damage equal to 1/5 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_RecoilFifthOfDamageDealt < PokeBattle_RecoilMove
    def recoilFactor; return 0.2; end
end

#===============================================================================
# User takes recoil damage equal to 1/4 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_RecoilQuarterOfDamageDealt < PokeBattle_RecoilMove
    def recoilFactor;  return 0.25; end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_RecoilThirdOfDamageDealt < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end
end

# Empowered Brave Bird
class PokeBattle_Move_EmpoweredBraveBird < PokeBattle_Move_RecoilThirdOfDamageDealt
    include EmpoweredMove
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
#===============================================================================
class PokeBattle_Move_RecoilThirdOfDamageDealtNumbTarget < PokeBattle_RecoilMove
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
class PokeBattle_Move_RecoilThirdOfDamageDealtBurnTarget < PokeBattle_RecoilMove
    def recoilFactor; return (1.0 / 3.0); end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyBurn(user) if target.canBurn?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getBurnEffectScore(user, target)
    end
end

# Empowered Flareblitz
class PokeBattle_Move_EmpoweredFlareBlitz < PokeBattle_Move_RecoilThirdOfDamageDealtBurnTarget
    include EmpoweredMove
end

#===============================================================================
# User takes recoil damage equal to 1/2 of the damage this move dealt.
# (Head Smash, Light of Ruin)
#===============================================================================
class PokeBattle_Move_RecoilHalfOfDamageDealt < PokeBattle_RecoilMove
    def recoilFactor;  return 0.5; end
end

#===============================================================================
# User takes recoil damage equal to 2/3 of the damage this move dealt.
# (Head Charge)
#===============================================================================
class PokeBattle_Move_RecoilTwoThirdsOfDamageDealt < PokeBattle_RecoilMove
    def recoilFactor; return (2.0 / 3.0); end
end

#===============================================================================
# 100% Recoil Move (Thunder Belly)
#===============================================================================
class PokeBattle_Move_RecoilFullDamageDealt < PokeBattle_RecoilMove
    def recoilFactor; return 1.0; end
end

#===============================================================================
# If attack misses, user takes crash damage of 1/2 of max HP.
# (High Jump Kick, Jump Kick)
#===============================================================================
class PokeBattle_Move_CrashDamageIfFailsUnusableInGravity < PokeBattle_Move
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
class PokeBattle_Move_DamageBelowHalfTakenAsRecoil < PokeBattle_Move
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

#===============================================================================
# User loses half their current hp in recoil. (Steel Beam, Mist Burst)
#===============================================================================
class PokeBattle_Move_UserLosesHalfOfCurrentHP < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return unless user.takesIndirectDamage?
        @battle.pbDisplay(_INTL("{1} loses half its health in recoil!", user.pbThis))
        user.applyFractionalDamage(1.0 / 2.0, true, true)
    end

    def getEffectScore(user, _target)
        return 0 unless user.takesIndirectDamage?
        return -((user.hp.to_f / user.totalhp.to_f) * 50).floor
    end
end

#===============================================================================
# User loses one third of their current hp in recoil.
#===============================================================================
class PokeBattle_Move_UserLosesThirdOfCurrentHP < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return unless user.takesIndirectDamage?
        @battle.pbDisplay(_INTL("{1} loses one third of its health in recoil!", user.pbThis))
        user.applyFractionalDamage(1.0 / 3.0, true, true)
    end

    def getEffectScore(user, _target)
        return -((user.hp.to_f / user.totalhp.to_f) * 30).floor
    end
end

#===============================================================================
# User loses one tenth of their total hp in recoil. (Shred Shot, Shards)
#===============================================================================
class PokeBattle_Move_UserLosesTenthOfTotalHP < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return unless user.takesIndirectDamage?
        @battle.pbDisplay(_INTL("{1} lost some of its HP!", user.pbThis))
        user.applyFractionalDamage(1.0 / 10.0, true)
    end

    def getEffectScore(user, _target)
        return getHPLossEffectScore(user, 0.1)
    end
end

#===============================================================================
# Damages user by 1/2 of its max HP, even if this move misses. (Mind Blown)
#===============================================================================
class PokeBattle_Move_UserLosesHalfOfTotalHP < PokeBattle_Move
    def worksWithNoTargets?; return true; end

    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        return unless user.takesIndirectDamage?
        @battle.pbDisplay(_INTL("{1} loses half its health in recoil!", user.pbThis))
        user.applyFractionalDamage(1.0 / 2.0, true)
    end

    def getEffectScore(user, _target)
        return getHPLossEffectScore(user, 0.5)
    end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt. (Undying Rush)
# But can't faint from that recoil damage.
#===============================================================================
class PokeBattle_Move_RecoilThirdOfDamageDealtButCantFaint < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end
    
    def pbRecoilDamage(user, target)
        damage = (target.damageState.totalHPLost * finalRecoilFactor(user)).round
        damage = [damage,(user.hp - 1)].min
        return damage
    end

    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        recoilDamage = pbRecoilDamage(user, target)
        return if recoilDamage <= 0
        user.applyRecoilDamage(recoilDamage, false, true)
    end
end