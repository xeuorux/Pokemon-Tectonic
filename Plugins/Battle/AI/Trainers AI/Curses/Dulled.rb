PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_DULLED,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("Your Pokemon don't get extra damage on their same-type attacks.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
