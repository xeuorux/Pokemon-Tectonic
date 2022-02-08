BattleHandlers::ItemOnStatLoss.add(:EJECTPACK,
  proc { |item,battler,user,move,switched,battle|
    next if battle.pbAllFainted?(battler.idxOpposingSide)
    next if !battle.pbCanChooseNonActive?(battler.index)
	next if move.function=="0EE" # U-Turn, Volt-Switch, Flip Turn
	next if move.function=="151" # Parting Shot
    battle.pbCommonAnimation("UseItem",battler)
    battle.pbDisplay(_INTL("{1} is switched out with the {2}!",battler.pbThis,battler.itemName))
    battler.pbConsumeItem(true,false)
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next if newPkmn<0
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    switched.push(battler.index)
  }
)

#######################
# ABRAPORTER
#######################
ItemHandlers::UseFromBag.add(:ABRAPORTER,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
=begin
  if !GameData::MapMetadata.exists?($game_map.map_id)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
=end
  if $game_map.name[/"Gym"/]
    pbMessage(_INTL("You can't teleport from Gyms."))
    next 0
  end
  healing = $PokemonGlobal.healingSpot
  healing = GameData::Metadata.get.home if !healing   # Home
  if !healing
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  next 2
})

ItemHandlers::ConfirmUseInField.add(:ABRAPORTER,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next false
  end
=begin
  if !GameData::MapMetadata.exists?($game_map.map_id)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
=end
  if $game_map.name.include?("Gym")
    pbMessage(_INTL("You can't teleport from Gyms."))
    next false
  end
  healing = $PokemonGlobal.healingSpot
  healing = GameData::Metadata.get.home if !healing   # Home
  if !healing
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  
  mapname = pbGetMapNameFromId(healing[0])
  next pbConfirmMessage(_INTL("Want to teleport from here and return to {1}?",mapname))
})

ItemHandlers::UseInField.add(:ABRAPORTER,proc { |item|
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you."))
    next 0
  end
=begin
  if !GameData::MapMetadata.exists?($game_map.map_id)
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
=end
  healing = $PokemonGlobal.healingSpot
  healing = GameData::Metadata.get.home if !healing   # Home
  if !healing
    pbMessage(_INTL("Can't use that here."))
    next 0
  end
  pbUseItemMessage(item)
  pbFadeOutIn {
    $game_temp.player_new_map_id    = healing[0]
    $game_temp.player_new_x         = healing[1]
    $game_temp.player_new_y         = healing[2]
    $game_temp.player_new_direction = 2
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }
  pbEraseEscapePoint
  next 1
})


BattleHandlers::EOREffectItem.add(:POISONORB,
  proc { |item,battler,battle|
    next if !battler.pbCanPoison?(nil,false)
    battler.pbPoison(nil,_INTL("{1} was poisoned by the {2}!",
       battler.pbThis,battler.itemName),false)
  }
)

ItemHandlers::UseOnPokemon.add(:EXPCANDYXS,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,250,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,1000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYM,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,4000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYL,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,12000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,50000,item,scene)
})

##################
# EXP-EZ DISPENSER
##################

ItemHandlers::UseFromBag.add(:EXPEZDISPENSER,proc { |item|
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
		next 0
	end
	next 1
})


ItemHandlers::ConfirmUseInField.add(:EXPEZDISPENSER,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:EXPEZDISPENSER,proc { |item|
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
		next 0
	end
	next 1
})


##################
# TEAM HEALER
##################

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

BattleHandlers::DamageCalcTargetItem.add(:STRIKEVEST,
  proc { |item,user,target,move,mults,baseDmg,type|
    mults[:defense_multiplier] *= 1.5 if move.physicalMove?
  }
)

########################
# Universal Formalizer
########################
ItemHandlers::UseOnPokemon.add(:UNIVERSALFORMALIZER,proc { |item,pkmn,scene|
	species = pkmn.species
	if [:DEOXYS,:ORICORIO,:LYCANROC,:ROTOM,
			:DARMANITAN,:GDARMANITAN,:BURMY,:WORMADAM,
			:DEERLING,:SAWSBUCK,:TORNADUS,:THUNDURUS,:LANDORUS,
			:PUMPKABOO,:GOURGEIST,:URSHIFU].include?(species)
		possibleForms = []
		possibleFormNames = []
		GameData::Species.each do |species_data|
			next unless species_data.species == species
			next if species_data.form == pkmn.form
			possibleForms.push(species_data)
			possibleFormNames.push(species_data.real_form_name)
		end
		possibleFormNames.push(_INTL("Cancel"))
		choice = scene.pbMessage("Which form shall the Pokemon take?",	possibleFormNames,possibleFormNames.length)
		if choice < possibleForm.length
			scene.pbMessage("#{pkmn.name} swapped to #{possibleFormNames[choice]}!")
			pkmn.form = possibleForms[choice].form
		end
		next true
	else
		scene.pbMessage("Cannot use this item on that Pokemon.")
		next false
	end
})