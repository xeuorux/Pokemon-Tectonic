BattleHandlers::HPHealItem.add(:BERRYJUICE,
  proc { |item, battler, battle, forced, filchedFrom|
      next false unless battler.canHeal?
      next false if !forced && battler.aboveHalfHealth?
      if filchedFrom
        battle.pbShowAbilitySplash(battler)
        itemName = GameData::Item.get(item).real_name
        battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
      end
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
      battle.pbCommonAnimation("UseItem", battler) unless forced
      battler.pbRecoverHP(20)
      if forced
          battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
      else
          battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
      end
      battle.pbHideAbilitySplash(battler) if filchedFrom
      next true
  }
)


BattleHandlers::HPHealItem.add(:GANLONBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :DEFENSE, 1, true, filchedFrom)
  }
)

BattleHandlers::HPHealItem.add(:APICOTBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :SPECIAL_DEFENSE, 1, true, filchedFrom)
  }
)

BattleHandlers::HPHealItem.add(:LIECHIBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :ATTACK, 1, true, filchedFrom)
  }
)

BattleHandlers::HPHealItem.add(:PETAYABERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :SPECIAL_ATTACK, 1, true, filchedFrom)
  }
)

BattleHandlers::HPHealItem.add(:SALACBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, :SPEED, 1, true, filchedFrom)
  }
)

BattleHandlers::HPHealItem.add(:LANSATBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next false if !forced && !battler.canConsumePinchBerry?
      next false if battler.effectAtMax?(:FocusEnergy)
      if filchedFrom
        battle.pbShowAbilitySplash(battler)
        itemName = GameData::Item.get(item).real_name
        battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
      end
      battle.pbCommonAnimation("Nom", battler) unless forced
      battler.incrementEffect(:FocusEnergy, 2)
      battle.pbHideAbilitySplash(battler) if filchedFrom
      next true
  }
)

BattleHandlers::HPHealItem.add(:MICLEBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next false if !forced && !battler.canConsumePinchBerry?
      next false unless battler.effectActive?(:MicleBerry)
      if filchedFrom
        battle.pbShowAbilitySplash(battler)
        itemName = GameData::Item.get(item).real_name
        battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
      end
      battle.pbCommonAnimation("Nom", battler) unless forced
      battler.applyEffect(:MicleBerry)
      itemName = GameData::Item.get(item).name
      if forced
          PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
          battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move!", battler.pbThis))
      else
          battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!",
             battler.pbThis, itemName))
      end
      attle.pbHideAbilitySplash(battler) if filchedFrom
      next true
  }
)

BattleHandlers::HPHealItem.add(:ORANBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next false unless battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(true)
      healFromBerry(battler, 1.0 / 3.0, item, forced, filchedFrom)
      next true
  }
)

BattleHandlers::HPHealItem.add(:SITRUSBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      next false unless battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      healFromBerry(battler, 1.0 / 4.0, item, forced, filchedFrom)
      next true
  }
)

BattleHandlers::HPHealItem.add(:STARFBERRY,
  proc { |item, battler, battle, forced, filchedFrom|
      stats = []
      GameData::Stat.each_main_battle { |s| stats.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler) }
      next false if stats.length == 0
      stat = stats[battle.pbRandom(stats.length)]
      next pbBattleStatIncreasingBerry(battler, battle, item, forced, stat, 2, true, filchedFrom)
  }
)