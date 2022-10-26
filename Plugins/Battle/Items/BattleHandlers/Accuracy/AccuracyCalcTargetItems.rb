BattleHandlers::AccuracyCalcTargetItem.add(:BRIGHTPOWDER,
    proc { |item,mults,user,target,move,type|
      mults[:accuracy_multiplier] *= 0.9
    }
  )
  
  BattleHandlers::AccuracyCalcTargetItem.copy(:BRIGHTPOWDER,:LAXINCENSE)