PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:XERNEAS,"124"],
	proc { |speciesAndMoveCode,user,target,move|
		#Use wonder room if its not the first attack of the round, and if all the player's active pokemon
		#have higher special defense than physical defense
		if user.battle.commandPhasesThisRound != 0
			allSpecialFocused = true
			user.battle.battlers.each do |b|
				next if !b || !user.opposes?(b)
				defense				= b.plainStats[:DEFENSE]
				specialDefense      = b.plainStats[:SPECIAL_DEFENSE]
				if defense > specialDefense
					allSpecialFocused = false
				end
			end
			
			next true if allSpecialFocused
		end
		next false
	}
)

PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:XERNEAS,"14E"],
	proc { |speciesAndMoveCode,user,target|
		next user.turnCount % 2 == 1 && user.lastMoveThisTurn?
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:XERNEAS,
	proc { |species,move,user,target|
		if move.function == "14E"
			user.battle.pbDisplay(_INTL("{1} senses the powerful defensive auras of your Pokemon!",user.pbThis))
		end
	}
)