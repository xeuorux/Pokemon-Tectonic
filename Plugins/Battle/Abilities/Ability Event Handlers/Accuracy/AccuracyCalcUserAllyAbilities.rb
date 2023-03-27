BattleHandlers::AccuracyCalcUserAllyAbility.add(:VICTORYSTAR,
  proc { |ability, mods, _user, _target, _move, _type|
      mods[:accuracy_multiplier] *= 1.1
  }
)

BattleHandlers::AccuracyCalcUserAllyAbility.add(:OCULAR,
    proc { |ability, mods, _user, _target, _move, _type|
        mods[:accuracy_multiplier] *= 1.5
    }
)
