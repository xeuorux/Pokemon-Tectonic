PokeBattle_AI::BossSpeciesRejectMove.add(:DIALGA,
	proc { |species,move,user,target|
		# Don't do roar of time if not yet enough turns available.
		next true if move.function == "0C2" && $game_variables[95] < 4
	}
)

PokeBattle_AI::BossBeginTurn.add(:DIALGA,
	proc { |species,battler|
		healthRation = battler.hp / battler.totalhp
		if $game_variables[95] == 1 && healthRation < 0.66
			battler.battle.pbDisplay(_INTL("The avatar of Dialga expands time on its side of the field!"))
			$game_variables[95] = 3
		elsif $game_variables[95] == 3 && healthRation < 0.33
			battler.battle.pbDisplay(_INTL("The avatar of Dialga expands time even more! It's stretched to the max!"))
			$game_variables[95] = 4
		end
	}
)