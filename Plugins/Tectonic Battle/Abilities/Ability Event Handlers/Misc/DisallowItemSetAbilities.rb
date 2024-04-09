# For multi-item abilities that restrict what items are allowed to be used in multiple

BattleHandlers::DisallowItemSetAbility.add(:ALLTHATGLITTERS,
    proc { |ability, pokemon, itemSet, showMessages|
        allGems = true
        itemSet.each do |item|
            next if GameData::Item.get(item).is_gem?
            allGems = false
            break
        end
        unless allGems
            pbMessage(_INTL("For #{pokemon.name} to have two items, both must be Gems!")) if showMessages
            next true
        end
        next false
    }
)

BattleHandlers::DisallowItemSetAbility.add(:BERRYBUNCH,
    proc { |ability, pokemon, itemSet, showMessages|
        allBerries = true
        itemSet.each do |item|
            next if GameData::Item.get(item).is_berry?
            allBerries = false
            break
        end
        unless allBerries
            pbMessage(_INTL("For #{pokemon.name} to have two items, both must be Berries!")) if showMessages
            next true
        end
        next false
    }
)

BattleHandlers::DisallowItemSetAbility.add(:HERBALIST,
    proc { |ability, pokemon, itemSet, showMessages|
        allHerbs = true
        itemSet.each do |item|
            next if GameData::Item.get(item).is_herb?
            allHerbs = false
            break
        end
        unless allHerbs
            pbMessage(_INTL("For #{pokemon.name} to have two items, both must be Herbs!")) if showMessages
            next true
        end
        next false
    }
)

BattleHandlers::DisallowItemSetAbility.add(:FASHIONABLE,
    proc { |ability, pokemon, itemSet, showMessages|
        clothingCount = 0
        itemSet.each do |item|
            next unless GameData::Item.get(item).is_clothing?
            clothingCount += 1
        end
        if clothingCount == 0
            pbMessage(_INTL("For #{pokemon.name} to have two items, at least one must be Clothing!")) if showMessages
            next true
        end
        if clothingCount > 1
            pbMessage(_INTL("For #{pokemon.name} to have two items, only one can be Clothing!")) if showMessages
            next true
        end
        next false
    }
)