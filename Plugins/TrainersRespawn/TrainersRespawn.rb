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
  for event in $game_map.events.values
    if event.name.downcase.include?("reset")
      $game_self_switches[[$game_map.map_id,event.id,"A"]] = false
    end
  end
}