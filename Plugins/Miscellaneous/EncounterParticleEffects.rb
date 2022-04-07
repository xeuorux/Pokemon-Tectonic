
# Show grass rustle animation, and auto-move the player over waterfalls and ice
Events.onStepTakenFieldMovement += proc { |_sender, e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    if $PokemonSystem.particle_effects == 0 && !event.floats
		event.each_occupied_tile do |x, y|
		  tag = $MapFactory.getTerrainTag(event.map.map_id, x, y, true)
		  if tag.shows_grass_rustle
			$scene.spriteset.addUserAnimation(Settings::GRASS_ANIMATION_ID, x, y, true, 1)
		  elsif tag == :Puddle
			$scene.spriteset.addUserAnimation(8, x, y, true, 1)
		  elsif tag == :FishingContest
			$scene.spriteset.addUserAnimation(8, x, y, true, 1)
		  elsif tag == :SewerFloor || tag == :SewerWater
		   $scene.spriteset.addUserAnimation(18, x, y, true, 1)
		  elsif tag == :DarkCave
			$scene.spriteset.addUserAnimation(2, x, y, true, 1)
		  end
		end
	end
	# Slide on ice
    if event == $game_player
      currentTag = $game_player.pbTerrainTag
      if currentTag.waterfall_crest
        pbDescendWaterfall
      elsif currentTag.ice && !$PokemonGlobal.sliding
        pbSlideOnIce
      end
    end
  end
}