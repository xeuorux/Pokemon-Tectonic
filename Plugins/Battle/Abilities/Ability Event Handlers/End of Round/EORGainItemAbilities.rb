BattleHandlers::EORGainItemAbility.add(:HARVEST,
    proc { |ability, battler, battle|
        next unless battler.recyclableItem
        next unless GameData::Item.get(battler.recyclableItem).is_berry?
        next if battler.hasItem?(battler.recyclableItem)
        next if !battle.sunny? && !(battle.pbRandom(100) < 50)
        recyclingMsg = _INTL("{1} harvested one {2}!", battler.pbThis, getItemName(battler.recyclableItem))
        battler.recycleItem(recyclingMsg: recyclingMsg, ability: ability)
    }
)

BattleHandlers::EORGainItemAbility.add(:LARDER,
    proc { |ability, battler, battle|
        next unless battler.recyclableItem
        next unless GameData::Item.get(battler.recyclableItem).is_berry?
        next if battler.hasItem?(battler.recyclableItem)
        recyclingMsg = _INTL("{1} withdrew another {2}!", battler.pbThis, getItemName(battler.recyclableItem))
        battler.recycleItem(recyclingMsg: recyclingMsg, ability: ability)
    }
)

BattleHandlers::EORGainItemAbility.add(:GOURMAND,
    proc { |ability, battler, battle|
        itemsCanAdd = []
        PINCH_BERRIES.each do |pinch|
            next if GameData::Item.get(pinch).super
            next unless battler.canAddItem?(pinch)
            itemsCanAdd.push(pinch) 
        end
        next if itemsCanAdd.length == 0
        battle.pbShowAbilitySplash(battler, ability)
        itemToAdd = itemsCanAdd.sample
        battler.giveItem(itemToAdd)
        battle.pbDisplay(_INTL("{1} was delivered one {2}!", battler.pbThis, getItemName(itemToAdd)))
        battle.pbHideAbilitySplash(battler)
        battler.pbHeldItemTriggerCheck
    }
)