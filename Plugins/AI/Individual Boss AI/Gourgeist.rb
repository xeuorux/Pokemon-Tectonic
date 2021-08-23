PokeBattle_AI::BossSpeciesRequireMove.add(:GOURGEIST,
	proc { |species,move,user,target|
		# If the first attack of a turn, always do either Trick or Treat or Will O Wisp
		next true if (move.function == "142" || move.function == "00A") && user.battle.commandPhasesThisRound == 0
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:GOURGEIST,
	proc { |species,move,user,target|
		# If not the first attack of a turn, never do either Trick or Treat or Will O Wisp
		next true if (move.function == "142" || move.function == "00A") && user.battle.commandPhasesThisRound != 0
	}
)