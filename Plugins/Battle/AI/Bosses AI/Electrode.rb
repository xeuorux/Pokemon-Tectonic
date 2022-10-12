ELECTRODE_TURNS_TO_EXPLODE = 3

# Self-destruct/Explosion
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:ELECTRODE,"0E0"],
	proc { |speciesAndMoveCode,user,target,move|
		next user.turnCount == ELECTRODE_TURNS_TO_EXPLODE
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:ELECTRODE,
	proc { |species,move,user,targets|
		if move.function == "0E0"
			user.battle.pbDisplay(_INTL("#{user.pbThis} is fully charged. Its about to explode!"))
		end
	}
)

PokeBattle_AI::BossBeginTurn.add(:ELECTRODE,
	proc { |species,battler|
		turnsRemaining = ELECTRODE_TURNS_TO_EXPLODE - battler.turnCount
		if turnsRemaining > 0
			battler.battle.pbDisplay(_INTL("#{battler.pbThis} is charging up."))
			battler.battle.pbDisplay(_INTL("#{turnsRemaining} turns remain!"))
		end
	}
)