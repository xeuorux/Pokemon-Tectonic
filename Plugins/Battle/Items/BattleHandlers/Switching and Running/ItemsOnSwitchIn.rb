BattleHandlers::ItemOnSwitchIn.add(:AIRBALLOON,
    proc { |_item, battler, battle|
        battle.pbDisplay(_INTL("{1} floats in the air with its {2}!", battler.pbThis, battler.itemName))
    }
)
