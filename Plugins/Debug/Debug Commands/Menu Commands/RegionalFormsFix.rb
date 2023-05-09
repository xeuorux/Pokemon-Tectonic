DebugMenuCommands.register("regionalformsfix", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Regional Forms as Species"),
  "description" => _INTL("Recode regional forms as their own separate species"),
  "effect"      => proc { |sprites, viewport|
	newSpeciesID = 2000
    GameData::Species.each do |species_data|
		next if species_data.form == 0
		next if !species_data.id
		formName = species_data.real_form_name
		next if !formName || formName == ""
		next unless formName.include?("Galarian") || formName.include?("Alolan")
		
		prefix = formName.include?("Galarian") ? "G" : "A"
		trimmedID = species_data.id.to_s[0..-3]
		newID = (prefix + trimmedID).to_sym
		echoln(newID)
	
		new_species_hash = {
          :id                    => newID,
          :id_number             => newSpeciesID,
          :name                  => species_data.name,
		  :form					 => 0,
          :form_name             => "",
          :category              => species_data.category,
          :pokedex_entry         => species_data.pokedex_entry,
          :type1                 => species_data.type1,
          :type2                 => species_data.type2,
          :base_stats            => species_data.base_stats,
          :evs                   => species_data.evs,
          :base_exp              => species_data.base_exp,
          :growth_rate           => species_data.growth_rate,
          :gender_ratio          => species_data.gender_ratio,
          :catch_rate            => species_data.catch_rate,
          :happiness             => species_data.happiness,
          :moves                 => species_data.moves, # MODIFIED
          :tutor_moves           => species_data.tutor_moves,
          :egg_moves             => species_data.egg_moves,
          :abilities             => species_data.abilities,
          :hidden_abilities      => species_data.hidden_abilities,
          :wild_item_common      => species_data.wild_item_common,
          :wild_item_uncommon    => species_data.wild_item_uncommon,
          :wild_item_rare        => species_data.wild_item_rare,
          :egg_groups            => species_data.egg_groups,
          :hatch_steps           => species_data.hatch_steps,
          :incense               => species_data.incense,
          :evolutions            => species_data.evolutions,
          :height                => species_data.height,
          :weight                => species_data.weight,
          :color                 => species_data.color,
          :shape                 => species_data.shape,
          :habitat               => species_data.habitat,
          :generation            => species_data.generation,
          :back_sprite_x         => species_data.back_sprite_x,
          :back_sprite_y         => species_data.back_sprite_y,
          :front_sprite_x        => species_data.front_sprite_x,
          :front_sprite_y        => species_data.front_sprite_y,
          :front_sprite_altitude => species_data.front_sprite_altitude,
          :shadow_x              => species_data.shadow_x,
          :shadow_size           => species_data.shadow_size
        }
		GameData::Species.register(new_species_hash)
		GameData::Species::DATA.delete(species_data.id)
		
		["Back","Back shiny","Front","Front shiny","Icons","Icons shiny","Footprints"].each do |subfolder|
			source = "Graphics/Pokemon/" + subfolder + "/" + species_data.id.to_s + ".png"
			destination = "Graphics/Pokemon/" + subfolder + "/" + newID.to_s + ".png"
			File.copy(source, destination) rescue nil
		end
		
		cry_source = "Audio/SE/Cries/" + trimmedID + ".ogg"
		cry_destination = "Audio/SE/Cries/" + "/" + newID.to_s + ".ogg"
		File.copy(cry_source, cry_destination) rescue nil
		
		newSpeciesID += 1
	end
	GameData::Species.save
	Compiler.write_pokemon
	Compiler.write_pokemon_forms
  }
})
