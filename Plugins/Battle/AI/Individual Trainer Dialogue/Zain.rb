PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:ZAIN,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	starters = [:APPLIN,:FLAPPLE,:APPLETUN,:NUMEL,:CAMERUPT,:DROMERUPT,:KRABBY,:KINGLER,:KLAWSAR]
	if starters.include?(battler.species) && !trainer_speaking.policyStates[:StarterDeathDialogue]
		dialogue_array.push("I guess the power of friendship only goes so far.")
		trainer_speaking.policyStates[:StarterDeathDialogue] = true
	elsif !trainer_speaking.policyStates[:NonStarterDeathDialogue]
		dialogue_array.push("Wow, that is really cathartic.")
		trainer_speaking.policyStates[:NonStarterDeathDialogue] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::PlayerSendsOutPokemonDialogue.add(:ZAIN,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if $Trainer.able_pokemon_count == 1 && !trainer_speaking.policyStates[:LastPokemonDialogue]
		dialogue_array.push("Is that all? I must’ve lost count. I thought we were just getting started.")
		trainer_speaking.policyStates[:LastPokemonDialogue] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:ZAIN,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonDialogue]
		dialogue_array.push("You’ve got a really punchable face, you know that? Smug to the end.")
		trainer_speaking.policyStates[:LastPokemonDialogue] = true
	end
    next dialogue_array
  }
)