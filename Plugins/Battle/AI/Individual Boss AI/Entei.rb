PokeBattle_AI::BossSpeciesRequireMove.add(:ENTEI,
	proc { |species,move,user,target|
		# Always incinerate items if you can
		next true if move.function == "0F5" && target.item && (target.item.is_berry? || target.item.is_gem?)
	}
)