PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERISH_SONGED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Extreme Perish Song")
		battle.pbDisplay(_INTL("Your Pokemon gain the \"Extreme Perish Song\" status when they enter battle.\1"))
		curses_array.push(curse_policy)
		next curses_array
	}
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_PERISH_SONGED,
	proc { |curse_policy,battler,battle|
		next if battler.opposes?
		battler.effects[PBEffects::PerishSong]     = 2
    	battler.effects[PBEffects::PerishSongUser] = battler.index
		battle.pbDisplay(_INTL("{1} heard the Extreme Perish Song! It will faint in two turns!",battler.pbThis))
	}
)