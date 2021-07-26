def pbRespawnTrainers
  if !$game_variables[76].is_a?(Array)
    $game_variables[76] = []
    echo("Creating respawn table.\n")
    return
  end
  for i in 0...200
    $game_variables[76][i] = true
  end
end

Events.onMapChange += proc { |_sender,e|
  if !$game_variables[76].is_a?(Array)
    $game_variables[76] = []
    echo("Recreating respawn table.\n")
    next
  end
  oldid = e[0] # previous map ID, 0 if no map ID
  
  if oldid==0 || oldid==$game_map.map_id
    echo("Skipping this map because of some unknown error.\n")
    next
  end
    
  if !$game_variables[76][$game_map.map_id] && $game_variables[75].is_a?(Array) && !$game_variables[75].any?{|id| id == $game_map.map_id}
    echo("Skipping this map because its already been reset and it's not an always reset map.\n")
    next
  end
    
  $game_variables[76][$game_map.map_id] = false
  echo("Resetting events on this map\n")
  for event in $game_map.events.values
    if event.name.downcase.include?("trainer") or ($game_switches[78] && event.name.downcase.include?("berryplant"))
      $game_self_switches[[$game_map.map_id,event.id,"A"]] = false
    end
  end
}