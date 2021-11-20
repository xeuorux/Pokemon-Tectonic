PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:JIRACHI,:DOOMDESIRE],
  proc { |speciesAndMove,user,target,move|
	next user.battle.turnCount % 2 == 0
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:JIRACHI,:LIFEDEW],
  proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 1 && user.battle.turnCount % 2 == 1 && user.hp < user.totalhp/2
  }
)