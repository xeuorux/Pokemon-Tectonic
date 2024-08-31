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

# Corners go NW, NE, SE, SW
def conveyorBeltLogic(corners)
	conveyor_route = getNewMoveRoute()
	conveyor_route.repeat = true

	westX = corners[0][0]
	eastX = corners[1][0]
	northY = corners[0][1]
	southY = corners[2][1]

	if westX >= eastX || northY >= southY
		echoln("Failed to create a conveyor belt logic with these params.")
		return
	end

	currentX = self.x
	currentY = self.y
	firstX = self.x
	firstY = self.y
	targetCornerIndex = getNextClockwiseCornerIndex(corners, currentX, currentY)
	targetCorner = corners[targetCornerIndex]
	echoln("The target corner is first set at index #{targetCornerIndex}: #{targetCorner}")

	loop do
		# Then, determine if should be opaque or not
		if block_given?
			opacity = yield currentX,currentY
			conveyor_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Opacity,[opacity]))
		end

		case targetCornerIndex
		when 0
			conveyor_route.list.push(RPG::MoveCommand.new(Up/2))
			currentY -= 1

			echoln("Moving North")

			if currentY == targetCorner[1]
				targetCornerIndex = 1
				targetCorner = corners[targetCornerIndex]
				echoln("The target corner is changed to index #{targetCornerIndex}: #{targetCorner}")
			end
		when 1
			conveyor_route.list.push(RPG::MoveCommand.new(Right/2))
			currentX += 1

			echoln("Moving East")

			if currentX == targetCorner[0]
				targetCornerIndex = 2
				targetCorner = corners[targetCornerIndex]
				echoln("The target corner is changed to index #{targetCornerIndex}: #{targetCorner}")
			end
		when 2
			conveyor_route.list.push(RPG::MoveCommand.new(Down/2))
			currentY += 1

			echoln("Moving South")

			if currentY == targetCorner[1]
				targetCornerIndex = 3
				targetCorner = corners[targetCornerIndex]
				echoln("The target corner is changed to index #{targetCornerIndex}: #{targetCorner}")
			end
		when 3
			conveyor_route.list.push(RPG::MoveCommand.new(Left/2))
			currentX -= 1

			echoln("Moving West")

			if currentX == targetCorner[0]
				targetCornerIndex = 0
				targetCorner = corners[targetCornerIndex]
				echoln("The target corner is changed to index #{targetCornerIndex}: #{targetCorner}")
			end
		end

		# Stop moving if made it back to original positon
		break if currentX == firstX && currentY == firstY
	end

	conveyor_route.list.push(RPG::MoveCommand.new(0)) # End of move route
	
	self.set_move_route(conveyor_route)
end

def getNextClockwiseCornerIndex(corners, currentX, currentY)
	westX = corners[0][0]
	eastX = corners[1][0]
	northY = corners[0][1]
	southY = corners[2][1]

	nextCorner = 0
	if currentY == northY
		if currentX == eastX
			nextCorner = 2
		else
			nextCorner = 1
		end
	elsif currentY == southY
		if currentX == westX
			nextCorner = 0
		else
			nextCorner = 3
		end
	else
		if currentX == westX
			nextCorner = 0
		else
			nextCorner = 2
		end
	end
	return nextCorner
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

def birdCrossing(directions=[Left,Right,Up,Down],speed=nil)
	chooseDirection(directions,$game_map.width,$game_map.height)
	self.event.pages[0].move_speed = speed if speed
end

def chooseDirection(directions,width,height)
	direction = directions.sample
	
	new_route = getNewMoveRoute()
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

    new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,rand(10..20)))
	
	for i in 0..length
		new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Forward))
	end

    new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,rand(20..60)))

    new_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,
		["chooseDirection(#{directions.to_s},#{$game_map.width},#{$game_map.height})"]))
	
	new_route.list.push(RPG::MoveCommand.new(0))
		
	self.set_move_route(new_route)
end

def modulateOrbHueOverTime()
	calculatedHue = self.character_hue
	
	new_move_route = getNewMoveRoute()
	new_move_route.repeat = true
	
	maxHue = 160
	[maxHue,0].each do |hueTarget|
		targetReached = false
		while !targetReached
			distanceFromPoles = [(maxHue - calculatedHue).abs, calculatedHue.abs].min
			speed = (1 + distanceFromPoles / 12.0).floor
			if calculatedHue < hueTarget
				calculatedHue += speed
				if calculatedHue > hueTarget
					calculatedHue = hueTarget
					targetReached = true
				end
			else
				calculatedHue -= speed
				if calculatedHue < hueTarget
					calculatedHue = hueTarget
					targetReached = true
				end
			end
			calculatedHue = calculatedHue.round
			calculatedHue = calculatedHue.clamp(0,maxHue)
			params = [self.character_name,calculatedHue,self.direction,self.pattern]
			new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Graphic,params))
			new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[1]))
		end
	end
	
	new_move_route.list.push(RPG::MoveCommand.new(0))
	
	self.set_move_route(new_move_route)
end