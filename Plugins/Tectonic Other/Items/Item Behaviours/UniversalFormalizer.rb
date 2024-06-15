ItemHandlers::UseOnPokemon.add(:UNIVERSALFORMALIZER,proc { |item,pkmn,scene|
	species = pkmn.species
	validSpecies = %i[DEOXYS ORICORIO LYCANROC ROTOM DARMANITAN GDARMANITAN DEERLING SAWSBUCK URSHIFU]
	if validSpecies.include?(species)
		possibleForms = []
		possibleFormNames = []
		GameData::Species.each do |species_data|
			next unless species_data.species == species
			next if species_data.form == pkmn.form
			next if species_data.species == :LYCANROC && species_data.form == 1
			possibleForms.push(species_data)
			possibleFormNames.push(species_data.form_name)
		end
		possibleFormNames.push(_INTL("Cancel"))
		choice = pbMessage(_INTL("Which form shall the Pokemon take?"),possibleFormNames,possibleFormNames.length)
		if choice < possibleForms.length
			pbSceneDefaultDisplay(_INTL("#{pkmn.name} swapped to #{possibleFormNames[choice]}!"),scene)
			
			showPokemonChanges(pkmn) {
				pkmn.form = possibleForms[choice].form
			}
		end
		next true
	else
		pbSceneDefaultDisplay(_INTL("Cannot use this item on that Pokemon."),scene)
		next false
	end
})


def getFormSelectionChoices(species,currentForm=0)
	possibleForms = []
	possibleFormNames = []
	GameData::Species.each do |species_data|
		next unless species_data.species == species
		next if species_data.form == currentForm
		possibleForms.push(species_data)
		possibleFormNames.push(species_data.form_name)
	end
	possibleFormNames.push(_INTL("Cancel"))
	return possibleForms, possibleFormNames
end

ItemHandlers::UseOnPokemon.add(:ZYGARDECUBE,proc { |item,pkmn,scene|
	if pkmn.species == :ZYGARDE
		pkmn.form = pkmn.form == 0 ? 3 : 0
		scene&.pbRefresh
		pbSceneDefaultDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,GameData::Ability.get(pkmn.ability).name),scene)
		next true
	else
		pbSceneDefaultDisplay(_INTL("Cannot use this item on that Pokemon."),scene)
		next false
	end
})