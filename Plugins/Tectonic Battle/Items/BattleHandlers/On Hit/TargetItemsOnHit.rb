BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next unless target.canConsumeBerry?
      next unless move.physicalMove?
      next unless user.takesIndirectDamage?
      next target.hasActiveAbilityAI?(:RIPEN) ? -30 : -15 if aiCheck
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
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next unless target.canConsumeBerry?
      next unless move.specialMove?
      next unless user.takesIndirectDamage?
      next target.hasActiveAbilityAI?(:RIPEN) ? -30 : -15 if aiCheck
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
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next if battle.futureSight
      next unless move.physicalMove?
      next unless user.takesIndirectDamage?
      next -10 * aiNumHits if aiCheck
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, getItemName(item)))
      user.applyFractionalDamage(1.0 / 6.0)
      target.aiLearnsItem(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:HIVISJACKET,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next if battle.futureSight
      next if move.physicalMove?
      next unless user.takesIndirectDamage?
      next -10 * aiNumHits if aiCheck
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!", user.pbThis, getItemName(item)))
      user.applyFractionalDamage(1.0 / 6.0)
      target.aiLearnsItem(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ENIGMABERRY,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next if aiCheck
      next if target.damageState.substitute || target.damageState.disguise
      next unless Effectiveness.super_effective?(target.damageState.typeMod)
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:AIRBALLOON,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next 15 if aiCheck
      battle.pbDisplay(_INTL("{1}'s {2} popped!", target.pbThis, getItemName(item)))
      target.consumeItem(item, recoverable: false)
  }
)

BattleHandlers::TargetItemOnHit.add(:KEEBERRY,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next unless move.physicalMove?
      next getMultiStatUpEffectScore([:DEFENSE, target.hasActiveAbilityAI?(:RIPEN) ? 4 : 2], user, target, evaluateThreat: false) if aiCheck
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:MARANGABERRY,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next unless move.specialMove?
      next getMultiStatUpEffectScore([:SPECIAL_DEFENSE, target.hasActiveAbilityAI?(:RIPEN) ? 4 : 2], user, target, evaluateThreat: false) if aiCheck
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item, target, battle, false)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:WEAKNESSPOLICY,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      statUp = [:ATTACK, 4, :SPECIAL_ATTACK, 4]
      next if aiCheck # aiCheck Disabled until AI item rework, also needs rework for type calculation
      #next getMultiStatUpEffectScore(statUp, user, target, evaluateThreat: false) if aiCheck
      next if target.damageState.disguise
      next unless Effectiveness.super_effective?(target.damageState.typeMod)
      next if !target.pbCanRaiseStatStep?(:ATTACK, target) &&
              !target.pbCanRaiseStatStep?(:SPECIAL_ATTACK, target)
      if target.pbRaiseMultipleStatSteps(statUp, target, item: item)
          target.pbHeldItemTriggered(item)
      end
  }
)

BattleHandlers::TargetItemOnHit.add(:STICKYBARB,
  proc { |item, user, target, move, battle, aiCheck, aiNumHits|
      next if battle.futureSight
      next unless user.canAddItem?(item)
      next -20 if aiCheck 
      user.giveItem(item)
      target.removeItem(item)
      battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
         target.pbThis, getItemName(item), user.pbThis(true)))
  }
)