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

                if storingPokemon.hasItem?
                    itemName = GameData::Item.get(storingPokemon.item).real_name
                    if pbConfirmMessageSerious(_INTL("{1} is holding an {2}. Would you like to take it before transferring?",
          storingPokemon.name, itemName))
                        pbTakeItemFromPokemon(storingPokemon)
                    end
                end

                $Trainer.party[chosen] = pkmn

                refreshFollow
            end
        end
        pbStorePokemonInPC(storingPokemon)
    else
        $Trainer.party[$Trainer.party.length] = pkmn
    end
end

def pbTakeItemFromPokemon(pkmn, _scene = nil)
    ret = false
    if !pkmn.hasItem?
        pbMessage(_INTL("{1} isn't holding anything.", pkmn.name))
    elsif !$PokemonBag.pbCanStore?(pkmn.item)
        pbMessage(_INTL("The Bag is full. The Pokémon's item could not be removed."))
    elsif pkmn.mail
        if pbConfirmMessage(_INTL("Save the removed mail in your PC?"))
            if !pbMoveToMailbox(pkmn)
                pbMessage(_INTL("Your PC's Mailbox is full."))
            else
                pbMessage(_INTL("The mail was saved in your PC."))
                pkmn.item = nil
                ret = true
            end
        elsif pbConfirmMessage(_INTL("If the mail is removed, its message will be lost. OK?"))
            $PokemonBag.pbStoreItem(pkmn.item)
            pbMessage(_INTL("Received the {1} from {2}.", pkmn.item.name, pkmn.name))
            pkmn.item = nil
            pkmn.mail = nil
            ret = true
        end
    else
        $PokemonBag.pbStoreItem(pkmn.item)
        pbMessage(_INTL("Received the {1} from {2}.", pkmn.item.name, pkmn.name))
        pkmn.item = nil
        ret = true
    end
    return ret
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

    pbMessage(_INTL("The {1} is holding an {2}!", pkmn.name, pkmn.item.name)) if pkmn.hasItem?

    # Increase the caught count for the global metadata
    incrementDexNavCounts(false) if defined?(incrementDexNavCounts)

    if !pkmn.shadowPokemon? && (!defined?($PokemonSystem.nicknaming_prompt) || $PokemonSystem.nicknaming_prompt == 0)
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
