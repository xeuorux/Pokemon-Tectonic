PokeBattle_AI::BossSpeciesRequireMove.add(:PORYGONZ,
  proc { |species,move,user,target|
    # Conversion and Conversion 2
	next true if ["05E","05F"].include?(move.function) && user.battle.commandPhasesThisRound == 0
  }
)

PokeBattle_AI::BossSpeciesRejectMove.add(:PORYGONZ,
  proc { |species,move,user,target|
    # Conversion and Conversion 2
	next true if ["05E","05F"].include?(move.function) && user.battle.commandPhasesThisRound != 0
  }
)