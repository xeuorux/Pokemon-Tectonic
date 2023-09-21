STICKY_BARB_DAMAGE_FRACTION = 0.125 # 1/8

BattleHandlers::EOREffectItem.add(:STICKYBARB,
  proc { |item, battler, battle|
      next unless battler.takesIndirectDamage?
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, getItemName(item)))
      battler.applyFractionalDamage(STICKY_BARB_DAMAGE_FRACTION)
  }
)

BattleHandlers::EOREffectItem.add(:POISONORB,
  proc { |item, battler, battle|
	  next unless battler.canPoison?(nil, false)
      battler.applyPoison(nil,
  	  _INTL("{1} was poisoned by the {2}! {3}!", battler.pbThis, getItemName(item), POISONED_EXPLANATION))
  }
)

BattleHandlers::EOREffectItem.add(:FROSTORB,
  proc { |item, battler, battle|
	  next unless battler.canFrostbite?(nil, false)
      battler.applyFrostbite(nil,
  	  _INTL("{1} was frostbitten by the {2}! {3}!", battler.pbThis, getItemName(item), FROSTBITE_EXPLANATION))
  }
)

BattleHandlers::EOREffectItem.add(:FLAMEORB,
  proc { |item, battler, battle|
	  next unless battler.canBurn?(nil, false)
      battler.applyBurn(nil,
  	  _INTL("{1} was burned by the {2}! {3}!", battler.pbThis, getItemName(item), BURNED_EXPLANATION))
  }
)