CALYREX_QUEST_GLOBAL_VAR = 42

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

def checkForCalyrexQuestFinale
    return unless $Trainer.owned?(:SPECTRIER)
    return unless $Trainer.owned?(:GLASTRIER)
    return unless pbHasItem?(:REINSOFUNITY)
    incrementGlobalVar(CALYREX_QUEST_GLOBAL_VAR)
end

def calyrexLegendFight
    level = [70,getLevelCap].min
    result = pbWildBattleCore(:CALYREX, level)
    if result == 4 # Caught
        get_self.opacity = 0
        setSpeaker(CALYREX)
        pbMessage(_INTL("<i>What!!?</i>"))
        pbMessage(_INTL("<i>How... how could you?</i>"))
        pbMessage(_INTL("<i>Insolent fool! Treasonous wretch!!!  Usurping the King of All in your desperate attemp–</i>"))
        pbWait(20)
        removeSpeaker
        pbMessage(_INTL("Calyrex's protests fade away, leaving an echoing silence in its absence."))
        return true
    elsif result == 1
        setSpeaker(CALYREX)
        pbMessage(_INTL("<i>Drink the regal blood if you must.</i>"))
        pbMessage(_INTL("<i>Indulge in your <b>traitorous nature</b> if you insist.</i>"))
        pbMessage(_INTL("<i>Repulsive flea...</i>"))
        pbMessage(_INTL("<i><b>I will swat you from the sky.</b></i>"))
        return false
    end
end