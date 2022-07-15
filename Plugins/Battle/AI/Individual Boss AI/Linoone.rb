# Covet
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:LINOONE,:COVET],
  proc { |speciesAndMove,user,target,move|
	  next user.item.nil? && !target.item.nil?
  }
)

PokeBattle_AI::BossDecidedOnMove.add(:LINOONE,
	proc { |species,move,user,target|
		if move.id == :COVET
			user.battle.pbDisplay(_INTL("#{user.pbThis} eyes #{target.pbThis(true)}'s #{GameData::Item.get(target.item).real_name} with jealousy!"))
		end
	}
)