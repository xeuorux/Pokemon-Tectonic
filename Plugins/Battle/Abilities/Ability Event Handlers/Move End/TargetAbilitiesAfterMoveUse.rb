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
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. This doesn't make
    #       sense, so this code doesn't do it.
    next if battle.wildBattle? && target.opposes? && !user.boss
    next if !move.contactMove?
    next if switched.include?(user.index)
    next if user.effectActive?(:Substitute) || target.damageState.substitute
    next if target.item || !user.item
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if user.hasActiveAbility?(:STICKYHOLD)
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = nil
    user.applyEffect(:ItemLost)
    if battle.wildBattle? && !target.initialItem && user.initialItem == target.item
      target.setInitialItem(target.item)
      user.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
       user.pbThis(true),target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
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
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
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