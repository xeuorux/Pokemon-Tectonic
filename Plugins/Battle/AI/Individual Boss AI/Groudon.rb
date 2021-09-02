# Eruption
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GROUDON,"08B"],
	proc { |species,move,user,target|
		next @battle.turnCount == 0
	}
)

# PRECIPICE BLADES
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:GROUDON,:PRECIPICEBLADES],
	proc { |species,move,user,target|
		next battler.battle.numBossOnlyTurns == 0 && @battle.turnCount >= 0
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:GROUDON,
	proc { |species,move,user,target|
		if move.function == "08B"
			user.battle.pbDisplay(_INTL("The avatar is clearly preparing a massive opening attack!"))
		elsif move.id == :PRECIPICEBLADES
			user.battle.pbDisplay(_INTL("The avatar is gathering energy for a big attack!"))
		end
	}
)

PokeBattle_AI::BossBeginTurn.add(:GROUDON,
	proc { |species,battler|
		turnCount = battler.battle.turnCount
		if turnCount == 0
			battler.battle.numBossOnlyTurns = 1
		elsif turnCount % 3 == 0 && @turnCount > 0
			battler.battle.numBossOnlyTurns = 1
		else
			battler.battle.numBossOnlyTurns = 3
		end
	}
)