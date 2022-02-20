def showQuestion(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(4,event.x,event.y)
end

def showExclamation(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(3,event.x,event.y)
end

def showHappy(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,event.x,event.y)
end

def showNormal(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,event.x,event.y)
end

def showHate(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,event.x,event.y)
end

def showPoison(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Poison,event.x,event.y)
end

def showSing(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Sing,event.x,event.y)
end

def showLove(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Love,event.x,event.y)
end

def showPokeballEnter(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_In,event.x,event.y)
end

def showPokeballExit(event = 0)
	event = get_character(event) if event.is_a?(Integer)
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_Out,event.x,event.y)
end

def showBallReturn(x,y)
	$scene.spriteset.addUserAnimation(30,x,y)
end