PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:RAIKOU,:LIGHTNINGSHRIEK],
  proc { |speciesAndMove,user,target,move|
	next user.stages[:SPEED]<1
  }
)
