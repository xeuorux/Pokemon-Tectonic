BattleHandlers::TargetAbilityOnHit.add(:FEEDBACK,
  proc { |ability,user,target,move,battle|
    next if !move.specialMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
      user.applyFractionalDamage(1.0/8.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
  proc { |ability,user,target,move,battle|
    next unless move.specialMove?
    next if battle.pbRandom(100)>=30
    next if user.poisoned?
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}! {4}}!",target.pbThis,target.abilityName,user.pbThis(true),POISONED_EXPLANATION)
      end
      user.pbPoison(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SUDDENCHILL,
  proc { |ability,user,target,move,battle|
    next if !move.specialMove?
    next if battle.pbRandom(100)>=30
    next if user.frostbitten?
    battle.pbShowAbilitySplash(target)
    if user.pbCanFrostbite?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} frostbit {3}! {4}!",target.pbThis,target.abilityName,user.pbThis(true),FROSTBITE_EXPLANATION)
      end
      user.pbFrostbite(msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    next if user.frostbitten?
    battle.pbShowAbilitySplash(target)
    if user.pbCanFrostbite?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} frostbit {3}! {4}!",target.pbThis,target.abilityName,user.pbThis(true),FROSTBITE_EXPLANATION)
      end
      user.pbFrostbite(msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.effects[PBEffects::Curse] == true || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("{1} laid a curse on {2}!",target.pbThis(true),user.pbThis))
    user.effects[PBEffects::Curse] = true
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILING,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
	  # next if target.effects[PBEffects::Charm] > 0
    # battle.pbShowAbilitySplash(target)
    # if user.pbCanCharm?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
    #    user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    #   msg = nil
    #   if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    #     msg = _INTL("{1}'s {2} charmed {3}!",target.pbThis,
    #        target.abilityName,user.pbThis(true))
    #   end
    #   user.pbCharm
    # end
    # battle.pbHideAbilitySplash(target)
    next if user.mystified?
    battle.pbShowAbilitySplash(target)
    if user.pbCanMystify?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} mystified {3}! {4}!",target.pbThis,target.abilityName,user.pbThis(true),MYSTIFIED_EXPLANATION)
      end
      user.pbMystify(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:DISORIENT,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
	  # next if target.effects[PBEffects::Confusion] > 0
    # battle.pbShowAbilitySplash(target)
    # if user.pbCanConfuse?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
    #    user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    #   msg = nil
    #   if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    #     msg = _INTL("{1}'s {2} confused {3}!",target.pbThis,
    #        target.abilityName,user.pbThis(true))
    #   end
    #   user.pbConfuse
    # end
    # battle.pbHideAbilitySplash(target)
    next if user.flustered?
    battle.pbShowAbilitySplash(target)
    if user.pbCanFluster?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} flustered {3}! {4}!",target.pbThis,target.abilityName,user.pbThis(true),FLUSTERED_EXPLANATION)
      end
      user.pbFluster(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ADAPTIVESKIN,
  proc { |ability,user,target,move,battle|
    if move.physicalMove?
		  target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
	  else
		  target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target)
	  end
  }
)


BattleHandlers::TargetAbilityOnHit.add(:QUILLERINSTINCT,
  proc { |ability,user,target,move,battle|
    next if target.pbOpposingSide.effectAtMax?(:Spikes)
    battle.pbShowAbilitySplash(target)
    target.pbOpposingSide.incrementEffect(:Spikes)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ELECTRICFENCE,
  proc { |ability,user,target,move,battle|
	echoln target.battle.field.terrain == :Electric
    next unless target.battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) && user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
      user.applyFractionalDamage(1.0/6.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PETRIFYING,
  proc { |ability,user,target,move,battle|
    next if user.paralyzed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} numbed {3}! {4}!",
           target.pbThis,target.abilityName,user.pbThis(true),NUMBED_EXPLANATION)
      end
      user.pbParalyze(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)


BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
  proc { |ability,user,target,move,battle|
    next if !Effectiveness.resistant?(target.damageState.typeMod)
	if target.pbCanRaiseStatStage?(:ATTACK,target) || target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
		battle.pbShowAbilitySplash(target)
		target.pbRaiseStatStageByAbility(:ATTACK,1,target,false) if target.pbCanRaiseStatStage?(:ATTACK,target)
		target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false) if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
		battle.pbHideAbilitySplash(target)
	end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SEEDSCATTER,
	proc { |ability,target,battler,move,battle|
    terrainSetAbility(:Grassy,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:THUNDERSTRUCK,
	proc { |ability,target,battler,move,battle|
    terrainSetAbility(:Electric,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:MISTCRAFT,
	proc { |ability,target,battler,move,battle|
		terrainSetAbility(:Misty,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:CLEVERRESPONSE,
	proc { |ability,target,battler,move,battle|
    terrainSetAbility(:Psychic,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:RELUCTANTBLADE,
  proc { |ability,user,target,move,battle|
    if move.physicalMove?
      battle.forceUseMove(target,:LEAFAGE,user.index,true,nil,nil,true)
	  end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WIBBLEWOBBLE,
  proc { |ability,user,target,move,battle|
      battle.forceUseMove(target,:POWERSPLIT,user.index,true,nil,nil,true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CONSTRICTOR,
  proc { |ability,user,target,move,battle|
    if move.physicalMove?
      battle.forceUseMove(target,:BIND,user.index,true,nil,nil,true)
	  end
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:REAWAKENEDPOWER,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
	if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
		battle.pbShowAbilitySplash(target)
		target.pbMaximizeStatStage(:SPECIAL_ATTACK,user,self) if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
		battle.pbHideAbilitySplash(target)
	end
  }
)