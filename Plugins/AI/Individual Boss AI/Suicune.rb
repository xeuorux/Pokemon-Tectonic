PokeBattle_AI::BossSpeciesRequireMove.add(:SUICUNE,
	proc { |species,move,user,target|
		next true if move.function == "019" # Heal bell
	}
 
)