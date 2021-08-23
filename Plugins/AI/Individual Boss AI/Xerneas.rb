PokeBattle_AI::BossSpeciesRequireMove.add(:XERNEAS,
	proc { |species,move,user,target|
		next true if move.function == "14E" && isTimeForGeomancy(user,target)
		next true if move.function == "124" && wonderRoomStrong(user,target)
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:XERNEAS,
	proc { |species,move,user,target|
		next true if move.function == "14E" && !isTimeForGeomancy(user,target)
		next true if move.function == "124" && !wonderRoomStrong(user,target)
	}
)

def isTimeForGeomancy(user,target)
	return user.turnCount % 2 == 1 && user.battle.commandPhasesThisRound == $game_variables[95] - 1
end

def wonderRoomStrong(user,target)	
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
		
		return true if allSpecialFocused
	end
	return false
end

PokeBattle_AI::BossDecidedOnMove.add(:XERNEAS,
	proc { |species,move,user,target|
		if move.function == "14E"
			user.battle.pbDisplay(_INTL("{1} senses the powerful defensive auras of your Pokemon...",user.pbThis))
		end
	}
)