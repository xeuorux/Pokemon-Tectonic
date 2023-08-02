def useTarotAmulet()
	$PokemonGlobal.tarot_amulet_active = !$PokemonGlobal.tarot_amulet_active
	if $PokemonGlobal.tarot_amulet_active
		pbMessage(_INTL("You turn the Tarot Amulet to its front face. It is now active."))
	else
		pbMessage(_INTL("You turn the Tarot Amulet to its back face. It is now disabled."))
	end
	return true
end

ItemHandlers::UseFromBag.add(:TAROTAMULET,proc { |item|
	useTarotAmulet()
	next 1
})

ItemHandlers::ConfirmUseInField.add(:TAROTAMULET,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:TAROTAMULET,proc { |item|
	next useTarotAmulet()
})