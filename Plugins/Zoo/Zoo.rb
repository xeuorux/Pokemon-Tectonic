def forEachZooMap()
	[31].each do |map_id|
		map = $MapFactory.getMapNoAdd(map_id)
		yield map if map
	end
end

def canBeSentToZoo(pkmn)
	return eventExistsFor?(pkmn.species) && !donatedToZoo?(pkmn.species)
end

def donatedToZoo?(species)
	speciesName = GameData::Species.get(species).id.to_s
	return checkForZooMap(speciesName,true) != -1
end

def eventExistsFor?(species)
	speciesName = GameData::Species.get(species).id.to_s
	return checkForZooMap(speciesName,false) != -1
end

def eventExistsInMap?(mapID,species)
	map = $MapFactory.getMapNoAdd(mapID)
	map.events.each_value { |event|
		return true if eventIsForSpecies(event,species.name)
	}
	return false
end

def checkForZooMap(speciesName,careAboutEnabled=false)
	forEachZooMap do |map|
		map.events.each_value { |event|
			if eventIsForSpecies(event,speciesName)
				if careAboutEnabled
					if $game_self_switches[[map.map_id, event.id, 'A']]
						return map.map_id
					else
						return -1
					end
				else
					return map.map_id
				end
			end
		}
	end
	return -1
end

def eventIsForSpecies(event,speciesName)
	match = event.name.match(/.*overworld\(([A-Za-z_0-9]+)\).*/i)
	return match && match[1] == speciesName
end

def sendToZoo()
	pokemonName = pbGet(3)
	return unless pbConfirmMessageSerious(_INTL("Are you sure you want to send {1} to the Zoo?",pokemonName))
	
	species = pbGetPokemon(1).species
	speciesName = GameData::Species.get(species).id.to_s
	
	placementMap = nil
	forEachZooMap do |map|
		map.events.each_value { |event|
			if eventIsForSpecies(event,speciesName)
				echoln("Enabling event #{event.name}")
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
	pokemon.shinyRerolls *= 2 if donatedToZoo?(pokemon.species)
}