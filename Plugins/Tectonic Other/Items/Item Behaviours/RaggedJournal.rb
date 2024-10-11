def raggedJournalLoot(pageNumber)
    unlockRaggedJournalPage(pageNumber)
    setMySwitch('A')
end

# Gives the player the item if they don't yet have it
def unlockRaggedJournalPage(pageNumber)
    unless pbHasItem?(:RAGGEDJOURNAL)
        pbReceiveItem(:RAGGEDJOURNAL)
        pbMessage(_INTL("Looking inside the journal, you see that the only page that hasn't fallen out is page {1}.",pageNumber+1))
        $PokemonGlobal.ragged_journal_pages_collected = []
    else
        pbMessage(_INTL("\\i[RAGGEDJOURNAL]You've found page {1} of the {2}!",pageNumber+1,getItemName(:RAGGEDJOURNAL)))
        pbMessage(_INTL("You slot the page into its proper place in the journal."))
    end

    $PokemonGlobal.ragged_journal_pages_collected[pageNumber] = true
    
    if pbConfirmMessage(_INTL("Read it now?"))
        readRaggedJournalPage(pageNumber)
    end
end

def readRaggedJournalPage(pageNumber)
    pageTitle = _INTL("Page {1}",pageNumber+1)
    text, date = getRaggedJournalPageTextAndDate(pageNumber)

    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999

    background = ColoredPlane.new(Color.new(20,12,8),viewport)
    # bitmapName = pbResolveBitmap("Graphics/Pictures/helpadventurebg")
    # background.setBitmap(bitmapName)
    pageNumberWindow = Window_UnformattedTextPokemon.newWithSize(pageTitle,
      0, 0, 150, 64, viewport)
    dateWindow = Window_UnformattedTextPokemon.newWithSize(date,
      Graphics.width - 150, 0, 150, 64, viewport)
    textWindow = Window_AdvancedTextPokemon.newWithSize(text,
      0, 64, Graphics.width, Graphics.height-64, viewport)

    loop do
        Graphics.update
        Input.update
        pageNumberWindow.update
        textWindow.update
        dateWindow.update
        if Input.trigger?(Input::BACK)
            break
        end
    end
    pageNumberWindow.dispose
    textWindow.dispose
    dateWindow.dispose
    background.dispose
end

def getRaggedJournalPageTextAndDate(pageNumber)
    text = ""
    case pageNumber
    when 0
        text += _INTL("Ah, to be on solid ground again. Away from Galar's suffocating industrial sprawl. Stable. Connected. Tranquil. No cold steel shifting and rocking beneath my feet. No stench of smoke and oil to burn my lungs.\n")
        text += _INTL("Just me, my companion, and Makya.\n")
        date = _INTL("May 22nd")
    when 1
        text += _INTL("I wonder if it's just me. So sentimental and wistful over little things I thought I knew. Is nostalgia tainting my perceptions? Or is the world truly as broken as it looks?\n")
        text += _INTL("My new friend makes me expect the latter. A sad story. But... inspiring nonetheless. Maybe I'll meet them again someday.\n")
        date = _INTL("May 26th")
    when 2
        text = _INTL("Life. Not just Life as life – Life as creation. Life as energy. Life as imagination, and falsehood, and memory, and motion. Over six days in Makya, this is the one place that seems to be governed by Life... and not its negation.\n")
        text += _INTL("The world is dead. And Makya stands as little more than a polished mirror. What a shame.\n")
        date = _INTL("May 29th")
    when 3
        text = _INTL("I left last night when the earth began to rumble. I only returned for my companion, despite my... reservations.\n")
        text += _INTL("A great pit separates me from yesterday's memories. A dozen blackened eyes study my every step.\n")
        text += _INTL("What's done is done.\n")
        date = _INTL("June 4th")
    when 4
        text = _INTL("At every turn, a set of eyes. On every perch, a silver scout. But... surely they cannot see everywhere? My friend at the Monument seemed to imply as much.\n")
        text += _INTL("But with every step I take, I find a new reason to check over my shoulder. Whether it's guilt or fear that guides me to that great tower... well. I'd rather not dwell on that yet.\n")
        date = _INTL("June 6th")
    when 5
        text = _INTL("This was a mistake. This was <i>all</i> a mistake...\n")
        text += _INTL("A set of silver eyes rests atop Carnation Tower today. I couldn't shake the feeling that it expected me... He must know I stole His reign. Nothing makes sense if He doesn't.\n")
        text += _INTL("To anyone reading this, I urge you: Speak to my friend at the Monument. As long as He stands without rule, we can act without fear.\n")
        date = _INTL("June 11th")
    when 6
        text = _INTL("I can't afford to speak.\n")
        text += _INTL("I can't afford to trust.\n")
        text += _INTL("I can barely afford to write this.\n")
        text += _INTL("A woman with hollow eyes and an uncanny smile approached me today. She asked about my history. She asked about Makya. She asked... about Him.\n")
        text += _INTL("Tomorrow. All of this ends tomorrow morning.\n")
        date = _INTL("June 13th")
    when 7
        text = _INTL("This can't be a coincidence.\n")
        text += _INTL("My best hope of escaping His grasp... but I can tell we're not moving anymore.\n")
        text += _INTL("Nobody seems to believe me. We can't even see the waves! And I've heard four hooves circling my bed for hours...\n")
        text += _INTL("He won.\n")
        date = _INTL("June 15th")
    end

    text += _INTL("  —Oriel")

    return text,date
end

def openRaggedJournal
    lastChoice = 0
    while true
        choices = []
        valuesInOrder = []
        $PokemonGlobal.ragged_journal_pages_collected.each_with_index do |pageValue, index|
            next unless pageValue
            choices.push(_INTL("Page {1}",index+1))
            valuesInOrder.push(index)
        end
        choices.push(_INTL("Cancel"))
        indexChosen = pbMessage(_INTL("Which page would you like to read?"),choices,choices.length,nil,lastChoice)
        break if indexChosen == choices.length - 1
        readRaggedJournalPage(valuesInOrder[indexChosen])
        lastChoice = indexChosen
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