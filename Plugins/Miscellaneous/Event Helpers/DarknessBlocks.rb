def fadeOutDarknessBlock(event_id = -1)
    event_id = 0 if event_id < 0
    pbSEPlay('fake wall reveal')
    event = get_character(event_id)
	255.downto(0) do |i|
		next if i % 3 != 0
		event.opacity = i
		pbWait(1)
	end
    pbSetSelfSwitch(event.id,'A',true)
end

def fadeInDarknessBlock(event_id = -1)
    event_id = 0 if event_id < 0
    event = get_character(event_id)
	0.upto(255) do |i|
		next if i % 3 != 0
		event.opacity = i
		pbWait(1)
	end
    pbSetSelfSwitch(event.id,'A',false)
end