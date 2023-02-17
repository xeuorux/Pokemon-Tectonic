def fadeOutDarknessBlock(event_id = -1, play_sound = true)
    event_id = 0 if event_id < 0
    pbSEPlay('fake wall reveal', 150, 100) if play_sound
    event = get_character(event_id)
	255.downto(0) do |i|
		next if i % 5 != 0
		event.opacity = i
		pbWait(1)
	end
    pbSetSelfSwitch(event.id,'A',true)
end

def fadeInDarknessBlock(event_id = -1, play_sound = true)
    event_id = 0 if event_id < 0
    event = get_character(event_id)
	0.upto(255) do |i|
		next if i % 5 != 0
		event.opacity = i
		pbWait(1)
	end
    pbSetSelfSwitch(event.id,'A',false)
end