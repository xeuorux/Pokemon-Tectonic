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
	refillAidKit()
end

def earnBadge(badgeNum)
	badgeNames = [
		"Loyalty",
		"Perseverance",
		"Patience",
		"Reverence",
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

def healAndGiveRewardIfNotYetGiven(badgeNum)
	index = badgeNum-1
	leaderDialogue =
		["I'll heal up your Pokémon and get out of your way.",
		"Let me tend to your Pokémon while you bask in your victory."][index] || ""
	pbMessage(leaderDialogue) if !leaderDialogue.blank?
	healPartyWithDelay()
end

def perfectTrainer(maxTrainerLevel=15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone()
	}
	pbTrainerDropsItem(maxTrainerLevel)
end

def perfectDoubleTrainer(event1,event2,maxTrainerLevel = 15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSetSelfSwitch(event1,'D',true)
		pbSetSelfSwitch(event2,'D',true)
		setFollowerGone(event1)
		setFollowerGone(event2)
	}
	pbTrainerDropsItem(maxTrainerLevel)
	pbTrainerDropsItem(maxTrainerLevel)
end

def pbTrainerDropsItem(maxTrainerLevel = 15)
  # For a medium slow pokemon (e.g. starters):
  # 10: 200, 15: 500, 20: 1000
  # 25: 1700, 30: 2500, 35: 3500
  # 40: 4800, 45: 6200, 50: 7800
  # 55: 9500, 60: 11,500, 65: 13,500
  itemsGiven = []
  case maxTrainerLevel
  when 0..12
	itemsGiven = [:EXPCANDYXS,1] # 250
  when 13..17
	itemsGiven = [:EXPCANDYXS,2] # 500
  when 18..22
	itemsGiven = [:EXPCANDYS,1] # 1000
  when 23..27
	itemsGiven = [:EXPCANDYS,2] # 2000
  when 28..32
	itemsGiven = [:EXPCANDYS,3] # 3000
  when 33..37
	itemsGiven = [:EXPCANDYM,1] # 4000
  when 38..42
	itemsGiven = [:EXPCANDYM,1,:EXPCANDYS,1] # 5000
  when 43..47
	itemsGiven = [:EXPCANDYM,1,:EXPCANDYS,2] # 6000
  when 48..52
	itemsGiven = [:EXPCANDYM,2] # 8000
  when 53..57
	itemsGiven = [:EXPCANDYM,2,:EXPCANDYS,2] # 10000
  when 58..62
	itemsGiven = [:EXPCANDYL,1] # 12000
  when 63..67
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,1] # 16000
  when 68..70
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,2] # 20000
  else
	pbMessage("Unassigned level passed to pbTrainerDropsItem: #{maxTrainerLevel}") if $DEBUG
	itemsGiven = [:EXPCANDYXS,1] # 250
  end
  total = 0
  for i in 0...itemsGiven.length/2
  	total += itemsGiven[i*2 + 1]
  end
  if total == 1
	pbMessage("The fleeing trainer dropped a candy!")
  else
	pbMessage("The fleeing trainer dropped some candies!")
  end
  for i in 0...itemsGiven.length/2
  	pbReceiveItem(itemsGiven[i*2],itemsGiven[i*2 + 1])
  end
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
	followers = getFollowerPokemon(eventId)
	if followers.nil? || followers.length == 0
		pbMessage("ERROR: Could not find follower Pokemon!") if $DEBUG
		return
	end
	followers.each do |follower|
		showBallReturn(follower.x,follower.y)
		pbWait(Graphics.frame_rate/10)
		pbSetSelfSwitch(follower.id,'A',true)
	end
end

def setFollowerGone(eventId=0)
	followers = getFollowerPokemon(eventId)
	if followers.nil? || followers.length == 0
		pbMessage("ERROR: Could not find follower Pokemon!") if $DEBUG
		return
	end
	followers.each do |follower|
		pbSetSelfSwitch(follower.id,'D',true)
	end
end

def showBallReturn(x,y)
	$scene.spriteset.addUserAnimation(30,x,y)
end

def getFollowerPokemon(eventId=0)
	x = get_character(eventId).original_x
	y = get_character(eventId).original_y
	
	followers = []
	for event in $game_map.events.values
		next unless event.name.downcase.include?("follower")
		xDif = (event.x - x).abs
		yDif = (event.y - y).abs
		next unless xDif <= 1 && yDif <= 1 # Must be touching
		followers.push(event)
    end
	return followers
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
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(4,event.x,event.y)
end

def showExclamation(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(3,event.x,event.y)
end

def showHappy(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,event.x,event.y)
end

def showNormal(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,event.x,event.y)
end

def showHate(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,event.x,event.y)
end

def showPoison(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Poison,event.x,event.y)
end

def showSing(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Sing,event.x,event.y)
end

def showLove(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Love,event.x,event.y)
end

def showPokeballEnter(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_In,event.x,event.y)
end

def showPokeballExit(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_Out,event.x,event.y)
end

def blackFadeOutIn(length=10,&block)
	if $PokemonSystem.skip_fades == 1
		$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), length * Graphics.frame_rate / 20)
		pbWait(length * Graphics.frame_rate / 20)
	end
	block.call
	if $PokemonSystem.skip_fades == 1
		$game_screen.start_tone_change(Tone.new(0,0,0,0), length * Graphics.frame_rate / 20)
		pbWait(length * Graphics.frame_rate / 20)
	end
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

def purchaseStarters(type,price=3000)
	return unless [:GRASS,:FIRE,:WATER].include?(type)
	typeName = GameData::Type.get(type).real_name
	
	token = (type.to_s + "TOKEN").to_sym
	tokenName = GameData::Item.get(token).real_name
	
	pbMessage("Hello, and welcome to the Starters Store!")
	pbMessage("I'm the #{typeName}-type starters salesperson!")
	pbMessage("You can buy a #{typeName}-type starter Pokemon from me if you have $#{price} and a #{tokenName}.")
	if $Trainer.money < price
		pbMessage("I'm sorry, but it seems as though you don't have that much money.")
		return
	end
	if !$PlayerBag.pbHasItem?(token)
		pbMessage("I'm sorry, but it seems as though you don't have a #{tokenName}.")
		return
	end
	pbMessage("Would you like to buy a #{typeName}-type starter Pokemon?")
	
	starterArray = []
	case type
	when :GRASS
		starterArray = ["None","Bulbasaur","Chikorita","Treecko","Turtwig","Snivy","Chespin","Rowlet","Grookey"]
	when :FIRE
		starterArray = ["None","Charmander","Cyndaquil","Torchic","Chimchar","Tepig","Fennekin","Litten","Scorbunny"]
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
		pbMessage("\PN handed over $#{price} and a #{tokenName} in exchange.")
		$Trainer.money -= price
		$PlayerBag.pbDeleteItem(token)
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

def unstowFollowerIfAllowed()
	if $PokemonSystem.followers == 0
		pbToggleFollowingPokemon("on",true)
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
	
	unstowFollowerIfAllowed()
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

def introduceAvatar(species,form=0)
	Pokemon.play_cry(species, form)
	$game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
	pbWait(2 * Graphics.frame_rate)
end

def pbDeleteItem(item,amount=1)
	$PokemonBag.pbDeleteItem(item,amount)
end

def registerYezera(id = nil)
	stowFollowerIfActive
	pbToggleFollowingPokemon("off",false)
	$PokemonTemp.dependentEvents.removeEventByName("FollowerPkmn")
	pbRegisterPartner(:POKEMONTRAINER_Yezera,"Yezera",1)
	pbAddDependency2(id ? id : @event_id,"Yezera",3)
end

def transferPlayer(x,y,direction)
	$game_temp.player_transferring = true
	$game_temp.player_new_map_id    = $game_map.map_id
	$game_temp.player_new_x         = x
	$game_temp.player_new_y         = y
	$game_temp.player_new_direction = direction || $game_player.direction
	
	Graphics.freeze
	$game_temp.transition_processing = true
	$game_temp.transition_name       = ""
end

def hasPokemonInParty(speciesToCheck)
	if !speciesToCheck.is_a?(Array)
		speciesToCheck = [speciesToCheck]
	end
	hasAll = true
	speciesToCheck.each do |species|
		hasInParty = false
		$Trainer.party.each do |party_member|
			echoln("Comparing #{party_member.species} to #{species}")
			if party_member.species == species
				hasInParty = true
				break
			end
		end
		if !hasInParty
			hasAll = false
			break
		end
	end
	return hasAll
end

def weatherTMSell()
	pbPokemonMart(
		[:TM32,
		:TM33,
		:TM34,
		:TM35],
		"Do you like anything you see?"
	)
end

def terrainTMSell()
	pbPokemonMart(
		[:TM88,
		:TM89,
		:TM90,
		:TM91],
		"Do you like anything you see?"
	)
end

def teleportYezera()
	get_character(1).moveto($game_player.x-1,$game_player.y)
end

def noteMovedSelf()
	echoln("#{$PokemonMap}, #{get_self().id}, #{$game_map.events[get_self().id].name}")
	$PokemonMap.addMovedEvent(get_self().id) if $PokemonMap
end

def malasadaVendor()
	pbPokemonMart(
		[:BIGMALASADA,
		:BERRYJUICE,
		:SODAPOP],
		"Take a look, it's all delicious!"
	)
end

def hasFirstFourBadges?()
	return $game_switches[4] && $game_switches[5] && $game_switches[6] && $game_switches[7]
end

def reviveFossil(fossil)
	fossilsToSpecies = {
		:HELIXFOSSIL => :OMANYTE,
		:DOMEFOSSIL => :KABUTO,
		:OLDAMBER => :AERODACTYL,
		:ROOTFOSSIL => :LILEEP,
		:CLAWFOSSIL => :ANORITH,
		:SKULLFOSSIL => :CRANIDOS,
		:ARMORFOSSIL => :SHIELDON,
		:COVERFOSSIL => :TIRTOUGA,
		:PLUMEFOSSIL => :ARCHEN,
		:JAWFOSSIL => :TYRUNT,
		:SAILFOSSIL => :AMAURA
	}
	
	species = fossilsToSpecies[fossil] || nil
	
	if species.nil?
		pbMessage("Error! Could not determine how to revive the given fossil.")
		return
	end
	item_data = GameData::Item.get(fossil)
	
	pbMessage("\\PN hands over the #{item_data.name} and $3000.")
	
	pbMessage("The procedure has started, now just to wait...")
	
	blackFadeOutIn(30) {
		$Trainer.money = $Trainer.money - 3000
		$PokemonBag.pbDeleteItem(fossil)
	}
	
	pbMessage("It's done! Here is your newly revived Pokemon!")
	
	pbAddPokemon(species,10)
end

def pbSilentItem(item,quantity=1)
	$PokemonBag.pbStoreItem(item,quantity)
end

def showThinkingOverFollower(followerName = "Yezera")
	event = pbGetDependency(followerName)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,event.x,event.y)
end
