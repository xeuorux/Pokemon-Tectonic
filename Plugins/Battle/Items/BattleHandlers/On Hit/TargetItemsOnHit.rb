BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
  proc { |item, user, target, move, battle|
      next unless target.canConsumeBerry?
      next unless move.physicalMove?
      next unless user.takesIndirectDamage?
      battle.pbCommonAnimation("Nom", target)
      battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!", target.pbThis,
         getItemName(item), user.pbThis(true)))
      fraction = 1.0 / 8.0
      fraction *= 2 if target.hasActiveAbility?(:RIPEN)
      user.applyFractionalDamage(fraction)
      target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROWAPBERRY,
  proc { |item, user, target, move, battle|
      next unless target.canConsumeBerry?
      next unless move.specialMove?
      next unless user.takesIndirectDamage?
      battle.pbCommonAnimation("Nom", target)
      battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!", target.pbThis,
         getItemName(item), user.pbThis(true)))
      fraction = 1.0 / 8.0
      fraction *= 2 if target.hasActiveAbility?(:RIPEN)
      user.applyFractionalDamage(fraction)
      target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROCKYHELMET,
  proc { |item, user, target, move, battle|
      next unless move.physicalMove?
      next unless user.takesIndirectDamage?
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, getItemName(item)))
      user.applyFractionalDamage(1.0 / 6.0)
  }
)

BattleHandlers::TargetItemOnHit.add(:HIVISJACKET,
  proc { |item, user, target, move, battle|
      next if move.physicalMove?
      next unless user.takesIndirectDamage?
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, getItemName(item)))
      user.applyFractionalDamage(1.0 / 6.0)
  }
)

BattleHandlers::TargetItemOnHit.add(:ENIGMABERRY,
  proc { |item, _user, target, _move, battle|
      next if target.damageState.substitute || target.damageState.disguise || target.damageState.iceface
      next unless Effectiveness.super_effective?(target.damageState.typeMod)
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:AIRBALLOON,
  proc { |item, _user, target, _move, battle|
      battle.pbDisplay(_INTL("{1}'s {2} popped!", target.pbThis, getItemName(item)))
      target.consumeItem(item, recoverable: false)
  }
)

BattleHandlers::TargetItemOnHit.add(:KEEBERRY,
  proc { |item, _user, target, move, battle|
      next unless move.physicalMove?
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:MARANGABERRY,
  proc { |item, _user, target, move, battle|
      next unless move.specialMove?
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:WEAKNESSPOLICY,
  proc { |item, _user, target, _move, _battle|
      next if target.damageState.disguise || target.damageState.iceface
      next unless Effectiveness.super_effective?(target.damageState.typeMod)
      next if !target.pbCanRaiseStatStage?(:ATTACK, target) &&
              !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, target)
      if target.pbRaiseMultipleStatStages([:ATTACK, 1, :SPECIAL_ATTACK, 1], target, item: item)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:STICKYBARB,
  proc { |item, user, target, move, battle|
      next unless move.physicalMove?
      next unless user.canAddItem?
      user.giveItem(item)
      target.removeItem(item)
      battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
         target.pbThis, getItemName(item), user.pbThis(true)))
  }
)