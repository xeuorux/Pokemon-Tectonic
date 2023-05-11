PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:ZAIN,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      starters = %i[APPLIN FLAPPLE APPLETUN NUMEL CAMERUPT DROMERUPT KRABBY KINGLER KLAWSAR]
      if $Trainer.able_pokemon_count == 0
          dialogue_array.push("Really? That's it? Get back up. That can't be all you've got.")
      elsif starters.include?(battler.species) && !trainer_speaking.policyStates[:StarterDeathDialogue]
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
  proc { |_policy, _battler, trainer_speaking, dialogue_array|
      if $Trainer.able_pokemon_count == 1 && !trainer_speaking.policyStates[:PlayerLastPokemonDialogue]
          dialogue_array.push("Is that all? I must've lost count. I thought we were just getting started.")
          trainer_speaking.policyStates[:PlayerLastPokemonDialogue] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:ZAIN,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:TrainerLastPokemonComment]
          dialogue_array.push("You've got a really punchable face, you know that? Smug to the end.")
          trainer_speaking.policyStates[:TrainerLastPokemonComment] = true
      end
      next dialogue_array
  }
)
