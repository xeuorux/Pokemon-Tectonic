PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:SAMORN,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
          dialogue_array.push("...")
          trainer_speaking.policyStates[:LastPokemonComment] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::PlayerPokemonImmuneDialogue.add(:SAMORN,
  proc { |_policy, attacker, _target, _isImmunityAbility, trainer_speaking, dialogue_array|
      if attacker.species == :GARCHOMP && !trainer_speaking.policyStates[:GarchompImmunityComment]
          dialogue_array.push("...!")
          trainer_speaking.policyStates[:GarchompImmunityComment] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::PlayerPokemonFaintedDialogue.add(:SAMORN,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if !trainer_speaking.policyStates[:BPDeathComment] && battler.lastFoeAttacker.length > 0 && battler.battle.pbWeather == :Rain
          anyLastMoveWasBulletPunch = false
          battler.lastFoeAttacker.each do |battler_index|
              anyLastMoveWasBulletPunch = true if battler.battle.battlers[battler_index].lastMoveUsed == :BULLETPUNCH
          end
          if anyLastMoveWasBulletPunch
              dialogue_array.push("...Hmph.")
              trainer_speaking.policyStates[:BPDeathComment] = true
          end
      end
      next dialogue_array
  }
)
