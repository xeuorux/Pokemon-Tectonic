PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERFECT_LUCK,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Determinism I Defer to Thee, Free Will I Freely Give. Let Thy Die Remain Uncast."),
            _INTL("Enemy attacks always activate their additional effects.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
