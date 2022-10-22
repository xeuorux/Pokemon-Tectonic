BattleHandlers::AbilityOnStatLoss.add(:BELLIGERENT,
    proc { |ability,battler,stat,user|
      next if user && !user.opposes?(battler)
      battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,battler)
        battler.pbRaiseStatStageByAbility(:ATTACK,2,battler)
    }
  )
  
  BattleHandlers::AbilityOnStatLoss.add(:IMPERIOUS,
    proc { |ability,battler,stat,user|
      next if user && !user.opposes?(battler)
      battler.pbRaiseStatStageByAbility(:SPEED,2,battler)
    }
  )