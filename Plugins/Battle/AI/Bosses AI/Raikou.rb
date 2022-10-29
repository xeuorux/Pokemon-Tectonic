PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:RAIKOU,:LIGHTNINGSHRIEK],
  proc { |speciesAndMove,user,target,move|
	next user.stages[:SPEED]<1
  }
)


PokeBattle_AI::BossDecidedOnMove.add(:RAIKOU,
	proc { |species,move,user,targets|
		if move.id == :LIGHTNINGSHRIEK
			user.battle.pbDisplayBossNarration(_INTL("#{user.pbThis} opens its mouth up wide!"))
		end
	}
)