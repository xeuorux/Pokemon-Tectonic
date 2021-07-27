def forEachZooMap()
	[31].each do |map_id|
		map = $MapFactory.getMapNoAdd(map_id)
		yield map if map
	end
end

def canBeSentToZoo(pkmn)
	return !donatedToZoo?(pkmn.species)
end

def donatedToZoo?(species)
	speciesName = GameData::Species.get(species).id.to_s
	return checkFor(speciesName,true)
end

def eventExistsFor?(species)
	speciesName = GameData::Species.get(species).id.to_s
	return checkFor(speciesName,false)
end

def checkFor(speciesName,careAboutEnabled)
	forEachZooMap do |map|
		map.events.each_value { |event|
			if event.name.include?(speciesName) && (!careAboutEnabled || $game_self_switches[[map.map_id, event.id, "A"]])
				return true
			end
		}
	end
	return false
end

def sendToZoo()
	pokemonName = pbGet(3)
	return unless pbConfirmMessageSerious(_INTL("Are you sure you want to send {1} to the Zoo?",pokemonName))
	
	species = pbGetPokemon(1).species
	speciesName = GameData::Species.get(species).id.to_s
	
	placementMap = nil
	forEachZooMap do |map|
		map.events.each_value { |event|
			if event.name.include?(speciesName)
				pbSetSelfSwitch(event.id,"A",true,map.map_id)
				placementMap = (pbGetMessage(MessageTypes::MapNames,map.map_id) rescue nil) || "???" if !placementMap
			end
		}
	end
	
	if !placementMap
		pbMessage("ERROR: Unable to find that species in the zoo!")
		return
	end
	
	$Trainer.party[pbGet(1)] = nil
	$Trainer.party.compact!
	
	pbMessage("#{pokemonName} was placed in #{placementMap}!")
	
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

def debugCheckMissingSpecies()
	totalPresent = 0
	totalMissing = 0
	GameData::Species.each do |species_data|
		next if species_data.form != 0
		if !eventExistsFor?(species_data.species)
			echo("No Zoo event exists for species: #{species_data.real_name}\n")
			totalMissing += 1
		else
			totalPresent += 1
		end
	end
	pbMessage("#{totalPresent} species have an event.")
	pbMessage("#{totalMissing} species do NOT have an event.")
	completion = totalPresent.to_f / (totalPresent + totalMissing).to_f
	completion = (completion*10000).floor / 100.0
	pbMessage("The Zoo is #{completion} percent complete.")
end

# More likely to be shiny
Events.onWildPokemonCreate+=proc {|sender,e|
	pokemon=e[0]
	pokemon.shinyRerolls *= 2 if isInZoo(pokemon.species)
}