def battlePerfected?
	return $game_switches[94]
end

def perfectTrainer(maxTrainerLevel=15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone
	}
	pbTrainerDropsItem(maxTrainerLevel)
end

def perfectAncientTrainer
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone
	}
	pbMessage("The fleeing trainer dropped some food!")
	pbReceiveItem(:VANILLATULUMBA)
end

def perfectAceTrainer(maxTrainerLevel=15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		setFollowerGone
	}
	pbTrainerDropsItem(maxTrainerLevel,4)
end

def perfectDoubleTrainer(event1,event2,maxTrainerLevel = 15)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSetSelfSwitch(event1,'D',true)
		pbSetSelfSwitch(event2,'D',true)
		setFollowerGone(event1)
		setFollowerGone(event2)
	}
	pbTrainerDropsItem(maxTrainerLevel,2,true)
end

def perfectDoubleAncientTrainer(event1,event2)
	blackFadeOutIn() {
		setMySwitch('D',true)
		pbSetSelfSwitch(event1,'D',true)
		pbSetSelfSwitch(event2,'D',true)
		setFollowerGone(event1)
		setFollowerGone(event2)
	}

	pbMessage("The fleeing trainers dropped some food!")
	pbReceiveItem(:VANILLATULUMBA,2)
end

def pbTrainerDropsItem(maxTrainerLevel = 15,multiplier=1,plural=false)
	itemsGiven = candiesForLevel(maxTrainerLevel)
	
	total = 0
	for i in 0...itemsGiven.length/2
		itemsGiven[i*2 + 1] *= multiplier
		total += itemsGiven[i*2 + 1]
	end
	if total == 1
		if plural
			pbMessage("One of the fleeing trainers dropped a candy!")
		else
			pbMessage("The fleeing trainer dropped a candy!")
		end
	else
		if plural
			pbMessage("The fleeing trainers dropped some candies!")
		else
			pbMessage("The fleeing trainer dropped some candies!")
		end
	end
	
	for i in 0...itemsGiven.length/2
		pbReceiveItem(itemsGiven[i*2],itemsGiven[i*2 + 1])
	end
end

def candiesForLevel(level)
  # For a medium slow pokemon (e.g. starters):
  # 10: 200, 15: 500, 20: 1000
  # 25: 1700, 30: 2500, 35: 3500
  # 40: 4800, 45: 6200, 50: 7800
  # 55: 9500, 60: 11,500, 65: 13,500
  itemsGiven = []
  case level
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
  when 68..72
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,2] # 20000
  when 68..72
	itemsGiven = [:EXPCANDYL,1,:EXPCANDYM,2] # 20000
  else
	pbMessage("Unassigned level passed to pbTrainerDropsItem: #{maxTrainerLevel}") if $DEBUG
	itemsGiven = [:EXPCANDYXS,1] # 250
  end
  return itemsGiven
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

def rejectTooFewPokemon(dialogue,movePlayer=true)
	if $Trainer.ablePokemonCount <= 1
		dialogue = "Unable to start double battle with only 1 able Pokemon." unless dialogue
		pbMessage(dialogue)
		if movePlayer
			new_move_route = RPG::MoveRoute.new
			new_move_route.repeat    = false
			new_move_route.skippable = false
			new_move_route.list.clear
			new_move_route.list.push(RPG::MoveCommand.new(13)) # Backwards
			new_move_route.list.push(RPG::MoveCommand.new(0)) # End
			get_player.force_move_route(new_move_route)
			@move_route_waiting = true if !$game_temp.in_battle # Wait for move route completion
		end
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

def allTrainersBeaten(events)
	events.each do |event_id|
		trainerAOn = $game_self_switches[[$game_map.map_id,event_id,"A"]]
		trainerDOn = $game_self_switches[[$game_map.map_id,event_id,"D"]]
		trainerBeaten = trainerAOn || trainerDOn
    	if !trainerBeaten
			return false
		end
	end
	return true
end

def allTrainersPerfected(events)
	events.each do |event_id|
		trainerDOn = $game_self_switches[[$game_map.map_id,event_id,"D"]]
    	if !trainerDOn
			return false
		end
	end
	return true
end

def allEventsExclaim(eventIDArray)
	eventIDArray.each do |id|
		showExclamation(id)
		pbWait(10)
	end
end

def wildBattlersFlee(eventIDArray)
	allEventsExclaim(eventIDArray)
	pbWait(20)
	blackFadeOutIn {
		pbSEPlay('Battle flee')
		eventIDArray.each do |id|
			pbSetSelfSwitch(id,'D')
		end
	}
end