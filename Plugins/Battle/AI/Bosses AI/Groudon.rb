# Eruption
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GROUDON,"08B"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.turnCount == 0
	}
)

# PRECIPICE BLADES
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:GROUDON,:PRECIPICEBLADES],
	proc { |speciesAndMoveCode,user,target,move|
		turnCount = user.battle.turnCount
		next turnCount > 0 && turnCount % 3 == 0
	}
)

#signals precipice blades
PokeBattle_AI::BossDecidedOnMove.add(:GROUDON,
	proc { |species,move,user,targets|
		if move.function == "08B"
			user.battle.pbDisplayBossNarration(_INTL("The avatar is clearly preparing a massive opening attack!"))
			user.extraMovesPerTurn = 0
		elsif move.id == :PRECIPICEBLADES
			user.battle.pbDisplayBossNarration(_INTL("The avatar is gathering energy for a big attack!"))
			user.extraMovesPerTurn = 0
		end
	}
)