ItemHandlers::UseFromBag.add(:SMARTPHONE,proc { |item|
	choice = pbMessage(_INTL("Open which app?"), [_INTL("Camera"), _INTL("VS Recorder"),], -1)
	next 2 if choice == 0
	choice = pbMessage(_INTL("What do you do?"), [_INTL("Watch battle"), _INTL("Save last battle"), _INTL("Rename battle"), _INTL("Delete battle")], -1)
	case choice
	when 0
		echoln("REPLAYING LAST BATTLE...")
		playRecordedBattle("LastBattle")
		next 0
	else
		next 0
	end
})

ItemHandlers::ConfirmUseInField.add(:SMARTPHONE,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:SMARTPHONE,proc { |item|
	next takeSelfie
})