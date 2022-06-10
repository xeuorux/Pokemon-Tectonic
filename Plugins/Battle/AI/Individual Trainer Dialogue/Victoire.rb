PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:VICTOIRE,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:LightningDeathDialogue] && !battler.lastFoeAttacker.nil? &&
			!battler.lastFoeAttacker.lastMoveUsed.nil? && battler.lastFoeAttacker.lastMoveUsed == :THUNDER && battler.battle.pbWeather == :Rain
		dialogue_array.push("Coup de foudre, coup de grace.")
		trainer_speaking.policyStates[:LightningDeathDialogue] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:VICTOIRE,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
		dialogue_array.push("The night seems to be drawing to a close. One last dance?")
		trainer_speaking.policyStates[:LastPokemonComment] = true
	elsif battler.species == :BLASTOISE && !trainer_speaking.policyStates[:BlastoiseComment]
		dialogue_array.push("Were you expecting something else? By now you should know that deception is the foundation of all strategy.")
		trainer_speaking.policyStates[:BlastoiseComment] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonImmuneDialogue.add(:VICTOIRE,
  proc { |policy,attacker,target,isImmunityAbility,trainer_speaking,dialogue_array|
	if target.species == :AGGRON && isImmunityAbility && !trainer_speaking.policyStates[:AggronMotorComment]
		dialogue_array.push("All safeties disengaged – the floor is yours, Aggron.")
		trainer_speaking.policyStates[:AggronMotorComment] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerIsUsingMoveDialogue.add(:VICTOIRE,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if move.id == :DRAGONDANCE && battler.species == :HYMNUS &&
			!trainer_speaking.policyStates[:DragonDanceComment] &&
		dialogue_array.push("This is an archetypal stratagem. Do you have an effective counter planned?")
		trainer_speaking.policyStates[:DragonDanceComment] = true
	end
    next dialogue_array
  }
)