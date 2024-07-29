GYM_LEVEL_CAPS = [
    15,
    20,
    25,
    30,
    40,
    45,
    55,
    60,
]

def checkGymAchievements(gymNumber)
    checkCursedGymPerfectAchievement(gymNumber)
    checkGymUnderLevelCapAchievement(gymNumber)
end

def checkCursedGymPerfectAchievement(gymNumber)
    return unless battlePerfected?
    return unless tarotAmuletActive?
    return unless getLevelCap <= GYM_LEVEL_CAPS[gymNumber-1]
    achievementID = ("PERFECT_CURSED_GYM_" + gymNumber.to_s).to_sym
    unlockAchievement(achievementID)
end

def checkGymUnderLevelCapAchievement(gymNumber)
    return unless getLevelCap < GYM_LEVEL_CAPS[gymNumber-1]
    unlockAchievement(:DEFEAT_GYM_BELOW_CAP)
end