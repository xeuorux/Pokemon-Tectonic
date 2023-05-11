PokeBattle_AI::TrainerSendsOutPokemonDialogue.add(:HELENA,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
      if battler.battle.pbAbleCount(battler.index) == battler.battle.sideSizes[1] && !trainer_speaking.policyStates[:LastPokemonComment]
          dialogue_array.push("Don’t give me that look. I've won worse.")
          trainer_speaking.policyStates[:LastPokemonComment] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::TerrainChangeDialogue.add(:HELENA,
  proc { |_policy, old_terrain, _new_terrain, trainer_speaking, dialogue_array|
      if old_terrain == :Electric && !trainer_speaking.policyStates[:TerrainChangeComment]
          dialogue_array.push("...How regrettable. Sick of having your fuses blown?")
          trainer_speaking.policyStates[:TerrainChangeComment] = true
      end
      next dialogue_array
  }
)

PokeBattle_AI::TrainerIsUsingMoveDialogue.add(:HELENA,
  proc { |_policy, battler, move, _target, trainer_speaking, dialogue_array|
      if move.id == :TERRAINPULSE && battler.species == :CLAUNCHER && !trainer_speaking.policyStates[:TerrainPulseComment] && battler.battle.field.terrain == :Electric
          dialogue_array.push("Absolute power is at your clawtips, Clauncher. Bring down the house!")
          trainer_speaking.policyStates[:TerrainPulseComment] = true
      end
      next dialogue_array
  }
)
