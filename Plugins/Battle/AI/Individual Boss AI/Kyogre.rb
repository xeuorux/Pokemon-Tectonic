#use water spout on turn one
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:KYOGRE,"08B"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.turnCount == 0
	}
)

#Use origin pulse every 3 turns after Water Spout
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:KYOGRE,:ORIGINPULSE],
	proc { |speciesAndMoveCode,user,target,move|
		next user.battle.numBossOnlyTurns == 0 && user.battle.turnCount > 0
	}
)

#signals origin pulse
PokeBattle_AI::BossDecidedOnMove.add(:KYOGRE,
	proc { |species,move,user,target|
		if move.function == "08B"
			user.battle.pbDisplay(_INTL("The avatar is clearly preparing a massive opening attack!"))
		elsif move.id == :ORIGINPULSE
			user.battle.pbDisplay(_INTL("The avatar is gathering energy for a massive attack!"))
		end
	}
)

#every three turns after the first, change from normal move to origin pulse
PokeBattle_AI::BossBeginTurn.add(:KYOGRE,
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