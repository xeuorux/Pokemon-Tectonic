class Game_Event < Game_Character
	attr_accessor :opacity
end

def defeatBoss(item=nil,count=1,opacityStart=180,opacityTarget=0)
	$PokemonGlobal.respawnPoint = nil

	event = get_self

	opacityStart.downto(opacityTarget) do |i|
		next if i % 2 != 0
		event.opacity = i
		pbWait(1)
	end

	setMySwitch('A',true)

	if item != nil
		if count == 1
			pbMessage("It left behind an item!")
			pbReceiveItem(item)
		elsif count > 1
			pbMessage("It left behind some items!")
			pbReceiveItem(item,count)
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