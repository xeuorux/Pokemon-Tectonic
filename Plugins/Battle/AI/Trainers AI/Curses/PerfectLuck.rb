PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERFECT_LUCK,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Just My Luck")
		battle.pbDisplaySlower(_INTL("Enemy moves with a chance to activate an added effect always activate."))
		curses_array.push(curse_policy)
		next curses_array
	}
)