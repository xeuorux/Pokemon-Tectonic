# Choice Crown
BattleHandlers::DamageCalcUserItem.add(:CHOICECROWN,
    proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
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
  proc { |item, user, _battle, attackMult|
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
    proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
      mults[:defense_multiplier] *= 1.5
    }
)

# Assault Corset
BattleHandlers::SpecialDefenseCalcUserItem.copy(:ASSAULTVEST,:ASSAULTCORSET)
BattleHandlers::TargetItemOnHit.copy(:ROCKYHELMET,:ASSAULTCORSET)

# Strike Corset
BattleHandlers::DefenseCalcUserItem.copy(:STRIKEVEST,:STRIKECORSET)
BattleHandlers::TargetItemOnHit.copy(:HIVISJACKET,:STRIKECORSET)

# Jagged Helmet
BattleHandlers::TargetItemOnHit.add(:JAGGEDHELMET,
    proc { |item,user,target,move,battle,aiCheck,aiNumHits|
        next unless move.physicalMove?
        next if !user.takesIndirectDamage?
        next -20 * aiNumHits if aiCheck
        battle.pbDisplay(_INTL("{1} was badly hurt by the {2}!",user.pbThis,getItemName(item)))
        user.applyFractionalDamage(1.0/3.0)
    }
)
  
BattleHandlers::TargetItemOnHit.add(:LUSTROUSJACKET,
    proc { |item,user,target,move,battle,aiCheck,aiNumHits|
        next unless move.specialMove?
        next if !user.takesIndirectDamage?
        next -20 * aiNumHits if aiCheck
        battle.pbDisplay(_INTL("{1} was badly hurt by the {2}!",user.pbThis,getItemName(item)))
        user.applyFractionalDamage(1.0/3.0)
    }
)

# Sitreon berry
BattleHandlers::HPHealItem.add(:SITREONBERRY,
    proc { |item,battler,battle,forced,filchedFrom,filchingAbility|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      battle.pbCommonAnimation("Nom",battler) if !forced
      healFromBerry(battler,1.0/2.0,item,forced,filchedFrom,filchingAbility)
      next true
    }
)

# Roseli Feast
BattleHandlers::EORHealingItem.copy(:LEFTOVERS,:ROSELIFEAST)

BattleHandlers::DamageCalcTargetItem.add(:ROSELIFEAST,
    proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
      pbBattleTypeWeakingBerry(item, :FAIRY,type,target,mults,true,aiCheck)
    }
)

# Occa Feast
BattleHandlers::EORHealingItem.copy(:LEFTOVERS,:OCCAFEAST)

BattleHandlers::DamageCalcTargetItem.add(:OCCAFEAST,
    proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
      pbBattleTypeWeakingBerry(item, :FIRE,type,target,mults,true,aiCheck)
    }
)

# Rindo Feast
BattleHandlers::EORHealingItem.copy(:LEFTOVERS,:RINDOFEAST)

BattleHandlers::DamageCalcTargetItem.add(:RINDOFEAST,
    proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
      pbBattleTypeWeakingBerry(item, :GRASS,type,target,mults,true,aiCheck)
    }
)

# Lunus berry
BattleHandlers::StatusCureItem.add(:LUNUSBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if !battler.hasAnyStatusNoTrigger
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("Nom",battler) if !forced
      battler.pbCureStatus
      battler.pbRaiseMultipleStatSteps([:ATTACK,2,:DEFENSE,2,:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,2], battler, item: item)
      next true
    }
)

# Zalaka Berry
BattleHandlers::HPHealItem.add(:ZALAKABERRY,
    proc { |item,battler,battle,forced,filchedFrom,filchingAbility|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPEED,99,false,filchedFrom, filchingAbility)
    }
)

# Lucent Gem
BattleHandlers::DamageCalcUserItem.add(:LUCENTGEM,
    proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
        user.applyEffect(:GemConsumed,item) unless aiCheck
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
end

# White Bough
BattleHandlers::EndOfMoveStatRestoreItem.add(:WHITEBOUGH,
  proc { |item,battler,battle,forced|
    reducedStats = false
    GameData::Stat.each_battle do |s|
      next if battler.steps[s.id] >= 0
      battler.steps[s.id] = 0
      reducedStats = true
    end
    next false if !reducedStats
    itemName = GameData::Item.get(item).name
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
BattleHandlers::TargetItemAfterMoveUse.add(:BIGREDBUTTON,
  proc { |item,battler,user,move,switched,battle|
    next if battle.pbAllFainted?(battler.idxOpposingSide)
    next if !battle.pbCanChooseNonActive?(battler.index)
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} pressed its {2}!",battler.pbThis,getItemName(item)))
    battler.consumeItem(item)
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
  proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
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
    recoverMessage = _INTL("{1} restored HP using its {2}!", user.pbThis,getItemName(item))
    user.pbRecoverHP(healAmount,true,true,true,recoverMessage)
  }
)

# Lunch Box
BattleHandlers::EORHealingItem.add(:LUNCHBOX,
  proc { |item,battler,battle|
      next if !battler.canLeftovers?
      healMessage =_INTL("{1} restored HP using its {2}!",battler.pbThis,getItemName(item))
      battler.applyFractionalHealing(1.0/8.0, customMessage: healMessage, item: item)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:LUNCHBOX,
  proc { |item,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:final_damage_multiplier] *= (2.0/3.0) if target.hp == target.totalhp
  }
)

# Grandmaster Scroll
BattleHandlers::ItemOnSwitchIn.add(:GRANDMASTERSCROLL,
  proc { |item,battler,battle|
    battle.pbDisplay(_INTL("{1} holds the {2}! It deals double effectiveness!",battler.pbThis,getItemName(item)))
  }
)