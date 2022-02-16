PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TYPE_WEAKENED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Type Weakened")
		battle.pbDisplay(_INTL("Your Pokemon's Super Effective attacks are instead Not Very Effective .\1"))
		curses_array.push(curse_policy)
		next curses_array
	}
)

PokeBattle_Battle::EffectivenessChangeCurseEffect.add(:CURSE_TYPE_WEAKENED,
	proc { |curse_policy,moveType,defType,user,target,effectiveness|
		if user.pbOwnedByPlayer? && effectiveness == Effectiveness::SUPER_EFFECTIVE_ONE
			next Effectiveness::NOT_VERY_EFFECTIVE_ONE 
		end
	}
)