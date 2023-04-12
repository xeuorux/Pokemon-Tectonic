# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(ability, user, target, move, moveType, immuneType, battle, showMessages, aiChecking = false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiChecking
    if target.applyFractionalHealing(1.0 / 4.0, ability: ability) <= 0 && showMessages
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis, getAbilityName(ability),
move.name))
    end
    return true
end

# For abilities that grant immunity to moves of a particular type, and raises
# one of the ability's bearer's stats instead.
def pbBattleMoveImmunityStatAbility(ability, user, target, move, moveType, immuneType, stat, increment, battle, showMessages, aiChecking = false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiChecking
    battle.pbShowAbilitySplash(target, ability) if showMessages
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

def pbBattleWeatherAbility(ability, weather, battler, battle, ignorePrimal = false, ignoreFainted = false, aiChecking = false, baseDuration: 4)
    return 0 if battle.pbWeather == weather && battle.field.weatherDuration == -1
    return 0 if !ignorePrimal && battle.primevalWeatherPresent?(!aiChecking)
    if aiChecking
        if baseDuration < 0 # infinite
            duration = 20 - battle.turnCount
        else
            duration = battler.getWeatherSettingDuration(weather, baseDuration, ignoreFainted)
            duration -= battle.field.weatherDuration if battle.field.weather == weather
        end
        ret = -getWeatherSettingEffectScore(weather, battler, battle, duration, false)
        return ret
    else
        battle.pbShowAbilitySplash(battler, ability) # NOTE: The ability splash is hidden again in def pbStartWeather.
        battle.pbStartWeather(battler, weather, baseDuration, true, ignoreFainted)
    end
end

def terrainSetAbility(ability, terrain, battler, battle, _ignorePrimal = false)
    return if battle.field.terrain == terrain
    battle.pbShowAbilitySplash(battler, ability)
    battle.pbStartTerrain(battler, terrain)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
end

def randomStatusProcUserAbility(ability, status, chance, user, target, move, battle, aiChecking = false, aiNumHits = 1)
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
        battle.pbShowAbilitySplash(user, ability)
        target.pbInflictStatus(status, 0, nil, user) if target.pbCanInflictStatus?(status, user, true, move)
        battle.pbHideAbilitySplash(user)
    end
end

def randomStatusProcTargetAbility(ability, status, chance, user, target, move, battle, aiChecking = false, aiNumHits = 1)
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
        battle.pbShowAbilitySplash(target, ability)
        user.pbInflictStatus(status, 0, nil, target) if user.pbCanInflictStatus?(status, target, true, move)
        battle.pbHideAbilitySplash(target)
    end
end