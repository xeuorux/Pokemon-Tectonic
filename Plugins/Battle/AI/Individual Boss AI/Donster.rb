PokeBattle_AI::BossSpeciesRejectMove.add([:DONSTER,:MIASMA],
  proc { |speciesAndMove,user,target,move|
	  next user.belched?
  }
)