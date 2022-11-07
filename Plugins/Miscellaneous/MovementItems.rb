class Game_Character
	def move_speed=(val)
		return if val==@move_speed
		@move_speed = val
		# @move_speed_real is the number of quarter-pixels to move each frame. There
		# are 128 quarter-pixels per tile.
		self.move_speed_real = [3.2,6.4,12.8,25.6,44,64][val-1]
	end
end

class Game_Map
	def playerPassable?(x, y, d, self_event = nil)
		bit = (1 << (d / 2 - 1)) & 0x0f
		for i in [2, 1, 0]
		  tile_id = data[x, y, i]
		  terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
		  passage = @passages[tile_id]
		  if terrain
			# Ignore bridge tiles if not on a bridge
			next if terrain.bridge && $PokemonGlobal.bridge == 0
			# Make water tiles passable if player is surfing or has the surfboard
			return true if terrain.can_surf && !terrain.waterfall && ($PokemonGlobal.surfing || $PokemonBag.pbHasItem?(:SURFBOARD))
			return true if terrain.rock_climbable && $PokemonBag.pbHasItem?(:CLIMBINGGEAR)
			# Prevent cycling in really tall grass/on ice
			return false if $PokemonGlobal.bicycle && terrain.must_walk
			# Depend on passability of bridge tile if on bridge
			if terrain.bridge && $PokemonGlobal.bridge > 0
			  return (passage & bit == 0 && passage & 0x0f != 0x0f)
			end
		  end
		  # Regular passability checks
		  if !terrain || !terrain.ignore_passability
			return false if passage & bit != 0 || passage & 0x0f == 0x0f
			return true if @priorities[tile_id] == 0
		  end
		end
		return true
	  end
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