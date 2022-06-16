# Eruption
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GROUDON,"08B"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.turnCount == 0
	}
)

# PRECIPICE BLADES
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:GROUDON,:PRECIPICEBLADES],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.numBossOnlyTurns == 0 && user.battle.turnCount > 0
	}
)

#signals precipice blades
PokeBattle_AI::BossDecidedOnMove.add(:GROUDON,
	proc { |species,move,user,target|
		if move.function == "08B"
			user.battle.pbDisplay(_INTL("The avatar is clearly preparing a massive opening attack!"))
		elsif move.id == :PRECIPICEBLADES
			user.battle.pbDisplay(_INTL("The avatar is gathering energy for a big attack!"))
		end
	}
)

#every three turns after the first, change from normal move to precipice
PokeBattle_AI::BossBeginTurn.add(:GROUDON,
	proc { |species,battler|
		turnCount = battler.battle.turnCount
		if turnCount == 0
			battler.battle.numBossOnlyTurns = 0
		elsif turnCount % 3 == 0 && turnCount > 0
			battler.battle.numBossOnlyTurns = 0
		else
			battler.battle.numBossOnlyTurns = 2
		end
	}
)