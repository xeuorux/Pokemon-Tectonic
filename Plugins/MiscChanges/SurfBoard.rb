class Game_Character
	def move_speed=(val)
		if $PokemonGlobal && $PokemonGlobal.surfing
		  val = 5
		end
		if $game_player && $game_map.terrain_tag($game_player.x, $game_player.y).slows
			val -= 1
		end
		return if val==@move_speed
		@move_speed = val
		# @move_speed_real is the number of quarter-pixels to move each frame. There
		# are 128 quarter-pixels per tile. By default, it is calculated from
		# @move_speed and has these values (assuming 40 fps):
		# 1 => 3.2    # 40 frames per tile
		# 2 => 6.4    # 20 frames per tile
		# 3 => 12.8   # 10 frames per tile - walking speed
		# 4 => 25.6   # 5 frames per tile - running speed (2x walking speed)
		# 5 => 32     # 4 frames per tile - cycling speed (1.25x running speed)
		# 6 => 64     # 2 frames per tile
		self.move_speed_real = (val == 6) ? 64 : (val == 5) ? 32 : (2 ** (val + 1)) * 0.8
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
			#echo("#{$PokemonBag.pbHasItem?(:SURFBOARD)}, #{errain.can_surf}, #{terrain.waterfall}\n")
			return true if terrain.can_surf && !terrain.waterfall && ($PokemonGlobal.surfing || $PokemonBag.pbHasItem?(:SURFBOARD))
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
		pbStartSurfing()
      end
    end
  end
}