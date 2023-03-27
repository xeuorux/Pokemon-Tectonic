BattleHandlers::EORGainItemAbility.add(:HARVEST,
    proc { |ability, battler, battle|
        next if battler.baseItem
        next if !battler.recycleItem || !GameData::Item.get(battler.recycleItem).is_berry?
        next if !battle.sunny? && !(battle.pbRandom(100) < 50)
        battle.pbShowAbilitySplash(battler, ability)
        battler.item = battler.recycleItem
        battler.setRecycleItem(nil)
        battler.setInitialItem(battler.item) unless battler.initialItem
        battle.pbDisplay(_INTL("{1} harvested one {2}!", battler.pbThis, getItemName(battler.baseItem)))
        battle.pbHideAbilitySplash(battler)
        battler.pbHeldItemTriggerCheck
    }
)

BattleHandlers::EORGainItemAbility.add(:LARDER,
    proc { |ability, battler, battle|
        next if battler.baseItem
        next if !battler.recycleItem || !GameData::Item.get(battler.recycleItem).is_berry?
        battle.pbShowAbilitySplash(battler, ability)
        battler.item = battler.recycleItem
        battler.setRecycleItem(nil)
        battler.setInitialItem(battler.item) unless battler.initialItem
        battle.pbDisplay(_INTL("{1} withdrew one {2}!", battler.pbThis, getItemName(battler.baseItem)))
        battle.pbHideAbilitySplash(battler)
        battler.pbHeldItemTriggerCheck
    }
)

BattleHandlers::EORGainItemAbility.add(:PICKUP,
  proc { |ability, battler, battle|
      next if battler.baseItem
      foundItem = nil
      fromBattler = nil
      use = 0
      battle.eachBattler do |b|
          next if b.index == battler.index
          next if b.effects[:PickupUse] <= use
          foundItem   = b.effects[:PickupItem]
          fromBattler = b
          use         = b.effects[:PickupUse]
      end
      next unless foundItem
      battle.pbShowAbilitySplash(battler, ability)
      battler.item = foundItem
      fromBattler.disableEffect(:PickupItem)
      fromBattler.setRecycleItem(nil) if fromBattler.recycleItem == foundItem
      if battle.wildBattle? && !battler.initialItem && fromBattler.initialItem == foundItem
          battler.setInitialItem(foundItem)
          fromBattler.setInitialItem(nil)
      end
      battle.pbDisplay(_INTL("{1} found one {2}!", battler.pbThis, getItemName(battler.baseItem)))
      battle.pbHideAbilitySplash(battler)
      battler.pbHeldItemTriggerCheck
  }
)

BattleHandlers::EORGainItemAbility.add(:GOURMAND,
    proc { |ability, battler, battle|
        next if battler.baseItem
        battle.pbShowAbilitySplash(battler, ability)
        battler.item =
            %i[
                ORANBERRY GANLONBERRY LANSATBERRY APICOTBERRY LIECHIBERRY
                PETAYABERRY SALACBERRY STARFBERRY MICLEBERRY SITREONBERRY
            ].sample
        battle.pbDisplay(_INTL("{1} was delivered one {2}!", battler.pbThis, getItemName(battler.baseItem)))
        battle.pbHideAbilitySplash(battler)
        battler.pbHeldItemTriggerCheck
    }
)