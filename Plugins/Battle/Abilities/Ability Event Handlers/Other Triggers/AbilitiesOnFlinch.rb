BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
    proc { |ability,battler,battle|
      battler.tryRaiseStat(:SPEED,battler,showAbilitySplash: true)
    }
)