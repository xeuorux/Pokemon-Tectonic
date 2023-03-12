BattleHandlers::ItemOnStatLoss.add(:EJECTPACK,
  proc { |_item, battler, _user, move, switched, battle|
      next if battle.pbAllFainted?(battler.idxOpposingSide)
      next unless battle.pbCanChooseNonActive?(battler.index)
      next if move&.switchOutMove?
      battle.pbCommonAnimation("UseItem", battler)
      battle.pbDisplay(_INTL("{1} is switched out with the {2}!", battler.pbThis, battler.itemName))
      battler.pbConsumeItem(true, false)
      newPkmn = battle.pbGetReplacementPokemonIndex(battler.index) # Owner chooses
      next if newPkmn < 0
      battle.pbRecallAndReplace(battler.index, newPkmn)
      battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
      switched.push(battler.index)
  }
)
