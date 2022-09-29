PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:XERNEAS,"14E"],
	proc { |speciesAndMoveCode,user,target|
		next user.turnCount == 0 && user.lastMoveThisTurn?
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:XERNEAS,
	proc { |species,move,user,targets|
		if move.function == "14E"
			user.battle.pbDisplay(_INTL("{1} senses the powerful defensive auras of your Pokemon!",user.pbThis))
		end
	}
)