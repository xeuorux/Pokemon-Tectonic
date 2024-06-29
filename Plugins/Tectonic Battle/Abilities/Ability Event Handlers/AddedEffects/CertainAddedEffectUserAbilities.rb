BattleHandlers::CertainAddedEffectUserAbility.add(:STARSALIGN,
    proc { |ability, battle, user, target, move|
        next battle.eclipsed?
    }
)