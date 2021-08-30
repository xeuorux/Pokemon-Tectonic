# Self-destruct
PokeBattle_AI::BossSpeciesRequireMove.add(:WAILORD,
	proc { |species,move,user,target|
		next true if move.function == "0E0" && user.turnCount == 2
	}
)

# Self-destruct
PokeBattle_AI::BossSpeciesRejectMove.add(:WAILORD,
	proc { |species,move,user,target|
		next true if move.function == "0E0" && user.turnCount != 2
	}
)