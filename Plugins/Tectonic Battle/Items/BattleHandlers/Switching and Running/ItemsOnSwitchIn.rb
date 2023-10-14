BattleHandlers::ItemOnSwitchIn.add(:AIRBALLOON,
    proc { |item, battler, battle|
        battle.pbDisplay(_INTL("{1} floats in the air with its {2}!", battler.pbThis, getItemName(item)))
    }
)


BattleHandlers::ItemOnSwitchIn.add(:RUINEDTOWERKEY,
    proc { |item, battler, battle|
        if battle.wildBattle? && battler.opposes?
            battle.pbDisplay(_INTL("Oh? {1} is holding something!", battler.pbThis))
            battle.pbDisplay(_INTL("It seems to be a strange key!", battler.pbThis))
        end
    }
)


BattleHandlers::ItemOnSwitchIn.add(:ALLOYEDLUMP,
    proc { |item, battler, battle|
        if battle.wildBattle? && battler.opposes?
            battle.pbDisplay(_INTL("Oh? {1} is holding something!", battler.pbThis))
            battle.pbDisplay(_INTL("It seems to be a lump of metal!", battler.pbThis))
        end
    }
)

BattleHandlers::ItemOnSwitchIn.add(:LUMBERAXE,
    proc { |item, battler, battle|
        battler.tryLowerStat(:SPEED, battler, item: item, ignoreContrary: true)
    }
)

BattleHandlers::ItemOnSwitchIn.add(:WATERBALLOON,
    proc { |item, battler, battle|
        battle.pbDisplay(_INTL("{1} dropped its {2}!", battler.pbThis, getItemName(item)))
        battler.consumeItem(item)
        battler.applyEffect(:AquaRing)
    }
)

BattleHandlers::ItemOnSwitchIn.add(:FRAGILELOCKET,
    proc { |item, battler, battle|
        battle.pbDisplay(_INTL("{1} holds a {2} close!", battler.pbThis, getItemName(item)))
    }
)
