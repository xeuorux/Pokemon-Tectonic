BattleHandlers::ItemOnSwitchIn.add(:AIRBALLOON,
    proc { |item, battler, battle|
        battle.pbDisplay(_INTL("{1} floats in the air with its {2}!", battler.pbThis, getItemName(item)))
        battler.aiLearnsItem(item)
    }
)


BattleHandlers::ItemOnSwitchIn.add(:RUINEDTOWERKEY,
    proc { |item, battler, battle|
        if battle.wildBattle? && battler.opposes?
            battle.pbDisplay(_INTL("Oh? {1} is holding something!", battler.pbThis))
            battle.pbDisplay(_INTL("It seems to be a strange key!", battler.pbThis))
            battler.aiLearnsItem(item)
        end
    }
)


BattleHandlers::ItemOnSwitchIn.add(:ALLOYEDLUMP,
    proc { |item, battler, battle|
        if battle.wildBattle? && battler.opposes?
            battle.pbDisplay(_INTL("Oh? {1} is holding something!", battler.pbThis))
            battle.pbDisplay(_INTL("It seems to be a lump of metal!", battler.pbThis))
            battler.aiLearnsItem(item)
        end
    }
)

BattleHandlers::ItemOnSwitchIn.add(:LUMBERAXE,
    proc { |item, battler, battle|
        if battler.tryLowerStat(:SPEED, battler, item: item, ignoreContrary: true)
            battler.aiLearnsItem(item)
        end
    }
)

BattleHandlers::ItemOnSwitchIn.add(:FRAGILELOCKET,
    proc { |item, battler, battle|
        battle.pbDisplay(_INTL("{1} holds a {2} close!", battler.pbThis, getItemName(item)))
        battler.aiLearnsItem(item)
    }
)

# Just to reveal item
BattleHandlers::ItemOnSwitchIn.add(:CRYSTALVEIL,
    proc { |item, battler, battle|
        battler.aiLearnsItem(item)
    }
)

BattleHandlers::ItemOnSwitchIn.add(:MEMORYSET,
    proc { |item, battler, battle|
        battler.aiLearnsItem(item) if battler.isSpecies?(:SILVALLY) && battler.hasActiveAbility?(:RKSSYSTEM)
    }
)

BattleHandlers::ItemOnSwitchIn.add(:PRISMATICPLATE,
    proc { |item, battler, battle|
        battler.aiLearnsItem(item) if battler.isSpecies?(:ARCEUS)
    }
)