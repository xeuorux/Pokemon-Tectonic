DebugMenuCommands.register("detectmonotypeabilities", {
  "parent"      => "analysis",
  "name"        => _INTL("Detect monotype abilities"),
  "description" => _INTL("See which abilities have too many usages by species-lines of the same type."),
  "effect"      => proc { |sprites, viewport|
	ability_type_counts = {}
	GameData::Ability.each do |ability_data|
		ability_type_counts[ability_data.id] = {}
		GameData::Type.each do |type_data|
			ability_type_counts[ability_data.id][type_data.id] = 0
		end
	end
	
	abilities_by_lines = {}
    GameData::Species.each do |species_data|
		# Don't check the species if its an alt form that isn't a regional form
		next if species_data.form != 0
		# ... or if its not fully evolved
		next if species_data.get_evolutions().length > 0
		next if isLegendary?(species_data.id) || isQuarantined?(species_data.id)

				
		species_data.abilities.each do |ability_id|
			ability_type_counts[ability_id][species_data.type1] += 1
			ability_type_counts[ability_id][species_data.type2] += 1 if species_data.type2 != species_data.type1
		end
	end
	
	# Find the outliers
	sorted_info = {}
	ability_type_counts.each do |ability,type_counts|
		type_counts.each do |type,count|
			if count > 0
				sorted_info[[ability,type]] = count
			end
		end
	end
	sorted_info = sorted_info.sort_by { |ability_and_type, count| [-count,ability_and_type[0]] }
	sorted_info.each do |ability_and_type,count|
		ability = ability_and_type[0]
		type = ability_and_type[1]
		echoln("#{ability} is given to #{count} species-lines of the #{type} type.")
	end
  }
})