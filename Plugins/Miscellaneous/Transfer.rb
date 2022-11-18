class Scene_Map
	def transfer_player(cancelVehicles=true)
		$game_temp.player_transferring = false
		pbCancelVehicles($game_temp.player_new_map_id) if cancelVehicles
		autofade($game_temp.player_new_map_id)
		pbBridgeOff
		@spritesetGlobal.playersprite.clearShadows if @spritesetGlobal
		if $game_map.map_id!=$game_temp.player_new_map_id
		  $MapFactory.setup($game_temp.player_new_map_id)
		end
		$game_temp.setup_sames = false
		$game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
		case $game_temp.player_new_direction
		when 2 then $game_player.turn_down
		when 4 then $game_player.turn_left
		when 6 then $game_player.turn_right
		when 8 then $game_player.turn_up
		end
		$game_player.straighten
		$game_map.update
		
		# The player surfs if they were transferred to a surfable tile
		terrainID = $game_map.terrain_tag($game_player.x, $game_player.y).id
		terrain = GameData::TerrainTag.try_get(terrainID)
		if terrain && terrain.can_surf
			$PokemonGlobal.surfing = true
			pbUpdateVehicle
		end
		
		recreateSpritesets
		
		if $game_temp.transition_processing
		  $game_temp.transition_processing = false
		  Graphics.transition(20)
		end
		$game_map.autoplay
		Graphics.frame_reset
		Input.update
	end

	def recreateSpritesets
		disposeSpritesets
		RPG::Cache.clear
		createSpritesets
	end
end