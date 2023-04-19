#===============================================================================
# Give an item to a Pokémon to hold from the bag, swapping out existing items if needed
#===============================================================================
def pbGiveItemToPokemon(item,pkmn,scene,fromBag=true)
    newitemname = GameData::Item.get(item).name

    if pkmn.egg?
        scene.pbDisplay(_INTL("Eggs can't hold items."))
        return false
    end

    # If they don't have an item, just give them it
    if !pkmn.hasItem?
        giveItem = true
    # If the pokemon can have multiple items due to an ability, check for legality thereof
    elsif pkmn.canHaveMultipleItems?
        if pkmn.canHaveItem?(item, true)
            giveItem = true
        elsif scene.pbConfirm(_INTL("Swap its items with the #{newitemname}?"))
            pbTakeItemsFromPokemon(pkmn)
            giveItem = !pkmn.hasItem? # If somehow one of the items couldn't be taken
        end
    # Otherwise, allow the player to swap the one held item for another
    else
        alreadyHoldingAlert(pkmn,pkmn.firstItem,scene)
        if scene.pbConfirm(_INTL("Would you like to switch the two items?"))
            $PokemonBag.pbDeleteItem(item) if fromBag
            if $PokemonBag.pbStoreItem(pkmn.firstItem)
                scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.",getItemName(pkmn.firstItem),pkmn.name,newitemname))
                pocketAlert(pkmn.firstItem)
                pkmn.setItems(item)
                return true
            else
                if fromBag && !$PokemonBag.pbStoreItem(item)
                    raise _INTL("Could't re-store deleted item in Bag somehow")
                end
                scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
                return false
            end
        end
    end

    if giveItem
        $PokemonBag.pbDeleteItem(item) if fromBag
        pkmn.giveItem(item)
        scene&.pbDisplay(_INTL("{1} is now holding the {2}.",pkmn.name,getItemName(item)))
    end

    return giveItem
end

def pocketAlert(item)
    item = GameData::Item.get(item)
    pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",
        item.real_name,item.pocket,PokemonBag.pocketNames()[item.pocket]))
end

def alreadyHoldingAlert(pkmn,itemID,scene)
    itemName = getItemName(itemID)
    if itemID == :LEFTOVERS
        scene.pbDisplay(_INTL("{1} is already holding some {2}.",pkmn.name,itemName))
    elsif itemName.starts_with_vowel?
        scene.pbDisplay(_INTL("{1} is already holding an {2}.",pkmn.name,itemName))
    else
        scene.pbDisplay(_INTL("{1} is already holding a {2}.",pkmn.name,itemName))
    end
end

def pbTakeOneItemFromPokemon(pkmn)
    if pkmn.items.empty?
        pbMessage(_INTL("{1} isn't holding anything.", pkmn.name))
        return false
    end

    commands = []
    pkmn.items.each do |item|
        commands.push(getItemName(item))
    end
    
    commands[commandCancel = commands.length] = _INTL("Cancel")

    selection = pbMessage(_INTL("Take which item?"),commands,commandCancel+1)

    return false if selection == commandCancel

    selectedItem = pkmn.items[selection]
    if !$PokemonBag.pbCanStore?(selectedItem)
        pbMessage(_INTL("The Bag is full. The Pokémon's {1} could not be removed.",getItemName(item)))
        return false
    else
        $PokemonBag.pbStoreItem(selectedItem)
        pbMessage(_INTL("Received the {1} from {2}.", getItemName(selectedItem), pkmn.name))
        pkmn.removeItem(selectedItem)
        return true
    end
end

def pbTakeItemsFromPokemon(pkmn)
    if pkmn.items.empty?
        pbMessage(_INTL("{1} isn't holding anything.", pkmn.name))
        return 0
    end

    itemsTaken = 0
    itemsToRemove = []
    pkmn.items.each do |item|
        if !$PokemonBag.pbCanStore?(item)
            pbMessage(_INTL("The Bag is full. The Pokémon's {1} could not be removed.",getItemName(item)))
        else
            $PokemonBag.pbStoreItem(item)
            pbMessage(_INTL("Received the {1} from {2}.", getItemName(item), pkmn.name))
            itemsToRemove.push(item)
            itemsTaken += 1
        end
    end
    itemsToRemove.each do |itemToRemove|
        pkmn.removeItem(itemToRemove)
    end
    return itemsTaken
end