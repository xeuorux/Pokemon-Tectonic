BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability,user,target,c|
    next c+2
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:STAMPEDE,
  proc { |ability,user,target,c|
    next c+user.stages[:SPEED]
  }
)