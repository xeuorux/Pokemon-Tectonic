def turnPlayerTowardEvent(eventId = 0)
	event = get_character(eventId)
	turnPlayerTowardSpot(event.x,event.y)
end

def turnPlayerTowardSpot(x,y)
	$game_player.turn_towards_spot(x,y)
end

def stowFollowerIfActive()
	if $PokemonGlobal.follower_toggled
		pbToggleFollowingPokemon("off",!$PokemonGlobal.bicycle)
		pbWait(Graphics.frame_rate)
	end
end

def unstowFollowerIfAllowed()
	if $PokemonSystem.followers == 0
		pbToggleFollowingPokemon("on",!$PokemonGlobal.bicycle)
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

def getEventByID(event_id,map_id = -1)
	begin
		map_id = $game_map.map_id if map_id < 0
		mapData = Compiler::MapData.new
		map = mapData.getMap(map_id)
		event = map.events[event_id]
		return event
	rescue Error
		return nil
	end
end

def transferPlayerToEvent(event,direction=-1,map_id = -1,offset=[0,0])
	event = getEventByID(event,map_id) if event.is_a?(Integer)
	return false if event.nil?
	x = event.x + offset[0]
	y = event.y + offset[1]
	direction = $game_player.direction if direction < 0
	transferPlayer(x,y,direction,map_id)
	return true
end

def teleportPlayer(map_id,x,y,instant=false,dir = nil)
	$game_temp.player_transferring = true
	$game_temp.player_new_map_id    = map_id || $game_map.map_id
	$game_temp.player_new_x         = x
	$game_temp.player_new_y         = y
	$game_temp.player_new_direction = dir || $game_player.direction
	
	Graphics.freeze
	$game_temp.transition_processing = true
	$game_temp.transition_name       = ""

	$scene.transfer_player if instant
end

def healPartyWithDelay(skipAidKit = false)
	$Trainer.heal_party
	pbMEPlay('Pkmn healing')
	pbWait(68)
	refillAidKit unless skipAidKit
end

def pumpedUp?
	return !$PokemonGlobal.exp_multiplier.nil? && $PokemonGlobal.exp_multiplier > 1.0
end

def resetEXPBonus
	return unless pumpedUp?
	$PokemonGlobal.exp_multiplier = 1.0
	pbMessage(_INTL("You no longer feel pumped up."))
end

def nonLegendarySpeciesCount(owned = false)
    count = 0
    GameData::Species.each do |speciesData|
        next unless speciesData.form == 0
        next if speciesData.isLegendary?
        next if speciesData.isTest?
        next if owned && !$Trainer.pokedex.owned?(speciesData.species)
        count += 1
    end
    return count
end

def dexCompletionPercent
    ownedCount = nonLegendarySpeciesCount(true)
    totalCount = nonLegendarySpeciesCount
	ratio = 100.0 * ownedCount.to_f / totalCount.to_f
	return ratio.floor
end

def readOutDexCompletionPercent
    pbMessage(_INTL("You've currently completed {1} percent of the Dex.",dexCompletionPercent))
end

def lockPlayerInput
	$game_player.lock
	$game_system.menu_disabled = true
end

def unlockPlayerInput
	$game_player.unlock
	$game_system.menu_disabled = false
end

def playerOffsetX
    return $game_player.x - get_self.x
end

def playerOffsetY
    return $game_player.y - get_self.y
end

def playerCirclesThisToFaceNorth
    return if playerFacingNorth? && playerOffsetX == 0
    eventWidth = get_self.width
    eventHeight = get_self.width

    new_move_route = getNewMoveRoute()
    
    xMovement = -playerOffsetX - 1
    yMovement = playerOffsetY - 1

    echoln("#{playerOffsetX},#{playerOffsetY}")

    if playerOffsetX >= eventWidth || playerFacingNorth?
        yDir = yMovement > 0 ? Up/2 : Down/2
        (yMovement.abs).times do |i|
            new_move_route.list.push(RPG::MoveCommand.new(yDir))
        end
        xDir = xMovement > 0 ? Right/2 : Left/2
        (xMovement.abs - 1).times do |i|
            new_move_route.list.push(RPG::MoveCommand.new(xDir))
        end
    else
        xDir = xMovement > 0 ? Right/2 : Left/2
        (xMovement.abs).times do |i|
            new_move_route.list.push(RPG::MoveCommand.new(xDir))
        end
        yDir = yMovement > 0 ? Up/2 : Down/2
        (yMovement.abs).times do |i|
            new_move_route.list.push(RPG::MoveCommand.new(yDir))
        end
        new_move_route.list.push(RPG::MoveCommand.new(Right/2))
    end
    
    new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::TurnUp))

    new_move_route.list.push(RPG::MoveCommand.new(0)) # End of move route
    get_player.force_move_route(new_move_route)
end
