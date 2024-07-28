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
                    GameData::Achievement.register(achievement_hash) if achievement_hash
                    # Parse achievement ID
                    achievement_id = $~[1].to_sym
                    if GameData::Achievement.exists?(achievement_id)
                        raise _INTL("Achievement ID '{1}' is used twice.\r\n{2}", achievement_id, FileLineData.linereport)
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
            GameData::Achievement.register(achievement_hash) if achievement_hash
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
        f.write("\#-------------------------------\r\n")
        f.write("[#{achievement.id}]\r\n")
        f.write("Name = #{achievement.real_name}\r\n")
        f.write("Description = #{achievement.real_description}\r\n")
        f.write("Page = #{achievement.page}\r\n")
        f.write("Hidden = true\r\n") if achievement.hidden
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

        DATA = {}
        DATA_FILENAME = "achievements.dat"

        extend ClassMethodsSymbols
        include InstanceMethods

        SCHEMA = {
            "Name"         => [:name,        "s"],
            "Description"  => [:description, "q"],
            "Page"         => [:page,      "y"],
            "Hidden"       => [:hidden,      "B"],
        }
        
        def initialize(hash)
            @id                     = hash[:id]
            @id_number              = hash[:id_number]    || -1
            @real_name              = hash[:name]         || "Unnamed"
            @real_description       = hash[:description]  || "???"
            @page                   = hash[:page]         || 0
            @hidden                 = hash[:hidden]       || false
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