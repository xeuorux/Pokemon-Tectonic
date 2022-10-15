# Trick or Treat
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GOURGEIST,"142"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.lastMoveThisTurn?
	}
)