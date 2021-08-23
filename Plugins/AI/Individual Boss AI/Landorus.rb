PokeBattle_AI::BossSpeciesRequireMove.add(:LANDORUS,
	proc { |species,move,user,target|
		# Always gravity if you can
		next true if move.function == "200"
	}
)