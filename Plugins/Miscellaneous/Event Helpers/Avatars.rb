def defeatBoss(item=nil,count=1)
	pbMessage("The avatar staggers, then drifts away into nothingness.")
	blackFadeOutIn {
		setMySwitch('A',true)
	}
	return if item == nil
	if count == 1
		pbMessage("It left behind an item!")
		pbReceiveItem(item)
	elsif count > 1
		pbMessage("It left behind some items!")
		pbReceiveItem(item,count)
	end
end

def introduceAvatar(species,form=0)
	Pokemon.play_cry(species, form)
	$game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
	pbWait(2 * Graphics.frame_rate)
end

def introduceAvatarQuicker(species,form=0)
	Pokemon.play_cry(species, form)
	$game_screen.start_shake(5, 5, 2 * Graphics.frame_rate)
	pbWait((0.5 * Graphics.frame_rate).ceil)
end