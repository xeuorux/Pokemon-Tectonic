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