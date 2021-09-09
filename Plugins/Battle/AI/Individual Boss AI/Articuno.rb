PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:ARTICUNO,"070"],
	proc { |speciesAndMoveCode,user,target,move|
		next target.frozen?
	}
)