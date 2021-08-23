PokeBattle_AI::BossSpeciesRequireMove.add(:GROUDON,
	proc { |species,move,user,target|
		# Always use eruption on the first turn
		next true if move.function == "08B" && @battle.turnCount == 0
		next true if move.id == :PRECIPICEBLADES && $game_variables[95] == 1
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:GROUDON,
	proc { |species,move,user,target|
		# Never use eruption past the first turn
		next true if move.function == "08B" && @battle.turnCount != 0
		next true if move.id == :PRECIPICEBLADES && $game_variables[95] != 1
	}
)