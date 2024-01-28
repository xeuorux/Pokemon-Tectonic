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