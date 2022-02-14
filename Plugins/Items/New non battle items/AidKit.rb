AID_KIT_BASE_HEALING = 25
HEALING_UPGRADE_AMOUNT = 10

def initializeAidKit()
	$PokemonGlobal.teamHealerUpgrades 		= 0
	$PokemonGlobal.teamHealerMaxUses 		= 3
	$PokemonGlobal.teamHealerCurrentUses 	= 3
end

def refillAidKit()
	if $PokemonBag.pbHasItem?(:AIDKIT)
		$PokemonGlobal.teamHealerCurrentUses = $PokemonGlobal.teamHealerMaxUses
		pbMessage(_INTL("Your Aid Kit was refreshed to #{$PokemonGlobal.teamHealerCurrentUses} charges."))
	end
end

def useAidKit()
	if $PokemonGlobal.teamHealerCurrentUses > 0
		$PokemonGlobal.teamHealerCurrentUses -= 1
		echoln("Aid kit info: #{AID_KIT_BASE_HEALING},#{HEALING_UPGRADE_AMOUNT},#{$PokemonGlobal.teamHealerUpgrades}")
		healAmount = AID_KIT_BASE_HEALING + HEALING_UPGRADE_AMOUNT * $PokemonGlobal.teamHealerUpgrades
		pbMessage(_INTL("Healing your entire team by {1}.",healAmount))
		charges = $PokemonGlobal.teamHealerCurrentUses
		pbMessage(_INTL("You have {1} #{charges == 1 ? "charge" : "charges"} left.", charges))
		$Trainer.party.each do |p|
			next if p.egg?
			pbItemRestoreHP(p,healAmount)
			p.heal_status
			p.heal_PP
		end
		return 1
	else
		pbMessage(_INTL("You are out of charges."))
		return 0
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