BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,mults,user,target,move,type|
    mults[:base_accuracy] = 0 if type == :ELECTRIC
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability,mults,user,target,move,type|
    mults[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability,mults,user,target,move,type|
    mults[:base_accuracy] = 0 if type == :WATER
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability,mults,user,target,move,type|
    mults[:accuracy_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability,mults,user,target,move,type|
    if move.statusMove? && user.opposes?(target)
      mults[:base_accuracy] = 50 if mults[:base_accuracy] > 50
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
    proc { |ability,mults,user,target,move,type|
      mults[:accuracy_multiplier] /= 2 if target.confused? || target.charmed?
    }
)