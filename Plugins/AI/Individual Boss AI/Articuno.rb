PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:ARTICUNO,"070"],
	proc { |speciesAndMoveCode,user,target|
		next target.frozen?
	}
)