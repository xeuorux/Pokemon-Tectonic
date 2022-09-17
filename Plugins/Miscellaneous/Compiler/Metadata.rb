module GameData
  class Metadata
	attr_reader :avatar_battle_BGM
	attr_reader :legendary_avatar_battle_BGM
	
	SCHEMA = {
	  "Home"             			=> [1,  "vuuu"],
	  "WildBattleBGM"    			=> [2,  "s"],
	  "TrainerBattleBGM" 			=> [3,  "s"],
	  "AvatarBattleBGM" 			=> [4,  "s"],
	  "LegendaryAvatarBattleBGM" 	=> [5,  "s"],
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
	  "PlayerH"          			=> [18, "esssssss", :TrainerType]
	}
  
		def self.editor_properties
			return [
			 ["Home",             			MapCoordsFacingProperty, _INTL("Map ID and X and Y coordinates of where the player goes if no Pokémon Center was entered after a loss.")],
			 ["WildBattleBGM",    			BGMProperty,             _INTL("Default BGM for wild Pokémon battles.")],
			 ["TrainerBattleBGM", 			BGMProperty,             _INTL("Default BGM for Trainer battles.")],
			 ["AvatarBattleBGM", 			BGMProperty,             _INTL("Default BGM for Avatar battles.")],
			 ["LegendaryAvatarBattleBGM", 	BGMProperty,             _INTL("Default BGM for Legendary Avatar battles.")],
			 ["WildVictoryME",    			MEProperty,              _INTL("Default ME played after winning a wild Pokémon battle.")],
			 ["TrainerVictoryME", 			MEProperty,              _INTL("Default ME played after winning a Trainer battle.")],
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
			 ["PlayerH",          			PlayerProperty,          _INTL("Specifies player H.")]
			]
		end
		
		def initialize(hash)
		  @id                  			= hash[:id]
		  @home               			= hash[:home]
		  @wild_battle_BGM     			= hash[:wild_battle_BGM]
		  @trainer_battle_BGM  			= hash[:trainer_battle_BGM]
		  @avatar_battle_BGM   			= hash[:avatar_battle_BGM]
		  @legendary_avatar_battle_BGM  = hash[:legendary_avatar_battle_BGM]
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
		  when "AvatarBattleBGM" 			then return @avatar_battle_BGM
		  when "LegendaryAvatarBattleBGM" 	then return @legendary_avatar_battle_BGM
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