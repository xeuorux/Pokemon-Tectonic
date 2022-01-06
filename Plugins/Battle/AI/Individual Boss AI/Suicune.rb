PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SUICUNE,:PURIFYINGWATER],
  proc { |speciesAndMove,user,target,move|
	next user.pbHasAnyStatus?
  }
)