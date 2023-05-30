class Game_Event < Game_Character
	attr_accessor :opacity
end

def defeatBoss(item=nil,count=1,opacityStart=180,opacityTarget=0)
	$PokemonGlobal.respawnPoint = nil

	event = get_self

	pbSEPlay("Avatar death")
	opacityStart.downto(opacityTarget) do |i|
		next if i % 3 != 0
		event.opacity = i
		pbWait(1)
	end

	pbWait(60)

	setMySwitch('A',true)

	if item != nil
		if item.is_a?(Array)
			pbMessage("It left behind some items!")
			item.each do |actualItem|
				pbReceiveItem(actualItem)
			end
		else
			if count == 1
				pbMessage("It left behind an item!")
				pbReceiveItem(item)
			elsif count > 1
				pbMessage("It left behind some items!")
				pbReceiveItem(item,count)
			end
		end
	end

	# If the map is playing the bad variant of the primal clay BGM
	# Forces it to move to the good variant
	primalClayBGMChange()
end

def defeatRegigigas
	$PokemonGlobal.respawnPoint = nil
	event = get_self
	difference = 255 - 180
	180.upto(255) do |i|
		event.opacity = i
		pbWait(1)
	end
end

def defeatMultipleBosses(item=nil,count=1,eventIDs=[])
	$PokemonGlobal.respawnPoint = nil

	events = eventIDs.map { |eventID| get_character(eventID)}
	255.downto(0) do |i|
		next if i % 3 != 0
		events.each do |event|
			event.opacity = i
		end
		pbWait(1)
	end

	eventIDs.each do |id|
		pbSetSelfSwitch(id,'A',true)
	end

	return if item == nil
	if count == 1
		pbMessage("They left behind an item!")
		pbReceiveItem(item)
	elsif count > 1
		pbMessage("They left behind some items!")
		pbReceiveItem(item,count)
	end

	# If the map is playing the bad variant of the primal clay BGM
	# Forces it to move to the good variant
	primalClayBGMChange()
end

def introduceAvatar(species,form=0)
	Pokemon.play_cry(species, form)
	$game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
	pbWait(2 * Graphics.frame_rate)
end

def introduceAvatarQuicker(species,form=0)
	$game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
	quickCry(species, form)
end

def quickCry(species, form = 0)
	Pokemon.play_cry(species, form)
	pbWait((0.5 * Graphics.frame_rate).ceil)
end

def avatarSpawnsIn(event_id)
	pbSEPlay("Avatar summoning")
	avatarEvent = get_event(event_id)
	for i in 20..180 do
		avatarEvent.opacity = i
		pbWait(1)
	end
end

def thunderClap
	pbSEPlay("Anim/PRSFX- Thunderbolt2")
	duration = (0.5 * Graphics.frame_rate).ceil
	$game_screen.start_flash(Color.new(255, 255, 255),duration)
end

def timeMagicDay
	return if PBDayNight.isDay?
	$game_screen.start_shake(4, 4, 999)
	pbWait(10)
	while !PBDayNight.isDay?
		UnrealTime.add_seconds(200)
		pbWait(1)
	end
	$game_screen.start_shake(2, 2, 10)
	pbWait(30)
end

def timeMagicNight
	return if PBDayNight.isNight?
	$game_screen.start_shake(4, 4, 999)
	pbWait(10)
	while !PBDayNight.isNight?
		UnrealTime.add_seconds(200)
		pbWait(1)
	end
	$game_screen.start_shake(2, 2, 10)
	pbWait(30)
end

def disableAutoWeather
	weather(:None,0,60)
	$game_switches[82] = true
end

def enableAutoWeather
	$game_switches[82] = false
	applyOutdoorEffects
end

def fadeInUniqueFog(fogName)
	disableAutoWeather

	$game_map.start_fog_opacity_change(0, 80)
	pbWait(80)

	applyFog(fogName)

	for i in 0..200 do
		$game_map.fog_opacity    = i
		pbWait(1)
	end

	pbWait(20)
end

def fadeOutUniqueFog
	$game_map.start_fog_opacity_change(0, 40)
	pbWait(40)

	enableAutoWeather
end