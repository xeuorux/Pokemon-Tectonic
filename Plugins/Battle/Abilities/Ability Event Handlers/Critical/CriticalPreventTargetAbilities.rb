BattleHandlers::CriticalPreventTargetAbility.add(:BATTLEARMOR,
  proc { |ability,user,target,battle|
    next true
  }
)


BattleHandlers::CriticalPreventTargetAbility.copy(:BATTLEARMOR,:SHELLARMOR,:IMPERVIOUS,:STEELYSHELL)