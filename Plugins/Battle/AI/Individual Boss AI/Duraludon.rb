# Dragon Roar
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:DURALUDON,"522"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound < 2
	}
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:DURALUDON,:TWISTER],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 2
	}
)