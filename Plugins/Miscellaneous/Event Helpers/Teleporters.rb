def teleportLeaveAnimation
	stowFollowerIfActive()
	player = get_player

	new_move_route = getNewMoveRoute()
	frame = 0
	while frame <= 16
		opac = 255 * (1-frame/16.0)
		new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Opacity,[opac]))
		new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::PlaySE,[RPG::AudioFile.new("Player jump"),120])) if frame % 4 == 0
		new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[1]))
		frame += 1
	end

	new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[5]))
	new_move_route.list.push(RPG::MoveCommand.new(0)) # End of move route
	
	get_player.force_move_route(new_move_route)
end

def teleportArriveAnimation
	new_move_route = getNewMoveRoute()
	frame = 0
	while frame <= 16
		opac = 255 * (frame/16.0)
		new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Opacity,[opac]))
		new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::PlaySE,[RPG::AudioFile.new("Player jump"),120])) if frame % 4 == 0
		new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[1]))
		frame += 1
	end
	new_move_route.list.push(RPG::MoveCommand.new(0)) # End of move route
	
	get_player.force_move_route(new_move_route)
	
	unstowFollowerIfAllowed()
end