DebugMenuCommands.register("renamemovefrominput", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Rename Move From Input"),
  "description" => _INTL("Rename an existing move in moves, species, forms, and trainers PBS files based on user input."),
  "effect"      => proc {
    while true
      oldMoveInternalName = pbEnterText(_INTL("Enter move internal name."),0,20)
      break if oldMoveInternalName == ""
      newMoveInternalName = pbEnterText(_INTL("Enter the move's new internal name."),0,20)
      break if newMoveInternalName == ""
      newMoveInternalName = newMoveInternalName.gsub(" ","").upcase
      newMoveDisplayName = pbEnterText(_INTL("Enter the move's new display name."),0,20)
      break if newMoveDisplayName == ""

      renameMoves({oldMoveInternalName => [newMoveInternalName,newMoveDisplayName]})

      Compiler.write_moves

      echoln("Compiling species data")
      Compiler.write_pokemon
      Compiler.write_pokemon_forms

      echoln("Compiling trainer data")
      Compiler.write_trainers

      echoln("Compiling avatar data")
      Compiler.write_avatars

      pbMessage("Rename completed.")
      break
    end
  }
})

DebugMenuCommands.register("renamemovefromfile", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Rename Moves From File"),
  "description" => _INTL("Rename an existing move in moves, species, forms, and trainers PBS files based on PBS/move_renames.txt."),
  "effect"      => proc {
    begin
      renamingHash = getRenamedMovesBatch()
      
      renameMoves(renamingHash)

      Compiler.write_moves

      echoln("Compiling species data")
      Compiler.write_pokemon
      Compiler.write_pokemon_forms

      echoln("Compiling trainer data")
      Compiler.write_trainers

      echoln("Compiling avatar data")
      Compiler.write_avatars
      pbMessage("Mass rename completed.")

      pbMessage("Create a new move rename save conversion, and rename \"move_renames.txt\" to \"move_renames_{X}.txt\"" +
        " where {X} is the next highest number of all files you see (e.g." +
        " If you see a \"move_renames_2.txt\", rename yours to \"move_renames_3\".txt)")
      pbMessage("Or tell a programmer to do it for you :)")
    rescue
      pbMessage("Some sort of error has occured.")
    end
  }
})

def getRenamedMovesBatch(version = -1)
  renamingHash = {}
  if version != -1
    filename = "PBS/move_renames_#{version}.txt"
  else
    filename = "PBS/move_renames.txt"
  end
  File.open(filename,"rb") { |f|
    FileLineData.file = filename
    lineno = 1
    f.each_line { |line|
      if lineno==1 && line[0].ord==0xEF && line[1].ord==0xBB && line[2].ord==0xBF
        line = line[3,line.length-3]
      end
      line.sub!(/\s*\#.*$/,"")
      line.sub!(/^\s+/,"")
      line.sub!(/\s+$/,"")
      if !line[/^\#/] && !line[/^\s*$/]
        FileLineData.setLine(line,lineno)
        line_items = line.split(",")
        renamingHash[line_items[0]] = [line_items[1],line_items[2]]
      end
      lineno += 1
    }
  }
  return renamingHash
end

def renameMoves(renamingHash)
  renamingHash.delete_if { |key,value|
    oldMoveData = nil
    begin
      oldMoveData = GameData::Move.get(key.to_sym)
    rescue => exception
      # Nothing
    end
    if oldMoveData.nil?
      echoln("No move with the internal name #{key} was found.")
      next true
    end
    if !value[0][/^(?![0-9])\w+$/]
      echoln("New internal name #{value[0]} must contain only letters, digits, and underscores and can't begin with a number.")
    end
    next false
  }

  # Construct move hash
  renamingHash.each do |oldMoveName,newMoveNames|
    oldMoveData = GameData::Move.get(oldMoveName.to_sym)
    move_hash = {
      :id_number     => oldMoveData.id_number,
      :id            => newMoveNames[0],
      :name          => newMoveNames[1],
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
  end

  GameData::Species.each do |species_data|
    changed = false
    modifiedLevelUpMoves = species_data.moves
    modifiedLevelUpMoves.map! { |moveEntry|
      moveName = moveEntry[1].to_s
      if renamingHash.has_key?(moveName)
        changed = true
        next [moveEntry[0], renamingHash[moveName][0].to_sym]
      else
        next moveEntry
      end
    }
    modifiedTutorMoves = species_data.tutor_moves
    modifiedTutorMoves.map! { |moveSym|
      moveName = moveSym.to_s
      if renamingHash.has_key?(moveName)
        changed = true
        next renamingHash[moveName][0].to_sym
      else
        next moveSym
      end
    }
    modifiedEggMoves = species_data.egg_moves
    modifiedEggMoves.map! { |moveSym|
      moveName = moveSym.to_s
      if renamingHash.has_key?(moveName)
        changed = true
        next renamingHash[moveName][0].to_sym
      else
        next moveSym
      end
    }

    if !changed
      next
    else
      echoln("Modifying #{species_data.real_name}")
    end
    
    if species_data.form == 0
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
    else
      base_data = GameData::Species.get(species_data.species)
      new_species_hash = {
        :species               => base_data.species,
        :id                    => species_data.id,
        :id_number             => species_data.id_number,
        :name                  => species_data.name,
        :form					         => species_data.form,
        :form_name             => species_data.form_name,
        :category              => species_data.category || base_data.category,
        :pokedex_entry         => species_data.pokedex_entry || base_data.pokedex_entry,
        :type1                 => species_data.type1 || base_data.type1,
        :type2                 => species_data.type2 || base_data.type2,
        :base_stats            => species_data.base_stats || base_data.base_stats,
        :evs                   => species_data.evs || base_data.evs,
        :base_exp              => species_data.base_exp || base_data.base_exp,
        :growth_rate           => species_data.growth_rate || base_data.growth_rate,
        :gender_ratio          => species_data.gender_ratio || base_data.gender_ratio,
        :catch_rate            => species_data.catch_rate || base_data.catch_rate,
        :happiness             => species_data.happiness || base_data.happiness,
        :moves                 => modifiedLevelUpMoves,
        :tutor_moves           => modifiedTutorMoves,
        :egg_moves             => modifiedEggMoves,
        :abilities             => species_data.abilities || base_data.abilities,
        :hidden_abilities      => species_data.hidden_abilities || base_data.hidden_abilities,
        :wild_item_common      => species_data.wild_item_common || base_data.wild_item_common,
        :wild_item_uncommon    => species_data.wild_item_uncommon || base_data.wild_item_uncommon,
        :wild_item_rare        => species_data.wild_item_rare || base_data.wild_item_rare,
        :egg_groups            => species_data.egg_groups || base_data.egg_groups,
        :hatch_steps           => species_data.hatch_steps || base_data.hatch_steps,
        :incense               => species_data.incense || base_data.incense,
        :evolutions            => species_data.evolutions || base_data.evolutions,
        :height                => species_data.height || base_data.height,
        :weight                => species_data.weight || base_data.weight,
        :color                 => species_data.color || base_data.color,
        :shape                 => species_data.shape || base_data.shape,
        :habitat               => species_data.habitat || base_data.habitat,
        :generation            => species_data.generation || base_data.generation,
        :back_sprite_x         => species_data.back_sprite_x || base_data.back_sprite_x,
        :back_sprite_y         => species_data.back_sprite_y || base_data.back_sprite_y,
        :front_sprite_x        => species_data.front_sprite_x || base_data.front_sprite_x,
        :front_sprite_y        => species_data.front_sprite_y || base_data.front_sprite_y,
        :front_sprite_altitude => species_data.front_sprite_altitude || base_data.front_sprite_altitude,
        :shadow_x              => species_data.shadow_x || base_data.shadow_x,
        :shadow_size           => species_data.shadow_size || base_data.shadow_size,
        :mega_stone            => species_data.mega_stone,
        :mega_move             => species_data.mega_move,
        :unmega_form           => species_data.unmega_form,
        :mega_message          => species_data.mega_message,
      }
    end
    GameData::Species::DATA.delete(species_data.id)
    GameData::Species::DATA.delete(species_data.id_number)
    GameData::Species.register(new_species_hash)
    GameData::Species.save
  end

  GameData::Trainer.each do |trainer_data|
    new_pokemon = trainer_data.pokemon.clone
    new_pokemon.each do |party_member|
      next if party_member[:moves].nil? || party_member[:moves].length == 0
      party_member[:moves].map! { |move|
        if renamingHash.has_key?(move.to_s)
          next renamingHash[move.to_s][0].to_sym
        else
          next move
        end
      }
    end
    new_trainer_hash = {
      :id_number    => trainer_data.id_number,
      :trainer_type => trainer_data.trainer_type,
      :name         => trainer_data.name,
      :version      => trainer_data.version,
      :pokemon      => new_pokemon
    }
    GameData::Trainer.register(new_trainer_hash)

    # Save all data
    GameData::Trainer.save
  end

  GameData::Avatar.each do |avatar_data|
    newMoves1 = avatar_data.moves1.map { |move|
      if renamingHash.has_key?(move.to_s)
        next renamingHash[move.to_s][0].to_sym
      else
        next move
      end
    }
    newMoves2 = avatar_data.moves2.map { |move|
      if renamingHash.has_key?(move.to_s)
        next renamingHash[move.to_s][0].to_sym
      else
        next move
      end
    }
    newMoves3 = avatar_data.moves3.map { |move|
      if renamingHash.has_key?(move.to_s)
        next renamingHash[move.to_s][0].to_sym
      else
        next move
      end
    }
    new_avatar_hash = {
      :id          		    => avatar_data.id,
      :id_number   		    => avatar_data.id_number,
      :turns		 		      => avatar_data.num_turns,
      :form		 		        => avatar_data.form,
      :moves1		 		      => newMoves1,
      :moves2		 		      => newMoves2,
      :moves3		 		      => newMoves3,
      :ability	 		      => avatar_data.ability,
      :item		 		        => avatar_data.item,
      :hp_mult	 		      => avatar_data.hp_mult,
      :dmg_mult			      => avatar_data.dmg_mult,
      :size_mult	 		    => avatar_data.size_mult,
    }
    GameData::Avatar::DATA.delete(avatar_data.id)
    GameData::Avatar::DATA.delete(avatar_data.id_number)
    GameData::Avatar.register(new_avatar_hash)

    # Save all data
    GameData::Avatar.save
  end
end