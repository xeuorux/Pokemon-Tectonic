PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_EXTRA_TYPES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Portrait of the Opposition in Radiant Ulfire and Stygian Blue"),
            _INTL("Enemy Pokemon all have an extra type.")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)