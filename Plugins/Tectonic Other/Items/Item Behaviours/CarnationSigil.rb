ItemHandlers::UseFromBag.add(:CARNATIONSIGIL,proc { |item|
    next 0 unless canTeleport?(true)
    next pbMessage(_INTL("You feel yourself being pulled away.")) ? 2 : 0
})

ItemHandlers::ConfirmUseInField.add(:CARNATIONSIGIL,proc { |item|
  next false unless canTeleport?(true)
  next pbMessage(_INTL("You feel yourself being pulled away."))
})

ItemHandlers::UseInField.add(:CARNATIONSIGIL,proc { |item|
    commands = []
    commands.push(_INTL("The Tower"))
    commands.push(_INTL("The Stockpile"))
    commands.push(_INTL("Cancel"))
    choiceNumber = pbMessage(_INTL("Where would you like to go?"),commands,commands.length)
    case choiceNumber
    when 0
        transferPlayerToEvent(30,Down,186)
        next 1
    when 1
        transferPlayerToEvent(13,Down,126)
        next 1
    when 2
        next 0
    end
})