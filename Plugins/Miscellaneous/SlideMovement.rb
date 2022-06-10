# Auto-move the player over waterfalls and ice
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
	# Slide on ice and descend down waterfalls
    if event == $game_player
      currentTag = $game_player.pbTerrainTag
      if slideDownTerrainTag(currentTag)
        pbDescendWaterfall
      elsif currentTag.ice && !$PokemonGlobal.sliding
        pbSlideOnIce
      end
    end
  end
}

def slideDownTerrainTag(terrain)
  return terrain.waterfall || terrain.waterfall_crest || terrain.id == :SouthConveyor
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