BattleHandlers::AnyoneAbilityEndOfMove.add(:FIESTA,
    proc { |ability, battler, user, targets, move, battle|
        next unless move.soundMove? || move.danceMove?
        battler.applyFractionalHealing(1.0 / 8.0, ability: :FIESTA)
    }
)

BattleHandlers::AnyoneAbilityEndOfMove.add(:ANCESTRALDANCE,
    proc { |ability, battler, user, targets, move, battle|
        next unless move.danceMove?
        battler.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, ability: :ANCESTRALDANCE)
    }
)

BattleHandlers::AnyoneAbilityEndOfMove.add(:CHOREOGRAPHY,
    proc { |ability, battler, user, targets, move, battle|
        next unless move.danceMove?
        battler.pbRaiseMultipleStatSteps([:SPEED, 1], user, ability: :CHOREOGRAPHY)
    }
)

BattleHandlers::AnyoneAbilityEndOfMove.add(:GROOVY,
    proc { |ability, battler, user, targets, move, battle|
        next unless move.danceMove?
        battler.pbRaiseMultipleStatSteps([:ATTACK, 1], user, ability: :GROOVY)
    }
)