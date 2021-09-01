# Trick or Treat
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GOURGEIST,"142"],
	proc { |species,move,user,target|
		next user.battle.commandPhasesThisRound == 0
	}
)

# Trick or Treat
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GOURGEIST,"00A"],
	proc { |species,move,user,target|
		next user.battle.commandPhasesThisRound == 0
	}
)