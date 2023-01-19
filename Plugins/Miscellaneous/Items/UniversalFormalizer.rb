ItemHandlers::UseOnPokemon.add(:UNIVERSALFORMALIZER,proc { |item,pkmn,scene|
	species = pkmn.species
	if [:DEOXYS,:ORICORIO,:LYCANROC,:ROTOM,
			:DARMANITAN,:GDARMANITAN,:BURMY,:WORMADAM,
			:DEERLING,:SAWSBUCK,:TORNADUS,:THUNDURUS,:LANDORUS,
			:PUMPKABOO,:GOURGEIST,:URSHIFU].include?(species)
			possibleForms, possibleFormNames = getFormSelectionChoices(species,pkmn.form)
			choice = scene.pbMessage("Which form shall the Pokemon take?",	possibleFormNames,possibleFormNames.length)
			if choice < possibleForms.length
				scene.pbMessage("#{pkmn.name} swapped to #{possibleFormNames[choice]}!")
				
				showPokemonChanges(pkmn) {
					pkmn.form = possibleForms[choice].form
				}
			end
			next true
	else
		scene.pbMessage("Cannot use this item on that Pokemon.")
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
		possibleFormNames.push(species_data.real_form_name)
	end
	possibleFormNames.push(_INTL("Cancel"))
	return [possibleForms, possibleFormNames]
end