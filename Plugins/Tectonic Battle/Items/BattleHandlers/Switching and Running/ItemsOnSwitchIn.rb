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