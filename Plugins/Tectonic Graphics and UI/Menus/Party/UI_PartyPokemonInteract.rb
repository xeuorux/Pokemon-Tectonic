class TilingCardsPokemonMenu_Scene < TilingCardsMenu_Scene
    attr_reader :party

    def cursorFileLocation
        return addLanguageSuffix("Graphics/Pictures/Party/cursor_pokemon")
    end

    def tileFileLocation
        path = "Graphics/Pictures/Party/pokemon_menu_tile"
        path += "_dark" if darkMode?
        return _INTL(path)
    end

    def backgroundFadeFileLocation
        return addLanguageSuffix("Graphics/Pictures/Party/background_fade")
    end

    def initialize(pkmnid, party, partyScene)
        super()
        @pkmnid = pkmnid
        @pkmn = party[pkmnid]
        @party = party
        @partyScene = partyScene
        @buttonRowHeight = 68
    end

    def initializeMenuButtons
        super
        canEditTeam = teamEditingAllowed?

        @cardButtons = {
                  :SUMMARY => {
                      :label => _INTL("Summary"),
                      :press_proc => proc do |_scene|
                          @partyScene.pbSummary(@pkmnid)
                      end,
                  },
                  :ITEM => {
                      :label => _INTL("Item"),
                      :active_proc => proc do
                          canEditTeam
                      end,
                      :press_proc => proc do |_scene|
                          next true if itemCommandMenu
                      end,
                  },
                  :SWITCH => {
                      :label => inPokestate? ? _INTL("Set Down") : _INTL("Switch"),
                      :active_proc => proc do
                          inPokestate? ? @party.length > 1 : canEditTeam
                      end,
                      :press_proc => proc do |_scene|
                          if 	inPokestate?
                              if $PokEstate.setDownIntoEstate(@pkmn)
                                  @party[@pkmnid] = nil
                                  @party.compact!
                                  @partyScene.pbHardRefresh
                                  next true
                              end
                          else
                              hideTileMenu
                              pbSetHelpText(_INTL("Move to where?"))
                              newpkmnid = @partyScene.pbChoosePokemon(true)
                              pbSwitch(newpkmnid, @pkmnid) if newpkmnid >= 0 && newpkmnid != @pkmnid
                              next true
                          end
                      end,
                  },
                  :MODIFY => {
                      :label => _INTL("Modify"),
                      :active_proc => proc do
                          canEditTeam && !@pkmn.egg?
                      end,
                      :press_proc => proc do |_scene|
                          next true if modifyCommandMenu
                      end,
                  },
                  :MASTERDEX => {
                      :label => _INTL("MasterDex"),
                      :active_proc => proc do
                          $Trainer.has_pokedex
                      end,
                      :press_proc => proc do |_scene|
                          openSingleDexScreen(@pkmn)
                      end,
                  },
                  :SEND_PC => {
                      :label => _INTL("Send to PC"),
                      :active_proc => proc do
                          @party.length > 1 && ($Trainer.able_pokemon_count > 1 || !@pkmn.able?)
                      end,
                      :press_proc => proc do |_scene|
                          if pbConfirm(_INTL("Are you sure you'd like to send back #{@pkmn.name}?"))
                              promptToTakeItems(@pkmn)
                              pbStorePokemonInPC(@pkmn)
                              @party[@pkmnid] = nil
                              @party.compact!
                              pbSEPlay("PC close")
                              @partyScene.pbHardRefresh
                              next true
                          end
                      end,
                  },
                }

        if $DEBUG
            @yOffset -= 16
            @cardButtons[:DEBUG] = {
                :label => _INTL("Debug"),
                :press_proc => proc do |_scene|
                    pbPokemonDebug(@pkmn, @pkmnid)
                    next true
                end,
            }
        end
    end

    def inPokestate?
        return defined?($PokEstate.setDownIntoEstate) && $PokEstate.isInEstate?
    end

    def itemCommandMenu
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItems = -1
        cmdTakeOneItem = -1
        cmdSwapItemOrder = -1
        cmdMoveItem = -1
        cmdSetItemType = -1
        # Build the commands
        itemcommands[cmdSetItemType = itemcommands.length] = _INTL("Set Item Type") if @pkmn.hasTypeSetterItem?
        itemcommands[cmdGiveItem = itemcommands.length] = _INTL("Give")
        if @pkmn.hasItem?
            if @pkmn.hasMultipleItems?
                itemcommands[cmdTakeOneItem = itemcommands.length] = _INTL("Take One")
                itemcommands[cmdTakeItems = itemcommands.length] = _INTL("Take All")
                if @pkmn.itemCount == 2
                    itemcommands[cmdSwapItemOrder = itemcommands.length] =
                        _INTL("Swap Order")
                end
            else
                itemcommands[cmdTakeItems = itemcommands.length] = _INTL("Take")
                itemcommands[cmdMoveItem = itemcommands.length] = _INTL("Move")
            end
        end
        itemcommands[cmdUseItem = itemcommands.length] = _INTL("Use")
        itemcommands[itemcommands.length] = _INTL("Cancel")
        command = @partyScene.pbShowCommands(_INTL("Do what with an item?"), itemcommands)
        if cmdUseItem >= 0 && command == cmdUseItem # Use
            item = selectItemForUseOnPokemon($PokemonBag, @pkmn) do
                @partyScene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            end
            if item
                used = pbUseItemOnPokemon(item, @pkmn, self)
                pbRefreshSingle(@pkmnid)
                return true if used
            end
        elsif cmdGiveItem >= 0 && command == cmdGiveItem # Give
            item = @partyScene.pbChooseItem($PokemonBag) do
                pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            end
            pbRefreshSingle(@pkmnid) if item && pbGiveItemToPokemon(item, @pkmn, self)
        elsif cmdTakeItems >= 0 && command == cmdTakeItems # Take/ Take All
            pbRefreshSingle(@pkmnid) if pbTakeItemsFromPokemon(@pkmn) > 0
        elsif cmdTakeOneItem >= 0 && command == cmdTakeOneItem # Take One
            pbRefreshSingle(@pkmnid) if pbTakeOneItemFromPokemon(@pkmn)
        elsif cmdSwapItemOrder >= 0 && command == cmdSwapItemOrder # Swap Item Order
            @pkmn.setItems(@pkmn.items.reverse)
            firstItemName = getItemName(@pkmn.items[0])
            secondItemName = getItemName(@pkmn.items[1])
            pbDisplay(_INTL("{1}'s {2} and {3} swapped order.", @pkmn.name, firstItemName, secondItemName))
            pbRefreshSingle(@pkmnid)
        elsif cmdMoveItem >= 0 && command == cmdMoveItem # Move
            hideTileMenu
            item = @pkmn.firstItem
            @partyScene.pbSetHelpText(_INTL("Move {1} to where?", getItemName(item)))
            loop do
                @partyScene.pbPreSelect(@pkmnid)
                newpkmnid = @partyScene.pbChoosePokemon(true, @pkmnid)
                break if newpkmnid < 0
                newpkmn = @party[newpkmnid]
                break if newpkmnid == @pkmnid
                next unless pbGiveItemToPokemon(item, newpkmn, self, false)
                @pkmn.removeItem(item)
                @partyScene.pbClearSwitching
                pbRefresh
                break
            end
            showTileMenu
        elsif cmdSetItemType >= 0 && command == cmdSetItemType
            setItemType
        end
        return false
    end

    def setItemType
        typesArray = []
        typeCommands = []
        GameData::Type.each do |typeData|
            next if typeData.pseudo_type
            typesArray.push(typeData.id)
            typeCommands.push(typeData.name)
        end
        typeCommands.push("Cancel")
        existingIndex = typesArray.find_index(@pkmn.itemTypeChosen)
        chosenNumber = @partyScene.pbShowCommands(_INTL("What type should #{@pkmn.name} become?"), typeCommands,
existingIndex)
        if chosenNumber > -1 && chosenNumber < typeCommands.length - 1
            typeSettingItem = @pkmn.hasTypeSetterItem?
            pbDisplay(_INTL("#{@pkmn.name} changed its #{getItemName(typeSettingItem)} to #{typeCommands[chosenNumber]}-type!"))
            @pkmn.itemTypeChosen = typesArray[chosenNumber]
        end
    end

    def modifyCommandMenu
        commands   = []
        cmdRename  = -1
        cmdEvolve  = -1
        cmdStyle = -1

        # Build the commands
        commands[cmdRename = commands.length]       = _INTL("Rename")
        commands[cmdStyle = commands.length]        = _INTL("Set Style") if pbHasItem?(:STYLINGKIT)
        newspecies = @pkmn.check_evolution_on_level_up(false)
        commands[cmdEvolve = commands.length]       = _INTL("Evolve") if newspecies
        commands[commands.length]                   = _INTL("Cancel")

        modifyCommand = @partyScene.pbShowCommands(_INTL("Do what with {1}?", @pkmn.name), commands)
        if cmdRename >= 0 && modifyCommand == cmdRename
            currentName = @pkmn.name
            pbTextEntry("#{currentName}'s nickname?", 0, Pokemon::MAX_NAME_SIZE, 5)
            if pbGet(5) == "" || pbGet(5) == currentName
                @pkmn.name = currentName
            else
                @pkmn.name = pbGet(5)
            end
        elsif cmdEvolve >= 0 && modifyCommand == cmdEvolve
            newspecies = @pkmn.check_evolution_on_level_up(true)
            return false if newspecies.nil?
            pbFadeOutInWithMusic do
                evo = PokemonEvolutionScene.new
                evo.pbStartScreen(@pkmn, newspecies)
                evo.pbEvolution
                evo.pbEndScreen
                @partyScene.pbRefresh
            end
            return true
        elsif cmdStyle >= 0 && modifyCommand == cmdStyle
            pbStyleValueScreen(@pkmn)
        end

        return false
    end

    def pbSwitch(oldid, newid)
        if oldid != newid
            @partyScene.pbSwitchBegin(oldid, newid)
            tmp = @party[oldid]
            @party[oldid] = @party[newid]
            @party[newid] = tmp
            @partyScene.pbSwitchEnd(oldid, newid)
        end
    end

    # Interface methods
    def pbUpdate
        @partyScene.update
    end

    def pbHardRefresh
        @partyScene.pbHardRefresh
    end

    def pbRefresh
        @partyScene.pbRefresh
    end

    def pbRefreshSingle(i)
        @partyScene.pbRefreshSingle(i)
    end

    def pbDisplay(string)
        @partyScene.pbDisplay(string)
    end

    def pbConfirm(text)
        return @partyScene.pbDisplayConfirm(text)
    end

    def pbShowCommands(helptext, commands, index = 0)
        return @partyScene.pbShowCommands(helptext, commands, index)
    end

    def pbRefreshAnnotations(ableProc) # For after using an evolution stone
        return unless @partyScene.pbHasAnnotations?
        annot = []
        for pkmn in @party
            elig = ableProc.call(pkmn)
            annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
        end
        @partyScene.pbAnnotate(annot)
    end

    def pbClearAnnotations
        @partyScene.pbAnnotate(nil)
    end

    def pbSetHelpText(helptext)
        @partyScene.pbSetHelpText(helptext)
    end

    def pbChoosePokemon(helptext=nil)
        @partyScene.pbSetHelpText(helptext) if helptext
        return @partyScene.pbChoosePokemon
      end

    def supportsFusion?; return true; end
end

class TilingCardsPokemonMenu < TilingCardsMenu_Screen
end