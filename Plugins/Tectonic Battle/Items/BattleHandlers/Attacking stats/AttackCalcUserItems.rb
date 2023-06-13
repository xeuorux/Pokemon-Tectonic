BattleHandlers::AttackCalcUserItem.add(:MUSCLEBAND,
    proc { |item, _user, _battle, attackMult|
        attackMult *= 1.1
        next attackMult
    }
)

BattleHandlers::AttackCalcUserItem.add(:CHOICEBAND,
  proc { |item, _user, _battle, attackMult|
      attackMult *= 1.4
      next attackMult
  }
)

BattleHandlers::AttackCalcUserItem.add(:THICKCLUB,
  proc { |item, user, _battle, attackMult|
      attackMult *= 1.5 if user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK)
      next attackMult
  }
)
