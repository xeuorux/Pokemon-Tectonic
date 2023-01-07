PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:RAFAEL,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
          dialogue_array.push("...I've seen me win these. Yeah, I've seen me win these...")
          trainer_speaking.policyStates[:LastPokemonComment] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::TrainerAbilityTriggeredDialogue.add(:RAFAEL,
  proc { |_policy, _battler, ability, trainer_speaking, dialogue_array|
      if ability == :DANCER && !trainer_speaking.policyStates[:DancerGimmickComment]
          dialogue_array.push("Call me gimmicky, but I ain't a one-trick pony.")
          trainer_speaking.policyStates[:DancerGimmickComment] = true
      end
      next dialogue_array
  }
)
