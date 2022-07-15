# Self-destruct
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:WAILORD,"0E0"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.turnCount == 2
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:WAILORD,
	proc { |species,move,user,target|
		if move.function == "0E0"
			user.battle.pbDisplay(_INTL("#{user.pbThis} is flying erratically. It looks unstable!"))
		end
	}
)