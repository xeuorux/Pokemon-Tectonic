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
            @scene.pbStartBox(self, command)
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
                        if ableProc.nil? || ableProc.call(pokemon)
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
                        commands = []
                        cmdMove = -1
                        cmdOmniTutor = -1
                        cmdSummary  = -1
                        cmdWithdraw = -1
                        cmdGiveItem = -1
                        cmdTakeItem = -1
                        cmdMark     = -1
                        cmdRelease  = -1
                        cmdPokedex  = -1
                        cmdDebug    = -1
                        cmdCancel   = -1

                        selectedPokemon = nil
                        if heldpoke
                            helptext = _INTL("{1} is selected.", heldpoke.name)
                            commands[cmdMove = commands.length] = pokemon ? _INTL("Shift") : _INTL("Place")
                            selectedPokemon = heldpoke
                        elsif pokemon
                            helptext = _INTL("{1} is selected.", pokemon.name)
                            commands[cmdMove = commands.length] = _INTL("Move")
                            selectedPokemon = pokemon
                        end
                        commands[cmdOmniTutor = commands.length] = _INTL("OmniTutor") if selectedPokemon &&
                                                                                         $PokemonGlobal.omnitutor_active && getOmniMoves(selectedPokemon).length != 0
                        commands[cmdSummary = commands.length] = _INTL("Summary")
                        commands[cmdPokedex = commands.length] = _INTL("MasterDex") if $Trainer.has_pokedex
                        commands[cmdWithdraw = commands.length] =
                            (selected[0] == -1) ? _INTL("Store") : _INTL("Withdraw")
                        commands[cmdGiveItem = commands.length]     = _INTL("Give Item")
                        commands[cmdTakeItem = commands.length]     = _INTL("Take Item") if selectedPokemon.hasItem?
                        commands[cmdMark = commands.length]     = _INTL("Mark")
                        commands[cmdRelease = commands.length]  = _INTL("Candy Exchange")
                        commands[cmdDebug = commands.length]    = _INTL("Debug") if $DEBUG
                        commands[cmdCancel = commands.length]   = _INTL("Cancel")
                        command = pbShowCommands(helptext, commands)
                        if cmdMove >= 0 && command == cmdMove # Move/Shift/Place
                            if @heldpkmn
                                pokemon ? pbSwap(selected) : pbPlace(selected)
                            else
                                pbHold(selected)
                            end
                        elsif cmdSummary >= 0 && command == cmdSummary # Summary
                            pbSummary(selected, @heldpkmn)
                        elsif cmdWithdraw >= 0 && command == cmdWithdraw   # Store/Withdraw
                            (selected[0] == -1) ? pbStore(selected, @heldpkmn) : pbWithdraw(selected, @heldpkmn)
                        elsif cmdGiveItem >= 0 && command == cmdGiveItem   # Give Item
                            pbGiveItem(selectedPokemon)
                        elsif cmdTakeItem >= 0 && command == cmdTakeItem   # Take Item
                            pbTakeItem(selectedPokemon)
                        elsif cmdMark >= 0 && command == cmdMark # Mark
                            pbMark(selected, @heldpkmn)
                        elsif cmdRelease >= 0 && command == cmdRelease # Release
                            pbRelease(selected, @heldpkmn)
                        elsif cmdPokedex >= 0 && command == cmdPokedex # Pokedex
                            openSingleDexScreen(@heldpkmn || pokemon)
                        elsif cmdDebug >= 0 && command == cmdDebug # Debug
                            pbPokemonDebug(@heldpkmn || pokemon, selected, heldpoke)
                        elsif cmdOmniTutor >= 0 && command == cmdOmniTutor
                            omniTutorScreen(selectedPokemon)
                        end
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
                    cmdWithdraw = -1
                    cmdSummary = -1
                    cmdPokedex = -1
                    cmdMark = -1
                    cmdRelease = -1
                    commands = []
                    commands[cmdWithdraw = commands.length] = _INTL("Withdraw")
                    commands[cmdSummary = commands.length] = _INTL("Summary")
                    commands[cmdPokedex = commands.length] = _INTL("MasterDex") if $Trainer.has_pokedex
                    commands[cmdMark = commands.length] = _INTL("Mark")
                    commands[cmdRelease = commands.length] = _INTL("Candy Exchange")
                    commands.push(_INTL("Cancel"))
                    command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), commands)
                    if cmdWithdraw > -1 && command == cmdWithdraw
                        pbWithdraw(selected, nil)
                    elsif cmdSummary > -1 && command == cmdSummary
                        pbSummary(selected, nil)
                    elsif cmdMark > -1 && command == cmdMark
                        pbMark(selected, nil)
                    elsif	cmdRelease > -1 && command == cmdRelease
                        pbRelease(selected, nil)
                    elsif	cmdPokedex > -1 && command == cmdPokedex
                        $Trainer.pokedex.register_last_seen(pokemon)
                        pbFadeOutIn do
                            scene = PokemonPokedexInfo_Scene.new
                            screen = PokemonPokedexInfoScreen.new(scene)
                            screen.pbStartSceneSingle(pokemon.species)
                        end
                    end
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
                    cmdStore = -1
                    cmdSummary = -1
                    cmdPokedex = -1
                    cmdMark = -1
                    cmdRelease = -1
                    commands = []
                    commands[cmdStore = commands.length] = _INTL("Store")
                    commands[cmdSummary = commands.length] = _INTL("Summary")
                    commands[cmdPokedex = commands.length] = _INTL("MasterDex") if $Trainer.has_pokedex
                    commands[cmdMark = commands.length] = _INTL("Mark")
                    commands[cmdRelease = commands.length] = _INTL("Candy Exchange")
                    commands.push(_INTL("Cancel"))
                    command = pbShowCommands(_INTL("{1} is selected.", pokemon.name), commands)
                    if cmdStore > -1 && command == cmdStore
                        pbStore([-1, selected], nil)
                    elsif cmdSummary > -1 && command == cmdSummary
                        pbSummary([-1, selected], nil)
                    elsif cmdMark > -1 && command == cmdMark
                        pbMark([-1, selected], nil)
                    elsif	cmdRelease > -1 && command == cmdRelease
                        pbRelease([-1, selected], nil)
                    elsif	cmdPokedex > -1 && command == cmdPokedex
                        $Trainer.pokedex.register_last_seen(pokemon)
                        pbFadeOutIn do
                            scene = PokemonPokedexInfo_Scene.new
                            screen = PokemonPokedexInfoScreen.new(scene)
                            screen.pbStartSceneSingle(pokemon.species)
                        end
                    end
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
        @scene.pbUpdateOverlay(i[1], (i[0] == -1) ? @storage.party : nil)
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
                if @storage[destbox].isDonationBox?
                    pbStoreDonation(heldpoke || @storage[-1, index])
                elsif destbox >= 0
                    firstfree = @storage.pbFirstFreePos(destbox)
                    if firstfree < 0
                        pbDisplay(_INTL("The Box is full."))
                        next
                    end
                    if heldpoke || selected[0] == -1
                        p = heldpoke || @storage[-1, index]
                        p.time_form_set = nil
                        p.form          = 0 if p.isSpecies?(:SHAYMIN)
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
            @heldpkmn.form = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
            @heldpkmn.heal
            # promptToTakeItems(@heldpkmn)
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
                pkmnname = heldpokemon.name
                lifetimeEXP = heldpokemon.exp - heldpokemon.growth_rate.minimum_exp_for_level(heldpokemon.obtain_level)
                pbDisplay(_INTL("{1} was stored forever.", pkmnname))
                candiesFromReleasing(lifetimeEXP)
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
            @heldpkmn.form = 0 if @heldpkmn.isSpecies?(:SHAYMIN)
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
        command = pbShowCommands(_INTL("Release this Pokémon in exchange for Candies?"), [_INTL("No"), _INTL("Yes")])
        if command == 1
            pkmnname = pokemon.name
            lifetimeEXP = pokemon.exp - pokemon.growth_rate.minimum_exp_for_level(pokemon.obtain_level)
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
            candiesFromReleasing(lifetimeEXP)
        end
        return
    end

    CANDY_EXCHANGE_EFFICIENCY = 1.0

    def candiesFromReleasing(lifetimeEXP)
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
        loop do
            commands = []
            commands[jumpCommand = commands.length]         = _INTL("Jump")
            unless selectionMode
                commands[wallPaperCommand = commands.length]    = _INTL("Wallpaper")
                commands[nameCommand = commands.length]         = _INTL("Name")
            end
            commands[searchCommand = commands.length]       = _INTL("Search")
            unless selectionMode || @storage.boxes[@storage.currentBox].isDonationBox?
                commands[sortCommand = commands.length]         = _INTL("Sort")
                commands[sortAllCommand = commands.length]      = _INTL("Sort All")
                commands[lockCommand = commands.length]         =
                    @storage.boxes[@storage.currentBox].isLocked? ? _INTL("Sort Unlock") : _INTL("Sort Lock")
                if defined?(PokEstate) && !$game_switches[ESTATE_DISABLED_SWITCH]
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
                cmdSelect = -1
                cmdSummary = -1
                cmdStore = -1
                cmdWithdraw = -1
                cmdGiveItem = -1
                cmdTakeItem = -1
                cmdMark = -1
                commands = []
                commands[cmdSelect = commands.length] = _INTL("Select")
                commands[cmdSummary = commands.length] = _INTL("Summary")
                if selected[0] == -1
                    commands[cmdStore = commands.length] = _INTL("Store")
                else
                    commands[cmdWithdraw = commands.length] = _INTL("Withdraw")
                end
                commands[cmdGiveItem = commands.length] = _INTL("Give Item")
                commands[cmdTakeItem = commands.length] = _INTL("Take Item") if pokemon.hasItem?
                commands[cmdMark = commands.length] = _INTL("Mark")
                commands.push(_INTL("Cancel"))
                helptext = _INTL("{1} is selected.", pokemon.name)
                command = pbShowCommands(helptext, commands)
                if command == cmdSelect && cmdSelect > -1
                    if pokemon
                        retval = selected
                        break
                    end
                elsif command == cmdSummary && cmdSummary > -1
                    pbSummary(selected, nil)
                elsif command == cmdStore && cmdStore > -1
                    pbStore(selected, nil)
                elsif command == cmdWithdraw && cmdWithdraw > -1
                    pbWithdraw(selected, nil)
                elsif command == cmdGiveItem && cmdGiveItem > -1
                    pbGiveItem(selected)
                elsif command == cmdTakeItem && cmdTakeItem > -1
                    pbTakeItem(selected)
                elsif command == cmdMark && cmdMark > 1
                    pbMark(selected, nil)
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