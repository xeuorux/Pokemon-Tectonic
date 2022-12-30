BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
    proc { |_ability, battler, _battle|
        battler.tryRaiseStat(:SPEED, battler, showAbilitySplash: true)
    }
)
