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
        PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
        battle.pbCommonAnimation("UseItem", battler) unless forced
        if forced
            battle.pbDisplay(_INTL("{1}'s status returned to normal!", battler.pbThis))
        else
            battle.pbDisplay(_INTL("{1} returned its status to normal using its {2}!",
               battler.pbThis, itemName))
        end
        next true
    }
)
