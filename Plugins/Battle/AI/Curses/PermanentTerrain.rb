# PERMANENT ELECTRIC

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_PERMANENT_ELECTRIC,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Permanent Electric Terrain")
		battle.pbDisplaySlower(_INTL("The terrain is set to Electric Terrain at the beginning of every turn."))
		curses_array.push(curse_policy)
		battle.pbStartTerrain(nil, :Electric)
		next curses_array
	}
)

PokeBattle_Battle::BeginningOfTurnCurseEffect.add(:CURSE_PERMANENT_ELECTRIC,
	proc { |curse_policy,battle|
		if battle.field.terrain != :Electric
			battle.pbStartTerrain(nil, :Electric)
		end
	}
)