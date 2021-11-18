PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SHAYMIN,:AIRSLASH],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 0
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SHAYMIN,:MAGICALLEAF],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 0
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SHAYMIN,:ANGELSKISS],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 0
  }
)