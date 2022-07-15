PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:JIRACHI,:DOOMDESIRE],
  proc { |speciesAndMove,user,target,move|
	next user.battle.turnCount % 3 == 0 && user.lastMoveThisTurn?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:JIRACHI,:LIFEDEW],
  proc { |speciesAndMove,user,target,move|
	  next user.battle.commandPhasesThisRound == 1 && user.battle.turnCount % 3 == 1 && user.hp < user.totalhp/2
  }
)

PokeBattle_AI::BossDecidedOnMove.add(:JIRACHI,
	proc { |species,move,user,target|
		if move.id == :LIFEDEW
			user.battle.pbDisplay(_INTL("#{user.pbThis} takes a passive stance, inspecting its wounds."))
		end
	}
)