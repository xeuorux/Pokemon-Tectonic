BattleHandlers::AccuracyCalcUserAbility.add(:COMPOUNDEYES,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] *= 1.3
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:HUSTLE,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] *= 0.8 if move.physicalMove?
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:KEENEYE,
    proc { |ability,mods,user,target,move,type|
      mods[:evasion_stage] = 0 if mods[:evasion_stage] > 0 && Settings::MECHANICS_GENERATION >= 6
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:NOGUARD,
    proc { |ability,mods,user,target,move,type|
      mods[:base_accuracy] = 0
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:UNAWARE,
    proc { |ability,mods,user,target,move,type|
      mods[:evasion_stage] = 0 if move.damagingMove?
    }
  )
  
  BattleHandlers::AccuracyCalcUserAbility.add(:VICTORYSTAR,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] *= 1.1
    }
  )

BattleHandlers::AccuracyCalcUserAbility.add(:SANDSNIPER,
    proc { |ability,mods,user,target,move,type|
        mods[:base_accuracy] = 0 if user.battle.pbWeather == :Sandstorm
    }
)

BattleHandlers::AccuracyCalcUserAbility.add(:AQUASNEAK,
    proc { |ability,mods,user,target,move,type|
        mods[:base_accuracy] = 0 if user.turnCount <= 1
    }
)