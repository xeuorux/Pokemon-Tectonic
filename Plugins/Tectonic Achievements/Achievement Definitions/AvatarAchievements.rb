def checkForChamberAvatarsAchievement
    clearedAll = true
    for chamberClearSwitchID in 126..133
        next if getGlobalSwitch(chamberClearSwitchID)
        clearedAll = false
        break
    end
    return unless clearedAll
    unlockAchievement(:DEFEAT_ALL_CHAMBER_AVATARS)
end

GlobalStateHandlers::GlobalSwitchChanged.add(126,
    proc { |switchID, value|
        next if isAchievementUnlocked?(:DEFEAT_ALL_CHAMBER_AVATARS)
        checkForChamberAvatarsAchievement
    }
)

GlobalStateHandlers::GlobalSwitchChanged.copy(126,127,128,129,130,131,132,133)