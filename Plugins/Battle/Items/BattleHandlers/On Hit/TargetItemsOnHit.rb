BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next unless target.canConsumeBerry?
      next unless move.physicalMove?
      next unless user.takesIndirectDamage?
      next target.hasActiveAbilityAI?(:RIPEN) ? -30 : -15 if aiChecking
      battle.pbCommonAnimation("Nom", target)
      battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!", target.pbThis,
         getItemName(item), user.pbThis(true)))
      fraction = 1.0 / 4.0
      fraction *= 2 if target.hasActiveAbility?(:RIPEN)
      user.applyFractionalDamage(fraction)
      target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROWAPBERRY,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next unless target.canConsumeBerry?
      next unless move.specialMove?
      next unless user.takesIndirectDamage?
      next target.hasActiveAbilityAI?(:RIPEN) ? -30 : -15 if aiChecking
      battle.pbCommonAnimation("Nom", target)
      battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!", target.pbThis,
         getItemName(item), user.pbThis(true)))
      fraction = 1.0 / 4.0
      fraction *= 2 if target.hasActiveAbility?(:RIPEN)
      user.applyFractionalDamage(fraction)
      target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROCKYHELMET,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next unless move.physicalMove?
      next unless user.takesIndirectDamage?
      next -10 * aiNumHits if aiChecking
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, getItemName(item)))
      user.applyFractionalDamage(1.0 / 6.0)
  }
)

BattleHandlers::TargetItemOnHit.add(:HIVISJACKET,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next if move.physicalMove?
      next unless user.takesIndirectDamage?
      next -10 * aiNumHits if aiChecking
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, getItemName(item)))
      user.applyFractionalDamage(1.0 / 6.0)
  }
)

BattleHandlers::TargetItemOnHit.add(:ENIGMABERRY,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next if aiChecking
      next if target.damageState.substitute || target.damageState.disguise || target.damageState.iceface
      next unless Effectiveness.super_effective?(target.damageState.typeMod)
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:AIRBALLOON,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next 15 if aiChecking
      battle.pbDisplay(_INTL("{1}'s {2} popped!", target.pbThis, getItemName(item)))
      target.consumeItem(item, recoverable: false)
  }
)

BattleHandlers::TargetItemOnHit.add(:KEEBERRY,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next getMultiStatUpEffectScore([:DEFENSE, target.hasActiveAbilityAI?(:RIPEN) ? 4 : 2], user, target) if aiChecking
      next unless move.physicalMove?
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:MARANGABERRY,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next getMultiStatUpEffectScore([:SPECIAL_DEFENSE, target.hasActiveAbilityAI?(:RIPEN) ? 4 : 2], user, target) if aiChecking
      next unless move.specialMove?
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:WEAKNESSPOLICY,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      statUp = [:ATTACK, 4, :SPECIAL_ATTACK, 4]
      next getMultiStatUpEffectScore(statUp, user, target) if aiChecking
      next if target.damageState.disguise || target.damageState.iceface
      next unless Effectiveness.super_effective?(target.damageState.typeMod)
      next if !target.pbCanRaiseStatStage?(:ATTACK, target) &&
              !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK, target)
      if target.pbRaiseMultipleStatStages(statUp, target, item: item)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:STICKYBARB,
  proc { |item, user, target, move, battle, aiChecking, aiNumHits|
      next unless user.canAddItem?(item)
      next -20 if aiChecking 
      user.giveItem(item)
      target.removeItem(item)
      battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
         target.pbThis, getItemName(item), user.pbThis(true)))
  }
)