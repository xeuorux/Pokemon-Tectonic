EXP_PER_EXTRA_SMALL = 250

class PokemonGlobalMetadata
	attr_accessor :expJARUpgraded
end

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
	$PokemonGlobal.expJARUpgraded = false if $PokemonGlobal.expJARUpgraded.nil?
	candyTotal = 0
	pbMessage(_INTL("You have {1} EXP stored in the EXP-EZ Dispenser.",$PokemonGlobal.expJAR))

	xsCandyTotal = 0
	sCandyTotal = 0
	mCandyTotal = 0
	lCandyTotal = 0

	# Calculate how many of each candy size could be given
	if !$PokemonGlobal.expJARUpgraded
		xsCandyTotal = $PokemonGlobal.expJAR / EXP_PER_EXTRA_SMALL
		sCandyTotal = xsCandyTotal / 4
		xsCandyTotal = xsCandyTotal % 4
	else
		sCandyTotal = $PokemonGlobal.expJAR / (EXP_PER_EXTRA_SMALL * 4)
	end
	mCandyTotal = sCandyTotal / 4
	sCandyTotal = sCandyTotal % 4
	if $PokemonGlobal.expJARUpgraded
		lCandyTotal = mCandyTotal / 4
		mCandyTotal = mCandyTotal % 4
	end

	# Prompt the player to make the candies
	if sCandyTotal > 0 || xsCandyTotal > 0 || mCandyTotal > 0 || lCandyTotal > 0
		if !$PokemonGlobal.expJARUpgraded
			if pbConfirmMessage(_INTL("You can make {1} Medium, {2} Small and {3} Extra-Small candies. Would you like to?", mCandyTotal, sCandyTotal, xsCandyTotal))
				pbReceiveItem(:EXPCANDYM,mCandyTotal) if mCandyTotal > 0
				pbReceiveItem(:EXPCANDYS,sCandyTotal) if sCandyTotal > 0
				pbReceiveItem(:EXPCANDYXS,xsCandyTotal) if xsCandyTotal > 0
				$PokemonGlobal.expJAR = $PokemonGlobal.expJAR % EXP_PER_EXTRA_SMALL
			end
		else
			if pbConfirmMessage(_INTL("You can make {1} Large, {2} Medium and {3} Small candies. Would you like to?", lCandyTotal, mCandyTotal, sCandyTotal))
				pbReceiveItem(:EXPCANDYL,lCandyTotal) if lCandyTotal > 0
				pbReceiveItem(:EXPCANDYM,mCandyTotal) if mCandyTotal > 0
				pbReceiveItem(:EXPCANDYS,sCandyTotal) if sCandyTotal > 0
				$PokemonGlobal.expJAR = $PokemonGlobal.expJAR % (EXP_PER_EXTRA_SMALL * 4)
			end
		end
	else
		pbMessage(_INTL("That's not enough to make any candies."))
		return 0
	end
	return 1
end
