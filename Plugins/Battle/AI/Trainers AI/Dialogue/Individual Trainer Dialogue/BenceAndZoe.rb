PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:BENCE,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if battler.battle.pbAbleCount(battler.index) == 1 && !trainer_speaking.policyStates[:LastPokemon] && battler.battle.singleBattle?
		dialogue_array.push("Whoa. Hadn't realized it, but I'm running dry.")
		trainer_speaking.policyStates[:LastPokemon] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:ZOE,
  proc { |policy,battler,trainer_speaking,dialogue_array|
    if battler.battle.pbAbleCount(battler.index) == 1 && !trainer_speaking.policyStates[:LastPokemon] && battler.battle.singleBattle?
        dialogue_array.push("Gonna try to go out with a bang, but I know how this one ends.")
        trainer_speaking.policyStates[:LastPokemon] = true
    end
    next dialogue_array
  }
)

PokeBattle_AI::PlayerPokemonTookMoveDamageDialogue.add(:BENCE,
  proc { |policy,dealer,taker,trainer_speaking,dialogue_array|
    next dialogue_array unless dealer.species == :DREDNAW && dealer.lastMoveUsed == :JAWLOCK
    if !trainer_speaking.policyStates[:DrednawJawLock]
      dialogue_array.push("They don't call it the Bite Pokémon for nothing! You're stuck here with ME now!")
      trainer_speaking.policyStates[:DrednawJawLock] = true
    end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerIsUsingMoveDialogue.add(:BENCE,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if move.id == :STEALTHROCK && battler.species == :STONJOURNER && !trainer_speaking.policyStates[:StealthRock] && !battler.battle.singleBattle?
		dialogue_array.push("Agnes! Rip 'em up! This is OUR arena now!")
		trainer_speaking.policyStates[:StealthRock] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerIsUsingMoveDialogue.add(:ZOE,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if [:POWERUPPUNCH,:MACHPUNCH].include?(move.id) && battler.species == :BRAVIARY && !trainer_speaking.policyStates[:BirdPunch] && !battler.battle.singleBattle?
		dialogue_array.push("Ever been punched by a bird before? Not as funny as it sounds.")
		trainer_speaking.policyStates[:BirdPunch] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerIsUsingMoveDialogue.add(:ZOE,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if move.id == :HELPINGHAND && battler.species == :MANTINE && !trainer_speaking.policyStates[:MantineHand] && !battler.battle.singleBattle?
		dialogue_array.push("*hiss* Fine. Go, 1 Second! Don't leave him hanging!")
		trainer_speaking.policyStates[:MantineHand] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::PlayerIsUsingMoveDialogue.add(:BENCE,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if move.id == :STEALTHROCK && !trainer_speaking.policyStates[:TrainerStealthRock] && !battler.battle.singleBattle?
		dialogue_array.push("Oh, come ON! Turnabout's fair play, I guess...")
		trainer_speaking.policyStates[:TrainerStealthRock] = true
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:BENCE,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !battler.battle.singleBattle? && !battler.battle.pbAllFainted?(1) && battler.battle.pbGetOwnerFromBattlerIndex(battler.index).all_fainted?
		dialogue_array.push("That's me done. Zoé, don't you let me down. Again.")
	end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:ZOE,
  proc { |policy,battler,trainer_speaking,dialogue_array|
	if !battler.battle.singleBattle? && !battler.battle.pbAllFainted?(1) && battler.battle.pbGetOwnerFromBattlerIndex(battler.index).all_fainted?
		dialogue_array.push("I've got nothing. Nada. Bence, you better win this.")
	end
    next dialogue_array
  }
)