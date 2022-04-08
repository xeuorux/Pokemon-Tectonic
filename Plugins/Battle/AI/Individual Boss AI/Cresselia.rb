PokeBattle_AI::BossBeginTurn.add(:CRESSELIA,
	proc { |species,battler|
		battle = battler.battle
		turnCount = battle.turnCount
		if turnCount == 0
			battle.pbDisplay(_INTL("A Shadow creeps into the dream..."))

			battle.addAvatarBattler(:DARKRAI,battler.level)
		end
	}
)