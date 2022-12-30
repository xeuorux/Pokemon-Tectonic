BattleHandlers::RunFromBattleAbility.add(:RUNAWAY,
    proc { |_ability, _battler|
        next true
    }
)
