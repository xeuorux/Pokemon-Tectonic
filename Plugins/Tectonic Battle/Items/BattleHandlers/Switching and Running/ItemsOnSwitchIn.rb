BattleHandlers::ItemOnSwitchIn.add(:AIRBALLOON,
    proc { |item, battler, battle|
        battle.pbDisplay(_INTL("{1} floats in the air with its {2}!", battler.pbThis, getItemName(item)))
    }
)
