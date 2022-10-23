BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
    proc { |item,battler,mult|
      next mult * 1.33
    }
  )

  BattleHandlers::SpeedCalcItem.add(:MACHOBRACE,
    proc { |item,battler,mult|
      next mult/2
    }
  )
  
  BattleHandlers::SpeedCalcItem.copy(:MACHOBRACE,:POWERANKLET,:POWERBAND,
                                                 :POWERBELT,:POWERBRACER,
                                                 :POWERLENS,:POWERWEIGHT)
  
  BattleHandlers::SpeedCalcItem.add(:QUICKPOWDER,
    proc { |item,battler,mult|
      next mult*2 if battler.isSpecies?(:DITTO) &&
                     !battler.effects[PBEffects::Transform]
    }
  )
  
  BattleHandlers::SpeedCalcItem.add(:IRONBALL,
    proc { |item,battler,mult|
      next mult/2
    }
  )

  BattleHandlers::SpeedCalcItem.add(:SEVENLEAGUEBOOTS,
    proc { |item,battler,mult|
      next mult*1.1
    }
  )