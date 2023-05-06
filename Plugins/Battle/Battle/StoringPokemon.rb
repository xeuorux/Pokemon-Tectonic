def pbStorePokemon(pkmn)
    if pbBoxesFull?
        pbMessage(_INTL("There's no more room for Pokémon!\1"))
        pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
        return
    end
    pkmn.record_first_moves
    if $Trainer.party_full?
        storingPokemon = pkmn
        if pbConfirmMessageSerious(_INTL("Would you like to add {1} to your party?", pkmn.name))
            pbMessage(_INTL("Choose which Pokemon will be sent back to the PC."))
            # if Y, select pokemon to store instead
            pbChoosePokemon(1, 3)
            chosen = $game_variables[1]
            # Didn't cancel
            if chosen != -1
                storingPokemon = $Trainer.party[chosen]

                promptToTakeItems(storingPokemon)

                $Trainer.party[chosen] = pkmn

                refreshFollow
            end
        end
        pbStorePokemonInPC(storingPokemon)
    else
        $Trainer.party[$Trainer.party.length] = pkmn
    end
end

def promptToTakeItems(pkmn)
    if pkmn.hasItem?
        if pkmn.hasMultipleItems?
            queryMessage = _INTL("{1} is holding multiple items. Take them before transferring?",
                pkmn.name)
        else
            queryMessage = _INTL("{1} is holding an {2}. Would you like to take it before transferring?",
                pkmn.name, getItemName(pkmn.firstItem))
        end
        
        pbTakeItemsFromPokemon(pkmn) if pbConfirmMessageSerious(queryMessage)
    end
end

def pbStorePokemonInPC(pkmn)
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pkmn)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    if storedbox != oldcurbox
        pbMessage(_INTL("Box \"{1}\" on the Pokémon Storage PC was full.\1", curboxname))
        pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pkmn.name, boxname))
    else
        pbMessage(_INTL("{1} was transferred to the Pokémon Storage PC.\1", pkmn.name))
        pbMessage(_INTL("It was stored in box \"{1}.\"", boxname))
    end
end

def pbNicknameAndStore(pkmn)
    if pbBoxesFull?
        pbMessage(_INTL("There's no more room for Pokémon!\1"))
        pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
        return
    end
    $Trainer.pokedex.set_seen(pkmn.species)
    $Trainer.pokedex.set_owned(pkmn.species)

    # Let the player know info about the individual pokemon they caught
    pbMessage(_INTL("You check {1}, and discover that its ability is {2}!", pkmn.name, pkmn.ability.name))

    pkmn.items.each do |item|
        pbMessage(_INTL("The {1} is holding an {2}!", pkmn.name, getItemName(item)))
    end

    # Increase the caught count for the global metadata
    incrementDexNavCounts(false) if defined?(incrementDexNavCounts)

    if !defined?($PokemonSystem.nicknaming_prompt) || $PokemonSystem.nicknaming_prompt == 0
        pbNickname(pkmn)
    end

    pbStorePokemon(pkmn)
end

class StorageSystemPC
    def name
        return _INTL("Pokémon Storage PC")
    end
end

class TrainerPC
    def name
        return _INTL("Item Storage PC")
    end
end
