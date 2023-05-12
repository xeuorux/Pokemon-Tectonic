BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
    proc { |ability, battler, _battle|
        battler.tryRaiseStat(:SPEED, battler, ability: ability)
    }
)
