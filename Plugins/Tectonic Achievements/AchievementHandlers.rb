module AchievementHandlers
    def self.registerGlobalSwitchAchievement(achievementID, switchID, handler)
        return if isAchievementUnlocked?(achievementID)
        GlobalStateHandlers::GlobalSwitchChanged.add(switchID,
            proc { |switchID, value|
                next if isAchievementUnlocked?(achievementID)
                next unless handler.call(achievementID, switchID, value)
                unlockAchievement(achievementID)
            }
        )
    end

    def self.registerGlobalVariableAchievement(achievementID, variableID, handler)
        return if isAchievementUnlocked?(achievementID)
        GlobalStateHandlers::GlobalVariableChanged.add(variableID,
            proc { |variableID, value|
                next if isAchievementUnlocked?(achievementID)
                next unless handler.call(achievementID, variableID, value)
                unlockAchievement(achievementID)
            }
        )
    end
end