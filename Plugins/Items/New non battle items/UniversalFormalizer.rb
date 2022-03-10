ItemHandlers::UseOnPokemon.add(:UNIVERSALFORMALIZER,proc { |item,pkmn,scene|
	species = pkmn.species
	if [:DEOXYS,:ORICORIO,:LYCANROC,:ROTOM,
			:DARMANITAN,:GDARMANITAN,:BURMY,:WORMADAM,
			:DEERLING,:SAWSBUCK,:TORNADUS,:THUNDURUS,:LANDORUS,
			:PUMPKABOO,:GOURGEIST,:URSHIFU].include?(species)
		possibleForms = []
		possibleFormNames = []
		GameData::Species.each do |species_data|
			next unless species_data.species == species
			next if species_data.form == pkmn.form
			possibleForms.push(species_data)
			possibleFormNames.push(species_data.real_form_name)
		end
		possibleFormNames.push(_INTL("Cancel"))
		choice = scene.pbMessage("Which form shall the Pokemon take?",	possibleFormNames,possibleFormNames.length)
		if choice < possibleForms.length
			# Mark down pre-evolution stats
			oldTotalHP 	= pkmn.totalhp
			oldAttack 	= pkmn.attack
			oldDefense 	= pkmn.defense
			oldSpAtk 	= pkmn.spatk
			oldSpDef 	= pkmn.spdef
			oldSpeed 	= pkmn.speed
		
			scene.pbMessage("#{pkmn.name} swapped to #{possibleFormNames[choice]}!")
			pkmn.form = possibleForms[choice].form
			
			hpDif 		= pkmn.totalhp-oldTotalHP
			attackDif 	= pkmn.attack-oldAttack
			defenseDif 	= pkmn.defense-oldDefense
			spAtkDif 	= pkmn.spatk-oldSpAtk
			spDefDif 	= pkmn.spdef-oldSpDef
			speedDif 	= pkmn.speed-oldSpeed
			
			if hpDif != 0 || attackDif != 0 || defenseDif != 0 ||
				spAtkDif != 0 || spDefDif != 0 || speedDif != 0
				pbTopRightWindow(
					_INTL("Max. HP<r>#{hpDif >= 0 ? "+" : ""}{1}\r\nAttack<r>#{attackDif >= 0 ? "+" : ""}{2}\r\nDefense<r>#{defenseDif >= 0 ? "+" : ""}{3}\r\nSp. Atk<r>#{spAtkDif >= 0 ? "+" : ""}{4}\r\nSp. Def<r>#{spDefDif >= 0 ? "+" : ""}{5}\r\nSpeed<r>#{speedDif >= 0 ? "+" : ""}{6}",
					hpDif,attackDif,defenseDif,
					spAtkDif,spDefDif,speedDif))
				pbTopRightWindow(
					_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
					pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed))
			end
		end
		next true
	else
		scene.pbMessage("Cannot use this item on that Pokemon.")
		next false
	end
})
