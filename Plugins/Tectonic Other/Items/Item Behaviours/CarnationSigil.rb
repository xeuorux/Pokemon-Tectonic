ItemHandlers::UseFromBag.add(:CARNATIONSIGIL,proc { |item|
    next 0 unless canTeleport?(true)
    next pbConfirmMessageSerious(_INTL("You feel yourself pulled away. Allow yourself to be transported?")) ? 2 : 0
})

ItemHandlers::ConfirmUseInField.add(:CARNATIONSIGIL,proc { |item|
  next false unless canTeleport?(true)
  next pbConfirmMessageSerious(_INTL("You feel yourself pulled away. Allow yourself to be transported?"))
})

ItemHandlers::UseInField.add(:CARNATIONSIGIL,proc { |item|
  transferPlayerToEvent(30,Down,186) # An event placed on top of the carnation tower in frostflow farms
  next 1
})