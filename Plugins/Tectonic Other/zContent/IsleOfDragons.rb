
def trainedPseudoDragons?
    %i[DRAGONITE SALAMENCE GARCHOMP HYDREIGON GOODRA KOMMOO DRAGAPULT].each do |speciesID|
        next if $Trainer.owned?(speciesID)
        return false
    end
    return true
end