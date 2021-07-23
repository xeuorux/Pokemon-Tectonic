#===============================================================================
# TrainerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerChoseMoveDialogue.add(:TEST,
  proc { |policy,battler,move,target,trainername,dialogue_array|
	dialogue_array.push("I chose to use a move!") if $DEBUG
    next dialogue_array
  }
)

#===============================================================================
# PlayerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerChoseMoveDialogue.add(:TEST,
  proc { |policy,battler,move,target,dialogue_array|
	# Push to the dialogue_array based on conditions
	dialogue_array.push("You chose to use a move!") if $DEBUG
    next dialogue_array
  }
)