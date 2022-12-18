#===============================================================================
# TrainerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerChoseMoveDialogue.add(:DEBUG,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerChoseMoveDEBUG]
		dialogue_array.push("I chose a move!")
		trainer_speaking.policyStates[:TrainerChoseMoveDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerChoseMoveDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerChoseMoveDialogue.add(:DEBUG,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:PlayerChoseMoveDEBUG]
		dialogue_array.push("You chose a move!")
		trainer_speaking.policyStates[:PlayerChoseMoveDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# TrainerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:TrainerPokemonFaintedDEBUG]
		dialogue_array.push("My Pokemon fainted!")
		trainer_speaking.policyStates[:TrainerPokemonFaintedDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerPokemonFaintedDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if !trainer_speaking.policyStates[:PlayerPokemonFaintedDEBUG]
		dialogue_array.push("Your Pokemon fainted!")
		trainer_speaking.policyStates[:PlayerPokemonFaintedDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# TrainerSendsOutPokemonDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerSendsOutPokemonDEBUG]
		dialogue_array.push("I sent out a Pokemon!")
		trainer_speaking.policyStates[:TrainerSendsOutPokemonDEBUG] = true
	end
    next dialogue_array
  }
)

#===============================================================================
# PlayerSendsOutPokemonDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerSendsOutPokemonDialogue.add(:DEBUG,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerSendsOutPokemonDEBUG]
		dialogue_array.push("You sent out a Pokemon!")
		trainer_speaking.policyStates[:PlayerSendsOutPokemonDEBUG] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::PlayerSendsOutPokemonDialogue.add(:REMARKONSTARTER,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	next dialogue_array unless [:APPLIN,:NUMEL,:KRABBY].include?(battler.species)
	if !trainer_speaking.policyStates[:RemarkedOnStarter]
		dialogue_array.push("Wow, I've never seen that Pokemon before!")
		dialogue_array.push("I'm gonna check my MasterDex!")
		case battler.species
		when :APPLIN
			dialogue_array.push("Applin, it says. A Grass-type, AND a Dragon-type? Crazy!")
		when :NUMEL	
			dialogue_array.push("Numel, huh? Fire-type--hope I don't get burned!")
		when :KRABBY
			dialogue_array.push("Krabby... a Water-type... with massive attack power, wow!")
		end
		trainer_speaking.policyStates[:RemarkedOnStarter] = true
	end
    next dialogue_array
  }
)


#===============================================================================
# TrainerPokemonTookMoveDamageDialogue handlers
#===============================================================================
PokeBattle_AI::TrainerPokemonTookMoveDamageDialogue.add(:DEBUG,
  proc { |policy,dealer,taker,move,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:TrainerPokemonTookMoveDamageDEBUG]
		dialogue_array.push("My Pokemon took move damage!")
		trainer_speaking.policyStates[:TrainerPokemonTookMoveDamageDEBUG] = true
	end
    next dialogue_array
  }
)


#===============================================================================
# PlayerPokemonTookMoveDamageDialogue handlers
#===============================================================================
PokeBattle_AI::PlayerPokemonTookMoveDamageDialogue.add(:DEBUG,
  proc { |policy,dealer,taker,move,trainer_speaking,dialogue_array|
	if !trainer_speaking.policyStates[:PlayerPokemonTookMoveDamageDEBUG]
		dialogue_array.push("Your Pokemon took move damage!")
		trainer_speaking.policyStates[:PlayerPokemonTookMoveDamageDEBUG] = true
	end
    next dialogue_array
  }
)