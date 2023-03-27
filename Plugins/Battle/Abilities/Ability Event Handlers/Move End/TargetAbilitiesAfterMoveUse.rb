BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability, target, _user, move, _switched, battle|
      next if target.damageState.calcDamage == 0 || target.damageState.substitute
      next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
      next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
      typeName = GameData::Type.get(move.calcType).name
      battle.pbShowAbilitySplash(target, ability)
      target.pbChangeTypes(move.calcType)
      battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!", target.pbThis, getAbilityName(ability), typeName))
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability, target, user, move, switched, battle|
      next if switched.include?(user.index)
      next unless move.pbDamagingMove?
      next unless move.physicalMove?
      next if battle.futureSight
      move.stealItem(target, user, target.firstItem, ability: ability)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MOONLIGHTER,
  proc { |ability, target, user, move, switched, battle|
      next if switched.include?(user.index)
      next unless move.pbDamagingMove?
      next if battle.futureSight
      next unless battle.pbWeather == :Moonglow
      item = target.firstItem
      if move.canStealItem?(user,target, item)
        move.stealItem(target, user, item, ability: ability)
      else
        move.knockOffItems(target, user, ability: ability, firstItemOnly: true)
      end
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:VENGEANCE,
  proc { |ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      battle.pbShowAbilitySplash(target, ability)
      user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:BRILLIANTFLURRY,
  proc { |ability, target, user, move, _switched, _battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      user.pbLowerMultipleStatStages([:ATTACK, 2, :SPECIAL_ATTACK, 2, :SPEED, 2], target, ability: ability)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:STICKYMOLD,
  proc { |ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      next if user.leeched?
      battle.pbShowAbilitySplash(target, ability)
      user.applyLeeched(target) if user.canLeech?(target, true)
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:WRATHINSTINCT,
  proc { |ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      battle.forceUseMove(target, :DRAGONDANCE, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MALICE,
  proc { |ability, target, user, move, _switched, battle|
      next unless move.damagingMove?
      next unless target.knockedBelowHalf?
      next if user.effectActive?(:Curse)
      battle.pbShowAbilitySplash(target, ability)
      user.applyEffect(:Curse)
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:EXOADAPTION,
  proc { |ability, target, user, move, _switched, _battle|
      next unless move.pbDamagingMove?
      next unless move.specialMove?
      healingMessage = _INTL("{1} heals itself with energy from {2}'s attack!", target.pbThis, user.pbThis(true))
      target.applyFractionalHealing(1.0 / 4.0, ability: ability, customMessage: healingMessage)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:MORPHINGGUARD,
  proc { |ability, target, _user, move, _switched, battle|
      next unless move.pbDamagingMove?
      battle.pbShowAbilitySplash(target, ability)
      target.disableEffect(:MorphingGuard)
      target.applyEffect(:MorphingGuard,move.calcType)
      battle.pbHideAbilitySplash(target)
  }
)