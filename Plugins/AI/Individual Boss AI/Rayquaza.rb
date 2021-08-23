PokeBattle_AI::BossBeginTurn.add(:RAYQUAZA,
	proc { |species,battler|
		next if battler.mega?
		battler.battle.pbMegaEvolve(battler.index)
	}
)