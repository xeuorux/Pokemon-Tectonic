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
    old_format_current_line   = 0
    old_format_expected_lines = 0
    # Read each line of trainers.txt at a time and compile it as a trainer property
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if old_format_current_line > 0
            raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
          end
          if !current_pkmn
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
          :id_number    => trainer_id,
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
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
        when "Pokemon"
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
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts[trainer_id] = property_value if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
		  # The default ability index for a given species of a given trainer should be chaotic, but not random
		  current_pkmn[:ability_index] = jank_hash_code(trainer_hash[:name] + current_pkmn[:species].to_s) % 2
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
      else
        # Old format - backwards compatibility is SUCH fun!
        if old_format_current_line == 0   # Started an old trainer section
          if trainer_hash
            if !current_pkmn
              raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
            end
            # Add trainer's data to records
            trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
            GameData::Trainer.register(trainer_hash)
          end
          trainer_id += 1
          old_format_expected_lines = 3
          # Construct trainer hash
          trainer_hash = {
            :id_number    => trainer_id,
            :trainer_type => nil,
            :name         => nil,
            :version      => 0,
            :pokemon      => []
          }
          current_pkmn = nil
        end
        # Evaluate line and add to hash
        old_format_current_line += 1
        case old_format_current_line
        when 1   # Trainer type
          line_data = pbGetCsvRecord(line, line_no, [0, "e", :TrainerType])
          trainer_hash[:trainer_type] = line_data
        when 2   # Trainer name, version number
          line_data = pbGetCsvRecord(line, line_no, [0, "sU"])
          line_data = [line_data] if !line_data.is_a?(Array)
          trainer_hash[:name]    = line_data[0]
          trainer_hash[:version] = line_data[1] if line_data[1]
          trainer_names[trainer_hash[:id_number]] = line_data[0]
        when 3   # Number of Pokémon, items
          line_data = pbGetCsvRecord(line, line_no,
             [0, "vEEEEEEEE", nil, :Item, :Item, :Item, :Item, :Item, :Item, :Item, :Item])
          line_data = [line_data] if !line_data.is_a?(Array)
          line_data.compact!
          old_format_expected_lines += line_data[0]
          line_data.shift
          trainer_hash[:items] = line_data if line_data.length > 0
        else   # Pokémon lines
          line_data = pbGetCsvRecord(line, line_no,
             [0, "evEEEEEUEUBEUUSBU", :Species, nil, :Item, :Move, :Move, :Move, :Move, nil,
                                      {"M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                      "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1},
                                      nil, nil, :Nature, nil, nil, nil, nil, nil])
          current_pkmn = {
            :species => line_data[0]
          }
          trainer_hash[:pokemon].push(current_pkmn)
          # Error checking in properties
          line_data.each_with_index do |value, i|
            next if value.nil?
            case i
            when 1   # Level
              if value > max_level
                raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", value, max_level, FileLineData.linereport)
              end
            when 12   # IV
              if value > Pokemon::IV_STAT_LIMIT
                raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", value, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
              end
            when 13   # Happiness
              if value > 255
                raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", value, FileLineData.linereport)
              end
            when 14   # Nickname
              if value.length > Pokemon::MAX_NAME_SIZE
                raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
              end
            end
          end
          # Write all line data to hash
          moves = [line_data[3], line_data[4], line_data[5], line_data[6]]
          moves.uniq!.compact!
          ivs = {}
          if line_data[12]
            GameData::Stat.each_main do |s|
              ivs[s.id] = line_data[12] if s.pbs_order >= 0
            end
          end
          current_pkmn[:level]         = line_data[1]
          current_pkmn[:item]          = line_data[2] if line_data[2]
          current_pkmn[:moves]         = moves if moves.length > 0
          current_pkmn[:ability_index] = line_data[7] if line_data[7]
          current_pkmn[:gender]        = line_data[8] if line_data[8]
          current_pkmn[:form]          = line_data[9] if line_data[9]
          current_pkmn[:shininess]     = line_data[10] if line_data[10]
          current_pkmn[:nature]        = line_data[11] if line_data[11]
          current_pkmn[:iv]            = ivs if ivs.length > 0
          current_pkmn[:happiness]     = line_data[13] if line_data[13]
          current_pkmn[:name]          = line_data[14] if line_data[14] && !line_data[14].empty?
          current_pkmn[:shadowness]    = line_data[15] if line_data[15]
          current_pkmn[:poke_ball]     = line_data[16] if line_data[16]
          # Check if this is the last expected Pokémon
          old_format_current_line = 0 if old_format_current_line >= old_format_expected_lines
        end
      end
    }
    if old_format_current_line > 0
      raise _INTL("Unexpected end of file, last trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
    end
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
  # Main compiler method for events
  #=============================================================================
  def compile_trainer_events(_mustcompile)
    mapData = MapData.new
    t = Time.now.to_i
    Graphics.update
    trainerChecker = TrainerChecker.new
    for id in mapData.mapinfos.keys.sort
      changed = false
      map = mapData.getMap(id)
      next if !map || !mapData.mapinfos[id]
      pbSetWindowText(_INTL("Processing map {1} ({2})",id,mapData.mapinfos[id].name))
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
		newevent = convert_overworldPkmn_event(map.events[key])
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
  
  #=============================================================================
  # Add cry actions to overworld pokemon events which don't already have scripted behaviour.
  #=============================================================================
  def convert_overworldPkmn_event(event)
    return nil if !event || event.pages.length==0
	match = event.name.match(/.*overworld\((.*)_?([0-9]*)\).*/)
	return nil if !match
    ret = RPG::Event.new(event.x,event.y)
    ret.name = event.name.sub("nocry","")
    ret.id   = event.id
	ret.pages = []
	speciesName = match[1]
	return nil if !speciesName || speciesName == ""
	form = match[2]
	form = 0 if !form || form == ""
	speciesNamePretty = GameData::Species.get(speciesName.to_sym).real_name
	changedAny = false
	for pagenum in 0...event.pages.length
		page = Marshal::load(Marshal.dump(event.pages[pagenum]))
		# If this is definitely an overworld placeholder page, and there is not already scripting on this page
		if page.graphic.character_name == "00Overworld Placeholder" && page.list.length == 1
			echo("Doing a cry replacement for event: #{event.name}\n")
			page.trigger = 0 # Action button
			page.list = []
			push_script(page.list,sprintf("Pokemon.play_cry(:%s, %d)",speciesName,form))
			push_script(page.list,sprintf("pbMessage(\"#{speciesNamePretty} cries out!\")",))
			push_end(page.list)
			changedAny = true
		end
		ret.pages.push(page)
	end
	return nil if !changedAny
	return ret
  end
end

def jank_hash_code(str)
  result = 0
  for i in 0..(str.length - 1)
    result += str[i].to_i
  end
  return result
end