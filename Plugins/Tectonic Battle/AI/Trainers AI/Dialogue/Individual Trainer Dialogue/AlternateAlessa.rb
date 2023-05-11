PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:ALTERNATE_ALESSA,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.species == :ETERNATUS && !trainer_speaking.policyStates[:EternatusComment]
          dialogue_array.push("If you ever want to see the light of day again, you’ll serve, wyrm.")
          dialogue_array.push("Vent that hatred towards them, yeah?")
          trainer_speaking.policyStates[:EternatusComment] = true
      end
      next dialogue_array
  }
)
