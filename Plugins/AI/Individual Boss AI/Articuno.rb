PokeBattle_AI::BossSpeciesRejectMove.add(:ARTICUNO,
	proc { |species,move,user,target|
		# Never use Sheer Cold on non-chilled targets
		next true if move.function == "070" && !target.frozen?
	}
)

PokeBattle_AI::BossSpeciesRequireMove.add(:ARTICUNO,
	proc { |species,move,user,target|
		# Always use Sheer Cold on chilled targets
		next true if move.function == "070" && target.frozen?
	}
)