PokeBattle_AI::BossSpeciesRequireMove.add(:INCINEROAR,
	proc { |species,move,user,target|
		# If the first attack of a turn, always do either Swagger or Taunt
		next true if (move.function == "041" || move.function != "0BA") && user.battle.commandPhasesThisRound == 0
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:INCINEROAR,
	proc { |species,move,user,target|
		# If not the first attack of a turn, never do either Swagger or Taunt
		next true if (move.function == "041" || move.function != "0BA") && user.battle.commandPhasesThisRound != 0
	}
)