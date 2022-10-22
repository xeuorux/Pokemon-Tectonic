PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SPIKES,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Spikes")
		spikesCount = battle.sides[0].incrementEffect(:Spikes,GameData::BattleEffect(:Spikes).maximum)
		battle.pbDisplaySlower(_INTL("#{spikesCount} layers of Spikes were scattered all around your Pokemon's feet!"))
		curses_array.push(curse_policy)
		next curses_array
	}
)