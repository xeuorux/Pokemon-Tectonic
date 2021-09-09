# Metal burst
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:COBALION,"073"],
	proc { |speciesAndMoveCode,user,target,move|
		next (user.lastHPLostFromFoe/user.totalhp.to_f) > 0.1 &&
			user.battle.commandPhasesThisRound == user.battle.numBossOnlyTurns
	}
)