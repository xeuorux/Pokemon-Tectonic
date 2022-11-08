BattleHandlers::EORHealingItem.add(:BLACKSLUDGE,
    proc { |item,battler,battle|
      if battler.pbHasType?(:POISON)
        next if !battler.canHeal?
        battle.pbCommonAnimation("UseItem",battler)
        healAmount = battler.totalhp/16.0
        healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
        healMessage =_INTL("{1} restored a little HP using its {2}!",battler.pbThis,battler.itemName)
        battler.pbRecoverHP(healAmount,true,true,true,healMessage)
      elsif battler.takesIndirectDamage?
        battle.pbCommonAnimation("UseItem",battler)
        battle.pbDisplay(_INTL("{1} is hurt by its {2}!",battler.pbThis,battler.itemName))
        battler.applyFractionalDamage(1.0/8.0)
      end
    }
  )
  
  BattleHandlers::EORHealingItem.add(:LEFTOVERS,
    proc { |item,battler,battle|
        next if !battler.canHeal?
        next if !battler.canLeftovers?
        battle.pbCommonAnimation("UseItem",battler)
        healAmount = battler.totalhp/16.0
        healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
        healMessage =_INTL("{1} restored a little HP using its {2}!",battler.pbThis,battler.itemName)
        battler.pbRecoverHP(healAmount,true,true,true,healMessage)
    }
  )