def canBeSentToZoo(pkmn)
	species = pkmn.species
	speciesName = GameData::Species.get(species).id.to_s

	canBeSent = false
	$game_map.events.each_value { |event|
			if event.name.include?(speciesName) && !$game_self_switches[[@map_id, event.id, "A"]]
				canBeSent = true
			end
		}
	return canBeSent
end

def sendToZoo()
	if pbConfirmMessageSerious(_INTL("Are you sure you want to send {1} to the Zoo?",pbGet(3)))
		species = pbGetPokemon(1).species
		speciesName = GameData::Species.get(species).id.to_s
		
		$Trainer.party[pbGet(1)] = nil
		$Trainer.party.compact!
		
		$game_map.events.each_value { |event|
			if event.name.include?(speciesName)
				pbSetSelfSwitch(event.id,"A",true)
			end
		}
		
		refreshFollow()
	end
end

def debugTurnOnAll()
	$game_map.events.each_value { |event|
		if event.name.include?("overworld")
			pbSetSelfSwitch(event.id,"A",true)
		end
	}
end