BattleHandlers::TargetItemOnHit.add(:ABSORBBULB,
  proc { |item,user,target,move,battle|
    next if move.calcType != :WATER
    target.pbHeldItemTriggered(item) if target.tryRaiseStat(:SPECIAL_ATTACK,target,item: target.item)
  }
)

BattleHandlers::TargetItemOnHit.add(:CELLBATTERY,
  proc { |item,user,target,move,battle|
    next if move.calcType != :ELECTRIC
    target.pbHeldItemTriggered(item) if target.tryRaiseStat(:ATTACK,target,item: target.item)
  }
)

BattleHandlers::TargetItemOnHit.add(:LUMINOUSMOSS,
  proc { |item,user,target,move,battle|
    next if move.calcType != :WATER
    target.pbHeldItemTriggered(item) if target.tryRaiseStat(:SPECIAL_DEFENSE,target,item: target.item)
  }
)

BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
  proc { |item,user,target,move,battle|
    next if !target.canConsumeBerry?
    next if !move.physicalMove?
    next if !user.takesIndirectDamage?
    battle.pbCommonAnimation("EatBerry",target)
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
       target.itemName,user.pbThis(true)))
    fraction = 1.0/8.0
    fraction *= 2 if target.hasActiveAbility?(:RIPEN)
    user.applyFractionalDamage(fraction)
    target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROWAPBERRY,
  proc { |item,user,target,move,battle|
    next if !target.canConsumeBerry?
    next if !move.specialMove?
    next if !user.takesIndirectDamage?
    battle.pbCommonAnimation("EatBerry",target)
    battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
       target.itemName,user.pbThis(true)))
    fraction = 1.0/8.0
    fraction *= 2 if target.hasActiveAbility?(:RIPEN)
    user.applyFractionalDamage(fraction)
    target.pbHeldItemTriggered(item)
  }
)

BattleHandlers::TargetItemOnHit.add(:ROCKYHELMET,
  proc { |item,user,target,move,battle|
    next if !move.physicalMove?
    next if !user.takesIndirectDamage?
    battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,target.itemName))
    user.applyFractionalDamage(1.0/6.0)
  }
)

BattleHandlers::TargetItemOnHit.add(:BUSTEDRADIO,
  proc { |item,user,target,move,battle|
    next if move.physicalMove?
    next if !user.takesIndirectDamage?
    battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,target.itemName))
    user.applyFractionalDamage(1.0/6.0)
  }
)

BattleHandlers::TargetItemOnHit.add(:ENIGMABERRY,
  proc { |item,user,target,move,battle|
    next if target.damageState.substitute || target.damageState.disguise || target.damageState.iceface
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
      target.pbHeldItemTriggered(item)
    end
  }
)

BattleHandlers::TargetItemOnHit.add(:AIRBALLOON,
  proc { |item,user,target,move,battle|
    battle.pbDisplay(_INTL("{1}'s {2} popped!",target.pbThis,target.itemName))
	  target.pbScavenge
    target.pbConsumeItem(false,true)
    target.pbSymbiosis
  }
)

BattleHandlers::TargetItemOnHit.add(:KEEBERRY,
  proc { |item,user,target,move,battle|
    next if !move.physicalMove?
    if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
      target.pbHeldItemTriggered(item)
    end
  }
)

BattleHandlers::TargetItemOnHit.add(:MARANGABERRY,
  proc { |item,user,target,move,battle|
    next if !move.specialMove?
    if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
      target.pbHeldItemTriggered(item)
    end
  }
)

BattleHandlers::TargetItemOnHit.add(:WEAKNESSPOLICY,
  proc { |item,user,target,move,battle|
    next if target.damageState.disguise  || target.damageState.iceface
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    next if !target.pbCanRaiseStatStage?(:ATTACK,target) &&
            !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
    if target.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],target,item: target.item)
      target.pbHeldItemTriggered(item)
    end    
  }
)

BattleHandlers::TargetItemOnHit.add(:STICKYBARB,
  proc { |item,user,target,move,battle|
    next if !move.physicalMove?
    next if user.fainted? || user.item
    user.item = target.item
    target.item = nil
    target.applyEffect(:ItemLost)
    if battle.wildBattle? && !user.opposes?
      if !user.initialItem && target.initialItem==user.item
        user.setInitialItem(user.item)
        target.setInitialItem(nil)
      end
    end
    battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
       target.pbThis,user.itemName,user.pbThis(true)))
  }
)

BattleHandlers::TargetItemOnHit.add(:SNOWBALL,
  proc { |item,user,target,move,battle|
    next if move.calcType != :ICE
    target.pbHeldItemTriggered(item) if target.tryRaiseStat(:ATTACK,target,item: target.item)
  }
)