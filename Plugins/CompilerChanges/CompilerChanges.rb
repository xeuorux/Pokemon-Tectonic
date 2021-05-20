module Compiler
	module_function

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
          :shadow_size           => contents["BattlerShadowSize"]
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
end