PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:YEZERA4,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerDeathComment]
		dialogue_array.push("...I'm sorry. Stay down. Please...")
		trainer_speaking.policyStates[:PlayerDeathComment] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:YEZERA4,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.species == :TOGEKISS && !trainer_speaking.policyStates[:TogekissDeathComment]
		dialogue_array.push("You’ve done enough, Artemisia. Thank you.")
		trainer_speaking.policyStates[:TogekissDeathComment] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:YEZERA4,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
		dialogue_array.push("...It’s been so long since...")
		trainer_speaking.policyStates[:LastPokemonComment] = true
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