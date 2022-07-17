#use water spout on turn one
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:KYOGRE,"08B"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.turnCount == 0
	}
)

#Use origin pulse every 3 turns after Water Spout
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:KYOGRE,:ORIGINPULSE],
	proc { |speciesAndMoveCode,user,target,move|
		turnCount = battler.battle.turnCount
		next turnCount > 0 && turnCount % 3 == 0
	}
)

#signals origin pulse
PokeBattle_AI::BossDecidedOnMove.add(:KYOGRE,
	proc { |species,move,user,targets|
		if move.function == "08B"
			user.battle.pbDisplay(_INTL("The avatar is clearly preparing a massive opening attack!"))
			user.extraMovesPerTurn = 0
		elsif move.id == :ORIGINPULSE
			user.battle.pbDisplay(_INTL("The avatar is gathering energy for a massive attack!"))
			user.extraMovesPerTurn = 0
		end
	}
)