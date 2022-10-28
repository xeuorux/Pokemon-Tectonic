#===============================================================================
# TargetItemOnHitPositiveBerry handlers
# NOTE: This is for berries that have an effect when Pluck/Bug Bite/Fling
#       forces their use.
#===============================================================================

BattleHandlers::TargetItemOnHitPositiveBerry.add(:KEEBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if !battler.pbCanRaiseStatStage?(:DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      increment = 1
      if battler.hasActiveAbility?(:RIPEN)
        increment *=2
      end
      if !forced
        battle.pbCommonAnimation("EatBerry",battler)
        next battler.pbRaiseStatStageByCause(:DEFENSE,increment,battler,itemName)
      end
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      next battler.pbRaiseStatStage(:DEFENSE,increment,battler)
    }
  )
  
  BattleHandlers::TargetItemOnHitPositiveBerry.add(:MARANGABERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      increment = 1
      if battler.hasActiveAbility?(:RIPEN)
          increment *=2
      end
      if !forced
        battle.pbCommonAnimation("EatBerry",battler)
        next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,increment,battler,itemName)
      end
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      next battler.pbRaiseStatStage(:SPECIAL_DEFENSE,increment,battler)
    }
  )

  BattleHandlers::TargetItemOnHitPositiveBerry.add(:ENIGMABERRY,
    proc { |item,battler,battle,forced|
        next false if !battler.canHeal?
        next false if !forced && !battler.canConsumeBerry?
        battle.pbCommonAnimation("EatBerry",battler) if !forced
        healFromBerry(battler,1.0/4.0,item,forced=false)
        next true
    }
  )