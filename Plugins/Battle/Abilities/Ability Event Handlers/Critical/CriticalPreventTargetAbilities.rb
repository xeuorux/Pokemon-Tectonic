BattleHandlers::CriticalPreventTargetAbility.add(:BATTLEARMOR,
  proc { |_ability, _user, _target, _battle|
      next true
  }
)

BattleHandlers::CriticalPreventTargetAbility.copy(:BATTLEARMOR, :SHELLARMOR, :IMPERVIOUS, :STEELYSHELL, :HARSHTRAINING)
