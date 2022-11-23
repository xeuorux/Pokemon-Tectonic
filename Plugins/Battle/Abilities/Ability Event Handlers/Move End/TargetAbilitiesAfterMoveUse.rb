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

BattleHandlers::TargetAbilityAfterMoveUse.add(:BERSERK,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    target.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1], target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:ADRENALINERUSH,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    target.tryRaiseStat(:SPEED,target,increment: 2, showAbilitySplash: true)
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

BattleHandlers::TargetAbilityAfterMoveUse.add(:BOULDERNEST,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    battle.pbShowAbilitySplash(target)
	  if target.pbOpposingSide.effectActive?(:StealthRock)
        battle.pbDisplay(_INTL("But there were already pointed stones floating around {1}!",target.pbOpposingTeam(true)))
    else
        target.pbOpposingSide.applyEffect(:StealthRock)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:REAWAKENEDPOWER,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    target.pbMaximizeStatStage(:SPECIAL_ATTACK,user,self,false,true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:STICKYMOLD,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    next if user.leeched?
    battle.pbShowAbilitySplash(target)
	  user.applyLeech(target) if user.canLeech?(target, true)
    battle.pbHideAbilitySplash(target)
  }
)