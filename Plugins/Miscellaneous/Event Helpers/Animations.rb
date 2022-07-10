def showQuestion(eventID = 0)
	showAnimation(4,eventID)
end

def showExclamation(eventID = 0)
	showAnimation(3,eventID)
end

def showHappy(eventID = 0)
	showAnimation(FollowerSettings::Emo_Happy,eventID)
end

def showNormal(eventID = 0)
	showAnimation(FollowerSettings::Emo_Normal,eventID)
end

def showHate(eventID = 0)
	showAnimation(FollowerSettings::Emo_Hate,eventID)
end

def showPoison(eventID = 0)
	showAnimation(FollowerSettings::Emo_Poison,eventID)
end

def showSing(eventID = 0)
	showAnimation(FollowerSettings::Emo_Sing,eventID)
end

def showLove(eventID = 0)
	showAnimation(FollowerSettings::Emo_Love,eventID)
end

def showPokeballEnter(eventID = 0)
	showAnimation(FollowerSettings::Animation_Come_In,eventID)
end

def showPokeballExit(eventID = 0, animationID)
	showAnimation(FollowerSettings::Animation_Come_Out,eventID)
end

def showAnimation(animationID, eventId = 0)
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