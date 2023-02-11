def healFromBerry(battler, ratio, item, forced = false, filchedFrom = nil)
    battle.pbShowAbilitySplash(battler) if filchedFrom
    battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{item}!"))
    battler.battle.pbCommonAnimation("Nom", battler) unless forced
    ratio *= 2.0 if battler.hasActiveAbility?(:RIPEN)
    itemToPass = forced ? nil : item
    battler.applyFractionalHealing(ratio, item: itemToPass)
end

def pbBattleStatIncreasingBerry(battler, battle, item, forced, stat, increment = 1, checkGluttony = true, filchedFrom = nil)
    return false if !forced && !battler.canConsumePinchBerry?(checkGluttony)
    return false unless battler.pbCanRaiseStatStage?(stat, battler)
    battle.pbShowAbilitySplash(battler) if filchedFrom
    battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{item}!"))
    itemName = GameData::Item.get(item).name
    increment *= 2 if battler.hasActiveAbility?(:RIPEN)
    if forced
        PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
        return battler.pbRaiseStatStage(stat, increment, battler)
    end
    battle.pbCommonAnimation("Nom", battler)
    result = battler.pbRaiseStatStageByCause(stat, increment, battler, itemName)
    battle.pbHideAbilitySplash(battler) if filchedFrom
    return result
end

def pbBattleTypeWeakingBerry(type, moveType, target, mults, feast = false)
    return if moveType != type
    return if Effectiveness.resistant?(target.damageState.typeMod) && moveType != :NORMAL
    if target.hasActiveAbility?(:RIPEN)
        mults[:final_damage_multiplier] = (mults[:final_damage_multiplier] / 4).round
    else
        mults[:final_damage_multiplier] /= 2
    end
    if feast
        target.damageState.feastWeakened = true
    else
        target.damageState.berryWeakened = true
    end
    target.battle.pbCommonAnimation("Nom", target)
end

def pbBattleGem(user, type, move, mults, moveType, aiChecking = false)
    # Pledge moves never consume Gems
    return if move.is_a?(PokeBattle_PledgeMove)
    return if moveType != type
    user.applyEffect(:GemConsumed, user.item_id) unless aiChecking
    mults[:base_damage_multiplier] *= 1.5
end
