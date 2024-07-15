def useTarotAmulet()
	$PokemonGlobal.tarot_amulet_active = !$PokemonGlobal.tarot_amulet_active
    followerEventGraphicSwap(true)
	if $PokemonGlobal.tarot_amulet_active
		pbMessage(_INTL("\\db[Items/TAROTAMULET_active]You turn the Tarot Amulet to its front face. It is now active.\\wtnp[60]"))
	else
		pbMessage(_INTL("\\db[Items/TAROTAMULET]You turn the Tarot Amulet to its back face. It is now disabled.\\wtnp[60]"))
	end
	return true
end

ItemHandlers::UseFromBag.add(:TAROTAMULET,proc { |item|
	useTarotAmulet
	next 1
})

ItemHandlers::ConfirmUseInField.add(:TAROTAMULET,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:TAROTAMULET,proc { |item|
	next useTarotAmulet
})

def tarotAmuletActive?
	return $PokemonGlobal.tarot_amulet_active || false
end