PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SHAYMIN,:AIRSLASH],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 1
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:SHAYMIN,:ANGELSKISS],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 0
  }
)