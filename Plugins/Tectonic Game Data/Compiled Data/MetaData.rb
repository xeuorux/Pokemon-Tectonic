module GameData
    class Metadata
        attr_reader :id
        attr_reader :home
        attr_reader :wild_battle_BGM
        attr_reader :trainer_battle_BGM
        attr_reader :avatar_battle_BGM
        attr_reader :legendary_avatar_battle_BGM
        attr_reader :wild_victory_ME
        attr_reader :trainer_victory_ME
        attr_reader :wild_capture_ME
        attr_reader :surf_BGM
        attr_reader :bicycle_BGM
        attr_reader :player_A
        attr_reader :player_B
        attr_reader :player_C
        attr_reader :player_D
        attr_reader :player_E
        attr_reader :player_F
        attr_reader :player_G
        attr_reader :player_H

        DATA = {}
        DATA_FILENAME = "metadata.dat"

        SCHEMA = {
          "Home"             			=> [1,  "vuuu"],
          "WildBattleBGM"    			=> [2,  "s"],
          "TrainerBattleBGM" 			=> [3,  "s"],
          "AvatarBattleBGM" 			=> [4, "s"],
          "LegendaryAvatarBattleBGM" 	=> [5, "s"],
          "WildVictoryME"    			=> [6,  "s"],
          "TrainerVictoryME" 			=> [7,  "s"],
          "WildCaptureME"    			=> [8,  "s"],
          "SurfBGM"          			=> [9,  "s"],
          "BicycleBGM"       			=> [10,  "s"],
          "PlayerA"          			=> [11,  "esssssss", :TrainerType],
          "PlayerB"          			=> [12, "esssssss", :TrainerType],
          "PlayerC"          			=> [13, "esssssss", :TrainerType],
          "PlayerD"          			=> [14, "esssssss", :TrainerType],
          "PlayerE"          			=> [15, "esssssss", :TrainerType],
          "PlayerF"          			=> [16, "esssssss", :TrainerType],
          "PlayerG"          			=> [17, "esssssss", :TrainerType],
          "PlayerH"          			=> [18, "esssssss", :TrainerType],
        }

        extend ClassMethodsIDNumbers
        include InstanceMethods

        def self.editor_properties
            return [
                ["Home",             			MapCoordsFacingProperty,
                 _INTL("Map ID and X and Y coordinates of where the player goes if no Pokémon Center was entered after a loss."),],
                ["WildBattleBGM",    			BGMProperty,             _INTL("Default BGM for wild Pokémon battles.")],
                ["TrainerBattleBGM", 			BGMProperty,             _INTL("Default BGM for Trainer battles.")],
                ["AvatarBattleBGM", 			BGMProperty, _INTL("Default BGM for Avatar battles.")],
                ["LegendaryAvatarBattleBGM",	BGMProperty, _INTL("Default BGM for Legendary Avatar battles.")],
                ["WildVictoryME",    			MEProperty,
                 _INTL("Default ME played after winning a wild Pokémon battle."),],
                ["TrainerVictoryME", 			MEProperty,
                 _INTL("Default ME played after winning a Trainer battle."),],
                ["WildCaptureME",    			MEProperty,              _INTL("Default ME played after catching a Pokémon.")],
                ["SurfBGM",          			BGMProperty,             _INTL("BGM played while surfing.")],
                ["BicycleBGM",       			BGMProperty,             _INTL("BGM played while on a bicycle.")],
                ["PlayerA",          			PlayerProperty,          _INTL("Specifies player A.")],
                ["PlayerB",          			PlayerProperty,          _INTL("Specifies player B.")],
                ["PlayerC",          			PlayerProperty,          _INTL("Specifies player C.")],
                ["PlayerD",          			PlayerProperty,          _INTL("Specifies player D.")],
                ["PlayerE",          			PlayerProperty,          _INTL("Specifies player E.")],
                ["PlayerF",          			PlayerProperty,          _INTL("Specifies player F.")],
                ["PlayerG",          			PlayerProperty,          _INTL("Specifies player G.")],
                ["PlayerH",          			PlayerProperty,          _INTL("Specifies player H.")],
            ]
        end

        def self.get
            return DATA[0]
        end

        def self.get_player(id)
            case id
            when 0 then return get.player_A
            when 1 then return get.player_B
            when 2 then return get.player_C
            when 3 then return get.player_D
            when 4 then return get.player_E
            when 5 then return get.player_F
            when 6 then return get.player_G
            when 7 then return get.player_H
            end
            return nil
        end

        def initialize(hash)
            @id = hash[:id]
            @home = hash[:home]
            @wild_battle_BGM     			= hash[:wild_battle_BGM]
            @trainer_battle_BGM  			= hash[:trainer_battle_BGM]
            @avatar_battle_BGM   			= hash[:avatar_battle_BGM]
            @legendary_avatar_battle_BGM    = hash[:legendary_avatar_battle_BGM]
            @wild_victory_ME     			= hash[:wild_victory_ME]
            @trainer_victory_ME  			= hash[:trainer_victory_ME]
            @wild_capture_ME     			= hash[:wild_capture_ME]
            @surf_BGM            			= hash[:surf_BGM]
            @bicycle_BGM         			= hash[:bicycle_BGM]
            @player_A            			= hash[:player_A]
            @player_B            			= hash[:player_B]
            @player_C            			= hash[:player_C]
            @player_D            			= hash[:player_D]
            @player_E            			= hash[:player_E]
            @player_F            			= hash[:player_F]
            @player_G            			= hash[:player_G]
            @player_H            			= hash[:player_H]
        end

        def property_from_string(str)
            case str
            when "Home"             			then return @home
            when "WildBattleBGM"    			then return @wild_battle_BGM
            when "TrainerBattleBGM" 			then return @trainer_battle_BGM
            when "AvatarBattleBGM"				then return @avatar_battle_BGM
            when "LegendaryAvatarBattleBGM"		then return @legendary_avatar_battle_BGM
            when "WildVictoryME"    			then return @wild_victory_ME
            when "TrainerVictoryME" 			then return @trainer_victory_ME
            when "WildCaptureME"    			then return @wild_capture_ME
            when "SurfBGM"          			then return @surf_BGM
            when "BicycleBGM"       			then return @bicycle_BGM
            when "PlayerA"          			then return @player_A
            when "PlayerB"          			then return @player_B
            when "PlayerC"          			then return @player_C
            when "PlayerD"          			then return @player_D
            when "PlayerE"          			then return @player_E
            when "PlayerF"          			then return @player_F
            when "PlayerG"          			then return @player_G
            when "PlayerH"          			then return @player_H
            end
            return nil
        end
    end
end

module GameData
    class MapMetadata
        attr_reader :id
        attr_reader :outdoor_map
        attr_reader :announce_location
        attr_reader :can_bicycle
        attr_reader :always_bicycle
        attr_reader :teleport_destination
        attr_reader :weather
        attr_reader :temperature
        attr_reader :humidity
        attr_reader :town_map_position
        attr_reader :dive_map_id
        attr_reader :dark_map
        attr_reader :safari_map
        attr_reader :snap_edges
        attr_reader :random_dungeon
        attr_reader :battle_background
        attr_reader :wild_battle_BGM
        attr_reader :trainer_battle_BGM
        attr_reader :wild_victory_ME
        attr_reader :trainer_victory_ME
        attr_reader :wild_capture_ME
        attr_reader :town_map_size
        attr_reader :battle_environment
        attr_reader :teleport_blocked
        attr_reader :saving_blocked
        attr_reader :no_team_editing

        DATA = {}
        DATA_FILENAME = "map_metadata.dat"

        SCHEMA = {
          "Outdoor"          => [1,  "b"],
          "ShowArea"         => [2,  "b"],
          "Bicycle"          => [3,  "b"],
          "BicycleAlways"    => [4,  "b"],
          "HealingSpot"      => [5,  "vuu"],
          "Weather"          => [6,  "eu", :Weather],
		  "Temperature"		 => [7,  "e", ["Hot", "Cold", "Stable"]],
		  "Humidity"		 => [8,  "e", ["Wet", "Dry", "Stable"]],
          "MapPosition"      => [9,  "uuu"],
          "DiveMap"          => [10,  "v"],
          "DarkMap"          => [11,  "b"],
          "SafariMap"        => [12, "b"],
          "SnapEdges"        => [13, "b"],
          "Dungeon"          => [14, "b"],
          "BattleBack"       => [15, "s"],
          "WildBattleBGM"    => [16, "s"],
          "TrainerBattleBGM" => [17, "s"],
          "WildVictoryME"    => [18, "s"],
          "TrainerVictoryME" => [19, "s"],
          "WildCaptureME"    => [20, "s"],
          "MapSize"          => [21, "us"],
          "Environment"      => [22, "e", :Environment],
          "TeleportBlocked"  => [23, "b"],
          "SavingBlocked"    => [24, "b"],
          "NoTeamEditing"    => [25, "b"],
       }

        extend ClassMethodsIDNumbers
        include InstanceMethods

        def self.editor_properties
            return [
                ["Outdoor", BooleanProperty,
                 _INTL("If true, this map is an outdoor map and will be tinted according to time of day."),],
                ["ShowArea",         BooleanProperty,
                 _INTL("If true, the game will display the map's name upon entry."),],
                ["Bicycle",          BooleanProperty,
                 _INTL("If true, the bicycle can be used on this map."),],
                ["BicycleAlways",    BooleanProperty,
                 _INTL("If true, the bicycle will be mounted automatically on this map and cannot be dismounted."),],
                ["HealingSpot",      MapCoordsProperty,
                 _INTL("Map ID of this Pokémon Center's town, and X and Y coordinates of its entrance within that town."),],
                ["Weather",          WeatherEffectProperty,
                 _INTL("Weather conditions in effect for this map."),],
                ["Temperature",      EnumProperty.new([
                    _INTL("Hot"), _INTL("Cold"), _INTL("Stable")]),
                 _INTL("If no specific weather is set, the average temperature of this map for the timed weather controller."),],
                ["Humidity",        EnumProperty.new([
                    _INTL("Wet"), _INTL("Dry"), _INTL("Stable")]),
                 _INTL("If no specific weather is set, the average humidity of this map for the timed weather controller."),],
                ["MapPosition",      RegionMapCoordsProperty,
                 _INTL("Identifies the point on the regional map for this map."),],
                ["DiveMap",          MapProperty,
                 _INTL("Specifies the underwater layer of this map. Use only if this map has deep water."),],
                ["DarkMap",          BooleanProperty,
                 _INTL("If true, this map is dark and a circle of light appears around the player. Flash can be used to expand the circle."),],
                ["SafariMap",        BooleanProperty,
                 _INTL("If true, this map is part of the Safari Zone (both indoor and outdoor). Not to be used in the reception desk."),],
                ["SnapEdges",        BooleanProperty,
                 _INTL("If true, when the player goes near this map's edge, the game doesn't center the player as usual."),],
                ["Dungeon",          BooleanProperty,
                 _INTL("If true, this map has a randomly generated layout. See the wiki for more information."),],
                ["BattleBack",       StringProperty,
                 _INTL("PNG files named 'XXX_bg', 'XXX_base0', 'XXX_base1', 'XXX_message' in Battlebacks folder, where XXX is this property's value."),],
                ["WildBattleBGM",    BGMProperty,
                 _INTL("Default BGM for wild Pokémon battles on this map."),],
                ["TrainerBattleBGM", BGMProperty,
                 _INTL("Default BGM for trainer battles on this map."),],
                ["WildVictoryME",    MEProperty,
                 _INTL("Default ME played after winning a wild Pokémon battle on this map."),],
                ["TrainerVictoryME", MEProperty,
                 _INTL("Default ME played after winning a Trainer battle on this map."),],
                ["WildCaptureME",    MEProperty,
                 _INTL("Default ME played after catching a wild Pokémon on this map."),],
                ["MapSize",          MapSizeProperty,
                 _INTL("The width of the map in Town Map squares, and a string indicating which squares are part of this map."),],
                ["Environment",      GameDataProperty.new(:Environment),
                 _INTL("The default battle environment for battles on this map."),],
                ["TeleportBlocked",  BooleanProperty,
                 _INTL("Whether the player is prevented from teleporting out of this map."),],
                ["SavingBlocked",    BooleanProperty,
                 _INTL("Whether the player is prevented from saving the game on this map."),],
                ["NoTeamEditing",    BooleanProperty,
                 _INTL("Whether the player is prevented from editing their team on this map."),],
            ]
        end

        def initialize(hash)
            @id                   	= hash[:id]
            @outdoor_map          	= hash[:outdoor_map]
            @announce_location    	= hash[:announce_location]
            @can_bicycle          	= hash[:can_bicycle]
            @always_bicycle       	= hash[:always_bicycle]
            @teleport_destination 	= hash[:teleport_destination]
            @weather              	= hash[:weather]
			@temperature            = hash[:temperature]
			@humidity            	= hash[:humidity]
            @town_map_position    	= hash[:town_map_position]
            @dive_map_id          	= hash[:dive_map_id]
            @dark_map             	= hash[:dark_map]
            @safari_map           	= hash[:safari_map]
            @snap_edges           	= hash[:snap_edges]
            @random_dungeon       	= hash[:random_dungeon]
            @battle_background    	= hash[:battle_background]
            @wild_battle_BGM      	= hash[:wild_battle_BGM]
            @trainer_battle_BGM   	= hash[:trainer_battle_BGM]
            @wild_victory_ME      	= hash[:wild_victory_ME]
            @trainer_victory_ME   	= hash[:trainer_victory_ME]
            @wild_capture_ME     	= hash[:wild_capture_ME]
            @town_map_size        	= hash[:town_map_size]
            @battle_environment   	= hash[:battle_environment]
            @teleport_blocked		= hash[:teleport_blocked]
            @saving_blocked		    = hash[:saving_blocked]
            @no_team_editing 		= hash[:no_team_editing]
            @defined_in_extension   = hash[:defined_in_extension] || false
        end

        def property_from_string(str)
            case str
            when "Outdoor"          then return @outdoor_map
            when "ShowArea"         then return @announce_location
            when "Bicycle"          then return @can_bicycle
            when "BicycleAlways"    then return @always_bicycle
            when "HealingSpot"      then return @teleport_destination
            when "Weather"          then return @weather
            when "Temperature"      then return @temperature
            when "Humidity"         then return @humidity
            when "MapPosition"      then return @town_map_position
            when "DiveMap"          then return @dive_map_id
            when "DarkMap"          then return @dark_map
            when "SafariMap"        then return @safari_map
            when "SnapEdges"        then return @snap_edges
            when "Dungeon"          then return @random_dungeon
            when "BattleBack"       then return @battle_background
            when "WildBattleBGM"    then return @wild_battle_BGM
            when "TrainerBattleBGM" then return @trainer_battle_BGM
            when "WildVictoryME"    then return @wild_victory_ME
            when "TrainerVictoryME" then return @trainer_victory_ME
            when "WildCaptureME"    then return @wild_capture_ME
            when "MapSize"          then return @town_map_size
            when "Environment"      then return @battle_environment
            when "TeleportBlocked"  then return @teleport_blocked
            when "SavingBlocked"    then return @saving_blocked
            when "NoTeamEditing"    then return @no_team_editing
            end
            return nil
        end
    end
end

module Compiler
    module_function

    #=============================================================================
    # Compile metadata
    #=============================================================================
    def compile_metadata(path = "PBS/metadata.txt")
        GameData::Metadata::DATA.clear
        GameData::MapMetadata::DATA.clear
        # Read from PBS file
        baseFiles = [path]
        metadataTextFiles = []
        metadataTextFiles.concat(baseFiles)
        metadataExtensions = Compiler.get_extensions("metadata")
        metadataTextFiles.concat(metadataExtensions)
        metadataTextFiles.each do |path|
            baseFile = baseFiles.include?(path)
            File.open(path, "rb") do |f|
                FileLineData.file = path # For error reporting
                # Read a whole section's lines at once, then run through this code.
                # contents is a hash containing all the XXX=YYY lines in that section, where
                # the keys are the XXX and the values are the YYY (as unprocessed strings).
                pbEachFileSection(f) do |contents, map_id|
                    schema = (map_id == 0) ? GameData::Metadata::SCHEMA : GameData::MapMetadata::SCHEMA
                    # Go through schema hash of compilable data and compile this section
                    for key in schema.keys
                        FileLineData.setSection(map_id, key, contents[key]) # For error reporting
                        # Skip empty properties, or raise an error if a required property is
                        # empty
                        if contents[key].nil?
                            if map_id == 0 && %w[Home PlayerA].include?(key)
                                raise _INTL("The entry {1} is required in {2} section 0.", key, path)
                            end
                            next
                        end
                        # Compile value for key
                        value = pbGetCsvRecord(contents[key], key, schema[key])
                        value = nil if value.is_a?(Array) && value.length == 0
                        contents[key] = value
                    end
                    if map_id == 0 # Global metadata
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
                            :player_H           => contents["PlayerH"],
                        }
                        # Add metadata's data to records
                        GameData::Metadata.register(metadata_hash)
                    else # Map metadata
                        # Construct metadata hash
                        metadata_hash = {
                            :id                   	=> map_id,
                            :outdoor_map          	=> contents["Outdoor"],
                            :announce_location    	=> contents["ShowArea"],
                            :can_bicycle          	=> contents["Bicycle"],
                            :always_bicycle       	=> contents["BicycleAlways"],
                            :teleport_destination 	=> contents["HealingSpot"],
                            :weather              	=> contents["Weather"],
                            :temperature	    	=> contents["Temperature"],
                            :humidity	    		=> contents["Humidity"],
                            :town_map_position    	=> contents["MapPosition"],
                            :dive_map_id          	=> contents["DiveMap"],
                            :dark_map             	=> contents["DarkMap"],
                            :safari_map           	=> contents["SafariMap"],
                            :snap_edges           	=> contents["SnapEdges"],
                            :random_dungeon       	=> contents["Dungeon"],
                            :battle_background    	=> contents["BattleBack"],
                            :wild_battle_BGM      	=> contents["WildBattleBGM"],
                            :trainer_battle_BGM   	=> contents["TrainerBattleBGM"],
                            :wild_victory_ME      	=> contents["WildVictoryME"],
                            :trainer_victory_ME   	=> contents["TrainerVictoryME"],
                            :wild_capture_ME      	=> contents["WildCaptureME"],
                            :town_map_size        	=> contents["MapSize"],
                            :battle_environment   	=> contents["Environment"],
                            :teleport_blocked	    => contents["TeleportBlocked"],
                            :saving_blocked	      	=> contents["SavingBlocked"],
                            :no_team_editing	    => contents["NoTeamEditing"],
                            :defined_in_extension => !baseFile,
                        }
                        # Add metadata's data to records
                        GameData::MapMetadata.register(metadata_hash)
                    end
                end
            end
        end
        # Save all data
        GameData::Metadata.save
        GameData::MapMetadata.save
        Graphics.update
    end

    #=============================================================================
    # Save metadata data to PBS file
    #=============================================================================
    def write_metadata
        File.open("PBS/metadata.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            # Write global metadata
            f.write("\#-------------------------------\r\n")
            f.write("[000]\r\n")
            metadata = GameData::Metadata.get
            schema = GameData::Metadata::SCHEMA
            keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
            for key in keys
                record = metadata.property_from_string(key)
                next if record.nil?
                f.write(format("%s = ", key))
                pbWriteCsvRecord(record, f, schema[key])
                f.write("\r\n")
            end
            # Write map metadata
            map_infos = pbLoadMapInfos
            schema = GameData::MapMetadata::SCHEMA
            keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
            GameData::MapMetadata.each_base do |map_data|
                f.write("\#-------------------------------\r\n")
                f.write(format("[%03d]\r\n", map_data.id))
                f.write(format("# %s\r\n", map_infos[map_data.id].name)) if map_infos && map_infos[map_data.id]
                for key in keys
                    record = map_data.property_from_string(key)
                    next if record.nil?
                    f.write(format("%s = ", key))
                    pbWriteCsvRecord(record, f, schema[key])
                    f.write("\r\n")
                end
            end
        end
        Graphics.update
    end
end
