def raggedJournalLoot(pageNumber)
    unlockRaggedJournalPage(pageNumber)
    setMySwitch('A')
end

# Gives the player the item if they don't yet have it
def unlockRaggedJournalPage(pageNumber)
    unless pbHasItem?(:RAGGEDJOURNAL)
        pbReceiveItem(:RAGGEDJOURNAL)
        pbMessage(_INTL("Looking inside the journal, you see that the only page that hasn't fallen out is page {1}.",pageNumber))
        $PokemonGlobal.ragged_journal_pages_collected = []
    else
        pbMessage(_INTL("\\i[RAGGEDJOURNAL]You've found page {1} of the {2}!",pageNumber,getItemName(:RAGGEDJOURNAL)))
        pbMessage(_INTL("You slot the page into its proper place in the journal."))
    end

    $PokemonGlobal.ragged_journal_pages_collected[pageNumber] = true
    
    if pbConfirmMessage(_INTL("Read it now?"))
        readRaggedJournalPage(pageNumber)
    end
end

def readRaggedJournalPage(pageNumber)
    case pageNumber
    when 1
        pbMessage(_INTL("TO DO 1"))
    when 2
        pbMessage(_INTL("TO DO 2"))
    when 3
        pbMessage(_INTL("TO DO 3"))
    when 4
        pbMessage(_INTL("TO DO 4"))
    when 5
        pbMessage(_INTL("TO DO 5"))
    when 6
        pbMessage(_INTL("TO DO 6"))
    when 7
        pbMessage(_INTL("TO DO 7"))
    when 8
        pbMessage(_INTL("TO DO 8"))
    end
end

def openRaggedJournal
    choices = []
    $PokemonGlobal.ragged_journal_pages_collected.each_with_index do |pageValue, index|
        next unless pageValue
        choices.push(_INTL("Page {1}",index))
    end
    choices.push(_INTL("Cancel"))
    pageChosen = pbMessage(_INTL("Which page would you like to read?"),choices,choices.length)
    unless pageChosen == choices.length - 1
        readRaggedJournalPage(pageChosen + 1)
    end
    return 1
end

ItemHandlers::UseFromBag.add(:RAGGEDJOURNAL,proc { |item|
	next openRaggedJournal
})

ItemHandlers::ConfirmUseInField.add(:RAGGEDJOURNAL,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:RAGGEDJOURNAL,proc { |item|
	next openRaggedJournal
})