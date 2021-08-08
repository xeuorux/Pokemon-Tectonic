def healPartyWithDelay()
	$Trainer.heal_party
	pbMEPlay('Pkmn healing')
	pbWait(68)
end

def earnBadge(badgeNum)
	badgeNames = [
		"Loyalty",
		"Perseverance",
		"Reverence",
		"Patience",
		"Solidarity",
		"Clarity",
		"Generosity",
		"Mercy"
	]
	name = badgeNames
	pbMessage(_INTL("\\me[Badge get]You've earned the {1} Badge.",name))
	$Trainer.badges[badgeNum-1]=true
	$game_switches[3+badgeNum]=true # "Defeated Gym X" switch
	pbWait(120)
	
	# Increase the level cap
	case badgeNum
	when 1
		pbSetLevelCap(20)
	when 2..4
		pbIncreaseLevelCap(5)
	when 5
		pbSetLevelCap(45)
	when 6,7
		pbIncreaseLevelCap(5)
	when 8
		pbSetLevelCap(70)
	else
		echo("Gym badge #{index} not yet defined!\n")
	end
end

def receivedGymRewardYet?(index)
	if $game_variables[78] == 0
		$game_variables[78] = [false] * 8
	end
	
	return $game_variables[78][index]
end

def receiveGymReward(index)
	case index
	when 0
		pbReceiveItem(:FULLRESTORE)
		pbReceiveItem(:MAXREPEL)
		pbReceiveItem(:ULTRABALL)
		pbReceiveItem(:MAXREVIVE)
	else
		echo("Gym item #{index} not yet defined!\n")
	end
	
	$game_variables[78][index] = true # Mark the item as having been received
end

def gymLeaderDialogueHash()
	return @leaderDialogueHash if @leaderDialogueHash
	@leaderDialogueHash = {
		0 => ["I’ll heal up your Pokémon, give your other rewards, and get out of your way.",
		"I’ll heal up your Pokémon and get out of your way."]
	}
	return @leaderDialogueHash
end

def healAndGiveRewardIfNotYetGiven(index)
	dialogue = gymLeaderDialogueHash[index]
	if receivedGymRewardYet?(index)
		pbMessage(dialogue[1])
		healPartyWithDelay()
	else
		pbMessage(dialogue[0])
		healPartyWithDelay()
		receiveGymReward(index)
	end
end

def perfectTrainer()
	$game_screen.start_tone_change(Tone.new(-255,-255,-255,0), 6 * Graphics.frame_rate / 20)
	pbWait(8)
	pbSetSelfSwitch(get_self.id,'D',true)
	setFollowerGone()
	$game_screen.start_tone_change(Tone.new(0,0,0,0), 6 * Graphics.frame_rate / 20)
	pbTrainerDropsItem()
end