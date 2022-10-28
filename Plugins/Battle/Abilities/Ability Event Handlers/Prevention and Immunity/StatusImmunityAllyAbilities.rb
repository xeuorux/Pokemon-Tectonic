BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
    proc { |ability,battler,status|
      next true if battler.pbHasType?(:GRASS)
    }
)

BattleHandlers::StatusImmunityAllyAbility.add(:SWEETVEIL,
    proc { |ability,battler,status|
        next true if status == :SLEEP
    }
)