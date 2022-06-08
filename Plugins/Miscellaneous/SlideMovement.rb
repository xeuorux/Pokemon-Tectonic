# Auto-move the player over waterfalls and ice
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
	# Slide on ice and descend down waterfalls
    if event == $game_player
      currentTag = $game_player.pbTerrainTag
      if currentTag.waterfall_crest || currentTag.waterfall
        pbDescendWaterfall
      elsif currentTag.ice && !$PokemonGlobal.sliding
        pbSlideOnIce
      end
    end
  end
}

def pbDescendWaterfall
    if $game_player.direction != 2   # Can't descend if not facing down
        $game_player.move_down
    end
    terrain = $game_player.pbFacingTerrainTag
    return if !terrain.waterfall && !terrain.waterfall_crest
    oldthrough   = $game_player.through
    oldmovespeed = $game_player.move_speed
    $game_player.through    = true
    $game_player.move_speed = 2
    loop do
        $game_player.move_down
        terrain = $game_player.pbTerrainTag
        break if !terrain.waterfall && !terrain.waterfall_crest
    end
    $game_player.through    = oldthrough
    $game_player.move_speed = oldmovespeed
end