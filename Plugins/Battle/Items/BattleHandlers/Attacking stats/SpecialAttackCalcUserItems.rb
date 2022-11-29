BattleHandlers::SpecialAttackCalcUserItem.add(:MUSCLEBAND,
    proc { |item,user,battle,spAtkMult|
        attackMult *= 1.1
        next attackMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserItem.add(:DEEPSEATOOTH,
    proc { |item,user,battle,spAtkMult|
        spAtkMult *= 2 if user.isSpecies?(:CLAMPERL)
        next spAtkMult
    }
  )

  BattleHandlers::SpecialAttackCalcUserItem.add(:WISEGLASSES,
    proc { |item,user,battle,spAtkMult|
        spAtkMult *= 1.1
        next spAtkMult
    }
  )
  
  BattleHandlers::SpecialAttackCalcUserItem.add(:CHOICESPECS,
    proc { |item,user,battle,spAtkMult|
        spAtkMult *= 1.33
        next spAtkMult
    }
  )