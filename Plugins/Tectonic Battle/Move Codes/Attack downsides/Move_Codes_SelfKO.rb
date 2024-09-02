#===============================================================================
# User faints, even if the move does nothing else. (Explosion, Self-Destruct)
#===============================================================================
class PokeBattle_Move_UserFaintsExplosive < PokeBattle_Move
    def worksWithNoTargets?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbSelfKO(user)
        return if user.fainted?

        if user.hasActiveAbility?(:SPINESPLODE) && !user.pbOpposingSide.effectAtMax?(:Spikes)
            @battle.pbShowAbilitySplash(user, :SPINESPLODE)
            user.pbOpposingSide.incrementEffect(:Spikes, 2)
            @battle.pbHideAbilitySplash(user)
        end

        if user.bunkeringDown?
            @battle.pbShowAbilitySplash(user, :BUNKERDOWN)
            @battle.pbDisplay(_INTL("{1}'s {2} barely saves it!", user.pbThis, @name))
            user.pbReduceHP(user.hp - 1, false)
            @battle.pbHideAbilitySplash(user)
        else
            reduction = user.totalhp
            unbreakable = user.hasActiveAbility?(:UNBREAKABLE)
            if unbreakable
                @battle.pbShowAbilitySplash(user, :UNBREAKABLE)
                @battle.pbDisplay(_INTL("{1} resists the recoil!", user.pbThis))
                reduction /= 2
            end
            user.pbReduceHP(reduction, false)
            @battle.pbHideAbilitySplash(user) if unbreakable
            if user.hasActiveAbility?(:PERENNIALPAYLOAD,true)
                @battle.pbShowAbilitySplash(user, :PERENNIALPAYLOAD)
                @battle.pbDisplay(_INTL("{1} will revive in six turns!", user.pbThis))
                if user.pbOwnSide.effectActive?(:PerennialPayload)
                    user.pbOwnSide.effects[:PerennialPayload][user.pokemonIndex] = 7
                else
                    user.pbOwnSide.effects[:PerennialPayload] = {
                        user.pokemonIndex => 7,
                    }
                end
                @battle.pbHideAbilitySplash(user)
            end
        end
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        score += 30 if user.bunkeringDown?(true)
        score += 30 if user.hasActiveAbilityAI?(:PERENNIALPAYLOAD)
        if user.hasActiveAbility?(:SPINESPLODE)
            currentSpikeCount = user.pbOpposingSide.countEffect(:Spikes)
            spikesMax = GameData::BattleEffect.get(:Spikes).maximum
            count = [spikesMax, currentSpikeCount + 2].min - currentSpikeCount
            score += count * getHazardSettingEffectScore(user, target)
        end
        return score
    end
end

#===============================================================================
# Inflicts fixed damage equal to user's current HP. (Final Gambit)
# User faints (if successful).
#===============================================================================
class PokeBattle_Move_UserFaintsFixedDamageUserHP < PokeBattle_FixedDamageMove
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

#===============================================================================
# User faints, even if the move does nothing else. (Spiky Burst)
# Deals extra damage per "Spike" on the enemy side.
#===============================================================================
class PokeBattle_Move_UserFaintsExplosiveScalesWithEnemySideSpikes < PokeBattle_Move_UserFaintsExplosive
    def pbBaseDamage(baseDmg, _user, target)
        target.pbOwnSide.eachEffect(true) do |effect, value, effectData|
            next unless effectData.is_spike?
            baseDmg += 50 * value
        end
        return baseDmg
    end
end