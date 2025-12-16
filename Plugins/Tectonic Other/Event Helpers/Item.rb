#===============================================================================
# Picking up an item found on the ground
#===============================================================================
def pbItemBall(item, quantity = 1)
    item = GameData::Item.get(item)
    return false if !item || quantity < 1
    itemname = (quantity > 1) ? item.name_plural : item.name
    pocket = item.pocket
    move = item.move
    if $PokemonBag.pbStoreItem(item, quantity) # If item can be picked up
        meName = item.is_key_item? ? "Key item get" : "Item get"
        if item == :LEFTOVERS
            pbMessage(_INTL("\\me[{1}]You found some \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
        elsif quantity > 1
            pbMessage(_INTL("\\me[{1}]You found {2} \\c[1]{3}\\c[0]!\\wtnp[30]", meName, quantity, itemname))
        elsif itemname.starts_with_vowel?
            pbMessage(_INTL("\\me[{1}]You found an \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
        else
            pbMessage(_INTL("\\me[{1}]You found a \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
        end
        showItemDescription(item.id)
        pocketAlert(item)
        return true
    end
    # Can't add the item
    if item == :LEFTOVERS
        pbMessage(_INTL("You found some \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
    elsif quantity > 1
        pbMessage(_INTL("You found {1} \\c[1]{2}\\c[0]!\\wtnp[30]", quantity, itemname))
    elsif itemname.starts_with_vowel?
        pbMessage(_INTL("You found an \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
    else
        pbMessage(_INTL("You found a \\c[1]{1}\\c[0]!\\wtnp[30]", itemname))
    end
    pbMessage(_INTL("But your Bag is full..."))
    return false
end

def candyRock(level,multiplier = 2)
    if pbHasItem?(:SACCHARITEPICK)
        pbMessage(_INTL("\\i[SACCHARITEPICK]Using your pick-axe, you extract the saccharite."))
    else
        pbMessage(_INTL("A deposit of saccharite. You might be able to extract it with the proper tool."))
        command_end # Exit event processing
        return
    end
    receiveCandyBatch(level,multiplier)
end

def receiveCandyBatch(level,multiplier = 1)
    itemsGiven = candiesForLevel(level)
    for i in 0...itemsGiven.length/2
		pbReceiveItem(itemsGiven[i*2],itemsGiven[i*2 + 1] * multiplier)
	end
end

#===============================================================================
# Being given an item
#===============================================================================
def pbReceiveItem(item, quantity = 1)
    item = GameData::Item.get(item)
    return false if !item || quantity < 1
    raise _INTL("Player cannot receive a Super Item!") if item.super
    itemname = (quantity > 1) ? item.name_plural : item.name
    pocket = item.pocket
    move = item.move
    meName = item.is_key_item? ? "Key item get" : "Item get"
    if item.id == :LEFTOVERS
        pbMessage(_INTL("\\me[{1}]You obtained some \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    elsif quantity > 1
        pbMessage(_INTL("\\me[{1}]You obtained {2} \\c[1]{3}\\c[0]!\\wtnp[30]", meName, quantity, itemname))
    elsif itemname.starts_with_vowel?
        pbMessage(_INTL("\\me[{1}]You obtained an \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    else
        pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
    end
    showItemDescription(item.id)
    if $PokemonBag.pbStoreItem(item, quantity) # If item can be added
        pocketAlert(item)
        return true
    end
    return false # Can't add the item
end

def combineSigil
    if pbHasItem?(:SIGILLEFTHALF) && pbHasItem?(:SIGILRIGHTHALF)
        pbMessage(_INTL("You combine the {1} and the {2}.", getItemName(:SIGILLEFTHALF), getItemName(:SIGILRIGHTHALF)))
        pbReceiveItem(:CARNATIONSIGIL)
        $PokemonBag.pbDeleteItem(:SIGILLEFTHALF)
        $PokemonBag.pbDeleteItem(:SIGILRIGHTHALF)
    end
end

class PokemonGlobalMetadata
    attr_accessor :hadItemYet
end

def initializeItemHistory
    $PokemonGlobal.hadItemYet = {
        :POKEBALL => true,
        :GREATBALL => true,
        :ULTRABALL => true,
        :STATUSHEAL => true,
        :REVIVE => true,
        :MAXREVIVE => true,
        :FRESHWATER => true,
        :LEMONADE => true,
        :MOOMOOMILK => true,
        :MASTERBALL => true,
        :REPEL => true,
        :SUPERREPEL => true,
        :MAXREPEL => true,
    }
end

def showItemDescription(item)
    initializeItemHistory if $PokemonGlobal.hadItemYet.nil?
    unless $PokemonGlobal.hadItemYet[item]
        $PokemonGlobal.hadItemYet[item] = true
        if $Options.show_item_descriptions == 0
            showItemDescriptionMessage(item)
        end
    end
end

def showItemDescriptionMessage(item)
    itemData = GameData::Item.get(item)
    itemName = itemData.name
    itemDesc = itemData.description
    messageText = "<b>#{itemName}</b>\r\n#{itemDesc}"
    pbMessage(_INTL("\\cl\\l[5]\\op\\wu\\i[{1}]\\or{2}\\wt[30]", item, messageText))
end

def pbPickBerry(berry, qty = 1)
    interp = pbMapInterpreter
    thisEvent = interp.get_character(0)
    berryData = interp.getVariable
    berry = GameData::Item.get(berry)
    itemname = (qty > 1) ? berry.name_plural : berry.name
    unless $PokemonBag.pbCanStore?(berry, qty)
        pbMessage(_INTL("Too bad...\nThe Bag is full..."))
        return
    end
    $PokemonBag.pbStoreItem(berry, qty)
    if qty > 1
        pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0].\\wtnp[20]", qty, itemname))
    else
        pbMessage(_INTL("\\me[Berry get]You picked the \\c[1]{1}\\c[0].\\wtnp[20]", itemname))
    end
    showItemDescription(berry.id)
    pocket = berry.pocket
    pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
       $Trainer.name, itemname, pocket, PokemonBag.pocketNames[pocket]))
    if Settings::NEW_BERRY_PLANTS
        pbMessage(_INTL("The berry plant withered away."))
        berryData = [0, nil, 0, 0, 0, 0, 0, 0]
    else
        pbMessage(_INTL("The berry plant withered away."))
        berryData = [0, nil, false, 0, 0, 0]
    end
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id, "A", true)
end