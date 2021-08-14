#===============================================================================
# TrainerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerChoseMoveDialogue.add(:DEBUG,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerChoseMoveDEBUG]
		dialogue_array.push("I chose a move!")
		trainer_speaking.policyStates[:TrainerChoseMoveDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerChoseMoveDialogue.add(:DEBUG,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:PlayerChoseMoveDEBUG]
		dialogue_array.push("You chose a move!")
		trainer_speaking.policyStates[:PlayerChoseMoveDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# TrainerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:TrainerPokemonFaintedDEBUG]
		dialogue_array.push("My Pokemon fainted!")
		trainer_speaking.policyStates[:TrainerPokemonFaintedDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:PlayerPokemonFaintedDEBUG]
		dialogue_array.push("Your Pokemon fainted!")
		trainer_speaking.policyStates[:PlayerPokemonFaintedDEBUG] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:PERFECTINGTUTORIAL,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:FaintTutorialGiven]
		dialogue_array.push("Heh, you aren't so tough!")
		trainer_speaking.policyStates[:FaintTutorialGiven] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# TrainerSendsOutPokemonDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerSendsOutPokemonDEBUG]
		dialogue_array.push("I sent out a Pokemon!")
		trainer_speaking.policyStates[:TrainerSendsOutPokemonDEBUG] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:LAMBERT,
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
PokeBattle_AI::PlayerSendsOutPokemonDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerSendsOutPokemonDEBUG]
		dialogue_array.push("You sent out a Pokemon!")
		trainer_speaking.policyStates[:PlayerSendsOutPokemonDEBUG] = true
	end
    next dialogue_array
  }
)


#===============================================================================
# TrainerPokemonTookMoveDamageDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerPokemonTookMoveDamageDialogue.add(:DEBUG,
  proc { |policy,dealer,taker,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerPokemonTookMoveDamageDEBUG]
		dialogue_array.push("My Pokemon took move damage!")
		trainer_speaking.policyStates[:TrainerPokemonTookMoveDamageDEBUG] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonTookMoveDamageDialogue.add(:LAMBERT,
  proc { |policy,dealer,taker,trainer_speaking,dialogue_array|
	next dialogue_array if trainer_speaking.policyStates[:IllusionTrick]
	next dialogue_array if taker.species !=:ZORUA
	if taker.damageState.typeMod < Effectiveness::NORMAL_EFFECTIVE	
		dialogue_array.push("Hah. Oldest trick in the book.")
	elsif taker.damageState.typeMod > Effectiveness::NORMAL_EFFECTIVE
		dialogue_array.push("Saw through my trick, did ya?")
	end
	trainer_speaking.policyStates[:IllusionTrick] = true
    next dialogue_array
  }
)

#===============================================================================
# PlayerPokemonTookMoveDamageDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerPokemonTookMoveDamageDialogue.add(:DEBUG,
  proc { |policy,dealer,taker,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerPokemonTookMoveDamageDEBUG]
		dialogue_array.push("Your Pokemon took move damage!")
		trainer_speaking.policyStates[:PlayerPokemonTookMoveDamageDEBUG] = true
	end
    next dialogue_array
  }
)