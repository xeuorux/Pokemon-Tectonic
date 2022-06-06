PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:YEZERA4,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerDeathDialogue]
		dialogue_array.push("...I'm sorry. Stay down. Please...")
		trainer_speaking.policyStates[:PlayerDeathDialogue] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:YEZERA4,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.species == :TOGEKISS && !trainer_speaking.policyStates[:TrainerDeathDialogue]
		dialogue_array.push("You’ve done enough, Artemisia. Thank you.")
		trainer_speaking.policyStates[:TrainerDeathDialogue] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:YEZERA4,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonDialogue]
		dialogue_array.push("...It’s been so long since...")
		trainer_speaking.policyStates[:LastPokemonDialogue] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::BattleSurvivedDialogue.add(:YEZERA4,
  proc { |policy,trainer_speaking,dialogue_array|
  	dialogue_array.push("...We’re done here. We wanted time, we got it. No need to continue this.")
    next dialogue_array
  }
)