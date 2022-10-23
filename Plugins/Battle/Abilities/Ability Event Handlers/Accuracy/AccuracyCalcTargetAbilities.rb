BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if type == :ELECTRIC
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if type == :WATER
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability,mods,user,target,move,type|
    if move.statusMove? && user.opposes?(target)
      mods[:base_accuracy] = 50 if mods[:base_accuracy] > 50
    end
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
    proc { |ability,mods,user,target,move,type|
      mods[:accuracy_multiplier] /= 2 if target.confused? || target.charmed?
    }
)