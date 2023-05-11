Events.onBadgeEarned += proc { |_sender,_e|
    totalBadges = _e[1]
    if totalBadges == 4
        $PokemonGlobal.shouldProcSurfboardCall = true
    elsif totalBadges == 6
        $PokemonGlobal.shouldProcCatacombsCall = true
    end
}

Events.onMapChange += proc { |_sender, _e|
	if playerIsOutdoors?()
		if $PokemonGlobal.shouldProcSurfboardCall
			$game_switches[SURFBOARD_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcSurfboardCall = false
		end
		if $PokemonGlobal.shouldProcCatacombsCall
			$game_switches[CATACOMBS_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcCatacombsCall = false
		end
	end
}

class PokemonGlobalMetadata
	attr_accessor :shouldProcSurfboardCall
	attr_accessor :shouldProcCatacombsCall
end