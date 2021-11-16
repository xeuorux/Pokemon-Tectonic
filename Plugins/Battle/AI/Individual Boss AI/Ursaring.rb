# Scratch
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:URSARING,:SCRATCH],
  proc { |speciesAndMove,user,target,move|
	next user.hp > user.totalhp / 2
  }
)

# Slash
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:URSARING,:SLASH],
  proc { |speciesAndMove,user,target,move|
	next user.hp <= user.totalhp / 2
  }
)