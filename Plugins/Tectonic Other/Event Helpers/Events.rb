###############################################################
# Self-switches
###############################################################
def pbSetSelfSwitch(eventid, switch_name, value=true, mapid = -1)
	$game_system.map_interpreter.pbSetSelfSwitch(eventid, switch_name, value, mapid)
end

def setMySwitch(switch='A',value=true)
	pbSetSelfSwitch(get_self.id,switch,value)
end

def invertMySwitch(switch)
	value = !$game_self_switches[[$game_map.map_id, get_self.id, switch]]
	pbSetSelfSwitch(get_self.id,switch,value)
end

def pbSetAllSwitches(eventid, value, mapid = -1)
	['A','B','C','D'].each do |switch|
		pbSetSelfSwitch(eventid, switch, value, mapid)
	end
end

def pbGetSelfSwitch(eventid, switch = 'A', mapid = -1)
    mapid = $game_map.map_id if mapid < 0
    return $game_self_switches[[mapid, eventid, switch]]
end

def getMySwitch(switch)
	return pbGetSelfSwitch(get_self.id,switch)
end

def pbSetOnlySwitch(eventid, switch, value = true, mapid = -1)
	pbSetAllSwitches(eventid, !value, mapid)
	pbSetSelfSwitch(eventid, switch, value, mapid)
end

def pbGetFirstSwitch(eventid, value = true, mapid = -1)
	['A','B','C','D'].each do |switch|
		return switch if pbGetSelfSwitch(eventid, switch, mapid) == value
	end
	return nil
end

def setSwitchesAll(eventIDs, switch = 'A', value = true, mapid = -1)
	eventIDs.each do |eventID|
		pbSetSelfSwitch(eventID, switch, value, mapid)
	end
end

def fadeSwitchOn(switchName = 'A')
	blackFadeOutIn {
		setMySwitch(switchName,true)
	}
end

def fadeSwitchOff(switchName = 'A')
	blackFadeOutIn {
		setMySwitch(switchName,false)
	}
end

def toggleSwitch(eventID, switchName = 'A')
	mapid = $game_map.map_id
	currentValue = $game_self_switches[[mapid, eventID, switchName]]
	pbSetSelfSwitch(eventID,switchName,!currentValue,mapid)
end

def toggleSwitches(eventsArray,switchName="A")
	mapid = $game_map.map_id
	eventsArray.each do |eventID|
		currentValue = $game_self_switches[[mapid, eventID, switchName]]
		$game_self_switches[[mapid, eventID, switchName]] = !currentValue
	end
	$MapFactory.getMap(mapid, false).need_refresh = true
end

def fadeEventsIn(eventIDs)
	for i in 20..180 do
		eventIDs.each do |eventID|
			get_event(eventID).opacity = i
		end
		pbWait(1)
	end
end

###############################################################
# Global switches
###############################################################
def pbSetGlobalSwitch(switchID, value = true)
	$game_system.map_interpreter.setGlobalSwitch(switchID, value)
end

alias setGlobalSwitch pbSetGlobalSwitch

def getGlobalSwitch(switchID)
	return $game_switches[switchID]
end

def fadeGlobalSwitch(switchID, value = true)
	blackFadeOutIn {
		setGlobalSwitch(switchID, value)
	}
end

###############################################################
# Global variables
###############################################################
def setGlobalVariable(variableID, value)
	$game_system.map_interpreter.setVariable(variableID, value)
end

def getGlobalVariable(variableID)
	return $game_system.map_interpreter.getVariable(variableID)
end

def incrementGlobalVar(variableID)
	setVariable(variableID,getGlobalVariable(variableID) + 1)
end

def fadeVarIncrement(variableID)
	blackFadeOutIn {
		incrementGlobalVar(variableID)
	}
end

###############################################################
# Other event helpers
###############################################################
def refreshMapEvents()
	events = $game_map.events.values
	for event in events
		event.refresh()
    end
end

def noteMovedSelf()
	echoln("#{$PokemonMap}, #{get_self().id}, #{$game_map.events[get_self().id].name}")
	$PokemonMap.addMovedEvent(get_self().id) if $PokemonMap
end

def goToLabel(label_name)
	temp_index = 0
	loop do
		return true if temp_index >= @list.size - 1   # Reached end of commands
		# Check whether this command is a label with the desired name
		if @list[temp_index].code == 118 &&
		   @list[temp_index].parameters[0] == label_name
		  @index = temp_index
		  return true
		end
		# Command isn't the desired label, increment temp_index and keep looking
		temp_index += 1
	  end
end

def playerDirectlyWest?
	eventPosX = get_self.original_x
	eventPosY = get_character(0).original_y
	playerCheckPosX = eventPosX - 1
	playerCheckPosY = eventPosY
	return $game_player.x == playerCheckPosX && $game_player.y == playerCheckPosY
end

def playerDirectlyEast?
	eventPosX = get_self.original_x
	eventPosY = get_self.original_y
	playerCheckPosX = eventPosX + 1
	playerCheckPosY = eventPosY
	return $game_player.x == playerCheckPosX && $game_player.y == playerCheckPosY
end

def playerDirectlyNorth?
	eventPosX = get_self.original_x
	eventPosY = get_self.original_y
	playerCheckPosX = eventPosX
	playerCheckPosY = eventPosY - 1
	return $game_player.x == playerCheckPosX && $game_player.y == playerCheckPosY
end

def playerDirectlySouth?
	eventPosX = get_self.original_x
	eventPosY = get_self.original_y
	playerCheckPosX = eventPosX
	playerCheckPosY = eventPosY + 1
	return $game_player.x == playerCheckPosX && $game_player.y == playerCheckPosY
end

def playerFacingNorth?
	return $game_player.direction == Up
end

def playerFacingSouth?
	return $game_player.direction == Down
end

def playerFacingEast?
	return $game_player.direction == Right
end

def playerFacingWest?
	return $game_player.direction == Left
end

def turnEventTowardsEvent(eventToTurnID, eventToTurnTowardsID)
	pbTurnTowardEvent(pbMapInterpreter.get_event(eventToTurnID),pbMapInterpreter.get_event(eventToTurnTowardsID))
end

def turnTowardsEvent(eventID)
	pbTurnTowardEvent(get_self,pbMapInterpreter.get_event(eventID))
end

def turnEventTowardsThis(eventID)
	pbTurnTowardEvent(pbMapInterpreter.get_event(eventID),get_self)
end

def playerTurnsTowards
	turnEventTowardsThis(-1)
end

def turnPlayerTowardsEvent(eventID)
    pbTurnTowardEvent($game_player,pbMapInterpreter.get_event(eventID))
end

def playerOnTopOfEvent?(eventID)
    return get_character(eventID).at_coordinate?($game_player.x,$game_player.y)
end