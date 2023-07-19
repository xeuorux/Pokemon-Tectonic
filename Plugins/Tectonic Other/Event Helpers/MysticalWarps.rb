LABYRINTH_WARP_1 = [0,52]
LABYRINTH_WARP_2 = [38,-52]
LABYRINTH_WARP_3 = [0,52]
LABYRINTH_WARP_4 = [-38,-52]

def mirroredTeleportToEvent(event_id,fourWay=false)
	mysticalWarpEffect {
		mapData = Compiler::MapData.new
		map = mapData.getMap($game_map.map_id)
		event = map.events[event_id]

		if fourWay
			distanceX = $game_player.x - get_self.x
			distanceY = $game_player.y - get_self.y

			case $game_player.direction
			when Up
				direction = Down
			when Down
				direction = Up
			when Left
				direction = Right
			when Right
				direction = Left
			end
		else
			distanceX = $game_player.x - get_self.x
			distanceY = get_self.y - $game_player.y

			case $game_player.direction
			when Left
				direction = Right
			when Right
				direction = Left
			else
				direction = $game_player.direction
			end
		end

		x = event.x - distanceX
		y = event.y - distanceY

		transferPlayer(x,y,direction)
	}
end

def mysticalOffsetWarp(offsetX, offsetY = nil)
	if offsetX.is_a?(Array)
		offsetY = offsetX[1]
		offsetX = offsetX[0]
	end

	blackFadeOutIn {
		pbSEPlay("Anim/PRSFX- Avalanche",120,70)
		pbWait(20)
		silentWarpPlayer(offsetX, offsetY)
	}
end

def mysticalWarpEffect(&block)
	teleportLeaveAnimation(false)

	pbWait(10)

	pbSEPlay("Anim/PRSFX- Calm Mind")

	pbWait(20)

	block.call

	pbWait(10)

	pbSEPlay("Anim/PRSFX- Calm Mind")

	pbWait(20)

	teleportArriveAnimation(false)

	command_210 # Wait for move's completion
end

def silentWarpPlayer(offsetX, offsetY)
	$game_player.silent_offset(offsetX, offsetY)
	centerCameraOnPlayer
	$game_map.update
    $scene.force_update_characters
	$game_map.autoplay
	Graphics.frame_reset
	Input.update
end