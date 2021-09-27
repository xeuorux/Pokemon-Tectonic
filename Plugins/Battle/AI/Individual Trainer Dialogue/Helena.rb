PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:HELENA,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] &&
		!trainer_speaking.policyStates[:CommentedOnLastPokemonYet]
		dialogue_array.push("Don’t give me that look. I’ve won worse.")
		trainer_speaking.policyStates[:CommentedOnLastPokemonYet] = true
	end
    next dialogue_array
  }
)