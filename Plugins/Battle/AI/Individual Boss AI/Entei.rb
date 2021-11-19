PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ENTEI,:INCINERATE],
  proc { |speciesAndMove,user,target,move|
	next target.item && (target.item.is_berry? || target.item.is_gem?)
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ENTEI,:SUNNYDAY],
  proc { |speciesAndMove,user,target,move|
	next user.battle.field.weather != :Sun && user.hp <= user.totalhp / 2
  }
)

PokeBattle_AI::BossDecidedOnMove.add(:ENTEI,
	proc { |species,move,user,target|
		if move.id == :SUNNYDAY
			user.battle.pbDisplay(_INTL("The avatar of Entei is heating up with rage!"))
		end
	}
)