BattleHandlers::GuaranteedCriticalUserAbility.add(:MERCILESS,
    proc { |_ability, _user, target, _battle|
        next true if target.poisoned?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:HARSH,
    proc { |_ability, _user, target, _battle|
        next true if target.burned?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:BITTER,
    proc { |_ability, _user, target, _battle|
        next true if target.frostbitten?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:WALLNINJA,
    proc { |_ability, user, _target, _battle|
        next true if user.battle.roomActive?
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:AQUASNEAK,
    proc { |_ability, user, _target, _battle|
        next true if user.turnCount <= 1
    }
)

BattleHandlers::GuaranteedCriticalUserAbility.add(:LURING,
    proc { |_ability, _user, target, _battle|
        next true if target.dizzy?
    }
)
