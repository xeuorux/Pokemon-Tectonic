PokeBattle_AI::TrainerIsUsingMoveDialogue.add(:HELENA,
  proc { |policy,battler,move,target,trainer_speaking,dialogue_array|
	if move.id == :SELFDESTRUCT && 
			!trainer_speaking.policyStates[:CommentedOnSelfDestructYet]
		hasGhostAlly = false
		battler.battle.eachSameSideBattler(battler.index) do |b|
			next if b.index == battler.index
			hasGhostAlly = true if b.pbHasType?(:GHOST)
		end
		if hasGhostAlly
			dialogue_array.push("Call me gimmicky, but I ain’t a one-trick pony.")
			trainer_speaking.policyStates[:CommentedOnSelfDestructYet] = true
		end
	end
    next dialogue_array
  }
)