def checkCursedCatacombsYezeraPerfectAchievement
    return unless battlePerfected?
    return unless tarotAmuletActive?
    unlockAchievement(:PERFECT_CURSED_CATACOMBS_YEZERA)
end

def checkCreditsAchievements
    unlockAchievement(:CREDITS_BELOW_10_HOURS) if getSaveDurationInHours < 10
    #unlockAchievement(:CREDITS_BELOW_5_HOURS) if getSaveDurationInHours < 5
end