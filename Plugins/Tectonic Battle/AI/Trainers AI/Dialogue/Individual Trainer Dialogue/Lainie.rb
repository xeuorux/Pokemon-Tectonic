PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:LAINIE,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.species == :SOLGALEO && !trainer_speaking.policyStates[:SolgaleoDeathComment]
        dialogue_array.push("NO! My friend! What have you done to my light?!")
        trainer_speaking.policyStates[:SolgaleoDeathComment] = true
      elsif battler.species == :LUNALA && !trainer_speaking.policyStates[:LunalaDeathComment]
        dialogue_array.push("The light! My friend's light! I NEED IT!")
        trainer_speaking.policyStates[:LunalaDeathComment] = true
      end
      next dialogue_array
  }
)