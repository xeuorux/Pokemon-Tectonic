PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_SUBSTITUTED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Substituted")
		battle.pbDisplaySlower(_INTL("Whenever an enemy Pokemon enters the battlefield, if it's at full health, it forms a substitute."))
		curses_array.push(curse_policy)
		next curses_array
	}
)

PokeBattle_Battle::BattlerEnterCurseEffect.add(:CURSE_SUBSTITUTED,
	proc { |curse_policy,battler,battle|
		next unless battler.opposes?
		next unless battler.hp>=battler.totalhp
		subLife = battler.totalhp/4
		subLife = 1 if subLife<1
		battler.pbReduceHP(subLife,false,false)
		battler.pbHealthLossChecks()
		battler.effects[PBEffects::Trapping]     = 0
		battler.effects[PBEffects::TrappingMove] = nil
		battler.effects[PBEffects::Substitute]   = subLife
		battle.pbDisplaySlower(_INTL("{1} put in a substitute!",battler.pbThis))
	}
)