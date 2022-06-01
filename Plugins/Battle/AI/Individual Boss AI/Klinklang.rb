PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:KLINGKLANG,:CHARGE],
  proc { |speciesAndMove,user,target,move|
	next user.battle.turnCount % 2 == 0 && user.battle.commandPhasesThisRound == 1
  }
)