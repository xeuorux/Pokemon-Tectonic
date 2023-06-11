GROUZ_AVATAR_PHONECALL_GLOBAL = 61
CATACOMBS_PHONECALL_GLOBAL = 62
WHITEBLOOM_PHONECALL_GLOBAL = 54

Events.onBadgeEarned += proc { |_sender,_e|
    totalBadges = _e[1]
    if totalBadges == 4
        $PokemonGlobal.shouldProcGrouzAvatarCall = true
    elsif totalBadges == 6
        $PokemonGlobal.shouldProcCatacombsCall = true
	elsif totalBadges == 8
        $PokemonGlobal.shouldProcWhitebloomCall = true
    end
}

Events.onMapChange += proc { |_sender, _e|
	if playerIsOutdoors?()
		if $PokemonGlobal.shouldProcGrouzAvatarCall
			$game_switches[GROUZ_AVATAR_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcGrouzAvatarCall = false
		end
		if $PokemonGlobal.shouldProcCatacombsCall
			$game_switches[CATACOMBS_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcCatacombsCall = false
		end
		if $PokemonGlobal.shouldProcWhitebloomCall
			$game_switches[WHITEBLOOM_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcWhitebloomCall = false
		end
	end
}

class PokemonGlobalMetadata
	attr_accessor :shouldProcGrouzAvatarCall
	attr_accessor :shouldProcCatacombsCall
	attr_accessor :shouldProcWhitebloomCall
end