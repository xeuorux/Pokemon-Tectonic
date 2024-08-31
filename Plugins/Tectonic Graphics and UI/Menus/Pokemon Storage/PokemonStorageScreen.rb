#===============================================================================
# Pokémon storage mechanics
#===============================================================================
class PokemonStorageScreen
    attr_reader :scene
    attr_reader :storage
    attr_accessor :heldpkmn

    def initialize(scene, storage)
        @scene = scene
        @storage = storage
        @pbHeldPokemon = nil
    end

    def pbStartScreen(command,ableProc = nil)
        @heldpkmn = nil
        if command == 0 || command == 4 # Organise or Select
            @scene.pbStartBox(self, command, ableProc)
            loop do
                selected = @scene.pbSelectBox(@storage.party)
                if selected.nil?
                    if pbHeldPokemon
                        pbDisplay(_INTL("You're holding a Pokémon!"))
                        next
                    end
                    next if command != 4 && pbConfirm(_INTL("Continue Box operations?"))
                    break
                elsif selected[0] == -3   # Close box
                    if pbHeldPokemon
                        pbDisplay(_INTL("You're holding a Pokémon!"))
                        next
                    end
                    if command == 4 || pbConfirm(_INTL("Exit from the Box?"))
                        pbSEPlay("PC close")
                        break
                    end
                    next
                elsif selected[0] == -4   # Box name
                    if pbBoxCommands(command == 4)
                        @scene.pbCloseBox
                        return true
                    end
                else
                    pokemon = @storage[selected[0], selected[1]]
                    if pokemon && command == 4
                        selectedBox = selected[0]
                        if selectedBox > -1 && @storage[selectedBox].isDonationBox?
                            pbPlayBuzzerSE
                            pbDisplay(_INTL("You cannot select a donated Pokémon!"))
                            next
                        elsif ableProc.nil? || ableProc.call(pokemon)
                            @scene.pbCloseBox
                            return pokemon,selected[0],selected[1]
                        else
                            pbPlayBuzzerSE
                            pbDisplay(_INTL("That Pokémon is not a valid choice!"))
                            next
                        end
                    end
                    heldpoke = pbHeldPokemon
                    next if !pokemon && !heldpoke
                    if @scene.quickswap
                        if @heldpkmn
                            pokemon ? pbSwap(selected) : pbPlace(selected)
                        else
                            pbHold(selected)
                        end
                    else
                        if heldpoke
                            selectedPokemon = heldpoke
                        elsif pokemon
                            selectedPokemon = pokemon
                        end
                        interactionScene = TilingCardsStorageInteractionMenu_Scene.new(command,selectedPokemon,selected,heldpoke,self,@scene)
                        interactionScreen = TilingCardsStorageInteractionMenu.new(interactionScene)
                        interactionScreen.pbStartPokemonMenu
                    end
                end
            end
            @scene.pbCloseBox
        elsif command == 1 # Withdraw
            @scene.pbStartBox(self, command)
            loop do
                selected = @scene.pbSelectBox(@storage.party)
                if selected.nil?
                    next if command == 4 || pbConfirm(_INTL("Continue Box operations?"))
                    break
                else
                    case selected[0]
                    when -2   # Party Pokémon
                        pbDisplay(_INTL("Which one will you take?"))
                        next
                    when -3   # Close box
                        if pbConfirm(_INTL("Exit from the Box?"))
                            pbSEPlay("PC close")
                            break
                        end
                        next
                    when -4   # Box name
                        if pbBoxCommands
                            @scene.pbCloseBox
                            return true
                        end
                    end
                    pokemon = @storage[selected[0], selected[1]]
                    next unless pokemon

                    interactionScene = TilingCardsStorageInteractionMenu_Scene.new(command,pokemon,selected,nil,self,@scene)
                    interactionScreen = TilingCardsStorageInteractionMenu.new(interactionScene)
                    interactionScreen.pbStartPokemonMenu
                end
            end
            @scene.pbCloseBox
        elsif command == 2 # Deposit
            @scene.pbStartBox(self, command)
            loop do
                selected = @scene.pbSelectParty(@storage.party)
                if selected == -3 # Close box
                    if pbConfirm(_INTL("Exit from the Box?"))
                        pbSEPlay("PC close")
                        break
                    end
                    next
                elsif selected < 0
                    next if pbConfirm(_INTL("Continue Box operations?"))
                    break
                else
                    pokemon = @storage[-1, selected]
                    next unless pokemon

                    interactionScene = TilingCardsStorageInteractionMenu_Scene.new(command,pokemon,[-1,selected],nil,self,@scene)
                    interactionScreen = TilingCardsStorageInteractionMenu.new(interactionScene)
                    interactionScreen.pbStartPokemonMenu
                end
            end
            @scene.pbCloseBox
        elsif command == 3
            @scene.pbStartBox(self, command)
            @scene.pbCloseBox
        end
        if command == 4
            return [nil,nil,nil]
        else
            return false
        end
    end

    def pbUpdate # For debug
        @scene.update
    end

    def pbHardRefresh # For debug
        @scene.pbHardRefresh
    end

    def pbRefreshSingle(i) # For debug
        @scene.pbUpdateOverlay(i[1], (i[0] == -1) ? @storage.party : nil, true)
        @scene.pbHardRefresh
    end

    def pbDisplay(message)
        @scene.pbDisplay(message)
    end

    def pbConfirm(str)
        return @scene.pbConfirm(str)
    end

    def pbShowCommands(msg, commands, index = 0)
        return @scene.pbShowCommands(msg, commands, index)
    end

    def pbAble?(pokemon)
        pokemon && !pokemon.egg? && pokemon.hp > 0
    end

    def pbAbleCount
        count = 0
        for p in @storage.party
            count += 1 if pbAble?(p)
        end
        return count
    end

    def pbHeldPokemon
        return @heldpkmn
    end

    def pbWithdraw(selected, heldpoke)
        box = selected[0]
        index = selected[1]
        if @storage[box].isDonationBox?
            pbDisplay(_INTL("Can't withdraw from a donation box.")) 
            return false
        end
        raise _INTL("Can't withdraw from party...") if box == -1
        if @storage.party_full?
            pbDisplay(_INTL("Your party's full!"))
            return false
        end
        @scene.pbWithdraw(selected, heldpoke, @storage.party.length)
        if heldpoke
            @storage.pbMoveCaughtToParty(heldpoke)
            @heldpkmn = nil
        else
            @storage.pbMove(-1, -1, box, index)
        end
        @scene.pbRefresh
        return true
    end

    def pbStore(selected, heldpoke)
        box = selected[0]
        index = selected[1]
        raise _INTL("Can't deposit from box...") if box != -1
        if pbAbleCount <= 1 && pbAble?(@storage[box, index]) && !heldpoke
            pbPlayBuzzerSE
            pbDisplay(_INTL("That's your last Pokémon!"))
        else
            loop do
                destbox = @scene.pbChooseBox(_INTL("Deposit in which Box?"))
                firstfree = @storage.pbFirstFreePos(destbox)
                if firstfree < 0
                    pbDisplay(_INTL("The Box is full."))
                    next
                end
                if destbox >= 0
                    if @storage[destbox].isDonationBox?
                        next unless pbStoreDonation(heldpoke || @storage[-1, index])
                    end
                    if heldpoke || selected[0] == -1
                        p = heldpoke || @storage[-1, index]
                        p.time_form_set = nil
                        p.heal
                        promptToTakeItems(p)
                    end
                    @scene.pbStore(selected, heldpoke, destbox, firstfree)
                    if heldpoke
                        @storage.pbMoveCaughtToBox(heldpoke, destbox)
                        @heldpkmn = nil
                    else
                        @storage.pbMove(destbox, -1, -1, index)
                    end
                end
                break
            end
            @scene.pbRefresh
        end
    end

    def pbHold(selected)
        box = selected[0]
        index = selected[1]
        if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1
            pbPlayBuzzerSE
            pbDisplay(_INTL("That's your last Pokémon!"))
            return
        elsif box > -1 && @storage[box].isDonationBox?
            pbDisplay(_INTL("Can't withdraw from a donation box.")) 
            return false
        end
        @scene.pbHold(selected)
        @heldpkmn = @storage[box, index]
        @storage.pbDelete(box, index)
        @scene.pbRefresh
    end

    def pbPlace(selected)
        box = selected[0]
        index = selected[1]
        raise _INTL("Position {1},{2} is not empty...", box, index) if @storage[box, index]
        if box != -1 && index >= @storage.maxPokemon(box)
            pbDisplay("Can't place that there.")
            return
        end
        if box > -1 && @storage[box].isDonationBox?
            return if !pbStoreDonation(@heldpkmn)
        end
        if box >= 0
            @heldpkmn.time_form_set = nil
            @heldpkmn.heal
            promptToTakeItems(@heldpkmn)
        end
        @scene.pbPlace(selected, @heldpkmn)
        @storage[box, index] = @heldpkmn
        @storage.party.compact! if box == -1
        @scene.pbRefresh
        @heldpkmn = nil
    end

    def pbStoreDonation(heldpokemon)
        command = pbShowCommands(_INTL("Permanently store this Pokémon in exchange for Candies?"), [_INTL("No"), _INTL("Yes")])
        if command == 1
            command = pbShowCommands(_INTL("This Pokémon will not be retrievable after this. Are you sure?"), [_INTL("No"), _INTL("Yes")])
            if command == 1
                pbTakeItemsFromPokemon(heldpokemon) if heldpokemon.hasItem?
                pkmnname = heldpokemon.name
                lifetimeEXP = heldpokemon.exp - heldpokemon.growth_rate.minimum_exp_for_level(heldpokemon.obtain_level)
                pbDisplay(_INTL("{1} was stored forever.", pkmnname))
                candiesFromDonating(lifetimeEXP)
                pbDisplay(_INTL("Bye-bye, {1}!", pkmnname))
            else return false
            end
        else return false
        end
        return true
    end

    def pbChangeLock(boxNumber)
        box = @storage.boxes[boxNumber]
        if box.isLocked?
            box.unlock
            pbDisplay("Box #{boxNumber + 1} is no longer locked to sorting.")
        else
            box.lock
            pbDisplay("Box #{boxNumber + 1} is now locked to sorting.")
        end
    end

    # Returns how many boxes were sorted
    def pbSortAll(sortingType)
        return 0 if @heldpkmn
        
        validBoxes = []
        allPokemonInValidBoxes = []
        
        # Store all pokemon in one big list
        @storage.boxes.each do |box|
            next if box.isLocked? || box.isDonationBox?
            validBoxes.push(box)
            box.each do |pokemon|
                allPokemonInValidBoxes.push(pokemon) if pokemon
            end

            box.clear
        end

        return 0 if allPokemonInValidBoxes.empty?

        # Sort the big pokemon list
        sortPokemonList(allPokemonInValidBoxes,sortingType)

        # Store all pokemon back into storage
        validBoxes.each do |box|
            for indexInBox in 0...PokemonBox::BOX_SIZE
                pokemonToStore = allPokemonInValidBoxes.shift
                break unless pokemonToStore
                box[indexInBox] = pokemonToStore
            end
            break if allPokemonInValidBoxes.length == 0
        end

        @scene.pbHardRefresh

        return validBoxes.length
    end

    # Returns whether the box was sorted or not
    def pbSortBox(sortingType, boxNumber)
        box = @storage.boxes[boxNumber]
        return false if @heldpkmn
        return false if box.isLocked?
        return false if box.empty?
        nitems = box.nitems - 1
        listOfPokemon = []
        dicttosort = {}
        for i in 0..PokemonBox::BOX_SIZE
            listOfPokemon.push(box[i]) if box[i]
        end

        sortPokemonList(listOfPokemon,sortingType)

        for i in 0..nitems
            dicttosort[listOfPokemon[i]] = i
        end

		anyMoved = false
        for i in 0..PokemonBox::BOX_SIZE
            while dicttosort[@storage[boxNumber, i]] != i
                break unless @storage[boxNumber, i]
                toswap = box[i]
                destination = dicttosort[toswap]

				next if destination == i # No swap to happen

				# Actually perform the swap
                temp = box[destination]
                box[destination] = toswap
                box[i] = temp

				anyMoved = true
            end
        end
        @scene.pbHardRefresh
        return anyMoved
    end

    def sortPokemonList(listToSort,sortingType)
        if sortingType == 1 # Name
            listToSort.sort! { |a, b|
                if a.name != b.name
                    a.name <=> b.name
                elsif a.species == b.species
                    a.form <=> b.form
                else
                    a.personalID <=> b.personalID
                end
            }
        elsif sortingType == 2 # Species
            listToSort.sort! { |a, b|
                if a.speciesName != b.speciesName
                    a.speciesName <=> b.speciesName
                elsif a.form != b.form
                    a.form <=> b.form
                else
                    a.personalID <=> b.personalID
                end
            }
        elsif sortingType == 3 # DexID
            listToSort.sort! { |a, b|
                if a.species != b.species
                    idNumberA = GameData::Species.get(a.species).id_number
                    idNumberB = GameData::Species.get(b.species).id_number
                    idNumberA <=> idNumberB
                elsif a.form != b.form
                    a.form <=> b.form
                else
                    a.personalID <=> b.personalID
                end
            }
        elsif sortingType == 4 # Type - Type 1 then Type 2 on colissions
            listToSort.sort! { |a, b|
                typeIDListA = []
                typeIDListB = []
                a.types.each do |typeSymbol|
                    typeIDListA.push(GameData::Type.get(typeSymbol).id_number)
                end
                b.types.each do |typeSymbol|
                    typeIDListB.push(GameData::Type.get(typeSymbol).id_number)
                end
                typeIDListA.sort!
                typeIDListB.sort!
                if typeIDListA != typeIDListB
                    typeIDListA <=> typeIDListB
                elsif a.form != b.form
                    a.form <=> b.form
                else
                    a.personalID <=> b.personalID
                end
            }   
        elsif sortingType == 5 # Level
            listToSort.sort! { |a, b|
                if a.level != b.level
                    b.level <=> a.level # Order inverted so higher level is earlier
                elsif a.species != b.species
                    idNumberA = GameData::Species.get(a.species).id_number
                    idNumberB = GameData::Species.get(b.species).id_number
                    idNumberA <=> idNumberB
                elsif a.form != b.form
                    a.form <=> b.form
                else
                    a.personalID <=> b.personalID
                end
            }
        end
    end

    def pbSwap(selected)
        box = selected[0]
        index = selected[1]
        raise _INTL("Position {1},{2} is empty...", box, index) unless @storage[box, index]
        if box == -1 && pbAble?(@storage[box, index]) && pbAbleCount <= 1 && !pbAble?(@heldpkmn)
            pbPlayBuzzerSE
            pbDisplay(_INTL("That's your last Pokémon!"))
            return false
        end
        if box >= 0
            @heldpkmn.time_form_set = nil
            @heldpkmn.heal
            promptToTakeItems(@heldpkmn)
        end
        @scene.pbSwap(selected, @heldpkmn)
        tmp = @storage[box, index]
        @storage[box, index] = @heldpkmn
        @heldpkmn = tmp
        @scene.pbRefresh
        return true
    end

    def pbRelease(selected, heldpoke)
        box = selected[0]
        index = selected[1]
        pokemon = heldpoke || @storage[box, index]
        return unless pokemon
        if pokemon.egg?
            pbDisplay(_INTL("You can't release an Egg."))
            return false
        end
        if box == -1 && pbAbleCount <= 1 && pbAble?(pokemon) && !heldpoke
            pbPlayBuzzerSE
            pbDisplay(_INTL("That's your last Pokémon!"))
            return
        end
        command = pbShowCommands(_INTL("Are you sure you want to release this pokemon?"), [_INTL("No"), _INTL("Yes")])
        if command == 1
            command = pbShowCommands(_INTL("They will be gone forever. Are you sure?"), [_INTL("No"), _INTL("Yes")])
            if command == 1
                pkmnname = pokemon.name
                @scene.pbRelease(selected, heldpoke)
                if heldpoke
                    @heldpkmn = nil
                else
                    @storage.pbDelete(box, index)
                end
                @scene.pbRefresh
                pbDisplay(_INTL("{1} was released.", pkmnname))
                pbDisplay(_INTL("Bye-bye, {1}!", pkmnname))
                @scene.pbRefresh
            end
        end
        return
    end

    CANDY_EXCHANGE_EFFICIENCY = 1.0

    def candiesFromDonating(lifetimeEXP)
        lifetimeEXP = (lifetimeEXP * CANDY_EXCHANGE_EFFICIENCY).floor
        if lifetimeEXP > 0
            xsCandyTotal, sCandyTotal, mCandyTotal, _lCandyTotal = calculateCandySplitForEXP(lifetimeEXP)
            if (xsCandyTotal + sCandyTotal + mCandyTotal) == 0
                pbDisplay(_INTL("It didn't earn enough XP for you to earn any candies back."))
            else
                percentile = (CANDY_EXCHANGE_EFFICIENCY * 100).to_i
                pbDisplay(_INTL("You are reimbursed for #{percentile} percent of the EXP it earned."))
                pbReceiveItem(:EXPCANDYM, mCandyTotal) if mCandyTotal > 0
                pbReceiveItem(:EXPCANDYS, sCandyTotal) if sCandyTotal > 0
                pbReceiveItem(:EXPCANDYXS, xsCandyTotal) if xsCandyTotal > 0
            end
        else
            pbDisplay(_INTL("It never gained any EXP, so no candies are awarded."))
        end
    end

    def pbChooseMove(pkmn, helptext, index = 0)
        movenames = []
        for i in pkmn.moves
            if i.total_pp <= 0
                movenames.push(_INTL("{1} (PP: ---)", i.name))
            else
                movenames.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
            end
        end
        return @scene.pbShowCommands(helptext, movenames, index)
    end

    def pbSummary(selected, heldpoke)
        @scene.pbSummary(selected, heldpoke)
    end

    def pbMark(selected, heldpoke)
        @scene.pbMark(selected, heldpoke)
    end

    def pbGiveItem(pokemon)
        item = scene.pbChooseItem($PokemonBag)
        @scene.pbHardRefresh if item && pbGiveItemToPokemon(item, pokemon, scene)
    end

    def pbTakeItem(pokemon)
        @scene.pbHardRefresh if pbTakeItemsFromPokemon(pokemon) > 0
    end

    def pbUseItem(pokemon)
        item = selectItemForUseOnPokemon($PokemonBag,pokemon)
        return unless item
        pbUseItemOnPokemon(item,pokemon)
        @scene.pbHardRefresh
    end

    def pbBoxCommands(selectionMode = false)
        jumpCommand = -1
        wallPaperCommand = -1
        nameCommand = -1
        searchCommand = -1
        lockCommand = -1
        sortCommand = -1
        sortAllCommand = -1
        visitEstateCommand = -1
        cancelCommand = -1
        command = 0

        donationBox = @storage.boxes[@storage.currentBox].isDonationBox?

        loop do
            commands = []
            commands[jumpCommand = commands.length]         = _INTL("Jump")
            unless selectionMode || donationBox
                commands[wallPaperCommand = commands.length]    = _INTL("Wallpaper")
                commands[nameCommand = commands.length]         = _INTL("Name")
            end
            commands[searchCommand = commands.length]       = _INTL("Search")
            unless selectionMode || donationBox
                commands[sortCommand = commands.length]         = _INTL("Sort")
                commands[sortAllCommand = commands.length]      = _INTL("Sort All")
                commands[lockCommand = commands.length]         =
                    @storage.boxes[@storage.currentBox].isLocked? ? _INTL("Sort Unlock") : _INTL("Sort Lock")
                if defined?(PokEstate) && !getGlobalSwitch(ESTATE_DISABLED_SWITCH)
                    commands[visitEstateCommand = commands.length] = _INTL("Visit PokÉstate")
                end
            end
            commands[cancelCommand = commands.length]       = _INTL("Cancel")
            command = pbShowCommands(_INTL("What do you want to do?"), commands, command)
            if command == jumpCommand && jumpCommand > -1
                destbox = @scene.pbChooseBox(_INTL("Jump to which Box?"))
                @scene.pbJumpToBox(destbox) if destbox >= 0
            elsif command == wallPaperCommand && wallPaperCommand > -1
                papers = @storage.availableWallpapers
                index = 0
                for i in 0...papers[1].length
                    if papers[1][i] == @storage[@storage.currentBox].background
                        index = i
                        break
                    end
                end
                wpaper = pbShowCommands(_INTL("Pick the wallpaper."), papers[0], index)
                @scene.pbChangeBackground(papers[1][wpaper]) if wpaper >= 0
            elsif command == nameCommand && nameCommand > -1
                @scene.pbBoxName(_INTL("Box name?"), 0, 12)
            elsif command == visitEstateCommand && visitEstateCommand > -1
                if heldpkmn
                    @scene.pbDisplay("Can't Visit the PokÉstate while you have a Pokémon in your hand!")
                    return false
                end
                if @storage.boxes[@storage.currentBox].isDonationBox?
                    @scene.pbDisplay("Can't visit donation boxes.")
                    return false
                end
                $PokEstate.transferToEstate(@storage.currentBox, 0)
                return true
            elsif command == searchCommand && searchCommand > -1
                searchMethod = @scene.pbChooseSearch(_INTL("Search how?"))
                next unless searchMethod > 0
                case searchMethod
                when 1
                    searchPrompt = _INTL("Which name?")
                when 2
                    searchPrompt = _INTL("Which species?")
                when 3
                    searchPrompt = _INTL("Which type?")
                when 4
                    searchPrompt = _INTL("Which tribe?")
                end

                next unless @scene.pbSearch(searchPrompt, 0, 12, searchMethod)
            elsif command == lockCommand && lockCommand > -1
                pbChangeLock(@storage.currentBox)
                next
            elsif command == sortCommand && sortCommand > -1
                if @heldpkmn
                    @scene.pbDisplay(_INTL("Can't sort while you have a Pokémon in your hand!"))
                    next
                end
                if @storage.boxes[@storage.currentBox].isLocked?
                    @scene.pbDisplay(_INTL("The box is sort locked!"))
                    next
                end
                if @storage.boxes[@storage.currentBox].empty?
                    @scene.pbDisplay(_INTL("The box is empty."))
                    next
                end
                sortMethod = @scene.pbChooseSort(_INTL("How will you sort?"))
                next unless sortMethod > 0
                unless pbSortBox(sortMethod, @storage.currentBox)
					@scene.pbDisplay(_INTL("Each Pokémon is already in the right place!"))
				end
            elsif command == sortAllCommand && sortAllCommand > -1
                if @heldpkmn
                    @scene.pbDisplay(_INTL("Can't sort while you have a Pokémon in your hand!"))
                    next
                end
                sortMethod = @scene.pbChooseSort(_INTL("How will you sort?"))
                next unless sortMethod > 0
                boxesSorted = pbSortAll(sortMethod)
                if boxesSorted == 0
                    @scene.pbDisplay(_INTL("No boxes were sorted."))
                elsif boxesSorted == 1
                    @scene.pbDisplay(_INTL("Only one box was sorted."))
                else
                    @scene.pbDisplay(_INTL("#{boxesSorted} boxes were sorted!"))
                end
            end
            break
        end
        return false
    end

    def pbChoosePokemon(_party = nil)
        @heldpkmn = nil
        @scene.pbStartBox(self, 1)
        retval = nil
        loop do
            selected = @scene.pbSelectBox(@storage.party)
            if selected && selected[0] == -3 # Close box
                if pbConfirm(_INTL("Exit from the Box?"))
                    pbSEPlay("PC close")
                    break
                end
                next
            end
            if selected.nil?
                next if pbConfirm(_INTL("Continue Box operations?"))
                break
            elsif selected[0] == -4   # Box name
                pbBoxCommands
            else
                pokemon = @storage[selected[0], selected[1]]
                next unless pokemon

                retValWrapper = [false]
                interactionScene = TilingCardsStorageInteractionMenu_Scene.new(5,pokemon,selected,nil,self,@scene,retValWrapper)
                interactionScreen = TilingCardsStorageInteractionMenu.new(interactionScene)
                interactionScreen.pbStartPokemonMenu
                if retValWrapper[0]
                    retval = selected
                    break
                end
            end
        end
        @scene.pbCloseBox
        return retval
    end
end

def pbChooseBoxPokemon(variableNumber,storageLocVarNumber,ableProc=nil)
	chosenPkmn = nil
    storageBox = nil
    boxLocation = nil
	pbFadeOutIn {
		scene = PokemonStorageScene.new
        screen = PokemonStorageScreen.new(scene, $PokemonStorage)
		chosenPkmn,storageBox,boxLocation = screen.pbStartScreen(4,ableProc)
	}
	pbSet(variableNumber,chosenPkmn)
	pbSet(storageLocVarNumber,[storageBox,boxLocation])
end

def boxPokemonChosen?
    return pbGet(1).is_a?(Pokemon)
end