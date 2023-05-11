BattleHandlers::RunFromBattleAbility.add(:RUNAWAY,
    proc { |ability, _battler|
        next true
    }
)
