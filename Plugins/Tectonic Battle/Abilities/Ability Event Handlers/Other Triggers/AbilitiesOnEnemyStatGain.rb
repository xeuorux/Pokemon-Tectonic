BattleHandlers::AbilityOnEnemyStatGain.add(:PETTY,
    proc { |ability, battler, stat, increment, user, battle, benefactor|
        battler.tryRaiseStat(stat, battler, increment: increment, ability: ability)
    }
)