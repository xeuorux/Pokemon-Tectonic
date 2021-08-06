#===============================================================================
# TrainerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerChoseMoveDialogue.add(:Debug,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerChoseMoveDebug]
		dialogue_array.push("I chose a move!")
		trainer_speaking.policyStates[:TrainerChoseMoveDebug] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerChoseMoveDialogue.add(:Debug,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:PlayerChoseMoveDebug]
		dialogue_array.push("You chose a move!")
		trainer_speaking.policyStates[:PlayerChoseMoveDebug] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# TrainerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:Debug,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:TrainerPokemonFaintedDebug]
		dialogue_array.push("My Pokemon fainted!")
		trainer_speaking.policyStates[:TrainerPokemonFaintedDebug] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:Debug,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:PlayerPokemonFaintedDebug]
		dialogue_array.push("Your Pokemon fainted!")
		trainer_speaking.policyStates[:PlayerPokemonFaintedDebug] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# TrainerSendsOutPokemonDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:Debug,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerSendsOutPokemonDebug]
		dialogue_array.push("I sent out a Pokemon!")
		trainer_speaking.policyStates[:TrainerSendsOutPokemonDebug] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:Lambert,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:CommentedOnLastPokemonYet]
		dialogue_array.push("Got me on the ropes, huh? Well it ain’t over till it’s over.")
		trainer_speaking.policyStates[:CommentedOnLastPokemonYet] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerSendsOutPokemonDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerSendsOutPokemonDialogue.add(:Debug,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerSendsOutPokemonDebug]
		dialogue_array.push("You sent out a Pokemon!")
		trainer_speaking.policyStates[:PlayerSendsOutPokemonDebug] = true
	end
    next dialogue_array
  }
)