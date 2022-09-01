PokeBattle_AI::BossSpeciesRejectMove.add([:KELDEO,:POISONJAB],
  proc { |speciesAndMove,user,target,move|
	  next user.belched?
  }
)