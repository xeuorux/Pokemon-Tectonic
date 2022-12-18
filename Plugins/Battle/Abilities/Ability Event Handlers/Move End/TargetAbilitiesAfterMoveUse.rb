BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability,target,user,move,switched,battle|
    next if target.damageState.calcDamage==0 || target.damageState.substitute
    next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = GameData::Type.get(move.calcType).name
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
       target.abilityName,typeName))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability,target,user,move,switched,battle|
    next if switched.include?(user.index)
    next if !move.pbDamagingMove?
    next if !move.physicalMove?
    next if battle.futureSight
    move.stealItem(target,user,true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:VENGEANCE,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(true)
      user.applyFractionalDamage(1.0/4.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:BRILLIANTFLURRY,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    user.pbLowerMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1,:SPEED,1], user, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:STICKYMOLD,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    next if user.leeched?
    battle.pbShowAbilitySplash(target)
	  user.applyLeeched(target) if user.canLeech?(target, true)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:TYRANTSWRATH,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    battle.forceUseMove(target,:TYRANTSFIT,user.index,false,nil,nil,true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MALICE,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    next if user.effectActive?(:Curse)
    battle.pbShowAbilitySplash(target)
    user.applyEffect(:Curse)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:EXOADAPTION,
  proc { |ability,target,user,move,switched,battle|
    next unless move.pbDamagingMove?
    next unless move.specialMove?
    healingMessage = _INTL("{1} heals itself with energy from {2}'s attack!", target.pbThis, user.pbThis(true))
    target.applyFractionalHealing(1.0/4.0, showAbilitySplash: true, customMessage: healingMessage)
  }
)