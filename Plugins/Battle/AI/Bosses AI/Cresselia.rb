PokeBattle_AI::BossBeginTurn.add(:CRESSELIA,
	proc { |species,battler|
		battle = battler.battle
		if battle.turnCount == 4
			battle.pbDisplay(_INTL("A Shadow creeps into the dream..."))

			battle.addAvatarBattler(:DARKRAI,battler.level)
		end
	}
)