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

BattleHandlers::CriticalCalcUserAbility.add(:AQUASNEAK,
  proc { |ability,user,target,c|
    next 99 if user.turnCount <= 1
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:LURING,
  proc { |ability,user,target,c|
    next 99 if target.mystified?
  }
)