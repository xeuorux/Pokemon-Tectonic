ItemHandlers::ConfirmUseInField.add(:BOXLINK,proc { |item|
    next teamEditingAllowed?
  })

ItemHandlers::UseInField.add(:BOXLINK,proc { |item|
    $game_switches[ESTATE_DISABLED_SWITCH] = true
    pbPokeCenterPC
    $game_switches[ESTATE_DISABLED_SWITCH] = false
    next 1
})