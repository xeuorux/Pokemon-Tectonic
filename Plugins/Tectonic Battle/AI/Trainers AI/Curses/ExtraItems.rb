PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_EXTRA_ITEMS,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("forge a blade\nfrom gold/\npluck out its\nsilhouette and/\nwield the\nshadow too!"),
            _INTL("Enemy Pokemon all have an extra item.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
