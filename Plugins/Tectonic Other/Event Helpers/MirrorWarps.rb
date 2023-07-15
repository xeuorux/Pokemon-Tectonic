def mirroredTeleportToEvent(event_id)
	teleportLeaveAnimation(false)

	pbWait(10)

	pbSEPlay("Anim/PRSFX- Calm Mind")

	pbWait(20)

	mapData = Compiler::MapData.new
	map = mapData.getMap($game_map.map_id)
	event = map.events[event_id]

	distanceX = $game_player.x - get_self.x
	distanceY = $game_player.y - get_self.y

	x = event.x - distanceX
	y = event.y - distanceY

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

	transferPlayer(x,y,direction)

	pbWait(10)

	pbSEPlay("Anim/PRSFX- Calm Mind")

	pbWait(20)

	teleportArriveAnimation(false)

	command_210 # Wait for move's completion
end

def silentWarpPlayer(offsetX, offsetY)
    $game_player.silent_offset(offsetX, offsetY)
end