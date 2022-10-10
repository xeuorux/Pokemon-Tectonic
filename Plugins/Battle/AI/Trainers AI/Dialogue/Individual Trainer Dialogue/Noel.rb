PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:NOEL,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
		dialogue_array.push("...Hope I've kept you entertained..")
		trainer_speaking.policyStates[:LastPokemonComment] = true
	elsif battler.species == :METAGROSS && !trainer_speaking.policyStates[:ArmigerComment]
		dialogue_array.push("What do you think? A little gaudy? Let me tell you: it's more than a pretty face.")
		trainer_speaking.policyStates[:ArmigerComment] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonConsumesItemDialogue.add(:NOEL,
	proc { |policy,battler,item,trainer_speaking,dialogue_array|
	  if battler.species == :LUNATONE && item == :POWERHERB && !trainer_speaking.policyStates[:LunatoneHerbComment]
		  dialogue_array.push("Sorry. Patience is overrated.")
		  trainer_speaking.policyStates[:LunatoneHerbComment] = true
	  end
	  next dialogue_array
	}
)