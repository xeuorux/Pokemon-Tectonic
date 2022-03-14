class Pokemon
	attr_accessor :pre_curse_exp
end

PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_DELEVELED,
	proc { |curse_policy,battle,curses_array|
		battle.amuletActivates("Deleveled")
		battle.pbDisplaySlower(_INTL("Your Pokemon start this fight 10 levels lower."))
		
		$Trainer.party.each do |pokemon|
			pokemon.pre_curse_exp = pokemon.exp
			pokemon.level -= 10
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