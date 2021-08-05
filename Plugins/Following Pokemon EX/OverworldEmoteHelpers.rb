def showQuestion(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(4,event.x,event.y)
end

def showExclamation(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(3,event.x,event.y)
end

def showHappy(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,event.x,event.y)
end

def showNormal(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,event.x,event.y)
end

def showHate(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,event.x,event.y)
end

def showPoison(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Poison,event.x,event.y)
end

def showSing(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Sing,event.x,event.y)
end

def showLove(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Emo_Sing,event.x,event.y)
end

def showPokeballEnter(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_In,event.x,event.y)
end

def showPokeballExit(event)
	event = get_character(event) if !event.is_a?(Game_Character)
	$scene.spriteset.addUserAnimation(FollowerSettings::Animation_Come_Out,event.x,event.y)
end