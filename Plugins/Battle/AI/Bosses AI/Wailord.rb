PokeBattle_AI::BossDecidedOnMove.add(:WAILORD,
	proc { |species,move,user,targets|
		if move.function == "0E0"
			user.battle.pbDisplay(_INTL("#{user.pbThis} is flying erratically. It looks unstable!"))
		end
	}
)