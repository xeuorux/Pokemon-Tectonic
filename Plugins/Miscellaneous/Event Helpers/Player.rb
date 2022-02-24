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

def mapTransitionTransfer(map_id,x,y)
	pbSEPlay('Exit Door',80)
	blackFadeOutIn {
		distanceX = $game_player.x - get_self.x
		distanceY = $game_player.y - get_self.y

		$game_temp.player_transferring = true
		$game_temp.player_new_map_id    = map_id || $game_map.map_id
		$game_temp.player_new_x         = x + distanceX
		$game_temp.player_new_y         = y + distanceY
		$game_temp.player_new_direction = $game_player.direction
		
		Graphics.freeze
		$game_temp.transition_processing = true
		$game_temp.transition_name       = ""
	}
end

def healPartyWithDelay()
	$Trainer.heal_party
	pbMEPlay('Pkmn healing')
	pbWait(68)
	refillAidKit()
end