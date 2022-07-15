# Swagger
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:INCINEROAR,"041"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 0
	}
)

# Taunt
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:INCINEROAR,"0BA"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 0
	}
)