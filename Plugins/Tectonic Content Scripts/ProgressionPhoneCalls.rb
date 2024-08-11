ZAIN_2_BADGES_PHONECALL_GLOBAL = 230
ZAIN_3_BADGES_PHONECALL_GLOBAL = 231
GROUZ_AVATAR_PHONECALL_GLOBAL = 226
CATACOMBS_PHONECALL_GLOBAL = 227
WHITEBLOOM_PHONECALL_GLOBAL = 228
BATTLE_MONUMENT_PHONECALL_GLOBAL = 229
DR_HEKATA_PHONECALL_GLOBAL = 232
ESTATE_PHONECALL_GLOBAL = 233

Events.onBadgeEarned += proc { |_sender,_e|
    totalBadges = _e[1]
	if totalBadges == 2
		$PokemonGlobal.shouldProc2BadgesZainCall = true
	elsif totalBadges == 3
		$PokemonGlobal.shouldProc3BadgesZainCall = true
	elsif totalBadges == 4
        $PokemonGlobal.shouldProcGrouzAvatarCall = true
    elsif totalBadges == 6
        $PokemonGlobal.shouldProcCatacombsCall = true
	elsif totalBadges == 8
        $PokemonGlobal.shouldProcWhitebloomCall = true
    end
}

def gameWon?
	return $game_switches[68]
end

Events.onMapChange += proc { |_sender, _e|
	if playerIsOutdoors?
		if $PokemonGlobal.shouldProcGrouzAvatarCall
			$game_switches[GROUZ_AVATAR_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcGrouzAvatarCall = false
		elsif $PokemonGlobal.shouldProcCatacombsCall
			$game_switches[CATACOMBS_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcCatacombsCall = false
		elsif $PokemonGlobal.shouldProcWhitebloomCall
			$game_switches[WHITEBLOOM_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProcWhitebloomCall = false
		elsif $PokemonGlobal.shouldProc2BadgesZainCall
			$game_switches[ZAIN_2_BADGES_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProc2BadgesZainCall = false
		elsif $PokemonGlobal.shouldProc3BadgesZainCall
			$game_switches[ZAIN_3_BADGES_PHONECALL_GLOBAL] = true
			$PokemonGlobal.shouldProc3BadgesZainCall = false
        end
	end

	if 		gameWon? &&
			!$game_switches[99] && # Battle monument not yet unlocked
			$game_map.map_id == 188 # In Prizca Castle
		$game_switches[BATTLE_MONUMENT_PHONECALL_GLOBAL] = true # Trigger the phonecall from Vanya
	end
}

Events.onStepTaken += proc { |_sender,_e|
    if playerIsOutdoors? && $PokemonGlobal.shouldProcEstateCall
        $game_switches[ESTATE_PHONECALL_GLOBAL] = true
        $PokemonGlobal.shouldProcEstateCall = false
    end
}
