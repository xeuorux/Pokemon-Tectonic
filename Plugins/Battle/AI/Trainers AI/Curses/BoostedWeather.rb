# Boosted Sun
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_SUN,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with Sunshine. The effects of Sunshine are doubled.")
        )

        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sun)
        next curses_array
    }
)

# Boosted Rain
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_RAIN,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with Rain. The effects of Rain are doubled.")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Rain)
        next curses_array
    }
)

# BOOSTED HAIL
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_BOOSTED_HAIL,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("TODO"),
            _INTL("The battle begins with Hail. The effects of Hail are doubled.")
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
            _INTL(The battle begins with Sandstorm. The effects of Sandstorm are doubled."")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sandstorm)
        next curses_array
    }
)
