# Self-destruct
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:WAILORD,"0E0"],
	proc { |speciesAndMoveCode,user,target|
		next user.turnCount == 2
	}
)