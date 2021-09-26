PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:EKO,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] &&
		!trainer_speaking.policyStates[:CommentedOnLastPokemonYet]
		dialogue_array.push("You’re close now! But don’t you dare relax yet!")
		trainer_speaking.policyStates[:CommentedOnLastPokemonYet] = true
	end
    next dialogue_array
  }
)