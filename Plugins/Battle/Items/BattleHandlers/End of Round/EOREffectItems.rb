BattleHandlers::EOREffectItem.add(:FLAMEORB,
    proc { |item,battler,battle|
      next if !battler.canBurn?(nil,false)
      battler.applyBurn(nil,_INTL("{1} was burned by the {2}! {3}",battler.pbThis,battler.itemName,BURNED_EXPLANATION))
    }
  )
  
  BattleHandlers::EOREffectItem.add(:POISONORB,
    proc { |item,battler,battle|
      next if !battler.canPoison?(nil,false)
      battler.applyPoison(nil,_INTL("{1} was poisoned by the {2}! {3}!",battler.pbThis,battler.itemName,POISONED_EXPLANATION))
    }
  )
  
  BattleHandlers::EOREffectItem.add(:FROSTORB,
    proc { |item,battler,battle|
      next if !battler.canFrostbite?(nil,false)
      battler.applyFrostbite(nil,_INTL("{1} was afflicted by the {2}! {3}!",battler.pbThis,battler.itemName,FROSTBITE_EXPLANATION))
    }
  )
  
  BattleHandlers::EOREffectItem.add(:STICKYBARB,
    proc { |item,battler,battle|
      next if !battler.takesIndirectDamage?
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!",battler.pbThis,battler.itemName))
      battler.applyFractionalDamage(1.0/8.0)
    }
  )