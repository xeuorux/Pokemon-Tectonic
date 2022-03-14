PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_TYPE_WEAKENED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Type Weakened")
		battle.pbDisplaySlower(_INTL("Your Pokemon's Super Effective attacks are instead Not Very Effective."))
		curses_array.push(curse_policy)
		next curses_array
	}
)

PokeBattle_Battle::EffectivenessChangeCurseEffect.add(:CURSE_TYPE_WEAKENED,
	proc { |curse_policy,moveType,user,target,effectiveness|
		if user.pbOwnedByPlayer? &&
				!target.pbOwnedByPlayer? &&
				Effectiveness::super_effective?(effectiveness)
			next Effectiveness::NORMAL_EFFECTIVE / 2 
		end
	}
)