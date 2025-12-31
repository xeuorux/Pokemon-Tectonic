module Compiler
    module_function

    #=============================================================================
    # Compile achievement data
    #=============================================================================
    def compile_achievements
        GameData::Achievement::DATA.clear
        schema = GameData::Achievement::SCHEMA
        achievement_names        = []
        achievement_descriptions = []
        baseFiles = ["PBS/achievements.txt"]
        achievementTextFiles = []
        achievementTextFiles.concat(baseFiles)
        achievementExtensions = Compiler.get_extensions("achievements")
        achievementTextFiles.concat(achievementExtensions)
        achievementTextFiles.each do |path|
            baseFile = baseFiles.include?(path)
            
            achievement_hash         = nil
            pbCompilerEachPreppedLine(path) { |line, line_no|
                if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [achievement_id]
                    # Add previous achievement's data to records
                    if achievement_hash
                        # If this is an extension modifying an existing achievement, modify it in-place
                        if achievement_hash[:defined_in_extension] && GameData::Achievement::DATA[achievement_hash[:id]]
                            existing_achievement = GameData::Achievement::DATA[achievement_hash[:id]]
                            existing_achievement.instance_variable_set(:@real_name, achievement_hash[:name]) if achievement_hash[:name]
                            existing_achievement.instance_variable_set(:@real_description, achievement_hash[:description]) if achievement_hash[:description]
                            existing_achievement.instance_variable_set(:@page, achievement_hash[:page]) if achievement_hash[:page]
                            existing_achievement.instance_variable_set(:@hidden, achievement_hash[:hidden]) if achievement_hash.key?(:hidden)
                            existing_achievement.instance_variable_set(:@disabled_in_randomizer, achievement_hash[:disabled_in_randomizer]) if achievement_hash.key?(:disabled_in_randomizer)
                        else
                            GameData::Achievement.register(achievement_hash)
                        end
                    end
                    # Parse achievement ID
                    achievement_id = $~[1].to_sym
                    if GameData::Achievement.exists?(achievement_id)
                        if !baseFile
                            # Back up base entry for writing base PBS later (only if not already backed up)
                            unless GameData::Achievement::BASE_DATA[achievement_id]
                                old_achievement = GameData::Achievement::DATA[achievement_id]
                                backup_hash = {
                                    :id                     => old_achievement.id,
                                    :id_number              => old_achievement.id_number,
                                    :name                   => old_achievement.real_name,
                                    :description            => old_achievement.real_description,
                                    :page                   => old_achievement.page,
                                    :hidden                 => old_achievement.hidden,
                                    :disabled_in_randomizer => old_achievement.disabled_in_randomizer,
                                    :defined_in_extension   => old_achievement.instance_variable_get(:@defined_in_extension)
                                }
                                GameData::Achievement::BASE_DATA[achievement_id] = GameData::Achievement.new(backup_hash)
                            end
                            # Extension is modifying an existing achievement - will merge below
                        else
                            raise _INTL("Achievement ID '{1}' is used twice.\r\n{2}", achievement_id, FileLineData.linereport)
                        end
                    end
                    # Construct achievement hash
                    achievement_hash = {
                        :id                     => achievement_id,
                        :defined_in_extension   => !baseFile,
                    }
                elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
                    if !achievement_hash
                        raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
                    end
                    # Parse property and value
                    property_name = $~[1]
                    line_schema = schema[property_name]
                    next if !line_schema
                    property_value = pbGetCsvRecord($~[2], line_no, line_schema)
                    # Record XXX=YYY setting
                    achievement_hash[line_schema[0]] = property_value
                    case property_name
                    when "Name"
                        achievement_names.push(achievement_hash[:name])
                    when "Description"
                        achievement_descriptions.push(achievement_hash[:description])
                    end
                end
            }
            # Add last achievement's data to records
            if achievement_hash
                # If this is an extension modifying an existing achievement, modify it in-place
                if achievement_hash[:defined_in_extension] && GameData::Achievement::DATA[achievement_hash[:id]]
                    existing_achievement = GameData::Achievement::DATA[achievement_hash[:id]]
                    existing_achievement.instance_variable_set(:@real_name, achievement_hash[:name]) if achievement_hash[:name]
                    existing_achievement.instance_variable_set(:@real_description, achievement_hash[:description]) if achievement_hash[:description]
                    existing_achievement.instance_variable_set(:@page, achievement_hash[:page]) if achievement_hash[:page]
                    existing_achievement.instance_variable_set(:@hidden, achievement_hash[:hidden]) if achievement_hash.key?(:hidden)
                    existing_achievement.instance_variable_set(:@disabled_in_randomizer, achievement_hash[:disabled_in_randomizer]) if achievement_hash.key?(:disabled_in_randomizer)
                else
                    GameData::Achievement.register(achievement_hash)
                end
            end
        end

        # Save all data
        GameData::Achievement.save
        MessageTypes.setMessagesAsHash(MessageTypes::Achievements, achievement_names)
        MessageTypes.setMessagesAsHash(MessageTypes::AchievementDescs, achievement_descriptions)
        Graphics.update
    end

    #=============================================================================
    # Save achievement data to PBS file
    #=============================================================================
    def write_achievements
        File.open("PBS/achievements.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Achievement.each_base do |a|
                write_achievement(f, a)
            end
        end
        Graphics.update
    end

    def write_achievement(f, achievement)
        # Use backed-up base data if it exists (i.e., if an extension modified this achievement)
        achievement_to_write = GameData::Achievement::BASE_DATA[achievement.id] || achievement
        f.write("\#-------------------------------\r\n")
        f.write("[#{achievement_to_write.id}]\r\n")
        f.write("Name = #{achievement_to_write.real_name}\r\n")
        f.write("Description = #{achievement_to_write.real_description}\r\n")
        f.write("Page = #{achievement_to_write.page}\r\n")
        f.write("Hidden = true\r\n") if achievement_to_write.hidden
        f.write("DisabledInRandomizer = true\r\n") if achievement_to_write.disabled_in_randomizer?
    end
end

module GameData
    class Achievement
        attr_reader :id
        attr_reader :id_number
        attr_reader :real_name
        attr_reader :real_description
        attr_reader :hidden
        attr_reader :page
        attr_reader :disabled_in_randomizer

        DATA = {}
        BASE_DATA = {} # Data that hasn't been extended
        DATA_FILENAME = "achievements.dat"

        extend ClassMethodsSymbols
        include InstanceMethods

        SCHEMA = {
            "Name"                  => [:name,                      "s"],
            "Description"           => [:description,               "q"],
            "Page"                  => [:page,                      "y"],
            "Hidden"                => [:hidden,                    "B"],
            "DisabledInRandomizer"  => [:disabled_in_randomizer,    "B"],
        }
        
        def initialize(hash)
            @id                     = hash[:id]
            @id_number              = hash[:id_number]    || -1
            @real_name              = hash[:name]         || "Unnamed"
            @real_description       = hash[:description]  || "???"
            @page                   = hash[:page]         || 0
            @hidden                 = hash[:hidden]       || false
            @disabled_in_randomizer = hash[:disabled_in_randomizer] || false
            @defined_in_extension   = hash[:defined_in_extension] || false
        end

        # @return [String] the translated name of this achievement
        def name
            return pbGetMessageFromHash(MessageTypes::Achievements, @real_name)
        end

        # @return [String] the translated description of this achievement
        def description
            return pbGetMessageFromHash(MessageTypes::AchievementDescs, @real_description)
        end

        def disabled_in_randomizer?
            return @disabled_in_randomizer
        end

        def self.each
            keys = self::DATA.keys.sort { |a, b|
                dataA = self::DATA[a]
                dataB = self::DATA[b]
                if dataA.page == dataB.page
                    if dataA.hidden == dataB.hidden
                        next dataA.id <=> dataB.id
                    elsif dataA.hidden
                        next 1
                    elsif dataB.hidden
                        next -1
                    end
                else
                    next dataA.page <=> dataB.page
                end
            }
            keys.each { |key| yield self::DATA[key] }
        end
    end
end