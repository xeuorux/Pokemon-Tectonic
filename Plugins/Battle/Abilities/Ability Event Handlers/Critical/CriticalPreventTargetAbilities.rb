BattleHandlers::CriticalPreventTargetAbility.add(:BATTLEARMOR,
  proc { |ability, _user, _target, _battle|
      next true
  }
)

BattleHandlers::CriticalPreventTargetAbility.copy(:BATTLEARMOR, :SHELLARMOR, :IMPERVIOUS, :STEELYSHELL, :LIVINGARMOR, :HARSHTRAINING)