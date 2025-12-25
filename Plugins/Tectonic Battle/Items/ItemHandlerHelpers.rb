def healFromBerry(battler, ratio, item, forced = false, filchedFrom = nil, filchingAbility = nil, items_to_skip: [])
    if filchedFrom
        battler.battle.pbShowAbilitySplash(battler, filchingAbility)
        itemName = GameData::Item.get(item).name
        battler.battle.pbDisplay(_INTL("{1} filched {2}'s {3}!", battler.pbThis, filchedFrom.pbThis(true), itemName))
    end
    battler.battle.pbCommonAnimation("Nom", battler) unless forced
    ratio *= 2.0 if battler.hasActiveAbility?(:RIPEN)
    if battler.hasTribeBonus?(:SCAVENGER)
        ratio *= 1.5
        battler.battle.pbShowTribeSplash(battler,:SCAVENGER)
        battler.battle.pbDisplay(_INTL("{1} got a bit extra out of their {2}!", battler.pbThis, getItemName(item)))
        battler.battle.pbHideTribeSplash(battler)
    end
    itemToPass = forced ? nil : item
    items_to_skip.push(itemToPass) if itemToPass
    battler.applyFractionalHealing(ratio, item: itemToPass, items_to_skip: items_to_skip)
    battler.battle.pbHideAbilitySplash(battler) if filchedFrom
end

def pbBattleStatIncreasingBerry(battler, battle, item, forced, stat, increment = 1, checkGluttony = true, filchedFrom = nil, filchingAbility = nil)
    return false if !forced && !battler.canConsumePinchBerry?(checkGluttony)
    return false unless battler.pbCanRaiseStatStep?(stat, battler)
    if filchedFrom
        battle.pbShowAbilitySplash(battler, filchingAbility)
        itemName = GameData::Item.get(item).name
        battle.pbDisplay(_INTL("{1} filched {2}'s {3}!", battler.pbThis, filchedFrom.pbThis(true), itemName))
    end
    itemName = GameData::Item.get(item).name
    increment *= 2 if battler.hasActiveAbility?(:RIPEN)
    if forced
        return battler.pbRaiseStatStep(stat, increment, battler)
    end
    battle.pbCommonAnimation("Nom", battler)
    result = battler.pbRaiseStatStepByCause(stat, increment, battler, itemName)
    battle.pbHideAbilitySplash(battler) if filchedFrom
    return result
end

def pbBattleTypeWeakingBerry(item, type, moveType, target, mults, feast = false, aiCheck = false)
    return if moveType != type
    return if !Effectiveness.super_effective?(target.damageState.typeMod) && moveType != :NORMAL
    if target.hasActiveAbility?(:RIPEN)
        mults[:final_damage_multiplier] = (mults[:final_damage_multiplier] / 4).round
    else
        mults[:final_damage_multiplier] /= 2
    end
    if feast
        target.damageState.feastWeakened = item
    else
        target.damageState.berryWeakened = item
    end
    target.battle.pbCommonAnimation("Nom", target) unless aiCheck
end

def pbBattleGem(item, user, type, move, mults, moveType, aiCheck = false)
    # Pledge moves never consume Gems
    return if move.is_a?(PokeBattle_PledgeMove)
    return if moveType != type
    return unless user.canConsumeGem?
    user.applyEffect(:GemConsumed, item) unless aiCheck
    mults[:base_damage_multiplier] *= 1.5
end

def typeBoostingItem(item, user, type, mults, moveType, aiCheck = false)
    if moveType == type
        mults[:base_damage_multiplier] *= 1.2
        user.aiLearnsItem(item) unless aiCheck
    end
end