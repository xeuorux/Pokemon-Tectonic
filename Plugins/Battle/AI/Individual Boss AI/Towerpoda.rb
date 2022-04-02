# Dragon Roar
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:TOWERPODA,"522"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound < 1
	}
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:TOWERPODA,:TWISTER],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 1
	}
)