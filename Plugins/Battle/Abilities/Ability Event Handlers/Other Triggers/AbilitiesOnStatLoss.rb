BattleHandlers::AbilityOnStatLoss.add(:COMPETITIVE,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.tryRaiseStat(:SPECIAL_ATTACK,battler,showAbilitySplash: true)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:DEFIANT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.tryRaiseStat(:ATTACK,battler,showAbilitySplash: true)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:BELLIGERENT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseMultipleStatStages([:ATTACK,2,:SPECIAL_ATTACK,2],battler,showAbilitySplash: true)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:IMPERIOUS,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.tryRaiseStat(:SPEED,battler,showAbilitySplash: true)
  }
)