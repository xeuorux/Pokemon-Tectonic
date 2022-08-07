BattleHandlers::CriticalCalcUserAbility.add(:HARSH,
  proc { |ability,user,target,c|
    next 99 if target.burned?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:BITTER,
  proc { |ability,user,target,c|
    next 99 if target.frostbitten?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:STAMPEDE,
  proc { |ability,user,target,c|
    next c+user.stages[:SPEED]
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:WALLNINJA,
  proc { |ability,user,target,c|
    next 99 if user.battle.roomActive?
  }
)