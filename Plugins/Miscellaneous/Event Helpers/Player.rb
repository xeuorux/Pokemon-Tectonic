def turnPlayerTowardEvent(eventId = 0)
	event = get_character(eventId)
	turnPlayerTowardSpot(event.x,event.y)
end

def turnPlayerTowardSpot(x,y)
	$game_player.turn_towards_spot(x,y)
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

def transferPlayer(x,y,direction,map_id = -1)
	$game_temp.player_transferring = true
	$game_temp.player_new_map_id    = map_id == -1 ? $game_map.map_id : map_id
	$game_temp.player_new_x         = x
	$game_temp.player_new_y         = y
	$game_temp.player_new_direction = direction || $game_player.direction
	
	Graphics.freeze
	$game_temp.transition_processing = true
	$game_temp.transition_name       = ""
end

def mapTransitionTransfer(map_id,x,y,fade=true)
	pbSEPlay('Exit Door',80) if fade
	distanceX = $game_player.x - get_self.x
	distanceY = $game_player.y - get_self.y
	if fade
		blackFadeOutIn {
			teleportPlayer(map_id,x + distanceX,y + distanceY)
		}
	else
		teleportPlayer(map_id,x + distanceX,y + distanceY)
	end
end

def transferPlayerToEvent(event_id,direction,map_id = -1,offset=[0,0])
	map_id = $game_map.map_id if map_id < 0
	mapData = Compiler::MapData.new
	map = mapData.getMap(map_id)
	event = map.events[event_id]
	x = event.x + offset[0]
	y = event.y + offset[1]
	transferPlayer(x,y,direction,map_id)
end

def teleportPlayer(map_id,x,y,instant=false)
	$game_temp.player_transferring = true
	$game_temp.player_new_map_id    = map_id || $game_map.map_id
	$game_temp.player_new_x         = x
	$game_temp.player_new_y         = y
	$game_temp.player_new_direction = $game_player.direction
	
	Graphics.freeze
	$game_temp.transition_processing = true
	$game_temp.transition_name       = ""

	$scene.transfer_player if instant
end

def healPartyWithDelay()
	$Trainer.heal_party
	pbMEPlay('Pkmn healing')
	pbWait(68)
	refillAidKit()
end

def dexCompletionPercent(dexNumber = -1)
	ratio = 100.0 * $Trainer.pokedex.owned_count(dexNumber).to_f / pbGetRegionalDexLength(dexNumber).to_f
	return ratio.floor
end

def lockPlayerInput
	$game_player.lock
	$game_system.menu_disabled = true
end

def unlockPlayerInput
	$game_player.unlock
	$game_system.menu_disabled = false
end

module Compiler
	class MapData
		def mapFilename(mapID)
		  	return sprintf("Data/Map%03d.rxdata", mapID)
		end
	end
end

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