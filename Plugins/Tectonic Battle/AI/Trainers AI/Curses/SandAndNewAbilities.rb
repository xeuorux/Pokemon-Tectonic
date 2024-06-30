PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SAND_ABILITIES,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("A Sky Scoured of Star and Sun"),
            _INTL("The battle begins with sandstorm. The foe has extra sandstorm abilities!")
        )
        curses_array.push(curse_policy)
        battle.pbStartWeather(nil, :Sandstorm)
        next curses_array
    }
)
