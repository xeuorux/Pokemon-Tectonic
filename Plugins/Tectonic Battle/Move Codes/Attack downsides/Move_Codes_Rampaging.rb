#===============================================================================
# User must use this move for 2 more rounds. (Outrage, etc.)
#===============================================================================
class PokeBattle_Move_Rampage < PokeBattle_Move
    def rampagingMove?; return true; end

    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Rampaging, user.getRampageDuration) if !target.damageState.unaffected && !user.effectActive?(:Rampaging)
        user.tickDownAndProc(:Rampaging)
    end

    def getEffectScore(user, _target)
        return -20 * user.getRampageDuration(aiCheck: true)
    end
end

#===============================================================================
# User must use this move for 2 more rounds. No battlers can sleep. (Uproar)
# NOTE: Bulbapedia claims that an uproar will wake up Pokémon even if they have
#       Soundproof, and will not allow Pokémon to fall asleep even if they have
#       Soundproof. I think this is an oversight, so I've let Soundproof Pokémon
#       be unaffected by Uproar waking/non-sleeping effects.
#===============================================================================
class PokeBattle_Move_RampagePreventSleeping < PokeBattle_Move
    def pbEffectGeneral(user)
        return if user.effectActive?(:Uproar)
        user.applyEffect(:Uproar, user.getRampageDuration)
        user.currentMove = @id
    end

    def getEffectScore(user, _target)
        return -20 * user.getRampageDuration(aiCheck: true)
    end
end

#===============================================================================
# User must use this move for 2 more rounds. Raises Speed if KOs. (Tyrant's Fit)
#===============================================================================
class PokeBattle_Move_RampageKOsRaiseSpeed1 < PokeBattle_Move_Rampage
    def pbEffectAfterAllHits(user, target)
        super
        user.tryRaiseStat(:SPEED, user, increment: 1, move: self) if target.damageState.fainted
    end

    def getFaintEffectScore(user, target)
        return getMultiStatUpEffectScore([:SPEED, 1], user, user)
    end
end

#===============================================================================
# User must use this move for 2 more rounds. This attack is always a critical hit. (Whip Trance)
#===============================================================================
class PokeBattle_Move_RampageAlwaysCriticalHit < PokeBattle_Move_Rampage
    def pbCriticalOverride(_user, _target); return 1; end
end