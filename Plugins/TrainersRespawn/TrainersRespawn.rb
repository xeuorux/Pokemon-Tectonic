MAPS_MAXIMUM = 500

class PokemonGlobalMetadata
	attr_accessor :respawnTable
end

def pbRespawnTrainers
  if $PokemonGlobal.respawnTable.nil? || !$PokemonGlobal.respawnTable.is_a?(Array)
    $PokemonGlobal.respawnTable = []
    echo("Creating respawn table.\n")
    return
  end
  for i in 0...MAPS_MAXIMUM
    $PokemonGlobal.respawnTable[i] = true
  end
end

Events.onMapChange += proc { |_sender,e|
  if $PokemonGlobal.respawnTable.nil? || !$PokemonGlobal.respawnTable.is_a?(Array)
    $PokemonGlobal.respawnTable = []
    echo("Recreating respawn table.\n")
    next
  end
  oldid = e[0] # previous map ID, 0 if no map ID
  
  if oldid==0 || oldid==$game_map.map_id
    echo("Skipping this map for respawns because of some unknown error.\n")
    next
  end
    
  if !$PokemonGlobal.respawnTable[$game_map.map_id]
    echo("Skipping this map for respawns because its already been reset.\n")
    next
  end
    
  $PokemonGlobal.respawnTable[$game_map.map_id] = false
  echo("Resetting events on this map\n")
  anyTrainersRespawned = false
  for event in $game_map.events.values
    if event.name.downcase.include?("reset")
		if event.name.downcase.include?("trainer") && $game_self_switches[[$game_map.map_id,event.id,"A"]]
			anyTrainersRespawned = true
		end
		$game_self_switches[[$game_map.map_id,event.id,"A"]] = false
    end
  end
  
  if anyTrainersRespawned && !$PokemonGlobal.respawns_tutorialized
	$PokemonGlobal.respawn_tutorial = 5
  else
    $PokemonGlobal.respawn_tutorial = 0
  end
}

Events.onStepTaken += proc { |_sender,_e|
	next if $PokemonGlobal.respawn_tutorial <= 0
	if $PokemonGlobal.respawn_tutorial == 1
		pbWait(10)
		pbMessage(_INTL("\\wmAfter healing at a bed or Pokecenter, defeated enemy trainers will become battle ready again!\\wtnp[80]\1"))
		pbMessage(_INTL("\\wmTrainers who fled don't come back, however.\\wtnp[80]\1"))
		pbWait(10)
		$PokemonGlobal.respawns_tutorialized = true
	end
	$PokemonGlobal.respawn_tutorial -= 1
}
