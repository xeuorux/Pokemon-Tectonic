#===============================================================================
# Power doubles for each consecutive use. (Fury Cutter)
#===============================================================================
class PokeBattle_Move_091 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :FuryCutter
        super
    end
end

#===============================================================================
# Power doubles for each consecutive use. (Ice Ball)
#===============================================================================
class PokeBattle_Move_543 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :Snowball
        super
    end
end

#===============================================================================
# Power doubles for each consecutive use. (Rock Roll)
#===============================================================================
class PokeBattle_Move_544 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :RockRoll
        super
    end
end

#===============================================================================
# Power is multiplied by the number of consecutive rounds in which this move was
# used by any Pokémon on the user's side. (Echoed Voice)
#===============================================================================
class PokeBattle_Move_092 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        oldCount = user.pbOwnSide.effects[:EchoedVoiceCounter]
        super # Reset all other counters

        # If this is the first time the move is being used on this side this turn
        unless user.pbOwnSide.effectActive?(:EchoedVoiceUsed)
            user.pbOwnSide.effects[:EchoedVoiceCounter] = oldCount
            user.pbOwnSide.incrementEffect(:EchoedVoiceCounter)
        end
        user.pbOwnSide.applyEffect(:EchoedVoiceUsed)
    end

    def pbBaseDamage(baseDmg, user, _target)
        return baseDmg * user.pbOwnSide.effects[:EchoedVoiceCounter]
    end
end

#===============================================================================
# Power increases by 20 for each consecutive use. User heals by 50% of damage dealt. (Heart Rhythm)
#===============================================================================
class PokeBattle_Move_5A9 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :HeartRhythm
        super
    end

    def damageAtCount(baseDmg, count)
        return baseDmg + 20 * count
    end

    def healingMove?; return true; end

    def drainFactor(_user, _target); return 0.5; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0
        hpGain = (target.damageState.hpLost * drainFactor(user, target)).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end
end

#===============================================================================
# Hits three times by base, and one extra every time the move is used
# over the course of a battle. (Blades of Grass)
#===============================================================================
class PokeBattle_Move_130 < PokeBattle_Move
    def multiHitMove?; return true; end

    def pbNumHits(user, _targets, _checkingForAI = false)
        return 3 + user.moveUsageCount(@id)
    end
end