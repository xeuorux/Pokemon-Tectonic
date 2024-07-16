def isAchievementUnlocked?(achievementID)
    return false # TODO
end

def unlockAchievement(achievementID)
    showAchievement(achievementID)
    # TODO
end

def showAchievement(achievementID)
    name = achievementID.to_s
    name.gsub!(":","")
    name.gsub!("_"," ")
    name.gsub(/\w+/) do |word|
        word.capitalize
    end
	label = _INTL("Achievement Unlocked:\r\n{1}",name)
	$scene.spriteset.addUserSprite(LocationWindow.new(label,Graphics.frame_rate * 4))
end