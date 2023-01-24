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
def pbBattleMoveImmunityStatAbility(user, target, _move, moveType, immuneType, stat, increment, battle, showMessages, aiChecking = false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiChecking
    battle.pbShowAbilitySplash(target) if showMessages
    if !target.tryRaiseStat(stat, target, increment: increment) && showMessages
        battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
    end
    battle.pbHideAbilitySplash(target)
    return true
end

def pbBattleWeatherAbility(weather, battler, battle, ignorePrimal = false, ignoreFainted = false)
    return if !ignorePrimal && %i[HarshSun HeavyRain StrongWinds].include?(battle.field.weather)
    battle.pbShowAbilitySplash(battler)
    battle.pbStartWeather(battler, weather, 4, true, ignoreFainted)
    # NOTE: The ability splash is hidden again in def pbStartWeather.
end

def terrainSetAbility(terrain, battler, battle, _ignorePrimal = false)
    return if battle.field.terrain == terrain
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, terrain)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
end

def randomStatusProcAbility(status, chance, user, target, move, battle)
    return if battle.pbRandom(100) >= chance
    return if target.pbHasStatus?(status)
    return if target.fainted?
    return unless move.canApplyAdditionalEffects?(user, target)
    battle.pbShowAbilitySplash(user)
    target.pbInflictStatus(status, 0, nil, user) if target.pbCanInflictStatus?(status, user, true, move)
    battle.pbHideAbilitySplash(user)
end
