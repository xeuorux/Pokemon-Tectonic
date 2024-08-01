# For abilities that grant immunity to moves of a particular type, and heals the
# ability's bearer by 1/4 of its total HP instead.
def pbBattleMoveImmunityHealAbility(ability, user, target, move, moveType, immuneType, battle, showMessages, aiCheck = false, canOverheal: false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiCheck
    if target.applyFractionalHealing(1.0 / 4.0, ability: ability, canOverheal: canOverheal) <= 0 && showMessages
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!", target.pbThis, getAbilityName(ability),
move.name))
        battle.pbHideAbilitySplash(target)
    end
    return true
end

# For abilities that grant immunity to moves of a particular type, and raises
# one of the ability's bearer's stats instead.
def pbBattleMoveImmunityStatAbility(ability, user, target, move, moveType, immuneType, stat, increment, battle, showMessages, aiCheck = false)
    return false if user.index == target.index
    return false if moveType != immuneType
    return true if aiCheck
    battle.pbShowAbilitySplash(target, ability) if showMessages
    if stat.is_a?(Array)
        target.pbRaiseMultipleStatSteps(stat, target, move: move)
    else
        if !target.tryRaiseStat(stat, target, increment: increment) && showMessages
            battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
        end
    end
    battle.pbHideAbilitySplash(target)
    return true
end

def pbBattleWeatherAbility(ability, weather, battler, battle, ignorePrimal = false, ignoreFainted = false, aiCheck = false, baseDuration: 4)
    return 0 if battle.pbWeather == weather && battle.field.weatherDuration == -1
    return 0 if !ignorePrimal && battle.primevalWeatherPresent?(!aiCheck)
    if aiCheck
        if baseDuration < 0 # infinite
            duration = 20
        else
            duration = battler.getWeatherSettingDuration(weather, baseDuration, ignoreFainted)
            duration -= battle.field.weatherDuration if battle.field.weather == weather
        end
        return getWeatherSettingEffectScore(weather, battler, battle, duration, false)
    else
        battle.pbShowAbilitySplash(battler, ability) # NOTE: The ability splash is hidden again in def pbStartWeather.
        battle.pbStartWeather(battler, weather, baseDuration, true, ignoreFainted)
    end
end

def randomStatusProcUserAbility(ability, status, chance, user, target, move, battle, aiCheck = false, aiNumHits = 1)
    return if target.pbHasStatus?(status)
    return if target.fainted?
    if aiCheck
        chanceOfActivating = 1 - (((100 - chance) / 100)**aiNumHits)
        ret = getStatusSettingEffectScore(status, target, user)
        ret *= chanceOfActivating
        ret = ret.round(-1)
        return ret
    else
        return if battle.pbRandom(100) >= chance
        return unless move.canApplyRandomAddedEffects?(user, target, true)
        battle.pbShowAbilitySplash(user, ability)
        target.pbInflictStatus(status, 0, nil, user) if target.pbCanInflictStatus?(status, user, true, move)
        battle.pbHideAbilitySplash(user)
    end
end

def randomStatusProcTargetAbility(ability, status, chance, user, target, move, battle, aiCheck = false, aiNumHits = 1)
    return if user.pbHasStatus?(status)
    return if user.fainted?
    if aiCheck
        chanceOfActivating = 1 - (((100 - chance) / 100.0)**aiNumHits)
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

def entryDebuffAbility(ability, battler, battle, statDownArray, aiCheck: false)
    battle.pbShowAbilitySplash(battler, ability) unless aiCheck
    score = 0
    battler.eachOpposing(true) do |b|
        next unless b.near?(battler)
        next if b.blockAteAbilities(battler, ability, !aiCheck)
        if aiCheck
            score += getMultiStatDownEffectScore(statDownArray,battler,b)
        elsif b.pbLowerMultipleStatSteps(statDownArray, battler, showFailMsg: true)
            b.pbItemOnIntimidatedCheck
        end
    end
    battle.pbHideAbilitySplash(battler) unless aiCheck
    return score if aiCheck
end

def entryTrappingAbility(ability, battler, battle, trappingMove, trappingDuration: 2, aiCheck: false, &block)
    trappingDuration *= 2 if battler.shouldItemApply?(:GRIPCLAW,aiCheck )

    score = 0
    battle.pbShowAbilitySplash(battler, ability) unless aiCheck
    battler.eachOpposing do |b|
        next if b.effectActive?(:Trapping)
        if aiCheck
            score += 15 * trappingDuration
        else
            b.applyEffect(:Trapping, trappingDuration)
            b.applyEffect(:TrappingMove, trappingMove)
            b.pointAt(:TrappingUser, battler)

            if block_given?
                trappingMessage = block.call(b)
            else
                trappingMessage = _INTL("{1} became trapped!", b.pbThis)
            end
            battle.pbDisplay(trappingMessage)
        end
    end
    battle.pbHideAbilitySplash(battler) unless aiCheck
    return score
end

def entryLowestHealingAbility(ability, battler, battle, healingFraction = 0.5, aiCheck: false, &block)
    lowestId = battler.index
    lowestPercent = battler.hp / battler.totalhp.to_f
    battler.eachAlly do |b|
        thisHP = b.hp / b.totalhp.to_f
        if (thisHP < lowestPercent) && b.canHeal?
            lowestId = b.index
            lowestPercent = thisHP
        end
    end
    lowestIdBattler = battle.battlers[lowestId]
    if aiCheck    
        return 0 unless lowestIdBattler.canHeal?
        healingScore = lowestIdBattler.applyFractionalHealing(healingFraction, aiCheck: true)
        return healingScore
    end
    served = (lowestId == battler.index ? "itself" : lowestIdBattler.pbThis)
    healMessage = block.call(served)
    battle.pbShowAbilitySplash(battler, ability)
    lowestIdBattler.applyFractionalHealing(healingFraction, customMessage: healMessage)
    battle.pbHideAbilitySplash(battler)
end

# Protean and such
def moveUseTypeChangeAbility(ability, user, move, battle, thirdType = false)
    return false if move.callsAnotherMove?
    return false if move.snatched
    return false if GameData::Type.get(move.calcType).pseudo_type
    return false unless user.pbHasOtherType?(move.calcType)
    battle.pbShowAbilitySplash(user, ability)
    if thirdType
        user.applyEffect(:Type3, move.calcType)
    else
        user.pbChangeTypes(move.calcType)
        typeName = GameData::Type.get(move.calcType).name
        battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
    battle.pbHideAbilitySplash(user)
    return true
end