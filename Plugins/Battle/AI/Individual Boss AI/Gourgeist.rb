# Trick or Treat
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GOURGEIST,"142"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 0
	}
)

# Trick or Treat
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GOURGEIST,"00A"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.commandPhasesThisRound == 0
	}
)