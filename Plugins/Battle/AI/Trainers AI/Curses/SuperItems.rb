PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SUPER_ITEMS,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Super Items")
		battle.pbDisplaySlower(_INTL("Each member of the enemy team is holding a super-powerful item. Stolen items turn to dust."))
		curses_array.push(curse_policy)
		next curses_array
	}
)