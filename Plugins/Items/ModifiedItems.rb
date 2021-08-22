
def pbBattleConfusionBerry(battler,battle,item,forced,flavor,confuseMsg)
  return false if !forced && !battler.canHeal?
  return false if !forced && !battler.canConsumePinchBerry?(Settings::MECHANICS_GENERATION >= 7)
  itemName = GameData::Item.get(item).name
  battle.pbCommonAnimation("EatBerry",battler) if !forced
  fraction_to_heal = 8   # Gens 6 and lower
  if Settings::MECHANICS_GENERATION == 7;    fraction_to_heal = 2
  elsif Settings::MECHANICS_GENERATION >= 8; fraction_to_heal = 3
  end
  intendedHealAmount = (battler.totalhp / fraction_to_heal)
  intendedHealAmount *= 2 if battler.hasActiveAbility?(:RIPEN)
  amt = battler.pbRecoverHP(intendedHealAmount)
  if amt>0
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
  end
  flavor_stat = [:ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE][flavor]
  battler.nature.stat_changes.each do |change|
    next if change[1] > 0 || change[0] != flavor_stat
    battle.pbDisplay(confuseMsg)
    battler.pbConfuse if battler.pbCanConfuseSelf?(false)
    break
  end
  return true
end

def pbBattleStatIncreasingBerry(battler,battle,item,forced,stat,increment=1)
  return false if !forced && !battler.canConsumePinchBerry?
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

def pbBattleTypeWeakingBerry(type,moveType,target,mults)
  return if moveType != type
  return if Effectiveness.resistant?(target.damageState.typeMod) && moveType != :NORMAL
  if target.hasActiveAbility?(:RIPEN)
    mults[:final_damage_multiplier] = (mults[:final_damage_multiplier]/4).round
  else
	mults[:final_damage_multiplier] /= 2
  end
  target.damageState.berryWeakened = true
  target.battle.pbCommonAnimation("EatBerry",target)
end

BattleHandlers::HPHealItem.add(:ORANBERRY,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    battle.pbCommonAnimation("EatBerry",battler) if !forced
	healAmount = 10
	healAmount *= 2 if battler.hasActiveAbility?(:RIPEN)
    battler.pbRecoverHP(healAmount)
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",battler.pbThis,itemName))
    end
    next true
  }
)

BattleHandlers::HPHealItem.add(:SITRUSBERRY,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    battle.pbCommonAnimation("EatBerry",battler) if !forced
	if battler.hasActiveAbility?(:RIPEN)
		battler.pbRecoverHP(battler.totalhp/4)
	else
		battler.pbRecoverHP(battler.totalhp/2)
	end
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
    end
    next true
  }
)

BattleHandlers::StatusCureItem.add(:ASPEARBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :FROZEN
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} unchilled it!",battler.pbThis,itemName)) if !forced
    next true
  }
)

ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :FROZEN
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was unchilled out.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

BattleHandlers::EOREffectItem.add(:TOXICORB,
  proc { |item,battler,battle|
    next if !battler.pbCanPoison?(nil,false)
    battler.pbPoison(nil,_INTL("{1} was toxified by the {2}!",
       battler.pbThis,battler.itemName),true)
  }
)

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,:STATUSHEAL)

ItemHandlers::UseOnPokemon.add(:POTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,40,scene)
})

ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,80,scene)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,120,scene)
})

BattleHandlers::StatusCureItem.add(:LUMBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status == :NONE
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    oldStatus = battler.status
    battler.pbCureStatus(forced)
    if !forced
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,itemName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,itemName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,itemName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,itemName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,itemName))
      end
    end
    next true
  }
)

BattleHandlers::StatusCureItem.add(:PERSIMBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.effects[PBEffects::Confusion]==0 && battler.effects[PBEffects::Charm]==0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
	wasConfused 	= (battler.effects[PBEffects::Confusion]>0)
	wasCharmed		= (battler.effects[PBEffects::Charm]>0)
    battler.pbCureConfusion
	battler.pbCureCharm
    if forced
		battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis)) if wasConfused
		battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis)) if wasCharmed
    else
		battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName)) if wasConfused
		battle.pbDisplay(_INTL("{1}'s {2} released it from the charm!",battler.pbThis,itemName)) if wasCharmed
    end
    next true
  }
)

BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
  proc { |item,user,target,move,battle|
    next if !target.canConsumeBerry?
    next if !move.physicalMove?
    next if !user.takesIndirectDamage?
    battle.pbCommonAnimation("EatBerry",target)
    battle.scene.pbDamageAnimation(user)
	if target.hasActiveAbility?(:RIPEN)
		user.pbReduceHP(user.totalhp/4,false)
	else
		user.pbReduceHP(user.totalhp/8,false)
	end
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
       target.itemName,user.pbThis(true)))
    target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROWAPBERRY,
  proc { |item,user,target,move,battle|
    next if !target.canConsumeBerry?
    next if !move.specialMove?
    next if !user.takesIndirectDamage?
    battle.pbCommonAnimation("EatBerry",target)
    battle.scene.pbDamageAnimation(user)
    if target.hasActiveAbility?(:RIPEN)
		user.pbReduceHP(user.totalhp/4,false)
	else
		user.pbReduceHP(user.totalhp/8,false)
	end
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
       target.itemName,user.pbThis(true)))
    target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::StatusCureItem.add(:MENTALHERB,
  proc { |item,battler,battle,forced|
    next false if battler.effects[PBEffects::Attract]==-1 &&
                  battler.effects[PBEffects::Taunt]==0 &&
                  battler.effects[PBEffects::Encore]==0 &&
                  !battler.effects[PBEffects::Torment] &&
                  battler.effects[PBEffects::Disable]==0 &&
                  battler.effects[PBEffects::HealBlock]==0 &&
				  battler.effects[PBEffects::Confusion]==0 &&
				  battler.effects[PBEffects::Charm]==0 &&
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    battle.pbCommonAnimation("UseItem",battler) if !forced
    if battler.effects[PBEffects::Attract]>=0
      if forced
        battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} cured its infatuation status using its {2}!",
           battler.pbThis,itemName))
      end
      battler.pbCureAttract
    end
    battle.pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis)) if battler.effects[PBEffects::Taunt]>0
    battler.effects[PBEffects::Taunt]      = 0
    battle.pbDisplay(_INTL("{1}'s encore ended!",battler.pbThis)) if battler.effects[PBEffects::Encore]>0
    battler.effects[PBEffects::Encore]     = 0
    battler.effects[PBEffects::EncoreMove] = nil
    battle.pbDisplay(_INTL("{1}'s torment wore off!",battler.pbThis)) if battler.effects[PBEffects::Torment]
    battler.effects[PBEffects::Torment]    = false
    battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis)) if battler.effects[PBEffects::Disable]>0
    battler.effects[PBEffects::Disable]    = 0
    battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis)) if battler.effects[PBEffects::HealBlock]>0
    battler.effects[PBEffects::HealBlock]  = 0
	battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName)) if battler.effects[PBEffects::Confusion]>0
	battler.pbCureConfusion
	battle.pbDisplay(_INTL("{1}'s {2} released it from the charm!",battler.pbThis,itemName)) if battler.effects[PBEffects::Charm]>0
	battler.pbCureCharm
    next true
  }
)

BattleHandlers::DamageCalcUserItem.add(:THICKCLUB,
  proc { |item,user,target,move,mults,baseDmg,type|
    if (user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK)) && move.physicalMove?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::TargetItemOnHit.add(:ENIGMABERRY,
  proc { |item,user,target,move,battle|
    next if target.damageState.substitute || target.damageState.disguise || target.damageState.iceface
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
      target.pbHeldItemTriggered(item)
    end
  }
)

BattleHandlers::TargetItemOnHit.add(:WEAKNESSPOLICY,
  proc { |item,user,target,move,battle|
    next if target.damageState.disguise  || target.damageState.iceface
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    next if !target.pbCanRaiseStatStage?(:ATTACK,target) &&
            !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
    battle.pbCommonAnimation("UseItem",target)
    showAnim = true
    if target.pbCanRaiseStatStage?(:ATTACK,target)
      target.pbRaiseStatStageByCause(:ATTACK,2,target,target.itemName,showAnim)
      showAnim = false
    end
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      target.pbRaiseStatStageByCause(:SPECIAL_ATTACK,2,target,target.itemName,showAnim)
    end
    target.pbHeldItemTriggered(item)
  }
)

#===============================================================================
# TargetItemOnHitPositiveBerry handlers
# NOTE: This is for berries that have an effect when Pluck/Bug Bite/Fling
#       forces their use.
#===============================================================================

BattleHandlers::TargetItemOnHitPositiveBerry.add(:ENIGMABERRY,
  proc { |item,battler,battle,forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumeBerry?
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    if battler.hasActiveAbility?(:RIPEN)
      battler.pbRecoverHP(battler.totalhp/2)
    else
      battler.pbRecoverHP(battler.totalhp/4)
    end
    if forced
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,
         itemName))
    end
    next true
  }
)

BattleHandlers::TargetItemOnHitPositiveBerry.add(:KEEBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.pbCanRaiseStatStage?(:DEFENSE,battler)
    itemName = GameData::Item.get(item).name
	increment = 1
	if battler.hasActiveAbility?(:RIPEN)
      increment *=2
    end
    if !forced
      battle.pbCommonAnimation("EatBerry",battler)
      next battler.pbRaiseStatStageByCause(:DEFENSE,increment,battler,itemName)
    end
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    next battler.pbRaiseStatStage(:DEFENSE,increment,battler)
  }
)

BattleHandlers::TargetItemOnHitPositiveBerry.add(:MARANGABERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,battler)
    itemName = GameData::Item.get(item).name
	ncrement = 1
	if battler.hasActiveAbility?(:RIPEN)
      increment *=2
    end
    if !forced
      battle.pbCommonAnimation("EatBerry",battler)
      next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,increment,battler,itemName)
    end
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    next battler.pbRaiseStatStage(:SPECIAL_DEFENSE,increment,battler)
  }
)


BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
  proc { |item,user,target,move,battle|
    next if !target.canConsumeBerry?
    next if !move.physicalMove?
    next if !user.takesIndirectDamage?
    battle.pbCommonAnimation("EatBerry",target)
    battle.scene.pbDamageAnimation(user)
	reduce = user.totalhp/8
	reduce /= 4 if user.boss
    user.pbReduceHP(reduce,false)
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
       target.itemName,user.pbThis(true)))
    target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROWAPBERRY,
  proc { |item,user,target,move,battle|
    next if !target.canConsumeBerry?
    next if !move.specialMove?
    next if !user.takesIndirectDamage?
    battle.pbCommonAnimation("EatBerry",target)
    battle.scene.pbDamageAnimation(user)
    reduce = user.totalhp/8
	reduce /= 4 if user.boss
    user.pbReduceHP(reduce,false)
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
       target.itemName,user.pbThis(true)))
    target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROCKYHELMET,
  proc { |item,user,target,move,battle|
    next if !move.pbContactMove?(user) || !user.affectedByContactEffect?
    next if !user.takesIndirectDamage?
    battle.scene.pbDamageAnimation(user)
	reduce = user.totalhp/6
	reduce /= 4 if user.boss
    user.pbReduceHP(reduce,false)
    battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,target.itemName))
  }
)