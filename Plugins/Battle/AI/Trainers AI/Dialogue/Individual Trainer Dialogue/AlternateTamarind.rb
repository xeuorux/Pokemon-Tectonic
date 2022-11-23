PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:ALTERNATE_TAMARIND,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.species == :MEWTWO && !trainer_speaking.policyStates[:MewtwoComment]
		dialogue_array.push("You know the plan. My dear friend, dismantle them.")
		dialogue_array.push("Show them why you’re the god of this place!")
		trainer_speaking.policyStates[:MewtwoComment] = true
	end
    next dialogue_array
  }
)