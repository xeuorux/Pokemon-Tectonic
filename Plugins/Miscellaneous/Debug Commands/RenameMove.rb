DebugMenuCommands.register("renamemove", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Rename Move"),
  "description" => _INTL("Rename an existing move in moves, species, forms, and trainers PBS files"),
  "effect"      => proc {
    while true
      oldMoveInternalName = pbEnterText(_INTL("Enter move internal name."),0,20)
      break if oldMoveInternalName == ""
      oldMoveData = nil
      begin
        oldMoveData = GameData::Move.get(oldMoveInternalName)
      rescue => exception
        
      end
      if oldMoveData.nil?
        pbMessage("No move with that internal name was found.")
        next
      end
      newMoveInternalName = pbEnterText(_INTL("Enter the move's new internal name."),0,20)
      break if newMoveInternalName == ""
      newMoveInternalName = newMoveInternalName.gsub(" ","").upcase
      newMoveDisplayName = pbEnterText(_INTL("Enter the move's new display name."),0,20)
      break if newMoveDisplayName == ""

      # Construct move hash
      move_hash = {
        :id_number     => oldMoveData.id_number,
        :id            => newMoveInternalName,
        :name          => newMoveDisplayName,
        :function_code => oldMoveData.function_code,
        :base_damage   => oldMoveData.base_damage,
        :type          => oldMoveData.type,
        :category      => oldMoveData.category,
        :accuracy      => oldMoveData.accuracy,
        :total_pp      => oldMoveData.total_pp,
        :effect_chance => oldMoveData.effect_chance,
        :target        => oldMoveData.target,
        :priority      => oldMoveData.priority,
        :flags         => oldMoveData.flags,
        :description   => oldMoveData.description
      }
      # Add move's data to records
      GameData::Move::DATA.delete(oldMoveData.id)
      GameData::Move::DATA.delete(oldMoveData.id_number)
      GameData::Move.register(move_hash)
      GameData::Move.save
      Compiler.write_moves

      GameData::Species.each do |species_data|
        modifiedLevelUpMoves = species_data.moves
        modifiedLevelUpMoves.map! { |moveEntry|
          next [moveEntry[0],moveEntry[1] == oldMoveInternalName ? newMoveInternalName : oldMoveInternalName]
        }
        modifiedTutorMoves = species_data.tutor_moves
        modifiedTutorMoves.map! { |moveSym|
          next moveSym == oldMoveInternalName ? newMoveInternalName : oldMoveInternalName
        }
        modifiedEggMoves = species_data.egg_moves
        modifiedEggMoves.map! { |moveSym|
          next moveSym == oldMoveInternalName ? newMoveInternalName : oldMoveInternalName
        }
        
        new_species_hash = {
          :id                    => species_data.id,
          :id_number             => species_data.id_number,
          :name                  => species_data.name,
		      :form					         => species_data.form,
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
          :moves                 => modifiedLevelUpMoves,
          :tutor_moves           => modifiedTutorMoves,
          :egg_moves             => modifiedEggMoves,
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
        GameData::Species.DATA.delete(species_data_.id)
        GameData::Species.DATA.delete(species_data_.id_number)
        GameData::Species.register(new_species_hash)
        GameData::Species.save
      end
      Compiler.write_pokemon
      Compiler.write_pokemon_forms

      pbMessage("Move successfully renamed!")

      # Compiler.write_trainers
      break
    end
  }
})