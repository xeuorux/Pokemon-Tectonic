module Compiler
	module_function
  
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
end