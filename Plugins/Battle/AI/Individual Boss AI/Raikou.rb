PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:RAIKOU,:LIGHTNINGSHRIEK],
  proc { |speciesAndMove,user,target,move|
	next user.stages[:SPEED]<1
  }
)
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:RAIKOU,:THUNDERWAVE],
  proc { |speciesAndMove,user,target,move|
	next GameData::Species.get(target.species).base_stats[:SPEED]>75
  }
)

PokeBattle_AI::BossDecidedOnMove.add(:KYOGRE,
	proc { |species,move,user,target|
		if move.id == :THUNDERWAVE
			user.battle.pbDisplay(_INTL("Raikou feels rivalled by #{target.name}'s speed!"))
		end
	}
)