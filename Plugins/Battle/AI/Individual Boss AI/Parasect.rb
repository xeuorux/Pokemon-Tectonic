PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:PARASECT,:SPORE],
	proc { |speciesAndMoveCode,user,target,move|
		# Only use spore if no enemy is asleep
		user.battle.battlers.each do |b|
			next if !b || !user.opposes?(b)
			next false if b.asleep?
		end
		next true
	}
)