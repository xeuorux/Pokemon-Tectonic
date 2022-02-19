def pbSetSelfSwitch(eventid, switch_name, value, mapid = -1)
	$game_system.map_interpreter.pbSetSelfSwitch(eventid, switch_name, value, mapid)
end

def setMySwitch(switch,value)
	pbSetSelfSwitch(get_self.id,switch,value)
end

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