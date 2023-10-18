def earnedHatcherTrust?
    return true if trainedPseudoDragons?
    return true if gameWon? # Yezera defeated
    return false
end

def trainedPseudoDragons?
    %i[DRAGONITE SALAMENCE GARCHOMP HYDREIGON KOMMOO DRAGAPULT].each do |speciesID|
        next if $Trainer.owned?(speciesID)
        return false
    end
    return false unless $Trainer.owned?(:GOODRA) || $Trainer.owned?(:HGOODRA) # Either one
    return true
end
