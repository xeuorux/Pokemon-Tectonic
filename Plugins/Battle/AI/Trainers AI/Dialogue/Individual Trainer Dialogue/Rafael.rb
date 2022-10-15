PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:RAFAEL,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
		dialogue_array.push("...I've seen me win these. Yeah, I've seen me win these...")
		trainer_speaking.policyStates[:LastPokemonComment] = true
	end
    next dialogue_array
  }
)