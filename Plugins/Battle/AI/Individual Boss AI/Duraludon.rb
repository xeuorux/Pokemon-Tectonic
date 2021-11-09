# Dragon Roar
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:DURALUDON,"522"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound < 2
	}
)

# Breaking Swipe
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:DURALUDON,"042"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 2
	}
)