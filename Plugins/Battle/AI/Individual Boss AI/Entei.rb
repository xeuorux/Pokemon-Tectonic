PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ENTEI,:INCINERATE],
  proc { |speciesAndMove,user,target,move|
	next target.item && (target.item.is_berry? || target.item.is_gem?)
  }
)