def showQuestion(eventID = 0)
	showAnimtion(4,eventID)
end

def showExclamation(eventID = 0)
	showAnimtion(3,eventID)
end

def showHappy(eventID = 0)
	showAnimtion(FollowerSettings::Emo_Happy,eventID)
end

def showNormal(eventID = 0)
	showAnimtion(FollowerSettings::Emo_Normal,eventID)
end

def showHate(eventID = 0)
	showAnimtion(FollowerSettings::Emo_Hate,eventID)
end

def showPoison(eventID = 0)
	showAnimtion(FollowerSettings::Emo_Poison,eventID)
end

def showSing(eventID = 0)
	showAnimtion(FollowerSettings::Emo_Sing,eventID)
end

def showLove(eventID = 0)
	showAnimtion(FollowerSettings::Emo_Love,eventID)
end

def showPokeballEnter(eventID = 0)
	showAnimtion(FollowerSettings::Animation_Come_In,eventID)
end

def showPokeballExit(eventID = 0, animationID)
	showAnimtion(FollowerSettings::Animation_Come_Out,eventID)
end

def showAnimtion(animationID, eventId = 0)
	event = nil
	if pbMapInterpreterRunning?
		event = get_character(eventId)
	else
		event = self
	end
	if event.nil?
		pbMessage("Could not find event to show emote for.") if $DEBUG
		return
	end
	$scene.spriteset.addUserAnimation(animationID,event.x,event.y)
end

def showBallReturn(x,y)
	$scene.spriteset.addUserAnimation(30,x,y)
end