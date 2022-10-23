BattleHandlers::EORGainItemAbility.add(:HARVEST,
    proc { |ability,battler,battle|
      next if battler.item
      next if !battler.recycleItem || !GameData::Item.get(battler.recycleItem).is_berry?
      if ![:Sun, :HarshSun].include?(battle.pbWeather)
        next unless battle.pbRandom(100)<50
      end
      battle.pbShowAbilitySplash(battler)
      battler.item = battler.recycleItem
      battler.setRecycleItem(nil)
      battler.setInitialItem(battler.item) if !battler.initialItem
      battle.pbDisplay(_INTL("{1} harvested one {2}!",battler.pbThis,battler.itemName))
      battle.pbHideAbilitySplash(battler)
      battler.pbHeldItemTriggerCheck
    }
  )
  
  BattleHandlers::EORGainItemAbility.add(:PICKUP,
    proc { |ability,battler,battle|
      next if battler.item
      foundItem = nil; fromBattler = nil; use = 0
      battle.eachBattler do |b|
        next if b.index==battler.index
        next if b.effects[PBEffects::PickupUse]<=use
        foundItem   = b.effects[PBEffects::PickupItem]
        fromBattler = b
        use         = b.effects[PBEffects::PickupUse]
      end
      next if !foundItem
      battle.pbShowAbilitySplash(battler)
      battler.item = foundItem
      fromBattler.effects[PBEffects::PickupItem] = nil
      fromBattler.effects[PBEffects::PickupUse]  = 0
      fromBattler.setRecycleItem(nil) if fromBattler.recycleItem==foundItem
      if battle.wildBattle? && !battler.initialItem && fromBattler.initialItem==foundItem
        battler.setInitialItem(foundItem)
        fromBattler.setInitialItem(nil)
      end
      battle.pbDisplay(_INTL("{1} found one {2}!",battler.pbThis,battler.itemName))
      battle.pbHideAbilitySplash(battler)
      battler.pbHeldItemTriggerCheck
    }
  )