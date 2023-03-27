BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability, mults, _user, _target, _move, type|
      mults[:base_accuracy] = 0 if type == :ELECTRIC
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability, mults, _user, _target, _move, _type|
      mults[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability, mults, _user, _target, _move, type|
      mults[:base_accuracy] = 0 if type == :WATER
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability, mults, _user, _target, move, _type|
      mults[:accuracy_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability, mults, user, target, move, _type|
      mults[:base_accuracy] = 50 if move.statusMove? && user.opposes?(target) && (mults[:base_accuracy] > 50)
  }
)