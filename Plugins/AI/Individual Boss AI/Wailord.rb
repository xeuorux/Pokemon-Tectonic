PokeBattle_AI::BossSpeciesRequireMove.add(:XERNEAS,
	proc { |species,move,user,target|
		next true if move.function == "0E0" && user.turnCount == 3
	}
)