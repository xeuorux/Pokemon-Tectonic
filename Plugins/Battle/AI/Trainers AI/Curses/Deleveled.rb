class Pokemon
	attr_accessor :pre_curse_exp
end

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_DELEVELED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Deleveled")
		battle.pbDisplaySlower(_INTL("Your Pokemon start this fight 10 levels lower. All XP gained goes to the EXP-EZ dispenser."))
		
		battle.expCapped = true
		
		$Trainer.party.each do |pokemon|
			pokemon.pre_curse_exp = pokemon.exp
			pokemon.level = [1,pokemon.level-10].max
			pokemon.calc_stats
		end
		
		battle.eachSameSideBattler(0) do |battler|
			battler.pbUpdate
		end
		
		battle.scene.pbRefresh
		
		curses_array.push(curse_policy)
		next curses_array
	}
)

PokeBattle_Battle::BattleEndCurse.add(:CURSE_DELEVELED,
	proc { |curse_policy,battle|
		$Trainer.party.each do |pokemon|
			pokemon.exp = pokemon.pre_curse_exp
			pokemon.calc_stats
		end
	}
)