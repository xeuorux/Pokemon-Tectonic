def forEachZooMap()
	[31].each do |map_id|
		map = $MapFactory.getMapNoAdd(map_id)
		yield map if map
	end
end

def canBeSentToZoo(pkmn)
	return !isInZoo(pkmn.species)
end

def isInZoo(species)
	speciesName = GameData::Species.get(species).id.to_s

	isInZoo = false
	forEachZooMap do |map|
		map.events.each_value { |event|
			if event.name.include?(speciesName) && $game_self_switches[[map.map_id, event.id, "A"]]
				isInZoo = true
			end
		}
	end
	return isInZoo
end

def sendToZoo()
	return unless pbConfirmMessageSerious(_INTL("Are you sure you want to send {1} to the Zoo?",pbGet(3)))
	
	species = pbGetPokemon(1).species
	speciesName = GameData::Species.get(species).id.to_s
	
	successfulSet = false
	forEachZooMap do |map|
		map.events.each_value { |event|
			if event.name.include?(speciesName)
				pbSetSelfSwitch(event.id,"A",true,map.map_id)
				successfuLSet = true
			end
		}
	end
	
	if !successfulSet
		pbMessage("Unable to find that species in the zoo!")
		return
	end
	
	$Trainer.party[pbGet(1)] = nil
	$Trainer.party.compact!
	
	refreshFollow()
end

def debugTurnOnAll()
	forEachZooMap do |map|
		map.events.each_value { |event|
			if event.name.include?("overworld")
				pbSetSelfSwitch(event.id,"A",true,map.map_id)
			end
		}
	end
end

def debugTurnOffAll()
	forEachZooMap do |map|
		map.events.each_value { |event|
			if event.name.include?("overworld")
				pbSetSelfSwitch(event.id,"A",false,map.map_id)
			end
		}
	end
end

# More likely to be shiny
Events.onWildPokemonCreate+=proc {|sender,e|
	pokemon=e[0]
	pokemon.shinyRerolls *= 2 if isInZoo(pokemon.species)
}