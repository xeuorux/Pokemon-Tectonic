ItemHandlers::UseFromBag.add(:EXPEZDISPENSER,proc { |item|
	next useEXPEZ
})


ItemHandlers::ConfirmUseInField.add(:EXPEZDISPENSER,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:EXPEZDISPENSER,proc { |item|
	next useEXPEZ
})

def useEXPEZ()
	$PokemonGlobal.expJAR = 0 if $PokemonGlobal.expJAR.nil?
	candyTotal = 0
	pbMessage(_INTL("You have {1} EXP stored in the EXP-EZ Dispenser.",$PokemonGlobal.expJAR))
	xsCandyTotal = $PokemonGlobal.expJAR / 350
	sCandyTotal = xsCandyTotal / 4
	xsCandyTotal = xsCandyTotal % 4
	mCandyTotal = sCandyTotal / 4
	sCandyTotal = sCandyTotal % 4
	if sCandyTotal > 0 || xsCandyTotal > 0 || mCandyTotal > 0
		if pbConfirmMessage(_INTL("You can make {1} Medium, {2} Small and {3} Extra-Small candies. Would you like to?", mCandyTotal, sCandyTotal, xsCandyTotal))
			pbReceiveItem(:EXPCANDYM,mCandyTotal) if mCandyTotal > 0
			pbReceiveItem(:EXPCANDYS,sCandyTotal) if sCandyTotal > 0
			pbReceiveItem(:EXPCANDYXS,xsCandyTotal) if xsCandyTotal > 0
			$PokemonGlobal.expJAR = $PokemonGlobal.expJAR % 350
		end
	else
		pbMessage(_INTL("That's not enough to make any candies."))
		return 0
	end
	return 1
end
