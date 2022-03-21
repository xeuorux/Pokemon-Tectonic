DebugMenuCommands.register("relearnsfix", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Bad relearns fix"),
  "description" => _INTL("Swap moves that are 'relearned' at level 1 into the egg moves category of the lines first species."),
  "effect"      => proc { |sprites, viewport|
    GameData::Species.each do |species_data|
		next if species_data.form != 0
		next if species_data.get_prevolutions.length == 0
				
		movesToKeep = []
		firstSpecies = species_data
		
		# Find the first species of this line, and also gather an array of all moves learned by previous pokemon in the line
		while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
			firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
			firstSpecies.moves.each do |learnset_entry|
				movesToKeep.push(learnset_entry[1])
			end
		end
		
		# Also gather any "evolution" moves from the current species
		species_data.moves.each do |learnset_entry|
			next unless learnset_entry[0] == 0
			movesToKeep.push(learnset_entry[1])
		end
		
		movesToKeep.uniq!
		movesToKeep.compact!
		
		newLearnSet = []
		species_data.moves.each do |learnset_entry|
			level = learnset_entry[0]
			move = learnset_entry[1]
			if movesToKeep.include?(move) || level != 1
				newLearnSet.push([level,move])
			else
				echo("Transferring the move #{move} of the species #{species_data.id} to its first line-member #{firstSpecies.id}\n")
				firstSpecies.egg_moves.push(move)
			end
		end
		
		new_species_hash = {
          :id                    => species_data.id,
          :id_number             => species_data.id_number,
          :name                  => species_data.name,
          :form_name             => species_data.form_name,
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
          :moves                 => newLearnSet, # MODIFIED
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
		
		firstSpecies.egg_moves.uniq!
		firstSpecies.egg_moves.compact!
	end
	GameData::Species.save
	Compiler.write_pokemon
  }
})
