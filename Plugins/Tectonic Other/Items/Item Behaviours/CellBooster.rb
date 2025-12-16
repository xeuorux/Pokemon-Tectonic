def useCellBooster
	$PokemonGlobal.cell_booster_inactive = !$PokemonGlobal.cell_booster_inactive
	duration = amuletMessageDuration / 2
	if $PokemonGlobal.cell_booster_inactive
		pbMessage(_INTL("\\db[Items/CELLBOOSTER_inactive]You disable the Cell Booster.\\wtnp[{1}]",duration))
	else
		pbMessage(_INTL("\\db[Items/CELLBOOSTER]You enable the Cell Booster.\\wtnp[{1}]",duration))
	end
	return true
end

ItemHandlers::UseFromBag.add(:CELLBOOSTER,proc { |item|
	useCellBooster
	next 1
})

ItemHandlers::ConfirmUseInField.add(:CELLBOOSTER,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:CELLBOOSTER,proc { |item|
	next useCellBooster
})

def cellBoosterActive?
    return $PokemonBag && pbHasItem?(:CELLBOOSTER) && !cellBoosterInactive?
end

def cellBoosterInactive?
	return $PokemonGlobal.cell_booster_inactive || false
end