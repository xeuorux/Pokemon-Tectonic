BattleHandlers::CriticalCalcUserItem.add(:LUCKYPUNCH,
    proc { |item,user,target,c|
      next c+2 if user.isSpecies?(:CHANSEY)
    }
  )
  
  BattleHandlers::CriticalCalcUserItem.add(:RAZORCLAW,
    proc { |item,user,target,c|
      next c+1
    }
  )
  
  BattleHandlers::CriticalCalcUserItem.copy(:RAZORCLAW,:SCOPELENS)
  
  BattleHandlers::CriticalCalcUserItem.add(:STICK,
    proc { |item,user,target,c|
      next c+2 if user.isSpecies?(:FARFETCHD)
    }
  )