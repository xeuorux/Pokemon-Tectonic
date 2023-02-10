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
        pbPushedByWater
      else
        $PokemonGlobal.sliding = false
        $game_player.walk_anime = true
      end
    end
  end
}

def pbPushedByWater
  $game_player.move_generic($game_player.pbTerrainTag.push_direction)
  return if $game_player.check_event_trigger_here([1,2])
  terrain = $game_player.pbFacingTerrainTag
  return unless terrain.push_direction
  oldthrough   = $game_player.through
  $game_player.through    = true
  loop do
    $game_player.move_generic($game_player.pbTerrainTag.push_direction)
    break if $game_player.check_event_trigger_here([1,2])
    terrain = $game_player.pbTerrainTag
    break unless terrain.push_direction
  end
  $game_player.through    = oldthrough
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
    break if !$game_player.can_move_in_direction?(direction)
    break if !$game_player.pbTerrainTag.ice
    $game_player.move_forward
    while $game_player.moving?
      pbUpdateSceneMap
      Graphics.update
      Input.update
    end
  end
  $game_player.center($game_player.x, $game_player.y)
  $game_player.straighten
  $game_player.walk_anime = oldwalkanime
  $PokemonGlobal.sliding = false
end