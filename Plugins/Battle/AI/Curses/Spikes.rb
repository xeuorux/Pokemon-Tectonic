PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SPIKES,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Spikes")
		battle.sides[0].effects[PBEffects::Spikes] = 1
		battle.pbDisplay(_INTL("Spikes were scattered all around your Pokemon's feet!"))
		curses_array.push(curse_policy)
		next curses_array
	}
)