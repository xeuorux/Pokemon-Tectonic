AchievementHandlers.registerGlobalVariableAchievement(:DEFEAT_ALL_FORMER_CHAMPIONS, 38,
    proc { |achievementID, variableID, value|
        next value >= 7
    }
)

def checkVanyaDefeatNoGenderAchievement
    genderlessCount = 0
    $Trainer.party.each do |partyMember|
        genderlessCount += 1 if partyMember.gender == 2 # Genderless
    end
    return unless genderlessCount >= 6
    unlockAchievement(:DEFEAT_MASTER_VANYA_FULL_GENDERLESS_TEAM)
end