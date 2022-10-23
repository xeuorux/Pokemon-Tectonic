BattleHandlers::CriticalCalcTargetAbility.add(:BATTLEARMOR,
    proc { |ability,user,target,c|
      next -1
    }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:SHELLARMOR,:IMPERVIOUS)