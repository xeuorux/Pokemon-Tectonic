ItemHandlers::ConfirmUseInField.add(:BOXLINK,proc { |item|
    next teamEditingAllowed?
  })

ItemHandlers::UseInField.add(:BOXLINK,proc { |item|
    estateDisablementBefore = getGlobalSwitch(ESTATE_DISABLED_SWITCH)
    setGlobalSwitch(ESTATE_DISABLED_SWITCH,true)
    pbPokeCenterPC
    setGlobalSwitch(ESTATE_DISABLED_SWITCH,estateDisablementBefore)
    next 1
})