PokeBattle_AI::BossSpeciesRequireMove.add(:MAGNEZONE,
	proc { |species,move,user,target|
		# Always use zap cannon on the first move of a turn against a locked-on target
		next true if move.id == :ZAPCANNON && user.battle.commandPhasesThisRound == 0 && 
						user.effects[PBEffects::LockOnPos] == target.index
		
		# Always use locked on for the last move of the turn
		next true if move.function == "0A6" && user.battle.commandPhasesThisRound == $game_variables[95] - 1
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:MAGNEZONE,
	proc { |species,move,user,target|
		# Never use zap cannon except on the first move of a turn against a locked-on target
		if move.id == :ZAPCANNON
			next true if user.battle.commandPhasesThisRound != 0
			next true if user.effects[PBEffects::LockOnPos] != target.index
		end
		
		# Never use lock on except for the last move of the turn
		next true if move.function == "0A6" && user.battle.commandPhasesThisRound != $game_variables[95] - 1
	}
)