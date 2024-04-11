BattleHandlers::CertainAddedEffectUserAbility.add(:STARSALIGN,
    proc { |ability, battle, user, target, move|
        next battle.eclipsed?
    }
)

BattleHandlers::CertainAddedEffectUserAbility.add(:WISHMAKER,
    proc { |ability, battle, user, target, move|
        next true
    }
)