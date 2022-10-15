# Will O Wisp
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:NINETALES,"00A"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 0
	}
)