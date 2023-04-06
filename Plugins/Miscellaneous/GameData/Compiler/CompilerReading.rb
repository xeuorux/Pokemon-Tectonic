module Compiler
	module_function
	
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
      yield(_INTL("Compiling species tribes"))
	    compile_tribes
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
      yield(_INTL("Compiling species earliest encounter levels"))
      compile_species_earliest_levels
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
  # Compile type data
  #=============================================================================
  def compile_types(path = "PBS/types.txt")
    GameData::Type::DATA.clear
    type_names = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Type::SCHEMA
      pbEachFileSection(f) { |contents, type_number|
        # Go through schema hash of compilable data and compile this section
        for key in schema.keys
          FileLineData.setSection(type_number, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, type_id)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
          # Ensure weaknesses/resistances/immunities are in arrays and are symbols
          if value && ["Weaknesses", "Resistances", "Immunities"].include?(key)
            contents[key] = [contents[key]] if !contents[key].is_a?(Array)
            contents[key].map! { |x| x.to_sym }
            contents[key].uniq!
          end
        end
        # Construct type hash
        type_symbol = contents["InternalName"].to_sym
        type_hash = {
          :id           => type_symbol,
          :id_number    => type_number,
          :name         => contents["Name"],
          :pseudo_type  => contents["IsPseudoType"],
          :special_type => contents["IsSpecialType"],
          :weaknesses   => contents["Weaknesses"],
          :resistances  => contents["Resistances"],
          :immunities   => contents["Immunities"],
          :color        => contents["Color"],
        }
        # Add type's data to records
        GameData::Type.register(type_hash)
        type_names[type_number] = type_hash[:name]
      }
    }
    # Ensure all weaknesses/resistances/immunities are valid types
    GameData::Type.each do |type|
      type.weaknesses.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Weaknesses).", other_type.to_s, path, type.id_number)
      end
      type.resistances.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Resistances).", other_type.to_s, path, type.id_number)
      end
      type.immunities.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Immunities).", other_type.to_s, path, type.id_number)
      end
    end
    # Save all data
    GameData::Type.save
    MessageTypes.setMessages(MessageTypes::Types, type_names)
    Graphics.update
  end

  #=============================================================================
  # Compile move data
  #=============================================================================
  def compile_moves()
    GameData::Move::DATA.clear
    move_names        = []
    move_descriptions = []
    idBase = 0
    ["PBS/moves.txt","PBS/moves_new.txt","PBS/moves_primeval.txt","PBS/moves_z.txt","PBS/moves_cut.txt"].each do |path|
      idNumber = idBase
      primeval = path == "PBS/moves_primeval.txt"
      cut = path == "PBS/moves_cut.txt"
      tectonic_new = path == "PBS/moves_new.txt"
      zmove = path == "PBS/moves_z.txt"
      # Read each line of moves.txt at a time and compile it into an move
      pbCompilerEachPreppedLine(path) { |line, line_no|
        idNumber += 1
        line = pbGetCsvRecord(line, line_no, [0, "vnssueeuuueissN",
          nil, nil, nil, nil, nil, :Type, ["Physical", "Special", "Status"],
          nil, nil, nil, :Target, nil, nil, nil, nil
        ])
        move_number = idNumber
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
          :animation_move   => animation_move,
          :primeval         => primeval,
          :cut              => cut,
          :tectonic_new     => tectonic_new,
          :zmove            => zmove,
        }
        # Add move's data to records
        GameData::Move.register(move_hash)
        move_names[move_number]        = move_hash[:name]
        move_descriptions[move_number] = move_hash[:description]
      }
      idBase += 1000
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

  #=============================================================================
  # Compile item data
  #=============================================================================
  def compile_items()
    GameData::Item::DATA.clear
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    ["PBS/items.txt","PBS/items_super.txt"].each do |path|
      # Read each line of items.txt at a time and compile it into an item
      pbCompilerEachCommentedLine(path) { |line, line_no|
        line = pbGetCsvRecord(line, line_no, [0, "vnssuusuuUN"])
        item_number = line[0]
        item_symbol = line[1].to_sym
        if GameData::Item::DATA[item_number]
          raise _INTL("Item ID number '{1}' is used twice.\r\n{2}", item_number, FileLineData.linereport)
        elsif GameData::Item::DATA[item_symbol]
          raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_symbol, FileLineData.linereport)
        end
        # Construct item hash
        item_hash = {
          :id_number   => item_number,
          :id          => item_symbol,
          :name        => line[2],
          :name_plural => line[3],
          :pocket      => line[4],
          :price       => line[5],
          :description => line[6],
          :field_use   => line[7],
          :battle_use  => line[8],
          :type        => line[9]
        }
        item_hash[:move] = parseMove(line[10]) if !nil_or_empty?(line[10])
        # Add item's data to records
        GameData::Item.register(item_hash)
        item_names[item_number]        = item_hash[:name]
        item_names_plural[item_number] = item_hash[:name_plural]
        item_descriptions[item_number] = item_hash[:description]
      }
    end
    # Save all data
    GameData::Item.save
    MessageTypes.setMessages(MessageTypes::Items, item_names)
    MessageTypes.setMessages(MessageTypes::ItemPlurals, item_names_plural)
    MessageTypes.setMessages(MessageTypes::ItemDescriptions, item_descriptions)
    Graphics.update
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

  def compile_tribes(path = "PBS/tribes.txt")
	  GameData::Tribe::DATA.clear
    # Read each line of tribes.txt at a time and compile it
    pbCompilerEachCommentedLine(path) { |line, line_no|
      tribeSchema = [0, "*nis"]
      tribe_number = 1
      line = pbGetCsvRecord(line, line_no, tribeSchema)
      tribe_symbol = line[0].to_sym
      tribe_threshold = line[1].to_i
      tribe_description = line[2]
      if GameData::Tribe::DATA[tribe_symbol]
        raise _INTL("Tribe ID '{1}' is used twice.\r\n{2}", tribe_symbol, FileLineData.linereport)
      end
      tribe_number += 1
      # Construct trainer type hash
      tribe_hash = {
        :id          => tribe_symbol,
        :id_number   => tribe_number,
        :threshold   => tribe_threshold,
        :description => tribe_description,
      }
      # Add trainer policy's data to records
      GameData::Tribe.register(tribe_hash)
    }
    # Save all data
    GameData::Tribe.save
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
    File.open(path, "rb") { |f|
		FileLineData.file = path   # For error reporting
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
				# when "Moves1"
				# 	if contents["Moves1"].length > 4
				# 		raise _INTL("The {1} entry has too many moves in PBS/avatars.txt section {2}.", key, avatar_species)
				# 	end
        when "Ability"
          abilities = contents["Ability"]
          abilities.each do |ability|
            if !speciesData.abilities.concat(speciesData.hidden_abilities).include?(ability) &&
                !ability.to_s.downcase.include?("primeval")
              echoln(_INTL("Ability {1} is not legal for the Avatar defined in PBS/avatars.txt section {2}.", ability, avatar_species))
            end
          end
        when "Aggression"
          if value < 0 || value > PokeBattle_AI_Boss::MAX_BOSS_AGGRESSION
            raise _INTL("Aggression value {1} is not legal for the Avatar defined in PBS/avatars.txt section {2}. Aggression must be between 0 and {3} (inclusive)", value, avatar_species, PokeBattle_AI_Boss::MAX_BOSS_AGGRESSION)
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
				:abilities	 		    => contents["Ability"],
				:item		 		        => contents["Item"],
				:hp_mult	 		      => contents["HPMult"],
        :size_mult	 		    => contents["SizeMult"],
				:dmg_mult			      => contents["DMGMult"],
        :dmg_resist			    => contents["DMGResist"],
				:health_bars	 		  => contents["HealthBars"],
        :aggression         => contents["Aggression"],
			}
			avatar_number += 1
			# Add trainer avatar's data to records
			GameData::Avatar.register(avatar_hash)
		}
    }

    # Save all data
    GameData::Avatar.save
    Graphics.update

    createBossSpritesAllSpeciesForms(false)
  end 

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
      if line[10]
        policies_string_array = line[10].gsub('[','').gsub(']','').split(',')
        policies_string_array.each do |policy_string|
          policies_array.push(policy_string.to_sym)
          echoln("#{policy_string}")
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
          when "TutorMoves", "EggMoves", "LineMoves", "Abilities", "HiddenAbility", "Compatibility"
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
          :line_moves            => contents["LineMoves"],
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
          :notes                 => contents["Notes"],
          :tribes                => contents["Tribes"],
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
          when "TutorMoves", "EggMoves", "LineMoves", "Abilities", "HiddenAbility", "Compatibility"
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
          :egg_moves             => contents["LineMoves"] || base_data.egg_moves.clone,
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
          :notes                 => contents["Notes"],
          :tribes                => contents["Tribes"]  || base_data.tribes,
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
              property_value[spAtkIndex] = attackingStatsValue
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
          if ev_total < Pokemon::EV_LIMIT
            raise _INTL("Total EVs are less than required ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
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
            :avatar_battle_BGM 	=> contents["AvatarBattleBGM"],
			      :legendary_avatar_battle_BGM 	=> contents["LegendaryAvatarBattleBGM"],
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

    def compile_species_earliest_levels
      # A hash of all species in the game that can be aquired directly
      # where the key is the species ID and the value is the earliest level they can be directly aquired
      earliestWildEncounters = {}
  
      # Checking every single map in the game for encounters
      GameData::Encounter.each_of_version do |enc_data|
        earliestLevelForMap = getEarliestLevelForMap(enc_data.map)
  
        # For each slot in that encounters data listing
        enc_data.types.each do |key,slots|
          next if !slots
          earliestLevelForSlot = earliestLevelForMap
          earliestLevelForSlot = [earliestLevelForSlot,SURFING_LEVEL].min if key == :ActiveWater
          slots.each do |slot|
            species = slot[1]
            if !earliestWildEncounters.has_key?(species) || earliestWildEncounters[species] > earliestLevelForSlot
              earliestWildEncounters[species] = earliestLevelForSlot
            end
          end
        end
      end
  
      # A hash where the key is a species
      # and the value is a hash that describes different ways of aquiring it
      earliestAquisition = earliestWildEncounters.clone
  
      iterationCount = 0
      loop do
        madeAnyChanges = false
        iterationCount += 1
        echoln("Iteration #{iterationCount} of calculating earliest species aquisition level!")
        GameData::Species.each do |speciesData|
          species = speciesData.id
          next unless earliestAquisition.has_key?(species)
          earliestLevelForBase = earliestAquisition[species]
  
          evolutions = speciesData.get_evolutions
  
          # Determine the earliest possible aquisiton level for each of its evolutions
          evolutions.each do |evolutionEntry|
            evoSpecies = evolutionEntry[0]
            evoMethod = evolutionEntry[1]
            param = evolutionEntry[2]
            case evoMethod
            # All method based on leveling up to a certain level
            when :Level,:LevelDay,:LevelNight,:LevelMale,:LevelFemale,:LevelRain,
              :AttackGreater,:AtkDefEqual,:DefenseGreater,:LevelDarkInParty,
              :Silcoon,:Cascoon,:Ninjask,:Shedinja,:Originize,:Ability0,:Ability1
              
              evoLevelThreshold = param
            # All methods based on holding a certain item or using a certain item on the pokemon
            when :HoldItem,:HoldItemMale,:HoldItemFemale,:DayHoldItem,:NightHoldItem,
              :Item,:ItemMale,:ItemFemale,:ItemDay,:ItemNight,:ItemHappiness
              
              # Push this prevo if the evolution from it is gated by an item which is available by this point
              evoLevelThreshold = getEarliestLevelForItem(param)
            end
  
            earliestLevelForEvolved = [earliestLevelForBase,evoLevelThreshold].max
  
            if !earliestAquisition.has_key?(evoSpecies) || earliestAquisition[evoSpecies] > earliestLevelForEvolved
              earliestAquisition[evoSpecies] = earliestLevelForEvolved
              madeAnyChanges = true
            end
          end
        end
        break if !madeAnyChanges
      end
  
      earliestAquisition.each do |species,level|
        GameData::Species.get(species).earliest_available = level
      end
  
      GameData::Species.save
      Graphics.update
    end
  
    def getEarliestLevelForItem(item_id)
      ITEMS_AVAILABLE_BY_CAP.each do |levelCapBracket, itemArray|
        next unless itemArray.include?(item_id)
        return levelCapBracket
      end
      return 100
    end
  
    def getEarliestLevelForMap(map_id)
      MAPS_AVAILABLE_BY_CAP.each do |levelCapBracket, mapArray|
        next unless mapArray.include?(map_id)
        return levelCapBracket
      end
      return 100
    end
end