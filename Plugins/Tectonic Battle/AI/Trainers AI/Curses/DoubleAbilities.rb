PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_DOUBLE_ABILITIES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("Enemy Pokemon have all of their legal abilities!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)