PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SUICUNE,:PURIFYINGWATER],
  proc { |speciesAndMove,user,target,move|
	next user.pbHasAnyStatus?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SUICUNE,:WHIRLPOOL],
  proc { |speciesAndMove,user,target,move|
	next user.pbHasAnyStatus?
  }
)