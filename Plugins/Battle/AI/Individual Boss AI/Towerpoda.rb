# Loom Over
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:TOWERPODA,"522"],
	proc { |speciesAndMoveCode,user,target,move|
		next !user.lastMoveThisTurn?
	}
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:TOWERPODA,:TWISTER],
	proc { |speciesAndMoveCode,user,target,move|
		next user.lastMoveThisTurn?
	}
)