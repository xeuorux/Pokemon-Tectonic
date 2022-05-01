PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:PARASECT,:SPORE],
	proc { |speciesAndMove,user,target,move|
		# Only use spore if no enemy is asleep
		anyAsleep = false
		user.battle.battlers.each do |b|
			next if !b || !user.opposes?(b)
			anyAsleep = true if b.asleep?
		end
		next !anyAsleep
	}
)