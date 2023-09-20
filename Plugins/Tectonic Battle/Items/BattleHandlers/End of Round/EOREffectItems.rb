STICKY_BARB_DAMAGE_FRACTION = 0.125 # 1/8

BattleHandlers::EOREffectItem.add(:STICKYBARB,
  proc { |item, battler, battle|
      next unless battler.takesIndirectDamage?
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!", battler.pbThis, getItemName(item)))
      battler.applyFractionalDamage(STICKY_BARB_DAMAGE_FRACTION)
  }
)
