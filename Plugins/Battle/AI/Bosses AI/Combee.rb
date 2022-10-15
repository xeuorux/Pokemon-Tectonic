PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:COMBEE,:HELPINGHAND],
	proc { |speciesAndMoveID,user,target,move|
		next user.firstMoveThisTurn?
	}
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:COMBEE,:SMUSH],
	proc { |speciesAndMoveID,user,target,move|
		next user.lastMoveThisTurn?
	}
)