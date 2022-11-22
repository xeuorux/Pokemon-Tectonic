BattleHandlers::AttackCalcUserAbility.add(:FLOWERGIFT,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.5 if user.battle.sunny?
        next attackMult
    }
  )

BattleHandlers::AttackCalcUserAbility.add(:SLOWSTART,
    proc { |ability,user,battle,attackMult|
        attackMult /= 2 if user.effectActive?(:SlowStart)
        next attackMult
    }
)

BattleHandlers::AttackCalcUserAbility.add(:PRIMEVALSLOWSTART,
  proc { |ability,user,battle,attackMult|
      attackMult /= 2
      next attackMult
  }
)

BattleHandlers::AttackCalcUserAbility.add(:GORILLATACTICS,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.5
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:GUTS,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.33 if user.pbHasAnyStatus?
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:TOUGHCLAWS,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.3
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:TOXICBOOST,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.5 if user.poisoned?
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:HUGEPOWER,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.5
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.copy(:HUGEPOWER,:PUREPOWER)

  BattleHandlers::AttackCalcUserAbility.add(:FLUSTERFLOCK,
    proc { |ability,user,battle,attackMult|
        attackMult *= 2.0 if user.dizzy?
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:POWERUP,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.5
        next attackMult
    }
  )

  BattleHandlers::AttackCalcUserAbility.add(:DEEPSTING,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.5
        next attackMult
    }
  )

  BattleHandlers::AttackCalcUserAbility.add(:BIGTHORNS,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.3 if battle.field.terrain == :Grassy
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:SUNCHASER,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.3 if battle.sunny?
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:BLIZZBOXER,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.3 if battle.pbWeather == :Hail
        next attackMult
    }
  )

  BattleHandlers::AttackCalcUserAbility.add(:STRANGESTRENGTH,
    proc { |ability,user,battle,attackMult|
        attackMult *= 2.0 if battle.field.terrain == :Misty
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:HARSHHUNTER,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.3 if battle.pbWeather == :Sandstorm
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:RAMMINGSPEED,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.3 if user.pbOwnSide.effectActive?(:Tailwind)
        next attackMult
    }
  )
  
  BattleHandlers::AttackCalcUserAbility.add(:ROBUST,
    proc { |ability,user,battle,attackMult|
        attackMult *= 1.2
        next attackMult
    }
  )