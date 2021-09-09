PokeBattle_AI::BossSpeciesRequireMove.add(:KYOGRE,
	proc { |speciesAndMoveCode,user,target,move|
		# Always use water spout on the first turn
		next true if move.function == "08B" && @battle.turnCount == 0
		next true if move.id == :ORIGINPULSE && $game_variables[95] == 1
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:KYOGRE,
	proc { |speciesAndMoveCode,user,target,move|
		# Never use water spout past the first turn
		next true if move.function == "08B" && @battle.turnCount != 0
		next true if move.id == :ORIGINPULSE && $game_variables[95] != 1
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:KYOGRE,
	proc { |species,move,user,target|
		if move.function == "08B"
			user.battle.pbDisplay(_INTL("The avatar is clearly preparing a massive opening attack!"))
		elsif move.id == :ORIGINPULSE
			user.battle.pbDisplay(_INTL("The avatar is gathering energy for a massive attack!"))
		end
	}
)

PokeBattle_AI::BossBeginTurn.add(:KYOGRE,
	proc { |species,battler|
		turnCount = battler.battle.turnCount
		if turnCount == 0
			$game_variables[95] = 1
		elsif turnCount % 3 == 0 && @turnCount > 0
			$game_variables[95] = 1
		else
			$game_variables[95] = 3
		end
	}
)