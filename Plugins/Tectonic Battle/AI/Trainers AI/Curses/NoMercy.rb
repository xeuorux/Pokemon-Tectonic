PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_NO_MERCY,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("In Our Equality, Disparity; from Injustice Settled Scales"),
            _INTL("Bence and Zoé are using 5 battlers each. This is a big battle!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_NO_MERCY_2,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Fool's Errand"),
            _INTL("Yezera and Shadow Mavis are using 6 battlers each. This is a huge battle!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_NO_MERCY_3,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Singular Hypocrisy, Repeated Sixfold"),
            _INTL("Despite making you use 4, Nora is using 6 battlers!")
        )
        curses_array.push(curse_policy)
        next curses_array
    }
)
