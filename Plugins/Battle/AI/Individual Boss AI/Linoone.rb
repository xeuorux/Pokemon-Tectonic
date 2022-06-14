# Covet
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:LINOONE,:COVET],
  proc { |speciesAndMove,user,target,move|
	  next user.item.nil? && !target.item.nil?
  }
)