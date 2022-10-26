BattleHandlers::AccuracyCalcUserAbility.add(:COMPOUNDEYES,
    proc { |ability,mults,user,target,move,type|
      mults[:accuracy_multiplier] *= 1.3
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:HUSTLE,
    proc { |ability,mults,user,target,move,type|
      mults[:accuracy_multiplier] *= 0.8 if move.physicalMove?
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:KEENEYE,
    proc { |ability,mults,user,target,move,type|
      mults[:evasion_stage] = 0 if mults[:evasion_stage] > 0
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:NOGUARD,
    proc { |ability,mults,user,target,move,type|
      mults[:base_accuracy] = 0
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:UNAWARE,
    proc { |ability,mults,user,target,move,type|
      mults[:evasion_stage] = 0 if move.damagingMove?
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:VICTORYSTAR,
    proc { |ability,mults,user,target,move,type|
      mults[:accuracy_multiplier] *= 1.1
    }
  )

BattleHandlers::AccuracyCalcUserAbility.add(:SANDSNIPER,
    proc { |ability,mults,user,target,move,type|
        mults[:base_accuracy] = 0 if user.battle.pbWeather == :Sandstorm
    }
)

BattleHandlers::AccuracyCalcUserAbility.add(:AQUASNEAK,
    proc { |ability,mults,user,target,move,type|
        mults[:base_accuracy] = 0 if user.turnCount <= 1
    }
)