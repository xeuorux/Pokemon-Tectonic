# Metal burst
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:COBALION,"073"],
	proc { |species,move,user,target|
		next false if (user.lastHPLostFromFoe/user.totalhp) < 0.1
		next false if user.battle.commandPhasesThisRound != ($game_variables[95] - 1)
		next true
	}
)