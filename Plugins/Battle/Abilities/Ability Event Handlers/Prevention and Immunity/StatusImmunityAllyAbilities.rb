BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
    proc { |_ability, battler, _status|
        next true if battler.pbHasType?(:GRASS)
    }
)

BattleHandlers::StatusImmunityAllyAbility.add(:SWEETVEIL,
    proc { |_ability, _battler, status|
        next true if status == :SLEEP
    }
)
