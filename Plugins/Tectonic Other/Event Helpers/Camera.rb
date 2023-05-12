def blackFadeOutIn(length=10,&block)
	if $PokemonSystem.skip_fades == 1 || !$DEBUG
		fadeToBlack(length)
	end
	block.call
	if $PokemonSystem.skip_fades == 1 || !$DEBUG
		fadeIn(length)
	end
end

def fadeToBlack(length=10)
	adjustedDuration = length * Graphics.frame_rate / 20
	$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), adjustedDuration)
	pbWait(adjustedDuration)
end

def fadeIn(length=10)
	adjustedDuration = length * Graphics.frame_rate / 20
	$game_screen.start_tone_change(Tone.new(0,0,0,0), adjustedDuration)
	pbWait(adjustedDuration)
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