BattleHandlers::DefenseCalcUserItem.add(:STRIKEVEST,
  proc { |_item, _user, _battle, defenseMult|
      defenseMult *= 1.5
      next defenseMult
  }
)
