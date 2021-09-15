def pbSetSelfSwitch(eventid, switch_name, value, mapid = -1)
	$game_system.map_interpreter.pbSetSelfSwitch(eventid, switch_name, value, mapid)
end

def pbReceiveRandomPokemon(level)
  $game_variables[26] = level if level > $game_variables[26]
  possibleSpecies = []
  GameData::Species.each do |species_data|
	next if species_data.get_evolutions.length > 0 && ![:ONIX,:SCYTHER].include?(species_data.species)
	next if isLegendary(species_data.id)
	if species_data.real_form_name
		regionals = ["alolan","galarian","makyan"]
		regionalForm = false
		regionals.each do |regional|
			regionalForm = true if species_data.real_form_name.downcase.include?(regional)
		end
		next if !regionalForm
	end
	possibleSpecies.push(species_data)
  end
  speciesDat = possibleSpecies.sample
  pkmn = Pokemon.new(speciesDat.species, level)
  pkmn.form = speciesDat.form
  pbAddPokemonSilent(pkmn)
  pbMessage(_INTL("You recieved a #{speciesDat.real_name} (#{speciesDat.real_form_name})"))
end

def healPartyWithDelay()
	$Trainer.heal_party
	pbMEPlay('Pkmn healing')
	pbWait(68)
end

def earnBadge(badgeNum)
	badgeNames = [
		"Loyalty",
		"Perseverance",
		"Reverence",
		"Patience",
		"Solidarity",
		"Clarity",
		"Generosity",
		"Mercy"
	]
	name = badgeNames[badgeNum-1]
	pbMessage(_INTL("\\me[Badge get]You've earned the {1} Badge.",name))
	$Trainer.badges[badgeNum-1]=true
	$game_switches[3+badgeNum]=true # "Defeated Gym X" switch
	pbWait(120)
	
	# Increase the level cap
	case badgeNum
	when 1
		pbSetLevelCap(20)
	when 2..4
		pbIncreaseLevelCap(5)
	when 5
		pbSetLevelCap(45)
	when 6,7
		pbIncreaseLevelCap(5)
	when 8
		pbSetLevelCap(70)
	else
		echo("Gym badge #{index} not yet defined!\n")
	end
end

def receivedGymRewardYet?(index)
	if $game_variables[78] == 0
		$game_variables[78] = [false] * 8
	end
	
	return $game_variables[78][index]
end

def receiveGymReward(badgeNum)
	index = badgeNum-1
	case index
	when 0,1
		pbReceiveItem(:FULLRESTORE)
		pbReceiveItem(:MAXREPEL)
		pbReceiveItem(:ULTRABALL)
		pbReceiveItem(:MAXREVIVE)
	else
		echo("Gym item #{index} not yet defined!\n")
	end
	
	$game_variables[78][index] = true # Mark the item as having been received
end

def gymLeaderDialogueHash()
	return @leaderDialogueHash if @leaderDialogueHash
	@leaderDialogueHash = {
		0 => ["I'll heal up your Pokémon, give your other rewards, and get out of your way.",
		"I'll heal up your Pokémon and get out of your way."],
		1 => ["Let me tend to the Pokémon, and hand over something special, while you bask in your victory.",
		"Let me tend to the Pokémon while you bask in your victory."]
	}
	return @leaderDialogueHash
end

def healAndGiveRewardIfNotYetGiven(badgeNum)
	index = badgeNum-1
	dialogue = gymLeaderDialogueHash[index]
	if receivedGymRewardYet?(index)
		pbMessage(dialogue[1])
		healPartyWithDelay()
	else
		pbMessage(dialogue[0])
		healPartyWithDelay()
		receiveGymReward(index)
	end
end

def perfectTrainer()
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone()
	}
	pbTrainerDropsItem()
end

def perfectDoubleTrainer(event1,event2)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSetSelfSwitch(event1,'D',true)
		pbSetSelfSwitch(event2,'D',true)
		setFollowerGone(event1)
		setFollowerGone(event2)
	}
	pbTrainerDropsItem()
	pbTrainerDropsItem()
end

def defeatTrainer()
	setMySwitch('A',true)
	setFollowerInactive()
end

def defeatDoubleTrainer(event1,event2)
	setMySwitch('A',true)
	pbSetSelfSwitch(event1,'A',true)
	pbSetSelfSwitch(event2,'A',true)
	setFollowerInactive(event1)
	setFollowerInactive(event2)
end

def rejectTooFewPokemon(dialogue)
	if $Trainer.ablePokemonCount<=1
		pbMessage(dialogue)
		new_move_route = RPG::MoveRoute.new
		new_move_route.repeat    = false
		new_move_route.skippable = false
		new_move_route.list.clear
		new_move_route.list.push(RPG::MoveCommand.new(13)) # Backwards
		new_move_route.list.push(RPG::MoveCommand.new(0)) # End
		get_player.force_move_route(new_move_route)
		@move_route_waiting = true if !$game_temp.in_battle # Wait for move route completion
		command_end # Exit event processing
	end
end

def setFollowerInactive(eventId=0)
	follower = getFollowerPokemon(eventId)
	if !follower
		pbMessage("ERROR: Could not find follower Pokemon!")
		return
	end
	showBallReturn(follower.x,follower.y)
	pbWait(Graphics.frame_rate/10)
	pbSetSelfSwitch(follower.id,'A',true)
end

def setFollowerGone(eventId=0)
	follower = getFollowerPokemon(eventId)
	if !follower
		pbMessage("ERROR: Could not find follower Pokemon!")
		return
	end
	pbSetSelfSwitch(follower.id,'D',true)
end

def showBallReturn(x,y)
	$scene.spriteset.addUserAnimation(30,x,y)
end

def getFollowerPokemon(eventId=0)
	x = get_character(eventId).original_x
	y = get_character(eventId).original_y
	
	follower = nil
	for event in $game_map.events.values
		next unless event.name.downcase.include?("follower") ||
			event.name.downcase.include?("overworld")
		xDif = (event.x - x).abs
		yDif = (event.y - y).abs
		next unless xDif <= 1 && yDif <= 1 # Must be touching
		follower = event
		break
    end
	return follower
end

def phoneCallSE()
	msgwindow = pbCreateMessageWindow()
	3.times do
		pbMessageDisplay(msgwindow,"\\se[Voltorb Flip level up]Ring ring...")
		pbWait(20)
	end
	pbDisposeMessageWindow(msgwindow)
	Input.update
end

def phoneCall(caller="Unknown",eventSwitch=nil)
	phoneCallSE()
	setMySwitch(eventSwitch,true) if eventSwitch
	if !pbConfirmMessage(_INTL("...It's {1}. Pick up the phone?", caller))
		phoneCallEnd()
		command_end
		return
	end	
end

def phoneCallEnd()
	pbMessage(_INTL("\\se[Voltorb Flip mark]Click."))
	pbWait(40)
end

def showQuestion(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(4,event.x,event.y)
end

def showExclamation(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(3,event.x,event.y)
end

def showHappy(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,event.x,event.y)
end

def showNormal(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,event.x,event.y)
end

def showHate(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,event.x,event.y)
end

def showPoison(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Poison,event.x,event.y)
end

def showSing(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Sing,event.x,event.y)
end

def showLove(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Love,event.x,event.y)
end

def showPokeballEnter(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_In,event.x,event.y)
end

def showPokeballExit(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_Out,event.x,event.y)
end

def blackFadeOutIn(&block)
	$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
	pbWait(14)
	block.call
	$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
end

def setMySwitch(switch,value)
	pbSetSelfSwitch(get_self.id,switch,value)
end

Down = 2
Left = 4
Right = 6
Up = 8

def moveBackAndForth(length,initialDirection=Right,transverseLength=0,clockwise=true)
	back_and_forth_route = getNewMoveRoute()
	
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

def purchaseStarters(type,price=5000)
	return unless [:GRASS,:FIRE,:WATER].include?(type)
	typeName = GameData::Type.get(type).real_name
	
	pbMessage("Hello, and welcome to the Starters Store!")
	pbMessage("I'm the #{typeName}-type starters salesperson!")
	pbMessage("You can buy a #{typeName}-type starter Pokemon from me if you have $#{price}.")
	if $Trainer.money < price
		pbMessage("I'm sorry, but it seems as though you don't have that much money.")
		return
	end
	pbMessage("Would you like to buy a #{typeName}-type starter Pokemon?")
	
	starterArray = []
	case type
	when :GRASS
		starterArray = ["None","Bulbasaur","Chikorita","Turtwig","Snivy","Chespin","Rowlet","Grookey"]
	when :FIRE
		starterArray = ["None","Charmander","Torchic","Chimchar","Tepig","Fennekin","Litten","Scorbunny"]
	when :WATER
		starterArray = ["None","Squirtle","Totodile","Mudkip","Piplup","Oshawott","Froakie","Popplio","Sobble"]
	else
		return
	end
	
	result = pbShowCommands(nil,starterArray)
	if result == 0
		pbMessage("Understood, please come back if there's a #{typeName}-type starter Pokemon you'd like to purchase!")
	else
		starterChosenName = starterArray[result]
		starterSpecies = starterChosenName.upcase.to_sym
		pbAddPokemon(starterSpecies,10)
		pbMessage("\PN handed over $#{price} in exchange.")
		$Trainer.money -= price
		pbMessage("Thank you for shopping here at the Starters Store!")
	end
end

def timedCameraPreview(centerX,centerY,seconds = 5)
	$game_map.timedCameraPreview(centerX,centerY,seconds)
end

def centerCameraOnPlayer()
	$game_map.centerCameraOnPlayer()
end

def slideCameraToPlayer(speed=3)
	$game_map.slideCameraToPlayer(speed)
end

def slideCameraToEvent(event_id=0,speed=3)
	event = get_character(event_id)
	$game_map.slideCameraToSpot(event.x,event.y,speed)
end

def slideCameraToSpot(centerX,centerY,speed=3)
	$game_map.slideCameraToSpot(centerX,centerY,speed)
end

class Game_Map
	def slideCameraToSpot(centerX,centerY,speed=3)
		distX = (centerX - 8) - (self.display_x/128)
		xDirection = distX > 0 ? 6 : 4
		distY = (centerY - 6) - (self.display_y/128)
		yDirection = distY > 0 ? 2 : 8
		distXAbs = distX.abs
		distYAbs = distY.abs
		if distXAbs > distYAbs
			pbScrollMap(xDirection,distXAbs,speed) if distXAbs > 0
			pbScrollMap(yDirection,distYAbs,speed) if distYAbs > 0
		else
			pbScrollMap(yDirection,distYAbs,speed) if distYAbs > 0
			pbScrollMap(xDirection,distXAbs,speed) if distXAbs > 0
		end
	end

	def timedCameraPreview(centerX,centerY,seconds = 5)
		prevCameraX = self.display_x
		prevCameraY = self.display_y
		blackFadeOutIn {
			self.display_x = (centerX - 8) * 128
			self.display_y = (centerY - 8) * 128
		}
		Graphics.update
		pbWait(Graphics.frame_rate*seconds)
		blackFadeOutIn {
			self.display_x = prevCameraX
			self.display_y = prevCameraY
		}
	end
	
	def centerCameraOnPlayer()
		self.display_x = $game_player.x * 128
		self.display_y = $game_player.y * 128
	end
	
	def slideCameraToPlayer(speed=3)
		slideCameraToSpot($game_player.x,$game_player.y,speed)
	end
end

def turnPlayerTowardEvent(eventId = 0)
	event = get_character(eventId)
	turnPlayerTowardSpot(event.x,event.y)
end

def turnPlayerTowardSpot(x,y)
	$game_player.turn_towards_spot(x,y)
end

class Game_Player < Game_Character
	def turn_towards_spot(otherX,otherY)
		sx = @x + @width / 2.0 - otherX
		sy = @y - @height / 2.0 - otherY
		return if sx == 0 && sy == 0
		if sx.abs > sy.abs
		  (sx > 0) ? turn_left : turn_right
		else
		  (sy > 0) ? turn_up : turn_down
		end
	end
end

def stowFollowerIfActive()
	if $PokemonGlobal.follower_toggled
		pbToggleFollowingPokemon("off",true)
		pbWait(Graphics.frame_rate)
	end
end

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
end

def defeatBoss(item=nil,count=1)
	pbMessage("The avatar staggers, then drifts away into nothingness.")
	blackFadeOutIn {
		setMySwitch('A',true)
	}
	return if item == nil
	if count == 1
		pbMessage("It left behind an item!")
		pbReceiveItem(item)
	elsif count > 1
		pbMessage("It left behind some items!")
		pbReceiveItem(item,count)
	end
end

def introduceAvatar(species)
	pbPlayCrySpecies(species)
	$game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
	pbWait(2 * Graphics.frame_rate)
end

def pbDeleteItem(item,amount=1)
	$PokemonBag.pbDeleteItem(item,amount)
end