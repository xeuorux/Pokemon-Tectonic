BattleHandlers::AccuracyCalcTargetItem.add(:BRIGHTPOWDER,
    proc { |item,mods,user,target,move,type|
      mods[:accuracy_multiplier] *= 0.9
    }
  )
  
  BattleHandlers::AccuracyCalcTargetItem.copy(:BRIGHTPOWDER,:LAXINCENSE)