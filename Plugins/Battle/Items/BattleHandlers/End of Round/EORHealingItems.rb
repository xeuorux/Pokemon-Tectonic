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
        oldHP = battler.hp
        battle.pbCommonAnimation("UseItem",battler)
        damageAmount = battler.totalhp/8.0
        damageAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
        battler.pbReduceHP(damageAmount)
        battle.pbDisplay(_INTL("{1} is hurt by its {2}!",battler.pbThis,battler.itemName))
        battler.pbItemHPHealCheck
        battler.pbAbilitiesOnDamageTaken(oldHP)
        battler.pbFaint if battler.fainted?
      end
    }
  )
  
  BattleHandlers::EORHealingItem.add(:LEFTOVERS,
    proc { |item,battler,battle|
        next if !battler.canHeal?
        battle.pbCommonAnimation("UseItem",battler)
        healAmount = battler.totalhp/16.0
        healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
        healMessage =_INTL("{1} restored a little HP using its {2}!",battler.pbThis,battler.itemName)
        battler.pbRecoverHP(healAmount,true,true,true,healMessage)
    }
  )