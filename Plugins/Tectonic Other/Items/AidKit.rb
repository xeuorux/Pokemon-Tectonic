AID_KIT_BASE_HEALING = 25
HEALING_UPGRADE_AMOUNT = 10

def initializeAidKit()
	$PokemonGlobal.teamHealerUpgrades 		= 0
	$PokemonGlobal.teamHealerMaxUses 		= 3
	$PokemonGlobal.teamHealerCurrentUses 	= 3
end

def refillAidKit(doubled = false)
	refillCharges = $PokemonGlobal.teamHealerMaxUses
	refillCharges *= 2 if doubled
	if $PokemonBag.pbHasItem?(:AIDKIT) && $PokemonGlobal.teamHealerCurrentUses < refillCharges
		$PokemonGlobal.teamHealerCurrentUses = refillCharges
		pbMessage(_INTL("Your Aid Kit was refreshed to #{$PokemonGlobal.teamHealerCurrentUses} charges."))
	end
end

def useAidKit()
	alreadyHealthy = true
	$Trainer.party.each do |p|
		next if p.egg?
		alreadyHealthy = false if p.hp < p.totalhp
		alreadyHealthy = false if p.status != :NONE
		p.moves.each do |move|
			alreadyHealthy = false if move.pp != move.total_pp
		end
	end
	if $PokemonGlobal.teamHealerCurrentUses <= 0
		pbMessage(_INTL("You are out of charges."))
		return 0
	elsif alreadyHealthy
		pbMessage(_INTL("Your entire team is already fully healed!"))
		return 0
	else
		$PokemonGlobal.teamHealerCurrentUses -= 1
		healAmount = AID_KIT_BASE_HEALING + HEALING_UPGRADE_AMOUNT * $PokemonGlobal.teamHealerUpgrades
		playerTribalBonus.updateTribeCount
		healAmount = (healAmount * 1.25).ceil if playerTribalBonus.hasTribeBonus?(:CARETAKER)
		pbMessage(_INTL("Healing your entire team by {1}.",healAmount))
		fullyHealed = true
		$Trainer.party.each do |p|
			next if p.egg?
			pbItemRestoreHP(p,healAmount)
			p.heal_status
			p.heal_PP
			fullyHealed = false if p.hp < p.totalhp
		end
		refreshFollow(false)
		pbMessage(_INTL("Your entire team is healthy!")) if fullyHealed
		return 1
	end
end

ItemHandlers::UseFromBag.add(:AIDKIT,proc { |item|
	next useAidKit()
})

ItemHandlers::ConfirmUseInField.add(:AIDKIT,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:AIDKIT,proc { |item|
	next useAidKit()
})

ItemHandlers::UseFromBag.add(:KITEXPANSION,proc { |item|
	if !$PokemonBag.pbHasItem?(:AIDKIT)
		pbMessage(_INTL("You don't have a Aid Kit to upgrade."))
		next 0
	end
	charges = $PokemonGlobal.teamHealerMaxUses
	pbMessage(_INTL("Your Aid Kit has been increased to #{charges+1} charges."))
	$PokemonGlobal.teamHealerMaxUses	 	+= 1
	$PokemonGlobal.teamHealerCurrentUses 	+= 1
	next 3
})

ItemHandlers::UseFromBag.add(:MEDICALUPGRADE,proc { |item|
	if !$PokemonBag.pbHasItem?(:AIDKIT)
		pbMessage(_INTL("You don't have a Aid Kit to upgrade."))
		next 0
	end
	charges = $PokemonGlobal.teamHealerMaxUses
	pbMessage(_INTL("Your Aid Kit now heals an additional #{HEALING_UPGRADE_AMOUNT} HP per charge."))
	$PokemonGlobal.teamHealerUpgrades	 	+= 1
	next 3
})

def getAidKitCharges()
	return $PokemonGlobal.teamHealerCurrentUses
end

def setAidKitCharges(num)
	$PokemonGlobal.teamHealerCurrentUses = num
end