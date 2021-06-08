BattleHandlers::StatusCureItem.add(:ASPEARBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status != :FROZEN
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced)
    battle.pbDisplay(_INTL("{1}'s {2} unchilled it!",battler.pbThis,itemName)) if !forced
    next true
  }
)

ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc { |item,pkmn,scene|
  if pkmn.fainted? || pkmn.status != :FROZEN
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  pkmn.heal_status
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1} was unchilled out.",pkmn.name))
  next true
})

ItemHandlers::UseOnPokemon.copy(:ICEHEAL,:ASPEARBERRY)

BattleHandlers::EOREffectItem.add(:TOXICORB,
  proc { |item,battler,battle|
    next if !battler.pbCanPoison?(nil,false)
    battler.pbPoison(nil,_INTL("{1} was toxified by the {2}!",
       battler.pbThis,battler.itemName),true)
  }
)

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,:STATUSHEAL)

ItemHandlers::UseOnPokemon.add(:POTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,40,scene)
})

ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,80,scene)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc { |item,pkmn,scene|
  next pbHPItem(pkmn,120,scene)
})

BattleHandlers::StatusCureItem.add(:LUMBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.status == :NONE
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    oldStatus = battler.status
    battler.pbCureStatus(forced)
    if !forced
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,itemName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,itemName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,itemName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,itemName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,itemName))
      end
    end
    next true
  }
)

BattleHandlers::StatusCureItem.add(:PERSIMBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if battler.effects[PBEffects::Confusion]==0 && battler.effects[PBEffects::Charm]==0
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
	wasConfused 	= (battler.effects[PBEffects::Confusion]>0)
	wasCharmed		= (battler.effects[PBEffects::Charm]>0)
    battler.pbCureConfusion
	battler.pbCureCharm
    if forced
		battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis)) if wasConfused
		battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis)) if wasCharmed
    else
		battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName)) if wasConfused
		battle.pbDisplay(_INTL("{1}'s {2} released it from the charm!",battler.pbThis,itemName)) if wasCharmed
    end
    next true
  }
)

BattleHandlers::StatusCureItem.add(:MENTALHERB,
  proc { |item,battler,battle,forced|
    next false if battler.effects[PBEffects::Attract]==-1 &&
                  battler.effects[PBEffects::Taunt]==0 &&
                  battler.effects[PBEffects::Encore]==0 &&
                  !battler.effects[PBEffects::Torment] &&
                  battler.effects[PBEffects::Disable]==0 &&
                  battler.effects[PBEffects::HealBlock]==0 &&
				  battler.effects[PBEffects::Confusion]==0 &&
				  battler.effects[PBEffects::Charm]==0 &&
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    battle.pbCommonAnimation("UseItem",battler) if !forced
    if battler.effects[PBEffects::Attract]>=0
      if forced
        battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} cured its infatuation status using its {2}!",
           battler.pbThis,itemName))
      end
      battler.pbCureAttract
    end
    battle.pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis)) if battler.effects[PBEffects::Taunt]>0
    battler.effects[PBEffects::Taunt]      = 0
    battle.pbDisplay(_INTL("{1}'s encore ended!",battler.pbThis)) if battler.effects[PBEffects::Encore]>0
    battler.effects[PBEffects::Encore]     = 0
    battler.effects[PBEffects::EncoreMove] = nil
    battle.pbDisplay(_INTL("{1}'s torment wore off!",battler.pbThis)) if battler.effects[PBEffects::Torment]
    battler.effects[PBEffects::Torment]    = false
    battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis)) if battler.effects[PBEffects::Disable]>0
    battler.effects[PBEffects::Disable]    = 0
    battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis)) if battler.effects[PBEffects::HealBlock]>0
    battler.effects[PBEffects::HealBlock]  = 0
	battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName)) if battler.effects[PBEffects::Confusion]>0
	battler.pbCureConfusion
	battle.pbDisplay(_INTL("{1}'s {2} released it from the charm!",battler.pbThis,itemName)) if battler.effects[PBEffects::Charm]>0
	battler.pbCureCharm
    next true
  }
)

BattleHandlers::DamageCalcUserItem.add(:THICKCLUB,
  proc { |item,user,target,move,mults,baseDmg,type|
    if (user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK)) && move.physicalMove?
      mults[:attack_multiplier] *= 1.5
    end
  }
)