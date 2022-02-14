PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TORMENTED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Tormented")
		battle.pbDisplay(_INTL("Your Pokemon gain the \"Tormented\" status when they enter battle.\1"))
		curses_array.push(:CURSE_TORMENTED)
		next curses_array
	}
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_TORMENTED,
	proc { |curse_policy,battler,battle|
		next if battler.opposes?
		battler.effects[PBEffects::Torment] = true
		battle.pbDisplay(_INTL("{1} was subjected to torment!",battler.pbThis))
		battler.pbItemStatusCureCheck
	}
)