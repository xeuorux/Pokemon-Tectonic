BattleHandlers::EndOfMoveItem.add(:LEPPABERRY,
    proc { |item, battler, battle, forced|
        next false if !forced && !battler.canConsumeBerry?
        found = []
        battler.pokemon.moves.each_with_index do |m, i|
            next if m.total_pp <= 0 || m.pp == m.total_pp
            next if !forced && m.pp > 0
            found.push(i)
        end
        next false if found.length == 0
        itemName = GameData::Item.get(item).name
        PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
        battle.pbCommonAnimation("Nom", battler) unless forced
        choice = found[battle.pbRandom(found.length)]
        pkmnMove = battler.pokemon.moves[choice]
        pkmnMove.pp += 10
        pkmnMove.pp = pkmnMove.total_pp if pkmnMove.pp > pkmnMove.total_pp
        battler.moves[choice].pp = pkmnMove.pp
        moveName = pkmnMove.name
        if forced
            battle.pbDisplay(_INTL("{1} restored its {2}'s PP.", battler.pbThis, moveName))
        else
            battle.pbDisplay(_INTL("{1}'s {2} restored its {3}'s PP!", battler.pbThis, itemName, moveName))
        end
        next true
    }
)
