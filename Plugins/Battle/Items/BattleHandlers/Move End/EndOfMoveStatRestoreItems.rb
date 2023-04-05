BattleHandlers::EndOfMoveStatRestoreItem.add(:WHITEHERB,
    proc { |item, battler, battle, forced|
        reducedStats = false
        GameData::Stat.each_battle do |s|
            next if battler.stages[s.id] >= 0
            battler.stages[s.id] = 0
            reducedStats = true
        end
        next false unless reducedStats
        itemName = GameData::Item.get(item).name
        battle.pbCommonAnimation("UseItem", battler) unless forced
        if forced
            battle.pbDisplay(_INTL("{1}'s stat changes returned to normal!", battler.pbThis))
        else
            battle.pbDisplay(_INTL("{1} returned its stat changes to normal using its {2}!",
               battler.pbThis, itemName))
        end
        next true
    }
)

BattleHandlers::EndOfMoveStatRestoreItem.add(:BLACKHERB,
    proc { |item, battler, battle, forced|
        reducedStats = false
        statDown = []
        GameData::Stat.each_battle do |s|
            next if battler.stages[s.id] >= 0
            statDown.push(s.id)
            statDown.push(battler.stages[s.id])
            reducedStats = true
        end
        next false unless reducedStats
        itemName = GameData::Item.get(item).name
        battle.pbCommonAnimation("UseItem", battler) unless forced
        if forced
            battle.pbDisplay(_INTL("{1}'s stat changes were weaponized!", battler.pbThis))
        else
            battle.pbDisplay(_INTL("{1} weaponized its stat changes using its {2}!",
               battler.pbThis, itemName))
        end
        battler.eachOpposing do |oppBattler|
            oppBattler.pbLowerMultipleStatStages(statDown,battler,item: item)
        end
        next true
    }
)
