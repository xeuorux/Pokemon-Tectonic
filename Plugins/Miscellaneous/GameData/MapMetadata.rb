module GameData
  class MapMetadata
	attr_reader :teleport_blocked
  attr_reader :saving_blocked
  attr_reader :no_team_editing
	
	SCHEMA = {
       "Outdoor"          => [1,  "b"],
       "ShowArea"         => [2,  "b"],
       "Bicycle"          => [3,  "b"],
       "BicycleAlways"    => [4,  "b"],
       "HealingSpot"      => [5,  "vuu"],
       "Weather"          => [6,  "eu", :Weather],
       "MapPosition"      => [7,  "uuu"],
       "DiveMap"          => [8,  "v"],
       "DarkMap"          => [9,  "b"],
       "SafariMap"        => [10, "b"],
       "SnapEdges"        => [11, "b"],
       "Dungeon"          => [12, "b"],
       "BattleBack"       => [13, "s"],
       "WildBattleBGM"    => [14, "s"],
       "TrainerBattleBGM" => [15, "s"],
       "WildVictoryME"    => [16, "s"],
       "TrainerVictoryME" => [17, "s"],
       "WildCaptureME"    => [18, "s"],
       "MapSize"          => [19, "us"],
       "Environment"      => [20, "e", :Environment],
	     "TeleportBlocked"  => [21, "b"],
       "SavingBlocked"    => [22, "b"],
       "NoTeamEditing"    => [23, "b"],
    }
  
		def self.editor_properties
      return [
         ["Outdoor",          BooleanProperty,                    _INTL("If true, this map is an outdoor map and will be tinted according to time of day.")],
         ["ShowArea",         BooleanProperty,                    _INTL("If true, the game will display the map's name upon entry.")],
         ["Bicycle",          BooleanProperty,                    _INTL("If true, the bicycle can be used on this map.")],
         ["BicycleAlways",    BooleanProperty,                    _INTL("If true, the bicycle will be mounted automatically on this map and cannot be dismounted.")],
         ["HealingSpot",      MapCoordsProperty,                  _INTL("Map ID of this Pokémon Center's town, and X and Y coordinates of its entrance within that town.")],
         ["Weather",          WeatherEffectProperty,              _INTL("Weather conditions in effect for this map.")],
         ["MapPosition",      RegionMapCoordsProperty,            _INTL("Identifies the point on the regional map for this map.")],
         ["DiveMap",          MapProperty,                        _INTL("Specifies the underwater layer of this map. Use only if this map has deep water.")],
         ["DarkMap",          BooleanProperty,                    _INTL("If true, this map is dark and a circle of light appears around the player. Flash can be used to expand the circle.")],
         ["SafariMap",        BooleanProperty,                    _INTL("If true, this map is part of the Safari Zone (both indoor and outdoor). Not to be used in the reception desk.")],
         ["SnapEdges",        BooleanProperty,                    _INTL("If true, when the player goes near this map's edge, the game doesn't center the player as usual.")],
         ["Dungeon",          BooleanProperty,                    _INTL("If true, this map has a randomly generated layout. See the wiki for more information.")],
         ["BattleBack",       StringProperty,                     _INTL("PNG files named 'XXX_bg', 'XXX_base0', 'XXX_base1', 'XXX_message' in Battlebacks folder, where XXX is this property's value.")],
         ["WildBattleBGM",    BGMProperty,                        _INTL("Default BGM for wild Pokémon battles on this map.")],
         ["TrainerBattleBGM", BGMProperty,                        _INTL("Default BGM for trainer battles on this map.")],
         ["WildVictoryME",    MEProperty,                         _INTL("Default ME played after winning a wild Pokémon battle on this map.")],
         ["TrainerVictoryME", MEProperty,                         _INTL("Default ME played after winning a Trainer battle on this map.")],
         ["WildCaptureME",    MEProperty,                         _INTL("Default ME played after catching a wild Pokémon on this map.")],
         ["MapSize",          MapSizeProperty,                    _INTL("The width of the map in Town Map squares, and a string indicating which squares are part of this map.")],
         ["Environment",      GameDataProperty.new(:Environment), _INTL("The default battle environment for battles on this map.")],
		     ["TeleportBlocked",  BooleanProperty,					          _INTL("Whether the player is prevented from teleporting out of this map.")],
         ["SavingBlocked",    BooleanProperty,					          _INTL("Whether the player is prevented from saving the game on this map.")],
         ["NoTeamEditing",    BooleanProperty,					          _INTL("Whether the player is prevented from editing their team on this map.")],
	  ]
    end
		
    def initialize(hash)
      @id                   = hash[:id]
      @outdoor_map          = hash[:outdoor_map]
      @announce_location    = hash[:announce_location]
      @can_bicycle          = hash[:can_bicycle]
      @always_bicycle       = hash[:always_bicycle]
      @teleport_destination = hash[:teleport_destination]
      @weather              = hash[:weather]
      @town_map_position    = hash[:town_map_position]
      @dive_map_id          = hash[:dive_map_id]
      @dark_map             = hash[:dark_map]
      @safari_map           = hash[:safari_map]
      @snap_edges           = hash[:snap_edges]
      @random_dungeon       = hash[:random_dungeon]
      @battle_background    = hash[:battle_background]
      @wild_battle_BGM      = hash[:wild_battle_BGM]
      @trainer_battle_BGM   = hash[:trainer_battle_BGM]
      @wild_victory_ME      = hash[:wild_victory_ME]
      @trainer_victory_ME   = hash[:trainer_victory_ME]
      @wild_capture_ME      = hash[:wild_capture_ME]
      @town_map_size        = hash[:town_map_size]
      @battle_environment   = hash[:battle_environment]
	    @teleport_blocked		  = hash[:teleport_blocked]
      @saving_blocked		    = hash[:saving_blocked]
      @no_team_editing      = hash[:no_team_editing]
    end

    def property_from_string(str)
      case str
      when "Outdoor"          then return @outdoor_map
      when "ShowArea"         then return @announce_location
      when "Bicycle"          then return @can_bicycle
      when "BicycleAlways"    then return @always_bicycle
      when "HealingSpot"      then return @teleport_destination
      when "Weather"          then return @weather
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

def pbEditMetadata(map_id = 0)
  mapinfos = pbLoadMapInfos
  data = []
  if map_id == 0   # Global metadata
    map_name = _INTL("Global Metadata")
    metadata = GameData::Metadata.get
    properties = GameData::Metadata.editor_properties
  else   # Map metadata
    map_name = mapinfos[map_id].name
    metadata = GameData::MapMetadata.try_get(map_id)
    metadata = GameData::Metadata.new({}) if !metadata
    properties = GameData::MapMetadata.editor_properties
  end
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(map_name, data, properties, true)
    if map_id == 0   # Global metadata
      # Construct metadata hash
      metadata_hash = {
        :id                 => map_id,
        :home               => data[0],
        :wild_battle_BGM    => data[1],
        :trainer_battle_BGM => data[2],
        :wild_victory_ME    => data[3],
        :trainer_victory_ME => data[4],
        :wild_capture_ME    => data[5],
        :surf_BGM           => data[6],
        :bicycle_BGM        => data[7],
        :player_A           => data[8],
        :player_B           => data[9],
        :player_C           => data[10],
        :player_D           => data[11],
        :player_E           => data[12],
        :player_F           => data[13],
        :player_G           => data[14],
        :player_H           => data[15]
      }
      # Add metadata's data to records
      GameData::Metadata.register(metadata_hash)
      GameData::Metadata.save
    else   # Map metadata
      # Construct metadata hash
      metadata_hash = {
        :id                   => map_id,
        :outdoor_map          => data[0],
        :announce_location    => data[1],
        :can_bicycle          => data[2],
        :always_bicycle       => data[3],
        :teleport_destination => data[4],
        :weather              => data[5],
        :town_map_position    => data[6],
        :dive_map_id          => data[7],
        :dark_map             => data[8],
        :safari_map           => data[9],
        :snap_edges           => data[10],
        :random_dungeon       => data[11],
        :battle_background    => data[12],
        :wild_battle_BGM      => data[13],
        :trainer_battle_BGM   => data[14],
        :wild_victory_ME      => data[15],
        :trainer_victory_ME   => data[16],
        :wild_capture_ME      => data[17],
        :town_map_size        => data[18],
        :battle_environment   => data[19],
        :teleport_blocked     => data[20],
        :saving_blocked       => data[21],
        :no_team_editing      => data[22],
      }
      # Add metadata's data to records
      GameData::MapMetadata.register(metadata_hash)
      GameData::MapMetadata.save
    end
    Compiler.write_metadata
  end
end