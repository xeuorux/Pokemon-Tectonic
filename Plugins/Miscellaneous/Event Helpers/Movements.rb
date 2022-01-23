class Game_Character
	def set_move_route(move_route)
		@move_route         = move_route
		@move_route_index   = 0
		move_type_custom
	end
end

def getNewMoveRoute()
	new_move_route = RPG::MoveRoute.new
	new_move_route.repeat    = false
	new_move_route.skippable = false
	new_move_route.list.clear
	return new_move_route
end

def moveBackAndForth(length,initialDirection=Right,transverseLength=0,clockwise=true)
	back_and_forth_route = getNewMoveRoute()
	back_and_forth_route.repeat = true
	
	case initialDirection
	when 2 # Down
		transverseDirection = clockwise ? Left : Right
	when 4 # Left
		transverseDirection = clockwise ? Up : Down
	when 6 # Right
		transverseDirection = clockwise ? Down : Up
	when 8 # Up
		transverseDirection = clockwise ? Right : Left
	end
	
	inverseInitialDirection = 10 - initialDirection
	inverseTransverseDirection = 10 - transverseDirection
	
	length.times {
		back_and_forth_route.list.push(RPG::MoveCommand.new(initialDirection/2))
	}
	transverseLength.times {
		back_and_forth_route.list.push(RPG::MoveCommand.new(transverseDirection/2))
	}
	length.times {
		back_and_forth_route.list.push(RPG::MoveCommand.new(inverseInitialDirection/2))
	}
	transverseLength.times {
		back_and_forth_route.list.push(RPG::MoveCommand.new(inverseTransverseDirection/2))
	}
		
	back_and_forth_route.list.push(RPG::MoveCommand.new(0)) # End of move route
	
	self.set_move_route(back_and_forth_route)
end


def modulateOpacityOverTime(speed)
	currentOpacity = self.opacity
	
	new_move_route = getNewMoveRoute()
	new_move_route.repeat = true
	
	[0,255].each do |opacityTarget|
		calculatedOpacity = currentOpacity
		targetReached = false
		while !targetReached
			if calculatedOpacity < opacityTarget
				calculatedOpacity += speed
				if calculatedOpacity > opacityTarget
					calculatedOpacity = opacityTarget
					targetReached = true
				end
			else
				calculatedOpacity -= speed
				if calculatedOpacity < opacityTarget
					calculatedOpacity = opacityTarget
					targetReached = true
				end
			end
			output = calculatedOpacity.round
			output = [[output,0].max,255].min
			new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Opacity,[output]))
			new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[1]))
		end
	end
	
	new_move_route.list.push(RPG::MoveCommand.new(0))
	
	self.set_move_route(new_move_route)
end

def birdCrossing(directions=[Left,Right,Up,Down],speed=4)
	bird_route = getNewMoveRoute()
	bird_route.repeat = true
	
	bird_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,
		["chooseDirection(#{directions.to_s},#{$game_map.width},#{$game_map.height})"]))
	
	bird_route.list.push(RPG::MoveCommand.new(0))
	
	self.set_move_route(bird_route)
	self.event.pages[0].move_speed = speed
end

def chooseDirection(directions,width,height)
	direction = directions.sample
	
	new_route = getNewMoveRoute()
	new_route.repeat = true
	new_route.skippable = true
	
	self.direction = direction
	
	length = 0
	turn = nil
	case direction
	when Up
		length = height
		new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,
			["self.moveto(#{rand(width).floor},#{height-1})"]))
	when Down
		length = height
		new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,
			["self.moveto(#{rand(width).floor},0)"]))
	when Left
		length = width
		new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,
			["self.moveto(#{width-1},#{rand(height).floor})"]))
	when Right
		length = width
		new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,
			["self.moveto(0,#{rand(height).floor})"]))
	end
	
	for i in 0..length
		new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Forward))
	end
	
	new_route.list.push(RPG::MoveCommand.new(0))
		
	self.set_move_route(new_route)
end