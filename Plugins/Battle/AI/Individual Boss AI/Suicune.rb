PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SUICUNE,:PURIFYINGWATER],
  proc { |speciesAndMove,user,target,move|
	next user.pbHasAnyStatus?
  }
)

PokeBattle_AI::BossDecidedOnMove.add(:SUICUNE,
	proc { |species,move,user,targets|
		if move.id == :PURIFYINGWATER
			user.battle.pbDisplay(_INTL("#{user.pbThis} inspects it's status conditions."))
		end
	}
)