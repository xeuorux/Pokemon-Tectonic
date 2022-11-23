PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:SHADOW_MAVIS,
    proc { |policy,battler,trainer_speaking,dialogue_array|
      if pbAllFainted?(battler.index) && !pbAllFainted?(battler.index-2) && !trainer_speaking.policyStates[:RelyOnYezeraComment]
          dialogue_array.push("Tsk, tsk, tsk. It appears my work here is done.")
          dialogue_array.push("Let’s see which of you two is the better.")
          trainer_speaking.policyStates[:RelyOnYezeraComment] = true
      end
      next dialogue_array
    }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:SHADOW_MAVIS,
    proc { |policy,battler,trainer_speaking,dialogue_array|
        if battler.species == :LUXRAY && !trainer_speaking.policyStates[:LuxrayComment]
            dialogue_array.push("My pride and joy. Don’t you dare fail me now. Shred mommy’s enemies, OK?")
            trainer_speaking.policyStates[:LuxrayComment] = true
        end
        next dialogue_array
    }
)

PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:SHADOW_MAVIS,
    proc { |policy,battler,trainer_speaking,dialogue_array|
      if !trainer_speaking.policyStates[:PlayerDeathComment]
          dialogue_array.push("...Dispose of this one after we’re done.")
          dialogue_array.push("It doesn’t deserve its position. You can do better.")
          trainer_speaking.policyStates[:PlayerDeathComment] = true
      end
      next dialogue_array
    }
)