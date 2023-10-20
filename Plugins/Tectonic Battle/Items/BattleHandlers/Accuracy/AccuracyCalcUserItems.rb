BattleHandlers::AccuracyCalcUserItem.add(:WIDELENS,
  proc { |item, mults, _user, _target, _move, _type, aiCheck|
      mults[:accuracy_multiplier] *= 1.35
  }
)

BattleHandlers::AccuracyCalcUserItem.add(:SKILLHERB,
  proc { |item, mults, user, _target, _move, _type, aiCheck|
      next unless mults[:base_accuracy] < 100
      mults[:base_accuracy] = 0 # Can't miss
      user.applyEffect(:SkillHerbConsumed) unless aiCheck
  }
)