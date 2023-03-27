BattleHandlers::TargetItemAfterMoveUse.add(:EJECTBUTTON,
    proc { |item, battler, _user, _move, switched, battle|
        next if battle.pbAllFainted?(battler.idxOpposingSide)
        next unless battle.pbCanChooseNonActive?(battler.index)
        battle.pbCommonAnimation("UseItem", battler)
        battle.pbDisplay(_INTL("{1} is switched out with the {2}!", battler.pbThis, getItemName(battler.baseItem)))
        battler.pbConsumeItem(item, true, false)
        newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
        next if newPkmn < 0
        battle.pbRecallAndReplace(battler.index, newPkmn)
        battle.pbClearChoice(battler.index) # Replacement Pokémon does nothing this round
        switched.push(battler.index)
    }
)

BattleHandlers::TargetItemAfterMoveUse.add(:REDCARD,
  proc { |item, battler, user, _move, switched, battle|
      next if user.fainted? || switched.include?(user.index)
      newPkmn = battle.pbGetReplacementPokemonIndex(user.index, true) # Random
      next if newPkmn < 0
      battle.pbCommonAnimation("UseItem", battler)
      battle.pbDisplay(_INTL("{1} held up its {2} against {3}!",
         battler.pbThis, getItemName(battler.baseItem), user.pbThis(true)))
      battler.pbConsumeItem(item)
      battle.pbRecallAndReplace(user.index, newPkmn, true)
      battle.pbDisplay(_INTL("{1} was dragged out!", user.pbThis))
      battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      switched.push(user.index)
  }
)
