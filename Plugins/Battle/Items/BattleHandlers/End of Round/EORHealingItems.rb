BattleHandlers::EORHealingItem.add(:BLACKSLUDGE,
    proc { |item,battler,battle|
      if battler.pbHasType?(:POISON)
        target.applyFractionalHealing(1.0/16.0, customMessage: healMessage, item: item)
      elsif battler.takesIndirectDamage?
        battle.pbCommonAnimation("UseItem",battler)
        battle.pbDisplay(_INTL("{1} is hurt by its {2}!",battler.pbThis,battler.itemName))
        battler.applyFractionalDamage(1.0/8.0)
      end
    }
  )
  
  BattleHandlers::EORHealingItem.add(:LEFTOVERS,
    proc { |item,battler,battle|
        next if !battler.canLeftovers?
        battler.applyFractionalHealing(1.0/16.0, customMessage: healMessage, item: item)
    }
  )