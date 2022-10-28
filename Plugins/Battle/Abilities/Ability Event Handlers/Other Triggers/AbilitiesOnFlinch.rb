BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
    proc { |ability,battler,battle|
      battler.pbRaiseStatStageByAbility(:SPEED,1,battler)
    }
)