class Game_Character
	def move_speed=(val)
		return if val==@move_speed
		@move_speed = val
		# @move_speed_real is the number of quarter-pixels to move each frame. There
		# are 128 quarter-pixels per tile.
		self.move_speed_real = [3.2,6.4,12.8,25.6,44,64][val-1]
	end
end

def playerCanSurf?
	if hasDragonFlame?
		pbMessage(_INTL("Your flame would go out if you surfed now!"))
		return false
	end
	return $PokemonBag.pbHasItem?(:SURFBOARD)
end


Events.onStepTakenFieldMovement += proc { |_sender,e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    if event == $game_player
	  currentTag = $game_player.pbTerrainTag
      if currentTag.can_surf && !$PokemonGlobal.surfing && $PokemonGlobal.bridge == 0
		pbDismountBike
		pbStartSurfing(false)
		$PokemonGlobal.call_refresh = [true,false]
      end
    end
  end
}

def pbStartSurfing(jump = true)
	pbCancelVehicles
	$PokemonEncounters.reset_step_count
	$PokemonGlobal.surfing = true
	pbUpdateVehicle
	if jump
		$PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
		pbJumpToward
		$PokemonTemp.surfJump = nil
	end
	$game_player.check_event_trigger_here([1,2])
	progressMQStage(:CROSS_ELEIG,:FIND_FIFTH_GYM)
end