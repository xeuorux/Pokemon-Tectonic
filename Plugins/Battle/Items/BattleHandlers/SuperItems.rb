# Choice Crown
BattleHandlers::DamageCalcUserItem.add(:CHOICECROWN,
    proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
      mults[:base_damage_multiplier] *= 1.5
    }
)

BattleHandlers::SpeedCalcItem.add(:CHOICECROWN,
    proc { |item,battler,mult|
      next mult * 1.5
    }
)

# Zenith Band
BattleHandlers::AttackCalcUserItem.add(:ZENITHBAND,
  proc { |item,user,target,move,mults,baseDmg,type|
      attackMult *= 2.0
      next attackMult
  }
)

# Zenith Specs
BattleHandlers::SpecialAttackCalcUserItem.add(:ZENITHSPECS,
  proc { |item,user,battle,spAtkMult|
      spAtkMult *= 2.0
      next spAtkMult
  }
)

# Zenith Scarf
BattleHandlers::SpeedCalcItem.add(:ZENITHSCARF,
    proc { |item,battler,mult|
      next mult * 2.0
    }
)

# All-Purpose Vest
BattleHandlers::DamageCalcTargetItem.add(:ALLPURPOSEVEST,
    proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
      mults[:defense_multiplier] *= 1.5
    }
)

# Assault Corset
BattleHandlers::SpecialDefenseCalcUserItem.copy(:ASSAULTVEST,:ASSAULTCORSET)
BattleHandlers::TargetItemOnHit.copy(:ROCKYHELMET,:ASSAULTCORSET)

# Strike Corset
BattleHandlers::DefenseCalcUserItem.copy(:STRIKEVEST,:STRIKECORSET)
BattleHandlers::TargetItemOnHit.copy(:BUSTEDRADIO,:STRIKECORSET)

# Jagged Helmet
BattleHandlers::TargetItemOnHit.add(:JAGGEDHELMET,
    proc { |item,user,target,move,battle|
        next unless move.physicalMove?
        next if !user.takesIndirectDamage?
        battle.pbDisplay(_INTL("{1} was badly hurt by the {2}!",user.pbThis,target.itemName))
        user.applyFractionalDamage(1.0/3.0)
    }
)
  
BattleHandlers::TargetItemOnHit.add(:RUPTUREDRADIO,
    proc { |item,user,target,move,battle|
        next unless move.specialMove?
        next if !user.takesIndirectDamage?
        battle.pbDisplay(_INTL("{1} was badly hurt by the {2}!",user.pbThis,target.itemName))
        user.applyFractionalDamage(1.0/3.0)
    }
)

# Sitreon berry
BattleHandlers::HPHealItem.add(:SITREONBERRY,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      battle.pbCommonAnimation("Nom",battler) if !forced
      healFromBerry(battler,1.0/2.0,item,forced=false)
      next true
    }
)

# Roseli Feast
BattleHandlers::EORHealingItem.copy(:LEFTOVERS,:ROSELIFEAST)

BattleHandlers::DamageCalcTargetItem.add(:ROSELIFEAST,
    proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
      pbBattleTypeWeakingBerry(:FAIRY,type,target,mults,true)
    }
)

# Occa Feast
BattleHandlers::EORHealingItem.copy(:LEFTOVERS,:OCCAFEAST)

BattleHandlers::DamageCalcTargetItem.add(:OCCAFEAST,
    proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
      pbBattleTypeWeakingBerry(:FIRE,type,target,mults,true)
    }
)

# Rindo Feast
BattleHandlers::EORHealingItem.copy(:LEFTOVERS,:RINDOFEAST)

BattleHandlers::DamageCalcTargetItem.add(:RINDOFEAST,
    proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
      pbBattleTypeWeakingBerry(:GRASS,type,target,mults,true)
    }
)

# Lunus berry
BattleHandlers::StatusCureItem.add(:LUNUSBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if !battler.hasAnyStatusNoTrigger
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("Nom",battler) if !forced
      battler.pbCureStatus
      battler.pbRaiseMultipleStatStages([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1], user, item: item)
      next true
    }
)

# Zalaka Berry
BattleHandlers::HPHealItem.add(:ZALAKABERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPEED,99,false)
    }
)

# Lucent Gem
BattleHandlers::DamageCalcUserItem.add(:LUCENTGEM,
    proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
        user.applyEffect(:GemConsumed,user.item_id) unless aiChecking
        mults[:base_damage_multiplier] *= 1.5
    }
)

# Rings
ringTypes = [:NORMAL,:FIRE,:WATER,:GRASS,:ELECTRIC,:ICE,:FIGHTING,:POISON,:GROUND,:FLYING,:PSYCHIC,:BUG,:ROCK,:GHOST,:DARK,:DRAGON,:STEEL,:FAIRY]

ringTypes.each do |type_sym|
  ringSym = (type_sym.to_s + "RING").to_sym
  gemSym = (type_sym.to_s + "GEM").to_sym
  BattleHandlers::EORHealingItem.copy(:LEFTOVERS,ringSym)
  BattleHandlers::DamageCalcUserItem.copy(gemSym,ringSym)
  SUPER_ITEMS.push(ringSym)
end

# White Bough
BattleHandlers::EndOfMoveStatRestoreItem.add(:WHITEBOUGH,
  proc { |item,battler,battle,forced|
    reducedStats = false
    GameData::Stat.each_battle do |s|
      next if battler.stages[s.id] >= 0
      battler.stages[s.id] = 0
      reducedStats = true
    end
    next false if !reducedStats
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("UseItem",battler) if !forced
    if forced
      battle.pbDisplay(_INTL("{1}'s status returned to normal!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} returned its status to normal using its {2}!",
         battler.pbThis,itemName))
    end
    # Healing aspect
    itemToPass = forced ? nil : item
    battler.applyFractionalHealing(1.0/2.0, item: itemToPass)
    next true
  }
)

# Lead Balloon
BattleHandlers::ItemOnSwitchIn.copy(:AIRBALLOON,:LEADBALLOON)

# Spell Bell
BattleHandlers::UserItemAfterMoveUse.copy(:SHELLBELL,:SPELLBELL)
BattleHandlers::DamageCalcUserItem.copy(:SPELLTAG,:SPELLBELL)

# Big Red Button
BattleHandlers::TargetItemAfterMoveUse.add(:EJECTBUTTON,
  proc { |item,battler,user,move,switched,battle|
    next if battle.pbAllFainted?(battler.idxOpposingSide)
    next if !battle.pbCanChooseNonActive?(battler.index)
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} pressed its {2}!",battler.pbThis,battler.itemName))
    battler.pbConsumeItem(true,false)
    user.pbOwnSide.incrementEffect(:Spikes)
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next if newPkmn<0
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    switched.push(battler.index)
  }
)

# Smooth Sash
BattleHandlers::WeatherExtenderItem.copy(:SMOOTHROCK,:SMOOTHSASH)

# Death Orb
BattleHandlers::DamageCalcUserItem.add(:DEATHORB,
  proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
    if !move.is_a?(PokeBattle_Confusion)
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::UserItemAfterMoveUse.add(:DEATHORB,
  proc { |item,user,targets,move,numHits,battle|
    next if !user.canHeal?
    totalDamage = 0
    targets.each { |b| totalDamage += b.damageState.totalHPLost }
    next if totalDamage<=0
    healAmount = (totalDamage / 3.0)
    healAmount = 1 if healAmount < 1
    recoverMessage = _INTL("{1} restored HP using its {2}!", user.pbThis,user.itemName)
    user.pbRecoverHP(healAmount,true,true,true,recoverMessage)
  }
)

# Lunch Box
BattleHandlers::EORHealingItem.add(:LUNCHBOX,
  proc { |item,battler,battle|
      next if !battler.canLeftovers?
      healMessage =_INTL("{1} restored HP using its {2}!",battler.pbThis,battler.itemName)
      battler.applyFractionalHealing(1.0/8.0, customMessage: healMessage, item: item)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:LUNCHBOX,
  proc { |item,user,target,move,mults,baseDmg,type,aiChecking|
    mults[:final_damage_multiplier] *= (2.0/3.0) if target.hp == target.totalhp
  }
)

# Grandmaster Scroll
BattleHandlers::ItemOnSwitchIn.add(:GRANDMASTERSCROLL,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} holds the {2}! It deals double effectiveness!",battler.pbThis,battler.itemName))
  }
)