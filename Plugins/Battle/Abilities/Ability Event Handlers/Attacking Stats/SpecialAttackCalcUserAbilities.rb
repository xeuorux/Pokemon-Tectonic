  BattleHandlers::SpecialAttackCalcUserAbility.add(:FLAREBOOST,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 1.5 if user.burned?
      next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.add(:MINUS,
    proc { |ability,user,battle,spAtkMult|
      user.eachAlly do |b|
        next if !b.hasActiveAbility?([:MINUS, :PLUS])
        spAtkMult *= 1.5
        break
      end
      next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.copy(:MINUS,:PLUS)

  BattleHandlers::SpecialAttackCalcUserAbility.add(:SOLARPOWER,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 1.5 if battle.sunny?
      next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.add(:AUDACITY,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 1.33 if user.pbHasAnyStatus?
      next spAtkMult
    }
  )
  
  BattleHandlers::SpecialAttackCalcUserAbility.add(:HEADACHE,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 2.0 if user.dizzy?
      next spAtkMult
    }
  )
  
  BattleHandlers::SpecialAttackCalcUserAbility.add(:ENERGYUP,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 1.5
      next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.add(:ARCANEFINALE,
    proc { |ability,user,battle,spAtkMult|
        spAtkMult *= 2 if user.isLastAlive?
        next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.add(:TIDALFORCE,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 1.3 if battle.rainy?
      next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.add(:SOLARCELL,
    proc { |ability,user,battle,spAtkMult|
      spAtkMult *= 1.25 if battle.sunny?
      next spAtkMult
    }
  )
  
  BattleHandlers::SpecialAttackCalcUserAbility.add(:RADIATE,
    proc { |ability,user,battle,spAtkMult|
        spAtkMult *= 1.3
        next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserAbility.copy(:RADIATE,:ARCANE)