def happinessCheckerCorviknight
    showExclamation
    pbWait(60)
    showQuestion
    pbWait(60)

    pbMessage(_INTL("The Corviknight stares at you intently."))

    count = getMaxHappinessCount

    count.times do |i|
        showLove
        pbWait(40)
    end

    if count == 6
        pbWait(40)
        showExclamation
        pbWait(40)
        return true
    else
        pbWait(20)
        showSad
        pbWait(40)
        return false
    end
end

def getMaxHappinessCount
    count = 0
    $Trainer.pokemon_party.each do |partyMember|
        next unless partyMember.happiness = MAX_HAPPINESS
        count += 1
    end
    return count
end