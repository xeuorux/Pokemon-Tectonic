BattleHandlers::AbilityOnStatLoss.add(:COMPETITIVE,
  proc { |ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.tryRaiseStat(:SPECIAL_ATTACK, battler, ability: ability, increment: 2)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:DEFIANT,
  proc { |ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.tryRaiseStat(:ATTACK, battler, ability: ability, increment: 2)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:BELLIGERENT,
  proc { |ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.pbRaiseMultipleStatStages([:ATTACK, 2, :SPECIAL_ATTACK, 2], battler, ability: ability)
  }
)

BattleHandlers::AbilityOnStatLoss.add(:IMPERIOUS,
  proc { |ability, battler, _stat, user|
      next if user && !user.opposes?(battler)
      battler.tryRaiseStat(:SPEED, battler, ability: ability, increment: 2)
  }
)
