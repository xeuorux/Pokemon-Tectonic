BattleHandlers::ItemOnStatLoss.add(:EJECTPACK,
  proc { |item,battler,user,move,switched,battle|
    next if battle.pbAllFainted?(battler.idxOpposingSide)
    next if !battle.pbCanChooseNonActive?(battler.index)
	next if move.function=="0EE" # U-Turn, Volt-Switch, Flip Turn
	next if move.function=="151" # Parting Shot
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} is switched out with the {2}!",battler.pbThis,battler.itemName))
    battler.pbConsumeItem(true,false)
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next if newPkmn<0
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    switched.push(battler.index)
  }
)

BattleHandlers::UserItemAfterMoveUse.add(:THROATSPRAY,
  proc { |item, user, targets, move, numHits, battle|
    next if battle.pbAllFainted?(user.idxOwnSide) ||
            battle.pbAllFainted?(user.idxOpposingSide)
    next if !move.soundMove? || numHits == 0
    next if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    battle.pbCommonAnimation("UseItem",user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user)
    user.pbConsumeItem
  }
)

BattleHandlers::EOREffectItem.add(:POISONORB,
  proc { |item,battler,battle|
    next if !battler.pbCanPoison?(nil,false)
    battler.pbPoison(nil,_INTL("{1} was poisoned by the {2}!",
       battler.pbThis,battler.itemName),false)
  }
)

BattleHandlers::DamageCalcTargetItem.add(:STRIKEVEST,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[:defense_multiplier] *= 1.5 if move.physicalMove?
  }
)

BattleHandlers::SpeedCalcItem.add(:SEVENLEAGUEBOOTS,
  proc { |item,battler,mult|
    next mult*1.1
  }
)

BattleHandlers::TargetItemOnHit.add(:BUSTEDRADIO,
  proc { |item,user,target,move,battle|
    next if move.pbContactMove?(user)
    next if !user.takesIndirectDamage?
	  reduction = user.totalhp/6
	  reduction /= 4 if user.boss
	  user.damageState.displayedDamage = reduction
    battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(reduction,false)
    battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,target.itemName))
  }
)