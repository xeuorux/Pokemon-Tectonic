#===============================================================================
# User must use this move for 2 more rounds. (Outrage, etc.)
#===============================================================================
class PokeBattle_Move_55F < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# User must use this move for 2 more rounds. No battlers can sleep. (Uproar)
# NOTE: Bulbapedia claims that an uproar will wake up Pokémon even if they have
#       Soundproof, and will not allow Pokémon to fall asleep even if they have
#       Soundproof. I think this is an oversight, so I've let Soundproof Pokémon
#       be unaffected by Uproar waking/non-sleeping effects.
#===============================================================================
class PokeBattle_Move_0D1 < PokeBattle_Move
    def pbEffectGeneral(user)
        return if user.effectActive?(:Uproar)
        user.applyEffect(:Uproar, 3)
        user.currentMove = @id
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# Hits 2-5 times, for three turns in a row. (Pattern Release)
#===============================================================================
class PokeBattle_Move_56C < PokeBattle_Move_0C0
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
    end
end

#===============================================================================
# User must use this move for 2 more rounds. Raises Speed if KOs. (Tyrant's Fit)
#===============================================================================
class PokeBattle_Move_5A6 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
        return unless target.damageState.fainted
        user.tryRaiseStat(:SPEED, user, increment: 1, move: self)
    end

    def getFaintEffectScore(user, target)
        return getMultiStatUpEffectScore([:SPEED, 1], user, user)
    end
end