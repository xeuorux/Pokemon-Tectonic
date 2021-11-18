PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ENTEI,:INCINERATE],
  proc { |speciesAndMove,user,target,move|
	next target.item && (target.item.is_berry? || target.item.is_gem?)
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ENTEI,:SUNNYDAY],
  proc { |speciesAndMove,user,target,move|
	next user.battle.field.weather != :Sun && user.hp <= user.hptotal / 2
  }
)