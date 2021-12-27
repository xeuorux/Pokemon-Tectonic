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

PokeBattle_AI::BossDecidedOnMove.add(:RAIKOU,
	proc { |species,move,user,target|
		if move.id == :THUNDERWAVE
			battler = user.battle.battlers[target]
			user.battle.pbDisplay(_INTL("The avatar of Raikou feels rivalled by #{battler.name}'s speed!"))
		end
	}
)