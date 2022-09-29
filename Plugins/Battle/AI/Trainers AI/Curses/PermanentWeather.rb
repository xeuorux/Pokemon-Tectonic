# PERMANENT SUN

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERMANENT_SUN,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Permanent Sun")
		battle.pbDisplaySlower(_INTL("The weather is set to Harsh Sun at the beginning of every turn."))
		curses_array.push(curse_policy)
		battle.pbStartWeather(nil,:Sun)
		next curses_array
	}
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_PERMANENT_RAIN,
	proc { |curse_policy,battle|
		battle.pbStartWeather(nil,:Sun)
	}
)

# PERMANENT RAIN
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERMANENT_RAIN,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Permanent Rain")
		battle.pbDisplaySlower(_INTL("The weather is set to Rain at the beginning of every turn."))
		curses_array.push(curse_policy)
		battle.pbStartWeather(nil,:Rain)
		next curses_array
	}
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_PERMANENT_RAIN,
	proc { |curse_policy,battle|
		battle.pbStartWeather(nil,:Rain)
	}
)

# PERMANENT HAIL
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERMANENT_HAIL,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Permanent Hail")
		battle.pbDisplaySlower(_INTL("The weather is set to Hail at the beginning of every turn."))
		curses_array.push(curse_policy)
		battle.pbStartWeather(nil,:Hail)
		next curses_array
	}
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_PERMANENT_HAIL,
	proc { |curse_policy,battle|
		battle.pbStartWeather(nil,:Hail)
	}
)

# PERMANENT SAND
PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERMANENT_SAND,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Permanent Sand")
		battle.pbDisplaySlower(_INTL("The weather is set to Sand at the beginning of every turn."))
		curses_array.push(curse_policy)
		battle.pbStartWeather(nil,:Sand)
		next curses_array
	}
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_PERMANENT_SAND,
	proc { |curse_policy,battle|
		battle.pbStartWeather(nil,:Sand)
	}
)

