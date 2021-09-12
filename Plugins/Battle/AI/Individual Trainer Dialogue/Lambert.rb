PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:LAMBERT,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:CommentedOnLastPokemonYet]
		dialogue_array.push("Got me on the ropes, huh? Well it ain’t over till it’s over.")
		trainer_speaking.policyStates[:CommentedOnLastPokemonYet] = true
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