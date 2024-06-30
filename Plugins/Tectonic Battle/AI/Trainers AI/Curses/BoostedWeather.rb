# Boosted Sun
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_SUN,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with sunshine. The effects of sunshine are doubled.")
        )

        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sunshine)
        next curses_array
    }
)

# Boosted Rain
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_RAIN,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with rainstorm. The effects of rainstorm are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Rainstorm)
        next curses_array
    }
)

# BOOSTED HAIL
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_HAIL,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with hail. The effects of hail are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Hail)
        next curses_array
    }
)

# BOOSTED SAND
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_SAND,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Sky Scoured of Star and Sun"),
            _INTL("The battle begins with sandstorm. The effects of sandstorm are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sandstorm)
        next curses_array
    }
)
