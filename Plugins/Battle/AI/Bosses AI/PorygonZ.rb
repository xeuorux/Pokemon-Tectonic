# Conversion
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:PORYGONZ,"05E"],
	 proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 0
  }
)

# Conversion 2
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:PORYGONZ,"05F"],
	 proc { |speciesAndMove,user,target,move|
	next user.battle.commandPhasesThisRound == 0
  }
)