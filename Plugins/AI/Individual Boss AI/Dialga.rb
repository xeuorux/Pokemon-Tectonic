PokeBattle_AI::BossSpeciesRejectMove.add(:DIALGA,
	proc { |species,move,user,target|
		# Don't do roar of time if not yet enough turns available.
		next true if move.function == "0C2" && $game_variables[95] < 4
	}
)