module GameData
    class Avatar
        attr_reader :id
        attr_reader :id_number
        attr_reader :version
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
		attr_reader :pit_avatar

        DATA = {}
        DATA_FILENAME = "avatars.dat"

        SCHEMA = {
          "Turns" 				=> [:turns,			"u"],
          "Form" 				=> [:form,			"U"],
          "Moves1" 				=> [:moves1,        "*e", 	:Move],
          "Moves2"      		=> [:moves2,		"*E", 	:Move],
          "Moves3"      		=> [:moves3,		"*E", 	:Move],
          "Moves4"      		=> [:moves4,		"*E", 	:Move],
          "Moves5"      		=> [:moves5,		"*E", 	:Move],
          "Ability"      		=> [:abilities,		"*e", 	:Ability],
          "Item"         		=> [:item,			"e", 	:Item],
          "HPMult"				=> [:hp_mult,		"f"],
          "DMGMult"				=> [:dmg_mult,		"F"],
          "DMGResist"			=> [:dmg_resist,	"F"],
          "HealthBars"			=> [:health_bars,	"U"],
          "Aggression"			=> [:aggression,	"U"],
        }

        extend ClassMethods
        include InstanceMethods

        # @param avatar_species [Symbol, String]
        # @param avatar_version [Integer, nil]
        # @return [Boolean] whether the given other is defined as a self
        def self.exists?(avatar_species, avatar_version = 0)
            validate avatar_species => [Symbol, String]
            key = [avatar_species.to_sym, avatar_version]
            return !self::DATA[key].nil?
        end

        # @param avatar_species [Symbol, String]
        # @param avatar_version [Integer, nil]
        # @return [self]
        def self.get(avatar_species, avatar_version = 0)
            validate avatar_species => [Symbol, String]
            key = [avatar_species.to_sym, avatar_version]
            raise "Unknown avatar #{avatar_species} #{avatar_version}." unless self::DATA.has_key?(key)
            return self::DATA[key]
        end

        # @param avatar_species [Symbol, String]
        # @param avatar_version [Integer, nil]
        # @return [self, nil]
        def self.try_get(avatar_species, avatar_version = 0)
            validate avatar_species => [Symbol, String]
            key = [avatar_species.to_sym, avatar_version]
            return self::DATA.has_key?(key) ? self::DATA[key] : nil
        end

        @@pit_avatars = []

        def self.getPitAvatars
            if @@pit_avatars.empty?
                each do |avatar_data|
                    next unless avatar_data.pit_avatar
                    @@pit_avatars.push(avatar_data)
                end
            end
            return @@pit_avatars
        end

        def self.randomPitAvatar
            return getPitAvatars.sample
        end

        def initialize(hash)
            @id			= hash[:id]
            @id_number	= hash[:id_number]
            @version	= hash[:version] || 0
            @species	= hash[:species]
            @num_turns	= hash[:turns] || DEFAULT_BOSS_TURNS
            @form		= hash[:form] || 0
            @moves1		= hash[:moves1]
            @moves2		= hash[:moves2] || []
            @moves3		= hash[:moves3] || []
            @moves4		= hash[:moves4] || []
            @moves5		= hash[:moves5] || []
            @abilities	= hash[:abilities]
            @item		= hash[:item]
            @hp_mult	= hash[:hp_mult] || DEFAULT_BOSS_HP_MULT
            @dmg_mult	= hash[:dmg_mult] || DEFAULT_BOSS_DAMAGE_MULT
            @dmg_resist	= hash[:dmg_resist] || 0
            @aggression	= hash[:aggression] || PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION
            @defined_in_extension   = hash[:defined_in_extension] || false

            @pit_avatar  = hash[:pit_avatar] || false

            @@pit_avatars.push(self) if @pit_avatar

            raise _INTL("The Avatar definition for #{@id} has no first moves defined!") if @moves1.nil?

            @num_phases = 1
            if @moves2.length > 0
                @num_phases += 1
                if @moves3.length > 0
                    @num_phases += 1
                    if @moves4.length > 0
                        @num_phases += 1
                        @num_phases += 1 if @moves5.length > 0
                    end
                end
            end

            @num_health_bars = hash[:health_bars] || @num_phases

            @abilities.each do |abilityID|
                next unless abilityID
                next if GameData::Ability.get(abilityID).legal?(true)
                raise _INTL("Cut ability #{abilityID} is assigned to avatar #{@id}!")
            end

            [@moves1, @moves2, @moves3, @moves4, @moves5].flatten.each do |moveID|
                moveData = GameData::Move.get(moveID)
                next unless moveData.cut
                raise _INTL("Illegal move #{moveID} is assigned to avatar #{@id}!")
            end
        end

        def second_status?
            return @num_health_bars > 1
        end

        def arrayOfMoveSets
            return [@moves1, @moves2, @moves3, @moves4, @moves5]
        end

        def getListOfPhaseTypes
            phaseTypes = [nil]
            arrayOfMoveSets.each do |moveSet|
                moveSet.each do |move|
                    moveData = GameData::Move.get(move)
                    phaseTypes.push(moveData.type) if moveData.empoweredMove? && moveData.status?
                end
            end

            return phaseTypes
        end

        def getTypeForPhase(index)
            return getListOfPhaseTypes[index]
        end
        
        def self.get_from_pokemon(pokemon)
			return GameData::Avatar.get(pokemon.species,pokemon.bossVersion)
        end
    end
end

module Compiler
    module_function

    def compile_avatars
        GameData::Avatar::DATA.clear
        baseFiles = ["PBS/avatars.txt","PBS/avatars_pit.txt"]
        avatarTextFiles = []
        avatarTextFiles.concat(baseFiles)
        avatarExtensions = Compiler.get_extensions("avatars")
        avatarTextFiles.concat(avatarExtensions)
        avatarTextFiles.each do |path|
			isPit = path == "PBS/avatars_pit.txt"
            baseFile = baseFiles.include?(path)
			# Read from PBS file
			File.open(path, "rb") do |f|
				FileLineData.file = path # For error reporting
				# Read a whole section's lines at once, then run through this code.
				# contents is a hash containing all the XXX=YYY lines in that section, where
				# the keys are the XXX and the values are the YYY (as unprocessed strings).
				schema = GameData::Avatar::SCHEMA
				avatar_number = 1
				pbEachAvatarFileSection(f) do |contents, avatar_species, avatar_version|
					FileLineData.setSection(avatar_species, "header", nil) # For error reporting
	
					# Raise an error if a species is invalid or used twice
					if avatar_species == ""
						raise _INTL("An Avatar entry name can't be blank (PBS/avatars.txt).")
					elsif !GameData::Avatar::DATA[[avatar_species,avatar_version]].nil?
						raise _INTL("Avatar name '{1}' and version '{2}' is used twice.\r\n{3}", avatar_species, avatar_version, FileLineData.linereport)
					end
	
					speciesData = GameData::Species.get_species_form(avatar_species, contents["Form"].to_i || 0)
	
					# Go through schema hash of compilable data and compile this section
					for key in schema.keys
						# Skip empty properties, or raise an error if a required property is
						# empty
						if contents[key].nil? || contents[key] == ""
							if %w[Ability Moves1].include?(key)
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
								next unless !speciesData.abilities.concat(speciesData.hidden_abilities).include?(ability) &&
											!ability.to_s.downcase.include?("primeval")
								echoln(_INTL("Ability {1} is not legal for the Avatar defined in PBS/avatars.txt section {2}.", ability, avatar_species))
							end
						when "Aggression"
							if value < 0 || value > PokeBattle_AI_Boss::MAX_BOSS_AGGRESSION
								raise _INTL(
									"Aggression value {1} is not legal for the Avatar defined in PBS/avatars.txt section {2}. Aggression must be between 0 and {3} (inclusive)", value, avatar_species, PokeBattle_AI_Boss::MAX_BOSS_AGGRESSION)
							end
						end
					end
	
					# Construct avatar hash
					avatar_hash = {
					  :id_number		=> avatar_number,
					  :species			=> avatar_species,
					  :version			=> avatar_version, 
					  :turns			=> contents["Turns"],
					  :form				=> contents["Form"],
					  :moves1			=> contents["Moves1"],
					  :moves2			=> contents["Moves2"],
					  :moves3			=> contents["Moves3"],
					  :moves4			=> contents["Moves4"],
					  :moves5			=> contents["Moves5"],
					  :abilities		=> contents["Ability"],
					  :item				=> contents["Item"],
					  :hp_mult			=> contents["HPMult"],
					  :dmg_mult			=> contents["DMGMult"],
					  :dmg_resist		=> contents["DMGResist"],
					  :health_bars		=> contents["HealthBars"],
					  :aggression		=> contents["Aggression"],
					  :pit_avatar		=> isPit,
                      :defined_in_extension   => !baseFile,
					}
					avatar_number += 1
					# Add avatar's data to records
					avatar_hash[:id] = [avatar_hash[:species], avatar_hash[:version]]
					GameData::Avatar.register(avatar_hash)
				end
			end
		end

        # Save all data
        GameData::Avatar.save
        Graphics.update

        #createBossSpritesAllSpeciesForms(false)
    end

    def pbEachAvatarFileSection(f)
		return unless block_given?
        pbEachFileSectionEx(f) do |section, name|
			match = name.match(/^\s*\s*([A-Za-z0-9]+)\s*(?>,([0-9]+))?\s*\s*$/)
			next unless match
			avatar_species = match[1].to_sym
			avatar_version = match[2].to_i || 0
            yield section, avatar_species, avatar_version
        end
    end

    #=============================================================================
    # Save individual trainer data to PBS file
    #=============================================================================
    def write_avatars
        File.open("PBS/avatars.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Avatar.each_base do |avatar|
                next if avatar.pit_avatar
				write_avatar_to_file(avatar, f)
            end
        end
		File.open("PBS/avatars_pit.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Avatar.each_base do |avatar|
                next unless avatar.pit_avatar
				write_avatar_to_file(avatar, f)
            end
        end
        pbSetWindowText(nil)
        Graphics.update
    end

	def write_avatar_to_file(avatar, f)
		pbSetWindowText(_INTL("Writing avatar {1}...", avatar.id_number))
		Graphics.update if avatar.id_number % 20 == 0
		f.write("\#-------------------------------\r\n")
		if avatar.version > 0
			f.write(format("[%s,%d]\r\n", avatar.species, avatar.version))
		else
			f.write(format("[%s]\r\n", avatar.species))
		end
		f.write(format("Ability = %s\r\n", avatar.abilities.join(",")))
		f.write(format("Moves1 = %s\r\n", avatar.moves1.join(",")))
		if !avatar.moves2.nil? && avatar.num_phases >= 2
			f.write(format("Moves2 = %s\r\n", avatar.moves2.join(",")))
		end
		if !avatar.moves3.nil? && avatar.num_phases >= 3
			f.write(format("Moves3 = %s\r\n", avatar.moves3.join(",")))
		end
		if !avatar.moves4.nil? && avatar.num_phases >= 4
			f.write(format("Moves4 = %s\r\n", avatar.moves4.join(",")))
		end
		if !avatar.moves5.nil? && avatar.num_phases >= 5
			f.write(format("Moves5 = %s\r\n", avatar.moves5.join(",")))
		end
		f.write(format("Turns = %s\r\n", avatar.num_turns)) if avatar.num_turns != DEFAULT_BOSS_TURNS
		f.write(format("HPMult = %s\r\n", avatar.hp_mult)) if avatar.hp_mult != DEFAULT_BOSS_HP_MULT
		if avatar.num_health_bars != avatar.num_phases
			f.write(format("HealthBars = %s\r\n", avatar.num_health_bars))
		end
		f.write(format("Item = %s\r\n", avatar.item)) unless avatar.item.nil?
		f.write(format("DMGMult = %s\r\n", avatar.dmg_mult)) if avatar.dmg_mult != DEFAULT_BOSS_DAMAGE_MULT
		f.write(format("DMGResist = %s\r\n", avatar.dmg_resist)) if avatar.dmg_resist != 0.0
		f.write(format("Form = %s\r\n", avatar.form)) if avatar.form != 0
		if avatar.aggression != PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION
			f.write(format("Aggression = %s\r\n", avatar.aggression))
		end
	end
end