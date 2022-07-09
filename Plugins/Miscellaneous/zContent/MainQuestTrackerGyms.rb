# Set the proper main quest stage when you earn a new badge
Events.onBadgeEarned += proc { |_sender,_e|
    badgeEarned = _e[0]
    totalBadges = _e[1]
    badgeArray  = _e[2]
    case badgeEarned+1
    when 0
        setMQStage(:MEET_TAMARIND_AT_DOCKS)
    when 1..7
        setStageEarliestIncompleteGym(badgeArray)
    end
}

def setStageEarliestIncompleteGym(badgeArray)
    if !badgeArray[1]
        setMQStage(:FIND_SECOND_GYM)
    elsif !badgeArray[2]
        setMQStage(:FIND_THIRD_GYM)
    elsif !badgeArray[3]
        setMQStage(:FIND_FOURTH_GYM)
    elsif !badgeArray[4]
        setMQStage(:FIND_FIFTH_GYM)
    elsif !badgeArray[5]
        setMQStage(:FIND_SIXTH_GYM)
    elsif !badgeArray[6]
        setMQStage(:FIND_SEVENTH_GYM)
    elsif !badgeArray[7]
        setMQStage(:FIND_EIGHTH_GYM)
    else
        setMQStage(:FIND_CHAMPIONSHIP)
    end
end

# To be called whenever the player enters a gym
# To progress the gym-related stage if relevant
def progressStageForGym()
    case getMQStage()
    when :FIND_SECOND_GYM
        setMQStage(:DEFEAT_SECOND_GYM)
    when :FIND_THIRD_GYM,:RETURN_HELENAS_PACKAGE
        setMQStage(:DEFEAT_THIRD_GYM)
    when :FIND_FOURTH_GYM,:FIND_RAFAEL
        setMQStage(:DEFEAT_FOURTH_GYM)
    when :FIND_FIFTH_GYM
        setMQStage(:DEFEAT_FIFTH_GYM)
    when :FIND_SIXTH_GYM
        setMQStage(:DEFEAT_SIXTH_GYM)
    when :FIND_SEVENTH_GYM
        setMQStage(:DEFEAT_SEVENTH_GYM)
    when :FIND_EIGHTH_GYM
        setMQStage(:DEFEAT_EIGHTH_GYM)
    when :FIND_CHAMPIONSHIP
        setMQStage(:WIN_CHAMPIONSHIP)
    end
end