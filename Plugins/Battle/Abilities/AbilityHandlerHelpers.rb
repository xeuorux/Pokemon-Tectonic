# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(user, target, move, moveType, immuneType, battle, showMessages, aiChecking = false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiChecking
    if target.applyFractionalHealing(1.0 / 4.0, showAbilitySplash: true) <= 0 && showMessages
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis, target.abilityName,
move.name))
    end
    return true
end

# For abilities that grant immunity to moves of a particular type, and raises
# one of the ability's bearer's stats instead.
def pbBattleMoveImmunityStatAbility(user, target, move, moveType, immuneType, stat, increment, battle, showMessages, aiChecking = false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiChecking
    battle.pbShowAbilitySplash(target) if showMessages
    if stat.is_a?(Array)
        target.pbRaiseMultipleStatStages(stat, target, move: move)
    else
        if !target.tryRaiseStat(stat, target, increment: increment) && showMessages
            battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
        end
    end
    battle.pbHideAbilitySplash(target)
    return true
end

def pbBattleWeatherAbility(weather, battler, battle, ignorePrimal = false, ignoreFainted = false, aiChecking = false)
    return if !ignorePrimal && %i[HarshSun HeavyRain StrongWinds].include?(battle.field.weather)
    baseWeatherAbilityDuration = 4
    if aiChecking
        duration = battler.getWeatherSettingDuration(weather, baseWeatherAbilityDuration, ignoreFainted)
        duration -= battle.field.weatherDuration if battle.field.weather == weather
        ret = -getWeatherSettingEffectScore(weather, battler, battle, duration, false)
        return ret
    else
        battle.pbShowAbilitySplash(battler) # NOTE: The ability splash is hidden again in def pbStartWeather.
        battle.pbStartWeather(battler, weather, baseWeatherAbilityDuration, true, ignoreFainted)
    end
end

def terrainSetAbility(terrain, battler, battle, _ignorePrimal = false)
    return if battle.field.terrain == terrain
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, terrain)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
end

def randomStatusProcUserAbility(status, chance, user, target, move, battle, aiChecking = false, aiNumHits = 1)
    return if target.pbHasStatus?(status)
    return if target.fainted?
    if aiChecking
        chanceOfActivating = 1 - (((100 - chance) / 100)**aiNumHits)
        ret = getStatusSettingEffectScore(status, target, user)
        ret *= chanceOfActivating
        ret = ret.round(-1)
        return ret
    else
        return if battle.pbRandom(100) >= chance
        return unless move.canApplyAdditionalEffects?(user, target, true)
        battle.pbShowAbilitySplash(user)
        target.pbInflictStatus(status, 0, nil, user) if target.pbCanInflictStatus?(status, user, true, move)
        battle.pbHideAbilitySplash(user)
    end
end

def randomStatusProcTargetAbility(status, chance, user, target, move, battle, aiChecking = false, aiNumHits = 1)
    return if user.pbHasStatus?(status)
    return if user.fainted?
    if aiChecking
        chanceOfActivating = 1 - (((100 - chance) / 100)**aiNumHits)
        ret = -getStatusSettingEffectScore(status, target, user)
        ret *= chanceOfActivating
        ret = ret.round(-1)
        return ret
    else
        return if battle.pbRandom(100) >= chance
        battle.pbShowAbilitySplash(target)
        user.pbInflictStatus(status, 0, nil, target) if user.pbCanInflictStatus?(status, target, true, move)
        battle.pbHideAbilitySplash(target)
    end
end