def pbWait(numFrames)
	numFrames.times do
	  Graphics.update
	  Input.update
	  pbUpdateSceneMap
	end
  end

def debugControl
    $DEBUG && Input.press?(Input::CTRL)
end

def pbReceiveRandomPokemon(level)
	getLevelCap = level if level > getLevelCap
	possibleSpecies = []
	GameData::Species.each do |species_data|
		next if species_data.get_evolutions.length > 0
		next if species_data.isLegendary?
		possibleSpecies.push(species_data)
	end
	speciesDat = possibleSpecies.sample
	pkmn = Pokemon.new(speciesDat.species, level)
	pkmn.form = speciesDat.form
	pbAddPokemonSilent(pkmn)
	pbMessage(_INTL("You recieved a #{speciesDat.name} (#{speciesDat.form_name})"))
end

def hasPokemonInParty(speciesToCheck)
	if !speciesToCheck.is_a?(Array)
		speciesToCheck = [speciesToCheck]
	end
	hasAll = true
	speciesToCheck.each do |species|
		hasInParty = false
		$Trainer.party.each do |party_member|
			echoln("Comparing #{party_member.species} to #{species}")
			if party_member.species == species
				hasInParty = true
				break
			end
		end
		if !hasInParty
			hasAll = false
			break
		end
	end
	return hasAll
end

def playerIsOutdoors?
	return false unless GameData::MapMetadata.exists?($game_map.map_id)
	return GameData::MapMetadata.get($game_map.map_id).outdoor_map
end

def teamEditingAllowed?()
	return true unless GameData::MapMetadata.exists?($game_map.map_id)
	return !GameData::MapMetadata.get($game_map.map_id).no_team_editing
end

def showNoTeamEditingMessage()
	pbMessage(_INTL("Editing your team is not allowed at the moment."))
end