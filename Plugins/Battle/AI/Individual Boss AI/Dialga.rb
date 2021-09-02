PokeBattle_AI::BossSpeciesRejectMove.add(:DIALGA,
	proc { |species,move,user,target|
		# Don't do roar of time if not yet enough turns available.
		next true if move.function == "0C2" && battler.battle.numBossOnlyTurns < 3
	}
)

PokeBattle_AI::BossBeginTurn.add(:DIALGA,
	proc { |species,battler|
		healthRation = battler.hp / battler.totalhp
		if battler.battle.numBossOnlyTurns == 0 && healthRation < 0.66
			battler.battle.pbDisplay(_INTL("The avatar of Dialga expands time on its side of the field!"))
			battler.battle.numBossOnlyTurns = 2
		elsif battler.battle.numBossOnlyTurns == 2 && healthRation < 0.33
			battler.battle.pbDisplay(_INTL("The avatar of Dialga expands time even more! It's stretched to the max!"))
			battler.battle.numBossOnlyTurns = 3
		end
	}
)