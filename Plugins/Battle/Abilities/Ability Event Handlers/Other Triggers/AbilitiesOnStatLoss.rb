BattleHandlers::AbilityOnStatLoss.add(:COMPETITIVE,
  proc { |_ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.tryRaiseStat(:SPECIAL_ATTACK, battler, showAbilitySplash: true, increment: 2)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:DEFIANT,
  proc { |_ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.tryRaiseStat(:ATTACK, battler, showAbilitySplash: true, increment: 2)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:BELLIGERENT,
  proc { |_ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.pbRaiseMultipleStatStages([:ATTACK, 2, :SPECIAL_ATTACK, 2], battler, showAbilitySplash: true)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:IMPERIOUS,
  proc { |_ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.tryRaiseStat(:SPEED, battler, showAbilitySplash: true, increment: 2)
  }
)
