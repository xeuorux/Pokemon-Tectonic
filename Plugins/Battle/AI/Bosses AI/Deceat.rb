PokeBattle_AI::BossSpeciesRequireMove.add(:DECEAT,
  proc { |species,move,user,target|
	  next move.id == :FLING
  }
)
