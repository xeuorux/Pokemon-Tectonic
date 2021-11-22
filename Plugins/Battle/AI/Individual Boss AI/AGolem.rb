PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:AGOLEM,:TAKEDOWN],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound < 1
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:AGOLEM,:FLAIL],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound >= 1
  }
)