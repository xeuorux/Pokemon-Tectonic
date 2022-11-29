def healFromBerry(battler,ratio,item,forced=false)
    hpAmount = battler.totalhp * ratio.to_f
    hpAmount *= 2.0 if battler.hasActiveAbility?(:RIPEN)
    hpAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
    if forced
      battler.pbRecoverHP(hpAmount)
    else
      itemName = GameData::Item.get(item).name
      message = _INTL("{1} restored its health using its {2}!",battler.pbThis,itemName)
      battler.pbRecoverHP(hpAmount,true,true,true,message)
    end
  end
  
  
  def pbBattleConfusionBerry(battler,battle,item,forced,flavor,confuseMsg)
    return false if !forced && !battler.canHeal?
    return false if !forced && !battler.canConsumePinchBerry?(true)
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    healFromBerry(battler,1.0/3.0,item,forced)
    flavor_stat = [:ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE][flavor]
    battler.nature.stat_changes.each do |change|
      next if change[1] > 0 || change[0] != flavor_stat
      battle.pbDisplay(confuseMsg)
      battler.pbConfuse if battler.pbCanConfuseSelf?(false)
      break
    end
    return true
  end
  
  def pbBattleStatIncreasingBerry(battler,battle,item,forced,stat,increment=1,checkGluttony=true)
    return false if !forced && !battler.canConsumePinchBerry?(checkGluttony)
    return false if !battler.pbCanRaiseStatStage?(stat,battler)
    itemName = GameData::Item.get(item).name
    if battler.hasActiveAbility?(:RIPEN)
      increment *=2
    end
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      return battler.pbRaiseStatStage(stat,increment,battler)
    end
    battle.pbCommonAnimation("EatBerry",battler)
    return battler.pbRaiseStatStageByCause(stat,increment,battler,itemName)
  end
  
  def pbBattleTypeWeakingBerry(type,moveType,target,mults,feast=false)
    return if moveType != type
    return if Effectiveness.resistant?(target.damageState.typeMod) && moveType != :NORMAL
    if target.hasActiveAbility?(:RIPEN)
      mults[:final_damage_multiplier] = (mults[:final_damage_multiplier]/4).round
    else
      mults[:final_damage_multiplier] /= 2
    end
    if feast
      target.damageState.feastWeakened = true
    else
      target.damageState.berryWeakened = true
    end
    target.battle.pbCommonAnimation("EatBerry",target)
  end

  def pbBattleGem(user,type,move,mults,moveType,aiChecking=false)
    # Pledge moves never consume Gems
    return if move.is_a?(PokeBattle_PledgeMove)
    return if moveType != type
    user.applyEffect(:GemConsumed,user.item_id) unless aiChecking
    mults[:base_damage_multiplier] *= 1.5
  end