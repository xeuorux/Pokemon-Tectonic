BattleHandlers::DefenseCalcUserItem.add(:STRIKEVEST,
  proc { |item, _user, _battle, defenseMult|
      defenseMult *= 1.5
      next defenseMult
  }
)
