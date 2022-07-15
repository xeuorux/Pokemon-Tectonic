PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ENTEI,:INCINERATE],
  proc { |speciesAndMove,user,target,move|
	  next target.item && (target.item.is_berry? || target.item.is_gem?)
  }
)

PokeBattle_AI::BossDecidedOnMove.add(:ENTEI,
	proc { |species,move,user,target|
		if move.id == :INCINERATE
			user.battle.pbDisplay(_INTL("#{user.pbThis} notices #{target.pbThis(true)}'s flammable item!"))
		end
	}
)