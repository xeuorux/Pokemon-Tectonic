BattleHandlers::CriticalCalcUserItem.add(:LUCKYPUNCH,
    proc { |_item, user, _target, c|
        next c + 2 if user.isSpecies?(:CHANSEY)
    }
)

BattleHandlers::CriticalCalcUserItem.add(:RAZORCLAW,
  proc { |_item, _user, _target, c|
      next c + 1
  }
)

BattleHandlers::CriticalCalcUserItem.copy(:RAZORCLAW, :SCOPELENS)

BattleHandlers::CriticalCalcUserItem.add(:STICK,
  proc { |_item, user, _target, c|
      next c + 2 if user.isSpecies?(:FARFETCHD)
  }
)
