PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_NO_MERCY,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("No Mercy")
		battle.pbDisplaySlower(_INTL("Bence and Zoé are using 5 battlers each. This is a big battle!"))
		curses_array.push(curse_policy)
		next curses_array
	}
)