PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_VENGEANT,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Vengeant")
		battle.pbDisplaySlower(_INTL("When enemy Pokemon faint, they deal back to their last attacker damage equal to one quarter of their max HP."))
		curses_array.push(curse_policy)
		next curses_array
	}
)

PokeBattle_Battle::BattlerFaintedCurseEffect.add(:CURSE_VENGEANT,
	proc { |curse_policy,battler,battle|
		next if !battler.opposes?
		next if battler.lastFoeAttacker.length == 0
		battle.pbDisplay(_INTL("#{battler.pbThis} takes its vengeance!"))
		hpLoss = battler.totalhp / 4
		battler.lastFoeAttacker.each do |battler_index|
			affected = battle.battlers[battler_index]
			if affected.takesIndirectDamage?(true)
				battle.scene.pbDamageAnimation(affected)
				affected.pbReduceHP(hpLoss,false)
			end
		end
	}
)