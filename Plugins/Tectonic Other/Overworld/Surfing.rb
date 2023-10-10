def playerCanSurf?
	if hasDragonFlame?
		pbMessage(_INTL("Your flame would go out if you surfed now!"))
		return false
	end
	return $PokemonBag.pbHasItem?(:SURFBOARD)
end

def pbEndSurf(_xOffset,_yOffset)
	hidden = !$PokemonTemp.dependentEvents.can_refresh?
	ret = pbEndSurfEx(_xOffset,_yOffset)
  	$PokemonGlobal.call_refresh = [true, hidden] if ret
end

def pbEndSurfEx(_xOffset,_yOffset)
	return false if !$PokemonGlobal.surfing
	x = $game_player.x
	y = $game_player.y
	if $game_map.terrain_tag(x,y).can_surf && !$game_player.pbFacingTerrainTag.can_surf
	  $PokemonTemp.surfJump = [x,y]
	  if pbJumpToward(1,false,true)
		$game_map.autoplayAsCue
		$game_player.increase_steps
		result = $game_player.check_event_trigger_here([1,2])
		pbOnStepTaken(result)
	  end
	  $PokemonTemp.surfJump = nil
	  return true
	end
	return false
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