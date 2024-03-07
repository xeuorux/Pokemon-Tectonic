def tapuLogBook
    pbMessage(_INTL("A tattered notebook sits on the table."))
    pbMessage(_INTL("It's titled \"Tapu Log Book.\""))
    sectionChoices = []
    sectionChoices.push(_INTL("Notes: Cruel Cocoon"))
    sectionChoices.push(_INTL("Notes: Turbulent Sky"))
    sectionChoices.push(_INTL("Notes: Primal Forest"))
    sectionChoices.push(_INTL("Notes: Misdirecting Fog"))
    sectionChoices.push(_INTL("Stop Reading"))
    loop do
        sectionChoice = pbMessage(_INTL("Which section would you like to read?"),sectionChoices,sectionChoices.length)
        case sectionChoice
        when 0
            pbMessage(_INTL("Tapu Lele's ability \"Flutter Totem\" creates a \"Cruel Cocoon\" upon entry that only affects its side and lasts for 6 turns."))
            pbMessage(_INTL("At the end of each turn, it heals Pokemon on its side by 1/8th of their max HP."))
            pbMessage(_INTL("However, they also lose 1 PP from each of their moves. Cruel indeed."))
        when 1
            pbMessage(_INTL("Tapu Koko's ability \"Storm Totem\" creates a \"Turbulent Sky\" upon entry that only affects its side and lasts for 6 turns."))
            pbMessage(_INTL("Pokemon on its side get a 30% move damage boost, but they are prevented from using moves that are the same type as the move they most recently used."))
            pbMessage(_INTL("Or, to state it another way, they can't use the same move type twice in a row."))
        when 2
            pbMessage(_INTL("Tapu Bulu's ability \"Wild Totem\" creates a \"Primal Forest\" upon entry that only affects its side and lasts for 6 turns."))
            pbMessage(_INTL("Whenever a Pokemon on its side is hit by an offensive attack, it becomes enraged."))
            pbMessage(_INTL("Thereby, its defense stats are both lowered by 1 step and its attack stats are both raised by 1 step."))
        when 3
            pbMessage(_INTL("Tapu Fini's ability \"Fog Totem\" creates a \"Misdirecting Fog\" upon entry that only affects its side and lasts for 6 turns."))
            pbMessage(_INTL("Whenever a foe finishes attacking a Pokemon on its side, the attacker is forced to switch out of battle."))
            pbMessage(_INTL("Unlike moves such as Roar or Whirlwind, however, the trainer has enough time to select the replacement themselves."))
        else
            pbMessage(_INTL("You put down the book."))
            break
        end
    end
end