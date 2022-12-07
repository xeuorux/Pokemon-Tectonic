BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability,user,target,move,c|
    next c+2
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:STAMPEDE,
  proc { |ability,user,target,move,c|
    next c+user.stages[:SPEED]
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:RAZORSEDGE,
  proc { |ability,user,target,move,c|
    next c+1 if move.slashMove?
  }
)