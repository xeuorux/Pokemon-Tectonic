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
    if target.pbCanRaiseStatStage?(:ATTACK,target) || target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      battle.pbShowAbilitySplash(target)
      target.pbRaiseStatStageByAbility(:ATTACK,1,target,false) if target.pbCanRaiseStatStage?(:ATTACK,target)
      target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false) if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:ADRENALINERUSH,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
	target.pbRaiseStatStageByAbility(:SPEED,2,target) if target.pbCanRaiseStatStage?(:SPEED,target)
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
    next if !user.pbCanLowerStatStage?(:ATTACK,target) && !user.pbCanLowerStatStage?(:SPECIAL_ATTACK,target) && !user.pbCanLowerStatStage?(:SPEED,target)
    battle.pbShowAbilitySplash(target)
    if user.pbCanLowerStatStage?(:ATTACK,target,nil,true)
      user.pbLowerStatStage(:ATTACK,1,target)
    end
    if user.pbCanLowerStatStage?(:SPECIAL_ATTACK,target,nil,true)
      user.pbLowerStatStage(:SPECIAL_ATTACK,1,target)
    end
    if user.pbCanLowerStatStage?(:SPEED,target,nil,true)
      user.pbLowerStatStage(:SPEED,1,target)
    end
    battle.pbHideAbilitySplash(target)
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