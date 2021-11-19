PokeBattle_AI::BossSpeciesUseMoveIdIfAndOnlyIf.add([:SUICUNE,:PURIFYINGWATER],
  proc { |speciesAndMove,user,target,move|
	next user.pbHasAnyStatus?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIdIfAndOnlyIf.add([:SUICUNE,:WHIRLPOOL],
  proc { |speciesAndMove,user,target,move|
	next user.pbHasAnyStatus?
  }
)