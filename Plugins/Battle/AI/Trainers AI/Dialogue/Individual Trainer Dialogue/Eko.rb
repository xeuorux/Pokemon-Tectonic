PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:EKO,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] &&
          !trainer_speaking.policyStates[:CommentedOnLastPokemonYet]
          dialogue_array.push("You’re close now! But don’t you dare relax yet!")
          trainer_speaking.policyStates[:CommentedOnLastPokemonYet] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::PlayerPokemonDiesToDOTDialogue.add(:EKO,
  proc { |_policy, _pokemon, trainer_speaking, dialogue_array|
      unless trainer_speaking.policyStates[:CommentedOnDOTDeath]
          dialogue_array.push("So the lingering pain claims its first victim. Falter and you will fail!")
          trainer_speaking.policyStates[:CommentedOnDOTDeath] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonDiesToDOTDialogue.add(:EKO,
  proc { |_policy, _pokemon, trainer_speaking, dialogue_array|
      unless trainer_speaking.policyStates[:CommentedOnOwnDOTDeath]
          dialogue_array.push("Delightful! It seems you've learned from this!")
          trainer_speaking.policyStates[:CommentedOnOwnDOTDeath] = true
      end
      next dialogue_array
  }
)
