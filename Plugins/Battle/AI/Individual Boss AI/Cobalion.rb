# Metal burst
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:COBALION,"073"],
	proc { |species,move,user,target|
		next (user.lastHPLostFromFoe/user.totalhp.to_f) > 0.1 &&
			user.battle.commandPhasesThisRound == user.battle.numBossOnlyTurns
	}
)