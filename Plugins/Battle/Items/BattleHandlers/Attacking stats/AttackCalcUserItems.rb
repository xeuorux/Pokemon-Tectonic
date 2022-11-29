BattleHandlers::AttackCalcUserItem.add(:MUSCLEBAND,
    proc { |item,user,battle,attackMult|
        attackMult *= 1.1
        next attackMult
    }
  )

BattleHandlers::AttackCalcUserItem.add(:CHOICEBAND,
  proc { |item,user,battle,attackMult|
        attackMult *= 1.33
        next attackMult
    }
  )

  BattleHandlers::AttackCalcUserItem.add(:THICKCLUB,
    proc { |item,user,battle,attackMult|
        attackMult *= 1.5 if (user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK))
        next attackMult
    }
  )