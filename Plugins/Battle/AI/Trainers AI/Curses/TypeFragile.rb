PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TYPE_FRAGILE,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("Neutral attacks against your Pokemon are instead Super Effective.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::EffectivenessChangeCurseEffect.add(:CURSE_TYPE_FRAGILE,
    proc { |_curse_policy, _moveType, user, target, effectiveness|
        if !user.pbOwnedByPlayer? && target.pbOwnedByPlayer? &&
                Effectiveness.normal?(effectiveness)
            next effectiveness * 2
        end
    }
)
