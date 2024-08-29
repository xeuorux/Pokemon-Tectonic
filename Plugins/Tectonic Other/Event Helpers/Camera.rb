def blackFadeOutIn(length=10,&block)
	if $PokemonSystem.skip_fades == 1 || !$DEBUG
		fadeToBlack(length)
	end
	block.call if block_given?
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

def controlledCameraPreview(centerX,centerY,maxXOffset = 6, maxYOffset = 3, cameraSpeed = 0.15)
	$game_map.controlledCameraPreview(centerX,centerY,maxXOffset,maxYOffset,cameraSpeed)
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