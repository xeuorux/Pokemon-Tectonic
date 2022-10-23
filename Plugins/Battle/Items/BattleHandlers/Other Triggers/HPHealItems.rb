BattleHandlers::HPHealItem.add(:AGUAVBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,4,
         _INTL("For {1}, the {2} was too bitter!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:APICOTBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPECIAL_DEFENSE)
    }
  )
  
  BattleHandlers::HPHealItem.add(:BERRYJUICE,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && battler.hp>battler.totalhp/2
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
      battle.pbCommonAnimation("UseItem",battler) if !forced
      battler.pbRecoverHP(20)
      if forced
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:FIGYBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,0,
         _INTL("For {1}, the {2} was too spicy!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:GANLONBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:DEFENSE)
    }
  )
  
  BattleHandlers::HPHealItem.add(:IAPAPABERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,1,
         _INTL("For {1}, the {2} was too sour!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:LANSATBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumePinchBerry?
      next false if battler.effects[PBEffects::FocusEnergy]>=2
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.effects[PBEffects::FocusEnergy] = 2
      itemName = GameData::Item.get(item).name
      if forced
        battle.pbDisplay(_INTL("{1} got pumped from the {2}!",battler.pbThis,itemName))
      else
        battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:LIECHIBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:ATTACK)
    }
  )
  
  BattleHandlers::HPHealItem.add(:MAGOBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,2,
         _INTL("For {1}, the {2} was too sweet!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:MICLEBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumePinchBerry?
      next false if !battler.effects[PBEffects::MicleBerry]
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.effects[PBEffects::MicleBerry] = true
      itemName = GameData::Item.get(item).name
      if forced
        PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
        battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!",
           battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:ORANBERRY,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(true)
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      healFromBerry(battler,1.0/3.0,item,forced)
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:PETAYABERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPECIAL_ATTACK)
    }
  )
  
  BattleHandlers::HPHealItem.add(:SALACBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPEED)
    }
  )
  
  BattleHandlers::HPHealItem.add(:SITRUSBERRY,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      healFromBerry(battler,1.0/4.0,item,forced=false)
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:STARFBERRY,
    proc { |item,battler,battle,forced|
      stats = []
      GameData::Stat.each_main_battle { |s| stats.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler) }
      next false if stats.length==0
      stat = stats[battle.pbRandom(stats.length)]
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,stat,2)
    }
  )
  
  BattleHandlers::HPHealItem.add(:WIKIBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,3,
         _INTL("For {1}, the {2} was too dry!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )