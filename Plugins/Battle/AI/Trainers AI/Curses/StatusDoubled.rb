PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_STATUS_DOUBLED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Pyres raised\nHere we meet\nSpirits razed\nReduced to meat"),
            _INTL("Status conditions affect your Pokemon twice as much!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
