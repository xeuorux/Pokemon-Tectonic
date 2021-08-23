PokeBattle_AI::BossSpeciesRequireMove.add(:COBALION,
	proc { |species,move,user,target|
		next true if move.function == "073" && shouldUseMetalBurst(user,target)
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:COBALION,
	proc { |species,move,user,target|
		next true if move.function == "073" && !shouldUseMetalBurst(user,target)
	}
)

def shouldUseMetalBurst(user,target)
	return false if (user.lastHPLostFromFoe/user.totalhp) < 0.1
	return false if user.battle.commandPhasesThisRound != ($game_variables[95] - 1)
	return true
end