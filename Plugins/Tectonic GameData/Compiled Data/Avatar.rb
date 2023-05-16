module Compiler
	module_function

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
  
	def pbEachAvatarFileSection(f)
	  pbEachFileSectionEx(f) { |section,name|
		  yield section,name if block_given? && name[/^[a-zA-Z0-9_]+$/]
	  }
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
			f.write(sprintf("Ability = %s\r\n", avatar.abilities.join(",")))
			f.write(sprintf("Moves1 = %s\r\n", avatar.moves1.join(",")))
			f.write(sprintf("Moves2 = %s\r\n", avatar.moves2.join(","))) if !avatar.moves2.nil? && avatar.num_phases >= 2
			f.write(sprintf("Moves3 = %s\r\n", avatar.moves3.join(","))) if !avatar.moves3.nil? && avatar.num_phases >= 3
			f.write(sprintf("Moves4 = %s\r\n", avatar.moves4.join(","))) if !avatar.moves4.nil? && avatar.num_phases >= 4
			f.write(sprintf("Moves5 = %s\r\n", avatar.moves5.join(","))) if !avatar.moves5.nil? && avatar.num_phases >= 5
			f.write(sprintf("Turns = %s\r\n", avatar.num_turns)) if avatar.num_turns != DEFAULT_BOSS_TURNS
			f.write(sprintf("HPMult = %s\r\n", avatar.hp_mult)) if avatar.hp_mult != DEFAULT_BOSS_HP_MULT
			f.write(sprintf("HealthBars = %s\r\n", avatar.num_health_bars)) if avatar.num_health_bars != avatar.num_phases
			f.write(sprintf("Item = %s\r\n", avatar.item)) if !avatar.item.nil?
			f.write(sprintf("DMGMult = %s\r\n", avatar.dmg_mult)) if avatar.dmg_mult != DEFAULT_BOSS_DAMAGE_MULT
			f.write(sprintf("DMGResist = %s\r\n", avatar.dmg_resist)) if avatar.dmg_resist != 0.0
			f.write(sprintf("Form = %s\r\n", avatar.form)) if avatar.form != 0
			f.write(sprintf("Aggression = %s\r\n", avatar.aggression)) if avatar.aggression != PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION
		end
		}
		pbSetWindowText(nil)
		Graphics.update
	end
end

module GameData
	class Avatar
		attr_reader :id
		attr_reader :id_number
		attr_reader :num_turns
		attr_reader :species
		attr_reader :form
		attr_reader :moves1
		attr_reader :moves2
		attr_reader :moves3
		attr_reader :moves4
		attr_reader :moves5
		attr_reader :post_prime_moves
		attr_reader :abilities
		attr_reader :item
		attr_reader :hp_mult
		attr_reader :dmg_mult
		attr_reader :dmg_resist
		attr_reader :num_phases
		attr_reader :num_health_bars
		attr_reader :aggression
	
		DATA = {}
		DATA_FILENAME = "avatars.dat"

		SCHEMA = {
		  "Turns"         		=> [:turns,          	"u"],
		  "Form"         		=> [:form,          	"U"],
		  "Moves1"        		=> [:moves1,         	"*e", :Move],
		  "Moves2"      		=> [:moves2,			"*E", :Move],
		  "Moves3"      		=> [:moves3,			"*E", :Move],
		  "Moves4"      		=> [:moves4,			"*E", :Move],
		  "Moves5"      		=> [:moves5,			"*E", :Move],
		  "Ability"      		=> [:abilities,       	"*e", :Ability],
		  "Item"         		=> [:item,          	"e", :Item],
		  "HPMult"				=> [:hp_mult,			"f"],
		  "DMGMult"				=> [:dmg_mult,			"F"],
		  "DMGResist"			=> [:dmg_resist,		"F"],
		  "HealthBars"			=> [:health_bars,		"U"],
		  "Aggression"			=> [:aggression,		"U"],
		}

		extend ClassMethods
		include InstanceMethods
		
		def initialize(hash)
		  @id               = hash[:id]
		  @id_number        = hash[:id_number]
		  @num_turns        = hash[:turns] || DEFAULT_BOSS_TURNS
		  @species			= @id.to_s.split('_')[0].to_sym
		  @form             = hash[:form] || 0
		  @moves1        	= hash[:moves1]
		  @moves2 			= hash[:moves2] || []
		  @moves3 			= hash[:moves3] || []
		  @moves4 			= hash[:moves4] || []
		  @moves5 			= hash[:moves5] || []
		  @abilities        = hash[:abilities]
		  @item             = hash[:item]
		  @hp_mult			= hash[:hp_mult] || DEFAULT_BOSS_HP_MULT
		  @dmg_mult 		= hash[:dmg_mult] || DEFAULT_BOSS_DAMAGE_MULT
		  @dmg_resist		= hash[:dmg_resist] || 0
		  @aggression		= hash[:aggression] || PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION

		  raise _INTL("The Avatar definition for #{@id} has no first moves defined!") if @moves1.nil?

		  @num_phases = 1
		  if @moves2.length > 0
			@num_phases += 1
			if @moves3.length > 0
				@num_phases += 1
				if @moves4.length > 0
					@num_phases += 1
					if @moves5.length > 0
						@num_phases += 1
					end
				end
			end
		  end

		  @num_health_bars = hash[:health_bars] || @num_phases

		  @abilities.each do |abilityID|
			next unless abilityID
            next if GameData::Ability.get(abilityID).legal?(true)
            raise _INTL("Cut ability #{abilityID} is assigned to avatar #{@id}!")
		  end
		end

		def second_status?
			return @num_health_bars > 1
		end

		def arrayOfMoveSets
			return [@moves1,@moves2,@moves3,@moves4,@moves5]
		end

		def getListOfPhaseTypes
			phaseTypes = [nil]
			arrayOfMoveSets.each do |moveSet|
				moveSet.each do |move|
					moveData = GameData::Move.get(move)

					if moveData.empoweredMove? && moveData.category == 2
						phaseTypes.push(moveData.type)
					end
				end
			end

			return phaseTypes
		end

		def getTypeForPhase(index)
			return getListOfPhaseTypes[]
		end

		def self.get_from_species_form(speciesForm)
			if DATA.has_key?(speciesForm)
				return self.get(speciesForm)
			else
				species = speciesForm.to_s.split('_')[0].to_sym
				return self.get(species)
			end
		end

		def self.get_from_pokemon(pokemon)
			avatar_data = nil
			if pokemon.form != 0
				speciesFormSymbol = (pokemon.species.to_s + "_" + pokemon.form.to_s).to_sym
				avatar_data = GameData::Avatar.get_from_species_form(speciesFormSymbol)
			else
				avatar_data = GameData::Avatar.get(pokemon.species.to_sym)
			end
			return avatar_data
		end
	end
end