module Compiler
	module_function
	
  def main
    return if !$DEBUG
    begin
      dataFiles = [
         "berry_plants.dat",
         "encounters.dat",
         "form2species.dat",
         "items.dat",
         "map_connections.dat",
         "metadata.dat",
         "moves.dat",
         "phone.dat",
         "regional_dexes.dat",
         "ribbons.dat",
         "shadow_movesets.dat",
         "species.dat",
         "species_eggmoves.dat",
         "species_evolutions.dat",
         "species_metrics.dat",
         "species_movesets.dat",
         "species_old.dat",
         "tm.dat",
         "town_map.dat",
         "trainer_lists.dat",
         "trainer_types.dat",
         "trainers.dat",
         "types.dat",
         "policies.dat",
         "avatars.dat"
      ]
      textFiles = [
         "abilities.txt",
         "berryplants.txt",
         "connections.txt",
         "encounters.txt",
         "items.txt",
         "metadata.txt",
         "moves.txt",
         "phone.txt",
         "pokemon.txt",
		     "pokemon_old.txt",
         "pokemonforms.txt",
         "regionaldexes.txt",
         "ribbons.txt",
         "shadowmoves.txt",
         "townmap.txt",
         "trainerlists.txt",
         "trainers.txt",
         "trainertypes.txt",
         "types.txt",
		     "policies.txt",
		     "avatars.txt"
      ]
      latestDataTime = 0
      latestTextTime = 0
      mustCompile = false
      # Should recompile if new maps were imported
      mustCompile |= import_new_maps
      # If no PBS file, create one and fill it, then recompile
      if !safeIsDirectory?("PBS")
        Dir.mkdir("PBS") rescue nil
        write_all
        mustCompile = true
      end

      # Check data files and PBS files, and recompile if any PBS file was edited
      # more recently than the data files were last created
      dataFiles.each do |filename|
        next if !safeExists?("Data/" + filename)
        begin
          File.open("Data/#{filename}") { |file|
            latestDataTime = [latestDataTime, file.mtime.to_i].max
          }
        rescue SystemCallError
          mustCompile = true
        end
      end
      textFiles.each do |filename|
        next if !safeExists?("PBS/" + filename)
        begin
          File.open("PBS/#{filename}") { |file|
            latestTextTime = [latestTextTime, file.mtime.to_i].max
          }
        rescue SystemCallError
        end
      end
      MessageTypes.loadMessageFile("Data/messages.dat")
      if !mustCompile && latestTextTime >= latestDataTime
        echoln("!!!!!At least one PBS file is younger than your .rxdata compiled files!!!!!")
      end

      # Should recompile if holding Ctrl
      Input.update
      mustCompile = true if Input.press?(Input::CTRL) || ARGV.include?("compile")
      
      # Delete old data files in preparation for recompiling
      if mustCompile
        for i in 0...dataFiles.length
          begin
            File.delete("Data/#{dataFiles[i]}") if safeExists?("Data/#{dataFiles[i]}")
            rescue SystemCallError
          end
        end
      end
      # Recompile all data
      compile_all(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
    rescue Exception
      e = $!
      raise e if "#{e.class}"=="Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
      pbPrintException(e)
      for i in 0...dataFiles.length
        begin
          File.delete("Data/#{dataFiles[i]}")
        rescue SystemCallError
        end
      end
      raise Reset.new if e.is_a?(Hangup)
      loop do
        Graphics.update
      end
    end
  end
	
  #=============================================================================
  # Compile all data
  #=============================================================================
  def compile_all(mustCompile)
    FileLineData.clear
    if (!$INEDITOR || Settings::LANGUAGES.length < 2) && safeExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
    if mustCompile
      echoln _INTL("*** Starting full compile ***")
      echoln ""
      yield(_INTL("Compiling town map data"))
      compile_town_map               # No dependencies
      yield(_INTL("Compiling map connection data"))
      compile_connections            # No dependencies
      yield(_INTL("Compiling phone data"))
      compile_phone
      yield(_INTL("Compiling type data"))
      compile_types                  # No dependencies
      yield(_INTL("Compiling ability data"))
      compile_abilities              # No dependencies
      yield(_INTL("Compiling move data"))
      compile_moves                  # Depends on Type
      yield(_INTL("Compiling item data"))
      compile_items                  # Depends on Move
      yield(_INTL("Compiling berry plant data"))
      compile_berry_plants           # Depends on Item
      yield(_INTL("Compiling Pokémon data"))
      compile_pokemon                # Depends on Move, Item, Type, Ability
      yield(_INTL("Compiling Pokémon forms data"))
      compile_pokemon_forms          # Depends on Species, Move, Item, Type, Ability
      yield(_INTL("Compiling Old Pokémon data"))
      compile_pokemon_old                # Depends on Move, Item, Type, Ability
	    yield(_INTL("Compiling machine data"))
      compile_move_compatibilities   # Depends on Species, Move
      yield(_INTL("Compiling signature metadata"))
      compile_signature_metadata
      yield(_INTL("Compiling shadow moveset data"))
      compile_shadow_movesets        # Depends on Species, Move
      yield(_INTL("Compiling Regional Dexes"))
      compile_regional_dexes         # Depends on Species
      yield(_INTL("Compiling ribbon data"))
      compile_ribbons                # No dependencies
      yield(_INTL("Compiling encounter data"))
      compile_encounters             # Depends on Species
	    yield(_INTL("Compiling Trainer policy data"))
	    compile_trainer_policies
      yield(_INTL("Compiling Trainer type data"))
      compile_trainer_types          # No dependencies
      yield(_INTL("Compiling Trainer data"))
      compile_trainers               # Depends on Species, Item, Move
      yield(_INTL("Compiling battle Trainer data"))
      compile_trainer_lists          # Depends on TrainerType
	    yield(_INTL("Compiling Avatar battle data"))
	    compile_avatars				 # Depends on Species, Item, Move
      yield(_INTL("Compiling metadata"))
      compile_metadata               # Depends on TrainerType
      yield(_INTL("Compiling animations"))
      compile_animations
      yield(_INTL("Converting events"))
      compile_events
      yield(_INTL("Editing maps"))
      edit_maps
      yield(_INTL("Saving messages"))
      pbSetTextMessages
      MessageTypes.saveMessages
      echoln ""
      echoln _INTL("*** Finished full compile ***")
      echoln ""
      System.reload_cache

      write_all if ARGV.include?("compile") || pbConfirmMessageSerious(_INTL("\\ts[]Would you like to rewrite the PBS files from the compiled data?"))
    end
    pbSetWindowText(nil)
  end
  
  #=============================================================================
  # Compile Pokémon data
  #=============================================================================
  def compile_pokemon_old(path = "PBS/pokemon_old.txt")
    GameData::SpeciesOld::DATA.clear
    species_names           = []
    species_form_names      = []
    species_categories      = []
    species_pokedex_entries = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::SpeciesOld.schema
      pbEachFileSection(f) { |contents, species_number|
        FileLineData.setSection(species_number, "header", nil)   # For error reporting
        # Raise an error if a species number is invalid or used twice
        if species_number == 0
          raise _INTL("A Pokémon species can't be numbered 0 ({1}).", path)
        elsif GameData::SpeciesOld::DATA[species_number]
          raise _INTL("Species ID number '{1}' is used twice.\r\n{2}", species_number, FileLineData.linereport)
        end
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          # Skip empty properties, or raise an error if a required property is
          # empty
          if nil_or_empty?(contents[key])
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, species_number)
            end
            contents[key] = nil
            next
          end
          # Raise an error if a species internal name is used twice
          FileLineData.setSection(species_number, key, contents[key])   # For error reporting
          if GameData::SpeciesOld::DATA[contents["InternalName"].to_sym]
            raise _INTL("Species ID '{1}' is used twice.\r\n{2}", contents["InternalName"], FileLineData.linereport)
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Sanitise data
          case key
          when "BaseStats", "EffortPoints"
            value_hash = {}
            GameData::Stat.each_main do |s|
              value_hash[s.id] = value[s.pbs_order] if s.pbs_order >= 0
            end
            contents[key] = value_hash
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, {3})", key, species_number, path)
            end
            contents[key] = value
          when "Moves"
            move_array = []
            for i in 0...value.length / 2
              move_array.push([value[i * 2], value[i * 2 + 1], i])
            end
            move_array.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=>b [0] }
            move_array.each { |arr| arr.pop }
            contents[key] = move_array
          when "TutorMoves", "EggMoves", "Abilities", "HiddenAbility", "Compatibility"
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].compact!
          when "Evolutions"
            evo_array = []
            for i in 0...value.length / 3
              evo_array.push([value[i * 3], value[i * 3 + 1], value[i * 3 + 2], false])
            end
            contents[key] = evo_array
          end
        end
        # Construct species hash
        species_symbol = contents["InternalName"].to_sym
        species_hash = {
          :id                    => species_symbol,
          :id_number             => species_number,
          :name                  => contents["Name"],
          :form_name             => contents["FormName"],
          :category              => contents["Kind"],
          :pokedex_entry         => contents["Pokedex"],
          :type1                 => contents["Type1"],
          :type2                 => contents["Type2"],
          :base_stats            => contents["BaseStats"],
          :evs                   => contents["EffortPoints"],
          :base_exp              => contents["BaseEXP"],
          :growth_rate           => contents["GrowthRate"],
          :gender_ratio          => contents["GenderRate"],
          :catch_rate            => contents["Rareness"],
          :happiness             => contents["Happiness"],
          :moves                 => contents["Moves"],
          :tutor_moves           => contents["TutorMoves"],
          :egg_moves             => contents["EggMoves"],
          :abilities             => contents["Abilities"],
          :hidden_abilities      => contents["HiddenAbility"],
          :wild_item_common      => contents["WildItemCommon"],
          :wild_item_uncommon    => contents["WildItemUncommon"],
          :wild_item_rare        => contents["WildItemRare"],
          :egg_groups            => contents["Compatibility"],
          :hatch_steps           => contents["StepsToHatch"],
          :incense               => contents["Incense"],
          :evolutions            => contents["Evolutions"],
          :height                => contents["Height"],
          :weight                => contents["Weight"],
          :color                 => contents["Color"],
          :shape                 => GameData::BodyShape.get(contents["Shape"]).id,
          :habitat               => contents["Habitat"],
          :generation            => contents["Generation"],
          :back_sprite_x         => contents["BattlerPlayerX"],
          :back_sprite_y         => contents["BattlerPlayerY"],
          :front_sprite_x        => contents["BattlerEnemyX"],
          :front_sprite_y        => contents["BattlerEnemyY"],
          :front_sprite_altitude => contents["BattlerAltitude"],
          :shadow_x              => contents["BattlerShadowX"],
          :shadow_size           => contents["BattlerShadowSize"],
          :notes                 => contents["Notes"]
        }
        # Add species' data to records
        GameData::SpeciesOld.register(species_hash)
        species_names[species_number]           = species_hash[:name]
        species_form_names[species_number]      = species_hash[:form_name]
        species_categories[species_number]      = species_hash[:category]
        species_pokedex_entries[species_number] = species_hash[:pokedex_entry]
      }
    }
    # Enumerate all evolution species and parameters (this couldn't be done earlier)
    GameData::SpeciesOld.each do |species|
      FileLineData.setSection(species.id_number, "Evolutions", nil)   # For error reporting
      Graphics.update if species.id_number % 200 == 0
      pbSetWindowText(_INTL("Processing {1} evolution line {2}", FileLineData.file, species.id_number)) if species.id_number % 50 == 0
      species.evolutions.each do |evo|
        evo[0] = csvEnumField!(evo[0], :Species, "Evolutions", species.id_number)
        param_type = GameData::Evolution.get(evo[1]).parameter
        if param_type.nil?
          evo[2] = nil
        elsif param_type == Integer
          evo[2] = csvPosInt!(evo[2])
        else
          evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", species.id_number)
        end
      end
    end
    # Add prevolution "evolution" entry for all evolved species
    all_evos = {}
    GameData::SpeciesOld.each do |species|   # Build a hash of prevolutions for each species
      species.evolutions.each do |evo|
        all_evos[evo[0]] = [species.species, evo[1], evo[2], true] if !all_evos[evo[0]]
      end
    end
    GameData::SpeciesOld.each do |species|   # Distribute prevolutions
      species.evolutions.push(all_evos[species.species].clone) if all_evos[species.species]
    end
    # Save all data
    GameData::SpeciesOld.save
    Graphics.update
  end
  
  def compile_trainer_policies(path = "PBS/policies.txt")
	GameData::Policy::DATA.clear
    # Read each line of policies.txt at a time and compile it into a trainer type
    pbCompilerEachCommentedLine(path) { |line, line_no|
	  line = pbGetCsvRecord(line, line_no, [0, "*n"])
      policy_symbol = line[0].to_sym
      if GameData::Policy::DATA[policy_symbol]
        raise _INTL("Trainer policy ID '{1}' is used twice.\r\n{2}", policy_symbol, FileLineData.linereport)
      end
      # Construct trainer type hash
      policy_hash = {
        :id          => policy_symbol,
      }
      # Add trainer policy's data to records
      GameData::Policy.register(policy_hash)
    }
    # Save all data
    GameData::Policy.save
    Graphics.update
  end
  
  def pbEachAvatarFileSection(f)
    pbEachFileSectionEx(f) { |section,name|
        yield section,name if block_given? && name[/^[a-zA-Z0-9_]+$/]
    }
  end
  
  def compile_avatars(path = "PBS/avatars.txt")
	  GameData::Avatar::DATA.clear
    # Read from PBS file
    File.open("PBS/avatars.txt", "rb") { |f|
		FileLineData.file = "PBS/avatars.txt"   # For error reporting
		# Read a whole section's lines at once, then run through this code.
		# contents is a hash containing all the XXX=YYY lines in that section, where
		# the keys are the XXX and the values are the YYY (as unprocessed strings).
		schema = GameData::Avatar::SCHEMA
		avatar_number = 1
		pbEachAvatarFileSection(f) { |contents, avatar_species|
			FileLineData.setSection(avatar_species, "header", nil)   # For error reporting
			avatar_symbol = avatar_species.to_sym
			
			# Raise an error if a species is invalid or used twice
			if avatar_species == ""
			  raise _INTL("An Avatar entry name can't be blank (PBS/avatars.txt).")
			elsif !GameData::Avatar::DATA[avatar_symbol].nil?
			  raise _INTL("Avatar name '{1}' is used twice.\r\n{2}", avatar_species, FileLineData.linereport)
			end

      speciesData = GameData::Species.get_species_form(avatar_species,contents["Form"].to_i || 0)
			
			# Go through schema hash of compilable data and compile this section
			for key in schema.keys
				# Skip empty properties, or raise an error if a required property is
				# empty
				if contents[key].nil? || contents[key] == ""
					if ["Ability", "Moves1"].include?(key)
						raise _INTL("The entry {1} is required in PBS/avatars.txt section {2}.", key, avatar_species)
					end
					contents[key] = nil
					next
				end

				# Compile value for key
				value = pbGetCsvRecord(contents[key], key, schema[key])
				value = nil if value.is_a?(Array) && value.length == 0
				contents[key] = value
			  
			    # Sanitise data
				case key
				when "Moves1"
					if contents["Moves1"].length > 4
						raise _INTL("The {1} entry has too many moves in PBS/avatars.txt section {2}.", key, avatar_species)
					end
        when "Moves2"
					if contents["Moves2"].length > 4
						raise _INTL("The {1} entry has too many moves in PBS/avatars.txt section {2}.", key, avatar_species)
					end
        when "Moves3"
					if contents["Moves3"].length > 4
						raise _INTL("The {1} entry has too many moves in PBS/avatars.txt section {2}.", key, avatar_species)
					end
        when "Ability"
          if !speciesData.abilities.concat(speciesData.hidden_abilities).include?(contents["Ability"].to_sym)
            echoln(_INTL("Ability {1} is not legal for the Avatar defined in PBS/avatars.txt section {2}.", contents["Ability"], avatar_species))
          end
				end
			end
			
			# Construct avatar hash
			avatar_hash = {
				:id          		    => avatar_symbol,
				:id_number   		    => avatar_number,
				:turns		 		      => contents["Turns"],
				:form		 		        => contents["Form"],
				:moves1		 		      => contents["Moves1"],
        :moves2		 		      => contents["Moves2"],
        :moves3		 		      => contents["Moves3"],
        :moves4		 		      => contents["Moves4"],
        :moves5		 		      => contents["Moves5"],
				:ability	 		      => contents["Ability"],
				:item		 		        => contents["Item"],
				:hp_mult	 		      => contents["HPMult"],
        :size_mult	 		    => contents["SizeMult"],
				:dmg_mult			      => contents["DMGMult"],
        :dmg_resist			    => contents["DMGResist"],
				:health_bars	 		  => contents["HealthBars"],
			}
			avatar_number += 1
			# Add trainer avatar's data to records
			GameData::Avatar.register(avatar_hash)
		}
    }

    # Save all data
    GameData::Avatar.save
    Graphics.update
  end 
  
  #=============================================================================
  # Compile metadata
  #=============================================================================
  def compile_metadata(path = "PBS/metadata.txt")
    GameData::Metadata::DATA.clear
    GameData::MapMetadata::DATA.clear
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      pbEachFileSection(f) { |contents, map_id|
        schema = (map_id == 0) ? GameData::Metadata::SCHEMA : GameData::MapMetadata::SCHEMA
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          FileLineData.setSection(map_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if map_id == 0 && ["Home", "PlayerA"].include?(key)
              raise _INTL("The entry {1} is required in {2} section 0.", key, path)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
        end
        if map_id == 0   # Global metadata
          # Construct metadata hash
          metadata_hash = {
            :id                 			=> map_id,
            :home               			=> contents["Home"],
            :wild_battle_BGM    			=> contents["WildBattleBGM"],
            :trainer_battle_BGM 			=> contents["TrainerBattleBGM"],
			      :avatar_battle_BGM 				=> contents["AvatarBattleBGM"],
			      :legendary_avatar_battle_BGM 	=> contents["LegendaryAvatarBattleBGM"],
            :wild_victory_ME    			=> contents["WildVictoryME"],
            :trainer_victory_ME 			=> contents["TrainerVictoryME"],
            :wild_capture_ME    			=> contents["WildCaptureME"],
            :surf_BGM           			=> contents["SurfBGM"],
            :bicycle_BGM        			=> contents["BicycleBGM"],
            :player_A           			=> contents["PlayerA"],
            :player_B           			=> contents["PlayerB"],
            :player_C           			=> contents["PlayerC"],
            :player_D           			=> contents["PlayerD"],
            :player_E           			=> contents["PlayerE"],
            :player_F           			=> contents["PlayerF"],
            :player_G           			=> contents["PlayerG"],
            :player_H           			=> contents["PlayerH"]
          }
          # Add metadata's data to records
          GameData::Metadata.register(metadata_hash)
        else   # Map metadata
          # Construct metadata hash
          metadata_hash = {
            :id                   => map_id,
            :outdoor_map          => contents["Outdoor"],
            :announce_location    => contents["ShowArea"],
            :can_bicycle          => contents["Bicycle"],
            :always_bicycle       => contents["BicycleAlways"],
            :teleport_destination => contents["HealingSpot"],
            :weather              => contents["Weather"],
            :town_map_position    => contents["MapPosition"],
            :dive_map_id          => contents["DiveMap"],
            :dark_map             => contents["DarkMap"],
            :safari_map           => contents["SafariMap"],
            :snap_edges           => contents["SnapEdges"],
            :random_dungeon       => contents["Dungeon"],
            :battle_background    => contents["BattleBack"],
            :wild_battle_BGM      => contents["WildBattleBGM"],
            :trainer_battle_BGM   => contents["TrainerBattleBGM"],
            :wild_victory_ME      => contents["WildVictoryME"],
            :trainer_victory_ME   => contents["TrainerVictoryME"],
            :wild_capture_ME      => contents["WildCaptureME"],
            :town_map_size        => contents["MapSize"],
            :battle_environment   => contents["Environment"],
            :teleport_blocked     => contents["TeleportBlocked"],
          }
          # Add metadata's data to records
          GameData::MapMetadata.register(metadata_hash)
        end
      }
    }
    # Save all data
    GameData::Metadata.save
    GameData::MapMetadata.save
    Graphics.update
  end


=begin
#THIS IS TO BE BTAVATAR COMPILER CODE
 def compile_btavatars(path = "PBS/btavatars.txt")
	GameData::Avatar::DATA.clear
    # Read from PBS file
    File.open("PBS/btavatars.txt", "rb") { |f|
		FileLineData.file = "PBS/btavatars.txt"   # For error reporting
		# Read a whole section's lines at once, then run through this code.
		# contents is a hash containing all the XXX=YYY lines in that section, where
		# the keys are the XXX and the values are the YYY (as unprocessed strings).
		schema = GameData::Avatar::SCHEMA
		avatar_number = 1
		pbEachAvatarFileSection(f) { |contents, avatar_species|
			FileLineData.setSection(avatar_species, "header", nil)   # For error reporting
			avatar_symbol = avatar_species.to_sym
			
			# Raise an error if a species is invalid or used twice
			if avatar_species == ""
			  raise _INTL("An Avatar entry name can't be blank (PBS/avatars.txt).")
			elsif GameData::Avatar::DATA[avatar_symbol]
			  raise _INTL("Avatar name '{1}' is used twice.\r\n{2}", avatar_species, FileLineData.linereport)
			end
			
			# Go through schema hash of compilable data and compile this section
			for key in schema.keys
				# Skip empty properties, or raise an error if a required property is
				# empty
				if contents[key].nil? || contents[key] == ""
					if ["Turns", "Ability", "Moves", "HPMult"].include?(key)
						raise _INTL("The entry {1} is required in PBS/avatars.txt section {2}.", key, avatar_species)
					end
					contents[key] = nil
					next
				end

				# Compile value for key
				value = pbGetCsvRecord(contents[key], key, schema[key])
				value = nil if value.is_a?(Array) && value.length == 0
				contents[key] = value
			  
			    # Sanitise data
				case key
				when "Moves"
					if contents["Moves"].length > 4
						raise _INTL("The moves entry has too many moves in PBS/avatars.txt section {2}.", key, avatar_species)
					end
				end
			end
			
			# Construct avatar hash
			avatar_hash = {
				:id          => avatar_symbol,
				:id_number   => avatar_number,
				:turns		 => contents["Turns"],
				:form		 => contents["Form"],
				:moves		 => contents["Moves"],
				:ability	 => contents["Ability"],
				:item		 => contents["Item"],
				:hp_mult	 => contents["HPMult"],
				:dmg_mult	 => contents["DMGMult"],
				:size_mult	 => contents["SizeMult"],
			}
			avatar_number += 1
			# Add trainer avatar's data to records
			GameData::Avatar.register(avatar_hash)
		}
    }

    # Save all data
    GameData::Avatar.save
    Graphics.update
  end
end
=end
  #=============================================================================
  # Compile trainer type data
  #=============================================================================
  def compile_trainer_types(path = "PBS/trainertypes.txt")
    GameData::TrainerType::DATA.clear
    tr_type_names = []
    # Read each line of trainertypes.txt at a time and compile it into a trainer type
    pbCompilerEachCommentedLine(path) { |line, line_no|
      line = pbGetCsvRecord(line, line_no, [0, "unsUSSSeUSs",
        nil, nil, nil, nil, nil, nil, nil, {
        "Male"   => 0, "M" => 0, "0" => 0,
        "Female" => 1, "F" => 1, "1" => 1,
        "Mixed"  => 2, "X" => 2, "2" => 2, "" => 2,
        "Wild"   => 3, "W" => 3, "3" => 3
        }, nil, nil, nil]
      )
      type_number = line[0]
      type_symbol = line[1].to_sym
      if GameData::TrainerType::DATA[type_number]
        raise _INTL("Trainer type ID number '{1}' is used twice.\r\n{2}", type_number, FileLineData.linereport)
      elsif GameData::TrainerType::DATA[type_symbol]
        raise _INTL("Trainer type ID '{1}' is used twice.\r\n{2}", type_symbol, FileLineData.linereport)
      end
      policies_array = []
      if !line[10].nil?
        policies_string_array = line[10].gsub!('[','').gsub!(']','').split(',')
        policies_string_array.each do |policy_string|
          policies_array.push(policy_string.to_sym)
          end
      end
      # Construct trainer type hash
      type_hash = {
        :id_number   => type_number,
        :id          => type_symbol,
        :name        => line[2],
        :base_money  => line[3],
        :battle_BGM  => line[4],
        :victory_ME  => line[5],
        :intro_ME    => line[6],
        :gender      => line[7],
        :skill_level => line[8],
        :skill_code  => line[9],
        :policies    => policies_array,
      }
      # Add trainer type's data to records
      GameData::TrainerType.register(type_hash)
      tr_type_names[type_number] = type_hash[:name]
    }
    # Save all data
    GameData::TrainerType.save
    MessageTypes.setMessages(MessageTypes::TrainerTypes, tr_type_names)
    Graphics.update
  end

  #=============================================================================
  # Compile Pokémon data
  #=============================================================================
  def compile_pokemon
    GameData::Species::DATA.clear
    species_names           = []
    species_form_names      = []
    species_categories      = []
    species_pokedex_entries = []
    # Read from PBS file
    File.open("PBS/pokemon.txt", "rb") { |f|
      FileLineData.file = "PBS/pokemon.txt"   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Species.schema
      pbEachFileSection(f) { |contents, species_number|
        FileLineData.setSection(species_number, "header", nil)   # For error reporting
        # Raise an error if a species number is invalid or used twice
        if species_number == 0
          raise _INTL("A Pokémon species can't be numbered 0 (PBS/pokemon.txt).")
        elsif GameData::Species::DATA[species_number]
          raise _INTL("Species ID number '{1}' is used twice.\r\n{2}", species_number, FileLineData.linereport)
        end
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil? || contents[key] == ""
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in PBS/pokemon.txt section {2}.", key, species_number)
            end
            contents[key] = nil
            next
          end
          # Raise an error if a species internal name is used twice
          FileLineData.setSection(species_number, key, contents[key])   # For error reporting
          if GameData::Species::DATA[contents["InternalName"].to_sym]
            raise _INTL("Species ID '{1}' is used twice.\r\n{2}", contents["InternalName"], FileLineData.linereport)
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Sanitise data
          case key
          when "BaseStats", "EffortPoints"
            value_hash = {}
            GameData::Stat.each_main do |s|
              value_hash[s.id] = value[s.pbs_order] if s.pbs_order >= 0
            end
            contents[key] = value_hash
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)", key, species_number)
            end
            contents[key] = value
          when "Moves"
            move_array = []
            for i in 0...value.length / 2
              move_array.push([value[i * 2], value[i * 2 + 1], i])
            end
            move_array.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=>b [0] }
            move_array.each { |arr| arr.pop }
            contents[key] = move_array
          when "TutorMoves", "EggMoves", "Abilities", "HiddenAbility", "Compatibility"
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].compact!
          when "Evolutions"
            evo_array = []
            for i in 0...value.length / 3
              evo_array.push([value[i * 3], value[i * 3 + 1], value[i * 3 + 2], false])
            end
            contents[key] = evo_array
          end
        end
        # Construct species hash
        species_symbol = contents["InternalName"].to_sym
        species_hash = {
          :id                    => species_symbol,
          :id_number             => species_number,
          :name                  => contents["Name"],
          :form_name             => contents["FormName"],
          :category              => contents["Kind"],
          :pokedex_entry         => contents["Pokedex"],
          :type1                 => contents["Type1"],
          :type2                 => contents["Type2"],
          :base_stats            => contents["BaseStats"],
          :evs                   => contents["EffortPoints"],
          :base_exp              => contents["BaseEXP"],
          :growth_rate           => contents["GrowthRate"],
          :gender_ratio          => contents["GenderRate"],
          :catch_rate            => contents["Rareness"],
          :happiness             => contents["Happiness"],
          :moves                 => contents["Moves"],
          :tutor_moves           => contents["TutorMoves"],
          :egg_moves             => contents["EggMoves"],
          :abilities             => contents["Abilities"],
          :hidden_abilities      => contents["HiddenAbility"],
          :wild_item_common      => contents["WildItemCommon"],
          :wild_item_uncommon    => contents["WildItemUncommon"],
          :wild_item_rare        => contents["WildItemRare"],
          :egg_groups            => contents["Compatibility"],
          :hatch_steps           => contents["StepsToHatch"],
          :incense               => contents["Incense"],
          :evolutions            => contents["Evolutions"],
          :height                => contents["Height"],
          :weight                => contents["Weight"],
          :color                 => contents["Color"],
          :shape                 => GameData::BodyShape.get(contents["Shape"]).id,
          :habitat               => contents["Habitat"],
          :generation            => contents["Generation"],
          :back_sprite_x         => contents["BattlerPlayerX"],
          :back_sprite_y         => contents["BattlerPlayerY"],
          :front_sprite_x        => contents["BattlerEnemyX"],
          :front_sprite_y        => contents["BattlerEnemyY"],
          :front_sprite_altitude => contents["BattlerAltitude"],
          :shadow_x              => contents["BattlerShadowX"],
          :shadow_size           => contents["BattlerShadowSize"],
          :notes                 => contents["Notes"]
        }
        # Add species' data to records
        GameData::Species.register(species_hash)
        species_names[species_number]           = species_hash[:name]
        species_form_names[species_number]      = species_hash[:form_name]
        species_categories[species_number]      = species_hash[:category]
        species_pokedex_entries[species_number] = species_hash[:pokedex_entry]
      }
    }
    # Enumerate all evolution species and parameters (this couldn't be done earlier)
    GameData::Species.each do |species|
      FileLineData.setSection(species.id_number, "Evolutions", nil)   # For error reporting
      Graphics.update if species.id_number % 200 == 0
      pbSetWindowText(_INTL("Processing {1} evolution line {2}", FileLineData.file, species.id_number)) if species.id_number % 50 == 0
      species.evolutions.each do |evo|
        evo[0] = csvEnumField!(evo[0], :Species, "Evolutions", species.id_number)
        param_type = GameData::Evolution.get(evo[1]).parameter
        if param_type.nil?
          evo[2] = nil
        elsif param_type == Integer
          evo[2] = csvPosInt!(evo[2])
        else
          evo[2] = csvEnumField!(evo[2], param_type, "Evolutions", species.id_number)
        end
      end
    end
    # Add prevolution "evolution" entry for all evolved species
    all_evos = {}
    GameData::Species.each do |species|   # Build a hash of prevolutions for each species
      #next if all_evos[species.species]
      species.evolutions.each do |evo|
        all_evos[evo[0]] = [species.species, evo[1], evo[2], true] #if !all_evos[evo[0]]
      end
    end
    GameData::Species.each do |species|   # Distribute prevolutions
      species.evolutions.push(all_evos[species.species].clone) if all_evos[species.species]
    end
	
    # Save all data
    GameData::Species.save
    MessageTypes.setMessages(MessageTypes::Species, species_names)
    MessageTypes.setMessages(MessageTypes::FormNames, species_form_names)
    MessageTypes.setMessages(MessageTypes::Kinds, species_categories)
    MessageTypes.setMessages(MessageTypes::Entries, species_pokedex_entries)
    Graphics.update
  end

  #=============================================================================
  # Compile Pokémon forms data
  #=============================================================================
  def compile_pokemon_forms(path = "PBS/pokemonforms.txt")
    species_names           = []
    species_form_names      = []
    species_categories      = []
    species_pokedex_entries = []
    used_forms = {}
    # Get maximum species ID number
    form_number = 0
    GameData::Species.each do |species|
      form_number = species.id_number if form_number < species.id_number
    end
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Species.schema(true)
      pbEachFileSection2(f) { |contents, section_name|
        FileLineData.setSection(section_name, "header", nil)   # For error reporting
        # Split section_name into a species number and form number
        split_section_name = section_name.split(/[-,\s]/)
        if split_section_name.length != 2
          raise _INTL("Section name {1} is invalid ({2}). Expected syntax like [XXX,Y] (XXX=internal name, Y=form number).", sectionName, path)
        end
        species_symbol = csvEnumField!(split_section_name[0], :Species, nil, nil)
        form           = csvPosInt!(split_section_name[1])
        # Raise an error if a species is undefined, the form number is invalid or
        # a species/form combo is used twice
        if !GameData::Species.exists?(species_symbol)
          raise _INTL("Species ID '{1}' is not defined in {2}.\r\n{3}", species_symbol, path, FileLineData.linereport)
        elsif form == 0
          raise _INTL("A form cannot be defined with a form number of 0.\r\n{1}", FileLineData.linereport)
        elsif used_forms[species_symbol] && used_forms[species_symbol].include?(form)
          raise _INTL("Form {1} for species ID {2} is defined twice.\r\n{3}", form, species_symbol, FileLineData.linereport)
        end
        used_forms[species_symbol] = [] if !used_forms[species_symbol]
        used_forms[species_symbol].push(form)
        form_number += 1
        base_data = GameData::Species.get(species_symbol)
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          # Skip empty properties (none are required)
          if nil_or_empty?(contents[key])
            contents[key] = nil
            next
          end
          FileLineData.setSection(section_name, key, contents[key])   # For error reporting
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Sanitise data
          case key
          when "BaseStats", "EffortPoints"
            value_hash = {}
            GameData::Stat.each_main do |s|
              value_hash[s.id] = value[s.pbs_order] if s.pbs_order >= 0
            end
            contents[key] = value_hash
          when "Height", "Weight"
            # Convert height/weight to 1 decimal place and multiply by 10
            value = (value * 10).round
            if value <= 0
              raise _INTL("Value for '{1}' can't be less than or close to 0 (section {2}, {3})", key, section_name, path)
            end
            contents[key] = value
          when "Moves"
            move_array = []
            for i in 0...value.length / 2
              move_array.push([value[i * 2], value[i * 2 + 1], i])
            end
            move_array.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=>b [0] }
            move_array.each { |arr| arr.pop }
            contents[key] = move_array
          when "TutorMoves", "EggMoves", "Abilities", "HiddenAbility", "Compatibility"
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].compact!
          when "Evolutions"
            evo_array = []
            for i in 0...value.length / 3
              param_type = GameData::Evolution.get(value[i * 3 + 1]).parameter
              param = value[i * 3 + 2]
              if param_type.nil?
                param = nil
              elsif param_type == Integer
                param = csvPosInt!(param)
              else
                param = csvEnumField!(param, param_type, "Evolutions", section_name)
              end
              evo_array.push([value[i * 3], value[i * 3 + 1], param, false])
            end
            contents[key] = evo_array
          end
        end
        # Construct species hash
        form_symbol = sprintf("%s_%d", species_symbol.to_s, form).to_sym
        moves = contents["Moves"]
        if !moves
          moves = []
          base_data.moves.each { |m| moves.push(m.clone) }
        end
        evolutions = contents["Evolutions"]
        if !evolutions
          evolutions = []
          base_data.evolutions.each { |e| evolutions.push(e.clone) }
        end
        species_hash = {
          :id                    => form_symbol,
          :id_number             => form_number,
          :species               => species_symbol,
          :form                  => form,
          :name                  => base_data.real_name,
          :form_name             => contents["FormName"],
          :category              => contents["Kind"] || base_data.real_category,
          :pokedex_entry         => contents["Pokedex"] || base_data.real_pokedex_entry,
          :pokedex_form          => contents["PokedexForm"],
          :type1                 => contents["Type1"] || base_data.type1,
          :type2                 => contents["Type2"] || base_data.type2,
          :base_stats            => contents["BaseStats"] || base_data.base_stats,
          :evs                   => contents["EffortPoints"] || base_data.evs,
          :base_exp              => contents["BaseEXP"] || base_data.base_exp,
          :growth_rate           => base_data.growth_rate,
          :gender_ratio          => base_data.gender_ratio,
          :catch_rate            => contents["Rareness"] || base_data.catch_rate,
          :happiness             => contents["Happiness"] || base_data.happiness,
          :moves                 => moves,
          :tutor_moves           => contents["TutorMoves"] || base_data.tutor_moves.clone,
          :egg_moves             => contents["EggMoves"] || base_data.egg_moves.clone,
          :abilities             => contents["Abilities"] || base_data.abilities.clone,
          :hidden_abilities      => contents["HiddenAbility"] || base_data.hidden_abilities.clone,
          :wild_item_common      => contents["WildItemCommon"] || base_data.wild_item_common,
          :wild_item_uncommon    => contents["WildItemUncommon"] || base_data.wild_item_uncommon,
          :wild_item_rare        => contents["WildItemRare"] || base_data.wild_item_rare,
          :egg_groups            => contents["Compatibility"] || base_data.egg_groups.clone,
          :hatch_steps           => contents["StepsToHatch"] || base_data.hatch_steps,
          :incense               => base_data.incense,
          :evolutions            => evolutions,
          :height                => contents["Height"] || base_data.height,
          :weight                => contents["Weight"] || base_data.weight,
          :color                 => contents["Color"] || base_data.color,
          :shape                 => (contents["Shape"]) ? GameData::BodyShape.get(contents["Shape"]).id : base_data.shape,
          :habitat               => contents["Habitat"] || base_data.habitat,
          :generation            => contents["Generation"] || base_data.generation,
          :mega_stone            => contents["MegaStone"],
          :mega_move             => contents["MegaMove"],
          :unmega_form           => contents["UnmegaForm"],
          :mega_message          => contents["MegaMessage"],
          :back_sprite_x         => contents["BattlerPlayerX"] || base_data.back_sprite_x,
          :back_sprite_y         => contents["BattlerPlayerY"] || base_data.back_sprite_y,
          :front_sprite_x        => contents["BattlerEnemyX"] || base_data.front_sprite_x,
          :front_sprite_y        => contents["BattlerEnemyY"] || base_data.front_sprite_y,
          :front_sprite_altitude => contents["BattlerAltitude"] || base_data.front_sprite_altitude,
          :shadow_x              => contents["BattlerShadowX"] || base_data.shadow_x,
          :shadow_size           => contents["BattlerShadowSize"] || base_data.shadow_size,
          :notes                 => contents["Notes"]
        }
        # If form is single-typed, ensure it remains so if base species is dual-typed
        species_hash[:type2] = contents["Type1"] if contents["Type1"] && !contents["Type2"]
        # If form has any wild items, ensure none are inherited from base species
        if contents["WildItemCommon"] || contents["WildItemUncommon"] || contents["WildItemRare"]
          species_hash[:wild_item_common]   = contents["WildItemCommon"]
          species_hash[:wild_item_uncommon] = contents["WildItemUncommon"]
          species_hash[:wild_item_rare]     = contents["WildItemRare"]
        end
        # Add form's data to records
        GameData::Species.register(species_hash)
        species_names[form_number]           = species_hash[:name]
        species_form_names[form_number]      = species_hash[:form_name]
        species_categories[form_number]      = species_hash[:category]
        species_pokedex_entries[form_number] = species_hash[:pokedex_entry]
      }
    }
    # Add prevolution "evolution" entry for all evolved forms that define their
    # own evolution methods (and thus won't have a prevolution listed already)
    all_evos = {}
    GameData::Species.each do |species|   # Build a hash of prevolutions for each species
      species.evolutions.each do |evo|
        all_evos[evo[0]] = [species.species, evo[1], evo[2], true] if !evo[3] && !all_evos[evo[0]]
      end
    end
    GameData::Species.each do |species|   # Distribute prevolutions
      next if species.form == 0   # Looking at alternate forms only
      next if species.evolutions.any? { |evo| evo[3] }   # Already has prevo listed
      species.evolutions.push(all_evos[species.species].clone) if all_evos[species.species]
    end
    # Save all data
    GameData::Species.save
    MessageTypes.addMessages(MessageTypes::Species, species_names)
    MessageTypes.addMessages(MessageTypes::FormNames, species_form_names)
    MessageTypes.addMessages(MessageTypes::Kinds, species_categories)
    MessageTypes.addMessages(MessageTypes::Entries, species_pokedex_entries)
    Graphics.update
  end

  
  #=============================================================================
  # Compile individual trainer data
  #=============================================================================
  def compile_trainers(path = "PBS/trainers.txt")
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names             = []
    trainer_lose_texts        = []
    trainer_hash              = nil
    trainer_id                = -1
    current_pkmn              = nil
    isExtending               = false
    # Read each line of trainers.txt at a time and compile it as a trainer property
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if !current_pkmn && !isExtending
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          # Add trainer's data to records
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        trainer_id += 1
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        # Construct trainer hash
        trainer_hash = {
          :id_number       => trainer_id,
          :trainer_type    => line_data[0],
          :name            => line_data[1],
          :version         => line_data[2] || 0,
          :pokemon         => [],
		      :policies		     => [],
          :extends         => -1,
          :removed_pokemon => [],
        }
        isExtending = false
        current_pkmn = nil
        trainer_names[trainer_id] = trainer_hash[:name]
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Error checking in XXX=YYY lines
        case property_name
        when "Items"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
        when "Pokemon","RemovePokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.uniq!
          property_value.compact!
        when "IV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |ev|
            next if ev <= Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          if COMBINE_ATTACKING_STATS
            atkIndex = GameData::Stat.get(:ATTACK).pbs_order
            spAtkIndex = GameData::Stat.get(:SPECIAL_ATTACK).pbs_order

            if property_value[atkIndex] != property_value[spAtkIndex]
              attackingStatsValue = [property_value[atkIndex],property_value[spAtkIndex]].max
              property_value[atkIndex] = attackingStatsValue
              property_value[spAtkIndex]
            end
          end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            next if s == :SPECIAL_ATTACK && COMBINE_ATTACKING_STATS
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        when "Position"
          if property_value < 0 || property_value >= Settings::MAX_PARTY_SIZE
            raise _INTL("Bad party position: {1} (must be 0-{2}).\r\n{3}", property_value, Settings::MAX_PARTY_SIZE-1, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText","Policies","NameForHashing"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts[trainer_id] = property_value if property_name == "LoseText"
        when "Extends"
          trainer_hash[:extends_class] = property_value[0]
          trainer_hash[:extends_name] = property_value[1]
          trainer_hash[:extends_version] = property_value[2]
          isExtending = true
        when "ExtendsVersion"
          trainer_hash[:extends_version] = property_value
          isExtending = true
        when "Pokemon","RemovePokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1],
          }
          if !isExtending
            # The default ability index for a given species of a given trainer should be chaotic, but not random
            current_pkmn[:ability_index] = (trainer_hash[:name] + current_pkmn[:species].to_s).hash % 2
          end
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
          when "Ability"
            if property_value[/^\d+$/]
              current_pkmn[:ability_index] = property_value.to_i
            elsif !GameData::Ability.exists?(property_value.to_sym)
              raise _INTL("Value {1} isn't a defined Ability.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
          when "Ball"
            if property_value[/^\d+$/]
              current_pkmn[line_schema[0]] = pbBallTypeToItem(property_value.to_i).id
            elsif !GameData::Item.exists?(property_value.to_sym) ||
               !GameData::Item.get(property_value.to_sym).is_poke_ball?
              raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      end
    }
    # Add last trainer's data to records
    if trainer_hash
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    # Save all data
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    Graphics.update
  end
  
    #=============================================================================
  # Compile metadata
  #=============================================================================
  def compile_metadata(path = "PBS/metadata.txt")
    GameData::Metadata::DATA.clear
    GameData::MapMetadata::DATA.clear
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      pbEachFileSection(f) { |contents, map_id|
        schema = (map_id == 0) ? GameData::Metadata::SCHEMA : GameData::MapMetadata::SCHEMA
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          FileLineData.setSection(map_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if map_id == 0 && ["Home", "PlayerA"].include?(key)
              raise _INTL("The entry {1} is required in {2} section 0.", key, path)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
        end
        if map_id == 0   # Global metadata
          # Construct metadata hash
          metadata_hash = {
            :id                 => map_id,
            :home               => contents["Home"],
            :wild_battle_BGM    => contents["WildBattleBGM"],
            :trainer_battle_BGM => contents["TrainerBattleBGM"],
            :wild_victory_ME    => contents["WildVictoryME"],
            :trainer_victory_ME => contents["TrainerVictoryME"],
            :wild_capture_ME    => contents["WildCaptureME"],
            :surf_BGM           => contents["SurfBGM"],
            :bicycle_BGM        => contents["BicycleBGM"],
            :player_A           => contents["PlayerA"],
            :player_B           => contents["PlayerB"],
            :player_C           => contents["PlayerC"],
            :player_D           => contents["PlayerD"],
            :player_E           => contents["PlayerE"],
            :player_F           => contents["PlayerF"],
            :player_G           => contents["PlayerG"],
            :player_H           => contents["PlayerH"]
          }
          # Add metadata's data to records
          GameData::Metadata.register(metadata_hash)
        else   # Map metadata
          # Construct metadata hash
          metadata_hash = {
            :id                   => map_id,
            :outdoor_map          => contents["Outdoor"],
            :announce_location    => contents["ShowArea"],
            :can_bicycle          => contents["Bicycle"],
            :always_bicycle       => contents["BicycleAlways"],
            :teleport_destination => contents["HealingSpot"],
            :weather              => contents["Weather"],
            :town_map_position    => contents["MapPosition"],
            :dive_map_id          => contents["DiveMap"],
            :dark_map             => contents["DarkMap"],
            :safari_map           => contents["SafariMap"],
            :snap_edges           => contents["SnapEdges"],
            :random_dungeon       => contents["Dungeon"],
            :battle_background    => contents["BattleBack"],
            :wild_battle_BGM      => contents["WildBattleBGM"],
            :trainer_battle_BGM   => contents["TrainerBattleBGM"],
            :wild_victory_ME      => contents["WildVictoryME"],
            :trainer_victory_ME   => contents["TrainerVictoryME"],
            :wild_capture_ME      => contents["WildCaptureME"],
            :town_map_size        => contents["MapSize"],
            :battle_environment   => contents["Environment"],
			      :teleport_blocked	    => contents["TeleportBlocked"],
            :saving_blocked	      => contents["SavingBlocked"],
            :no_team_editing	    => contents["NoTeamEditing"],
          }
          # Add metadata's data to records
          GameData::MapMetadata.register(metadata_hash)
        end
      }
    }
    # Save all data
    GameData::Metadata.save
    GameData::MapMetadata.save
    Graphics.update
  end
  
  #=============================================================================
  # Main compiler method for events
  #=============================================================================
  def compile_events
    mapData = MapData.new
    t = Time.now.to_i
    Graphics.update
    trainerChecker = TrainerChecker.new
    for id in mapData.mapinfos.keys.sort
      changed = false
      map = mapData.getMap(id)
      next if !map || !mapData.mapinfos[id]
	    mapName = mapData.mapinfos[id].name
      pbSetWindowText(_INTL("Processing map {1} ({2})",id,mapName))
      for key in map.events.keys
        if Time.now.to_i-t>=5
          Graphics.update
          t = Time.now.to_i
        end
        newevent = convert_to_trainer_event(map.events[key],trainerChecker)
        if newevent
          map.events[key] = newevent
          changed = true
        end
        newevent = convert_to_item_event(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_chasm_style_trainers(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_avatars(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_placeholder_pokemon(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = convert_overworld_pokemon(map.events[key])
        if newevent
          map.events[key] = newevent
          changed = true
        end
		    newevent = change_overworld_placeholders(map.events[key])
		    if newevent
          map.events[key] = newevent
          changed = true
        end
        changed = true if fix_event_name(map.events[key])
        newevent = fix_event_use(map.events[key],id,mapData)
        if newevent
          map.events[key] = newevent
          changed = true
        end
      end
      if Time.now.to_i-t>=5
        Graphics.update
        t = Time.now.to_i
      end
      changed = true if check_counters(map,id,mapData)
      if changed
        mapData.saveMap(id)
        mapData.saveTilesets
      end
    end
    changed = false
    Graphics.update
    commonEvents = load_data("Data/CommonEvents.rxdata")
    pbSetWindowText(_INTL("Processing common events"))
    for key in 0...commonEvents.length
      newevent = fix_event_use(commonEvents[key],0,mapData)
      if newevent
        commonEvents[key] = newevent
        changed = true
      end
    end
    save_data(commonEvents,"Data/CommonEvents.rxdata") if changed
  end

  def edit_maps
    wallReplaceConvexID = GameData::TerrainTag.get(:WallReplaceConvex).id_number
  
    # Iterate over all maps
    mapData = Compiler::MapData.new
    tilesets_data = load_data("Data/Tilesets.rxdata")
    for id in mapData.mapinfos.keys.sort
        map = mapData.getMap(id)
        next if !map || !mapData.mapinfos[id]
        mapName = mapData.mapinfos[id].name

        # Grab the tileset here
        tileset = tilesets_data[map.tileset_id]

        next if tileset.nil?

        # Iterate over all tiles, finding the first with the relevant tag
        taggedPositions = []
        for x in 0..map.data.xsize
          for y in 0..map.data.ysize
            currentID = map.data[x, y, 1]
            next if currentID.nil?
            currentTag = tileset.terrain_tags[currentID]
            if currentTag == wallReplaceConvexID
              taggedPositions.push([x,y])
            end
          end
        end  

        next if taggedPositions.length == 0

        echoln("Map #{mapName} contains some WallReplaceConvex tiles")

        changeNum = 0
        taggedPositions.each do |position|
          taggedX = position[0]
          taggedY = position[1]

          touchedDirs = 0b0000 # North, East, South, West
          taggedPositions.each do |position2|
            posX = position2[0]
            posY = position2[1]
            # North
            touchedDirs = touchedDirs | 0b1000 if posX == taggedX && posY == taggedY - 1
            # East
            touchedDirs = touchedDirs | 0b0100 if posY == taggedY && posX == taggedX + 1
            # South
            touchedDirs = touchedDirs | 0b0010 if posX == taggedX && posY == taggedY + 1
            # West
            touchedDirs = touchedDirs | 0b0001 if posY == taggedY && posX == taggedX - 1
          end

          tileIDToAdd = 0
          if touchedDirs == 0b1100 # Northeast
            tileIDToAdd = 1485
          elsif touchedDirs == 0b1001 # NorthWest
            tileIDToAdd = 1487
          elsif touchedDirs == 0b0110 # Southeast
            tileIDToAdd = 1469
          elsif touchedDirs == 0b0011 # Southwest
            tileIDToAdd = 1471
          end

          next if tileIDToAdd == 0

          map.data[taggedX,taggedY,1] = tileIDToAdd
          changeNum += 1
        end

        if changeNum > 0
          echoln("Saving map after changing #{changeNum} tiles: #{mapName} (#{id})")
          mapData.saveMap(id)
        else
          echoln("Unable to make any changes to: #{mapName} (#{id})")
        end
    end
  end

  def tile_ID_from_coordinates(x, y)
    return x * TILES_PER_AUTOTILE if y == 0   # Autotile
    return TILESET_START_ID + (y - 1) * TILES_PER_ROW + x
  end
  
  #=============================================================================
  # Convert events using the PHT command into fully fledged trainers
  #=============================================================================
  def convert_chasm_style_trainers(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/PHT\(([_a-zA-Z0-9]+),([_a-zA-Z]+),([0-9]+)\)/)
    return nil if !match
    ret = RPG::Event.new(event.x,event.y)
    ret.id   = event.id
    ret.pages = []
    trainerTypeName = match[1]
    return nil if !trainerTypeName || trainerTypeName == ""
    trainerName = match[2]
    ret.name = "resettrainer(4) - " + trainerTypeName + " " + trainerName
    trainerMaxLevel = match[3]
    ret.pages = [3]
    
    # Create the first page, where the battle happens
    firstPage = RPG::Event::Page.new
    ret.pages[0] = firstPage
    firstPage.graphic.character_name = trainerTypeName
    firstPage.trigger = 2   # On event touch
    firstPage.list = []
    push_script(firstPage.list,"pbTrainerIntro(:#{trainerTypeName})")
    push_script(firstPage.list,"pbNoticePlayer(get_self)")
    push_text(firstPage.list,"Dialogue here.")
    
    push_branch(firstPage.list,"pbTrainerBattle(:#{trainerTypeName},\"#{trainerName}\")")
    push_branch(firstPage.list,"$game_switches[94]",1)
    push_text(firstPage.list,"Dialogue here.",2)
    push_script(firstPage.list,"perfectTrainer(#{trainerMaxLevel})",2)
    push_else(firstPage.list,2)
    push_text(firstPage.list,"Dialogue here.",2)
    push_script(firstPage.list,"defeatTrainer",2)
    push_branch_end(firstPage.list,2)
    push_branch_end(firstPage.list,1)
    
    push_script(firstPage.list,"pbTrainerEnd")
    push_end(firstPage.list)
    
    # Create the second page, which has a talkable action-button graphic
    secondPage = RPG::Event::Page.new
    ret.pages[1] = secondPage
    secondPage.graphic.character_name = trainerTypeName
    secondPage.condition.self_switch_valid = true
    secondPage.condition.self_switch_ch = "A"
    secondPage.list = []
    push_text(secondPage.list,"Dialogue here.")
    push_end(secondPage.list)
    
    # Create the third page, which has no functionality and no graphic
    thirdPage = RPG::Event::Page.new
    ret.pages[2] = thirdPage
    thirdPage.condition.self_switch_valid = true
    thirdPage.condition.self_switch_ch = "D"
    thirdPage.list = []
    push_end(thirdPage.list)
    
    return ret
  end
    
  #=============================================================================
  # Convert events using the PHA name command into fully fledged avatars
  #=============================================================================
  def convert_avatars(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/.*PHA\(([_a-zA-Z0-9]+),([0-9]+)(?:,([_a-zA-Z]+))?(?:,([_a-zA-Z0-9]+))?(?:,([0-9]+))?\).*/)
    return nil if !match
    ret = RPG::Event.new(event.x,event.y)
    ret.id   = event.id
    ret.pages = []
    avatarSpecies = match[1]
    ret.name = "size(2,2)trainer(4) - " + avatarSpecies
    legendary = isLegendary(avatarSpecies)
    return nil if !avatarSpecies || avatarSpecies == ""
    level = match[2]
    directionText = match[3]
    item = match[4] || nil
    itemCount = match[5].to_i || 0
    
    direction = Down
    if !directionText.nil?
      case directionText.downcase
      when "left"
        direction = Left
      when "right"
        direction = Right
      when "up"
        direction = Up
      else
        direction = Down
      end
    end
    
    # Create the needed graphics
    createBossGraphics(avatarSpecies)
    
    ret.pages = [2]
    # Create the first page, where the battle happens
    firstPage = RPG::Event::Page.new
    ret.pages[0] = firstPage
    firstPage.graphic.character_name = "zAvatar_#{avatarSpecies}"
    firstPage.graphic.opacity = 180
    firstPage.graphic.direction = direction
    firstPage.trigger = 2   # On event touch
    firstPage.step_anime = true # Animate while still
    firstPage.list = []
    push_script(firstPage.list,"pbNoticePlayer(get_self)")
    push_script(firstPage.list,"introduceAvatar(:#{avatarSpecies})")
    push_branch(firstPage.list,"pb#{legendary ? "Big" : "Small"}AvatarBattle([:#{avatarSpecies},#{level}])")
    if item.nil?
      push_script(firstPage.list,"defeatBoss",1)
    else
      if itemCount > 1
        push_script(firstPage.list,"defeatBoss(:#{item},#{itemCount})",1)
      else
        push_script(firstPage.list,"defeatBoss(:#{item})",1)
      end
    end
      push_branch_end(firstPage.list,1)
    push_end(firstPage.list)
    
    # Create the second page, which has nothing
    secondPage = RPG::Event::Page.new
    ret.pages[1] = secondPage
    secondPage.condition.self_switch_valid = true
    secondPage.condition.self_switch_ch = "A"
    
    return ret
    end
    
    #=============================================================================
    # Convert events using the PHP name command into fully fledged overworld pokemon
    #=============================================================================
    def convert_placeholder_pokemon(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/.*PHP\(([a-zA-Z0-9]+)(?:_([0-9]*))?(?:,([_a-zA-Z]+))?.*/)
    return nil if !match
    species = match[1]
    return if !species
    species = species.upcase
    form	= match[2]
    form = 0 if !form || form == ""
    speciesData = GameData::Species.get(species.to_sym)
    return if !speciesData
    directionText = match[3]
    direction = Down
    if !directionText.nil?
      case directionText.downcase
      when "left"
        direction = Left
      when "right"
        direction = Right
      when "up"
        direction = Up
      else
        direction = Down
      end
    end
    
    echoln("Converting event: #{species},#{form},#{direction}")
    
    ret = RPG::Event.new(event.x,event.y)
    ret.name = "resetfollower"
    ret.id   = event.id
    ret.pages = [3]
    
    # Create the first page, where the cry happens
    firstPage = RPG::Event::Page.new
    ret.pages[0] = firstPage
    fileName = species
    fileName += "_" + form.to_s if form != 0
    firstPage.graphic.character_name = "Followers/#{fileName}"
    firstPage.graphic.direction = direction
    firstPage.step_anime = true # Animate while still
    firstPage.trigger = 0 # Action button
    firstPage.list = []
    push_script(firstPage.list,sprintf("Pokemon.play_cry(:%s, %d)",speciesData.id,form))
    push_script(firstPage.list,sprintf("pbMessage(\"#{speciesData.real_name} cries out!\")",))
    push_end(firstPage.list)
    
    # Create the second page, which has nothing
    secondPage = RPG::Event::Page.new
    ret.pages[1] = secondPage
    secondPage.condition.self_switch_valid = true
    secondPage.condition.self_switch_ch = "A"
    
    # Create the third page, which has nothing
    thirdPage = RPG::Event::Page.new
    ret.pages[2] = thirdPage
    thirdPage.condition.self_switch_valid = true
    thirdPage.condition.self_switch_ch = "D"
    
    return ret
  end
  
  #=============================================================================
  # Convert events using the overworld name command to use the correct graphic.
  #=============================================================================
  def convert_overworld_pokemon(event)
    return nil if !event || event.pages.length==0
    match = event.name.match(/(.*)?overworld\(([a-zA-Z0-9]+)\)(.*)?/)
    return nil if !match
    nameStuff = match[1] || ""
    nameStuff += match[3] || ""
    nameStuff += match[2] || ""
    species = match[2]
    return nil if !species
    
    event.name = nameStuff
    event.pages.each do |page|
      next if page.graphic.character_name != "00Overworld Placeholder"
      page.graphic.character_name = "Followers/#{species}" 
    end
    
    return event
    end
    
    def change_overworld_placeholders(event)
    return nil if !event || event.pages.length==0
    return nil unless event.name.downcase.include?("boxplaceholder")
    
    return nil
    #event.pages.each do |page|
    #	page.move_type = 1
    #end
    
    return event
    end
  end

module GameData
	def self.load_all
		echoln("Loading all game data.")
		Type.load
		Ability.load
		Move.load
		Item.load
		BerryPlant.load
		Species.load
		SpeciesOld.load
		Ribbon.load
		Encounter.load
		TrainerType.load
		Trainer.load
		Metadata.load
		MapMetadata.load
		Policy.load
		Avatar.load
	end
end

module Compiler
	module_function

  #=============================================================================
  # Save Pokémon data to PBS file
  #=============================================================================
  def write_pokemon
    File.open("PBS/pokemon.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        next if species.form != 0
        pbSetWindowText(_INTL("Writing species {1}...", species.id_number))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n", species.id_number))
        f.write(sprintf("Name = %s\r\n", species.real_name))
        f.write(sprintf("InternalName = %s\r\n", species.species))
        f.write(sprintf("Notes = %s\r\n", species.notes)) if !species.notes.nil? && !species.notes.blank?
        f.write(sprintf("Type1 = %s\r\n", species.type1))
        f.write(sprintf("Type2 = %s\r\n", species.type2)) if species.type2 != species.type1
        stats_array = []
        evs_array = []
		    total = 0
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array[s.pbs_order] = species.evs[s.id]
		      total += species.base_stats[s.id]
        end
		    f.write(sprintf("# HP, Attack, Defense, Speed, Sp. Atk, Sp. Def\r\n", total))
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(",")))
		    f.write(sprintf("# Total = %s\r\n", total))
        f.write(sprintf("GenderRate = %s\r\n", species.gender_ratio))
        f.write(sprintf("GrowthRate = %s\r\n", species.growth_rate))
        f.write(sprintf("BaseEXP = %d\r\n", species.base_exp))
        f.write(sprintf("EffortPoints = %s\r\n", evs_array.join(",")))
        f.write(sprintf("Rareness = %d\r\n", species.catch_rate))
        f.write(sprintf("Happiness = %d\r\n", species.happiness))
        if species.abilities.length > 0
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0
          f.write(sprintf("HiddenAbility = %s\r\n", species.hidden_abilities.join(",")))
        end
        if species.moves.length > 0
          f.write(sprintf("Moves = %s\r\n", species.moves.join(",")))
        end
        if species.tutor_moves.length > 0
          f.write(sprintf("TutorMoves = %s\r\n", species.tutor_moves.join(",")))
        end
        if species.egg_moves.length > 0
          f.write(sprintf("EggMoves = %s\r\n", species.egg_moves.join(",")))
        end
        if species.egg_groups.length > 0
          f.write(sprintf("Compatibility = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps))
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0))
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0))
        f.write(sprintf("Color = %s\r\n", species.color))
        f.write(sprintf("Shape = %s\r\n", species.shape))
        f.write(sprintf("Habitat = %s\r\n", species.habitat)) if species.habitat != :None
        f.write(sprintf("Kind = %s\r\n", species.real_category))
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != 0
        f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common)) if species.wild_item_common
        f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon)) if species.wild_item_uncommon
        f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare)) if species.wild_item_rare
        f.write(sprintf("BattlerPlayerX = %d\r\n", species.back_sprite_x))
        f.write(sprintf("BattlerPlayerY = %d\r\n", species.back_sprite_y))
        f.write(sprintf("BattlerEnemyX = %d\r\n", species.front_sprite_x))
        f.write(sprintf("BattlerEnemyY = %d\r\n", species.front_sprite_y))
        f.write(sprintf("BattlerAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != 0
        f.write(sprintf("BattlerShadowX = %d\r\n", species.shadow_x))
        f.write(sprintf("BattlerShadowSize = %d\r\n", species.shadow_size))
        if species.evolutions.any? { |evo| !evo[3] }
          f.write("Evolutions = ")
          need_comma = false
          species.evolutions.each do |evo|
            next if evo[3]   # Skip prevolution entries
            f.write(",") if need_comma
            need_comma = true
            evo_type_data = GameData::Evolution.get(evo[1])
            param_type = evo_type_data.parameter
            f.write(sprintf("%s,%s,", evo[0], evo_type_data.id.to_s))
            if !param_type.nil?
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
        f.write(sprintf("Incense = %s\r\n", species.incense)) if species.incense
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Save Pokémon forms data to PBS file
  #=============================================================================
  def write_pokemon_forms
    File.open("PBS/pokemonforms.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        next if species.form == 0
        base_species = GameData::Species.get(species.species)
        pbSetWindowText(_INTL("Writing species {1}...", species.id_number))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s,%d]\r\n", species.species, species.form))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("Notes = %s\r\n", species.notes)) if !species.notes.nil? && !species.notes.blank?
        f.write(sprintf("PokedexForm = %d\r\n", species.pokedex_form)) if species.pokedex_form != species.form
        f.write(sprintf("MegaStone = %s\r\n", species.mega_stone)) if species.mega_stone
        f.write(sprintf("MegaMove = %s\r\n", species.mega_move)) if species.mega_move
        f.write(sprintf("UnmegaForm = %d\r\n", species.unmega_form)) if species.unmega_form != 0
        f.write(sprintf("MegaMessage = %d\r\n", species.mega_message)) if species.mega_message != 0
        if species.type1 != base_species.type1 || species.type2 != base_species.type2
          f.write(sprintf("Type1 = %s\r\n", species.type1))
          f.write(sprintf("Type2 = %s\r\n", species.type2)) if species.type2 != species.type1
        end
        stats_array = []
        evs_array = []
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array[s.pbs_order] = species.evs[s.id]
        end
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(","))) if species.base_stats != base_species.base_stats
        f.write(sprintf("BaseEXP = %d\r\n", species.base_exp)) if species.base_exp != base_species.base_exp
        f.write(sprintf("EffortPoints = %s\r\n", evs_array.join(","))) if species.evs != base_species.evs
        f.write(sprintf("Rareness = %d\r\n", species.catch_rate)) if species.catch_rate != base_species.catch_rate
        f.write(sprintf("Happiness = %d\r\n", species.happiness)) if species.happiness != base_species.happiness
        if species.abilities.length > 0 && species.abilities != base_species.abilities
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0 && species.hidden_abilities != base_species.hidden_abilities
          f.write(sprintf("HiddenAbility = %s\r\n", species.hidden_abilities.join(",")))
        end
        if species.moves.length > 0 && species.moves != base_species.moves
          f.write(sprintf("Moves = %s\r\n", species.moves.join(",")))
        end
        if species.tutor_moves.length > 0 && species.tutor_moves != base_species.tutor_moves
          f.write(sprintf("TutorMoves = %s\r\n", species.tutor_moves.join(",")))
        end
        if species.egg_moves.length > 0 && species.egg_moves != base_species.egg_moves
          f.write(sprintf("EggMoves = %s\r\n", species.egg_moves.join(",")))
        end
        if species.egg_groups.length > 0 && species.egg_groups != base_species.egg_groups
          f.write(sprintf("Compatibility = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps)) if species.hatch_steps != base_species.hatch_steps
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0)) if species.height != base_species.height
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0)) if species.weight != base_species.weight
        f.write(sprintf("Color = %s\r\n", species.color)) if species.color != base_species.color
        f.write(sprintf("Shape = %s\r\n", species.shape)) if species.shape != base_species.shape
        if species.habitat != :None && species.habitat != base_species.habitat
          f.write(sprintf("Habitat = %s\r\n", species.habitat))
        end
        f.write(sprintf("Kind = %s\r\n", species.real_category)) if species.real_category != base_species.real_category
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry)) if species.real_pokedex_entry != base_species.real_pokedex_entry
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != base_species.generation
        if species.wild_item_common != base_species.wild_item_common ||
           species.wild_item_uncommon != base_species.wild_item_uncommon ||
           species.wild_item_rare != base_species.wild_item_rare
          f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common)) if species.wild_item_common
          f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon)) if species.wild_item_uncommon
          f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare)) if species.wild_item_rare
        end
        f.write(sprintf("BattlerPlayerX = %d\r\n", species.back_sprite_x)) if species.back_sprite_x != base_species.back_sprite_x
        f.write(sprintf("BattlerPlayerY = %d\r\n", species.back_sprite_y)) if species.back_sprite_y != base_species.back_sprite_y
        f.write(sprintf("BattlerEnemyX = %d\r\n", species.front_sprite_x)) if species.front_sprite_x != base_species.front_sprite_x
        f.write(sprintf("BattlerEnemyY = %d\r\n", species.front_sprite_y)) if species.front_sprite_y != base_species.front_sprite_y
        f.write(sprintf("BattlerAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != base_species.front_sprite_altitude
        f.write(sprintf("BattlerShadowX = %d\r\n", species.shadow_x)) if species.shadow_x != base_species.shadow_x
        f.write(sprintf("BattlerShadowSize = %d\r\n", species.shadow_size)) if species.shadow_size != base_species.shadow_size
        if species.evolutions != base_species.evolutions && species.evolutions.any? { |evo| !evo[3] }
          f.write("Evolutions = ")
          need_comma = false
          species.evolutions.each do |evo|
            next if evo[3]   # Skip prevolution entries
            f.write(",") if need_comma
            need_comma = true
            evo_type_data = GameData::Evolution.get(evo[1])
            param_type = evo_type_data.parameter
            f.write(sprintf("%s,%s,", evo[0], evo_type_data.id.to_s))
            if !param_type.nil?
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  def write_moves
    File.open("PBS/moves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      current_type = -1
      GameData::Move.each do |m|
        break if m.id_number >= 2000
        if current_type != m.type && m.id_number < 742
          current_type = m.type
          f.write("\#-------------------------------\r\n")
        end
        f.write(sprintf("%d,%s,%s,%s,%d,%s,%s,%d,%d,%d,%s,%d,%s,%s,%s\r\n",
          m.id_number,
          csvQuote(m.id.to_s),
          csvQuote(m.real_name),
          csvQuote(m.function_code),
          m.base_damage,
          m.type.to_s,
          ["Physical", "Special", "Status"][m.category],
          m.accuracy,
          m.total_pp,
          m.effect_chance,
          m.target,
          m.priority,
          csvQuote(m.flags),
          csvQuoteAlways(m.real_description),
          m.animation_move.nil? ? "" : m.animation_move.to_s
        ))
      end
    }
    File.open("PBS/other_moves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      current_type = -1
      GameData::Move.each do |m|
        next if m.id_number < 2000
        if current_type != m.type && m.id_number < 742
          current_type = m.type
          f.write("\#-------------------------------\r\n")
        end
        f.write(sprintf("%d,%s,%s,%s,%d,%s,%s,%d,%d,%d,%s,%d,%s,%s,%s\r\n",
          m.id_number,
          csvQuote(m.id.to_s),
          csvQuote(m.real_name),
          csvQuote(m.function_code),
          m.base_damage,
          m.type.to_s,
          ["Physical", "Special", "Status"][m.category],
          m.accuracy,
          m.total_pp,
          m.effect_chance,
          m.target,
          m.priority,
          csvQuote(m.flags),
          csvQuoteAlways(m.real_description),
          m.animation_move.nil? ? "" : m.animation_move.to_s
        ))
      end
    }
    Graphics.update
  end
  
  #=============================================================================
  # Save trainer type data to PBS file
  #=============================================================================
  def write_trainer_types
    File.open("PBS/trainertypes.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::TrainerType.each do |t|
        policiesString = ""
        if t.policies
          policiesString += "["
          t.policies.each_with_index do |policy_symbol,index|
            policiesString += policy_symbol.to_s
            policiesString += "," if index < t.policies.length - 1
          end
          policiesString += "]"
        end
	  
        f.write(sprintf("%d,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s\r\n",
        t.id_number,
        csvQuote(t.id.to_s),
        csvQuote(t.real_name),
        t.base_money,
        csvQuote(t.battle_BGM),
        csvQuote(t.victory_ME),
        csvQuote(t.intro_ME),
        ["Male", "Female", "Mixed", "Wild"][t.gender],
        (t.skill_level == t.base_money) ? "" : t.skill_level.to_s,
        csvQuote(t.skill_code),
        policiesString
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_trainers
    File.open("PBS/trainers.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Trainer.each do |trainer|
        pbSetWindowText(_INTL("Writing trainer {1}...", trainer.id_number))
        Graphics.update if trainer.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        if trainer.version > 0
          f.write(sprintf("[%s,%s,%d]\r\n", trainer.trainer_type, trainer.real_name, trainer.version))
        else
          f.write(sprintf("[%s,%s]\r\n", trainer.trainer_type, trainer.real_name))
        end
        if trainer.extendsVersion >= 0
          if !trainer.extendsClass.nil? && !trainer.extendsName.nil?
            f.write(sprintf("Extends = %s,%s,%s\r\n", trainer.extendsClass.to_s, trainer.extendsName.to_s, trainer.extendsVersion.to_s))
          else
            f.write(sprintf("ExtendsVersion = %s\r\n", trainer.extendsVersion.to_s))
          end
        end
        if !trainer.nameForHashing.nil?
          f.write(sprintf("NameForHashing = %s\r\n", trainer.nameForHashing.to_s))
        end
		    if trainer.policies && trainer.policies.length > 0
          policiesString = ""
          trainer.policies.each_with_index do |policy_symbol,index|
            policiesString += policy_symbol.to_s
            policiesString += "," if index < trainer.policies.length - 1
          end
          f.write(sprintf("Policies = %s\r\n", policiesString))
        end
        f.write(sprintf("Items = %s\r\n", trainer.items.join(","))) if trainer.items.length > 0
        trainer.pokemon.each do |pkmn|
          f.write(sprintf("Pokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          writePartyMember(f,pkmn)
        end
        trainer.removedPokemon.each do |pkmn|
          f.write(sprintf("RemovePokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          writePartyMember(f,pkmn)
        end
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  def writePartyMember(f,pkmn)
    f.write(sprintf("    Position = %s\r\n", pkmn[:assigned_position])) if !pkmn[:assigned_position].nil?
    f.write(sprintf("    Name = %s\r\n", pkmn[:name])) if pkmn[:name] && !pkmn[:name].empty?
    f.write(sprintf("    Form = %d\r\n", pkmn[:form])) if pkmn[:form] && pkmn[:form] > 0
    f.write(sprintf("    Gender = %s\r\n", (pkmn[:gender] == 1) ? "female" : "male")) if pkmn[:gender]
    f.write("    Shiny = yes\r\n") if pkmn[:shininess]
    f.write("    Shadow = yes\r\n") if pkmn[:shadowness]
    f.write(sprintf("    Moves = %s\r\n", pkmn[:moves].join(","))) if pkmn[:moves] && pkmn[:moves].length > 0
    f.write(sprintf("    Ability = %s\r\n", pkmn[:ability])) if pkmn[:ability]
    f.write(sprintf("    AbilityIndex = %d\r\n", pkmn[:ability_index])) if pkmn[:ability_index]
    f.write(sprintf("    Item = %s\r\n", pkmn[:item])) if pkmn[:item]
    f.write(sprintf("    Nature = %s\r\n", pkmn[:nature])) if pkmn[:nature]
    ivs_array = []
    evs_array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      ivs_array[s.pbs_order] = pkmn[:iv][s.id] if pkmn[:iv]
      evs_array[s.pbs_order] = pkmn[:ev][s.id] if pkmn[:ev]
    end
    f.write(sprintf("    IV = %s\r\n", ivs_array.join(","))) if pkmn[:iv]
    f.write(sprintf("    EV = %s\r\n", evs_array.join(","))) if pkmn[:ev]
    f.write(sprintf("    Happiness = %d\r\n", pkmn[:happiness])) if pkmn[:happiness]
    f.write(sprintf("    Ball = %s\r\n", pkmn[:poke_ball])) if pkmn[:poke_ball]
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_avatars
    File.open("PBS/avatars.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Avatar.each do |avatar|
        pbSetWindowText(_INTL("Writing avatar {1}...", avatar.id_number))
        Graphics.update if avatar.id_number % 20 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", avatar.id))
        f.write(sprintf("Ability = %s\r\n", avatar.ability))
        f.write(sprintf("Moves1 = %s\r\n", avatar.moves1.join(",")))
        f.write(sprintf("Moves2 = %s\r\n", avatar.moves2.join(","))) if !avatar.moves2.nil? && avatar.num_phases >= 2
        f.write(sprintf("Moves3 = %s\r\n", avatar.moves3.join(","))) if !avatar.moves3.nil? && avatar.num_phases >= 3
        f.write(sprintf("Moves4 = %s\r\n", avatar.moves4.join(","))) if !avatar.moves4.nil? && avatar.num_phases >= 4
        f.write(sprintf("Moves5 = %s\r\n", avatar.moves5.join(","))) if !avatar.moves5.nil? && avatar.num_phases >= 5
        f.write(sprintf("Turns = %s\r\n", avatar.num_turns)) if avatar.num_turns != 2.0
        f.write(sprintf("HPMult = %s\r\n", avatar.hp_mult)) if avatar.num_turns != 4.0
        f.write(sprintf("HealthBars = %s\r\n", avatar.num_health_bars)) if avatar.num_health_bars != avatar.num_phases
        f.write(sprintf("Item = %s\r\n", avatar.item)) if !avatar.item.nil?
        f.write(sprintf("DMGMult = %s\r\n", avatar.dmg_mult)) if avatar.dmg_mult != 1.0
        f.write(sprintf("DMGResist = %s\r\n", avatar.dmg_resist)) if avatar.dmg_resist != 0.0
        f.write(sprintf("Form = %s\r\n", avatar.form)) if avatar.form != 0
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Compile move data
  #=============================================================================
  def compile_moves()
    GameData::Move::DATA.clear
    move_names        = []
    move_descriptions = []
    ["PBS/moves.txt","PBS/other_moves.txt"].each do |path|
      # Read each line of moves.txt at a time and compile it into an move
      pbCompilerEachPreppedLine(path) { |line, line_no|
        line = pbGetCsvRecord(line, line_no, [0, "vnssueeuuueissN",
          nil, nil, nil, nil, nil, :Type, ["Physical", "Special", "Status"],
          nil, nil, nil, :Target, nil, nil, nil, nil
        ])
        move_number = line[0]
        move_symbol = line[1].to_sym
        if GameData::Move::DATA[move_number]
          raise _INTL("Move ID number '{1}' is used twice.\r\n{2}", move_number, FileLineData.linereport)
        elsif GameData::Move::DATA[move_symbol]
          raise _INTL("Move ID '{1}' is used twice.\r\n{2}", move_symbol, FileLineData.linereport)
        end
        # Sanitise data
        if line[6] == 2 && line[4] != 0
          raise _INTL("Move {1} is defined as a Status move with a non-zero base damage.\r\n{2}", line[2], FileLineData.linereport)
        elsif line[6] != 2 && line[4] == 0
          print _INTL("Warning: Move {1} was defined as Physical or Special but had a base damage of 0. Changing it to a Status move.\r\n{2}", line[2], FileLineData.linereport)
          line[6] = 2
        end
        animation_move = line[14].nil? ? nil : line[14].to_sym
        # Construct move hash
        move_hash = {
          :id_number        => move_number,
          :id               => move_symbol,
          :name             => line[2],
          :function_code    => line[3],
          :base_damage      => line[4],
          :type             => line[5],
          :category         => line[6],
          :accuracy         => line[7],
          :total_pp         => line[8],
          :effect_chance    => line[9],
          :target           => GameData::Target.get(line[10]).id,
          :priority         => line[11],
          :flags            => line[12],
          :description      => line[13],
          :animation_move   => animation_move
        }
        # Add move's data to records
        GameData::Move.register(move_hash)
        move_names[move_number]        = move_hash[:name]
        move_descriptions[move_number] = move_hash[:description]
      }
    end
    # Save all data
    GameData::Move.save
    MessageTypes.setMessages(MessageTypes::Moves, move_names)
    MessageTypes.setMessages(MessageTypes::MoveDescriptions, move_descriptions)
    Graphics.update

    GameData::Move.each do |move_data|
      next if move_data.animation_move.nil?
      next if GameData::Move.exists?(move_data.animation_move)
      raise _INTL("Move ID '{1}' was assigned an Animation Move property {2} that doesn't match with any other move.\r\n", move_data.id, move_data.animation_move)
    end
  end

  def compile_signature_metadata
    signatureMoveInfo = getSignatureMoves()

    signatureMoveInfo.each do |moveID,signatureHolder|
      GameData::Move.get(moveID).signature_of = signatureHolder
    end

    signatureAbilityInfo = getSignatureAbilities()

    signatureAbilityInfo.each do |abilityID,signatureHolder|
      GameData::Ability.get(abilityID).signature_of = signatureHolder
    end

    # Save all data
    GameData::Move.save
    GameData::Ability.save
    Graphics.update
  end

  #=============================================================================
  # Save all data to PBS files
  #=============================================================================
  def write_all
    write_town_map
    write_connections
    write_phone
    write_types
    write_abilities
    write_moves
    write_items
    write_berry_plants
    write_pokemon
    write_pokemon_forms
    write_shadow_movesets
    write_regional_dexes
    write_ribbons
    write_encounters
    write_trainer_types
    write_trainers
    write_trainer_lists
    write_avatars
    write_metadata
  end
end