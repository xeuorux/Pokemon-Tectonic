module Compiler
    module_function

    #=============================================================================
    # Compile ability data
    #=============================================================================
    def compile_abilities
        GameData::Ability::DATA.clear
        schema = GameData::Ability::SCHEMA
        ability_names        = []
        ability_descriptions = []
        baseFiles = ["PBS/abilities.txt", "PBS/abilities_new.txt", "PBS/abilities_primeval.txt", "PBS/abilities_cut.txt"]
        abilityTextFiles = []
        abilityTextFiles.concat(baseFiles)
        abilityExtensions = Compiler.get_extensions("abilities")
        abilityTextFiles.concat(abilityExtensions)
        abilityTextFiles.each do |path|
            cutAbility = path == "PBS/abilities_cut.txt"
            primevalAbility = path == "PBS/abilities_primeval.txt"
            newAbility = ["PBS/abilities_new.txt", "PBS/abilities_primeval.txt"].include?(path) || abilityExtensions.include?(path)
            baseFile = baseFiles.include?(path)
            
            ability_hash         = nil
            pbCompilerEachPreppedLine(path) { |line, line_no|
                if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [ability_id]
                    # Add previous ability's data to records
                    GameData::Ability.register(ability_hash) if ability_hash
                    # Parse ability ID
                    ability_id = $~[1].to_sym
                    if GameData::Ability.exists?(ability_id)
                        raise _INTL("Ability ID '{1}' is used twice.\r\n{2}", ability_id, FileLineData.linereport)
                    end
                    # Construct ability hash
                    ability_hash = {
                        :id                     => ability_id,
                        :cut                    => cutAbility,
                        :tectonic_new           => newAbility,
                        :primeval               => primevalAbility,
                        :defined_in_extension   => !baseFile,
                    }
                elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
                    if !ability_hash
                        raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
                    end
                    # Parse property and value
                    property_name = $~[1]
                    line_schema = schema[property_name]
                    next if !line_schema
                    property_value = pbGetCsvRecord($~[2], line_no, line_schema)
                    # Record XXX=YYY setting
                    ability_hash[line_schema[0]] = property_value
                    case property_name
                    when "Name"
                        ability_names.push(ability_hash[:name])
                    when "Description"
                        ability_descriptions.push(ability_hash[:description])
                    end
                end
            }
            # Add last ability's data to records
            GameData::Ability.register(ability_hash) if ability_hash
        end

        # Save all data
        GameData::Ability.save
        MessageTypes.setMessagesAsHash(MessageTypes::Abilities, ability_names)
        MessageTypes.setMessagesAsHash(MessageTypes::AbilityDescs, ability_descriptions)
        Graphics.update

        BattleHandlers::LoadDataDependentAbilityHandlers.trigger
    end

    #=============================================================================
    # Save ability data to PBS file
    #=============================================================================
    def write_abilities
        File.open("PBS/abilities.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each_base do |a|
                next if a.cut || a.primeval || a.tectonic_new
                write_ability(f, a)
            end
        end
        File.open("PBS/abilities_new.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each_base do |a|
                next unless a.tectonic_new && !a.primeval
                write_ability(f, a)
            end
        end
        File.open("PBS/abilities_cut.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each_base do |a|
                next unless a.cut
                write_ability(f, a)
            end
        end
        File.open("PBS/abilities_primeval.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each_base do |a|
                next unless a.primeval
                write_ability(f, a)
            end
        end
        Graphics.update
    end

    def write_ability(f, ability)
        f.write("\#-------------------------------\r\n")
        f.write("[#{ability.id}]\r\n")
        f.write("Name = #{ability.real_name}\r\n")
        f.write("Description = #{ability.real_description}\r\n")
        f.write(sprintf("Flags = %s\r\n", ability.flags.join(","))) if ability.flags.length > 0
    end
end

module GameData
    class Ability
        attr_reader :signature_of, :cut, :primeval, :tectonic_new
        attr_reader :id
        attr_reader :id_number
        attr_reader :real_name
        attr_reader :real_description
        attr_reader :flags

        DATA = {}
        DATA_FILENAME = "abilities.dat"

        FLAG_INDEX = {}
        FLAGS_INDEX_DATA_FILENAME = "abilities_indexed_by_flag.dat"

        extend ClassMethodsSymbols
        include InstanceMethods

        SCHEMA = {
            "Name"         => [:name,        "s"],
            "Description"  => [:description, "q"],
            "Flags"        => [:flags,       "*s"]
        }
        
        def initialize(hash)
            @id                     = hash[:id]
            @id_number              = hash[:id_number]    || -1
            @real_name              = hash[:name]         || "Unnamed"
            @real_description       = hash[:description]  || "???"
            @flags                  = hash[:flags]       || []
            @cut                    = hash[:cut]          || false
            @primeval               = hash[:primeval]     || false
            @tectonic_new           = hash[:tectonic_new] || false
            @defined_in_extension   = hash[:defined_in_extension] || false

            @flags.each do |flag|
                if FLAG_INDEX.key?(flag)
                    FLAG_INDEX[flag].push(@id)
                else
                    FLAG_INDEX[flag] = [@id]
                end
            end
        end

        # @return [String] the translated name of this ability
        def name
            return pbGetMessageFromHash(MessageTypes::Abilities, @real_name)
        end

        # @return [String] the translated description of this ability
        def description
            return pbGetMessageFromHash(MessageTypes::AbilityDescs, @real_description)
        end

        # The highest evolution of a line
        def signature_of=(val)
            @signature_of = val
        end
  
        def is_signature?()
            return !@signature_of.nil?
        end

        def legal?(isBoss = false)
            return false if @cut
            return false if @primeval && !isBoss
            return true
        end

        def is_all_weather_synergy_ability?
            return @flags.include?("AllWeatherSynergy")
        end

        def is_sun_synergy_ability?
            return @flags.include?("SunshineSynergy")
        end

        def is_rain_synergy_ability?
            return @flags.include?("RainstormSynergy")
        end

        def is_sand_synergy_ability?
            return @flags.include?("SandstormSynergy")
        end

        def is_hail_synergy_ability?
            return @flags.include?("HailSynergy")
        end

        def is_eclipse_synergy_ability?
            return @flags.include?("EclipseSynergy")
        end

        def is_moonglow_synergy_ability?
            return @flags.include?("MoonglowSynergy")
        end
        
        def is_multiple_item_ability?
            return @flags.include?("MultipleItems")
        end

        def is_flinch_immunity_ability?
            return @flags.include?("FlinchImmunity")
        end

        def is_uncopyable_ability?
            return true if is_immutable_ability?
            return @flags.include?("Uncopyable")
        end

        def is_hazard_immunity_ability?
            return @flags.include?("HazardImmunity")
        end

        def is_mold_breaking_ability?
            return @flags.include?("MoldBreaking")
        end

        def is_choice_locking_ability?
            return @flags.include?("ChoiceLocking")
        end

        def is_setup_counter_ability_ai?
            return @flags.include?("SetupCounterAI")
        end

        def is_immutable_ability?
            return @flags.include?("Immutable")
        end

        def self.getByFlag(flag)
            if FLAG_INDEX.key?(flag)
              return FLAG_INDEX[flag]
            else
              return []
            end
        end

        def self.load
            super
            const_set(:FLAG_INDEX, load_data("Data/#{self::FLAGS_INDEX_DATA_FILENAME}"))
        end
    
        def self.save
            super
            save_data(self::FLAG_INDEX, "Data/#{self::FLAGS_INDEX_DATA_FILENAME}")
        end
    end
end