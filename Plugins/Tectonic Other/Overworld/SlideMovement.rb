def isPlayerSliding?
    if $PokemonGlobal
        return $PokemonGlobal.sliding
    else
        return false
    end 
end

# Auto-move the player over waterfalls, pushing water, and ice
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
	# Slide on ice and descend down waterfalls
    if event == $game_player
      currentTag = $game_player.pbTerrainTag
      if slideDownTerrainTag(currentTag)
        pbDescendWaterfall
      elsif currentTag.ice
        if !$PokemonGlobal.sliding
          pbSlideOnIce
        end
      elsif currentTag.push_direction
        pbPushedByTiles
      else
        $PokemonGlobal.sliding = false
        $game_player.walk_anime = true
      end
    end
  end
}

# Check for pushing every frame
Events.onMapUpdate += proc { |_sender,_e|
  pushingTag = $game_player.pushingTag
  if pushingTag.push_direction && pushingTag.pinning_wind && !$PokemonGlobal.pushing
    pbPushedByTiles
  end
}

def pinningWindActive?
  return pinningWindStrength >= 130
end

PINNING_WIND_CYCLE = 1.4

def pinningWindStrength
  return 150 if $game_map.map_id == 404 # Mirror Maze
  strength = 100 + 100 * Math.sin(Time.now.to_r / PINNING_WIND_CYCLE)
  strength = strength.clamp(50,150)
  return strength
end

def playPinningWindBGS
  pbBGSPlay("blizzard-loop-SE",1.5 * (pinningWindStrength - 25))
end

class PokemonGlobalMetadata
  attr_accessor :pushing
end

def pbPushedByTiles
  $PokemonGlobal.pushing = true
  loop do
    terrain = $game_player.pushingTag
    pushDirection = terrain.push_direction
    break if pushDirection.nil?
    break if terrain.pinning_wind && !pinningWindActive?
    $game_player.move_generic(pushDirection)
    pbWait(2)
    break if $game_player.check_event_trigger_here([1,2])
  end
  $PokemonGlobal.pushing = false
end

def slideDownTerrainTag(terrainTagData)
  return terrainTagData.waterfall || terrainTagData.waterfall_crest || terrainTagData.id == :SouthConveyor
end

def pbDescendWaterfall
    if $game_player.direction != 2   # Can't descend if not facing down
        $game_player.move_down
        return if $game_player.check_event_trigger_here([1,2])
    end
    terrain = $game_player.pbFacingTerrainTag
    return if !slideDownTerrainTag(terrain)
    oldthrough   = $game_player.through
    $game_player.through    = true
    loop do
        $game_player.move_down
        break if $game_player.check_event_trigger_here([1,2])
        terrain = $game_player.pbTerrainTag
        break if !slideDownTerrainTag(terrain)
    end
    $game_player.through    = oldthrough
end

def pbSlideOnIce
  return if !$game_player.pbTerrainTag.ice
  pbDismountBike
  $PokemonGlobal.sliding = true
  direction    = $game_player.direction
  oldwalkanime = $game_player.walk_anime
  $game_player.straighten
  $game_player.walk_anime = false
  loop do
    unless $game_player.can_move_in_direction?($game_player.direction)
      $game_player.bump_into_object
      break
    end
    break if !$game_player.pbTerrainTag.ice
    $game_player.move_forward
    while $game_player.moving?
      pbUpdateSceneMap
      Graphics.update
      Input.update
    end
    #echoln("Sliding on ice in #{direction} direction")
  end
  $game_player.center($game_player.x, $game_player.y)
  $game_player.straighten
  $game_player.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end