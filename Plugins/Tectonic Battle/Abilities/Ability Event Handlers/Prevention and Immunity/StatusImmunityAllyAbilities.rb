BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
    proc { |ability, battler, _status|
        next true if battler.pbHasType?(:GRASS)
    }
)

BattleHandlers::StatusImmunityAllyAbility.add(:SWEETVEIL,
    proc { |ability, _battler, status|
        next true if status == :SLEEP
    }
)
