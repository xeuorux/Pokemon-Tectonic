PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:ALESSA_4,
  proc { |_policy, battler, trainer_speaking, dialogue_array|

        killedByRattata = false
        battler.lastAttacker.each do |battlerIndex|
            if battler.battle.battlers[battlerIndex].species == :RATTATA
                killedByRattata = true
                break
            end
        end

        if killedByRattata && !trainer_speaking.policyStates[:RattataKillDialogue]
            dialogue_array.push("Thought ya'd be better than that, honestly.")
            trainer_speaking.policyStates[:RattataKillDialogue] = true
        end
        next dialogue_array
  }
)

PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:ALESSA_5,
    proc { |_policy, battler, trainer_speaking, dialogue_array|
        if battler.species == :HEATRAN && !trainer_speaking.policyStates[:HeatranComment]
            dialogue_array.push("Had to commit a few choice sins ta catch this fella, but it was well worth it.")
            trainer_speaking.policyStates[:HeatranComment] = true
        end
        next dialogue_array
    }
  )