#===============================================================================
# TrainerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerChoseMoveDialogue.add(:TEST,
  proc { |policy,battler,move,target,trainername,dialogue_array|
	# Push to the dialogue_array based on conditions
    next dialogue_array
  }
)

#===============================================================================
# PlayerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerChoseMoveDialogue.add(:TEST,
  proc { |policy,battler,move,target,dialogue_array|
	# Push to the dialogue_array based on conditions
    next dialogue_array
  }
)

#===============================================================================
# TrainerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:TEST,
  proc { |policy,battler,dialogue_array|
	# Push to the dialogue_array based on conditions
    next dialogue_array
  }
)

#===============================================================================
# PlayerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:TEST,
  proc { |policy,battler,dialogue_array|
	# Push to the dialogue_array based on conditions
    next dialogue_array
  }
)