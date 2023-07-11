BattleHandlers::CriticalCalcUserItem.add(:RAZORCLAW,
  proc { |item, _user, _target, c|
      next c + 1
  }
)

BattleHandlers::CriticalCalcUserItem.copy(:RAZORCLAW, :SCOPELENS)