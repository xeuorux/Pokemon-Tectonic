BattleHandlers::DefenseCalcUserItem.add(:STRIKEVEST,
  proc { |item,user,battle,defenseMult|
      defenseMult *= 1.5
      next defenseMult
  }
)