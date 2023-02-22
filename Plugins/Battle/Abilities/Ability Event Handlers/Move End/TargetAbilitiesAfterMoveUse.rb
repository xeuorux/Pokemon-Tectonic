BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |_ability, target, _user, move, _switched, battle|
      next if target.damageState.calcDamage == 0 || target.damageState.substitute
      next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
      next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
      typeName = GameData::Type.get(move.calcType).name
      battle.pbShowAbilitySplash(target)
      target.pbChangeTypes(move.calcType)
      battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!", target.pbThis,
         target.abilityName, typeName))
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |_ability, target, user, move, switched, battle|
      next if switched.include?(user.index)
      next unless move.pbDamagingMove?
      next unless move.physicalMove?
      next if battle.futureSight
      move.stealItem(target, user, true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:VENGEANCE,
  proc { |_ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      battle.pbShowAbilitySplash(target)
      user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:BRILLIANTFLURRY,
  proc { |_ability, target, user, move, _switched, _battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      user.pbLowerMultipleStatStages([:ATTACK, 1, :SPECIAL_ATTACK, 1, :SPEED, 1], user, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:STICKYMOLD,
  proc { |_ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      next if user.leeched?
      battle.pbShowAbilitySplash(target)
      user.applyLeeched(target) if user.canLeech?(target, true)
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:WRATHINSTINCT,
  proc { |_ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      battle.forceUseMove(target, :DRAGONDANCE, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MALICE,
  proc { |_ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      next if user.effectActive?(:Curse)
      battle.pbShowAbilitySplash(target)
      user.applyEffect(:Curse)
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:EXOADAPTION,
  proc { |_ability, target, user, move, _switched, _battle|
      next unless move.pbDamagingMove?
      next unless move.specialMove?
      healingMessage = _INTL("{1} heals itself with energy from {2}'s attack!", target.pbThis, user.pbThis(true))
      target.applyFractionalHealing(1.0 / 4.0, showAbilitySplash: true, customMessage: healingMessage)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MORPHINGGUARD,
  proc { |_ability, target, _user, move, _switched, battle|
      next unless move.pbDamagingMove?
      battle.pbShowAbilitySplash(target)
      target.disableEffect(:MorphingGuard)
      target.applyEffect(:MorphingGuard,move.calcType)
      battle.pbHideAbilitySplash(target)
  }
)