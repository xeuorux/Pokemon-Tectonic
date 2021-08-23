PokeBattle_AI::BossSpeciesRequireMove.add(:KYOGRE,
	proc { |species,move,user,target|
		# Always use water spout on the first turn
		next true if move.function == "08B" && @battle.turnCount == 0
		next true if move.id == :ORIGINPULSE && $game_variables[95] == 1
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:KYOGRE,
	proc { |species,move,user,target|
		# Never use water spout past the first turn
		next true if move.function == "08B" && @battle.turnCount != 0
		next true if move.id == :ORIGINPULSE && $game_variables[95] != 1
	}
)